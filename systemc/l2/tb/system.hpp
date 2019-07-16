// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

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

#ifdef STATS_ENABLE
    put_get_channel<bool> l2_stats_chnl;
#endif

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
	dut->l2_cpu_req(l2_cpu_req_chnl);
	dut->l2_fwd_in(l2_fwd_in_chnl);
	dut->l2_rsp_in(l2_rsp_in_chnl);
	dut->l2_flush(l2_flush_chnl);
	dut->l2_rd_rsp(l2_rd_rsp_chnl);
	dut->l2_inval(l2_inval_chnl);
	dut->l2_req_out(l2_req_out_chnl);
	dut->l2_rsp_out(l2_rsp_out_chnl);
#ifdef STATS_ENABLE
	dut->l2_stats(l2_stats_chnl);
#endif

	// Binding testbench
	tb->clk(clk);
	tb->rst(rst);
        tb->flush_done(flush_done);
	tb->l2_cpu_req_tb(l2_cpu_req_chnl);
	tb->l2_fwd_in_tb(l2_fwd_in_chnl);
	tb->l2_rsp_in_tb(l2_rsp_in_chnl); 
	tb->l2_flush_tb(l2_flush_chnl); 
	tb->l2_rd_rsp_tb(l2_rd_rsp_chnl);
	tb->l2_inval_tb(l2_inval_chnl);
	tb->l2_req_out_tb(l2_req_out_chnl);
	tb->l2_rsp_out_tb(l2_rsp_out_chnl);
#ifdef STATS_ENABLE
	tb->l2_stats_tb(l2_stats_chnl);
#endif

    }
};

#endif // __SYSTEM_HPP__
