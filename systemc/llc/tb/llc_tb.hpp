// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

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

    // Input ports
    put_initiator<llc_req_in_t<CACHE_ID_WIDTH> >  llc_req_in_tb;
    put_initiator<llc_req_in_t<LLC_COH_DEV_ID_WIDTH> >  llc_dma_req_in_tb;
    put_initiator<llc_rsp_in_t>  llc_rsp_in_tb;
    put_initiator<llc_mem_rsp_t> llc_mem_rsp_tb; 
    put_initiator<bool>          llc_rst_tb_tb; 

    // Output ports
    get_initiator<llc_rsp_out_t<CACHE_ID_WIDTH> > llc_rsp_out_tb;
    get_initiator<llc_rsp_out_t<LLC_COH_DEV_ID_WIDTH> > llc_dma_rsp_out_tb;
    get_initiator<llc_fwd_out_t> llc_fwd_out_tb;
    get_initiator<llc_mem_req_t> llc_mem_req_tb;
    get_initiator<bool>          llc_rst_tb_done_tb;

#ifdef STATS_ENABLE
    get_initiator<bool> llc_stats_tb;
#endif

    // Constructor
    SC_CTOR(llc_tb)
	: clk("clk")
	, rst("rst")
	, llc_req_in_tb("llc_req_in_tb")
	, llc_dma_req_in_tb("llc_dma_req_in_tb")
	, llc_rsp_in_tb("llc_rsp_in_tb")
	, llc_mem_rsp_tb("llc_mem_rsp_tb")
	, llc_rst_tb_tb("llc_rst_tb_tb")
	, llc_rsp_out_tb("llc_rsp_out_tb")
	, llc_dma_rsp_out_tb("llc_dma_rsp_out_tb")
	, llc_fwd_out_tb("llc_fwd_out_tb")
	, llc_mem_req_tb("llc_mem_req_tb")
	, llc_rst_tb_done_tb("llc_rst_tb_done_tb")
#ifdef STATS_ENABLE
	, llc_stats_tb("llc_stats_tb")
#endif
    {
	// Process performing the test
	SC_CTHREAD(llc_test, clk.pos());
	reset_signal_is(rst, false);
	// set_stack_size(0x400000);
#ifdef STATS_ENABLE
	SC_CTHREAD(get_stats, clk.pos());
	reset_signal_is(rst, false);
	// set_stack_size(0x400000);
#endif
	// Assign clock and reset to put_get ports
	llc_req_in_tb.clk_rst (clk, rst);
	llc_dma_req_in_tb.clk_rst (clk, rst);
	llc_rsp_in_tb.clk_rst (clk, rst);
	llc_mem_rsp_tb.clk_rst(clk, rst);
	llc_rst_tb_tb.clk_rst(clk, rst);
	llc_dma_rsp_out_tb.clk_rst(clk, rst);
	llc_rsp_out_tb.clk_rst(clk, rst);
	llc_fwd_out_tb.clk_rst(clk, rst);
	llc_mem_req_tb.clk_rst(clk, rst);
	llc_rst_tb_done_tb.clk_rst(clk, rst);
#ifdef STATS_ENABLE
	llc_stats_tb.clk_rst(clk, rst);
#endif
    }

    // Processes
    void llc_test();
#ifdef STATS_ENABLE
    void get_stats();
#endif

    // Functions
    void reset_dut(bool is_flush);
    inline void reset_llc_test();
    void evict_prep(addr_breakdown_llc_t addr_base, addr_breakdown_llc_t &addr1, 
		    addr_breakdown_llc_t &addr2, int tag_incr1, int tag_incr2, 
		    llc_way_t &evict_way, bool update_way);
    void regular_evict_prep(addr_breakdown_llc_t addr_base, addr_breakdown_llc_t &addr1,
			    addr_breakdown_llc_t &addr2, llc_way_t &evict_way);
    void op(mix_msg_t coh_msg, llc_state_t state, bool evict, addr_breakdown_llc_t req_addr, 
	    addr_breakdown_llc_t evict_addr, line_t req_line, line_t rsp_line, line_t evict_line,
	    invack_cnt_t invack_cnt, cache_id_t req_id, cache_id_t dest_id, hprot_t hprot);
    void op_rsp(coh_msg_t rsp_msg, addr_breakdown_llc_t req_addr, line_t req_line, cache_id_t req_id);
    void op_dma(mix_msg_t coh_msg, llc_state_t state, bool evict, bool dirty, 
		addr_breakdown_llc_t req_addr, addr_breakdown_llc_t evict_addr, 
		line_t req_line, line_t rsp_line, line_t evict_line,
		sharers_t sharers, owner_t owner, bool stall);
    void get_rsp_out(coh_msg_t coh_msg, addr_t addr, line_t line, invack_cnt_t invack_cnt,
		     cache_id_t req_id, cache_id_t dest_id, word_offset_t woff);
    void get_dma_rsp_out(coh_msg_t coh_msg, addr_t addr, line_t line, invack_cnt_t invack_cnt,
                         llc_coh_dev_id_t req_id, cache_id_t dest_id, word_offset_t woff);
    void get_fwd_out(mix_msg_t coh_msg, addr_t addr, cache_id_t req_id, cache_id_t dest_id);
    void get_mem_req(bool hwrite, addr_t addr, line_t line);
    void put_mem_rsp(line_t line);
    void put_req_in(mix_msg_t coh_msg, addr_t addr, line_t line, cache_id_t cache_id, hprot_t hprot,
		    word_offset_t woff, word_offset_t wvalid);
    void put_dma_req_in(mix_msg_t coh_msg, addr_t addr, line_t line, llc_coh_dev_id_t cache_id, hprot_t hprot,
                        word_offset_t woff, word_offset_t wvalid);
    void put_rsp_in(coh_msg_t rsp_msg, addr_t addr, line_t line, cache_id_t req_id);
};


#endif /* __LLC_TB_HPP__ */


