/* Copyright 2017 Columbia University, SLD Group */

#ifndef __SYSTEM_HPP__
#define __SYSTEM_HPP__

#include <string>
#include <iostream>
#include <sstream>

#include "l2.hpp"
#include "l2_wrap.h"

#include "llc.hpp"
#include "llc_wrap.h"

#include "mem.hpp"
#include "noc.hpp"

#include "sys_tb.hpp"

class system_t : public sc_module
{

public:

	// Clock signal
	sc_in<bool> clk;

	// Reset signal
	sc_in<bool> rst;

	//
	// Signals
	//

	// L2
	sc_signal<bool>	                  *l2_flush_done[N_CPU];
	sc_signal<sc_bv<ASSERT_WIDTH> >	  *l2_asserts[N_CPU];
	sc_signal<sc_bv<BOOKMARK_WIDTH> > *l2_bookmark[N_CPU];
	sc_signal<uint32_t>               *l2_custom_dbg[N_CPU];
	// To  L2 cache
	put_get_channel<l2_cpu_req_t>     *l2_cpu_req_chnl[N_CPU];
	put_get_channel<l2_fwd_in_t>      *l2_fwd_in_chnl[N_CPU];
	put_get_channel<l2_rsp_in_t>      *l2_rsp_in_chnl[N_CPU];
	put_get_channel<bool>             *l2_flush_chnl[N_CPU];
	// From	L2 cache
	put_get_channel<l2_rd_rsp_t>      *l2_rd_rsp_chnl[N_CPU];
	put_get_channel<l2_inval_t>       *l2_inval_chnl[N_CPU];
	put_get_channel<l2_req_out_t>     *l2_req_out_chnl[N_CPU];
	put_get_channel<l2_rsp_out_t>     *l2_rsp_out_chnl[N_CPU];

	// LLC
	sc_signal< sc_bv<LLC_ASSERT_WIDTH> >   llc_asserts;
	sc_signal< sc_bv<LLC_BOOKMARK_WIDTH> > llc_bookmark;
	sc_signal<uint32_t>                    llc_custom_dbg;
	sc_signal<bool>                        llc_tag_hit_out;
	sc_signal<llc_way_t>                   llc_hit_way_out;
	sc_signal<bool>                        llc_empty_way_found_out;
	sc_signal<llc_way_t>                   llc_empty_way_out;
	sc_signal<bool>                        llc_evict_out;
	sc_signal<llc_way_t>                   llc_way_out;
	sc_signal<llc_addr_t>                  llc_addr_out;
	// To LLC cache
	put_get_channel<llc_req_in_t>          llc_req_in_chnl;
	put_get_channel<llc_rsp_in_t>          llc_rsp_in_chnl;
	put_get_channel<llc_mem_rsp_t>         llc_mem_rsp_chnl;
	put_get_channel<bool>                  llc_rst_tb_chnl;
	// From LLC cache
	put_get_channel<llc_rsp_out_t>         llc_rsp_out_chnl;
	put_get_channel<llc_fwd_out_t>         llc_fwd_out_chnl;
	put_get_channel<llc_mem_req_t>         llc_mem_req_chnl;
	put_get_channel<bool>                  llc_rst_tb_done_chnl;

	//
	// Modules
	//

	// Memory
	mem *m;
	// LLC cache instance
	llc_wrapper *llc;
	// System testbench module
	sys_tb *tb;
	// NoC
	noc *n;
	// L2 cache instance
	l2_wrapper *l2[N_CPU];

