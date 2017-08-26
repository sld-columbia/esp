/* Copyright 2017 Columbia University, SLD Group */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "llc_tb.hpp"


/*
 * Processes
 */

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
    const hprot_t empty_hprot = 0;
    const addr_t empty_addr = 0;

    // preparation variables
    addr_breakdown_t addr_base, addr, addr_evict;
    word_t word, word_tmp;
    line_t line;

    /*
     * Reset
     */

    reset_llc_test();

    /*
     * T0) 1 CPU. No eviction. Test all possible internal states of LLC. 
     */

    CACHE_REPORT_INFO("T0) 1 CPU. NO EVICTION. TEST ALL POSSIBLE INTERNAL STATES OF LLC.");

    addr_base = rand_addr();
    addr = addr_base; addr_evict = addr_base;

    CACHE_REPORT_INFO("T0.1)");
    // fill a set with exclusive and modified states with GetS and GetM
    for (int i = 0; i < LLC_WAYS/2; ++i) {
    	op(REQ_GETS, INVALID, 0, addr, addr_evict, 0, make_line_of_addr(addr.line), 0, RPT_TB);
	addr.tag_incr(1);
    	op(REQ_GETM, INVALID, 0, addr, addr_evict, 0, make_line_of_addr(addr.line), 0, RPT_TB);
	addr.tag_incr(1);
    }
    
    CACHE_REPORT_INFO("T0.2)");
    // fill half of a different set with exclusive and modified states
    addr.set_incr(10);
    for (int i = 0; i < LLC_WAYS/4; ++i) {
    	op(REQ_GETS, INVALID, 0, addr, addr_evict, 0, make_line_of_addr(addr.line), 0, RPT_TB);
	addr.tag_incr(1);
    	op(REQ_GETM, INVALID, 0, addr, addr_evict, 0, make_line_of_addr(addr.line), 0, RPT_TB);
	addr.tag_incr(1);
    }

    CACHE_REPORT_INFO("T0.3)");
    // put back all of the ways in the first set with PutS and PutM
    addr.set_decr(10);
    addr.tag_decr(LLC_WAYS/2);
    for (int i = 0; i < LLC_WAYS/4; ++i) {
	addr.tag_decr(1);
    	op(REQ_PUTM, MODIFIED, 0, addr, addr_evict, 0xcace, 0, 0, RPT_TB);
	addr.tag_decr(1);
    	op(REQ_PUTS, EXCLUSIVE, 0, addr, addr_evict, 0, 0, 0, RPT_TB);
    }
    for (int i = 0; i < LLC_WAYS/4; ++i) {
	addr.tag_decr(1);
    	op(REQ_PUTM, MODIFIED, 0, addr, addr_evict, 0xcace, 0, 0, RPT_TB);
	addr.tag_decr(1);
    	op(REQ_PUTM, EXCLUSIVE, 0, addr, addr_evict, 0xcace, 0, 0, RPT_TB);
    }

    CACHE_REPORT_INFO("T0.4)");
    // put back 2 lines of the second set
    addr.set_incr(10);
    addr.tag_incr(LLC_WAYS);
    op(REQ_PUTS, EXCLUSIVE, 0, addr, addr_evict, 0, 0, 0, RPT_TB);
    addr.tag_incr(1);
    op(REQ_PUTM, MODIFIED, 0, addr, addr_evict, 0xcace, 0, 0, RPT_TB);

    CACHE_REPORT_INFO("T0.5)");
    // from the same set get 1 INVALID and 1 INVALID_NOT_EMPTY
    op(REQ_GETS, INVALID_NOT_EMPTY, 0, addr, addr_evict, 0, 0xcace, 0, RPT_TB);
    addr.tag_incr(LLC_WAYS/2);
    op(REQ_GETM, INVALID, 0, addr, addr_evict, 0, make_line_of_addr(addr.line), 0, RPT_TB);

    CACHE_REPORT_INFO("T0.6)");
    // get all INVALID_NOT_EMPTY from the first set
    addr.set_decr(10);
    addr.tag_decr(LLC_WAYS + 1 + LLC_WAYS/2);
    for (int i = 0; i < LLC_WAYS/4; ++i) {
    	op(REQ_GETM, INVALID_NOT_EMPTY, 0, addr, addr_evict, 0, 0xcace, 0, RPT_TB);
	addr.tag_incr(1);
    	op(REQ_GETS, INVALID_NOT_EMPTY, 0, addr, addr_evict, 0, 0xcace, 0, RPT_TB);
	addr.tag_incr(1);
    }
    for (int i = 0; i < LLC_WAYS/4; ++i) {
    	op(REQ_GETM, INVALID_NOT_EMPTY, 0, addr, addr_evict, 0, make_line_of_addr(addr.line), 0, RPT_TB);
	addr.tag_incr(1);
    	op(REQ_GETS, INVALID_NOT_EMPTY, 0, addr, addr_evict, 0, 0xcace, 0, RPT_TB);
	addr.tag_incr(1);
    }

    /*
     * T1) 1 CPU. Eviction.
     */

    CACHE_REPORT_INFO("T1) 1 CPU. EVICTION.");

    CACHE_REPORT_INFO("T1.1)");

    // cause LLC_WAYS + 2 invalidations on a new set
    addr.set_incr(11);
    addr_evict = addr;
    for (int i = 0; i < LLC_WAYS; ++i) {
    	op(REQ_GETS, INVALID, 0, addr, addr_evict, 0, make_line_of_addr(addr.line), 0, RPT_TB);
	addr.tag_incr(1);
    }

    CACHE_REPORT_INFO("T1.2)");
    for (int i = 0; i < LLC_WAYS/2; ++i) {
	op(REQ_PUTS, EXCLUSIVE, 0, addr_evict, addr_evict, 0, 0, 0, RPT_TB);
    	op(REQ_GETS, INVALID, 1, addr, addr_evict, 0, make_line_of_addr(addr.line), make_line_of_addr(addr_evict.line), RPT_TB);
	addr.tag_incr(1); addr_evict.tag_incr(1);
	op(REQ_PUTS, EXCLUSIVE, 0, addr_evict, addr_evict, 0, 0, 0, RPT_TB);
    	op(REQ_GETM, INVALID, 1, addr, addr_evict, 0, make_line_of_addr(addr.line), make_line_of_addr(addr_evict.line), RPT_TB);
	addr.tag_incr(1); addr_evict.tag_incr(1);
    }


    // End simulation
    sc_stop();
}

