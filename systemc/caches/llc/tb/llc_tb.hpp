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

#ifdef LLC_DEBUG

    // Debug signals
    sc_in< sc_bv<LLC_ASSERT_WIDTH> >   asserts;
    sc_in< sc_bv<LLC_BOOKMARK_WIDTH> > bookmark;
    sc_in<uint32_t>                    custom_dbg;

    sc_in<bool>		tag_hit_out;
    sc_in<llc_way_t>	hit_way_out;
    sc_in<bool>		empty_way_found_out;
    sc_in<llc_way_t>	empty_way_out;
    sc_in<llc_way_t>	way_out;
    sc_in<llc_addr_t>	llc_addr_out;
    sc_in<bool>		evict_out;
    sc_in<bool>		evict_valid_out;
    sc_in<bool>		evict_way_not_sd_out;
    sc_in<line_addr_t>	evict_addr_out;
    sc_in<llc_set_t>	flush_set_out;
    sc_in<llc_way_t>	flush_way_out;

    sc_in<bool>		req_stall_out;
    sc_in<bool>		req_in_stalled_valid_out;
    sc_in<llc_req_in_t> req_in_stalled_out;

    sc_in<llc_tag_t>	tag_buf_out[LLC_WAYS];
    sc_in<llc_state_t>	state_buf_out[LLC_WAYS];
    sc_in<hprot_t>	hprot_buf_out[LLC_WAYS];
    sc_in<line_t>	line_buf_out[LLC_WAYS];
    sc_in<sharers_t>	sharers_buf_out[LLC_WAYS];
    sc_in<owner_t>	owner_buf_out[LLC_WAYS];
    sc_in<sc_uint<2> >	dirty_bit_buf_out[LLC_WAYS];
    sc_in<llc_way_t>	evict_way_buf_out;
#endif

    // Input ports
    put_initiator<llc_req_in_t>  llc_req_in_tb;
    put_initiator<llc_rsp_in_t>  llc_rsp_in_tb;
    put_initiator<llc_mem_rsp_t> llc_mem_rsp_tb; 
    put_initiator<bool>          llc_rst_tb_tb; 

    // Output ports
    get_initiator<llc_rsp_out_t> llc_rsp_out_tb;
    get_initiator<llc_fwd_out_t> llc_fwd_out_tb;
    get_initiator<llc_mem_req_t> llc_mem_req_tb;
    get_initiator<bool>          llc_rst_tb_done_tb;

    // Constructor
    SC_CTOR(llc_tb)
	: clk("clk")
	, rst("rst")
#ifdef LLC_DEBUG
	, asserts("asserts")
	, bookmark("bookmark")
	, custom_dbg("custom_dbg")
	, tag_hit_out("tag_hit_out")
	, hit_way_out("hit_way_out")
	, empty_way_found_out("empty_way_found_out")
	, empty_way_out("empty_way_out")
	, way_out("way_out")
	, llc_addr_out("llc_addr_out")
	, evict_out("evict_out")
	, evict_valid_out("evict_valid_out")
	, evict_way_not_sd_out("evict_way_not_sd_out")
	, evict_addr_out("evict_addr_out")
	, flush_set_out("flush_set_out")
	, flush_way_out("flush_way_out")
	, evict_way_buf_out("evict_way_buf_out")
	, req_stall_out("req_stall_out")
	, req_in_stalled_valid_out("req_in_stalled_valid_out")
	, req_in_stalled_out("req_in_stalled_out")
#endif
	, llc_req_in_tb("llc_req_in_tb")
	, llc_rsp_in_tb("llc_rsp_in_tb")
	, llc_mem_rsp_tb("llc_mem_rsp_tb")
	, llc_rst_tb_tb("llc_rst_tb_tb")
	, llc_rsp_out_tb("llc_rsp_out_tb")
	, llc_fwd_out_tb("llc_fwd_out_tb")
	, llc_mem_req_tb("llc_mem_req_tb")
	, llc_rst_tb_done_tb("llc_rst_tb_done_tb")
    {
	// Process performing the test
	SC_CTHREAD(llc_test, clk.pos());
	reset_signal_is(rst, false);
	// set_stack_size(0x400000);

#ifdef LLC_DEBUG
	// Debug process
	SC_CTHREAD(llc_debug, clk.pos());
	reset_signal_is(rst, false);
	// set_stack_size(0x400000);
#endif

	// Assign clock and reset to put_get ports
	llc_req_in_tb.clk_rst (clk, rst);
	llc_rsp_in_tb.clk_rst (clk, rst);
	llc_mem_rsp_tb.clk_rst(clk, rst);
	llc_rst_tb_tb.clk_rst(clk, rst);
	llc_rsp_out_tb.clk_rst(clk, rst);
	llc_fwd_out_tb.clk_rst(clk, rst);
	llc_mem_req_tb.clk_rst(clk, rst);
	llc_rst_tb_done_tb.clk_rst(clk, rst);
    }

    // Processes
    void llc_test();
#ifdef LLC_DEBUG
    void llc_debug();
#endif

    // Functions
    void reset_dut(bool is_flush);
    inline void reset_llc_test();
    void evict_prep(addr_breakdown_t addr_base, addr_breakdown_t &addr1, addr_breakdown_t &addr2,
		    int tag_incr1, int tag_incr2, llc_way_t &evict_way, bool update_way);
    void regular_evict_prep(addr_breakdown_t addr_base, addr_breakdown_t &addr1,
			    addr_breakdown_t &addr2, llc_way_t &evict_way);
    void op(mix_msg_t coh_msg, llc_state_t state, bool evict, addr_breakdown_t req_addr, 
	    addr_breakdown_t evict_addr, line_t req_line, line_t rsp_line, line_t evict_line,
	    invack_cnt_t invack_cnt, cache_id_t req_id, cache_id_t dest_id, hprot_t hprot);
    void op_rsp(coh_msg_t rsp_msg, addr_breakdown_t req_addr, line_t req_line, cache_id_t req_id);
    void op_dma(mix_msg_t coh_msg, llc_state_t state, bool evict, bool dirty, 
		addr_breakdown_t req_addr, addr_breakdown_t evict_addr, 
		line_t req_line, line_t rsp_line, line_t evict_line,
		sharers_t sharers, owner_t owner, bool stall, bool done);
    void get_rsp_out(coh_msg_t coh_msg, addr_t addr, line_t line, invack_cnt_t invack_cnt,
		     cache_id_t req_id, cache_id_t dest_id);
    void get_fwd_out(coh_msg_t coh_msg, addr_t addr, cache_id_t req_id, cache_id_t dest_id);
    void get_mem_req(bool hwrite, addr_t addr, line_t line);
    void put_mem_rsp(line_t line);
    void put_req_in(mix_msg_t coh_msg, addr_t addr, line_t line, cache_id_t cache_id, hprot_t hprot);
    void put_rsp_in(coh_msg_t rsp_msg, addr_t addr, line_t line, cache_id_t req_id);
};


#endif /* __LLC_TB_HPP__ */


