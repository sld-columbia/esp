/* Copyright 2017 Columbia University, SLD Group */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "llc_tb.hpp"

/*
 * Processes
 */

#ifdef LLC_DEBUG

void llc_tb::llc_debug()
{
    sc_bv<LLC_ASSERT_WIDTH>   old_asserts  = 0;
    sc_bv<LLC_ASSERT_WIDTH>   new_asserts  = 0;
    sc_bv<LLC_BOOKMARK_WIDTH> old_bookmark = 0;
    sc_bv<LLC_BOOKMARK_WIDTH> new_bookmark = 0;
    uint32_t old_custom_dbg = 0;
    uint32_t new_custom_dbg = 0;

    while(true) {
	new_asserts = asserts.read();
	new_bookmark = bookmark.read();
	new_custom_dbg = custom_dbg.read();

	if (old_asserts != new_asserts) {
	    old_asserts = new_asserts;
	    CACHE_REPORT_DEBUG(sc_time_stamp(), "assert", new_asserts);
	}

	if (old_bookmark != new_bookmark) {
	    old_bookmark = new_bookmark;
	    if (RPT_BM) CACHE_REPORT_DEBUG(sc_time_stamp(), "bookmark", new_bookmark);
	}

	if (old_custom_dbg != new_custom_dbg) {
	    old_custom_dbg = new_custom_dbg;
	    if (RPT_CU) CACHE_REPORT_DEBUG(sc_time_stamp(), "custom_dbg", new_custom_dbg);
	}
	
	wait();
    }
}

#endif

