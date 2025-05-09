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
  sc_in<sc_logic> vec_in_a_val;
  sc_out<sc_logic> vec_in_a_rdy;
  sc_in<sc_lv<512> > vec_in_a_msg;
  sc_in<sc_logic> vec_in_b_val;
  sc_out<sc_logic> vec_in_b_rdy;
  sc_in<sc_lv<512> > vec_in_b_msg;
  sc_out<sc_logic> vec_out_val;
  sc_in<sc_logic> vec_out_rdy;
  sc_out<sc_lv<512> > vec_out_msg;
public:
  ccs_DUT_wrapper(const sc_module_name& nm, const char *hdl_name)
  :
    mc_foreign_module(nm, hdl_name), 
    clk("clk"), 
    rst("rst"), 
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