/*
 * Functions
 */

inline void llc_tb::reset_llc_test()
{
    llc_req_in_tb.reset();
    llc_rsp_in_tb.reset();
    llc_mem_rsp_tb.reset();
    llc_rsp_out_tb.reset();
    llc_fwd_out_tb.reset();
    llc_mem_req_tb.reset();

    wait();
}

void llc_tb::op(coh_msg_t coh_msg, llc_state_t state, bool evict, addr_breakdown_t req_addr, 
		addr_breakdown_t evict_addr, line_t req_line, line_t rsp_line, line_t evict_line, bool rpt)
{
    wait();

    coh_msg_t rsp_out_msg = 0;

    switch (coh_msg) {
    case REQ_GETS :
	switch (state) {
	case INVALID :
	case INVALID_NOT_EMPTY :
	    rsp_out_msg = RSP_EDATA;
	    break;
	}
	break;
    case REQ_GETM :
	switch (state) {
	case INVALID :
	case INVALID_NOT_EMPTY :
	    rsp_out_msg = RSP_DATA;
	    break;
	}
	break;
    case REQ_PUTS :
	switch (state) {
	case EXCLUSIVE :
	    rsp_out_msg = RSP_PUTACK;
	    break;
	}
	break;
    case REQ_PUTM :
	switch (state) {
	case EXCLUSIVE :
	case MODIFIED :
	    rsp_out_msg = RSP_PUTACK;
	    break;
	}
	break;
    }

    put_req_in(coh_msg, req_addr.line, req_line, 0, rpt);

    wait();

    if (evict) {
    	get_mem_req(LLC_WRITE, evict_addr.line, evict_line, rpt);
    	wait();
    }

    if (state == INVALID || evict) {
    	get_mem_req(LLC_READ, req_addr.line, 0, rpt);

    	wait();

    	put_mem_rsp(rsp_line, rpt);

    	wait();
    }

    wait();

    get_rsp_out(rsp_out_msg, req_addr.line, rsp_line, 0, 0, 0, rpt);

    wait();
}

