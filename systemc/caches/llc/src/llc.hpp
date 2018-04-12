/* Copyright 2017 Columbia University, SLD Group */

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
    sc_out< sc_bv<LLC_ASSERT_WIDTH> >   asserts;
    sc_out< sc_bv<LLC_BOOKMARK_WIDTH> > bookmark;
    sc_out<uint32_t>    custom_dbg;

    sc_out<bool>	tag_hit_out;
    sc_out<llc_way_t>	hit_way_out;
    sc_out<bool>	empty_way_found_out;
    sc_out<llc_way_t>	empty_way_out;
    sc_out<llc_way_t>	way_out;
    sc_out<llc_addr_t>	llc_addr_out;
    sc_out<bool>	evict_out;
    sc_out<bool>	evict_valid_out;
    sc_out<bool>	evict_way_not_sd_out;
    sc_out<line_addr_t> evict_addr_out;
    sc_out<llc_set_t>	flush_set_out;
    sc_out<llc_way_t>	flush_way_out;    

    sc_out<bool>		req_stall_out;
    sc_out<bool>		req_in_stalled_valid_out;
    sc_out<llc_req_in_t>	req_in_stalled_out;

    sc_out<llc_tag_t>	tag_buf_out[LLC_WAYS];
    sc_out<llc_state_t> state_buf_out[LLC_WAYS];
    sc_out<hprot_t>	hprot_buf_out[LLC_WAYS];
    sc_out<line_t>	line_buf_out[LLC_WAYS];
    sc_out<sharers_t>	sharers_buf_out[LLC_WAYS];
    sc_out<owner_t>	owner_buf_out[LLC_WAYS];
    sc_out<sc_uint<2> >	dirty_bit_buf_out[LLC_WAYS];
    sc_out<llc_way_t>	evict_way_buf_out;
#endif

    // Input ports
    nb_get_initiator<llc_req_in_t>	llc_req_in;
    nb_get_initiator<llc_rsp_in_t>	llc_rsp_in;
    get_initiator<llc_mem_rsp_t>	llc_mem_rsp;
    nb_get_initiator<bool>              llc_rst_tb;

    // Output ports
    put_initiator<llc_rsp_out_t>	llc_rsp_out;
    put_initiator<llc_fwd_out_t>	llc_fwd_out;
    put_initiator<llc_mem_req_t>        llc_mem_req;
    put_initiator<bool>                 llc_rst_tb_done;

    // Local memory
    // Local memory
    EXP_MEM_TYPE_STRING(llc, tags, LLC_SETS, LLC_WAYS)<llc_tag_t, LLC_LINES> tags;
    EXP_MEM_TYPE_STRING(llc, states, LLC_SETS, LLC_WAYS)<llc_state_t, LLC_LINES> states;
    EXP_MEM_TYPE_STRING(llc, lines, LLC_SETS, LLC_WAYS)<line_t, LLC_LINES> lines;
    EXP_MEM_TYPE_STRING(llc, hprots, LLC_SETS, LLC_WAYS)<hprot_t, LLC_LINES> hprots;
    EXP_MEM_TYPE_STRING(llc, owners, LLC_SETS, LLC_WAYS)<owner_t, LLC_LINES> owners;
    EXP_MEM_TYPE_STRING(llc, sharers, LLC_SETS, LLC_WAYS)<sharers_t, LLC_LINES> sharers;
    EXP_MEM_TYPE_STRING(llc, dirty_bits, LLC_SETS, LLC_WAYS)<sc_uint<2>, LLC_LINES> dirty_bits;
    EXP_MEM_TYPE_STRING(llc, evict_ways, LLC_SETS, LLC_WAYS)<llc_way_t, LLC_SETS> evict_ways;

    // Local registers
    llc_tag_t	 tag_buf[LLC_WAYS];
    llc_state_t	 state_buf[LLC_WAYS];
    hprot_t	 hprot_buf[LLC_WAYS];
    line_t	 line_buf[LLC_WAYS];
    sharers_t	 sharers_buf[LLC_WAYS];
    owner_t      owner_buf[LLC_WAYS];
    sc_uint<2>   dirty_bit_buf[LLC_WAYS];
    llc_way_t	 evict_way_buf;

    // Constructor
    SC_CTOR(llc)
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
	    , llc_req_in("llc_req_in")
	    , llc_rsp_in("llc_rsp_in")
	    , llc_mem_rsp("llc_mem_rsp")
	    , llc_rst_tb("llc_rst_tb")
	    , llc_rsp_out("llc_rsp_out")
	    , llc_fwd_out("llc_fwd_out")
	    , llc_mem_req("llc_mem_req")
	    , llc_rst_tb_done("llc_rst_tb_done")
    {
        // Cache controller process
	SC_CTHREAD(ctrl, clk.pos());
	reset_signal_is(rst, false);
	// set_stack_size(0x400000);

	// Assign clock and reset to put_get ports
	llc_req_in.clk_rst (clk, rst);
	llc_rsp_in.clk_rst (clk, rst);
	llc_mem_rsp.clk_rst (clk, rst);
	llc_rst_tb.clk_rst(clk, rst);
	llc_rsp_out.clk_rst (clk, rst);
	llc_fwd_out.clk_rst(clk, rst);
	llc_mem_req.clk_rst(clk, rst);
	llc_rst_tb_done.clk_rst(clk, rst);

	// Flatten arrays
	LLC_FLATTEN_REGS;

	// Clock binding for memories
	tags.clk(this->clk);
	states.clk(this->clk);
	hprots.clk(this->clk);
	lines.clk(this->clk);
	owners.clk(this->clk);
	sharers.clk(this->clk);
	dirty_bits.clk(this->clk);
	evict_ways.clk(this->clk);
    }

    // Processes
    void ctrl(); // cache controller

    // Functions
    inline void reset_io();
    inline void reset_states();
    void read_set(llc_addr_t base, llc_way_t offset);
    void lookup(llc_tag_t tag, llc_set_t set, llc_way_t &way, bool &evict, llc_addr_t &llc_addr);
    void send_mem_req(bool hwrite, line_addr_t line_addr, hprot_t hprot, line_t line);
    void get_mem_rsp(line_t &line);
    void get_req_in(llc_req_in_t &req_in);
    void get_rsp_in(llc_rsp_in_t &rsp_in);
    void send_rsp_out(coh_msg_t coh_msg, line_addr_t addr, line_t line, cache_id_t req_id,
		      cache_id_t dest_id, invack_cnt_t invack_cnt);
    void send_fwd_out(coh_msg_t coh_msg, line_addr_t addr, cache_id_t req_id, cache_id_t dest_id);
    llc_rsp_in_t wait_rsp_in(addr_t addr_evict);
    void process_rsp_in(llc_rsp_in_t rsp_in);

private:

#ifdef LLC_DEBUG
    // debug
    sc_bv<LLC_ASSERT_WIDTH>   asserts_tmp;
    sc_bv<LLC_BOOKMARK_WIDTH> bookmark_tmp;
    uint64_t custom_dbg_tmp;
#endif

    bool req_stall;
    bool req_in_stalled_valid;
    llc_req_in_t req_in_stalled;
    llc_tag_t req_in_stalled_tag;
    llc_set_t req_in_stalled_set;
};

#endif /* __LLC_HPP__ */
