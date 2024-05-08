// 2D mesh NoC router
//
// This module is a 5x5 router with 1 local port and 4 link ports (north, south, west, east) to
// route data. The routing algorithm is XY Dimension Order. The router uses a worm-hole flow-control
// at network level and an ACK/NACK or credit-based flow control at link level. Links can tolerate
// wire pipeline through the insertion of relay stations. The router implements routing look-ahead,
// performing routing for the following hop and carrying the routing result into the head flit of
// the worm. In case of incoming head flit directed to a free output without contention the flit is
// forwarded in a single clock cycle. In case of contention, the worm arriving from the port with
// the current highest priority is forwarded one cycle after the tail flit of the previous worm.
//
// This module has been implemented in SystemVerilog based on the original VHDL implementation from
// the Columbia University open-source project ESP: https://github.com/sld-columbia/esp
//
// The original copyright notice and author information are included below.
//
// Interface
//
// * Inputs
// - clk: all signals are synchronous to this clock signal.
// - rst: active high reset
// - position: static input that encodes the x,y coordinates of the router on the mesh.
// - data_X_in: input data for each port (North, South, West, East, Local).
// - data_void_in: each bit indicates if the corresponding data_X_in holds valid data.
// - stop_in: when using ACK/NACK flow control, stop_in[X] is 0 to indicate that the corresponding
//   output port X is ready to accept a new flit; when using credit-based flow control, stop_in[X]
//   is 0 to send credits back for the output port X.
//
// * Outputs
// - data_X_out: output data for each port (North, South, West, East, Local).
// - data_void_out: each bit indicates if the corresponding data_X_out holds valid data.
// - stop_out: when using ACK/NACK flow control, stop_out[X] is 0 to indicate that the corresponding
//   input port X is ready to accept a new flit; when using credit-based flow control, stop_in[X] is
//   0 to send credits back for the input port X.
//
// * Parameters
// - FlowControl: either ACK/NACK (stop-void) or credit-based
// - DataWidth: width of the router port, except for the two preaamble bits indicating head and
//   tail. DataWidth must be large enough to hold the header flit information for routing:
//   DataWidth > $bits(noc::packet_info_t) + $bits(noc::direction_t).
// - PortWidth: DataWidth + 2. This parameter is used to define input ports.
//   and should not be overwritten.
// - Ports: each bit is set to 1 to indicate that the corresponding input and output port is
//   enabled. This parameter can be used to disable ports on the fringe of the NoC mesh.
//

////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2011-2022 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
// Author: Michele Petracca
////////////////////////////////////////////////////////////////////////////////

