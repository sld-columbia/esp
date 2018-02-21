/* Copyright 2017 Columbia University, SLD Group */

#ifndef __SYSTEM_HPP__
#define __SYSTEM_HPP__


#include "llc.hpp"
#include "llc_wrap.h"
#include "llc_tb.hpp"


class system_t : public sc_module
{

public:

    // Clock signal
    sc_in<bool> clk;

    // Reset signal
    sc_in<bool> rst;

    // Signals
    sc_signal< sc_bv<LLC_ASSERT_WIDTH> >   asserts;
    sc_signal< sc_bv<LLC_BOOKMARK_WIDTH> > bookmark;
    sc_signal<uint32_t>                    custom_dbg;

#if LLC_DEBUG

    sc_signal<bool> tag_hit_out;
    sc_signal<llc_way_t> hit_way_out;
    sc_signal<bool> empty_way_found_out;
    sc_signal<llc_way_t> empty_way_out;
    sc_signal<bool> evict_out;
    sc_signal<llc_way_t> way_out;
    sc_signal<llc_addr_t> llc_addr_out;

    sc_signal<bool> req_stall_out;
    sc_signal<bool> req_in_stalled_valid_out;
    sc_signal<llc_req_in_t> req_in_stalled_out;

    sc_signal<bool> is_rsp_to_get_out;
    sc_signal<bool> is_req_to_get_out;

    sc_signal<tag_t> tag_buf_out[LLC_WAYS];
    sc_signal<llc_state_t> state_buf_out[LLC_WAYS];
    sc_signal<sharers_t> sharers_buf_out[LLC_WAYS];
    sc_signal<owner_t> owner_buf_out[LLC_WAYS];

#endif

    // Channels
    // To LLC cache
    put_get_channel<llc_req_in_t>  llc_req_in_chnl;
    put_get_channel<llc_rsp_in_t>  llc_rsp_in_chnl;
    put_get_channel<llc_mem_rsp_t> llc_mem_rsp_chnl;
    put_get_channel<bool>          llc_rst_tb_chnl;

    // From LLC cache
    put_get_channel<llc_rsp_out_t> llc_rsp_out_chnl;
    put_get_channel<llc_fwd_out_t> llc_fwd_out_chnl;
    put_get_channel<llc_mem_req_t> llc_mem_req_chnl;
    put_get_channel<bool>          llc_rst_tb_done_chnl;

    // Modules
    // LLC cache instance
    llc_wrapper	*dut;
    // LLC testbench module
    llc_tb      *tb;

    // Constructor
    SC_CTOR(system_t)
    {
	// Modules
	dut = new llc_wrapper("llc_wrapper");
	tb  = new llc_tb("llc_tb");

	// Binding LLC cache
	dut->clk(clk);
	dut->rst(rst);
        dut->asserts(asserts);
        dut->bookmark(bookmark);
        dut->custom_dbg(custom_dbg);
#if LLC_DEBUG
	dut->tag_hit_out(tag_hit_out);
	dut->hit_way_out(hit_way_out);
	dut->empty_way_found_out(empty_way_found_out);
	dut->empty_way_out(empty_way_out);
	dut->evict_out(evict_out);
	dut->way_out(way_out);
	dut->req_stall_out(req_stall_out);
	dut->req_in_stalled_valid_out(req_in_stalled_valid_out);
	dut->req_in_stalled_out(req_in_stalled_out);
	dut->is_rsp_to_get_out(is_rsp_to_get_out);
	dut->is_req_to_get_out(is_req_to_get_out);
	dut->tag_buf_out(tag_buf_out);
	dut->state_buf_out(state_buf_out);
	dut->sharers_buf_out(sharers_buf_out);
	dut->owner_buf_out(owner_buf_out);
#endif
	dut->llc_addr_out(llc_addr_out);
	dut->llc_req_in(llc_req_in_chnl);
	dut->llc_rsp_in(llc_rsp_in_chnl);
	dut->llc_mem_rsp(llc_mem_rsp_chnl);
	dut->llc_rst_tb(llc_rst_tb_chnl);
	dut->llc_rsp_out(llc_rsp_out_chnl);
	dut->llc_fwd_out(llc_fwd_out_chnl);
	dut->llc_mem_req(llc_mem_req_chnl);
	dut->llc_rst_tb_done(llc_rst_tb_done_chnl);

	// Binding testbench
	tb->clk(clk);
	tb->rst(rst);
	tb->asserts(asserts);
        tb->bookmark(bookmark);
        tb->custom_dbg(custom_dbg);
#if LLC_DEBUG
	tb->tag_hit_out(tag_hit_out);
	tb->hit_way_out(hit_way_out);
	tb->empty_way_found_out(empty_way_found_out);
	tb->empty_way_out(empty_way_out);
	tb->evict_out(evict_out);
	tb->way_out(way_out);
	tb->req_stall_out(req_stall_out);
	tb->req_in_stalled_valid_out(req_in_stalled_valid_out);
	tb->req_in_stalled_out(req_in_stalled_out);
	tb->is_rsp_to_get_out(is_rsp_to_get_out);
	tb->is_req_to_get_out(is_req_to_get_out);
	tb->tag_buf_out(tag_buf_out);
	tb->state_buf_out(state_buf_out);
	tb->sharers_buf_out(sharers_buf_out);
	tb->owner_buf_out(owner_buf_out);
#endif
	tb->llc_addr_out(llc_addr_out);
	tb->llc_req_in_tb(llc_req_in_chnl);
	tb->llc_rsp_in_tb(llc_rsp_in_chnl);
	tb->llc_mem_rsp_tb(llc_mem_rsp_chnl); 
	tb->llc_rst_tb_tb(llc_rst_tb_chnl);
	tb->llc_rsp_out_tb(llc_rsp_out_chnl);
	tb->llc_fwd_out_tb(llc_fwd_out_chnl);
	tb->llc_mem_req_tb(llc_mem_req_chnl);
	tb->llc_rst_tb_done_tb(llc_rst_tb_done_chnl);
    }
};

#endif // __SYSTEM_HPP__
