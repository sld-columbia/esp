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

module lookahead_router
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

  localparam integer DEST_ARR_SIZE = DEST_SIZE==1 || DEST_SIZE == 2 ? 1 : DEST_SIZE-1 ;

  // ajay_v
  // Modified the structure to add more destinataions and vaslid indications to each destination
  typedef struct packed {
    noc::xy_t source;
    noc::xy_t destination;
    //xy_t destination_1;
    noc::message_t message;
    noc::xy_t [0:DEST_ARR_SIZE-1] destination_arr;
    bit [DEST_SIZE-1:0] val; // 1 indicates Destination still awaits, 0 indicates destination already reached/taken care
    //logic val; // 1 indicates Destination 1 still awaits, 0 indicates destination already reached/crossed
  } packet_info_t;

  localparam bit FifoBypassEnable = FlowControl == noc::kFlowControlAckNack;

  localparam int unsigned ReservedWidth =
    DataWidth - $bits(packet_info_t) - $bits(noc::direction_t);

  typedef struct packed {
    noc::preamble_t preamble;
    packet_info_t info; // source, destination[],val[],message(5 bit)
    logic [ReservedWidth-1:0] reserved;
    noc::direction_t routing; // 5 bit logic indicates LEWSN
  } header_t;

  typedef logic [PortWidth-1:0] payload_t;
  
  // Including header and the flit
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
  //ajay_v added for unicasting
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
  //logic [4:0][4:0] next_hop_routing_2;
  // ajay_v signal indicates either of the next_hop_routing
  //logic [4:0][4:0] next_hop_routing_all;
  logic [4:0][4:0] inval_routing;
  

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

  noc::direction_t [4:0] current_routing;

  noc::xy_t [0:DEST_SIZE-1] destination_arr_temp [4:0];

  logic [4:0] forwarding_tail;
  logic [4:0] forwarding_head;
  logic [4:0] forwarding_in_progress;
  logic [4:0] insert_lookahead_routing;
  logic [4:0][2:0] val_checkme= 3'h0; //change this
  logic [4:0][2:0] dest_checkme= 3'h0; //change this
  

  

  assign data_in[noc::kNorthPort] = data_n_in;
  assign data_in[noc::kSouthPort] = data_s_in;
  assign data_in[noc::kWestPort] = data_w_in;
  assign data_in[noc::kEastPort] = data_e_in;

  // Assign the whole Local In data to the data_in[Local] port 
  // If the valid is not set, then this will ensure that atleast the first destination is valid
  // This is to ensure the new router is backwards compatible  
  assign data_in[noc::kLocalPort][PortWidth-1:ReservedWidth+5+1] = data_p_in[PortWidth-1:ReservedWidth+5+1];
  assign data_in[noc::kLocalPort][ReservedWidth+5-1:0] = data_p_in[ReservedWidth+5-1:0];
  assign data_in[noc::kLocalPort][ReservedWidth+5] = data_p_in[PortWidth-1] ? 1 : data_p_in[ReservedWidth+5];

//  assign temp_data_in = data_p_in;
//    assign data_in[noc::kLocalPort].header.preamble = temp_data_in.header.preamble;
//    assign data_in[noc::kLocalPort].header.reserved = temp_data_in.header.reserved;
//    assign data_in[noc::kLocalPort].header.routing = temp_data_in.header.routing;
//    assign data_in[noc::kLocalPort].header.info.source = temp_data_in.header.info.source;
//    assign data_in[noc::kLocalPort].header.info.destination = temp_data_in.header.info.destination;
//    assign data_in[noc::kLocalPort].header.info.message = temp_data_in.header.info.message;
//  
//  // Use this for higher logic resources
//  // assign data_in[noc::kLocalPort].header.info.val = temp_data_in.header.info.val + (!(|temp_data_in.header.info.val) && (temp_data_in.header.preamble.head));
//
//    // Use this for lower logic resources
//   // generate
//   // if (DEST_SIZE != 1)
//   //   assign data_in[noc::kLocalPort].header.info.val = {temp_data_in.header.info.val[DEST_SIZE - 1: 1],
//   //    (temp_data_in.header.info.val[0] | (!(|temp_data_in.header.info.val) && (temp_data_in.header.preamble.head)))};
//   // else 
//      assign data_in[noc::kLocalPort].header.info.val = temp_data_in.header.preamble.head ? 1 : temp_data_in.header.info.val;
      //assign data_in[noc::kLocalPort].header.info.val = temp_data_in.header.info.val | (!(|temp_data_in.header.info.val) && (temp_data_in.header.preamble.head));
    //endgenerate;
