/* Copyright 2017 Columbia University, SLD Group */

#ifndef __LLC_TB_HPP__
#define __LLC_TB_HPP__


#include "cache_utils.hpp"

class llc_tb : public sc_module
{

public:

    // Clock signal
    sc_in<bool> clk;

    // Reset signal
    sc_in<bool> rst;

    // Debug signals
    sc_in< sc_bv<LLC_ASSERT_WIDTH> >   asserts;
    sc_in< sc_bv<LLC_BOOKMARK_WIDTH> > bookmark;
    sc_in<uint32_t>     custom_dbg;

    // Input ports
    put_initiator<llc_req_in_t> llc_req_in_tb;
    put_initiator<llc_rsp_in_t> llc_rsp_in_tb;
    put_initiator<llc_mem_rsp_t> llc_mem_rsp_tb; 

    // Output ports
    put_initiator<llc_rsp_out_t> llc_rsp_out_tb;
    put_initiator<llc_fwd_out_t> llc_fwd_out_tb;
    put_initiator<llc_mem_req_t> llc_mem_req_tb;

    // Constructor
    SC_CTOR(llc_tb)
    {
	// Process performing the test
	SC_CTHREAD(llc_test, clk.pos());
	reset_signal_is(rst, false);
	// set_stack_size(0x400000);

	// Debug process
	SC_CTHREAD(llc_debug, clk.pos());
	reset_signal_is(rst, false);
	// set_stack_size(0x400000);

	// Assign clock and reset to put_get ports
	llc_req_in_tb.clk_rst (clk, rst);
	llc_rsp_in_tb.clk_rst (clk, rst);
	llc_mem_rsp_tb.clk_rst (clk, rst);
	llc_rsp_out_tb.clk_rst(clk, rst);
	llc_fwd_out_tb.clk_rst(clk, rst);
	llc_mem_req_tb.clk_rst(clk, rst);
    }

    // Processes
    void llc_test();
    void llc_debug();

    // Functions
    inline void reset_llc_test();

    // void put_req_in(llc_req_in_t &req_in, coh_msg_t coh_msg, bool cacheable, addr_t addr, 
    // 		    line_t line, cache_id_t cache_id, bool rpt);
    // void put_rsp_in(addr_t addr, line_t line, cache_id_t cache_id, bool rpt);
    // void put_mem_rsp(addr_t addr, line_t line, bool rpt);
    // void get_rsp_out(coh_msg_t coh_msg, addr_t addr, line_t line, invack_cnt_t invack_cnt, 
    // 		     cache_id_t cache_id, bool rpt);
    // void get_mem_req(mem_msg_t mem_msg, hprot_t hprot, addr_t addr, line_t line, bool rpt);

    // void op(coh_msg_t coh_msg, sc_uint<2> beh, addr_breakdown_t req_addr, bool rpt);
};


#endif /* __LLC_TB_HPP__ */


