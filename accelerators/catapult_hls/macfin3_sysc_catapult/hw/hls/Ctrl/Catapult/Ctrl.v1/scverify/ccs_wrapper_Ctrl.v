// SCVerify DUT wrapper used for SystemC > HDL interface bindings


module ccs_wrapper (
  clk, rst, acc_done, conf_info_val, conf_info_rdy, conf_info_msg, dma_read_chnl_val, dma_read_chnl_rdy, dma_read_chnl_msg,
      dma_write_chnl_val, dma_write_chnl_rdy, dma_write_chnl_msg, dma_read_ctrl_val, dma_read_ctrl_rdy, dma_read_ctrl_msg,
      dma_write_ctrl_val, dma_write_ctrl_rdy, dma_write_ctrl_msg, conf_info_out_val, conf_info_out_rdy, conf_info_out_msg,
      sync00_val, sync00_rdy, sync00_msg, in_wr_req_val, in_wr_req_rdy, in_wr_req_msg, in_rd_rsp_val, in_rd_rsp_rdy,
      in_rd_rsp_msg
);
  input clk;
  input rst;
  output acc_done;
  input conf_info_val;
  output conf_info_rdy;
  input [95:0] conf_info_msg;
  input dma_read_chnl_val;
  output dma_read_chnl_rdy;
  input [63:0] dma_read_chnl_msg;
  output dma_write_chnl_val;
  input dma_write_chnl_rdy;
  output [63:0] dma_write_chnl_msg;
  output dma_read_ctrl_val;
  input dma_read_ctrl_rdy;
  output [72:0] dma_read_ctrl_msg;
  output dma_write_ctrl_val;
  input dma_write_ctrl_rdy;
  output [72:0] dma_write_ctrl_msg;
  output conf_info_out_val;
  input conf_info_out_rdy;
  output [95:0] conf_info_out_msg;
  output sync00_val;
  input sync00_rdy;
  output sync00_msg;
  input in_wr_req_val;
  output in_wr_req_rdy;
  input [31:0] in_wr_req_msg;
  output in_rd_rsp_val;
  input in_rd_rsp_rdy;
  output [63:0] in_rd_rsp_msg;


  Ctrl dut_inst (
    .clk(clk),
    .rst(rst),
    .acc_done(acc_done),
    .conf_info_val(conf_info_val),
    .conf_info_rdy(conf_info_rdy),
    .conf_info_msg(conf_info_msg),
    .dma_read_chnl_val(dma_read_chnl_val),
    .dma_read_chnl_rdy(dma_read_chnl_rdy),
    .dma_read_chnl_msg(dma_read_chnl_msg),
    .dma_write_chnl_val(dma_write_chnl_val),
    .dma_write_chnl_rdy(dma_write_chnl_rdy),
    .dma_write_chnl_msg(dma_write_chnl_msg),
    .dma_read_ctrl_val(dma_read_ctrl_val),
    .dma_read_ctrl_rdy(dma_read_ctrl_rdy),
    .dma_read_ctrl_msg(dma_read_ctrl_msg),
    .dma_write_ctrl_val(dma_write_ctrl_val),
    .dma_write_ctrl_rdy(dma_write_ctrl_rdy),
    .dma_write_ctrl_msg(dma_write_ctrl_msg),
    .conf_info_out_val(conf_info_out_val),
    .conf_info_out_rdy(conf_info_out_rdy),
    .conf_info_out_msg(conf_info_out_msg),
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