//    assign data_in[noc::kLocalPort].flit = temp_data_in.flit;

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
      
      //ajay_v
      // Added another routing module to check for different destination
      // Can we make it parameterised based on the number of destinations available and the valid 
      // This will indicate the next routing direction
      // If next location is local, then next_routing = current_routing
      // genvar dest_num;
      //     lookahead_routing lookahead_routing_i
      //     (
      //       .clk,
      //       .position,
      //       .destination(fifo_head[g_i].header.info.destination),
	    // .val(fifo_head[g_i].header.info.val),
      //       .current_routing(fifo_head[g_i].header.routing),
      //       .next_routing(next_hop_routing[g_i])
      //       // ,
      //       // .val(fifo_head[g_i].header.info.val[dest_num])
      //     );
    //assign next_hop_routing_all[g_i] = next_hop_routing[g_i] || next_hop_routing_2[g_i];
    //assign fifo_head[g_i].header.info.val1 = (fifo_head[g_i].header.routing == next_hop_routing[g_i]) ? 0 : 1;
    //assign fifo_head[g_i].header.info.val2 = (fifo_head[g_i].header.routing == next_hop_routing_2[g_i]) ? 0 : 1;
    

    end 
    else begin : gen_input_port_disabled

      assign stop_out[g_i] = 1'b1;
      assign final_routing_request[g_i] = '0;
      assign saved_routing_request[g_i] = '0;
      assign in_unvalid_flit[g_i] = '1;
      assign fifo_head[g_i] = '0;
      assign empty[g_i] = 1'b1;
      assign full[g_i] = '0;
      assign next_hop_routing[g_i] = '0;
      //assign next_hop_routing_2[g_i] = '0;
      //assign next_hop_routing_all[g_i] = '0;
      assign rd_fifo_or[g_i] = '0;
      assign wr_fifo[g_i] = '0;
      assign in_valid_head[g_i] = 1'b0;

    end // if (Ports[g_i])

  end  // for gen_input_fifo

      // ajay_v
      always_comb begin

          destination_arr_temp[0] = 'b0;
          destination_arr_temp[1] = 'b0;
          destination_arr_temp[2] = 'b0;
          destination_arr_temp[3] = 'b0;
          destination_arr_temp[4] = 'b0;
        if(fifo_head[0].header.preamble.head && rd_fifo_or[0]) begin
        // if((fifo_head[0].header.preamble.head&& !fifo_head[0].header.preamble.tail) || (fifo_head[0].header.preamble.head && fifo_head[0].header.preamble.tail && !fifo_head[1].header.preamble.head && !fifo_head[2].header.preamble.head && !fifo_head[3].header.preamble.head && !fifo_head[4].header.preamble.head )) begin
          destination_arr_temp[0] = (DEST_SIZE == 1) ? fifo_head[0].header.info.destination : {fifo_head[0].header.info.destination,fifo_head[0].header.info.destination_arr};
          destination_arr_temp[1] = (DEST_SIZE == 1) ? fifo_head[0].header.info.destination : {fifo_head[0].header.info.destination,fifo_head[0].header.info.destination_arr};
          destination_arr_temp[2] = (DEST_SIZE == 1) ? fifo_head[0].header.info.destination : {fifo_head[0].header.info.destination,fifo_head[0].header.info.destination_arr};
          destination_arr_temp[3] = (DEST_SIZE == 1) ? fifo_head[0].header.info.destination : {fifo_head[0].header.info.destination,fifo_head[0].header.info.destination_arr};
          destination_arr_temp[4] = (DEST_SIZE == 1) ? fifo_head[0].header.info.destination : {fifo_head[0].header.info.destination,fifo_head[0].header.info.destination_arr};
        end
        // else if((fifo_head[1].header.preamble.head&& !fifo_head[1].header.preamble.tail) || (fifo_head[1].header.preamble.head && fifo_head[1].header.preamble.tail && !fifo_head[0].header.preamble.head && !fifo_head[2].header.preamble.head && !fifo_head[3].header.preamble.head && !fifo_head[4].header.preamble.head )) begin
        else if(fifo_head[1].header.preamble.head && rd_fifo_or[1]) begin
          destination_arr_temp[0] = (DEST_SIZE == 1) ? fifo_head[1].header.info.destination : {fifo_head[1].header.info.destination,fifo_head[1].header.info.destination_arr};
          destination_arr_temp[1] = (DEST_SIZE == 1) ? fifo_head[1].header.info.destination : {fifo_head[1].header.info.destination,fifo_head[1].header.info.destination_arr};
          destination_arr_temp[2] = (DEST_SIZE == 1) ? fifo_head[1].header.info.destination : {fifo_head[1].header.info.destination,fifo_head[1].header.info.destination_arr};
          destination_arr_temp[3] = (DEST_SIZE == 1) ? fifo_head[1].header.info.destination : {fifo_head[1].header.info.destination,fifo_head[1].header.info.destination_arr};
          destination_arr_temp[4] = (DEST_SIZE == 1) ? fifo_head[1].header.info.destination : {fifo_head[1].header.info.destination,fifo_head[1].header.info.destination_arr};
        end
        // else if((fifo_head[2].header.preamble.head&& !fifo_head[2].header.preamble.tail) || (fifo_head[2].header.preamble.head && fifo_head[2].header.preamble.tail && !fifo_head[0].header.preamble.head && !fifo_head[1].header.preamble.head && !fifo_head[3].header.preamble.head && !fifo_head[4].header.preamble.head )) begin
        else if(fifo_head[2].header.preamble.head && rd_fifo_or[2]) begin
          destination_arr_temp[0] = (DEST_SIZE == 1) ? fifo_head[2].header.info.destination : {fifo_head[2].header.info.destination,fifo_head[2].header.info.destination_arr};
          destination_arr_temp[1] = (DEST_SIZE == 1) ? fifo_head[2].header.info.destination : {fifo_head[2].header.info.destination,fifo_head[2].header.info.destination_arr};
          destination_arr_temp[2] = (DEST_SIZE == 1) ? fifo_head[2].header.info.destination : {fifo_head[2].header.info.destination,fifo_head[2].header.info.destination_arr};
          destination_arr_temp[3] = (DEST_SIZE == 1) ? fifo_head[2].header.info.destination : {fifo_head[2].header.info.destination,fifo_head[2].header.info.destination_arr};
          destination_arr_temp[4] = (DEST_SIZE == 1) ? fifo_head[2].header.info.destination : {fifo_head[2].header.info.destination,fifo_head[2].header.info.destination_arr};
        end
        // Added special condition here for 1 flit packet. 
        //else if((fifo_head[3].header.preamble.head && !fifo_head[3].header.preamble.tail) || (fifo_head[3].header.preamble.head && fifo_head[3].header.preamble.tail && !fifo_head[4].header.preamble.head)) begin
          // Extend it for all directions.
        //  else if((fifo_head[3].header.preamble.head && !fifo_head[3].header.preamble.tail) || (fifo_head[3].header.preamble.head && fifo_head[3].header.preamble.tail && !fifo_head[4].header.preamble.head && !fifo_head[0].header.preamble.head && !fifo_head[1].header.preamble.head && !fifo_head[2].header.preamble.head )) begin
        else if(fifo_head[3].header.preamble.head && rd_fifo_or[3]) begin
          destination_arr_temp[0] = (DEST_SIZE == 1) ? fifo_head[3].header.info.destination : {fifo_head[3].header.info.destination,fifo_head[3].header.info.destination_arr};
          destination_arr_temp[1] = (DEST_SIZE == 1) ? fifo_head[3].header.info.destination : {fifo_head[3].header.info.destination,fifo_head[3].header.info.destination_arr};
          destination_arr_temp[2] = (DEST_SIZE == 1) ? fifo_head[3].header.info.destination : {fifo_head[3].header.info.destination,fifo_head[3].header.info.destination_arr};
          destination_arr_temp[3] = (DEST_SIZE == 1) ? fifo_head[3].header.info.destination : {fifo_head[3].header.info.destination,fifo_head[3].header.info.destination_arr};
          destination_arr_temp[4] = (DEST_SIZE == 1) ? fifo_head[3].header.info.destination : {fifo_head[3].header.info.destination,fifo_head[3].header.info.destination_arr};                          
        end
        // else if((fifo_head[4].header.preamble.head&& !fifo_head[4].header.preamble.tail) || (fifo_head[4].header.preamble.head && fifo_head[4].header.preamble.tail && !fifo_head[0].header.preamble.head && !fifo_head[1].header.preamble.head && !fifo_head[2].header.preamble.head && !fifo_head[3].header.preamble.head )) begin
        else if(fifo_head[4].header.preamble.head && rd_fifo_or[4]) begin
          destination_arr_temp[0] = (DEST_SIZE == 1) ? fifo_head[4].header.info.destination : {fifo_head[4].header.info.destination,fifo_head[4].header.info.destination_arr};
          destination_arr_temp[1] = (DEST_SIZE == 1) ? fifo_head[4].header.info.destination : {fifo_head[4].header.info.destination,fifo_head[4].header.info.destination_arr};
          destination_arr_temp[2] = (DEST_SIZE == 1) ? fifo_head[4].header.info.destination : {fifo_head[4].header.info.destination,fifo_head[4].header.info.destination_arr};
          destination_arr_temp[3] = (DEST_SIZE == 1) ? fifo_head[4].header.info.destination : {fifo_head[4].header.info.destination,fifo_head[4].header.info.destination_arr};
          destination_arr_temp[4] = (DEST_SIZE == 1) ? fifo_head[4].header.info.destination : {fifo_head[4].header.info.destination,fifo_head[4].header.info.destination_arr};                          
        end

        else begin

        end
      end

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
        //data_out_crossbar[g_i] = '0;
        fifo_head_routing[g_i] = '0;
        rd_fifo[g_i] = '0;
        out_unvalid_flit[g_i] = 1'b1;

        //for (g_i=0; g_i<5; g_i++) begin : for_all_dests
        // destination_arr_temp[g_i] = DEST_SIZE == 1 ? fifo_head[g_i].header.info.destination : {fifo_head[g_i].header.info.destination,fifo_head[g_i].header.info.destination_arr};
        //end        


        //ajay_v added
        //fifo_head_temp[g_i][0] = fifo_head[0];
        //fifo_head_temp[g_i][1] = fifo_head[1];
        //fifo_head_temp[g_i][2] = fifo_head[2];
        //fifo_head_temp[g_i][3] = fifo_head[3];
        //fifo_head_temp[g_i][4] = fifo_head[4];

        for (int j=0; j<5; j++)
        begin
          fifo_head_temp[g_i][j] = fifo_head[j].header.preamble.head ? fifo_head[j].header : fifo_head[j].flit;
          //destination_arr_temp[j] = DEST_SIZE == 1 ? fifo_head[j].header.info.destination : {fifo_head[j].header.info.destination,fifo_head[j].header.info.destination_arr};
        end        

        //val_checkme= 3'h0;
        
        // To check which destination to invalidate
        inval_routing[g_i] = 5'b11111;



              // ajay_v : g_i corresponds to the input fifo
	     	      // ajay_v added below to check for destination valid and invalidate the irrelevant destinations
        if (enhanc_routing_configuration[g_i] == noc::goNorth ) begin // current_routing_north
        //if (enhanc_routing_configuration[g_i][0]) begin // current_routing_north
        	 	    val_checkme[g_i] = 3'h7;

	   //fifo_head_temp[noc::kNorthPort] = fifo_head[noc::kNorthPort];


           // Conditions for a destination to be invalid when the packet going to North of current packet 
          //  for(int index = 0; index < 2; index++) begin  //check_north_and_inval_dest
          //     if(fifo_head[noc::kNorthPort].header.info.val[index]) begin //---------- ajay_v - do we need to check for this condition ? ----------
          //      //if(fifo_head[g_i].header.info.val[index]) begin  //check_north_and_inval_dest_2 ajay_v - do we need to check for this condition ?
          //      // Disabling the destination valid that is already taken care/crossed
          //      // Conditions for a destination to be invalid when the packet going to North of current packet 
          //      // 1. if the x value of destination is not equal to the x value of next tile, invalidate that destination
          //      // 2. If the packet is local for the next router then make the valid as 0
          //      // 3. If the x value of destination is equal to the x value of next tile, and y value of destination is greater the the y value of next tile, then invalidate the destination
	        //      // fifo_head[g_i] is replaced with fifo_head[corresponding port]
          //      //if(fifo_head_temp[g_i][noc::kNorthPort].header.info.val[index]) begin // Check only if valid dest
          //      if(position.x != fifo_head[noc::kNorthPort].header.info.destination[index].x) begin  // dest_in_wrong_direction_for_next_router_0
          //          {val_checkme[g_i][0],fifo_head_temp[g_i][noc::kNorthPort].header.info.val[index]} = 2'b00;
          //          $display("Going north making dest invalid");
          //      end
          //      else begin 
          //        //if(position.y-1 == fifo_head[noc::kNorthPort].header.info.destination[index].y) // dest_is_local_for_next_router_0
          //          //fifo_head_temp[g_i][noc::kNorthPort].header.info.val[index] = 0;
         	//      //else 
          //         if(position.y-1 < fifo_head[noc::kNorthPort].header.info.destination[index].y) // opposite_direction_dest
          //     	    {val_checkme[g_i][0],fifo_head_temp[g_i][noc::kNorthPort].header.info.val[index]} = 2'b00;
          //     	  // else
          //     	  //    {val_checkme[g_i][0],fifo_head_temp[g_i][noc::kNorthPort].header.info.val[index]} = 2'b11;
          //      end
          //    end   
          //  end
	   // ajay_v Aren't we supposed to send out the fifo_head[] based on where the input is coming from ? rather than sending fifo_head[] of where we are heading to ! ?? doubt
            if(g_i == 0) begin // Going North
              for(int index = 0; index < DEST_SIZE; index++) begin  //check_north_and_inval_dest
                if(fifo_head[noc::kNorthPort].header.info.val[index]) begin 
                  // if(position.x != fifo_head[noc::kNorthPort].header.info.destination[index].x) begin  // dest_in_wrong_direction_for_next_router_0
                  if(position.x != destination_arr_temp[noc::kNorthPort][index].x) begin  // dest_in_wrong_direction_for_next_router_0
                      fifo_head_temp[g_i][noc::kNorthPort].header.info.val[index] = 0;
                      inval_routing[g_i][0] = 0;
                      dest_checkme[g_i] = 3'h7;
                  end
                  else begin 
                    // if(position.y-1 < fifo_head[noc::kNorthPort].header.info.destination[index].y) begin // opposite_direction_dest
                    if(position.y-1 < destination_arr_temp[noc::kNorthPort][index].y) begin // opposite_direction_dest
                      fifo_head_temp[g_i][noc::kNorthPort].header.info.val[index] = 0;
                      inval_routing[g_i][0] = 0;
                      dest_checkme[g_i] = 3'h7;
                    end
                  end
                end   
              end
            end

            if(g_i == 1) begin // Going South
              for(int index = 0; index < DEST_SIZE; index++) begin  // check_south_and_inval_dest
              // ajay_v   ******** To invalidate the routing bits ******* //
              // If going from south in to North out, you cant have E,W,N routing
              inval_routing[g_i][3] = 0;
              inval_routing[g_i][2] = 0;
              inval_routing[g_i][0] = 0;

                  if(fifo_head[noc::kNorthPort].header.info.val[index]) begin //---------- ajay_v - do we need to check for this condition ? ----------
                    if(position.x != destination_arr_temp[noc::kNorthPort][index].x) begin  // 
                      fifo_head_temp[g_i][noc::kNorthPort].header.info.val[index] = 0;
                      inval_routing[g_i][0] = 0;
                      dest_checkme[g_i] = 3'h5;
                    end
                    else begin  // wrong_direction_in_next_router_1
                      if(!(destination_arr_temp[noc::kNorthPort][index].y)) begin // destination is on the north // Check if pos.y+1 > dest
                        fifo_head_temp[g_i][noc::kNorthPort].header.info.val[index] = 0;
                        inval_routing[g_i][0] = 0;
                        dest_checkme[g_i] = 3'h5;
                      end
                    end
                  end
              end
            end
            if(g_i == 2) begin // Going West
              for(int index = 0; index < DEST_SIZE; index++) begin  // check_west_and_inval_dest
                  if(fifo_head[noc::kNorthPort].header.info.val[index]) begin // ---------- ajay_v - do we need to check for this condition ? ----------
                    if(position.x-1 < destination_arr_temp[noc::kNorthPort][index].x) begin // The destination is in the east direction 
                      fifo_head_temp[g_i][noc::kNorthPort].header.info.val[index] = 0;
                      inval_routing[g_i][0] = 0;
                      dest_checkme[g_i] = 3'h3;
                    end
                  end
              end // check_west_and_inval_dest
            end
            if(g_i == 3) begin // Going East
              for(int index = 0; index < DEST_SIZE; index++) begin  // check_west_and_inval_dest
                  if(fifo_head[noc::kNorthPort].header.info.val[index]) begin // ---------- ajay_v - do we need to check for this condition ? ----------
                    if(position.x+1 > destination_arr_temp[noc::kNorthPort][index].x) begin// The destination is in the east direction 
                      fifo_head_temp[g_i][noc::kNorthPort].header.info.val[index] = 0;
                      inval_routing[g_i][0] = 0;
                      dest_checkme[g_i] = 3'h1;
                    end
                  end
              end // check_west_and_inval_dest
            end
            if(g_i == 4) begin // Going Local
              for(int index = 0; index < DEST_SIZE; index++) begin  // check_east_and_inval_dest
                if(fifo_head[noc::kNorthPort].header.info.val[index]) begin // 
                  if((position.x != destination_arr_temp[noc::kNorthPort][index].x) || (position.y != destination_arr_temp[noc::kNorthPort][index].y)) begin // local_out
                    fifo_head_temp[g_i][noc::kNorthPort].header.info.val[index] = 0;
                    inval_routing[g_i][0]=0; 
                    dest_checkme[g_i] = 3'h6;
                  end
                end
              end  
            end
          fifo_head_routing[g_i] = fifo_head_temp[g_i][noc::kNorthPort].header.preamble.head ? fifo_head_temp[g_i][noc::kNorthPort].header : fifo_head[noc::kNorthPort].flit;

          //  data_out_crossbar[g_i] = ~insert_lookahead_routing[g_i] ? fifo_head_temp[g_i][noc::kNorthPort] :
          //  {fifo_head_temp[g_i][noc::kNorthPort].flit[PortWidth-1:5], (next_hop_routing[noc::kNorthPort])};
          //  {fifo_head_temp[g_i][noc::kNorthPort].flit[PortWidth-1:5], (next_hop_routing[noc::kNorthPort] & inval_routing[g_i])};
	   //data_out_crossbar[g_i] = ~insert_lookahead_routing[g_i] ? fifo_head_temp[noc::kNorthPort] :  
           //{fifo_head_temp[noc::kNorthPort].flit[PortWidth-1:5], next_hop_routing[noc::kNorthPort]};
           rd_fifo[g_i][noc::kNorthPort] = no_backpressure[g_i];
           out_unvalid_flit[g_i] = in_unvalid_flit[noc::kNorthPort];
	   
        end

         if (enhanc_routing_configuration[g_i] == noc::goSouth) begin  // current_routing_south
        //if (enhanc_routing_configuration[g_i][1]) begin  // current_routing_south
        	 	    val_checkme[g_i] = 3'h5;

	   //fifo_head_temp[noc::kSouthPort] = fifo_head[noc::kSouthPort];
           // Check for all destinations 
  //          for(int index = 0; index < 2; index++) begin  // check_south_and_inval_dest
  //             if(fifo_head_temp[g_i][noc::kSouthPort].header.info.val[index]) begin //---------- ajay_v - do we need to check for this condition ? ----------
		
  //             // if(fifo_head[g_i].header.info.val[index]) begin  // check_south_and_inval_dest_2 ajay_v - do we need to check for this condition ?
 	//       // Disabling the destination valid that is already taken care/crossed
  //             // Conditions for a destination to be invalid when the packet going to South of current packet 
 	//       // 1. if the x value of destination is not equal to the x value of next tile, invalidate that destination
  //             // 2. If the packet is local for the next router then make the valid as 0
 	//       // 3. If the x value of destination is equal to the x value of next tile, and y value of destination is less the the y value of next tile, then invalidate the destination
  //             // fifo_head[g_i] is replaced with fifo_head[corresponding port]
  //             //if(fifo_head_temp[g_i][noc::kSouthPort].header.info.val[index]) begin // Check only if valid dest
	// //	val_checkme = position.y+1;
  //               if(position.x != fifo_head[noc::kSouthPort].header.info.destination[index].x) begin  // 
  //                 fifo_head_temp[g_i][noc::kSouthPort].header.info.val[index] = 0;
  //               end
  //               else begin  // wrong_direction_in_next_router_1
  //                 //if(position.y+1 == fifo_head[noc::kSouthPort].header.info.destination[index].y) // local_in_next_router
  //                 //  fifo_head_temp[g_i][noc::kSouthPort].header.info.val[index] = 0;
  //                 //else
  //                 if(!(fifo_head_temp[g_i][noc::kSouthPort].header.info.destination[index].y)) begin // destination is on the north // Check if pos.y+1 > dest
  //                   fifo_head_temp[g_i][noc::kSouthPort].header.info.val[index] = 0;
	//  	    //val_checkme[g_i] = 3'h7;
	// 	  end
  //                 // else
  //                 //   {val_checkme[g_i][1],fifo_head_temp[g_i][noc::kSouthPort].header.info.val[index]} = 2'b11;
  //               end
  //             end
 	//     end // check_south_and_inval_dest
	    // ajay_v Aren't we supposed to send out the fifo_head[] based on where the input is coming from ? rather than sending fifo_head[] of where we are heading to ! 
        if(g_i == 0) begin // Going North
          for(int index = 0; index < DEST_SIZE; index++) begin  //check_north_and_inval_dest
            if(fifo_head[noc::kSouthPort].header.info.val[index]) begin 
              // ajay_v   ******** To invalidate the routing bits ******* //
              // If going from south in to North out, you cant have E,W,S routing
              inval_routing[g_i][3] = 0;
              inval_routing[g_i][2] = 0;
              inval_routing[g_i][1] = 0;

              if(position.x != destination_arr_temp[noc::kSouthPort][index].x) begin  // dest_in_wrong_direction_for_next_router_0
                  fifo_head_temp[g_i][noc::kSouthPort].header.info.val[index] = 0;
                  inval_routing[g_i][1] = 0;
                  dest_checkme[g_i] = 3'h7;
              end
              else begin 
                if(position.y-1 < destination_arr_temp[noc::kSouthPort][index].y) begin // opposite_direction_dest
                  fifo_head_temp[g_i][noc::kSouthPort].header.info.val[index] = 0;
                  inval_routing[g_i][1] = 0;
                  dest_checkme[g_i] = 3'h7;
                end
              end
            end   
          end
        end

        if(g_i == 1) begin // Going South
          for(int index = 0; index < DEST_SIZE; index++) begin  // check_south_and_inval_dest
              if(fifo_head[noc::kSouthPort].header.info.val[index]) begin //---------- ajay_v - do we need to check for this condition ? ----------
                if(position.x != destination_arr_temp[noc::kSouthPort][index].x) begin  // 
                  fifo_head_temp[g_i][noc::kSouthPort].header.info.val[index] = 0;
                  inval_routing[g_i][1] = 0;
                  dest_checkme[g_i] = 3'h5;
                end
                else begin  // wrong_direction_in_next_router_1
                  if(!(destination_arr_temp[noc::kSouthPort][index].y)) begin // destination is on the north // Check if pos.y+1 > dest
                    fifo_head_temp[g_i][noc::kSouthPort].header.info.val[index] = 0;
                    inval_routing[g_i][1] = 0;
                    dest_checkme[g_i] = 3'h5;
		              end
                end
              end
          end
        end
        if(g_i == 2) begin // Going West
          for(int index = 0; index < DEST_SIZE; index++) begin  // check_west_and_inval_dest
              if(fifo_head[noc::kSouthPort].header.info.val[index]) begin // ---------- ajay_v - do we need to check for this condition ? ----------
                if(position.x-1 < destination_arr_temp[noc::kSouthPort][index].x) begin // The destination is in the east direction 
                  fifo_head_temp[g_i][noc::kSouthPort].header.info.val[index] = 0;
                  inval_routing[g_i][1] = 0;
                  dest_checkme[g_i] = 3'h3;
                end
              end
          end // check_west_and_inval_dest
        end
        if(g_i == 3) begin // Going East
          for(int index = 0; index < DEST_SIZE; index++) begin  // check_west_and_inval_dest
              if(fifo_head[noc::kSouthPort].header.info.val[index]) begin // ---------- ajay_v - do we need to check for this condition ? ----------
                if(position.x+1 > destination_arr_temp[noc::kSouthPort][index].x) begin// The destination is in the east direction 
                  fifo_head_temp[g_i][noc::kSouthPort].header.info.val[index] = 0;
                  inval_routing[g_i][1] = 0;
                  dest_checkme[g_i] = 3'h1;
                end
              end
          end // check_west_and_inval_dest
        end
        if(g_i == 4) begin // Going Local
          for(int index = 0; index < DEST_SIZE; index++) begin  // check_east_and_inval_dest
            if(fifo_head[noc::kSouthPort].header.info.val[index]) begin // 
              if((position.x != destination_arr_temp[noc::kSouthPort][index].x) || (position.y != destination_arr_temp[noc::kSouthPort][index].y)) begin // local_out
                fifo_head_temp[g_i][noc::kSouthPort].header.info.val[index] = 0;
                inval_routing[g_i][1] = 0;
                dest_checkme[g_i] = 3'h6;
              end
            end
          end  
        end

          fifo_head_routing[g_i] = fifo_head_temp[g_i][noc::kSouthPort].header.preamble.head ? fifo_head_temp[g_i][noc::kSouthPort].header : fifo_head[noc::kSouthPort].flit;

            // data_out_crossbar[g_i] = ~insert_lookahead_routing[g_i] ? fifo_head_temp[g_i][noc::kSouthPort] :
            // {fifo_head_temp[g_i][noc::kSouthPort].flit[PortWidth-1:5], (next_hop_routing[noc::kSouthPort])};
              // {fifo_head_temp[g_i][noc::kSouthPort].flit[PortWidth-1:5], (next_hop_routing[noc::kSouthPort] & inval_routing[g_i])};
            rd_fifo[g_i][noc::kSouthPort] = no_backpressure[g_i];
            out_unvalid_flit[g_i] = in_unvalid_flit[noc::kSouthPort];
	   
        end // current_routing_south

         if (enhanc_routing_configuration[g_i] == noc::goWest) begin  // current_routing_west
        //if (enhanc_routing_configuration[g_i][2]) begin
	   //fifo_head_temp[noc::kWestPort] = fifo_head[noc::kWestPort];
	 	    val_checkme[g_i] = 3'h3;



    //       for(int index = 0; index < 2; index++) begin  // check_west_and_inval_dest
    //           if(fifo_head[g_i].header.info.val[index]) begin // ---------- ajay_v - do we need to check for this condition ? ----------
    //           // If the packet is local for the next router then make the valid as 0
    //           // Disabling the destination valid that is already taken care/crossed
    //           // Conditions for a destination to be invalid when the packet going to West of current packet 
    //           // 1. If the packet is local for the next router then make the valid as 0
    //           // 2. If the y value of destination is equal to the y value of next tile, and x value of destination is greater than x value of next tile, then invalidate the destination
    //           // 3. If the y value of destination is not equal to the y value of next tile, and x value of destination is greater than x value of next tile, then invalidate the destination
    //           // fifo_head[g_i] is replaced with fifo_head[corresponding port]
    //           //if(fifo_head_temp[g_i][noc::kWestPort].header.info.val[index]) begin // Check only if valid dest
    //             if(position.x-1 < fifo_head[noc::kWestPort].header.info.destination[index].x) // The destination is in the east direction 
    //                           {val_checkme[g_i][2],fifo_head_temp[g_i][noc::kWestPort].header.info.val[index]} = 2'b00;
    //             // else
    //             //   {val_checkme[g_i][2],fifo_head_temp[g_i][noc::kWestPort].header.info.val[index]} = 2'b11; // Destination is valid
    //           //end
    //         end
    //       end // check_west_and_inval_dest
	  // // ajay_v Aren't we supposed to send out the fifo_head[] based on where the input is coming from ? rather than sending fifo_head[] of where we are heading to ! 

        if(g_i == 0) begin // Going North
          for(int index = 0; index < DEST_SIZE; index++) begin  //check_north_and_inval_dest
            if(fifo_head[noc::kWestPort].header.info.val[index]) begin 
                // ajay_v   ******** To invalidate the routing bits ******* //
                // If going from west in to North out, you cant have E,W,S routing
                inval_routing[g_i][3] = 0;
                inval_routing[g_i][2] = 0;
                inval_routing[g_i][1] = 0;

              if(position.x != destination_arr_temp[noc::kWestPort][index].x) begin  // dest_in_wrong_direction_for_next_router_0
                  fifo_head_temp[g_i][noc::kWestPort].header.info.val[index] = 0;
                  inval_routing[g_i][2] = 0;
                  dest_checkme[g_i] = 3'h7;
              end
              else begin 
                if(position.y-1 < destination_arr_temp[noc::kWestPort][index].y) begin // opposite_direction_dest
                  fifo_head_temp[g_i][noc::kWestPort].header.info.val[index] = 0;
                  inval_routing[g_i][2] = 0;
                  dest_checkme[g_i] = 3'h7;
                end
              end
            end   
          end
        end

        if(g_i == 1) begin // Going South
          for(int index = 0; index < DEST_SIZE; index++) begin  // check_south_and_inval_dest
              if(fifo_head[noc::kWestPort].header.info.val[index]) begin //---------- ajay_v - do we need to check for this condition ? ----------
                // ajay_v   ******** To invalidate the routing bits ******* //
                // If going from west in to south out, you cant have E,W,N routing
                inval_routing[g_i][3] = 0;
                inval_routing[g_i][2] = 0;
                inval_routing[g_i][0] = 0;
                if(position.x != destination_arr_temp[noc::kWestPort][index].x) begin  // 
                  fifo_head_temp[g_i][noc::kWestPort].header.info.val[index] = 0;
                  dest_checkme[g_i] = 3'h5;
                end
                else begin  // wrong_direction_in_next_router_1
                  if(!(destination_arr_temp[noc::kWestPort][index].y)) begin // destination is on the north // Check if pos.y+1 > dest
                    fifo_head_temp[g_i][noc::kWestPort].header.info.val[index] = 0;
                    dest_checkme[g_i] = 3'h5;
		              end
                end
              end
          end
        end
        if(g_i == 2) begin // Going West
          for(int index = 0; index < DEST_SIZE; index++) begin  // check_west_and_inval_dest
              if(fifo_head[noc::kWestPort].header.info.val[index]) begin // ---------- ajay_v - do we need to check for this condition ? ----------
                if(position.x-1 < destination_arr_temp[noc::kWestPort][index].x) begin // The destination is in the east direction 
                  fifo_head_temp[g_i][noc::kWestPort].header.info.val[index] = 0;
                  inval_routing[g_i][2] = 0;
                  dest_checkme[g_i] = 3'h3;
                end
                // ajay_v   ******** To invalidate the routing bits ******* //
                if(position.x-1 == destination_arr_temp[noc::kWestPort][index].x) begin
                  inval_routing[g_i][1] = 1;
                  inval_routing[g_i][0] = 1;
                  inval_routing[g_i][4] = 1;
                end
                else if(position.x-1 != destination_arr_temp[noc::kWestPort][index].x) begin // Its its not a local there or not needed to go north or south, make the local bit of routing 0
                  inval_routing[g_i][4] = 0;
                  inval_routing[g_i][1] = 0;
                  inval_routing[g_i][0] = 0;
                end

              end
          end // check_west_and_inval_dest
        end
        if(g_i == 3) begin // Going East
          for(int index = 0; index < DEST_SIZE; index++) begin  // check_west_and_inval_dest
              if(fifo_head[noc::kWestPort].header.info.val[index]) begin // ---------- ajay_v - do we need to check for this condition ? ----------
                if(position.x+1 > destination_arr_temp[noc::kWestPort][index].x) begin// The destination is in the east direction 
                  fifo_head_temp[g_i][noc::kWestPort].header.info.val[index] = 0;
                  inval_routing[g_i][2] = 0;
                  dest_checkme[g_i] = 3'h1;
                end
                // ajay_v   ******** To invalidate the routing bits ******* //
                if(position.x+1 == destination_arr_temp[noc::kWestPort][index].x) begin
                  inval_routing[g_i][1] = ~inval_routing[g_i][1];
                  inval_routing[g_i][0] = ~inval_routing[g_i][0];
                end
                // else if(position.x+1 != fifo_head[noc::kWestPort].header.info.destination[index].x) begin // 
                else if(position.x+1 != destination_arr_temp[noc::kWestPort][index].x) begin // 
                  inval_routing[g_i][1] = ~inval_routing[g_i][1];
                  inval_routing[g_i][0] = ~inval_routing[g_i][0];
                end
              end
          end // check_west_and_inval_dest
        end
        if(g_i == 4) begin // Going Local
          for(int index = 0; index < DEST_SIZE; index++) begin  // check_east_and_inval_dest
            if(fifo_head[noc::kWestPort].header.info.val[index]) begin // 
              if((position.x != destination_arr_temp[noc::kWestPort][index].x) || (position.y != destination_arr_temp[noc::kWestPort][index].y)) begin // local_out
                fifo_head_temp[g_i][noc::kWestPort].header.info.val[index] = 0;
                inval_routing[g_i][2] = 0;
                dest_checkme[g_i] = 3'h6;
              end
            end
          end  
        end


          fifo_head_routing[g_i] = fifo_head_temp[g_i][noc::kWestPort].header.preamble.head ? fifo_head_temp[g_i][noc::kWestPort].header : fifo_head[noc::kWestPort].flit;
          // data_out_crossbar[g_i] = ~insert_lookahead_routing[g_i] ? fifo_head_temp[g_i][noc::kWestPort] :
          // {fifo_head_temp[g_i][noc::kWestPort].flit[PortWidth-1:5], (next_hop_routing[noc::kWestPort])};          
            // {fifo_head_temp[g_i][noc::kWestPort].flit[PortWidth-1:5], (next_hop_routing[noc::kWestPort] & inval_routing[g_i])};
          rd_fifo[g_i][noc::kWestPort] = no_backpressure[g_i];
          out_unvalid_flit[g_i] = in_unvalid_flit[noc::kWestPort];
	   
        end // current_routing_west

         if (enhanc_routing_configuration[g_i] == noc::goEast) begin  // current_routing_east
        //if (enhanc_routing_configuration[g_i][3]) begin
	   //fifo_head_temp[noc::kEastPort] = fifo_head[noc::kEastPort];
	 	    val_checkme[g_i] = 3'h1;