void llc_tb::llc_test()
{
    /*
     * Random seed
     */
    
    // initialize
    srand(time(NULL));

    /*
     * Local variables
     */

    // constants
    const word_t empty_word = 0;
    const line_t empty_line = 0;
    const hprot_t empty_hprot = 1;
    const addr_t empty_addr = 0;

    // preparation variables
    addr_breakdown_t addr_base, addr, addr_evict;
    word_t word, word_tmp;
    line_t line;

    unsigned int n_l2 = 1;
    unsigned int l2_ways = 1;

    /*
     * Configuration
     */

    switch (LLC_WAYS) {

    case 4:

	n_l2 = 1;
	l2_ways = 4;
	break;

    case 8:

	n_l2 = 2;
	l2_ways = 4;
	break;

    case 16:

	n_l2 = 4;
	l2_ways = 4;
	break;

    case 32:

	n_l2 = 8;
	l2_ways = 4;
	break;

    default:

	CACHE_REPORT_INFO("ERROR: LLC_WAYS not supported.");
    }

    /*
     * Reset
     */

    reset_llc_test();
    reset_dut();

    addr_base = rand_addr();
    addr = addr_base; addr_evict = addr_base;


    CACHE_REPORT_INFO("T0) 1 CPU. NO EVICTION. TEST ALL POSSIBLE INTERNAL STATES OF LLC.");

    addr = addr_base; addr_evict = addr_base;

    CACHE_REPORT_INFO("T0.0)");
    // fill a set with exclusive and modified states with GetS and GetM
    for (int i = 0; i < LLC_WAYS; ++i) {
    	op(REQ_GETS, INVALID, 0, addr, addr_evict, 0, line_of_addr(addr.line), 0, 0, 0, 0, RPT_TB);
	addr.tag_incr(1);
    }
    
    CACHE_REPORT_INFO("T0.2)");
    // put back all of the ways in the first set with PutS and PutM
    for (int i = 0; i < LLC_WAYS; ++i) {
	addr.tag_decr(1);
    	op(REQ_PUTM, MODIFIED, 0, addr, addr_evict, 0xcace, 0, 0, 0, 0, 0, RPT_TB);
    }

    CACHE_REPORT_INFO("T0.5)");
    // get all VALID from the first set
    for (int i = 0; i < LLC_WAYS; ++i) {
    	op(REQ_GETM, VALID, 0, addr, addr_evict, 0, 0xcace, 0, 0, 0, 0, RPT_TB);
	addr.tag_incr(1);
    }

    reset_dut();    

    ////////////////////////////

    CACHE_REPORT_INFO("T1) 1 CPU. EVICTION.");

    CACHE_REPORT_INFO("T1.0)");

    // cause LLC_WAYS + 2 invalidations on a new set
    addr_evict = addr;
    for (int i = 0; i < LLC_WAYS; ++i) {
    	op(REQ_GETS, INVALID, 0, addr, addr_evict, 0, line_of_addr(addr.line), 0, 0, 0, 0, RPT_TB);
	addr.tag_incr(1);
    }

    CACHE_REPORT_INFO("T1.1)");
    for (int i = 0; i < LLC_WAYS; ++i) {
	op(REQ_PUTS, EXCLUSIVE, 0, addr_evict, addr_evict, 0, 0, 0, 0, 0, 0, RPT_TB);
    	op(REQ_GETS, INVALID, 1, addr, addr_evict, 0, line_of_addr(addr.line), 
	   line_of_addr(addr_evict.line), 0, 0, 0, RPT_TB);
	addr.tag_incr(1); addr_evict.tag_incr(1);
    }

    if (LLC_WAYS < 8)
	sc_stop();

    reset_dut(); 

    /*
     * T0) 1 CPU. No eviction. Test all possible internal states of LLC. 
     */

    CACHE_REPORT_INFO("T0) 1 CPU. NO EVICTION. TEST ALL POSSIBLE INTERNAL STATES OF LLC.");

    addr = addr_base; addr_evict = addr_base;

    CACHE_REPORT_INFO("T0.0)");
    // fill a set with exclusive and modified states with GetS and GetM
    for (int i = 0; i < LLC_WAYS/2; ++i) {
    	op(REQ_GETS, INVALID, 0, addr, addr_evict, 0, line_of_addr(addr.line), 0, 0, 0, 0, RPT_TB);
	addr.tag_incr(1);
    	op(REQ_GETM, INVALID, 0, addr, addr_evict, 0, line_of_addr(addr.line), 0, 0, 0, 0, RPT_TB);
	addr.tag_incr(1);
    }
    
    CACHE_REPORT_INFO("T0.1)");
    // fill half of a different set with exclusive and modified states
    addr.set_incr(1);
    for (int i = 0; i < LLC_WAYS/4; ++i) {
	op(REQ_GETS, INVALID, 0, addr, addr_evict, 0, line_of_addr(addr.line), 0, 0, 0, 0, RPT_TB);
	addr.tag_incr(1);
	op(REQ_GETM, INVALID, 0, addr, addr_evict, 0, line_of_addr(addr.line), 0, 0, 0, 0, RPT_TB);
	addr.tag_incr(1);
    }

    CACHE_REPORT_INFO("T0.2)");
    // put back all of the ways in the first set with PutS and PutM
    addr.set_decr(1);
    addr.tag_decr(LLC_WAYS/2);
    for (int i = 0; i < LLC_WAYS/4; ++i) {
	addr.tag_decr(1);
    	op(REQ_PUTM, MODIFIED, 0, addr, addr_evict, 0xcace, 0, 0, 0, 0, 0, RPT_TB);
	addr.tag_decr(1);
    	op(REQ_PUTS, EXCLUSIVE, 0, addr, addr_evict, 0, 0, 0, 0, 0, 0, RPT_TB);
    }
    for (int i = 0; i < LLC_WAYS/4; ++i) {
	addr.tag_decr(1);
    	op(REQ_PUTM, MODIFIED, 0, addr, addr_evict, 0xcace, 0, 0, 0, 0, 0, RPT_TB);
	addr.tag_decr(1);
    	op(REQ_PUTM, EXCLUSIVE, 0, addr, addr_evict, 0xcace, 0, 0, 0, 0, 0, RPT_TB);
    }

    CACHE_REPORT_INFO("T0.3)");
    // put back 2 lines of the second set
    addr.set_incr(1);
    addr.tag_incr(LLC_WAYS);
    op(REQ_PUTS, EXCLUSIVE, 0, addr, addr_evict, 0, 0, 0, 0, 0, 0, RPT_TB);
    addr.tag_incr(1);
    op(REQ_PUTM, MODIFIED, 0, addr, addr_evict, 0xcace, 0, 0, 0, 0, 0, RPT_TB);

    CACHE_REPORT_INFO("T0.4)");
    // from the same set get 1 INVALID and 1 VALID
    op(REQ_GETS, VALID, 0, addr, addr_evict, 0, 0xcace, 0, 0, 0, 0, RPT_TB);
    addr.tag_incr(LLC_WAYS/2);
    op(REQ_GETM, INVALID, 0, addr, addr_evict, 0, line_of_addr(addr.line), 0, 0, 0, 0, RPT_TB);

    CACHE_REPORT_INFO("T0.5)");
    // get all VALID from the first set
    addr.set_decr(1);
    addr.tag_decr(LLC_WAYS + 1 + LLC_WAYS/2);
    for (int i = 0; i < LLC_WAYS/4; ++i) {
    	op(REQ_GETM, VALID, 0, addr, addr_evict, 0, 0xcace, 0, 0, 0, 0, RPT_TB);
	addr.tag_incr(1);
    	op(REQ_GETS, VALID, 0, addr, addr_evict, 0, 0xcace, 0, 0, 0, 0, RPT_TB);
	addr.tag_incr(1);
    }
    for (int i = 0; i < LLC_WAYS/4; ++i) {
    	op(REQ_GETM, VALID, 0, addr, addr_evict, 0, line_of_addr(addr.line), 0, 0, 0, 0, RPT_TB);
	addr.tag_incr(1);
    	op(REQ_GETS, VALID, 0, addr, addr_evict, 0, 0xcace, 0, 0, 0, 0, RPT_TB);
	addr.tag_incr(1);
    }

    reset_dut();

    /*
     * T1) 1 CPU. Eviction.
     */

    CACHE_REPORT_INFO("T1) 1 CPU. EVICTION.");

    CACHE_REPORT_INFO("T1.0)");

    // cause LLC_WAYS + 2 invalidations on a new set
    // addr.set_incr(2);
    addr_evict = addr;
    for (int i = 0; i < LLC_WAYS; ++i) {
    	op(REQ_GETS, INVALID, 0, addr, addr_evict, 0, line_of_addr(addr.line), 0, 0, 0, 0, RPT_TB);
	addr.tag_incr(1);
    }

    CACHE_REPORT_INFO("T1.1)");
    for (int i = 0; i < LLC_WAYS/2; ++i) {
	op(REQ_PUTS, EXCLUSIVE, 0, addr_evict, addr_evict, 0, 0, 0, 0, 0, 0, RPT_TB);
    	op(REQ_GETS, INVALID, 1, addr, addr_evict, 0, line_of_addr(addr.line), 
	   line_of_addr(addr_evict.line), 0, 0, 0, RPT_TB);
	addr.tag_incr(1); addr_evict.tag_incr(1);
	op(REQ_PUTS, EXCLUSIVE, 0, addr_evict, addr_evict, 0, 0, 0, 0, 0, 0, RPT_TB);
    	op(REQ_GETM, INVALID, 1, addr, addr_evict, 0, line_of_addr(addr.line), 
	   line_of_addr(addr_evict.line), 0, 0, 0, RPT_TB);
	addr.tag_incr(1); addr_evict.tag_incr(1);
    }

    reset_dut();

    /*
     * T2) Multiple CPUs.
     */

    CACHE_REPORT_INFO("T2) MULTIPLE CPUs.");

    CACHE_REPORT_INFO("T2.0) GetS - PutS. No eviction.");

    // GetS by all CPUs on all the ways of a set. No overlapping.
    addr.set_incr(10); addr_evict = addr;
    for (int j = 0; j < n_l2; j++) {
	for (int i = 0; i < l2_ways; i++) {
	    op(REQ_GETS, INVALID, 0, addr, addr_evict, 0, line_of_addr(addr.line), 0, 0, j, 0, RPT_TB);
	    addr.tag_incr(1);
	}
    }

    // PutS of one sharer for each way
    addr.tag_decr(n_l2*l2_ways);
    for (int j = 0; j < n_l2; j++) {
	for (int i = 0; i < l2_ways; i++) {
	    op(REQ_PUTS, EXCLUSIVE, 0, addr, addr_evict, 0, 0, 0, 0, j, j, RPT_TB);
	    addr.tag_incr(1);
	}
    }

    // GetS by all CPUs on all the ways of a set. No overlapping.
    addr.tag_decr(n_l2*l2_ways);
    for (int j = 0; j < n_l2; j++) {
	for (int i = 0; i < l2_ways; i++) {
	    op(REQ_GETS, VALID, 0, addr, addr_evict, 0, line_of_addr(addr.line), 0, 0, j, 0, RPT_TB);
	    addr.tag_incr(1);
	}
    }

    // GetS by all CPUs to have all the ways with 2 sharers
    addr.tag_decr(n_l2*l2_ways);
    for (int j = 1; j < n_l2; j++) {
	for (int i = 0; i < l2_ways; i++) {
	    op(REQ_GETS, EXCLUSIVE, 0, addr, addr_evict, 0, line_of_addr(addr.line), 0, 0, j, j-1, RPT_TB);
	    op_rsp(addr, line_of_addr(addr.line), j-1, RPT_TB);
	    addr.tag_incr(1);
	}
    }
    for (int i = 0; i < l2_ways; i++) {
	op(REQ_GETS, EXCLUSIVE, 0, addr, addr_evict, 0, line_of_addr(addr.line), 0, 0, 0, n_l2-1, RPT_TB);
	op_rsp(addr, line_of_addr(addr.line), n_l2-1, RPT_TB);
	addr.tag_incr(1);
    }

    // PutS of one sharer for each way
    addr.tag_decr(n_l2*l2_ways);
    for (int j = 0; j < n_l2; j++) {
	for (int i = 0; i < l2_ways; i++) {
	    op(REQ_PUTS, SHARED, 0, addr, addr_evict, 0, 0, 0, 0, j, j, RPT_TB);
	    addr.tag_incr(1);
	}
    }

    // GetS again all the ways to make sure data is still in the LLC
    addr.tag_decr(n_l2*l2_ways);
    for (int j = 0; j < n_l2; j++) {
	for (int i = 0; i < l2_ways; i++) {
	    op(REQ_GETS, SHARED, 0, addr, addr_evict, 0, line_of_addr(addr.line), 0, 0, j, 0, RPT_TB);
	    addr.tag_incr(1);
	}
    }

    // PutS of one sharer for each way
    addr.tag_decr(n_l2*l2_ways);
    for (int j = 0; j < n_l2; j++) {
	for (int i = 0; i < l2_ways; i++) {
	    op(REQ_PUTS, SHARED, 0, addr, addr_evict, 0, 0, 0, 0, j, j, RPT_TB);
	    addr.tag_incr(1);
	}
    }

    // PutS of the last sharer for each way
    addr.tag_decr(n_l2*l2_ways);
    for (int j = 1; j < n_l2; j++) {
	for (int i = 0; i < l2_ways; i++) {
	    op(REQ_PUTS, SHARED, 0, addr, addr_evict, 0, 0, 0, 0, j, j, RPT_TB);
	    addr.tag_incr(1);
	}
    }
    for (int i = 0; i < l2_ways; i++) {
	op(REQ_PUTS, SHARED, 0, addr, addr_evict, 0, 0, 0, 0, 0, 0, RPT_TB);
	addr.tag_incr(1);
    }

    // GetS again all the ways to make sure data is still in the LLC
    addr.tag_decr(n_l2*l2_ways);
    for (int j = 0; j < n_l2; j++) {
	for (int i = 0; i < l2_ways; i++) {
	    op(REQ_GETS, VALID, 0, addr, addr_evict, 0, line_of_addr(addr.line), 0, 0, j, 0, RPT_TB);
	    addr.tag_incr(1);
	}
    }

    // GetS by all CPUs to have all the ways with 2 sharers
    addr.tag_decr(n_l2*l2_ways);
    for (int j = 1; j < n_l2; j++) {
	for (int i = 0; i < l2_ways; i++) {
	    op(REQ_GETS, EXCLUSIVE, 0, addr, addr_evict, 0, line_of_addr(addr.line), 0, 0, j, j-1, RPT_TB);
	    op(REQ_PUTS, SD, 0, addr, addr_evict, 0, 0, 0, 0, j-1, j-1, RPT_TB);
	    op_rsp(addr, line_of_addr(addr.line), j-1, RPT_TB);
	    addr.tag_incr(1);
	}
    }

    for (int i = 0; i < l2_ways; i++) {
	op(REQ_GETS, EXCLUSIVE, 0, addr, addr_evict, 0, line_of_addr(addr.line), 0, 0, 0, n_l2-1, RPT_TB);
	op(REQ_PUTS, SD, 0, addr, addr_evict, 0, 0, 0, 0, n_l2-1, n_l2-1, RPT_TB);
	op_rsp(addr, line_of_addr(addr.line), n_l2-1, RPT_TB);
	addr.tag_incr(1);
    }

    // PutS of the last sharer for each way
    addr.tag_decr(n_l2*l2_ways);
    for (int j = 1; j < n_l2; j++) {
	for (int i = 0; i < l2_ways; i++) {
	    op(REQ_PUTS, SHARED, 0, addr, addr_evict, 0, 0, 0, 0, j, j, RPT_TB);
	    addr.tag_incr(1);
	}
    }
    for (int i = 0; i < l2_ways; i++) {
	op(REQ_PUTS, SHARED, 0, addr, addr_evict, 0, 0, 0, 0, 0, 0, RPT_TB);
	addr.tag_incr(1);
    }

    CACHE_REPORT_INFO("T2.1) GetS - PutS. Eviction.");

    // GetS by all CPUs on all the ways of a set. No overlapping.
    addr_evict = addr;
    addr_evict.tag_decr(n_l2*l2_ways);
    for (int j = 0; j < n_l2; j++) {
	for (int i = 0; i < l2_ways; i++) {
	    op(REQ_GETS, INVALID, 1, addr, addr_evict, 0, line_of_addr(addr.line), 
	       line_of_addr(addr_evict.line), 0, j, 0, RPT_TB);
	    addr.tag_incr(1); addr_evict.tag_incr(1);
	}
    }

    CACHE_REPORT_INFO("T2.2) GetM - PutM. No eviction.");

    addr.set_incr(1);
    for (int j = 0; j < n_l2; j++) {
	for (int i = 0; i < l2_ways; i++) {
	    op(REQ_GETM, INVALID, 0, addr, addr_evict, 0, line_of_addr(addr.line), 0, 0, j, 0, RPT_TB);
	    addr.tag_incr(1);
	}
    }

    CACHE_REPORT_INFO("T2.2) GetM - PutM. Eviction.");

    CACHE_REPORT_INFO("T2.3) All requests. Eviction.");

    CACHE_REPORT_INFO("T2.4) Arrival of Put requests misaligned.");


    // End simulation
    sc_stop();
}

