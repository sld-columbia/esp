// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __LLC_HPP__
#define __LLC_HPP__

#include "cache_utils.hpp"
#include "llc_directives.hpp"

#include EXP_MEM_INCLUDE_STRING(llc, tags, LLC_SETS, LLC_WAYS)
#include EXP_MEM_INCLUDE_STRING(llc, states, LLC_SETS, LLC_WAYS)
#include EXP_MEM_INCLUDE_STRING(llc, lines, LLC_SETS, LLC_WAYS)
#include EXP_MEM_INCLUDE_STRING(llc, hprots, LLC_SETS, LLC_WAYS)
#include EXP_MEM_INCLUDE_STRING(llc, sharers, LLC_SETS, LLC_WAYS)
#include EXP_MEM_INCLUDE_STRING(llc, owners, LLC_SETS, LLC_WAYS)
#include EXP_MEM_INCLUDE_STRING(llc, dirty_bits, LLC_SETS, LLC_WAYS)
#include EXP_MEM_INCLUDE_STRING(llc, evict_ways, LLC_SETS, LLC_WAYS)

class llc : public sc_module
{

public:

    // Clock signal
    sc_in<bool> clk;

    // Reset signal
    sc_in<bool> rst;

#ifdef LLC_DEBUG
    // Debug signals
    sc_signal< sc_bv<LLC_ASSERT_WIDTH> > dbg_asserts;
    sc_signal< sc_bv<LLC_BOOKMARK_WIDTH> > dbg_bookmark;

    sc_signal<bool>	dbg_is_rst_to_get;
    sc_signal<bool>	dbg_is_rsp_to_get;
    sc_signal<bool>	dbg_is_req_to_get;
    sc_signal<bool>     dbg_is_dma_read_to_resume;
    sc_signal<bool>     dbg_is_dma_write_to_resume;
    sc_signal<bool>     dbg_is_dma_req_to_get;

    sc_signal<bool>		dbg_tag_hit;
    sc_signal<llc_way_t>	dbg_hit_way;
    sc_signal<bool>		dbg_empty_way_found;
    sc_signal<llc_way_t>	dbg_empty_way;
    sc_signal<llc_way_t>	dbg_way;
    sc_signal<llc_addr_t>	dbg_llc_addr;
    sc_signal<bool>		dbg_evict;
    sc_signal<bool>		dbg_evict_valid;
    sc_signal<bool>		dbg_evict_way_not_sd;
    sc_signal<line_addr_t>	dbg_evict_addr;
    sc_signal<llc_set_t>	dbg_flush_set;
    sc_signal<llc_way_t>	dbg_flush_way;

    sc_signal<bool>		dbg_req_stall;
    sc_signal<bool>		dbg_req_in_stalled_valid;
    sc_signal<llc_req_in_t>	dbg_req_in_stalled;
    sc_signal<llc_tag_t>	dbg_req_in_stalled_tag;
    sc_signal<llc_set_t>	dbg_req_in_stalled_set;

    sc_signal<dma_length_t>	dbg_length;
    sc_signal<dma_length_t>	dbg_dma_length;
    sc_signal<bool>		dbg_dma_done;
    sc_signal<addr_t>		dbg_dma_addr;

    sc_signal<llc_tag_t>	dbg_tag_buf[LLC_WAYS];
    sc_signal<llc_state_t>	dbg_state_buf[LLC_WAYS];
    sc_signal<hprot_t>		dbg_hprot_buf[LLC_WAYS];
    sc_signal<line_t>		dbg_line_buf[LLC_WAYS];
    sc_signal<sharers_t>	dbg_sharers_buf[LLC_WAYS];
    sc_signal<owner_t>		dbg_owner_buf[LLC_WAYS];
    sc_signal<sc_uint<2> >      dbg_dirty_bit_buf[LLC_WAYS];
    sc_signal<llc_way_t>	dbg_evict_way_buf;
#endif

    // Input ports
    nb_get_initiator<llc_req_in_t<CACHE_ID_WIDTH> >        llc_req_in;
    nb_get_initiator<llc_req_in_t<LLC_COH_DEV_ID_WIDTH> >  llc_dma_req_in;
    nb_get_initiator<llc_rsp_in_t>	llc_rsp_in;
    nb_get_initiator<llc_mem_rsp_t>	llc_mem_rsp;
    nb_get_initiator<bool>              llc_rst_tb;

    // Output ports
    nb_put_initiator<llc_rsp_out_t<CACHE_ID_WIDTH> >        llc_rsp_out;
    nb_put_initiator<llc_rsp_out_t<LLC_COH_DEV_ID_WIDTH> >  llc_dma_rsp_out;
    nb_put_initiator<llc_fwd_out_t>	llc_fwd_out;
    nb_put_initiator<llc_mem_req_t>     llc_mem_req;
    nb_put_initiator<bool>              llc_rst_tb_done;

#ifdef STATS_ENABLE
    nb_put_initiator<bool>              llc_stats;
#endif