void llc_tb::get_rsp_out(coh_msg_t coh_msg, addr_t addr, line_t line, invack_cnt_t invack_cnt,
			 cache_id_t req_id, cache_id_t dest_id, bool rpt)
{
    wait();

    llc_rsp_out_t rsp_out;
    llc_rsp_out_tb.get(rsp_out);

    wait();

    if (rsp_out.coh_msg != coh_msg       ||
	rsp_out.addr   != addr           ||
	rsp_out.line   != line           ||
	// rsp_out.invack_cnt != invack_cnt ||
	rsp_out.req_id != req_id
	// rsp_out.dest_id != dest_id
	) {
	
	CACHE_REPORT_ERROR("coh_msg get rsp out", rsp_out.coh_msg);
	CACHE_REPORT_ERROR("coh_msg get rsp out gold", coh_msg);
	CACHE_REPORT_ERROR("addr get rsp out", rsp_out.addr);
	CACHE_REPORT_ERROR("addr get rsp out gold", addr);
	CACHE_REPORT_ERROR("line get rsp out", rsp_out.line);
	CACHE_REPORT_ERROR("line get rsp out gold", line);
	// CACHE_REPORT_ERROR("invack_cnt get rsp out", rsp_out.invack_cnt);
	// CACHE_REPORT_ERROR("invack_cnt get rsp out gold", invack_cnt);
	CACHE_REPORT_ERROR("req_id get rsp out", rsp_out.req_id);
	CACHE_REPORT_ERROR("req_id get rsp out gold", req_id);
	// CACHE_REPORT_ERROR("dest_id get rsp out", rsp_out.dest_id);
	// CACHE_REPORT_ERROR("dest_id get rsp out gold", dest_id);
    }
    if (rpt)
	CACHE_REPORT_VAR(sc_time_stamp(), "RSP_OUT", rsp_out);
}

void llc_tb::get_mem_req(bool hwrite, addr_t addr, line_t line, bool rpt)
{
    wait();

    llc_mem_req_t mem_req;
    mem_req = llc_mem_req_tb.get();

    wait();

    if (mem_req.hwrite != hwrite ||
	mem_req.addr   != addr   ||
	mem_req.line   != line) {
	
	CACHE_REPORT_ERROR("get mem req", mem_req.hwrite);
	CACHE_REPORT_ERROR("get mem req gold", hwrite);
	CACHE_REPORT_ERROR("get mem req", mem_req.addr);
	CACHE_REPORT_ERROR("get mem req gold", addr);
	CACHE_REPORT_ERROR("get mem req", mem_req.line);
	CACHE_REPORT_ERROR("get mem req gold", line);
    }
    if (rpt)
	CACHE_REPORT_VAR(sc_time_stamp(), "MEM_REQ", mem_req);

    wait();
}

void llc_tb::put_mem_rsp(line_t line, bool rpt)
{
    wait();

    llc_mem_rsp_t mem_rsp;
    mem_rsp.line = line;

    rand_wait();

    llc_mem_rsp_tb.put(mem_rsp);

    if (rpt)
	CACHE_REPORT_VAR(sc_time_stamp(), "MEM_RSP", mem_rsp);

    wait();
}

void llc_tb::put_req_in(coh_msg_t coh_msg, addr_t addr, line_t line, cache_id_t req_id, bool rpt)
{
    wait();

    llc_req_in_t req_in;
    req_in.coh_msg = coh_msg;
    req_in.hprot = DEFAULT_HPROT | CACHEABLE_MASK;
    req_in.addr = addr;
    req_in.line = line;
    req_in.req_id = req_id;

    rand_wait();

    llc_req_in_tb.put(req_in);

    if (rpt)
	CACHE_REPORT_VAR(sc_time_stamp(), "REQ_IN", req_in);

    wait();
}
