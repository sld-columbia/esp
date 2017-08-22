/* Copyright 2017 Columbia University, SLD Group */

#ifndef __LLC_HPP__
#define __LLC_HPP__

#include "cache_utils.hpp"
#include "llc_directives.hpp"
#include "llc_tags.hpp"
#include "llc_states.hpp"
#include "llc_hprots.hpp"
#include "llc_lines.hpp"
#include "llc_sharers.hpp"
#include "llc_owners.hpp"
#include "llc_evict_ways.hpp"

class llc : public sc_module
{

public:

    // Clock signal
    sc_in<bool> clk;

    // Reset signal
    sc_in<bool> rst;

    // Debug signals
    sc_out< sc_bv<LLC_ASSERT_WIDTH> >   asserts;
    sc_out< sc_bv<LLC_BOOKMARK_WIDTH> > bookmark;
    sc_out<uint32_t>                    custom_dbg;

    // Input ports
    nb_get_initiator<llc_req_in_t>	llc_req_in;
    // nb_get_initiator<llc_rsp_in_t>	llc_rsp_in;
    nb_get_initiator<llc_mem_rsp_t>	llc_mem_rsp;

    // Output ports
    put_initiator<llc_rsp_out_t>	llc_rsp_out;
    // put_initiator<llc_fwd_out_t>	llc_fwd_out;
    nb_put_initiator<llc_mem_req_t>     llc_mem_req;

    // Local memory (explicit, TODO: make implicit)
    llc_tags_t<tag_t, LLC_LINES>	 tags;
    llc_states_t<llc_state_t, LLC_LINES> states;
    llc_hprots_t<hprot_t, LLC_LINES>	 hprots;
    llc_lines_t<line_t, LLC_LINES>	 lines;
    llc_sharers_t<sharers_t, LLC_LINES>	 sharers;
    llc_owners_t<owner_t, LLC_LINES>	 owners;
    llc_evict_ways_t<llc_way_t, SETS>      evict_ways;

    // Local registers
    tag_t	 tag_buf[L2_WAYS];
    state_t	 state_buf[L2_WAYS];
    hprot_t	 hprot_buf[L2_WAYS];
    line_t	 line_buf[L2_WAYS];
    sharers_t	 sharers_buf[L2_WAYS];
    owner_t      owner_buf[L2_WAYS];
    llc_way_t	 evict_way;

    // Constructor
    SC_CTOR(llc)
    {
        // Cache controller process
	SC_CTHREAD(ctrl, clk.pos());
	reset_signal_is(rst, false);
	// set_stack_size(0x400000);

	// Assign clock and reset to put_get ports
	llc_req_in.clk_rst (clk, rst);
	// llc_rsp_in.clk_rst (clk, rst);
	llc_mem_rsp.clk_rst (clk, rst);
	llc_rsp_out.clk_rst (clk, rst);
	// llc_fwd_out.clk_rst(clk, rst);
	llc_mem_req.clk_rst(clk, rst);

	// Flatten arrays
	FLATTEN_REGS;

	// Clock binding for memories
	tags.clk(this->clk);
	states.clk(this->clk);
	hprots.clk(this->clk);
	lines.clk(this->clk);
	sharers.clk(this->clk);
	owners.clk(this->clk);
	evict_ways.clk(this->clk);
    }

    // Processes
    void ctrl(); // cache controller

    // Functions
    inline void reset_io();
    inline void reset_states();

    // void tag_lookup(addr_breakdown_t addr_br, bool &tag_hit,
    // 		    llc_way_t &way_hit, bool &empty_way_found,
    // 		    llc_way_t &empty_way, sc_uint<REQS_BITS> &reqs_i);
    // void reqs_lookup(addr_breakdown_t addr_br, bool &reqs_hit, 
    // 		     sc_uint<REQS_BITS> &reqs_hit_i);
    // void read_set(set_t set);
    // void fill_reqs(cpu_msg_t cpu_msg, addr_breakdown_t addr_br, tag_t tag_estall, llc_way_t way_hit, hsize_t hsize,
    // 		   unstable_state_t state, hprot_t hprot, 
    // 		   invack_cnt_t invack_cnt, word_t word, 
    // 		   line_t line, sc_uint<REQS_BITS> reqs_i);
    // void get_cpu_req(llc_cpu_req_t &cpu_req);
    // void get_rsp_in(llc_rsp_in_t &rsp_in);
    // void get_flush();
    // void send_req_out(coh_msg_t coh_msg, hprot_t hprot, 
    // 		      addr_t line_addr, line_t lines);
    // void send_rd_rsp(line_t lines);
    // void send_inval(addr_t addr_inval);
    // void put_reqs(set_t set, llc_way_t way, tag_t tag,
    // 		  line_t lines, hprot_t hprot, state_t state);

private:
    // debug
    sc_bv<LLC_ASSERT_WIDTH>   asserts_tmp;
    sc_bv<LLC_BOOKMARK_WIDTH> bookmark_tmp;
    uint64_t custom_dbg_tmp;
};

#endif /* __LLC_HPP__ */