    // Local memory
    EXP_MEM_TYPE_STRING(llc, tags, LLC_SETS, LLC_WAYS)<llc_tag_t, LLC_LINES> tags;
    EXP_MEM_TYPE_STRING(llc, states, LLC_SETS, LLC_WAYS)<llc_state_t, LLC_LINES> states;
    EXP_MEM_TYPE_STRING(llc, lines, LLC_SETS, LLC_WAYS)<line_t, LLC_LINES> lines;
    EXP_MEM_TYPE_STRING(llc, hprots, LLC_SETS, LLC_WAYS)<hprot_t, LLC_LINES> hprots;
    EXP_MEM_TYPE_STRING(llc, owners, LLC_SETS, LLC_WAYS)<owner_t, LLC_LINES> owners;
    EXP_MEM_TYPE_STRING(llc, sharers, LLC_SETS, LLC_WAYS)<sharers_t, LLC_LINES> sharers;
    EXP_MEM_TYPE_STRING(llc, dirty_bits, LLC_SETS, LLC_WAYS)<sc_uint<2>, LLC_LINES> dirty_bits;
    EXP_MEM_TYPE_STRING(llc, evict_ways, LLC_SETS, LLC_WAYS)<llc_way_t, LLC_SETS> evict_ways;
    // llc_tag_t tags[LLC_LINES];
    // llc_state_t states[LLC_LINES];
    // line_t lines[LLC_LINES];
    // hprot_t hprots[LLC_LINES];
    // owner_t owners[LLC_LINES];
    // sharers_t sharers[LLC_LINES];
    // sc_uint<2> dirty_bits[LLC_LINES];
    // llc_way_t evict_ways[LLC_SETS];

    // Local registers
    llc_tag_t	 tags_buf[LLC_WAYS];
    llc_state_t	 states_buf[LLC_WAYS];
    hprot_t	 hprots_buf[LLC_WAYS];
    line_t	 lines_buf[LLC_WAYS];
    sharers_t	 sharers_buf[LLC_WAYS];
    owner_t      owners_buf[LLC_WAYS];
    sc_uint<2>   dirty_bits_buf[LLC_WAYS];
    llc_way_t	 evict_ways_buf;

    // Constructor
    SC_CTOR(llc)
        : clk("clk")
        , rst("rst")
        , llc_req_in("llc_req_in")
        , llc_dma_req_in("llc_dma_req_in")
        , llc_rsp_in("llc_rsp_in")
        , llc_mem_rsp("llc_mem_rsp")
        , llc_rst_tb("llc_rst_tb")
        , llc_rsp_out("llc_rsp_out")
        , llc_dma_rsp_out("llc_dma_rsp_out")
        , llc_fwd_out("llc_fwd_out")
        , llc_mem_req("llc_mem_req")
        , llc_rst_tb_done("llc_rst_tb_done")
#ifdef STATS_ENABLE
        , llc_stats("llc_stats")
#endif
    {
        // Cache controller process
	SC_CTHREAD(ctrl, clk.pos());
	reset_signal_is(rst, false);
	// set_stack_size(0x400000);

	// Assign clock and reset to put_get ports
	llc_req_in.clk_rst (clk, rst);
	llc_dma_req_in.clk_rst (clk, rst);
	llc_rsp_in.clk_rst (clk, rst);
	llc_mem_rsp.clk_rst (clk, rst);
	llc_rst_tb.clk_rst(clk, rst);
	llc_rsp_out.clk_rst (clk, rst);
	llc_dma_rsp_out.clk_rst (clk, rst);
	llc_fwd_out.clk_rst(clk, rst);
	llc_mem_req.clk_rst(clk, rst);
	llc_rst_tb_done.clk_rst(clk, rst);
#ifdef STATS_ENABLE
	llc_stats.clk_rst(clk, rst);
#endif


	// Flatten arrays
	LLC_FLATTEN_REGS;

	// Debug signals
	PRESERVE_SIGNALS;

	// Clock binding for memories
	tags.clk(this->clk);
	states.clk(this->clk);
	hprots.clk(this->clk);
	lines.clk(this->clk);
	owners.clk(this->clk);
	sharers.clk(this->clk);
	dirty_bits.clk(this->clk);
	evict_ways.clk(this->clk);

	// // Mapping to memory resources
        // LLC_MAP_MEMORY;
    }

    // Processes
    void ctrl(); // cache controller

    // Functions
    inline void reset_io();
    inline void reset_state();
    inline void read_set(llc_addr_t base, llc_way_t offset);
    inline void lookup(llc_tag_t tag, llc_way_t &way, bool &evict);

    inline void send_mem_req(bool hwrite, line_addr_t line_addr, hprot_t hprot, line_t line);
#ifdef STATS_ENABLE
    inline void send_stats(bool stats);
#endif
    inline void get_mem_rsp(line_t &line);
    inline void send_rsp_out(coh_msg_t coh_msg, line_addr_t addr, line_t line, cache_id_t req_id,
                             cache_id_t dest_id, invack_cnt_t invack_cnt, word_offset_t word_offset);
    inline void send_fwd_out(mix_msg_t coh_msg, line_addr_t addr, cache_id_t req_id, cache_id_t dest_id);
    inline void send_dma_rsp_out(coh_msg_t coh_msg, line_addr_t addr, line_t line, llc_coh_dev_id_t req_id,
                                 cache_id_t dest_id, invack_cnt_t invack_cnt, word_offset_t word_offset);

private:

#ifdef LLC_DEBUG
    // debug
    sc_bv<LLC_ASSERT_WIDTH>   asserts_tmp;
    sc_bv<LLC_BOOKMARK_WIDTH> bookmark_tmp;
#endif

    bool rst_stall;
    bool flush_stall;
    llc_set_t rst_flush_stalled_set;
    bool req_stall;
    bool req_in_stalled_valid;
    llc_req_in_t<CACHE_ID_WIDTH> req_in_stalled;
    llc_tag_t req_in_stalled_tag;
    llc_set_t req_in_stalled_set;
    llc_req_in_t<LLC_COH_DEV_ID_WIDTH> dma_req_in;
    bool dma_read_pending;
    bool dma_write_pending;
    addr_t dma_addr;
    dma_length_t dma_read_length;
    dma_length_t dma_length;
    bool dma_done;
    bool dma_start;
    bool recall_pending;
    bool recall_valid;
};

#endif /* __LLC_HPP__ */
