// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

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

    // Channels
    // To LLC cache
    put_get_channel<llc_req_in_t<CACHE_ID_WIDTH> > llc_req_in_chnl;
    put_get_channel<llc_req_in_t<LLC_COH_DEV_ID_WIDTH> >  llc_dma_req_in_chnl;
    put_get_channel<llc_rsp_in_t>  llc_rsp_in_chnl;
    put_get_channel<llc_mem_rsp_t> llc_mem_rsp_chnl;
    put_get_channel<bool>          llc_rst_tb_chnl;

    // From LLC cache
    put_get_channel<llc_rsp_out_t<CACHE_ID_WIDTH> > llc_rsp_out_chnl;
    put_get_channel<llc_rsp_out_t<LLC_COH_DEV_ID_WIDTH> > llc_dma_rsp_out_chnl;
    put_get_channel<llc_fwd_out_t> llc_fwd_out_chnl;
    put_get_channel<llc_mem_req_t> llc_mem_req_chnl;
    put_get_channel<bool>          llc_rst_tb_done_chnl;

#ifdef STATS_ENABLE
    put_get_channel<bool> llc_stats_chnl;
#endif

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
	dut->llc_req_in(llc_req_in_chnl);
	dut->llc_dma_req_in(llc_dma_req_in_chnl);
	dut->llc_rsp_in(llc_rsp_in_chnl);
	dut->llc_mem_rsp(llc_mem_rsp_chnl);
	dut->llc_rst_tb(llc_rst_tb_chnl);
	dut->llc_rsp_out(llc_rsp_out_chnl);
	dut->llc_dma_rsp_out(llc_dma_rsp_out_chnl);
	dut->llc_fwd_out(llc_fwd_out_chnl);
	dut->llc_mem_req(llc_mem_req_chnl);
	dut->llc_rst_tb_done(llc_rst_tb_done_chnl);
#ifdef STATS_ENABLE
	dut->llc_stats(llc_stats_chnl);
#endif
	// Binding testbench
	tb->clk(clk);
	tb->rst(rst);
	tb->llc_req_in_tb(llc_req_in_chnl);
	tb->llc_dma_req_in_tb(llc_dma_req_in_chnl);
	tb->llc_rsp_in_tb(llc_rsp_in_chnl);
	tb->llc_mem_rsp_tb(llc_mem_rsp_chnl); 
	tb->llc_rst_tb_tb(llc_rst_tb_chnl);
	tb->llc_rsp_out_tb(llc_rsp_out_chnl);
	tb->llc_dma_rsp_out_tb(llc_dma_rsp_out_chnl);
	tb->llc_fwd_out_tb(llc_fwd_out_chnl);
	tb->llc_mem_req_tb(llc_mem_req_chnl);
	tb->llc_rst_tb_done_tb(llc_rst_tb_done_chnl);
#ifdef STATS_ENABLE
	tb->llc_stats_tb(llc_stats_chnl);
#endif
    }
};

#endif // __SYSTEM_HPP__
