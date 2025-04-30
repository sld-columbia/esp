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
  sc_in<sc_logic> conf_info_in_val;
  sc_out<sc_logic> conf_info_in_rdy;
  sc_in<sc_lv<96> > conf_info_in_msg;
  sc_in<sc_logic> sync00_val;
  sc_out<sc_logic> sync00_rdy;
  sc_in<sc_logic> sync00_msg;
  sc_out<sc_logic> in_wr_req_val;
  sc_in<sc_logic> in_wr_req_rdy;
  sc_out<sc_lv<32> > in_wr_req_msg;
  sc_in<sc_logic> in_rd_rsp_val;
  sc_out<sc_logic> in_rd_rsp_rdy;
  sc_in<sc_lv<64> > in_rd_rsp_msg;
public:
  ccs_DUT_wrapper(const sc_module_name& nm, const char *hdl_name)
  :
    mc_foreign_module(nm, hdl_name), 
    clk("clk"), 
    rst("rst"), 
    conf_info_in_val("conf_info_in_val"), 
    conf_info_in_rdy("conf_info_in_rdy"), 
    conf_info_in_msg("conf_info_in_msg"), 
    sync00_val("sync00_val"), 
    sync00_rdy("sync00_rdy"), 
    sync00_msg("sync00_msg"), 
    in_wr_req_val("in_wr_req_val"), 
    in_wr_req_rdy("in_wr_req_rdy"), 
    in_wr_req_msg("in_wr_req_msg"), 
    in_rd_rsp_val("in_rd_rsp_val"), 
    in_rd_rsp_rdy("in_rd_rsp_rdy"), 
    in_rd_rsp_msg("in_rd_rsp_msg")
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


