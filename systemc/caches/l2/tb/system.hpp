/* Copyright 2017 Columbia University, SLD Group */

#ifndef __SYSTEM_HPP__
#define __SYSTEM_HPP__


#include "l2.hpp"
#include "l2_wrap.h"
#include "l2_tb.hpp"


class system_t : public sc_module
{

public:

    // Clock signal
    sc_in<bool> clk;

    // Reset signal
    sc_in<bool> rst;

    // Signals
    sc_signal<bool> flush_done;
    sc_signal< sc_bv<ASSERT_WIDTH> > asserts;
    sc_signal< sc_bv<BOOKMARK_WIDTH> > bookmark;
    sc_signal<uint32_t> custom_dbg;

#ifdef L2_DEBUG
    sc_signal<sc_uint<REQS_BITS_P1> > reqs_cnt_out;   
    sc_signal<bool>		set_conflict_out;
    sc_signal<l2_cpu_req_t>	cpu_req_conflict_out;
    sc_signal<bool>		evict_stall_out;
    sc_signal<bool>		fwd_stall_out;
    sc_signal<bool>		fwd_stall_ended_out;
    sc_signal<l2_fwd_in_t>         fwd_in_stalled_out;
    sc_signal<sc_uint<REQS_BITS> > reqs_fwd_stall_i_out;
    sc_signal<bool>		ongoing_atomic_out;
    sc_signal<addr_t>		atomic_line_addr_out;
    sc_signal<sc_uint<REQS_BITS> > reqs_atomic_i_out;

    sc_signal<bool>	tag_hit_out;
    sc_signal<l2_way_t>	way_hit_out;
    sc_signal<bool>	empty_way_found_out;
    sc_signal<l2_way_t>	empty_way_out;
    sc_signal<bool>	reqs_hit_out;
    sc_signal<sc_uint<REQS_BITS> >	reqs_hit_i_out;
    sc_signal<sc_uint<REQS_BITS> >	reqs_i_out;
    sc_signal<bool>	is_flush_to_get_out;
    sc_signal<bool>	is_rsp_to_get_out;
    sc_signal<bool>	is_fwd_to_get_out;
    sc_signal<bool>	is_req_to_get_out;
    sc_signal<uint32_t>	put_cnt_out;

    sc_signal<reqs_buf_t>	reqs_out[N_REQS];
    sc_signal<tag_t>	tag_buf_out[L2_WAYS];
    sc_signal<state_t>	state_buf_out[L2_WAYS];
    sc_signal<l2_way_t>	evict_way_out;
#endif

    // Channels
    // To L2 cache
    put_get_channel<l2_cpu_req_t>	l2_cpu_req_chnl;
    put_get_channel<l2_fwd_in_t>	l2_fwd_in_chnl;
    put_get_channel<l2_rsp_in_t>	l2_rsp_in_chnl;
    put_get_channel<bool>		l2_flush_chnl;
    // From L2 cache
    put_get_channel<l2_rd_rsp_t>	l2_rd_rsp_chnl;
    put_get_channel<l2_inval_t>	        l2_inval_chnl;
    put_get_channel<l2_req_out_t>	l2_req_out_chnl;
    put_get_channel<l2_rsp_out_t>	l2_rsp_out_chnl;

    // Modules
    // L2 cache instance
    l2_wrapper	*dut;
    // L2 testbench module
    l2_tb        	*tb;

