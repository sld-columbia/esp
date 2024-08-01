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

module lookahead_router_multicast
  #(
    parameter noc::noc_flow_control_t FlowControl = noc::kFlowControlAckNack,
    parameter int unsigned DataWidth = 64,
    parameter int unsigned PortWidth = DataWidth + $bits(noc::preamble_t),
    parameter bit [4:0] Ports = noc::AllPorts,
    parameter integer DEST_SIZE = 6
    )
  (
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

  localparam integer DEST_ARR_SIZE = DEST_SIZE-1 ;

  localparam int unsigned ReservedWidth =
    DataWidth - (1 + DEST_SIZE) * $bits(noc::xy_t) - $bits(noc::message_t) - DEST_SIZE - $bits(noc::direction_t);

  // Modified the structure to add more destinations and a valid bit for each destination
  typedef struct packed {
    noc::xy_t source;
    noc::xy_t destination;
    noc::message_t message;
    logic [ReservedWidth-1:0] reserved;
    noc::xy_t [0:DEST_ARR_SIZE-1] destination_arr;
    bit [DEST_SIZE-1:0] val; // 1 indicates corresponding destination still needs to be served
  } packet_info_t;

  localparam bit FifoBypassEnable = FlowControl == noc::kFlowControlAckNack;

  typedef struct packed {
    noc::preamble_t preamble;
    packet_info_t info;
    noc::direction_t routing;
  } header_t;

  typedef logic [PortWidth-1:0] payload_t;

  typedef union packed {
    header_t header;
    payload_t flit;
  } flit_t;

  typedef enum logic {
    kHeadFlit     = 1'b0,
    kPayloadFlits = 1'b1
  } state_t;

  state_t [4:0] state;
  state_t [4:0] new_state;

  flit_t [4:0] data_in;
  flit_t temp_data_in;
  flit_t [4:0] fifo_head;
  flit_t [4:0] data_out_crossbar;
  flit_t [4:0] last_flit;
  flit_t [4:0] fifo_head_temp [4:0];
  flit_t [4:0] fifo_head_routing;
  flit_t [4:0] data_out_before_routing;

  logic [4:0][4:0] saved_routing_request;
  logic [4:0][4:0] final_routing_request;  // ri lint_check_waive NOT_READ
  logic [4:0][4:0] next_hop_routing;

  logic [4:0][3:0] transp_final_routing_request;

  logic [4:0][4:0] enhanc_routing_configuration;

  logic [4:0][3:0] routing_configuration;
  logic [4:0][3:0] saved_routing_configuration;
  logic [4:0][3:0] grant;
  logic [4:0] grant_valid;
  logic [4:0][4:0] backpressure_tmp;

  logic [4:0][4:0] rd_fifo;
  logic [4:0] no_backpressure;
  logic [4:0] no_backpressure_old;
  logic [4:0] rd_fifo_or;

  logic [4:0] in_unvalid_flit;
  logic [4:0] out_unvalid_flit;
  logic [4:0] in_valid_head;

  logic [4:0] full;
  logic [4:0] empty;
  logic [4:0] wr_fifo;

  noc::credits_t credits;

  noc::direction_t [4:0] current_routing;

  noc::xy_t [0:DEST_SIZE-1] destination_arr_temp [4:0];

  logic [4:0] forwarding_tail;
  logic [4:0] forwarding_head;
  logic [4:0] forwarding_in_progress;
  logic [4:0] insert_lookahead_routing;

  assign data_in[noc::kNorthPort] = data_n_in;
  assign data_in[noc::kSouthPort] = data_s_in;
  assign data_in[noc::kWestPort] = data_w_in;
  assign data_in[noc::kEastPort] = data_e_in;

  // Assign the whole Local In data to the data_in[Local] port
  // If the valid is not set, then this will ensure that at least the first destination is valid
  // This is to ensure the new router is backwards compatible
  assign data_in[noc::kLocalPort][PortWidth-1:$bits(noc::direction_t)+1] = data_p_in[PortWidth-1:$bits(noc::direction_t)+1];
  assign data_in[noc::kLocalPort][$bits(noc::direction_t)-1:0] = data_p_in[$bits(noc::direction_t)-1:0];
  assign data_in[noc::kLocalPort][$bits(noc::direction_t)] = (data_p_in[PortWidth-1] && !(|data_p_in[$bits(noc::direction_t) + (DEST_SIZE - 1):$bits(noc::direction_t)])) ? 1 : data_p_in[$bits(noc::direction_t)];
  //This router has a single cycle delay.
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
      router_fifo
        #(
          .BypassEnable(FifoBypassEnable),
          .Depth(noc::PortQueueDepth),
          .Width(PortWidth)
          )
      input_queue (
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
    end else begin : gen_input_port_disabled

      assign stop_out[g_i] = 1'b1;
      assign final_routing_request[g_i] = '0;
      assign saved_routing_request[g_i] = '0;
      assign in_unvalid_flit[g_i] = '1;
      assign fifo_head[g_i] = '0;
      assign empty[g_i] = 1'b1;
      assign full[g_i] = '0;
      assign next_hop_routing[g_i] = '0;
      assign rd_fifo_or[g_i] = '0;
      assign wr_fifo[g_i] = '0;
      assign in_valid_head[g_i] = 1'b0;

    end // if (Ports[g_i])

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
          assign enhanc_routing_configuration[g_i][g_j] = routing_configuration[g_i][g_j-1]; // doubt - Aren't we loosing the ability to represent all 5 possible routing here ?
        end else begin : gen_transpose_routin_j_eq_i
          assign enhanc_routing_configuration[g_i][g_j] = 1'b0;
        end
      end // for gen_transpose_routing

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

      assign rd_fifo[g_i][noc::kNorthPort] = no_backpressure[g_i] && (enhanc_routing_configuration[g_i] == noc::goNorth);
      assign rd_fifo[g_i][noc::kSouthPort] = no_backpressure[g_i] && (enhanc_routing_configuration[g_i] == noc::goSouth);
      assign rd_fifo[g_i][noc::kEastPort] = no_backpressure[g_i] && (enhanc_routing_configuration[g_i] == noc::goEast);
      assign rd_fifo[g_i][noc::kWestPort] = no_backpressure[g_i] && (enhanc_routing_configuration[g_i] == noc::goWest);
      assign rd_fifo[g_i][noc::kLocalPort] = no_backpressure[g_i] && (enhanc_routing_configuration[g_i] == noc::goLocal);

      always_comb begin
        destination_arr_temp[g_i] = 'b0;
        for (int j = 0; j < 5; j++) begin
          if (fifo_head[j].header.preamble.head && rd_fifo[g_i][j]) begin
            destination_arr_temp[g_i] = {fifo_head[j].header.info.destination, fifo_head[j].header.info.destination_arr};
          end
        end
      end

      // Sample current routing configuration
      always_ff @(posedge clk) begin
        if (forwarding_in_progress[g_i]) begin
          saved_routing_configuration[g_i] <= routing_configuration[g_i];
        end
        else
          saved_routing_configuration[g_i] <= 'h0;
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
      fifo_head_routing[g_i] = '0;
      out_unvalid_flit[g_i] = 1'b1;

      // for each input port
      for (int j = 0; j < 5; j++) begin
        fifo_head_temp[g_i][j] = fifo_head[j].header.preamble.head ? fifo_head[j].header : fifo_head[j].flit;
        // j is the current input port for output port g_i
        if (enhanc_routing_configuration[g_i] == (1 << j)) begin
	    // invalidate destinations that are no longer on the current multicast path
          if (noc::int2noc_port(g_i) == noc::kNorthPort) begin
            for (int index = 0; index < DEST_SIZE; index++) begin
              if (fifo_head[j].header.info.val[index]) begin
                // if going north, destination cannot be in different column
                if (position.x != destination_arr_temp[noc::kNorthPort][index].x) begin
                  fifo_head_temp[g_i][j].header.info.val[index] = 0;
                //next tile is north of destination
                end else if (position.y - 1 < destination_arr_temp[noc::kNorthPort][index].y) begin
                  fifo_head_temp[g_i][j].header.info.val[index] = 0;
                end
              end
            end
          end


          if (noc::int2noc_port(g_i) == noc::kSouthPort) begin
            for (int index = 0; index < DEST_SIZE; index++) begin
              if (fifo_head[j].header.info.val[index]) begin
                // if going south, destination cannot be in a differnet column
                if (position.x != destination_arr_temp[noc::kSouthPort][index].x) begin
                  fifo_head_temp[g_i][j].header.info.val[index] = 0;
                //next tile is south of destination
                end else if (position.y + 1 > destination_arr_temp[noc::kSouthPort][index].y) begin
                  fifo_head_temp[g_i][j].header.info.val[index] = 0;
                end
              end
            end
          end

          if (noc::int2noc_port(g_i) == noc::kWestPort) begin
            for (int index = 0; index < DEST_SIZE; index++) begin
               if (fifo_head[j].header.info.val[index]) begin
                 // next tile is west of destination
                 if (position.x - 1 < destination_arr_temp[noc::kWestPort][index].x) begin
                   fifo_head_temp[g_i][j].header.info.val[index] = 0;
                 end
               end
             end
           end

          if (noc::int2noc_port(g_i) == noc::kEastPort) begin
            for (int index = 0; index < DEST_SIZE; index++) begin
              if (fifo_head[j].header.info.val[index]) begin
                // next tile is east of destination
                if (position.x + 1 > destination_arr_temp[noc::kEastPort][index].x) begin
                  fifo_head_temp[g_i][j].header.info.val[index] = 0;
                end
              end
            end
          end

          fifo_head_routing[g_i] = fifo_head_temp[g_i][j].header.preamble.head ? fifo_head_temp[g_i][j].header : fifo_head[j].flit;
          out_unvalid_flit[g_i] = in_unvalid_flit[j];
        end
      end
    end

    assign current_routing[g_i] = 5'h1 << g_i ;

    lookahead_routing_multicast #(.DEST_SIZE(DEST_SIZE))
      lookahead_routing_i
      (
        .clk,
        .position,
        .destination(destination_arr_temp[g_i]),
        .val(fifo_head_routing[g_i].header.info.val),
        .current_routing(current_routing[g_i]),
        .next_routing(next_hop_routing[g_i])
      );

    // Only update valid bits only when we have a header
    assign data_out_crossbar[g_i] = ~insert_lookahead_routing[g_i] ? fifo_head_routing[g_i] :  {fifo_head_routing[g_i].flit[PortWidth-1:5], (next_hop_routing[g_i])};

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
    for (g_j = 0 ; g_j < 5; g_j++) begin
      assign backpressure_tmp[g_i][g_j] = ((g_i == g_j) || ((|enhanc_routing_configuration[g_i])
                 && (enhanc_routing_configuration[g_j] == enhanc_routing_configuration[g_i])))
                 && (FifoBypassEnable ? stop_in[g_j] : credits[g_j] == '0);
    end
    assign no_backpressure_old[g_i] = FifoBypassEnable ? ~stop_in[g_i] : credits != '0;
    assign no_backpressure[g_i] = ~(|backpressure_tmp[g_i]);
    assign forwarding_tail[g_i] = data_out_crossbar[g_i].header.preamble.tail &
                                   ~out_unvalid_flit[g_i] & no_backpressure[g_i];
    assign forwarding_head[g_i] = data_out_crossbar[g_i].header.preamble.head &
                                    ~out_unvalid_flit[g_i] & no_backpressure[g_i];

    always_comb begin : flow_control_fsm
      new_state[g_i] = state[g_i];
      routing_configuration[g_i] = '0;
      forwarding_in_progress[g_i] = 1'b0;

      unique case (state[g_i])
        kHeadFlit : begin
          if (grant_valid[g_i] & no_backpressure[g_i]) begin
            // First flit of a new packet can be forwarded
            routing_configuration[g_i] = grant[g_i];
            forwarding_in_progress[g_i] = 1'b1;
            if (~data_out_crossbar[g_i].header.preamble.tail) begin
              // Non-single-flit packet; expecting more payload flit
              new_state[g_i] = kPayloadFlits;
            end
          end
        end

        kPayloadFlits : begin
          // Payload of a packet is being forwarded; do not change routing configuration
          routing_configuration[g_i] = saved_routing_configuration[g_i];
          forwarding_in_progress[g_i] = 1'b1;
          if (forwarding_tail[g_i]) begin
              // Next flit must be head
              new_state[g_i] = kHeadFlit;
          end
        end

        default : begin
        end
      endcase // unique case (state[g_i])
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
          if (~forwarding_in_progress[g_i] && no_backpressure_old[g_i]) begin
            data_void_out[g_i] <= 1'b1;
          end else if (no_backpressure[g_i]) begin
            data_void_out[g_i] <= out_unvalid_flit[g_i];
          end else if (no_backpressure_old[g_i]) begin
            data_void_out[g_i] <= 1'b1;
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



    end  else begin : gen_input_port_disabled
      assign grant_valid[g_i] = '0;
      assign grant[g_i] = '0;
      assign data_void_out[g_i] = '1;
      assign out_unvalid_flit[g_i] = '1;
      assign data_out_crossbar[g_i] = '0;
      assign last_flit[g_i] = '0;
      assign routing_configuration[g_i] = '0;
      assign saved_routing_configuration[g_i] = '0;
      assign rd_fifo[g_i] = '0;
      assign backpressure_tmp[g_i] = '0;
      assign no_backpressure[g_i] = '1;
      assign no_backpressure_old[g_i] = '1;
      assign forwarding_tail[g_i] = '0;
      assign forwarding_head[g_i] = '0;
      assign forwarding_in_progress[g_i] = '0;
      assign insert_lookahead_routing[g_i] = '0;
      assign credits[g_i] = '0;
      assign fifo_head_temp[g_i][0] = '0;
      assign fifo_head_temp[g_i][1] = '0;
      assign fifo_head_temp[g_i][2] = '0;
      assign fifo_head_temp[g_i][3] = '0;
      assign fifo_head_temp[g_i][4] = '0;
      assign current_routing[g_i] = '0 ;
      assign enhanc_routing_configuration[g_i] = '0;
    end // block: gen_output_port_enabled

  end // for gen_output_control

  //////////////////////////////////////////////////////////////////////////////
  // Assertions
  //////////////////////////////////////////////////////////////////////////////

`ifndef SYNTHESIS
// pragma coverage off
//VCS coverage off

  if (DataWidth < $bits(packet_info_t) + $bits(noc::direction_t)) begin : gen_a_data_width
    $fatal(2'd2, "Fail: DataWidth insufficient to hold packet and routing information.");
  end

  if ($bits(header_t) != DataWidth + $bits(noc::preamble_t)) begin : gen_a_header_width
    $fatal(2'd2, "Fail: header_t width (%02d) must be DataWidth (%02d) + preamble_t width (%01d)",
           $bits(header_t), DataWidth, $bits(noc::preamble_t));
  end

  if (PortWidth != $bits(header_t)) begin : gen_a_port_width
    $fatal(2'd2, "Fail: PortWidth must match header_t width.");
  end

  for (g_i = 0; g_i < 4; g_i++) begin : gen_assert_legal_routing_request
    // a_no_request_to_same_port: assert property (@(posedge clk) disable iff(rst)
    //   final_routing_request[g_i][g_i] == 1'b0)
    //   else $error("Fail: a_no_request_to_same_port");
    a_enhanc_routing_configuration_onehot: assert property (@(posedge clk) disable iff(rst)
      $onehot0(enhanc_routing_configuration[g_i]))
      else $error("Fail: a_enhanc_routing_configuration_onehot");
    a_expect_head_flit: assert property (@(posedge clk) disable iff(rst)
      ~out_unvalid_flit[g_i] & state[g_i] == kHeadFlit
      |->
      data_out_crossbar[g_i].header.preamble.head)
      else $error("Fail: a_expect_head_flit");
    a_credits_in_range: assert property (@(posedge clk) disable iff(rst)
      credits[g_i] <= noc::PortQueueDepth)
      else $error("Fail: a_enhanc_routing_configuration_onehot");
   end

// pragma coverage on
//VCS coverage on
`endif // ~SYNTHESIS

endmodule
