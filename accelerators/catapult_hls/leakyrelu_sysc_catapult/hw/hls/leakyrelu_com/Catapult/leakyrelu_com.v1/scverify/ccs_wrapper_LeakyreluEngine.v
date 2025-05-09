// SCVerify DUT wrapper used for SystemC > HDL interface bindings


module ccs_wrapper (
  clk, rst, vec_in_a_val, vec_in_a_rdy, vec_in_a_msg, vec_in_b_val, vec_in_b_rdy, vec_in_b_msg, vec_out_val, vec_out_rdy,
      vec_out_msg
);
  input clk;
  input rst;
  input vec_in_a_val;
  output vec_in_a_rdy;
  input [511:0] vec_in_a_msg;
  input vec_in_b_val;
  output vec_in_b_rdy;
  input [511:0] vec_in_b_msg;
  output vec_out_val;
  input vec_out_rdy;
  output [511:0] vec_out_msg;


  LeakyreluEngine dut_inst (
    .clk(clk),
    .rst(rst),
    .vec_in_a_val(vec_in_a_val),
    .vec_in_a_rdy(vec_in_a_rdy),
    .vec_in_a_msg(vec_in_a_msg),
    .vec_in_b_val(vec_in_b_val),
    .vec_in_b_rdy(vec_in_b_rdy),
    .vec_in_b_msg(vec_in_b_msg),
    .vec_out_val(vec_out_val),
    .vec_out_rdy(vec_out_rdy),
    .vec_out_msg(vec_out_msg)
  );

endmodule

