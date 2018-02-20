/* Copyright 2017 Columbia University, SLD Group */

#ifndef __L2_HPP__
#define __L2_HPP__

#include "cache_utils.hpp"
#include "l2_directives.hpp"
#include "l2_tags.hpp"
#include "l2_states.hpp"
#include "l2_hprots.hpp"
#include "l2_lines.hpp"
#include "l2_evict_ways.hpp"

class l2 : public sc_module
{

public:

    // Clock signal
    sc_in<bool> clk;

    // Reset signal
    sc_in<bool> rst;

    // Debug signals
    sc_out< sc_bv<ASSERT_WIDTH> >   asserts;
    sc_out< sc_bv<BOOKMARK_WIDTH> > bookmark;
    sc_out<uint32_t>                custom_dbg;

#ifdef L2_DEBUG
    sc_out<sc_uint<REQS_BITS_P1> > reqs_cnt_out;   
    sc_out<bool>		set_conflict_out;
    sc_out<l2_cpu_req_t>	cpu_req_conflict_out;
    sc_out<bool>		evict_stall_out;
    sc_out<bool>		fwd_stall_out;
    sc_out<bool>		fwd_stall_ended_out;
    sc_out<l2_fwd_in_t>         fwd_in_stalled_out;
    sc_out<sc_uint<REQS_BITS> > reqs_fwd_stall_i_out;
    sc_out<bool>		ongoing_atomic_out;
    sc_out<addr_t>		atomic_line_addr_out;
    sc_out<sc_uint<REQS_BITS> > reqs_atomic_i_out;

    sc_out<bool>	tag_hit_out;
    sc_out<l2_way_t>	way_hit_out;
    sc_out<bool>	empty_way_found_out;
    sc_out<l2_way_t>	empty_way_out;
    sc_out<bool>	reqs_hit_out;
    sc_out<sc_uint<REQS_BITS> >	reqs_hit_i_out;
    sc_out<sc_uint<REQS_BITS> >	reqs_i_out;
    sc_out<bool>	is_flush_to_get_out;
    sc_out<bool>	is_rsp_to_get_out;
    sc_out<bool>	is_fwd_to_get_out;
    sc_out<bool>	is_req_to_get_out;
    sc_out<uint32_t>	flush_way_out;
    sc_out<uint32_t>	flush_set_out;

    sc_out<reqs_buf_t>	reqs_out[N_REQS];
    sc_out<tag_t>	tag_buf_out[L2_WAYS];
    sc_out<state_t>	state_buf_out[L2_WAYS];
    sc_out<l2_way_t>	evict_way_out;
#endif

    // Other signals
    sc_out<bool> flush_done;

    // Input ports
    nb_get_initiator<l2_cpu_req_t>	l2_cpu_req;
    nb_get_initiator<l2_fwd_in_t>	l2_fwd_in;
    nb_get_initiator<l2_rsp_in_t>	l2_rsp_in;
    nb_get_initiator<bool>		l2_flush;

    // Output ports
    put_initiator<l2_rd_rsp_t>	l2_rd_rsp;
    put_initiator<l2_inval_t>	l2_inval;
    nb_put_initiator<l2_req_out_t> l2_req_out;
    nb_put_initiator<l2_rsp_out_t> l2_rsp_out;

    // Local memory
    l2_tags_t<tag_t, L2_LINES>		tags;
    l2_states_t<state_t, L2_LINES>	states;
    l2_hprots_t<hprot_t, L2_LINES>	hprots;
    l2_lines_t<line_t, L2_LINES>	lines;
    l2_evict_ways_t<l2_way_t, SETS>	evict_ways;

    // Local registers
    reqs_buf_t	 reqs[N_REQS];

    tag_t	 tag_buf[L2_WAYS];
    state_t	 state_buf[L2_WAYS];
    hprot_t	 hprot_buf[L2_WAYS];
    line_t	 lines_buf[L2_WAYS];
    l2_way_t	 evict_way;