module lookahead_router #(
    parameter noc::noc_flow_control_t FlowControl = noc::kFlowControlAckNack,
    parameter int unsigned DataWidth = 32,
    parameter int unsigned PortWidth = DataWidth + $bits(noc::preamble_t),
    parameter bit [4:0] Ports = noc::AllPorts
) (
    input  logic clk,
    input  logic rst,
    // Coordinates
    input  noc::xy_t position,
    // Input ports
    input  logic [PortWidth-1:0] data_n_in,
    input  logic [PortWidth-1:0] data_s_in,
    input  logic [PortWidth-1:0] data_w_in,
    input  logic [PortWidth-1:0] data_e_in,
    input  logic [PortWidth-1:0] data_p_in,
    input  logic [4:0] data_void_in,
    output logic [4:0] stop_out,
    // Output ports
    output logic [PortWidth-1:0] data_n_out,
    output logic [PortWidth-1:0] data_s_out,
    output logic [PortWidth-1:0] data_w_out,
    output logic [PortWidth-1:0] data_e_out,
    output logic [PortWidth-1:0] data_p_out,
    output logic [4:0] data_void_out,
    input  logic [4:0] stop_in
);

    localparam bit FifoBypassEnable = FlowControl == noc::kFlowControlAckNack;

    localparam int unsigned ReservedWidth = DataWidth - $bits(
        noc::packet_info_t
    ) - $bits(
        noc::direction_t
    );

    typedef struct packed {
        noc::preamble_t preamble;
        noc::packet_info_t info;
        logic [ReservedWidth-1:0] reserved;
        noc::direction_t routing;
    } header_t;

    typedef logic [PortWidth-1:0] payload_t;

    typedef union packed {
        header_t  header;
        payload_t flit;
    } flit_t;

    typedef enum logic {
        kHeadFlit     = 1'b0,
        kPayloadFlits = 1'b1
    } state_t;

    state_t [4:0] state;
    state_t [4:0] new_state;

    flit_t [4:0] data_in;
    flit_t [4:0] fifo_head;
    flit_t [4:0] data_out_crossbar;
    flit_t [4:0] last_flit;

    logic [4:0][4:0] saved_routing_request;
    logic [4:0][4:0] final_routing_request;  // ri lint_check_waive NOT_READ
    logic [4:0][4:0] next_hop_routing;

    logic [4:0][3:0] transp_final_routing_request;

    logic [4:0][4:0] enhanc_routing_configuration;

    logic [4:0][3:0] routing_configuration;
    logic [4:0][3:0] saved_routing_configuration;
    logic [4:0][3:0] grant;
    logic [4:0] grant_valid;

    logic [4:0][4:0] rd_fifo;
    logic [4:0] no_backpressure;
    logic [4:0] rd_fifo_or;

    logic [4:0] in_unvalid_flit;
    logic [4:0] out_unvalid_flit;
    logic [4:0] in_valid_head;

    logic [4:0] full;
    logic [4:0] empty;
    logic [4:0] wr_fifo;

    noc::credits_t credits;

    logic [4:0] forwarding_tail;
    logic [4:0] forwarding_head;
    logic [4:0] forwarding_in_progress;
    logic [4:0] insert_lookahead_routing;

    assign data_in[noc::kNorthPort] = data_n_in;
    assign data_in[noc::kSouthPort] = data_s_in;
    assign data_in[noc::kWestPort] = data_w_in;
    assign data_in[noc::kEastPort] = data_e_in;
    assign data_in[noc::kLocalPort] = data_p_in;

    // This router has a single cycle delay.
    // When using ready-valid protocol, the register is placed at the output; for credit-based,
    // the register is the input FIFO (not bypassable) and the output of the crossbar is not
    // registered.
    assign data_n_out = FifoBypassEnable ? last_flit[noc::kNorthPort] :
                      data_out_crossbar[noc::kNorthPort];
    assign data_s_out = FifoBypassEnable ? last_flit[noc::kSouthPort] :
                      data_out_crossbar[noc::kSouthPort];
    assign data_w_out = FifoBypassEnable ? last_flit[noc::kWestPort]  :
                      data_out_crossbar[noc::kWestPort];
    assign data_e_out = FifoBypassEnable ? last_flit[noc::kEastPort]  :
                      data_out_crossbar[noc::kEastPort];
    assign data_p_out = FifoBypassEnable ? last_flit[noc::kLocalPort] :
                      data_out_crossbar[noc::kLocalPort];

    genvar g_i;

    //////////////////////////////////////////////////////////////////////////////
    // Input FIFOs and look-ahead routing
    //////////////////////////////////////////////////////////////////////////////
    for (g_i = 0; g_i < 5; g_i++) begin : gen_input_fifo
        if (Ports[g_i]) begin : gen_input_port_enabled

            // Read FIFO if any of the output ports requests data.
            // The FIFO won't update read pointer if empty
            assign rd_fifo_or[g_i] = rd_fifo[0][g_i] | rd_fifo[1][g_i] | rd_fifo[2][g_i] |
                               rd_fifo[3][g_i] | rd_fifo[4][g_i];

            // Write FIFO if data is valid.
            // The FIFO won't accept the write if full.
            assign wr_fifo[g_i] = ~data_void_in[g_i];

            // Input FIFO
            router_fifo #(
                .BypassEnable(FifoBypassEnable),
                .Depth(noc::PortQueueDepth),
                .Width(PortWidth)
            ) input_queue (
                .clk,
                .rst,
                .rdreq(rd_fifo_or[g_i]),
                .wrreq(wr_fifo[g_i]),
                .data_in(data_in[g_i]),
                .empty(empty[g_i]),
                .full(full[g_i]),
                .data_out(fifo_head[g_i])
            );

            assign in_unvalid_flit[g_i] = FifoBypassEnable ? empty[g_i] & data_void_in[g_i] : empty[g_i];
            assign in_valid_head[g_i] = fifo_head[g_i].header.preamble.head & ~in_unvalid_flit[g_i];

            always_ff @(posedge clk) begin
                if (rst) begin
                    saved_routing_request[g_i] <= '0;
                end else begin
                    if (fifo_head[g_i].header.preamble.tail) begin
                        // Clear saved_routing_request if tail is next
                        saved_routing_request[g_i] <= '0;
                    end else if (in_valid_head[g_i]) begin
                        // Sample saved_routing_request if valid head flit
                        saved_routing_request[g_i] <= fifo_head[g_i].header.routing;
                    end
                end
            end

            assign final_routing_request[g_i] = in_valid_head[g_i] ? fifo_head[g_i].header.routing :
                                            saved_routing_request[g_i];

            // AckNack: stop data at input port if FIFO is full
            // CreditBased: send credits when reading from the input FIFO
            assign stop_out[g_i] =  FifoBypassEnable ? full[g_i] :
                                ~(rd_fifo_or[g_i] & ~in_unvalid_flit[g_i]);

            lookahead_routing lookahead_routing_i (
                .clk,
                .position,
                .destination(fifo_head[g_i].header.info.destination),
                .current_routing(fifo_head[g_i].header.routing),
                .next_routing(next_hop_routing[g_i])
            );

        end else begin : gen_input_port_disabled

            assign stop_out[g_i]              = 1'b1;
            assign final_routing_request[g_i] = '0;
            assign saved_routing_request[g_i] = '0;
            assign in_unvalid_flit[g_i]       = '1;
            assign fifo_head[g_i]             = '0;
            assign empty[g_i]                 = 1'b1;
            assign full[g_i]                  = '0;
            assign next_hop_routing[g_i]      = '0;
            assign rd_fifo_or[g_i]            = '0;
            assign wr_fifo[g_i]               = '0;
            assign in_valid_head[g_i]         = 1'b0;

        end  // if (Ports[g_i])

    end  // for gen_input_fifo


    //////////////////////////////////////////////////////////////////////////////
    // Output crossbar and arbitration
    //////////////////////////////////////////////////////////////////////////////
    for (g_i = 0; g_i < 5; g_i++) begin : gen_output_control
        if (Ports[g_i]) begin : gen_output_port_enabled

            genvar g_j;
            for (g_j = 0; g_j < 5; g_j++) begin : gen_transpose_routing
                // transpose current routing request for easier accesss, but
                // allow routing only to output port different from input port
                if (g_j < g_i) begin : gen_transpose_routin_j_lt_i
                    assign transp_final_routing_request[g_i][g_j] = final_routing_request[g_j][g_i];
                    assign enhanc_routing_configuration[g_i][g_j] = routing_configuration[g_i][g_j];
                end else if (g_j > g_i) begin : gen_transpose_routin_j_gt_i
                    assign transp_final_routing_request[g_i][g_j-1] = final_routing_request[g_j][g_i];
                    assign enhanc_routing_configuration[g_i][g_j] = routing_configuration[g_i][g_j-1];
                end else begin : gen_transpose_routin_j_eq_i
                    assign enhanc_routing_configuration[g_i][g_j] = 1'b0;
                end
            end  // for gen_transpose_routing

            // Arbitration
            router_arbiter arbiter_i (
                .clk(clk),
                .rst(rst),
                .request(transp_final_routing_request[g_i]),
                .forwarding_head(forwarding_head[g_i]),
                .forwarding_tail(forwarding_tail[g_i]),
                .grant(grant[g_i]),
                .grant_valid(grant_valid[g_i])
            );

            // Sample current routing configuration
            always_ff @(posedge clk) begin
                if (forwarding_in_progress[g_i]) begin
                    saved_routing_configuration[g_i] <= routing_configuration[g_i];
                end
            end

            // Set to overwrite routing info only on the head flit
            always_ff @(posedge clk) begin
                if (rst) begin
                    // First flit must be head
                    insert_lookahead_routing[g_i] <= 1'b1;
                end else begin
                    if (forwarding_tail[g_i]) begin
                        // Next flit will be head (convers single-flit packet)
                        insert_lookahead_routing[g_i] <= 1'b1;
                    end else if (forwarding_head[g_i]) begin
                        // Next flit will not be head
                        insert_lookahead_routing[g_i] <= 1'b0;
                    end
                end
            end

            // Crossbar
            always_comb begin
                data_out_crossbar[g_i] = '0;
                rd_fifo[g_i]           = '0;
                out_unvalid_flit[g_i]  = 1'b1;

                unique case (enhanc_routing_configuration[g_i])
                    noc::goNorth: begin
                        data_out_crossbar[g_i] = ~insert_lookahead_routing[g_i] ? fifo_head[noc::kNorthPort] :
            {fifo_head[noc::kNorthPort].flit[PortWidth-1:5], next_hop_routing[noc::kNorthPort]};
                        rd_fifo[g_i][noc::kNorthPort] = no_backpressure[g_i];
                        out_unvalid_flit[g_i] = in_unvalid_flit[noc::kNorthPort];
                    end

                    noc::goSouth: begin
                        data_out_crossbar[g_i] = ~insert_lookahead_routing[g_i] ? fifo_head[noc::kSouthPort] :
              {fifo_head[noc::kSouthPort].flit[PortWidth-1:5], next_hop_routing[noc::kSouthPort]};
                        rd_fifo[g_i][noc::kSouthPort] = no_backpressure[g_i];
                        out_unvalid_flit[g_i] = in_unvalid_flit[noc::kSouthPort];
                    end

                    noc::goWest: begin
                        data_out_crossbar[g_i] = ~insert_lookahead_routing[g_i] ? fifo_head[noc::kWestPort] :
              {fifo_head[noc::kWestPort].flit[PortWidth-1:5], next_hop_routing[noc::kWestPort]};
                        rd_fifo[g_i][noc::kWestPort] = no_backpressure[g_i];
                        out_unvalid_flit[g_i] = in_unvalid_flit[noc::kWestPort];
                    end

                    noc::goEast: begin
                        data_out_crossbar[g_i] = ~insert_lookahead_routing[g_i] ? fifo_head[noc::kEastPort] :
              {fifo_head[noc::kEastPort].flit[PortWidth-1:5], next_hop_routing[noc::kEastPort]};
                        rd_fifo[g_i][noc::kEastPort] = no_backpressure[g_i];
                        out_unvalid_flit[g_i] = in_unvalid_flit[noc::kEastPort];
                    end

                    noc::goLocal: begin
                        data_out_crossbar[g_i] = ~insert_lookahead_routing[g_i] ? fifo_head[noc::kLocalPort] :
              {fifo_head[noc::kLocalPort].flit[PortWidth-1:5], next_hop_routing[noc::kLocalPort]};
                        rd_fifo[g_i][noc::kLocalPort] = no_backpressure[g_i];
                        out_unvalid_flit[g_i] = in_unvalid_flit[noc::kLocalPort];
                    end

                    default: begin
                    end
                endcase
            end


            // Sample output
            always_ff @(posedge clk) begin
                if (rst) begin
                    last_flit[g_i] <= '0;
                end else begin
                    if (FifoBypassEnable) begin
                        if (no_backpressure[g_i] & forwarding_in_progress[g_i] & ~out_unvalid_flit[g_i]) begin
                            last_flit[g_i] <= data_out_crossbar[g_i];
                        end
                    end else begin
                        if (~data_void_out[g_i]) begin
                            last_flit[g_i] <= data_out_crossbar[g_i];
                        end
                    end
                end
            end

            // Flow control
            assign no_backpressure[g_i] = FifoBypassEnable ? ~stop_in[g_i] : credits[g_i] != '0;
            assign forwarding_tail[g_i] = data_out_crossbar[g_i].header.preamble.tail &
                                    ~out_unvalid_flit[g_i] & no_backpressure[g_i];
            assign forwarding_head[g_i] = data_out_crossbar[g_i].header.preamble.head &
                                    ~out_unvalid_flit[g_i] & no_backpressure[g_i];

            always_comb begin : flow_control_fsm
                new_state[g_i]              = state[g_i];
                routing_configuration[g_i]  = '0;
                forwarding_in_progress[g_i] = 1'b0;

                unique case (state[g_i])
                    kHeadFlit: begin
                        if (grant_valid[g_i] & no_backpressure[g_i]) begin
                            // First flit of a new packet can be forwarded
                            routing_configuration[g_i]  = grant[g_i];
                            forwarding_in_progress[g_i] = 1'b1;
                            if (~data_out_crossbar[g_i].header.preamble.tail) begin
                                // Non-single-flit packet; expecting more payload flit
                                new_state[g_i] = kPayloadFlits;
                            end
                        end
                    end

                    kPayloadFlits: begin
                        // Payload of a packet is being forwarded; do not change routing configuration
                        routing_configuration[g_i]  = saved_routing_configuration[g_i];
                        forwarding_in_progress[g_i] = 1'b1;
                        if (forwarding_tail[g_i]) begin
                            // Next flit must be head
                            new_state[g_i] = kHeadFlit;
                        end
                    end

                    default: begin
                    end
                endcase  // unique case (state[g_i])
            end

            always_ff @(posedge clk) begin
                if (rst) begin
                    state[g_i] <= kHeadFlit;
                end else begin
                    state[g_i] <= new_state[g_i];
                end
            end

            // Data void out and credits
            if (FifoBypassEnable) begin : gen_data_void_out_acknack
                always_ff @(posedge clk) begin
                    if (rst) begin
                        data_void_out[g_i] <= 1'b1;
                    end else begin
                        if (~forwarding_in_progress[g_i] && no_backpressure[g_i]) begin
                            data_void_out[g_i] <= 1'b1;
                        end else if (no_backpressure[g_i]) begin
                            data_void_out[g_i] <= out_unvalid_flit[g_i];
                        end
                    end
                end
                assign credits[g_i] = '0;
            end else begin : gen_data_void_out_creditbased
                assign data_void_out[g_i] = forwarding_in_progress[g_i] & no_backpressure[g_i] ?
                                    out_unvalid_flit[g_i] : 1'b1;
                always_ff @(posedge clk) begin
                    if (rst) begin
                        credits[g_i] = noc::PortQueueDepth;
                    end else begin
                        if (~data_void_out[g_i]) begin
                            credits[g_i] = credits[g_i] - stop_in[g_i];
                        end else begin
                            credits[g_i] = credits[g_i] + ~stop_in[g_i];
                        end
                    end
                end
            end



        end else begin : gen_input_port_disabled
            assign grant_valid[g_i]                 = '0;
            assign grant[g_i]                       = '0;
            assign data_void_out[g_i]               = '1;
            assign out_unvalid_flit[g_i]            = '1;
            assign data_out_crossbar[g_i]           = '0;
            assign last_flit[g_i]                   = '0;
            assign routing_configuration[g_i]       = '0;
            assign saved_routing_configuration[g_i] = '0;
            assign rd_fifo[g_i]                     = '0;
            assign no_backpressure[g_i]             = '1;
            assign forwarding_tail[g_i]             = '0;
            assign forwarding_head[g_i]             = '0;
            assign forwarding_in_progress[g_i]      = '0;
            assign insert_lookahead_routing[g_i]    = '0;
            assign credits[g_i]                     = '0;
        end  // block: gen_output_port_enabled

    end  // for gen_output_control

    //////////////////////////////////////////////////////////////////////////////
    // Assertions
    //////////////////////////////////////////////////////////////////////////////