/*
 * Functions
 */

void llc_tb::reset_dut()
{
    bool tmp_rst_tb;

    llc_rst_tb_tb.put(1);
    llc_rst_tb_done_tb.get(tmp_rst_tb);
    wait();
}

inline void llc_tb::reset_llc_test()
{
    llc_req_in_tb.reset_put();
    llc_rsp_in_tb.reset_put();
    llc_mem_rsp_tb.reset_put();
    llc_rst_tb_tb.reset_put();
    llc_rsp_out_tb.reset_get();
    llc_fwd_out_tb.reset_get();
    llc_mem_req_tb.reset_get();
    llc_rst_tb_done_tb.reset_get();

    wait();
}

void llc_tb::op_rsp(addr_breakdown_t req_addr, line_t req_line, cache_id_t req_id, bool rpt)
{
    put_rsp_in(req_addr.line, req_line, req_id, rpt);
}

void llc_tb::op(coh_msg_t coh_msg, llc_state_t state, bool evict, addr_breakdown_t req_addr, 
		addr_breakdown_t evict_addr, line_t req_line, line_t rsp_line, line_t evict_line,
		invack_cnt_t invack_cnt, cache_id_t req_id, cache_id_t dest_id, bool rpt)
{
    int out_plane = FWD_PLANE;
    coh_msg_t out_msg = 0;

    switch (coh_msg) {
    case REQ_GETS :
	switch (state) {
	case INVALID :
	case VALID :
	    out_plane = RSP_PLANE;
	    out_msg = RSP_EDATA;
	    break;
	case SHARED :
	    out_plane = RSP_PLANE;
	    out_msg = RSP_DATA;
	    break;
	case EXCLUSIVE :
	    out_plane = FWD_PLANE;
	    out_msg = FWD_GETS;
	    break;
	}
	break;
    case REQ_GETM :
	switch (state) {
	case INVALID :
	case VALID :
	    out_plane = RSP_PLANE;
	    out_msg = RSP_DATA;
	    break;
	}
	break;
    case REQ_PUTS :
	out_plane = FWD_PLANE;
	out_msg = FWD_PUTACK;
	break;
    case REQ_PUTM :
	out_plane = FWD_PLANE;
	out_msg = FWD_PUTACK;
	break;
    }

    put_req_in(coh_msg, req_addr.line, req_line, req_id, rpt);

    if (evict) {
	get_mem_req(LLC_WRITE, evict_addr.line, evict_line, rpt);
	wait();
    }

    if (state == INVALID || evict) {
	get_mem_req(LLC_READ, req_addr.line, 0, rpt);
	wait();
	put_mem_rsp(rsp_line, rpt);
    }

    if (out_plane == RSP_PLANE) {
	get_rsp_out(out_msg, req_addr.line, rsp_line, invack_cnt, req_id, dest_id, rpt);
    } else {
	get_fwd_out(out_msg, req_addr.line, req_id, dest_id, rpt);
    }

    wait();
}

