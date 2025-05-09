// SCVerify DUT wrapper used for SystemC > HDL interface bindings


module ccs_wrapper (
  clk, rst, acc_done, dma_read_chnl_val, dma_read_chnl_rdy, dma_read_chnl_msg, dma_write_chnl_val, dma_write_chnl_rdy,
      dma_write_chnl_msg, dma_read_ctrl_val, dma_read_ctrl_rdy, dma_read_ctrl_msg, dma_write_ctrl_val, dma_write_ctrl_rdy,
      dma_write_ctrl_msg, conf_info_ctrl_dma2acc_val, conf_info_ctrl_dma2acc_rdy, conf_info_ctrl_dma2acc_msg, conf_info_ctrl_plm2vec_val,
      conf_info_ctrl_plm2vec_rdy, conf_info_ctrl_plm2vec_msg, conf_info_ctrl_acc2dma_val, conf_info_ctrl_acc2dma_rdy,
      conf_info_ctrl_acc2dma_msg, vec_in_a_val, vec_in_a_rdy, vec_in_a_msg, vec_in_b_val, vec_in_b_rdy, vec_in_b_msg,
      vec_out_val, vec_out_rdy, vec_out_msg
);
  input clk;
  input rst;
  output acc_done;
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
  input conf_info_ctrl_dma2acc_val;
  output conf_info_ctrl_dma2acc_rdy;
  input [159:0] conf_info_ctrl_dma2acc_msg;
  input conf_info_ctrl_plm2vec_val;
  output conf_info_ctrl_plm2vec_rdy;
  input [159:0] conf_info_ctrl_plm2vec_msg;
  input conf_info_ctrl_acc2dma_val;
  output conf_info_ctrl_acc2dma_rdy;
  input [159:0] conf_info_ctrl_acc2dma_msg;
  output vec_in_a_val;
  input vec_in_a_rdy;
  output [511:0] vec_in_a_msg;
  output vec_in_b_val;
  input vec_in_b_rdy;
  output [511:0] vec_in_b_msg;
  input vec_out_val;
  output vec_out_rdy;
  input [511:0] vec_out_msg;


  LeakyreluController dut_inst (
    .clk(clk),
    .rst(rst),
    .acc_done(acc_done),
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
    .conf_info_ctrl_dma2acc_val(conf_info_ctrl_dma2acc_val),
    .conf_info_ctrl_dma2acc_rdy(conf_info_ctrl_dma2acc_rdy),
    .conf_info_ctrl_dma2acc_msg(conf_info_ctrl_dma2acc_msg),
    .conf_info_ctrl_plm2vec_val(conf_info_ctrl_plm2vec_val),
    .conf_info_ctrl_plm2vec_rdy(conf_info_ctrl_plm2vec_rdy),
    .conf_info_ctrl_plm2vec_msg(conf_info_ctrl_plm2vec_msg),
    .conf_info_ctrl_acc2dma_val(conf_info_ctrl_acc2dma_val),
    .conf_info_ctrl_acc2dma_rdy(conf_info_ctrl_acc2dma_rdy),
    .conf_info_ctrl_acc2dma_msg(conf_info_ctrl_acc2dma_msg),
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

