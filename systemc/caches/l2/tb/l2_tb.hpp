/* Copyright 2017 Columbia University, SLD Group */

#ifndef __L2_TB_HPP__
#define __L2_TB_HPP__

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <algorithm>
#include "cache_utils.hpp"

class l2_tb : public sc_module
{

public:

    // Clock signal
    sc_in<bool> clk;

    // Reset signal
    sc_in<bool> rst;

    // Debug signals
    sc_in< sc_bv<ASSERT_WIDTH> >   asserts;
    sc_in< sc_bv<BOOKMARK_WIDTH> > bookmark;
    sc_in<uint32_t>     custom_dbg;

#ifdef L2_DEBUG
    sc_in<sc_uint<REQS_BITS_P1> > reqs_cnt_out;   
    sc_in<bool>		set_conflict_out;
    sc_in<l2_cpu_req_t>	cpu_req_conflict_out;
    sc_in<bool>		evict_stall_out;
    sc_in<bool>		fwd_stall_out;
    sc_in<bool>		fwd_stall_ended_out;
    sc_in<l2_fwd_in_t>         fwd_in_stalled_out;
    sc_in<sc_uint<REQS_BITS> > reqs_fwd_stall_i_out;
    sc_in<bool>		ongoing_atomic_out;
    sc_in<addr_t>		atomic_line_addr_out;
    sc_in<sc_uint<REQS_BITS> > reqs_atomic_i_out;

    sc_in<bool>	tag_hit_out;
    sc_in<l2_way_t>	way_hit_out;
    sc_in<bool>	empty_way_found_out;
    sc_in<l2_way_t>	empty_way_out;
    sc_in<bool>	reqs_hit_out;
    sc_in<sc_uint<REQS_BITS> >	reqs_hit_i_out;
    sc_in<sc_uint<REQS_BITS> >	reqs_i_out;
    sc_in<bool>	is_flush_to_get_out;
    sc_in<bool>	is_rsp_to_get_out;
    sc_in<bool>	is_fwd_to_get_out;
    sc_in<bool>	is_req_to_get_out;
    sc_in<uint32_t>	put_cnt_out;

    sc_in<reqs_buf_t>	reqs_out[N_REQS];
    sc_in<tag_t>	tag_buf_out[L2_WAYS];
    sc_in<state_t>	state_buf_out[L2_WAYS];
    sc_in<l2_way_t>	evict_way_out;
#endif

    // Other signals
    sc_in<bool> flush_done;

    // Input ports
    put_initiator<l2_cpu_req_t> l2_cpu_req_tb;
    put_initiator<l2_fwd_in_t>	l2_fwd_in_tb;
    put_initiator<l2_rsp_in_t>	l2_rsp_in_tb;
    put_initiator<bool>		l2_flush_tb;

    // Output ports
    get_initiator<l2_rd_rsp_t>	l2_rd_rsp_tb;
    get_initiator<l2_inval_t>   l2_inval_tb;
    get_initiator<l2_req_out_t> l2_req_out_tb;
    get_initiator<l2_rsp_out_t> l2_rsp_out_tb;

    // Constructor
    SC_CTOR(l2_tb)
    {
	// Process performing the test
	SC_CTHREAD(l2_test, clk.pos());
	reset_signal_is(rst, false);
	// set_stack_size(0x400000);

	// Debug process
	SC_CTHREAD(l2_debug, clk.pos());
	reset_signal_is(rst, false);
	// set_stack_size(0x400000);

	// Assign clock and reset to put_get ports
	l2_cpu_req_tb.clk_rst (clk, rst);
	l2_fwd_in_tb.clk_rst (clk, rst);
	l2_rsp_in_tb.clk_rst (clk, rst);
	l2_flush_tb.clk_rst (clk, rst);
	l2_rd_rsp_tb.clk_rst(clk, rst);
	l2_inval_tb.clk_rst(clk, rst);
	l2_req_out_tb.clk_rst(clk, rst);
	l2_rsp_out_tb.clk_rst(clk, rst);
    }

    // Processes
    void l2_test();
    void l2_debug();

    // Functions
    inline void reset_l2_test();

    // inline void write_word(line_t &line, word_t word, word_offset_t w_off);
    // inline word_t read_word(line_t line, word_offset_t w_off);
    // inline void rand_wait();
    // addr_breakdown_t rand_addr();
    // word_t rand_word();
    void put_cpu_req(l2_cpu_req_t &cpu_req, cpu_msg_t cpu_msg, hsize_t hsize, 
		     addr_t addr, word_t word);
    void get_req_out(coh_msg_t coh_msg, addr_t addr, hprot_t hprot);
    void get_rsp_out(coh_msg_t coh_msg, cache_id_t req_id, bool to_req, addr_t addr, 
		     line_t line);
    void put_fwd_in(coh_msg_t coh_msg, addr_t addr, cache_id_t req_id);
    void put_rsp_in(coh_msg_t coh_msg, addr_t addr, line_t line, invack_cnt_t invack_cnt);
    void get_rd_rsp(addr_breakdown_t addr, line_t line);
    void get_inval(addr_t addr);
    void op(cpu_msg_t cpu_msg, int beh, int rsp_beh, coh_msg_t rsp_msg, invack_cnt_t invack_cnt, 
	    coh_msg_t put_msg, hsize_t hsize, addr_breakdown_t req_addr, word_t req_word, 
	    line_t rsp_line, int fwd_beh, coh_msg_t fwd_msg, cache_id_t fwd_id, line_t fwd_line);
    void op_flush(coh_msg_t coh_msg, addr_t addr_line);
    void flush(int n_lines);

private:

    bool rpt;
};


#endif /* __L2_TB_HPP__ */