    // Constructor
    SC_CTOR(system_t)
    {
	// Modules
	dut = new l2_wrapper("l2_wrapper");
	tb  = new l2_tb("l2_tb");

	// Binding L2 cache
	dut->clk(clk);
	dut->rst(rst);
	dut->flush_done(flush_done);
        dut->asserts(asserts);
        dut->bookmark(bookmark);
        dut->custom_dbg(custom_dbg);
	dut->l2_cpu_req(l2_cpu_req_chnl);
	dut->l2_fwd_in(l2_fwd_in_chnl);
	dut->l2_rsp_in(l2_rsp_in_chnl);
	dut->l2_flush(l2_flush_chnl);
	dut->l2_rd_rsp(l2_rd_rsp_chnl);
	dut->l2_inval(l2_inval_chnl);
	dut->l2_req_out(l2_req_out_chnl);
	dut->l2_rsp_out(l2_rsp_out_chnl);
#ifdef L2_DEBUG
	dut->reqs_cnt_out(reqs_cnt_out);
	dut->set_conflict_out(set_conflict_out);
	dut->cpu_req_conflict_out(cpu_req_conflict_out);
	dut->evict_stall_out(evict_stall_out);
	dut->fwd_stall_out(fwd_stall_out);
	dut->fwd_stall_ended_out(fwd_stall_ended_out);
	dut->fwd_in_stalled_out(fwd_in_stalled_out);
	dut->reqs_fwd_stall_i_out(reqs_fwd_stall_i_out);
	dut->ongoing_atomic_out(ongoing_atomic_out);
	dut->atomic_line_addr_out(atomic_line_addr_out);
	dut->reqs_atomic_i_out(reqs_atomic_i_out);
	dut->tag_hit_out(tag_hit_out);
	dut->way_hit_out(way_hit_out);
	dut->empty_way_found_out(empty_way_found_out);
	dut->empty_way_out(empty_way_out);
	dut->reqs_hit_out(reqs_hit_out);
	dut->reqs_hit_i_out(reqs_hit_i_out);
	dut->reqs_i_out(reqs_i_out);
	dut->is_flush_to_get_out(is_flush_to_get_out);
	dut->is_rsp_to_get_out(is_rsp_to_get_out);
	dut->is_fwd_to_get_out(is_fwd_to_get_out);
	dut->is_req_to_get_out(is_req_to_get_out);
	dut->put_cnt_out(put_cnt_out);
	for (int i = 0; i < N_REQS; ++i)
	    dut->reqs_out[i](reqs_out[i]);
	for (int i = 0; i < L2_WAYS; i++) {
	    dut->tag_buf_out[i](tag_buf_out[i]);
	    dut->state_buf_out[i](state_buf_out[i]);
	}
	dut->evict_way_out(evict_way_out);
#endif

	// Binding testbench
	tb->clk(clk);
	tb->rst(rst);
        tb->flush_done(flush_done);
        tb->asserts(asserts);
        tb->bookmark(bookmark);
        tb->custom_dbg(custom_dbg);
	tb->l2_cpu_req_tb(l2_cpu_req_chnl);
	tb->l2_fwd_in_tb(l2_fwd_in_chnl);
	tb->l2_rsp_in_tb(l2_rsp_in_chnl); 
	tb->l2_flush_tb(l2_flush_chnl); 
	tb->l2_rd_rsp_tb(l2_rd_rsp_chnl);
	tb->l2_inval_tb(l2_inval_chnl);
	tb->l2_req_out_tb(l2_req_out_chnl);
	tb->l2_rsp_out_tb(l2_rsp_out_chnl);
#ifdef L2_DEBUG
	tb->reqs_cnt_out(reqs_cnt_out);
	tb->set_conflict_out(set_conflict_out);
	tb->cpu_req_conflict_out(cpu_req_conflict_out);
	tb->evict_stall_out(evict_stall_out);
	tb->fwd_stall_out(fwd_stall_out);
	tb->fwd_stall_ended_out(fwd_stall_ended_out);
	tb->fwd_in_stalled_out(fwd_in_stalled_out);
	tb->reqs_fwd_stall_i_out(reqs_fwd_stall_i_out);
	tb->ongoing_atomic_out(ongoing_atomic_out);
	tb->atomic_line_addr_out(atomic_line_addr_out);
	tb->reqs_atomic_i_out(reqs_atomic_i_out);
	tb->tag_hit_out(tag_hit_out);
	tb->way_hit_out(way_hit_out);
	tb->empty_way_found_out(empty_way_found_out);
	tb->empty_way_out(empty_way_out);
	tb->reqs_hit_out(reqs_hit_out);
	tb->reqs_hit_i_out(reqs_hit_i_out);
	tb->reqs_i_out(reqs_i_out);
	tb->is_flush_to_get_out(is_flush_to_get_out);
	tb->is_rsp_to_get_out(is_rsp_to_get_out);
	tb->is_fwd_to_get_out(is_fwd_to_get_out);
	tb->is_req_to_get_out(is_req_to_get_out);
	tb->put_cnt_out(put_cnt_out);
	for (int i = 0; i < N_REQS; ++i)
	    tb->reqs_out[i](reqs_out[i]);
	for (int i = 0; i < L2_WAYS; i++) {
	    tb->tag_buf_out[i](tag_buf_out[i]);
	    tb->state_buf_out[i](state_buf_out[i]);
	}
	tb->evict_way_out(evict_way_out);
#endif

    }
};

#endif // __SYSTEM_HPP__
