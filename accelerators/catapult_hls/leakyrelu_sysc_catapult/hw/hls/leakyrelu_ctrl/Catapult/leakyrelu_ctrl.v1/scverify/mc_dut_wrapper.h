// mc_dut_wrapper.h
#ifndef INCLUDED_CCS_DUT_WRAPPER_H
#define INCLUDED_CCS_DUT_WRAPPER_H

#ifndef SC_USE_STD_STRING
#define SC_USE_STD_STRING
#endif

#include <systemc.h>
#include <mc_simulator_extensions.h>

#ifdef CCS_SYSC
namespace HDL {
#endif

// Create a foreign module wrapper around the HDL
#ifdef VCS_SYSTEMC
// VCS support - ccs_DUT_wrapper is derived from VCS-generated SystemC wrapper around HDL code
class ccs_DUT_wrapper : public ccs_wrapper
{
public:
  ccs_DUT_wrapper(const sc_module_name& nm, const char *hdl_name)
  : ccs_wrapper(nm)
  {}
  ~ccs_DUT_wrapper() {}
};

#else
// non VCS simulators - ccs_DUT_wrapper is derived from mc_foreign_module (adding 2nd ctor arg)
class ccs_DUT_wrapper: public mc_foreign_module
{
public:
  // Interface Ports
  sc_in<bool> clk;
  sc_in<sc_logic> rst;
  sc_out<sc_logic> acc_done;
  sc_in<sc_logic> dma_read_chnl_val;
  sc_out<sc_logic> dma_read_chnl_rdy;
  sc_in<sc_lv<64> > dma_read_chnl_msg;
  sc_out<sc_logic> dma_write_chnl_val;
  sc_in<sc_logic> dma_write_chnl_rdy;
  sc_out<sc_lv<64> > dma_write_chnl_msg;
  sc_out<sc_logic> dma_read_ctrl_val;
  sc_in<sc_logic> dma_read_ctrl_rdy;
  sc_out<sc_lv<73> > dma_read_ctrl_msg;
  sc_out<sc_logic> dma_write_ctrl_val;
  sc_in<sc_logic> dma_write_ctrl_rdy;
  sc_out<sc_lv<73> > dma_write_ctrl_msg;
  sc_in<sc_logic> conf_info_ctrl_dma2acc_val;
  sc_out<sc_logic> conf_info_ctrl_dma2acc_rdy;
  sc_in<sc_lv<160> > conf_info_ctrl_dma2acc_msg;
  sc_in<sc_logic> conf_info_ctrl_plm2vec_val;
  sc_out<sc_logic> conf_info_ctrl_plm2vec_rdy;
  sc_in<sc_lv<160> > conf_info_ctrl_plm2vec_msg;
  sc_in<sc_logic> conf_info_ctrl_acc2dma_val;
  sc_out<sc_logic> conf_info_ctrl_acc2dma_rdy;
  sc_in<sc_lv<160> > conf_info_ctrl_acc2dma_msg;
  sc_out<sc_logic> vec_in_a_val;
  sc_in<sc_logic> vec_in_a_rdy;
  sc_out<sc_lv<512> > vec_in_a_msg;
  sc_out<sc_logic> vec_in_b_val;
  sc_in<sc_logic> vec_in_b_rdy;
  sc_out<sc_lv<512> > vec_in_b_msg;
  sc_in<sc_logic> vec_out_val;
  sc_out<sc_logic> vec_out_rdy;
  sc_in<sc_lv<512> > vec_out_msg;
public:
  ccs_DUT_wrapper(const sc_module_name& nm, const char *hdl_name)
  :
    mc_foreign_module(nm, hdl_name), 
    clk("clk"), 
    rst("rst"), 
    acc_done("acc_done"), 
    dma_read_chnl_val("dma_read_chnl_val"), 
    dma_read_chnl_rdy("dma_read_chnl_rdy"), 
    dma_read_chnl_msg("dma_read_chnl_msg"), 
    dma_write_chnl_val("dma_write_chnl_val"), 
    dma_write_chnl_rdy("dma_write_chnl_rdy"), 
    dma_write_chnl_msg("dma_write_chnl_msg"), 
    dma_read_ctrl_val("dma_read_ctrl_val"), 
    dma_read_ctrl_rdy("dma_read_ctrl_rdy"), 
    dma_read_ctrl_msg("dma_read_ctrl_msg"), 
    dma_write_ctrl_val("dma_write_ctrl_val"), 
    dma_write_ctrl_rdy("dma_write_ctrl_rdy"), 
    dma_write_ctrl_msg("dma_write_ctrl_msg"), 
    conf_info_ctrl_dma2acc_val("conf_info_ctrl_dma2acc_val"), 
    conf_info_ctrl_dma2acc_rdy("conf_info_ctrl_dma2acc_rdy"), 
    conf_info_ctrl_dma2acc_msg("conf_info_ctrl_dma2acc_msg"), 
    conf_info_ctrl_plm2vec_val("conf_info_ctrl_plm2vec_val"), 
    conf_info_ctrl_plm2vec_rdy("conf_info_ctrl_plm2vec_rdy"), 
    conf_info_ctrl_plm2vec_msg("conf_info_ctrl_plm2vec_msg"), 
    conf_info_ctrl_acc2dma_val("conf_info_ctrl_acc2dma_val"), 
    conf_info_ctrl_acc2dma_rdy("conf_info_ctrl_acc2dma_rdy"), 
    conf_info_ctrl_acc2dma_msg("conf_info_ctrl_acc2dma_msg"), 
    vec_in_a_val("vec_in_a_val"), 
    vec_in_a_rdy("vec_in_a_rdy"), 
    vec_in_a_msg("vec_in_a_msg"), 
    vec_in_b_val("vec_in_b_val"), 
    vec_in_b_rdy("vec_in_b_rdy"), 
    vec_in_b_msg("vec_in_b_msg"), 
    vec_out_val("vec_out_val"), 
    vec_out_rdy("vec_out_rdy"), 
    vec_out_msg("vec_out_msg")
  {
    elaborate_foreign_module(hdl_name);
  }

  ~ccs_DUT_wrapper() {}
};
#endif // VCS_SYSTEMC

#ifdef CCS_SYSC
} // namespace HDL
#endif
#endif // INCLUDED_CCS_DUT_WRAPPER_H


