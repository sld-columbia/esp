/* Copyright 2017 Columbia University, SLD Group */

#ifndef __L2_TB_HPP__
#define __L2_TB_HPP__


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
    // sc_in<reqs_buf_t>   reqs_out[N_REQS];
    // sc_in<bool>		evict_stall_out;
    // sc_in<bool>		set_conflict_out;
    // sc_in<l2_cpu_req_t>	cpu_req_conflict_out;
    // sc_in<bool>		tag_hit_out;
    // sc_in<l2_way_t>	way_hit_out;
    // sc_in<bool>		empty_way_found_out;
    // sc_in<l2_way_t>	empty_way_out;
    // sc_in<l2_way_t>	way_evict_out;
    // sc_in<bool>			reqs_hit_out;
    // sc_in< sc_uint<REQS_BITS> >	reqs_hit_i_out;
    // sc_in< sc_uint<REQS_BITS_P1> > reqs_cnt_out;    

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
		     bool cacheable, addr_t addr, word_t word, bool rpt);
    void get_req_out(coh_msg_t coh_msg, addr_t addr, hprot_t hprot, bool rpt);
    void put_rsp_in(coh_msg_t coh_msg, addr_t addr, line_t line, bool rpt);
    void get_rd_rsp(addr_breakdown_t addr, line_t line, bool rpt);
    void get_inval(addr_t addr, bool rpt);
    void op(cpu_msg_t cpu_msg, sc_uint<2> beh, coh_msg_t put_msg, hsize_t hsize, bool cacheable, 
	    addr_breakdown_t req_addr, word_t req_word, line_t rsp_line, bool rpt);
    void op_flush(coh_msg_t coh_msg, addr_t addr_line, bool rpt);
    line_t make_line_of_addr(addr_t addr);
};


#endif /* __L2_TB_HPP__ */