void llc_tb::get_rsp_out(coh_msg_t coh_msg, addr_t addr, line_t line, invack_cnt_t invack_cnt,
			 cache_id_t req_id, cache_id_t dest_id, bool rpt)
{
    llc_rsp_out_t rsp_out;
    llc_rsp_out_tb.get(rsp_out);

    if (rsp_out.coh_msg != coh_msg       ||
	rsp_out.addr   != addr.range(TAG_RANGE_HI, SET_RANGE_LO) ||
	rsp_out.line   != line           ||
	rsp_out.invack_cnt != invack_cnt ||
	rsp_out.req_id != req_id         ||
	rsp_out.dest_id != dest_id
	) {
	
	CACHE_REPORT_ERROR("coh_msg get rsp out", rsp_out.coh_msg);
	CACHE_REPORT_ERROR("coh_msg get rsp out gold", coh_msg);
	CACHE_REPORT_ERROR("addr get rsp out", rsp_out.addr);
	CACHE_REPORT_ERROR("addr get rsp out gold", addr.range(TAG_RANGE_HI, SET_RANGE_LO));
	CACHE_REPORT_ERROR("line get rsp out", rsp_out.line);
	CACHE_REPORT_ERROR("line get rsp out gold", line);
	CACHE_REPORT_ERROR("invack_cnt get rsp out", rsp_out.invack_cnt);
	CACHE_REPORT_ERROR("invack_cnt get rsp out gold", invack_cnt);
	CACHE_REPORT_ERROR("req_id get rsp out", rsp_out.req_id);
	CACHE_REPORT_ERROR("req_id get rsp out gold", req_id);
	CACHE_REPORT_ERROR("dest_id get rsp out", rsp_out.dest_id);
	CACHE_REPORT_ERROR("dest_id get rsp out gold", dest_id);
    }
    if (rpt)
	CACHE_REPORT_VAR(sc_time_stamp(), "RSP_OUT", rsp_out);
}