//           for(int index = 0; index < 2; index++) begin  // check_east_and_inval_dest
//             if(fifo_head[g_i].header.info.val[index]) begin // ---------- ajay_v - do we need to check for this condition ? ----------
//             // If the packet is local for the next router then make the valid as 0
//             // Disabling the destination valid that is already taken care/crossed
//             // Conditions for a destination to be invalid when the packet going to East of current packet 
//             // 1. If the packet is local for the next router then make the valid as 0
//             // 2. If the y value of destination is equal to the y value of next tile, and x value of destination is less than x value of next tile, then invalidate the destination
//             // 3. If the y value of destination is not equal to the y value of next tile, and x value of destination is less than x value of next tile, then invalidate the destination
//               // fifo_head[g_i] is replaced with fifo_head[corresponding port]
//             //if(fifo_head_temp[g_i][noc::kEastPort].header.info.val[index]) begin // 
//         	// Changed at 21:47  5/3/23        
// //              if(position.y == fifo_head[noc::kEastPort].header.info.destination[index].y) begin 
// //                //if(position.x-1 == fifo_head[noc::kEastPort].header.info.destination[index].x) // It is local at next tile
// //                //  fifo_head_temp[g_i][noc::kEastPort].header.info.val[index] = 0;
// //                //else
// //                if(position.x+1 > fifo_head[noc::kEastPort].header.info.destination[index].x) // The destination is in the west direction on the same x-axis
// //                  fifo_head_temp[g_i][noc::kEastPort].header.info.val[index] = 0;
// //                else
// //                  fifo_head_temp[g_i][noc::kEastPort].header.info.val[index] = 1; // Destination is valid
// //              end
// //              else begin
//                 if(position.x+1 > fifo_head[noc::kEastPort].header.info.destination[index].x) // The destination is in the west direction 
//                   {val_checkme[g_i][3],fifo_head_temp[g_i][noc::kEastPort].header.info.val[index]} = 2'b00;
//         	// Changed at 21:47  5/3/23        
// 	//else
//                 //  fifo_head_temp[g_i][noc::kEastPort].header.info.val[index] = 1; // Destination is valid
//               //end
//             end
//           end
	  // ajay_v Aren't we supposed to send out the fifo_head[] based on where the input is coming from ? rather than sending fifo_head[] of where we are heading to ! 
        if(g_i == 0) begin // Going North
          for(int index = 0; index < DEST_SIZE; index++) begin  //check_north_and_inval_dest
            // ajay_v   ******** To invalidate the routing bits ******* //
            // If going from west in to North out, you cant have E,W,S routing
            inval_routing[g_i][3] = 0;
            inval_routing[g_i][2] = 0;
            inval_routing[g_i][1] = 0;

            if(fifo_head[noc::kEastPort].header.info.val[index]) begin 
              if(position.x != destination_arr_temp[noc::kEastPort][index].x) begin  // dest_in_wrong_direction_for_next_router_0
                  fifo_head_temp[g_i][noc::kEastPort].header.info.val[index] = 0;
                  inval_routing[g_i][3] = 0;
                  dest_checkme[g_i] = 3'h7;
              end
              else begin 
                if(position.y-1 < destination_arr_temp[noc::kEastPort][index].y) begin // opposite_direction_dest
                  fifo_head_temp[g_i][noc::kEastPort].header.info.val[index] = 0;
                  inval_routing[g_i][3] = 0;
                  dest_checkme[g_i] = 3'h7;
                end
              end
            end   
          end
        end

        if(g_i == 1) begin // Going South
          for(int index = 0; index < DEST_SIZE; index++) begin  // check_south_and_inval_dest
              if(fifo_head[noc::kEastPort].header.info.val[index]) begin //---------- ajay_v - do we need to check for this condition ? ----------
                // ajay_v   ******** To invalidate the routing bits ******* //
                // If going from East in to South out, you cant have E,W,N routing
                inval_routing[g_i][3] = 0;
                inval_routing[g_i][2] = 0;
                inval_routing[g_i][0] = 0;

                if(position.x != destination_arr_temp[noc::kEastPort][index].x) begin  // 
                  fifo_head_temp[g_i][noc::kEastPort].header.info.val[index] = 0;
                  inval_routing[g_i][3] = 0;
                  dest_checkme[g_i] = 3'h5;
                end
                else begin  // wrong_direction_in_next_router_1
                  if(!(destination_arr_temp[noc::kEastPort][index].y)) begin // destination is on the north // Check if pos.y+1 > dest
                    fifo_head_temp[g_i][noc::kEastPort].header.info.val[index] = 0;
                    inval_routing[g_i][3] = 0;
                    dest_checkme[g_i] = 3'h5;
		              end
                end
              end
          end
        end
        if(g_i == 2) begin // Going West
          for(int index = 0; index < DEST_SIZE; index++) begin  // check_west_and_inval_dest
              if(fifo_head[noc::kEastPort].header.info.val[index]) begin // ---------- ajay_v - do we need to check for this condition ? ----------
                if(position.x-1 < destination_arr_temp[noc::kEastPort][index].x) begin // The destination is in the east direction 
                  fifo_head_temp[g_i][noc::kEastPort].header.info.val[index] = 0;
                  inval_routing[g_i][3] = 0;
                  dest_checkme[g_i] = 3'h3;
                end
                // ajay_v   ******** To invalidate the routing bits ******* //
                if(position.x-1 != destination_arr_temp[noc::kEastPort][index].x) begin // Its its not a local there or not needed to go north or south, make the local bit of routing 0
                  inval_routing[g_i][4] = 0;
                  inval_routing[g_i][1] = 0;
                  inval_routing[g_i][0] = 0;
                end
              end
          end // check_west_and_inval_dest
        end
        if(g_i == 3) begin // Going East
          for(int index = 0; index < DEST_SIZE; index++) begin  // check_west_and_inval_dest
              if(fifo_head[noc::kEastPort].header.info.val[index]) begin // ---------- ajay_v - do we need to check for this condition ? ----------
                if(position.x+1 > destination_arr_temp[noc::kEastPort][index].x) begin// The destination is in the east direction 
                  fifo_head_temp[g_i][noc::kEastPort].header.info.val[index] = 0;
                  inval_routing[g_i][3] = 0;
                  dest_checkme[g_i] = 3'h1;
                end
              end
          end // check_west_and_inval_dest
        end
        if(g_i == 4) begin // Going Local
          for(int index = 0; index < DEST_SIZE; index++) begin  // check_east_and_inval_dest
            if(fifo_head[noc::kEastPort].header.info.val[index]) begin // 
              if((position.x != destination_arr_temp[noc::kEastPort][index].x) || (position.y != destination_arr_temp[noc::kEastPort][index].y)) begin // local_out
                fifo_head_temp[g_i][noc::kEastPort].header.info.val[index] = 0;
                inval_routing[g_i][3] = 0;
                dest_checkme[g_i] = 3'h6;
              end
            end
          end  
        end

          fifo_head_routing[g_i] = fifo_head_temp[g_i][noc::kEastPort].header.preamble.head ? fifo_head_temp[g_i][noc::kEastPort].header : fifo_head[noc::kEastPort].flit;

          // data_out_crossbar[g_i] = ~insert_lookahead_routing[g_i] ? fifo_head_temp[g_i][noc::kEastPort] :
            // {fifo_head_temp[g_i][noc::kEastPort].flit[PortWidth-1:5], (next_hop_routing[noc::kEastPort])};
            // {fifo_head_temp[g_i][noc::kEastPort].flit[PortWidth-1:5], (next_hop_routing[noc::kEastPort] & inval_routing[g_i])};
          rd_fifo[g_i][noc::kEastPort] = no_backpressure[g_i];
          out_unvalid_flit[g_i] = in_unvalid_flit[noc::kEastPort];
	   
        end

    if (enhanc_routing_configuration[g_i] == noc::goLocal) begin
    //if (enhanc_routing_configuration[g_i][4]) begin
            val_checkme[g_i] = 3'h6;

	  // fifo_head_temp[noc::kLocalPort] = fifo_head[noc::kLocalPort];
	  // Q : ajay_v Aren't we supposed to send out the fifo_head[] based on where the input is coming from ? rather than sending fifo_head[] of where we are heading to !
	  // Ans : kLocalPort will be pointed to the input FIFO that is feeding data to this router
	  // for(int index = 0; index < 2; index++) begin  // check_local_and_inval_other_dest
		// if((position.y == fifo_head[noc::kLocalPort].header.info.destination[index].y) && (position.x == fifo_head[noc::kLocalPort].header.info.destination[index].x)) 
		// 	fifo_head_temp[g_i][noc::kLocalPort].header.info.val[index] = 1;	
		// else
		// 	fifo_head_temp[g_i][noc::kLocalPort].header.info.val[index] = 0;
	  // end
      // for(int index = 0; index < 2; index++) begin  // check_east_and_inval_dest
      //   if(fifo_head_temp[g_i][noc::kLocalPort].header.info.val[index]) begin // 
      //     if((position.x != fifo_head[noc::kLocalPort].header.info.destination[index].x) || (position.y != fifo_head[noc::kLocalPort].header.info.destination[index].y)) // local_out
      //       fifo_head_temp[g_i][noc::kLocalPort].header.info.val[index] = 0;
      //     // else
      //     //   fifo_head_temp[g_i][noc::kLocalPort].header.info.val[index] = 0;
      //   end
      // end  

        if(g_i == 0) begin // Going North
          for(int index = 0; index < DEST_SIZE; index++) begin  //check_north_and_inval_dest
            if(fifo_head[noc::kLocalPort].header.info.val[index]) begin 
              if(position.x != destination_arr_temp[noc::kLocalPort][index].x) begin  // dest_in_wrong_direction_for_next_router_0
                  fifo_head_temp[g_i][noc::kLocalPort].header.info.val[index] = 0;
                  inval_routing[g_i][4] = 0;
                  dest_checkme[g_i] = 3'h7;
              end
              else begin 
                if(position.y-1 < destination_arr_temp[noc::kLocalPort][index].y) begin // opposite_direction_dest
                  fifo_head_temp[g_i][noc::kLocalPort].header.info.val[index] = 0;
                  inval_routing[g_i][4] = 0;
                  dest_checkme[g_i] = 3'h7;
                end
              end
            end   
        end
          end

        if(g_i == 1) begin // Going South
          for(int index = 0; index < DEST_SIZE; index++) begin  // check_south_and_inval_dest
              if(fifo_head[noc::kLocalPort].header.info.val[index]) begin //---------- ajay_v - do we need to check for this condition ? ----------
                if(position.x != destination_arr_temp[noc::kLocalPort][index].x) begin  // 
                  fifo_head_temp[g_i][noc::kLocalPort].header.info.val[index] = 0;
                  inval_routing[g_i][4] = 0;
                  dest_checkme[g_i] = 3'h5;
                end
                else begin  // wrong_direction_in_next_router_1
                  if(!(destination_arr_temp[noc::kLocalPort][index].y)) begin // destination is on the north // Check if pos.y+1 > dest
                    fifo_head_temp[g_i][noc::kLocalPort].header.info.val[index] = 0;
                    inval_routing[g_i][4] = 0;
                    dest_checkme[g_i] = 3'h5;
		              end
                end
              end
          end
        end
        if(g_i == 2) begin // Going West
          for(int index = 0; index < DEST_SIZE; index++) begin  // check_west_and_inval_dest
              if(fifo_head[noc::kLocalPort].header.info.val[index]) begin // ---------- ajay_v - do we need to check for this condition ? ----------
                if(position.x-1 < destination_arr_temp[noc::kLocalPort][index].x) begin // The destination is in the east direction 
                  fifo_head_temp[g_i][noc::kLocalPort].header.info.val[index] = 0;
                  inval_routing[g_i][4] = 0;
                  dest_checkme[g_i] = 3'h3;
                end
              end
          end // check_west_and_inval_dest
        end
        if(g_i == 3) begin // Going East
          for(int index = 0; index < DEST_SIZE; index++) begin  // check_west_and_inval_dest
              if(fifo_head[noc::kLocalPort].header.info.val[index]) begin // ---------- ajay_v - do we need to check for this condition ? ----------
                if(position.x+1 > destination_arr_temp[noc::kLocalPort][index].x) begin// The destination is in the east direction 
                  fifo_head_temp[g_i][noc::kLocalPort].header.info.val[index] = 0;
                  inval_routing[g_i][4] = 0;
                  dest_checkme[g_i] = 3'h1;
                end
              end
          end // check_west_and_inval_dest
        end
        if(g_i == 4) begin // Going Local
          for(int index = 0; index < DEST_SIZE; index++) begin  // check_east_and_inval_dest
            if(fifo_head[noc::kLocalPort].header.info.val[index]) begin // 
              if((position.x != destination_arr_temp[noc::kLocalPort][index].x) || (position.y != destination_arr_temp[noc::kLocalPort][index].y)) begin // local_out
                fifo_head_temp[g_i][noc::kLocalPort].header.info.val[index] = 0;
                inval_routing[g_i][4] = 0;
                dest_checkme[g_i] = 3'h6;
              end
            end
          end  
        end

          fifo_head_routing[g_i] = fifo_head_temp[g_i][noc::kLocalPort].header.preamble.head ? fifo_head_temp[g_i][noc::kLocalPort].header : fifo_head[noc::kLocalPort].flit;

          // data_out_crossbar[g_i] = ~insert_lookahead_routing[g_i] ? fifo_head_temp[g_i][noc::kLocalPort] :
          //   {fifo_head_temp[g_i][noc::kLocalPort].flit[PortWidth-1:5], (next_hop_routing[noc::kLocalPort])};
            // {fifo_head_temp[g_i][noc::kLocalPort].flit[PortWidth-1:5], (next_hop_routing[noc::kLocalPort] & inval_routing[g_i])};

          rd_fifo[g_i][noc::kLocalPort] = no_backpressure[g_i];
          out_unvalid_flit[g_i] = in_unvalid_flit[noc::kLocalPort];
        end
        //  fifo_head[0] = 'b0;
        //  fifo_head[1] = 'b0;
        //  fifo_head[2] = 'b0;
        //  fifo_head[3] = 'b0;
        //  fifo_head[4] = 'b0;
      end
      
      assign current_routing[g_i] = 5'h1 << g_i ;

        lookahead_routing 
        #(
           .DEST_SIZE(DEST_SIZE)
        )
        lookahead_routing_i
        (
        .clk,
        .position,
        .destination(destination_arr_temp[g_i]),
        .val(fifo_head_routing[g_i].header.info.val),
        .current_routing(current_routing[g_i]),
        .next_routing(next_hop_routing[g_i])
        );

  // Modified on 11/29 to make sure we are updating valid bits only when we have header
  //      assign data_out_crossbar[g_i] = ~insert_lookahead_routing[g_i] ? fifo_head_routing[g_i] : (fifo_head[g_i].header.preamble.head ? {fifo_head_routing[g_i].header[PortWidth-1:5], (next_hop_routing[g_i])} : {fifo_head[g_i].flit[PortWidth-1:5],next_hop_routing[g_i]});
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
      assign no_backpressure[g_i] = FifoBypassEnable ? ~stop_in[g_i] : credits[g_i] != '0;
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
      assign no_backpressure[g_i] = '1;
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
      //assign transp_final_routing_request[g_i][g_j] = '0;

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
  //This assertion is to check whether we are not sending packet in the opposite direction
  // Need to update test bench 
    //a_no_request_to_same_port: assert property (@(posedge clk) disable iff(rst)
    //  final_routing_request[g_i][g_i] == 1'b0)
    //  else $info("Getting a_no_request_to_same_port"); //$error("Fail: a_no_request_to_same_port");
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
