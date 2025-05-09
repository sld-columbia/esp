// SCVerify DUT wrapper used for SystemC > HDL interface bindings


module ccs_wrapper (
  clk, rst, conf_info_val, conf_info_rdy, conf_info_msg, conf_info_ctrl_dma2acc_val, conf_info_ctrl_dma2acc_rdy,
      conf_info_ctrl_dma2acc_msg, conf_info_ctrl_plm2vec_val, conf_info_ctrl_plm2vec_rdy, conf_info_ctrl_plm2vec_msg,
      conf_info_ctrl_acc2dma_val, conf_info_ctrl_acc2dma_rdy, conf_info_ctrl_acc2dma_msg
);
  input clk;
  input rst;
  input conf_info_val;
  output conf_info_rdy;
  input [159:0] conf_info_msg;
  output conf_info_ctrl_dma2acc_val;
  input conf_info_ctrl_dma2acc_rdy;
  output [159:0] conf_info_ctrl_dma2acc_msg;
  output conf_info_ctrl_plm2vec_val;
  input conf_info_ctrl_plm2vec_rdy;
  output [159:0] conf_info_ctrl_plm2vec_msg;
  output conf_info_ctrl_acc2dma_val;
  input conf_info_ctrl_acc2dma_rdy;
  output [159:0] conf_info_ctrl_acc2dma_msg;


  LeakyreluConfig dut_inst (
    .clk(clk),
    .rst(rst),
    .conf_info_val(conf_info_val),
    .conf_info_rdy(conf_info_rdy),
    .conf_info_msg(conf_info_msg),
    .conf_info_ctrl_dma2acc_val(conf_info_ctrl_dma2acc_val),
    .conf_info_ctrl_dma2acc_rdy(conf_info_ctrl_dma2acc_rdy),
    .conf_info_ctrl_dma2acc_msg(conf_info_ctrl_dma2acc_msg),
    .conf_info_ctrl_plm2vec_val(conf_info_ctrl_plm2vec_val),
    .conf_info_ctrl_plm2vec_rdy(conf_info_ctrl_plm2vec_rdy),
    .conf_info_ctrl_plm2vec_msg(conf_info_ctrl_plm2vec_msg),
    .conf_info_ctrl_acc2dma_val(conf_info_ctrl_acc2dma_val),
    .conf_info_ctrl_acc2dma_rdy(conf_info_ctrl_acc2dma_rdy),
    .conf_info_ctrl_acc2dma_msg(conf_info_ctrl_acc2dma_msg)
  );

endmodule