`ifndef SYNTHESIS
    // pragma coverage off
    //VCS coverage off

    if (DataWidth < $bits(noc::packet_info_t) + $bits(noc::direction_t)) begin : gen_a_data_width
        $fatal(2'd2, "Fail: DataWidth insufficient to hold packet and routing information.");
    end

    if ($bits(header_t) != DataWidth + $bits(noc::preamble_t)) begin : gen_a_header_width
        $fatal(
            2'd2,
            "Fail: header_t width (%02d) must be DataWidth (%02d) + preamble_t width (%01d)",
            $bits(
                header_t
            ),
            DataWidth,
            $bits(
                noc::preamble_t
            )
        );
    end

    if (PortWidth != $bits(header_t)) begin : gen_a_port_width
        $fatal(2'd2, "Fail: PortWidth must match header_t width.");
    end

    for (g_i = 0; g_i < 4; g_i++) begin : gen_assert_legal_routing_request
        a_no_request_to_same_port :
        assert property (@(posedge clk) disable iff (rst) final_routing_request[g_i][g_i] == 1'b0)
        else $error("Fail: a_no_request_to_same_port");
        a_enhanc_routing_configuration_onehot :
        assert property (@(posedge clk) disable iff (rst) $onehot0(
            enhanc_routing_configuration[g_i]
        ))
        else $error("Fail: a_enhanc_routing_configuration_onehot");
        a_expect_head_flit :
        assert property (@(posedge clk) disable iff(rst)
      ~out_unvalid_flit[g_i] & state[g_i] == kHeadFlit
      |->
      data_out_crossbar[g_i].header.preamble.head)
        else $error("Fail: a_expect_head_flit");
        a_credits_in_range :
        assert property (@(posedge clk) disable iff (rst) credits[g_i] <= noc::PortQueueDepth)
        else $error("Fail: a_enhanc_routing_configuration_onehot");
    end

    // pragma coverage on
    //VCS coverage on
`endif  // ~SYNTHESIS

endmodule
