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

    sc_in<bool> tag_hit_out;
    sc_in<llc_way_t> hit_way_out;
    sc_in<bool> empty_way_found_out;
    sc_in<llc_way_t> empty_way_out;
    sc_in<bool> evict_out;
    sc_in<llc_way_t> way_out;
    sc_in<llc_addr_t> llc_addr_out;

    // Input ports
    put_initiator<llc_req_in_t> llc_req_in_tb;
    put_initiator<llc_rsp_in_t> llc_rsp_in_tb;
    put_initiator<llc_mem_rsp_t> llc_mem_rsp_tb; 

    // Output ports
    get_initiator<llc_rsp_out_t> llc_rsp_out_tb;
    get_initiator<llc_fwd_out_t> llc_fwd_out_tb;
    get_initiator<llc_mem_req_t> llc_mem_req_tb;

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
    void op(coh_msg_t coh_msg, llc_state_t state, bool evict, addr_breakdown_t req_addr, 
	    addr_breakdown_t evict_addr, line_t req_line, line_t rsp_line, line_t evict_line,
	    invack_cnt_t invack_cnt, cache_id_t req_id, cache_id_t dest_id, bool rpt);
    void op_rsp(addr_breakdown_t req_addr, line_t req_line, cache_id_t req_id, bool rpt);
    void get_rsp_out(coh_msg_t coh_msg, addr_t addr, line_t line, invack_cnt_t invack_cnt,
			     cache_id_t req_id, cache_id_t dest_id, bool rpt);
    void get_fwd_out(coh_msg_t coh_msg, addr_t addr, cache_id_t req_id, cache_id_t dest_id, bool rpt);
    void get_mem_req(bool hwrite, addr_t addr, line_t line, bool rpt);
    void put_mem_rsp(line_t line, bool rpt);
    void put_req_in(coh_msg_t coh_msg, addr_t addr, line_t line, cache_id_t cache_id, bool rpt);
    void put_rsp_in(addr_t addr, line_t line, cache_id_t req_id, bool rpt);
};


#endif /* __LLC_TB_HPP__ */


