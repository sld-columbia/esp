// SCVerify DUT wrapper used for SystemC > HDL interface bindings


module ccs_wrapper (
  clk, rst, conf_info_in_val, conf_info_in_rdy, conf_info_in_msg, sync00_val, sync00_rdy, sync00_msg, in_wr_req_val,
      in_wr_req_rdy, in_wr_req_msg, in_rd_rsp_val, in_rd_rsp_rdy, in_rd_rsp_msg
);
  input clk;
  input rst;
  input conf_info_in_val;
  output conf_info_in_rdy;
  input [95:0] conf_info_in_msg;
  input sync00_val;
  output sync00_rdy;
  input sync00_msg;
  output in_wr_req_val;
  input in_wr_req_rdy;
  output [31:0] in_wr_req_msg;
  input in_rd_rsp_val;
  output in_rd_rsp_rdy;
  input [63:0] in_rd_rsp_msg;


  DataPath dut_inst (
    .clk(clk),
    .rst(rst),
    .conf_info_in_val(conf_info_in_val),
    .conf_info_in_rdy(conf_info_in_rdy),
    .conf_info_in_msg(conf_info_in_msg),
    .sync00_val(sync00_val),
    .sync00_rdy(sync00_rdy),
    .sync00_msg(sync00_msg),
    .in_wr_req_val(in_wr_req_val),
    .in_wr_req_rdy(in_wr_req_rdy),
    .in_wr_req_msg(in_wr_req_msg),
    .in_rd_rsp_val(in_rd_rsp_val),
    .in_rd_rsp_rdy(in_rd_rsp_rdy),
    .in_rd_rsp_msg(in_rd_rsp_msg)
  );

endmodule

