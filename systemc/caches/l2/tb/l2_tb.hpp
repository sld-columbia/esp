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

#ifdef STATS_ENABLE
    get_initiator<bool> l2_stats_tb;
#endif


    // Constructor
    SC_CTOR(l2_tb)
    {
	// Process performing the test
	SC_CTHREAD(l2_test, clk.pos());
	reset_signal_is(rst, false);
	// set_stack_size(0x400000);

// #ifdef L2_DEBUG
// 	// Debug process
// 	SC_CTHREAD(l2_debug, clk.pos());
// 	reset_signal_is(rst, false);
// 	// set_stack_size(0x400000);
// #endif
#ifdef STATS_ENABLE
	SC_CTHREAD(get_stats, clk.pos());
	reset_signal_is(rst, false);
	// set_stack_size(0x400000);
#endif
	// Assign clock and reset to put_get ports
	l2_cpu_req_tb.clk_rst (clk, rst);
	l2_fwd_in_tb.clk_rst (clk, rst);
	l2_rsp_in_tb.clk_rst (clk, rst);
	l2_flush_tb.clk_rst (clk, rst);
	l2_rd_rsp_tb.clk_rst(clk, rst);
	l2_inval_tb.clk_rst(clk, rst);
	l2_req_out_tb.clk_rst(clk, rst);
	l2_rsp_out_tb.clk_rst(clk, rst);
#ifdef STATS_ENABLE
	l2_stats_tb.clk_rst(clk, rst);
#endif
    }

    // Processes
    void l2_test();
// #ifdef L2_DEBUG
//     void l2_debug();
// #endif
#ifdef STATS_ENABLE
    void get_stats();
#endif

    // Functions
    inline void reset_l2_test();

    // inline void write_word(line_t &line, word_t word, word_offset_t w_off);
    // inline word_t read_word(line_t line, word_offset_t w_off);
    // inline void rand_wait();
    // addr_breakdown_t rand_addr();
    // word_t rand_word();
    void put_cpu_req(l2_cpu_req_t &cpu_req, cpu_msg_t cpu_msg, hsize_t hsize, 
		     addr_t addr, word_t word, hprot_t hprot);
    void get_req_out(coh_msg_t coh_msg, addr_t addr, hprot_t hprot);
    void get_rsp_out(coh_msg_t coh_msg, cache_id_t req_id, bool to_req, addr_t addr, 
		     line_t line);
    void put_fwd_in(mix_msg_t coh_msg, addr_t addr, cache_id_t req_id);
    void put_rsp_in(coh_msg_t coh_msg, addr_t addr, line_t line, invack_cnt_t invack_cnt);
    void get_rd_rsp(line_t line);
    void get_inval(addr_t addr);
    void op(cpu_msg_t cpu_msg, int beh, int rsp_beh, coh_msg_t rsp_msg, invack_cnt_t invack_cnt, 
	    coh_msg_t put_msg, hsize_t hsize, addr_breakdown_t req_addr, word_t req_word, 
	    line_t rsp_line, int fwd_beh, mix_msg_t fwd_msg, state_t fwd_state, cache_id_t fwd_id, 
	    line_t fwd_line, hprot_t hprot);
    void op_flush(coh_msg_t coh_msg, addr_t addr);
    void flush(int n_lines, bool is_flush_all);

private:

    bool rpt;
};


#endif /* __L2_TB_HPP__ */


