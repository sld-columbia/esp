module lookahead_router_wrapper
  #(
    parameter bit FlowControl,
    parameter int unsigned Width = 32,
    parameter bit [4:0] Ports = noc::AllPorts
    )
  (
   input  logic clk,
   input  logic rst,
   // Coordinates
   input  logic[2:0] CONST_localx,
   input  logic[2:0] CONST_localy,
   // Input ports
   input  logic [Width-1:0] data_n_in,
   input  logic [Width-1:0] data_s_in,
   input  logic [Width-1:0] data_w_in,
   input  logic [Width-1:0] data_e_in,
   input  logic [Width-1:0] data_p_in,
   input  logic [4:0] data_void_in,
   output logic [4:0] stop_out,
   // Output ports
   output logic [Width-1:0] data_n_out,
   output logic [Width-1:0] data_s_out,
   output logic [Width-1:0] data_w_out,
   output logic [Width-1:0] data_e_out,
   output logic [Width-1:0] data_p_out,
   output logic [4:0] data_void_out,
   input  logic [4:0] stop_in
   );

  noc::xy_t position;
  assign position.x = CONST_localx;
  assign position.y = CONST_localy;

  lookahead_router
    #(
      .FlowControl(FlowControl),
      .DataWidth(Width - $bits(noc::preamble_t)),
      .Ports(Ports)
      ) router_impl_i
      (
       .clk,
       .rst(~rst),
       .position,
       .data_n_in,
       .data_s_in,
       .data_w_in,
       .data_e_in,
       .data_p_in,
       .data_void_in,
       .stop_out,
       .data_n_out,
       .data_s_out,
       .data_w_out,
       .data_e_out,
       .data_p_out,
       .data_void_out,
       .stop_in
       );

endmodule