    // Constructor
    SC_CTOR(l2)
	: clk("clk")
	, rst("rst")
	, asserts("asserts")
	, bookmark("bookmark")
	, custom_dbg("custom_dbg")
	, flush_done("flush_done")
	, l2_cpu_req("l2_cpu_req")
	, l2_fwd_in("l2_fwd_in")
	, l2_rsp_in("l2_rsp_in")
	, l2_flush("l2_flush")
	, l2_rd_rsp("l2_rd_rsp")
	, l2_inval("l2_inval")
	, l2_req_out("l2_req_out")
	, l2_rsp_out("l2_rsp_out")
	{
	    // Cache controller process
	    SC_CTHREAD(ctrl, clk.pos());
	    reset_signal_is(rst, false);
	    // set_stack_size(0x400000);

	    // Assign clock and reset to put_get ports
	    l2_cpu_req.clk_rst (clk, rst);
	    l2_fwd_in.clk_rst (clk, rst);
	    l2_rsp_in.clk_rst (clk, rst);
	    l2_flush.clk_rst (clk, rst);
	    l2_rd_rsp.clk_rst(clk, rst);
	    l2_inval.clk_rst(clk, rst);
	    l2_req_out.clk_rst(clk, rst);
	    l2_rsp_out.clk_rst(clk, rst);

	    // Flatten arrays
	    L2_FLATTEN_REGS;

	    // Clock binding for memories
	    tags.clk(this->clk);
	    states.clk(this->clk);
	    hprots.clk(this->clk);
	    lines.clk(this->clk);
	    evict_ways.clk(this->clk);
	}

    // Processes
    void ctrl(); // cache controller

    /* Functions for the reset phase */
    inline void reset_io();
    inline void reset_states();

    /* Functions to receive input messages */
    void get_cpu_req(l2_cpu_req_t &cpu_req);
    void get_fwd_in(l2_fwd_in_t &fwd_in);
    void get_rsp_in(l2_rsp_in_t &rsp_in);
    void get_flush();

    /* Functions to send output messages */
    void send_rd_rsp(line_t lines);
    void send_inval(addr_t addr_inval);
    void send_req_out(coh_msg_t coh_msg, hprot_t hprot, addr_t line_addr, line_t lines);
    void send_rsp_out(coh_msg_t coh_msg, cache_id_t req_id, bool to_req, addr_t line_addr, line_t line);

    /* Functions to move around buffered lines */
    void fill_reqs(cpu_msg_t cpu_msg, addr_breakdown_t addr_br, tag_t tag_estall, l2_way_t way_hit, 
		   hsize_t hsize, unstable_state_t state, hprot_t hprot, word_t word, line_t line,
		   sc_uint<REQS_BITS> reqs_i);
    void put_reqs(set_t set, l2_way_t way, tag_t tag, line_t lines, hprot_t hprot, state_t state,
		  sc_uint<REQS_BITS> reqs_i);

    /* Functions to search for cache lines either in memory or buffered */
    void read_set(set_t set);
    void tag_lookup(addr_breakdown_t addr_br, bool &tag_hit, l2_way_t &way_hit, bool &empty_way_found,
		    l2_way_t &empty_way);
    void reqs_lookup(addr_breakdown_t addr_br, sc_uint<REQS_BITS> &reqs_hit_i);
    bool reqs_peek_req(set_t set, sc_uint<REQS_BITS> &reqs_i);
    void reqs_peek_flush(set_t set, sc_uint<REQS_BITS> &reqs_i);
    bool reqs_peek_fwd(addr_breakdown_t addr_br, sc_uint<REQS_BITS> &reqs_i, bool &reqs_hit, coh_msg_t coh_msg);

    // line_t make_line_of_addr(addr_t addr); // is this needed here? not called by l2.cpp

private:
    /* Variables for debug*/ 
    sc_bv<ASSERT_WIDTH>   asserts_tmp;
    sc_bv<BOOKMARK_WIDTH> bookmark_tmp;
    uint64_t custom_dbg_tmp;

    /* Variables for stalls, conflicts and atomic operations */
    sc_uint<REQS_BITS_P1> reqs_cnt;
    bool set_conflict;
    l2_cpu_req_t cpu_req_conflict;
    bool evict_stall;
    bool fwd_stall;
    bool fwd_stall_ended;
    l2_fwd_in_t fwd_in_stalled;
    sc_uint<REQS_BITS> reqs_fwd_stall_i;
    bool ongoing_atomic;
    addr_t atomic_line_addr;
    sc_uint<REQS_BITS> reqs_atomic_i;
    bool ongoing_flush;
    uint32_t flush_way, flush_set;
};


#endif /* __L2_HPP__ */