void llc_tb::get_fwd_out(coh_msg_t coh_msg, addr_t addr, cache_id_t req_id, cache_id_t dest_id, bool rpt)
{
    llc_fwd_out_t fwd_out;
    llc_fwd_out_tb.get(fwd_out);

    if (fwd_out.coh_msg != coh_msg       ||
	fwd_out.addr   != addr.range(TAG_RANGE_HI, SET_RANGE_LO) ||
	fwd_out.req_id != req_id         ||
	fwd_out.dest_id != dest_id
	) {
	
	CACHE_REPORT_ERROR("coh_msg get fwd out", fwd_out.coh_msg);
	CACHE_REPORT_ERROR("coh_msg get fwd out gold", coh_msg);
	CACHE_REPORT_ERROR("addr get fwd out", fwd_out.addr);
	CACHE_REPORT_ERROR("addr get fwd out gold", addr.range(TAG_RANGE_HI, SET_RANGE_LO));
	CACHE_REPORT_ERROR("req_id get fwd out", fwd_out.req_id);
	CACHE_REPORT_ERROR("req_id get fwd out gold", req_id);
	CACHE_REPORT_ERROR("dest_id get fwd out", fwd_out.dest_id);
	CACHE_REPORT_ERROR("dest_id get fwd out gold", dest_id);
    }
    if (rpt)
	CACHE_REPORT_VAR(sc_time_stamp(), "FWD_OUT", fwd_out);
}