	// Constructor
	SC_CTOR(system_t)
		: clk("clk")
		, rst("rst")
		, llc_asserts("llc_asserts")
		, llc_bookmark("llc_bookmark")
		, llc_tag_hit_out("llc_tag_hit_out")
		, llc_hit_way_out("llc_hit_way_out")
		, llc_empty_way_found_out("llc_empty_way_found_out")
		, llc_empty_way_out("llc_empty_way_out")
		, llc_evict_out("llc_evict_out")
		, llc_way_out("llc_way_out")
		, llc_addr_out("llc_addr_out")
		, llc_req_in_chnl("llc_req_in_chnl")
		, llc_rsp_in_chnl("llc_rsp_in_chnl")
		, llc_mem_rsp_chnl("llc_mem_rsp_chnl")
		, llc_rst_tb_chnl("llc_rst_tb_chnl")
		, llc_rsp_out_chnl("llc_rsp_out_chnl")
		, llc_fwd_out_chnl("llc_fwd_out_chnl")
		, llc_mem_req_chnl("llc_mem_req_chnl")
		, llc_rst_tb_done_chnl("llc_rst_tb_done_chnl")
		{
			// Modules
			m = new mem("mem");
			n = new noc("noc");
			llc = new llc_wrapper("llc");
			tb  = new sys_tb("sys");

			// Binding memory
			m->clk(clk);
			m->rst(rst);
			m->mem_rsp(llc_mem_rsp_chnl);
			m->mem_req(llc_mem_req_chnl);

			// Binding LLC cache
			llc->clk(clk);
			llc->rst(rst);
			llc->asserts(llc_asserts);
			llc->bookmark(llc_bookmark);
			llc->custom_dbg(llc_custom_dbg);
			llc->tag_hit_out(llc_tag_hit_out);
			llc->hit_way_out(llc_hit_way_out);
			llc->empty_way_found_out(llc_empty_way_found_out);
			llc->empty_way_out(llc_empty_way_out);
			llc->evict_out(llc_evict_out);
			llc->way_out(llc_way_out);
			llc->llc_addr_out(llc_addr_out);
			llc->llc_req_in(llc_req_in_chnl);
			llc->llc_rsp_in(llc_rsp_in_chnl);
			llc->llc_mem_rsp(llc_mem_rsp_chnl);
			llc->llc_rst_tb(llc_rst_tb_chnl);
			llc->llc_rsp_out(llc_rsp_out_chnl);
			llc->llc_fwd_out(llc_fwd_out_chnl);
			llc->llc_mem_req(llc_mem_req_chnl);
			llc->llc_rst_tb_done(llc_rst_tb_done_chnl);

			// Binding testbench
			tb->clk(clk);
			tb->rst(rst);
			tb->llc_asserts(llc_asserts);
			tb->llc_bookmark(llc_bookmark);
			tb->llc_custom_dbg(llc_custom_dbg);
			tb->llc_tag_hit_out(llc_tag_hit_out);
			tb->llc_hit_way_out(llc_hit_way_out);
			tb->llc_empty_way_found_out(llc_empty_way_found_out);
			tb->llc_empty_way_out(llc_empty_way_out);
			tb->llc_evict_out(llc_evict_out);
			tb->llc_way_out(llc_way_out);
			tb->llc_addr_out(llc_addr_out);
			tb->llc_rst_tb(llc_rst_tb_chnl);
			tb->llc_rst_tb_done(llc_rst_tb_done_chnl);

			// Binding NoC
			n->clk(clk);
			n->rst(rst);
			n->llc_req_in(llc_req_in_chnl);
			n->llc_rsp_in(llc_rsp_in_chnl);
			n->llc_rsp_out(llc_rsp_out_chnl);
			n->llc_fwd_out(llc_fwd_out_chnl);

			for (int i = 0; i < N_CPU; i++) {
				std::stringstream stm;
				stm << "l2_wrapper_" << i;
				l2[i]  = new l2_wrapper(stm.str().c_str());

				stm.str("");
				stm << "l2_flush_done_" << i;
				l2_flush_done[i] = new sc_signal<bool>(stm.str().c_str());
				stm.str("");
				stm << "l2_asserts_" << i;
				l2_asserts[i] = new sc_signal<sc_bv<ASSERT_WIDTH> >(stm.str().c_str());
				stm.str("");
				stm << "l2_bookmark_" << i;
				l2_bookmark[i] = new sc_signal<sc_bv<BOOKMARK_WIDTH> >(stm.str().c_str());
				stm.str("");
				stm << "l2_custom_dbg_" << i;
				l2_custom_dbg[i] = new sc_signal<uint32_t>(stm.str().c_str());
				stm.str("");
				stm << "l2_cpu_req_chnl_" << i;
				l2_cpu_req_chnl[i] = new put_get_channel<l2_cpu_req_t>(stm.str().c_str());
				stm.str("");
				stm << "l2_fwd_in_chnl_" << i;
				l2_fwd_in_chnl[i] = new put_get_channel<l2_fwd_in_t>(stm.str().c_str());
				stm.str("");
				stm << "l2_rsp_in_chnl_" << i;
				l2_rsp_in_chnl[i] = new put_get_channel<l2_rsp_in_t>(stm.str().c_str());
				stm.str("");
				stm << "l2_flush_chnl_" << i;
				l2_flush_chnl[i] = new put_get_channel<bool>(stm.str().c_str());
				stm.str("");
				stm << "l2_rd_rsp_chnl_" << i;
				l2_rd_rsp_chnl[i] = new put_get_channel<l2_rd_rsp_t>(stm.str().c_str());
				stm.str("");
				stm << "l2_inval_chnl_" << i;
				l2_inval_chnl[i] = new put_get_channel<l2_inval_t>(stm.str().c_str());
				stm.str("");
				stm << "l2_req_out_chnl_" << i;
				l2_req_out_chnl[i] = new put_get_channel<l2_req_out_t>(stm.str().c_str());
				stm.str("");
				stm << "l2_rsp_out_chnl_" << i;
				l2_rsp_out_chnl[i] = new put_get_channel<l2_rsp_out_t>(stm.str().c_str());


				// Binding L2 cache
				l2[i]->clk(clk);
				l2[i]->rst(rst);
				l2[i]->flush_done(*l2_flush_done[i]);
				l2[i]->asserts(*l2_asserts[i]);
				l2[i]->bookmark(*l2_bookmark[i]);
				l2[i]->custom_dbg(*l2_custom_dbg[i]);
				l2[i]->l2_cpu_req(*l2_cpu_req_chnl[i]);
				l2[i]->l2_fwd_in(*l2_fwd_in_chnl[i]);
				l2[i]->l2_rsp_in(*l2_rsp_in_chnl[i]);
				l2[i]->l2_flush(*l2_flush_chnl[i]);
				l2[i]->l2_rd_rsp(*l2_rd_rsp_chnl[i]);
				l2[i]->l2_inval(*l2_inval_chnl[i]);
				l2[i]->l2_req_out(*l2_req_out_chnl[i]);
				l2[i]->l2_rsp_out(*l2_rsp_out_chnl[i]);

				// Binding NoC
				(*n->l2_fwd_in[i])(*l2_fwd_in_chnl[i]);
				(*n->l2_rsp_in[i])(*l2_rsp_in_chnl[i]);
				(*n->l2_req_out[i])(*l2_req_out_chnl[i]);
				(*n->l2_rsp_out[i])(*l2_rsp_out_chnl[i]);

				// Binding testbench
				tb->l2_flush_done[i](*l2_flush_done[i]);
				tb->l2_asserts[i](*l2_asserts[i]);
				tb->l2_bookmark[i](*l2_bookmark[i]);
				tb->l2_custom_dbg[i](*l2_custom_dbg[i]);
				(*tb->l2_cpu_req_tb[i])(*l2_cpu_req_chnl[i]);
				(*tb->l2_flush_tb[i])(*l2_flush_chnl[i]);
				(*tb->l2_rd_rsp_tb[i])(*l2_rd_rsp_chnl[i]);
				(*tb->l2_inval_tb[i])(*l2_inval_chnl[i]);
			}

		}
};

#endif // __SYSTEM_HPP__