void llc_tb::get_mem_req(bool hwrite, addr_t addr, line_t line, bool rpt)
{
    llc_mem_req_t mem_req;
    mem_req = llc_mem_req_tb.get();

    if (mem_req.hwrite != hwrite ||
	mem_req.addr   != addr.range(TAG_RANGE_HI, SET_RANGE_LO)   ||
	mem_req.line   != line) {
	
	CACHE_REPORT_ERROR("get mem req", mem_req.hwrite);
	CACHE_REPORT_ERROR("get mem req gold", hwrite);
	CACHE_REPORT_ERROR("get mem req", mem_req.addr);
	CACHE_REPORT_ERROR("get mem req gold", addr.range(TAG_RANGE_HI, SET_RANGE_LO));
	CACHE_REPORT_ERROR("get mem req", mem_req.line);
	CACHE_REPORT_ERROR("get mem req gold", line);
    }
    if (rpt)
	CACHE_REPORT_VAR(sc_time_stamp(), "MEM_REQ", mem_req);
}

void llc_tb::put_mem_rsp(line_t line, bool rpt)
{
    llc_mem_rsp_t mem_rsp;
    mem_rsp.line = line;

    rand_wait();

    llc_mem_rsp_tb.put(mem_rsp);

    if (rpt)
	CACHE_REPORT_VAR(sc_time_stamp(), "MEM_RSP", mem_rsp);
}

void llc_tb::put_req_in(coh_msg_t coh_msg, addr_t addr, line_t line, cache_id_t req_id, bool rpt)
{
    llc_req_in_t req_in;
    req_in.coh_msg = coh_msg;
    req_in.hprot = HPROT_DATA;
    req_in.addr = addr.range(TAG_RANGE_HI, SET_RANGE_LO);
    req_in.line = line;
    req_in.req_id = req_id;

    rand_wait();

    llc_req_in_tb.put(req_in);

    if (rpt)
	CACHE_REPORT_VAR(sc_time_stamp(), "REQ_IN", req_in);
}

void llc_tb::put_rsp_in(addr_t addr, line_t line, cache_id_t req_id, bool rpt)
{
    llc_rsp_in_t rsp_in;
    rsp_in.addr = addr.range(TAG_RANGE_HI, SET_RANGE_LO);
    rsp_in.line = line;
    rsp_in.req_id = req_id;

    rand_wait();

    llc_rsp_in_tb.put(rsp_in);

    if (rpt)
	CACHE_REPORT_VAR(sc_time_stamp(), "RSP_IN", rsp_in);
}
