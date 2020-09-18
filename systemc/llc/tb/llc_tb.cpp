// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
 
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "llc_tb.hpp"

#define L2_SETS LLC_SETS

/*
 * Processes
 */

// #ifdef LLC_DEBUG

// void llc_tb::llc_debug()
// {
//     sc_bv<LLC_ASSERT_WIDTH>   old_asserts  = 0;
//     sc_bv<LLC_ASSERT_WIDTH>   new_asserts  = 0;
//     sc_bv<LLC_BOOKMARK_WIDTH> old_bookmark = 0;
//     sc_bv<LLC_BOOKMARK_WIDTH> new_bookmark = 0;
//     uint32_t old_custom_dbg = 0;
//     uint32_t new_custom_dbg = 0;

//     while(true) {
// 	new_asserts = asserts.read();
// 	new_bookmark = bookmark.read();
// 	new_custom_dbg = custom_dbg.read();

// 	if (old_asserts != new_asserts) {
// 	    old_asserts = new_asserts;
// 	    CACHE_REPORT_DEBUG(sc_time_stamp(), "assert", new_asserts);
// 	}

// 	if (old_bookmark != new_bookmark) {
// 	    old_bookmark = new_bookmark;
// 	    if (RPT_BM) CACHE_REPORT_DEBUG(sc_time_stamp(), "bookmark", new_bookmark);
// 	}

// 	if (old_custom_dbg != new_custom_dbg) {
// 	    old_custom_dbg = new_custom_dbg;
// 	    if (RPT_CU) CACHE_REPORT_DEBUG(sc_time_stamp(), "custom_dbg", new_custom_dbg);
// 	}
	
// 	wait();
//     }
// }

// #endif

#ifdef STATS_ENABLE
void llc_tb::get_stats()
{
    llc_stats_tb.reset_get();

    wait();

    while(true) {
	
	bool tmp;

	llc_stats_tb.get(tmp);

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
    const hprot_t empty_hprot = INSTR;

    // constant
    const bool is_flush = true;
    const bool is_reset = false;

    // preparation variables
    addr_breakdown_llc_t addr_base, addr, addr_evict, null;
    null.breakdown(0);
    word_t word, word_tmp;
    line_t line;

    unsigned int n_l2 = 1;
    unsigned int l2_ways = 1;

    const unsigned int MIN_L2 = 4;
    const unsigned int MIN_WAYS = 4;

    bool tmp_rst_tb;

    /*
     * Configuration
     */

    switch (LLC_WAYS) {

    case 4:

	n_l2 = 4;
	l2_ways = 1;
	break;

    case 8:

	n_l2 = 4;
	l2_ways = 2;
	break;

    case 16:

	n_l2 = 4;
	l2_ways = 4;
	break;

    case 32:

	n_l2 = 4;
	l2_ways = 8;
	break;

    default:

	CACHE_REPORT_INFO("ERROR: LLC_WAYS not supported.");
    }

    /*
     * Reset
     */

    CACHE_REPORT_INFO("Reset LLC.");

    reset_llc_test();

    bool rst_tmp;
    llc_rst_tb_done_tb.get(rst_tmp);
    wait();

    reset_dut(is_reset);

    addr_base = rand_addr_llc();

    /*
     * Test all corners of our version of the MESI protocol
     */
    CACHE_REPORT_INFO("T0) FULL TEST OF COHERENCE PROTOCOL.");


    /* Invalid state. No eviction. */

    /* Results:
     * - set x,   way 0:    S, sharers = l2#0, line_of_addr, instr
     * - set x,   way 1:    E, owner   = l2#1, line_of_addr, data
     * - set x,   way 2:    M, owner   = l2#2, line_of_addr, data
     * - set x,   way 3:    V,                 line_of_addr, data
     * - set x+1, way 0123: V,                 line_of_addr, data, dirty
     */

    CACHE_REPORT_INFO("T0.0) Invalid state. No eviction.");

    addr = addr_base;

    // PutS. I -> I. l2#0.
    op(REQ_PUTS, INVALID, 0, addr, null, 0, 0, 0, 0, 0, 0, INSTR);

    // PutM. I -> I. l2#1.
    op(REQ_PUTM, INVALID, 0, addr, null, line_of_addr(addr.line), 0, 0, 0, 1, 1, DATA);

    // GetS, opcode. I -> S. l2#0. No evict.
    op(REQ_GETS, INVALID, 0, addr, null, 0, line_of_addr(addr.line), 0, 0, 0, 0, INSTR);
    addr.tag_incr(1);

    // GetS, data. I -> E. l2#1. No evict.
    op(REQ_GETS, INVALID, 0, addr, null, 0, line_of_addr(addr.line), 0, 0, 1, 0, DATA);
    addr.tag_incr(1);

    // GetM, opcode. Not possible.

    // GetM, data. I -> M. l2#2. No evict.
    op(REQ_GETM, INVALID, 0, addr, null, 0, line_of_addr(addr.line), 0, 0, 2, 0, DATA);
    addr.tag_incr(1);

    // DMAread, opcode. Not possible

    // DMAread, data. I -> V. l2#3. No evict.
    op_dma(DMA_READ, INVALID, 0, 0, addr, null, 4, line_of_addr(addr.line), 0, 0, 0, 0);
    addr.set_incr(1);

    // DMAwrite, opcode. Not possible

    // DMAwrite, data. I -> V. l2#0123. No evict.
    for (int i = 0; i < MIN_L2; i++) {
    	op_dma(DMA_WRITE, INVALID, 0, 0, addr, null, line_of_addr(addr.line), 4, 0, 0, 0, 0);
        addr.tag_incr(1);
    }

    /* Valid state. */

    /* Results:
     * - set x,   way 3: S, sharers = l2#0, line_of_addr, data
     * - set x+1, way 0: E, sharers = l2#1, line_of_addr, data, dirty 
     * - set x+1, way 1: M, owner   = l2#2, line_of_addr, data, dirty
     * - set x+1, way 2: V,                 line_of_addr, data, dirty
     * - set x+1, way 3: V,                 0xabcd0e0f0 , data, dirty
     */

    CACHE_REPORT_INFO("T0.1) Valid state.");

    addr = addr_base;
    addr.tag_incr(3);

    // PutS. V -> V. l2#0.
    op(REQ_PUTS, VALID, 0, addr, null, 0, 0, 0, 0, 0, 0, INSTR);

    // PutM. V -> V. l2#1.
    op(REQ_PUTM, VALID, 0, addr, null, 0xabcd0e0f0, 0, 0, 0, 1, 1, DATA);

    // GetS, opcode. V -> S. l2#0. No evict.
    op(REQ_GETS, VALID, 0, addr, null, 0, line_of_addr(addr.line), 0, 0, 0, 0, INSTR);
    addr.set_incr(1);

    // GetS, data. V -> E. l2#1. No evict.
    op(REQ_GETS, VALID, 0, addr, null, 0, line_of_addr(addr.line), 0, 0, 1, 0, DATA);
    addr.tag_incr(1);

    // GetM, opcode. Not possible.

    // GetM, data. V -> M. l2#2. No evict.
    op(REQ_GETM, VALID, 0, addr, null, 0, line_of_addr(addr.line), 0, 0, 2, 0, DATA);
    addr.tag_incr(1);

    // DMAread, opcode. Not possible

    // DMAread, data. V -> V. l2#3. No evict.
    op_dma(DMA_READ, VALID, 0, 0, addr, null, 4, line_of_addr(addr.line), 0, 0, 0, 0);
    addr.tag_incr(1);

    // DMAwrite, opcode. Not possible

    // DMAwrite, data. V -> V. l2#0. No evict.
    op_dma(DMA_WRITE, VALID, 0, 0, addr, null, 0xabcd0e0f0, 4, 0, 0, 0, 0);


    /* Shared state. */

    /* Results:
     * - set x,   way 0: V,                 line_of_addr
     * - set x,   way 3: S, sharers = cpu0, line_of_addr
     * - set x+1, way 0: V,                 line_of_addr, dirty
     */

    CACHE_REPORT_INFO("T0.2) Shared state.");

    addr = addr_base;

    // GetS, opcode. S -> S. Sharers l2#0123
    for (int j = 1; j < MIN_L2; j++) {
    	op(REQ_GETS, SHARED, 0, addr, null, 0, line_of_addr(addr.line), 0, 0, j, 0, INSTR);
    }

    // PutS, opcode. S -> V. 
    for (int j = MIN_L2 - 1; j >= 0; j--) {
    	op(REQ_PUTS, SHARED, 0, addr, null, 0, 0, 0, 0, j, j, INSTR);
    }

    addr.tag_incr(3);

    // GetS, data. S -> S. Sharers l2#0123
    for (int j = 1; j < MIN_L2; j++) {
    	op(REQ_GETS, SHARED, 0, addr, null, 0, line_of_addr(addr.line), 0, 0, j, 0, DATA);
    }

    // GetM, data. S -> M. l2#0.
    op(REQ_GETM, SHARED, 0, addr, null, 0, line_of_addr(addr.line), 0, MIN_L2-1, MIN_L2-1, 0, DATA);

    addr.set_incr(1);

    // GetS, data. S -> S. Sharers l2#123
    op(REQ_GETS, EXCLUSIVE, 0, addr, null, 0, line_of_addr(addr.line), 0, 0, 2, 1, DATA);
    op_rsp(RSP_DATA, addr, line_of_addr(addr.line), 1);
    for (int j = 3; j < MIN_L2; j++) {
    	op(REQ_GETS, SHARED, 0, addr, null, 0, line_of_addr(addr.line), 0, 0, j, 0, DATA);
    }

    // PutM, data. S -> V. 
    for (int j = 1; j < MIN_L2; j++) {
    	op(REQ_PUTM, SHARED, 0, addr, null, 0, 0, 0, 0, j, j, DATA);
    }


    /* Modified state. */

    /* Results:
     * - set x,   way 2: SD, sharers = l2#23, line_of_addr  , data
     * - set x,   way 3: V ,                  line_of_addr*2, data, dirty
     * - set x+1, way 1: M , owner   = l2#2,  line_of_addr  , data, dirty
     */

    CACHE_REPORT_INFO("T0.3) Modified state.");

    addr = addr_base;

    addr.tag_incr(2);

    // GetS, data. M -> SD. Sharers l2#23
    op(REQ_GETS, MODIFIED, 0, addr, null, 0, line_of_addr(addr.line), 0, 0, 3, 2, DATA);
    addr.tag_incr(1);

    // GetM, data. M -> M. Owner l2#0. 
    op(REQ_GETM, MODIFIED, 0, addr, null, 0, 0, 0, 0, 0, 3, DATA);

    // PutM, data. M -> M. Non owner
    op(REQ_PUTM, MODIFIED, 0, addr, null, 0xeeeeeeeee, 0, 0, 0, 2, 2, DATA);

    // PutM, data. M -> V. Owner
    op(REQ_PUTM, MODIFIED, 0, addr, null, line_of_addr(addr.line)*2, 0, 0, 0, 0, 0, DATA);

    addr.set_incr(1);

    // PutS, data. M -> S.
    op(REQ_PUTS, SHARED, 0, addr, null, 0, 0, 0, 0, 1, 1, DATA);


    /* Exclusive state. */

    /* Results:
     * - set x,   way 0: SD, sharers = l2#02, line_of_addr, data
     * - set x,   way 1: M , owner   = l2#3 , line_of_addr, data
     * - set x,   way 3: V ,                  line_of_addr*2, data, dirty
     * - set x+1, way 0: V ,                  line_of_addr*2, data, dirty
     */

    CACHE_REPORT_INFO("T0.4) Exclusive state.");

    addr = addr_base;

    // GetS, data. V -> E. Owner l2#0. line_of_addr
    op(REQ_GETS, VALID, 0, addr, null, 0, line_of_addr(addr.line), 0, 0, 0, 0, DATA);

    // GetS, data. E -> SD. Sharers l2#02. line_of_addr
    op(REQ_GETS, EXCLUSIVE, 0, addr, null, 0, line_of_addr(addr.line), 0, 0, 2, 0, DATA);

    addr.tag_incr(1);

    // GetM, data. M -> M. Owner l2#1 -> l2#3. 
    op(REQ_GETM, EXCLUSIVE, 0, addr, null, 0, line_of_addr(addr.line), 0, 0, 3, 1, DATA);
  
    addr.tag_incr(2);

    // GetS, data. V -> E. Owner l2#2. line_of_addr
    op(REQ_GETS, VALID, 0, addr, null, 0, line_of_addr(addr.line)*2, 0, 0, 2, 0, DATA);

    // PutS, data. E -> E. Not owner, owner is 2.
    op(REQ_PUTS, EXCLUSIVE, 0, addr, null, 0, 0, 0, 0, 0, 0, DATA);

    // PutS, data. E -> V. Owner (2).
    op(REQ_PUTS, EXCLUSIVE, 0, addr, null, 0, 0, 0, 0, 2, 2, DATA);

    addr.set_incr(1);

    // GetS, data. V -> E. Owner l2#3. line_of_addr
    op(REQ_GETS, VALID, 0, addr, null, 0, line_of_addr(addr.line), 0, 0, 3, 0, DATA);

    // PutM, data. M -> M. Non owner, owner is 3.
    op(REQ_PUTM, MODIFIED, 0, addr, null, 0xeeeeeeeee, 0, 0, 0, 2, 2, DATA);

    // PutM, data. M -> V. Owner (3).
    op(REQ_PUTM, MODIFIED, 0, addr, null, line_of_addr(addr.line)*2, 0, 0, 0, 3, 3, DATA);


    /* SD state. */

    /* Results:
     * - set x,   way 0: S, sharers = l2#1, 0xabcd0e0f0, instr
     * - set x,   way 2: M, owner   = l2#0, 0xabcd0e0f0, data
     */

    CACHE_REPORT_INFO("T0.5) SD state.");

    addr = addr_base;

    // PutS, data. SD -> SD. Sharers 02 -> 0
    op(REQ_PUTS, SD, 0, addr, null, 0, 0, 0, 0, 2, 2, DATA);

    addr.tag_incr(2);

    // PutM, data. SD -> SD. Sharers 23 -> 3
    op(REQ_PUTM, SD, 0, addr, null, 0xeeeeeeeee, 0, 0, 0, 2, 2, DATA);

    // PutM, data. SD -> SD. Sharers 3 -> none
    op(REQ_PUTM, SD, 0, addr, null, 0xeeeeeeeee, 0, 0, 0, 3, 3, DATA);

    addr.tag_decr(2);

    // GetS stall
    // GetS + Data. SD -> S -> S. Sharers 01. Instr
    put_req_in(FWD_GETS, addr.line, 0, 1, INSTR, 0, 0);

    op_rsp(RSP_DATA, addr, 0xabcd0e0f0, 1);

    get_rsp_out(RSP_DATA, addr.line, 0xabcd0e0f0, 0, 1, 0, 0);

    addr.tag_incr(2);

    wait();

    // Get stall operation
    // GetM + Data. SD -> V -> M. Owner 0.
    put_req_in(FWD_GETM, addr.line, 0, 0, DATA, 0, 0);

    op_rsp(RSP_DATA, addr, 0xabcd0e0f0, 0);

    get_rsp_out(RSP_DATA, addr.line, 0xabcd0e0f0, 0, 0, 0, 0);

    wait();


    CACHE_REPORT_INFO("T0.6) Flush.");

    /* Flush */

    /* Current status:
     * - set x,   way 0: S, sharers = l2#1, 0xabcd0e0f0 , instr
     * - set x,   way 1: M, owner   = l2#3, line_of_addr, data
     * - set x,   way 2: M, owner   = l2#0, 0xabcd0e0f0 , data
     * - set x,   way 3: V,                 line_of_addr*2, data, dirty
     * - set x+1, way 0: V,                 line_of_addr*2, data, dirty
     * - set x+1, way 1: M, owner   = l2#2, line_of_addr, data, dirty
     * - set x+1, way 2: V,                 line_of_addr, data, dirty
     * - set x+1, way 3: V,                 0xabcd0e0f0 , data, dirty
     *
     * Flush only acts on VALID lines containing data, updating them to 
     * INVALID and writing to main memory if the line is dirty.
     */

    addr = addr_base;

    // reset_dut(is_flush);

    // start partial flush
    llc_rst_tb_tb.put(is_flush);

    // only 4 lines are written back
    addr.tag_incr(3);

    get_mem_req(LLC_WRITE, addr.line, line_of_addr(addr.line)*2);

    addr.set_incr(1); wait();

    get_mem_req(LLC_WRITE, addr.line, line_of_addr(addr.line)*2);

    addr.tag_incr(2); wait();

    get_mem_req(LLC_WRITE, addr.line, line_of_addr(addr.line));

    addr.tag_incr(1); wait();

    get_mem_req(LLC_WRITE, addr.line, 0xabcd0e0f0);

    llc_rst_tb_done_tb.get(tmp_rst_tb);

    CACHE_REPORT_INFO("T0.7) Verify status of remaining lines.");

    /* Changed lines
     * - set x,   way 3: I
     * - set x+1, way 0: I
     * - set x+1, way 2: I
     * - set x+1, way 3: I
     */

    // check that the remaining lines are still in place
    addr = addr_base;

    // GetM, only sharer l2#1. No invack_cnt. S -> M
    op(REQ_PUTS, SHARED, 0, addr, null, 0, 0, 0, 0, 0, 0, DATA);

    op(REQ_GETM, SHARED, 0, addr, null, 0, 0xabcd0e0f0, 0, 0, 1, 0, DATA);
    
    // PutM, data. M -> V. Owner
    op(REQ_PUTM, MODIFIED, 0, addr, null, line_of_addr(addr.line)*2, 0, 0, 0, 1, 1, DATA);

    addr.tag_incr(1);    

    // PutM, data. M -> V. Owner
    op(REQ_PUTM, MODIFIED, 0, addr, null, line_of_addr(addr.line)*2, 0, 0, 0, 3, 3, DATA);

    addr.tag_incr(1);    

    // PutM, data. M -> V. Owner
    op(REQ_PUTM, MODIFIED, 0, addr, null, line_of_addr(addr.line)*2, 0, 0, 0, 0, 0, DATA);

    addr.tag_incr(2);
    addr.set_incr(1);

    // PutM, data. M -> V. Owner
    op(REQ_PUTM, MODIFIED, 0, addr, null, line_of_addr(addr.line)*2, 0, 0, 0, 2, 2, DATA);

    /* Changed lines:
     * - set x,   way 0: V, line_of_addr(addr.line)*2, instr
     * - set x,   way 1: V, line_of_addr(addr.line)*2, data, dirty
     * - set x,   way 2: V, line_of_addr(addr.line)*2, data, dirty
     * - set x+1, way 1: V, line_of_addr(addr.line)*2, data, dirty
     * - set x+1, way 2: V, line_of_addr(addr.line)*2, data, dirty
     */

    addr = addr_base;

    // start partial flush
    llc_rst_tb_tb.put(is_flush);

    // get_mem_req(LLC_WRITE, addr.line, 0xabcd0e0f0);
    get_mem_req(LLC_WRITE, addr.line, line_of_addr(addr.line)*2);

    addr.tag_incr(1); wait();

    get_mem_req(LLC_WRITE, addr.line, line_of_addr(addr.line)*2);

    addr.tag_incr(1); wait();

    get_mem_req(LLC_WRITE, addr.line, line_of_addr(addr.line)*2);

    addr.tag_incr(2);
    addr.set_incr(1); wait();

    get_mem_req(LLC_WRITE, addr.line, line_of_addr(addr.line)*2);

    llc_rst_tb_done_tb.get(tmp_rst_tb);

    wait();
    
    /* Changed lines:
     * - set x,   way 1: I
     * - set x,   way 2: I
     * - set x+1, way 1: I
     * - set x+1, way 2: I
     */

    // Now all lines in the cache are INVALID.
    
    llc_rst_tb_tb.put(is_reset); // there's one line that cannot be flushed, it's opcode.

    llc_rst_tb_done_tb.get(tmp_rst_tb);

    /* Eviction */    

    CACHE_REPORT_INFO("T0.8) Eviction.");

    addr_breakdown_llc_t addr1 = addr_base;
    addr_breakdown_llc_t addr2 = addr_base;
    addr_breakdown_llc_t addr_new = addr_base;
    addr_evict = addr_base;
    llc_way_t evict_way = 0;

    // GetS evicts VALID line, not dirty
    for (int i = 0; i < LLC_WAYS; i++) {
    	op(REQ_GETS, INVALID, 0, addr1, null, 0, line_of_addr(addr1.line), 0, 0, 0, 0, DATA);
    	addr1.tag_incr(1);
    }

    addr2.tag_incr(3);
    op(REQ_PUTS, SHARED, 0, addr2, null, 0, 0, 0, 0, 0, 0, DATA);

    op(REQ_GETS, INVALID, 0, addr1, null, 0, line_of_addr(addr1.line), 0, 0, 0, 0, DATA); // evict
    
    // GetS evicts VALID line, dirty
    op(REQ_PUTM, EXCLUSIVE, 0, addr1, null, line_of_addr(addr1.line)*2, 0, 0, 0, 0, 0, DATA);

    op(REQ_GETS, INVALID, EVICT, addr2, addr1, 0, line_of_addr(addr2.line), 
       line_of_addr(addr1.line)*2, 0, 0, 0, DATA);

    // GetM evicts VALID line, not dirty
    op(REQ_PUTS, EXCLUSIVE, 0, addr2, null, 0, 0, 0, 0, 0, 0, DATA);

    op(REQ_GETM, INVALID, 0, addr1, null, 0, line_of_addr(addr1.line), 0, 0, 0, 0, DATA); // evict

    // GetM evicts VALID line, dirty
    op(REQ_PUTM, EXCLUSIVE, 0, addr1, null, line_of_addr(addr1.line)*2, 0, 0, 0, 0, 0, DATA);

    op(REQ_GETS, INVALID, EVICT, addr2, addr1, 0, line_of_addr(addr2.line), 
       line_of_addr(addr1.line)*2, 0, 0, 0, DATA);

    // DMA_Read evicts VALID line, not dirty
    op(REQ_PUTS, EXCLUSIVE, 0, addr2, null, 0, 0, 0, 0, 0, 0, DATA);

    op_dma(DMA_READ, VALID, EVICT, 0, addr1, addr2, 4, line_of_addr(addr1.line), 0, 0, 0, 0);
    
    // DMA_Read evicts VALID line, dirty
    op_dma(DMA_WRITE, VALID, 0, 0, addr1, null, line_of_addr(addr1.line)*2, 4, 0, 0, 0, 0);

    op_dma(DMA_READ, VALID, EVICT, DIRTY, addr2, addr1, 4, line_of_addr(addr2.line), 
    	   line_of_addr(addr1.line)*2, 0, 0, 0);

    op(REQ_GETS, VALID, 0, addr2, null, 0, line_of_addr(addr2.line), 0, 0, 0, 0, DATA);

    // DMA_Write evicts VALID line, not dirty
    op(REQ_PUTS, EXCLUSIVE, 0, addr2, null, 0, 0, 0, 0, 0, 0, DATA);

    op_dma(DMA_WRITE, VALID, EVICT, 0, addr1, addr2, line_of_addr(addr1.line)*2, 4, 0, 0, 0, 0);

    // DMA_Write evicts VALID line, dirty
    op_dma(DMA_WRITE, VALID, EVICT, DIRTY, addr2, addr1, line_of_addr(addr2.line), 4,
    	   line_of_addr(addr1.line)*2, 0, 0, 0);

    op(REQ_GETS, VALID, 0, addr2, null, 0, line_of_addr(addr2.line), 0, 0, 0, 0, INSTR);

    // all lines in this set are exclusive and not dirty

    // DMA_Read evicts SHARED line, not dirty
    regular_evict_prep(addr_base, addr1, addr2, evict_way);

    op(REQ_PUTS, EXCLUSIVE, 0, addr2, null, 0, 0, 0, 0, 0, 0, DATA);

    op(REQ_GETS, VALID, 0, addr2, null, 0, line_of_addr(addr2.line), 0, 0, 0, 0, INSTR);

    op_dma(DMA_READ, SHARED, EVICT, 0, addr1, addr2, 4, line_of_addr(addr1.line), 
    	   0, 1, 0, 0);

    op(REQ_GETS, VALID, 0, addr1, null, 0, line_of_addr(addr1.line), 0, 0, 0, 0, DATA);

    // DMA_Read evicts SHARED line, dirty
    regular_evict_prep(addr_base, addr1, addr2, evict_way);

    op(REQ_PUTS, EXCLUSIVE, 0, addr2, null, 0, 0, 0, 0, 0, 0, DATA);

    op_dma(DMA_WRITE, VALID, 0, 0, addr2, null, line_of_addr(addr2.line)*2, 4, 0, 0, 0, 0);

    op(REQ_GETS, VALID, 0, addr2, null, 0, line_of_addr(addr2.line)*2, 0, 0, 0, 0, INSTR);

    op_dma(DMA_READ, SHARED, EVICT, DIRTY, addr1, addr2, 4, line_of_addr(addr1.line),
    	   line_of_addr(addr2.line)*2, 1, 0, 0);

    op(REQ_GETS, VALID, 0, addr1, null, 0, line_of_addr(addr1.line), 0, 0, 0, 0, DATA);

    // DMA_Read evicts EXCLUSIVE line, not dirty
    regular_evict_prep(addr_base, addr1, addr2, evict_way);

    op_dma(DMA_READ, EXCLUSIVE, EVICT, 0, addr1, addr2, 4, line_of_addr(addr1.line), 0, 1, 0, 0);

    op(REQ_GETS, VALID, 0, addr1, null, 0, line_of_addr(addr1.line), 0, 0, 0, 0, DATA);

    // DMA_Read evicts EXCLUSIVE line, dirty
    regular_evict_prep(addr_base, addr1, addr2, evict_way);

    op(REQ_PUTS, SHARED, 0, addr2, null, 0, 0, 0, 0, 0, 0, DATA);

    op_dma(DMA_WRITE, VALID, 0, 0, addr2, null, line_of_addr(addr2.line)*2, 4, 0, 0, 0, 0);


    op(REQ_GETS, VALID, 0, addr2, null, 0, line_of_addr(addr2.line)*2, 0, 0, 0, 0, DATA);

    op_dma(DMA_READ, EXCLUSIVE, EVICT, DIRTY, addr1, addr2, 4, line_of_addr(addr1.line),
    	   line_of_addr(addr2.line)*2, 1, 0, 0);

    op(REQ_GETS, VALID, 0, addr1, null, 0, line_of_addr(addr1.line), 0, 0, 0, 0, DATA);

    //with 4 ways, new base address after here
    if (LLC_WAYS <= 4){
        addr_new = addr_base;
        addr_new.tag_incr(4);
    }

    // DMA_Read evicts MODIFIED line, not dirty
    regular_evict_prep(addr_new, addr1, addr2, evict_way);

    op(REQ_PUTS, EXCLUSIVE, 0, addr2, null, 0, 0, 0, 0, 0, 0, DATA);

    op(REQ_GETM, VALID, 0, addr2, null, 0, line_of_addr(addr2.line), 0, 0, 0, 0, DATA);

    op_dma(DMA_READ, MODIFIED, EVICT, DIRTY, addr1, addr2, 4, line_of_addr(addr1.line),
    	   0, 1, 0, 0);

    op(REQ_GETS, VALID, 0, addr1, null, 0, line_of_addr(addr1.line), 0, 0, 0, 0, DATA);

    // DMA_Read evicts MODIFIED line, dirty
    regular_evict_prep(addr_new, addr1, addr2, evict_way);

    op(REQ_PUTS, EXCLUSIVE, 0, addr2, null, 0, 0, 0, 0, 0, 0, DATA);

    op_dma(DMA_WRITE, VALID, 0, 0, addr2, null, line_of_addr(addr2.line)*2, 4, 0, 0, 0, 0);

    op(REQ_GETS, VALID, 0, addr2, null, 0, line_of_addr(addr2.line)*2, 0, 0, 0, 0, DATA);

    op_dma(DMA_READ, MODIFIED, EVICT, DIRTY, addr1, addr2, 4, line_of_addr(addr1.line),
    	   line_of_addr(addr2.line)*2, 1, 0, 0);

    op(REQ_GETS, VALID, 0, addr1, null, 0, line_of_addr(addr1.line), 0, 0, 0, 0, DATA);

    // DMA_Write evicts SHARED line, not dirty
    regular_evict_prep(addr_new, addr1, addr2, evict_way);

    op(REQ_PUTS, EXCLUSIVE, 0, addr2, null, 0, 0, 0, 0, 0, 0, DATA);

    op(REQ_GETS, VALID, 0, addr2, null, 0, line_of_addr(addr2.line), 0, 0, 0, 0, INSTR);

    op_dma(DMA_WRITE, SHARED, EVICT, 0, addr1, addr2, line_of_addr(addr1.line)*2, 
    	   4, 0, 1, 0, 0);

    op(REQ_GETS, VALID, 0, addr1, null, 0, line_of_addr(addr1.line)*2, 0, 0, 0, 0, DATA);

    // DMA_Write evicts SHARED line, dirty
    regular_evict_prep(addr_new, addr1, addr2, evict_way);

    op(REQ_PUTS, EXCLUSIVE, 0, addr2, null, 0, 0, 0, 0, 0, 0, DATA);

    op_dma(DMA_WRITE, VALID, 0, 0, addr2, null, line_of_addr(addr2.line)*2,
    	   4, 0, 0, 0, 0);

    op(REQ_GETS, VALID, 0, addr2, null, 0, line_of_addr(addr2.line)*2, 0, 0, 0, 0, INSTR);

    op_dma(DMA_WRITE, SHARED, EVICT, DIRTY, addr1, addr2, line_of_addr(addr1.line),
    	   4, line_of_addr(addr2.line)*2, 1, 0, 0);

    op(REQ_GETS, VALID, 0, addr1, null, 0, line_of_addr(addr1.line), 0, 0, 0, 0, DATA);

    //with 4 or 8 ways, new base address after here
    if (LLC_WAYS <= 8){
        addr_new = addr_base;
        addr_new.tag_incr(8);
    }

    // DMA_Write evicts EXCLUSIVE line, not dirty
    regular_evict_prep(addr_new, addr1, addr2, evict_way);

    op_dma(DMA_WRITE, EXCLUSIVE, EVICT, 0, addr1, addr2, line_of_addr(addr1.line)*2,
    	   4, 0, 1, 0, 0);

    op(REQ_GETS, VALID, 0, addr1, null, 0, line_of_addr(addr1.line)*2, 0, 0, 0, 0, DATA);

    // DMA_Write evicts EXCLUSIVE line, dirty
    regular_evict_prep(addr_new, addr1, addr2, evict_way);

    op(REQ_PUTS, EXCLUSIVE, 0, addr2, null, 0, 0, 0, 0, 0, 0, DATA);

    op_dma(DMA_WRITE, VALID, 0, 0, addr2, null, line_of_addr(addr2.line)*2, 
    	   4, 0, 0, 0, 0);

    op(REQ_GETS, VALID, 0, addr2, null, 0, line_of_addr(addr2.line)*2, 0, 0, 0, 0, DATA);

    op_dma(DMA_WRITE, EXCLUSIVE, EVICT, DIRTY, addr1, addr2, line_of_addr(addr1.line),
    	   4, line_of_addr(addr2.line)*2, 0, 0, 0);

    op(REQ_GETS, VALID, 0, addr1, null, 0, line_of_addr(addr1.line), 0, 0, 0, 0, DATA);

    // DMA_Write evicts MODIFIED line, not dirty
    regular_evict_prep(addr_new, addr1, addr2, evict_way);

    op(REQ_PUTS, EXCLUSIVE, 0, addr2, null, 0, 0, 0, 0, 0, 0, DATA);

    //this transaction corresponds to different data depending on # of ways
    if (LLC_WAYS == 4)
    op(REQ_GETM, VALID, 0, addr2, null, 0, 2*line_of_addr(addr2.line), 0, 0, 0, 0, DATA);
    else
    op(REQ_GETM, VALID, 0, addr2, null, 0, line_of_addr(addr2.line), 0, 0, 0, 0, DATA);

    op_dma(DMA_WRITE, MODIFIED, EVICT, DIRTY, addr1, addr2, line_of_addr(addr1.line)*2, 4, 
    	   line_of_addr(addr2.line), 1, 0, 0);

    op(REQ_GETS, VALID, 0, addr1, null, 0, line_of_addr(addr1.line)*2, 0, 0, 0, 0, DATA);

    // DMA_Write evicts MODIFIED line, dirty
    regular_evict_prep(addr_new, addr1, addr2, evict_way);

    op(REQ_PUTS, EXCLUSIVE, 0, addr2, null, 0, 0, 0, 0, 0, 0, DATA);

    op_dma(DMA_WRITE, VALID, 0, 0, addr2, null, line_of_addr(addr2.line)*2, 
    	   4, 0, 0, 0, 0);

    op(REQ_GETM, VALID, 0, addr2, null, 0, line_of_addr(addr2.line)*2, 0, 0, 0, 0, DATA);

    op_dma(DMA_WRITE, MODIFIED, EVICT, DIRTY, addr1, addr2, line_of_addr(addr1.line),
    	   4, line_of_addr(addr2.line)*2, 1, 0, 0);

    op(REQ_GETS, VALID, 0, addr1, null, 0, line_of_addr(addr1.line), 0, 0, 0, 0, DATA);

    // // go to an empty set and fill with SD states, sharers l2#12

    // addr_base.set_incr(1);
    // addr1 = addr_base;
    // evict_way = 0;

    // for (int i = 0; i < LLC_WAYS; i++) {
    //     op(REQ_GETS, INVALID, 0, addr1, null, 0, line_of_addr(addr1.line), 0, 0, 1, 0, DATA);
    //     op(REQ_GETS, EXCLUSIVE, 0, addr1, null, 0, line_of_addr(addr1.line), 0, 0, 2, 1, DATA);
    //     addr1.tag_incr(1);
    // }

    // // DMA_Read evicts SD line, dirty (can't be not dirty)
    // regular_evict_prep(addr_base, addr1, addr2, evict_way);

    // op_dma(DMA_READ, SHARED, EVICT, DIRTY, addr1, addr2, 4, line_of_addr(addr1.line), 
    //        line_of_addr(addr2.line), 6, 1, 1);

    // op(REQ_GETS, VALID, 0, addr1, null, 0, line_of_addr(addr1.line), 0, 0, 1, 0, DATA);
    // op(REQ_GETS, EXCLUSIVE, 0, addr1, null, 0, line_of_addr(addr1.line), 0, 0, 2, 1, DATA);
 
    // // DMA_Write evicts SD line, dirty (can't be not dirty)
    // regular_evict_prep(addr_base, addr1, addr2, evict_way);

    // op_dma(DMA_WRITE, SHARED, EVICT, DIRTY, addr1, addr2, line_of_addr(addr1.line)*2, 
    //        4, line_of_addr(addr2.line)*2, 6, 1, 1);

    // TODO test SD -> DMA_* -> V (with some put) -> evict V -> execute DMA_*


    /* Fill whole cache */

    CACHE_REPORT_INFO("T0.9) Fill whole cache.");

    reset_dut(is_reset);

    // Make every entry in the cache dirty with DMA_WRITE requests
    CACHE_REPORT_INFO("Whole cache dirty.");

    addr = null;

    for (int i = 0; i < LLC_SETS; i++) {

    	for (int j = 0; j < LLC_WAYS; j++) {

    	    op_dma(DMA_WRITE, INVALID, 0, 0, addr, null, line_of_addr(addr.line), 4, 0, 0, 0, 0);

    	    addr.tag_incr(1);
    	}

    	addr.set_incr(1);
    }


    // Fill a quarter of each set with SHARED, a quarter with EXCLUSIVE, 
    // a quarter with MODIFIED, a quarter with VALID.
    CACHE_REPORT_INFO("Whole cache in various states.");

    addr = null;

    for (int i = 0; i < LLC_SETS; i++) {

    	for (int j = 0; j < LLC_WAYS; j++) {

    	    if ((j % 4) == 0) {
    		op(REQ_GETS, VALID, 0, addr, null, 0, line_of_addr(addr.line), 0, 0, 0, 0, DATA);
    		op(REQ_GETS, EXCLUSIVE, 0, addr, null, 0, line_of_addr(addr.line), 0, 0, 1, 0, DATA);
    		op_rsp(RSP_DATA, addr, line_of_addr(addr.line), 0);

    	    } else if ((j % 4) == 1) {
    		op(REQ_GETS, VALID, 0, addr, null, 0, line_of_addr(addr.line), 0, 0, 2, 0, DATA);

    	    } else if ((j % 4) == 2) {
    		op(REQ_GETM, VALID, 0, addr, null, 0, line_of_addr(addr.line), 0, 0, 3, 0, DATA);
    	    } else if ((j % 4) == 3) {
    		op_dma(DMA_READ, VALID, 0, 0, addr, null, 4, line_of_addr(addr.line), 0, 0, 0, 0);
    	    }

    	    addr.tag_incr(1);
    	}

    	addr.set_incr(1);
    }

    // Put back all lines
    CACHE_REPORT_INFO("Whole cache put back.");

    addr = null;

    for (int i = 0; i < LLC_SETS; i++) {

    	for (int j = 0; j < LLC_WAYS; j++) {

    	    if ((j % 4) == 0) {
    		op(REQ_PUTS, SHARED, 0, addr, null, 0, 0, 0, 0, 0, 0, DATA);
    		op(REQ_PUTS, SHARED, 0, addr, null, 0, 0, 0, 0, 1, 1, DATA);

    	    } else if ((j % 4) == 1) {
    		op(REQ_PUTS, EXCLUSIVE, 0, addr, null, 0, 0, 0, 0, 2, 2, DATA);

    	    } else if ((j % 4) == 2) {
    		op(REQ_PUTM, MODIFIED, 0, addr, null, line_of_addr(addr.line), 0, 0, 0, 3, 3, DATA);

    	    }

    	    addr.tag_incr(1);
    	}

    	addr.set_incr(1);
    }


    // Flush out all dirty lines
    CACHE_REPORT_INFO("Whole cache flush dirty.");

    llc_rst_tb_tb.put(is_flush);

    addr = null;

    for (int i = 0; i < LLC_SETS; i++) {

    	for (int j = 0; j < LLC_WAYS; j++) {
    
    	    get_mem_req(LLC_WRITE, addr.line, line_of_addr(addr.line));

    	    addr.tag_incr(1);

    	    wait();
    	}

    	addr.set_incr(1);
    }

    llc_rst_tb_done_tb.get(tmp_rst_tb);

    wait();

    /**************/
    /* DMA Bursts */

    CACHE_REPORT_INFO("T10) DMA Bursts Misaligned.");

    addr_breakdown_llc_t addr_ref = addr_base;

    const int wlength_size = 6;

    line_t wlengths[wlength_size] = {1, 2, 3, 4, 64, 1019};

    for (int k = 0; k < wlength_size; k++) { // select burst length

	for (int i = 0; i < WORDS_PER_LINE; i++) {

	    reset_dut(is_reset);

	    /* DMA Bursts on INVALID lines */

	    CACHE_REPORT_INFO("DMA Read burst. I -> V. Not dirty.");

	    addr = addr_ref;
	    addr.w_off = i;
	    addr_ref.tag_incr(1);

	    op_dma(DMA_READ, INVALID, 0, 0, addr, null, wlengths[k],
		   line_of_addr(addr.line), 0, 0, 0, 0);

	    CACHE_REPORT_INFO("DMA Write burst. I -> V. Dirty.");

	    addr.set_incr(256);

	    op_dma(DMA_WRITE, INVALID, 0, 0, addr, null, 0, wlengths[k], 0, 0, 0, 0);

	    /* DMA Bursts on VALID lines */

	    CACHE_REPORT_INFO("DMA Read burst. V -> V. Dirty.");

	    op_dma(DMA_READ, VALID, 0, 0, addr, null, wlengths[k], 0, 0, 0, 0, 0);

	    CACHE_REPORT_INFO("DMA Write burst. V -> V. Dirty.");

	    op_dma(DMA_WRITE, VALID, 0, 0, addr, null, line_of_addr(addr.line),
		   wlengths[k], 0, 0, 0, 0);

            wait(100);
	}
    }

    CACHE_REPORT_INFO("=== Test completed ===");

    /***************************************************************************/
    /* TODO                                                                    */
    /* DMA Bursts with Recalls Interrupted by GETS/GETM on different addresses */


    // /**************************************/
    // /* DMA Bursts Smaller Than Cache Line */

    // CACHE_REPORT_INFO("T12) DMA Burst Smaller Then Cache Line.");

    // reset_dut(is_reset);

    // /* DMA Bursts on INVALID lines */

    // CACHE_REPORT_INFO("DMA Read burst. I -> V. Not dirty.");

    // addr = addr_base;

    // op_dma(DMA_READ, INVALID, 0, 0, addr, null, 1024, line_of_addr(addr.line), 0, 0, 0, 0);

    // CACHE_REPORT_INFO("DMA Write burst. I -> V. Dirty.");

    // addr.set_incr(256);

    // op_dma(DMA_WRITE, INVALID, 0, 0, addr, null, 0, 1024, 0, 0, 0, 0);

    // /* DMA Bursts on VALID lines */

    // CACHE_REPORT_INFO("DMA Read burst. V -> V. Dirty.");

    // op_dma(DMA_READ, VALID, 0, 0, addr, null, 1024, 0, 0, 0, 0, 0);

    // CACHE_REPORT_INFO("DMA Write burst. V -> V. Dirty.");

    // op_dma(DMA_WRITE, VALID, 0, 0, addr, null, line_of_addr(addr.line), 1024, 0, 0, 0, 0);


    // End simulation
    sc_stop();
}

/*
 * Functions
 */

void llc_tb::reset_dut(bool is_flush)
{
    bool tmp_rst_tb;

    llc_rst_tb_tb.put(is_flush);
    llc_rst_tb_done_tb.get(tmp_rst_tb);
    wait();
}

inline void llc_tb::reset_llc_test()
{
    llc_req_in_tb.reset_put();
    llc_dma_req_in_tb.reset_put();
    llc_rsp_in_tb.reset_put();
    llc_mem_rsp_tb.reset_put();
    llc_rst_tb_tb.reset_put();
    llc_rsp_out_tb.reset_get();
    llc_dma_rsp_out_tb.reset_get();
    llc_fwd_out_tb.reset_get();
    llc_mem_req_tb.reset_get();
    llc_rst_tb_done_tb.reset_get();

    wait();
}

/*
 * Generic function to setup eviction addresses and update evict_way
 */
void llc_tb::evict_prep(addr_breakdown_llc_t addr_base, addr_breakdown_llc_t &addr1, 
			addr_breakdown_llc_t &addr2, int tag_incr1, int tag_incr2, 
			llc_way_t &evict_way, bool update_way)
{
    addr1 = addr_base;
    addr1.tag_incr(tag_incr1);
    addr2 = addr_base;
    addr2.tag_incr(tag_incr2);

    evict_way += update_way;
}

/*
 * Way to evict is evict_way. New way is evict_way + LLC_WAYS.
 * This calls a generic function to setup eviction addresses.
 */
void llc_tb::regular_evict_prep(addr_breakdown_llc_t addr_base, addr_breakdown_llc_t &addr1,
				addr_breakdown_llc_t &addr2, llc_way_t &evict_way)
{
    int tag_incr1 = (int) evict_way + LLC_WAYS;
    int tag_incr2 = (int) evict_way;

    evict_prep(addr_base, addr1, addr2, tag_incr1, tag_incr2, evict_way, 1);
}

void llc_tb::op_rsp(coh_msg_t rsp_msg, addr_breakdown_llc_t req_addr, line_t req_line, cache_id_t req_id)
{
    put_rsp_in(rsp_msg, req_addr.line, req_line, req_id);
}

void llc_tb::op(mix_msg_t coh_msg, llc_state_t state, bool evict, addr_breakdown_llc_t req_addr, 
		addr_breakdown_llc_t evict_addr, line_t req_line, line_t rsp_line, line_t evict_line,
		invack_cnt_t invack_cnt, cache_id_t req_id, cache_id_t dest_id, hprot_t hprot)
{
    int out_plane = REQ_PLANE;
    coh_msg_t out_msg = 0;
    bool out_plane_2 = false;

    // incoming request
    put_req_in(coh_msg, req_addr.line, req_line, req_id, hprot, 0, 0);

    // evict line
    if (evict) {
	get_mem_req(LLC_WRITE, evict_addr.line, evict_line);
	wait();
    }

    // read from main memory
    if ((state == INVALID || evict) && coh_msg != REQ_PUTS &&
	coh_msg != REQ_PUTM) {

	get_mem_req(LLC_READ, req_addr.line, 0);
	wait();
	put_mem_rsp(rsp_line);
    }

    // outgoing responses and forwards
    switch (coh_msg) {

    case REQ_GETS :

	switch (state) {

	case INVALID :
	case VALID :
	    out_plane = RSP_PLANE;
	    if (hprot == INSTR)
		out_msg = RSP_DATA;
	    else // hprot ==  DATA
		out_msg = RSP_EDATA;
	    break;

	case SHARED :
	    out_plane = RSP_PLANE;
	    out_msg = RSP_DATA;
	    break;

	case EXCLUSIVE:
	case MODIFIED:
	    out_plane = FWD_PLANE;
	    out_msg = FWD_GETS;
	    break;
	}
	break;

    case REQ_GETM:

	switch (state) {

	case INVALID:
	case VALID:
	    out_plane = RSP_PLANE;
	    out_msg = RSP_DATA;
	    break;

	case SHARED:
	    out_plane = RSP_PLANE;
	    out_msg = RSP_DATA;
	    out_plane_2 = true;
	    break;

	case EXCLUSIVE:
	case MODIFIED:
	    out_plane = FWD_PLANE;
	    out_msg = FWD_GETM;

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

    default:
	CACHE_REPORT_INFO("ERROR: This request type is undefined.");
    }

    if (out_plane_2) { // fwd_inv

	for (int i = 0; i < invack_cnt; i++) {
	    get_fwd_out(FWD_INV, req_addr.line, req_id, i);
	    wait();
	}

    } else if (out_plane == FWD_PLANE) { // fwd_getm, fwd_gets, fwd_putack

	get_fwd_out(out_msg, req_addr.line, req_id, dest_id);
    }

    if (out_plane == RSP_PLANE) { // rsp_edata, rsp_data

	get_rsp_out(out_msg, req_addr.line, rsp_line, invack_cnt, req_id, dest_id, 0);

    }

    wait();
}

void llc_tb::op_dma(mix_msg_t coh_msg, llc_state_t state, bool evict, bool dirty, 
		    addr_breakdown_llc_t req_addr, addr_breakdown_llc_t evict_addr, 
		    line_t req_line, line_t rsp_line, line_t evict_line,
		    sharers_t sharers, owner_t owner, bool stall)
{
    line_t wlength;
    bool done = false;
    word_offset_t init_offset = 0;
    init_offset = req_addr.w_off;

    if (coh_msg == REQ_DMA_READ_BURST) {
        word_t word = (req_line.range(ADDR_BITS - 1, 0).to_uint() * 4 +
		       (BYTES_PER_WORD-4)) / BYTES_PER_WORD;
        req_line = 0;
        req_line.range(BITS_PER_LINE - 1, BITS_PER_LINE - ADDR_BITS) = word;
	wlength = word;
    } else if (coh_msg == REQ_DMA_WRITE_BURST) {
	wlength = (rsp_line * 4 + (BYTES_PER_WORD-4)) / BYTES_PER_WORD;
    }

    word_t llength = (word_t) ((wlength + init_offset + WORDS_PER_LINE - 1) / WORDS_PER_LINE);
    word_offset_t wvalid;

    CACHE_REPORT_VAR(sc_time_stamp(), "wlength", wlength);
    CACHE_REPORT_VAR(sc_time_stamp(), "llength", llength);

    for (int i = 0; i < llength; i++) {

	if (i == llength - 1)
	    done = true;

	// req in
	if (coh_msg == REQ_DMA_WRITE_BURST || !i) {

	    if (coh_msg == REQ_DMA_READ_BURST)
		wvalid = 0;

	    else if (llength == 1)
		wvalid = wlength - 1;

	    else if (i == 0)
		wvalid = WORDS_PER_LINE - 1 - req_addr.w_off;

	    else if (i == llength - 1)
		wvalid = (init_offset + wlength) % WORDS_PER_LINE - 1;

	    else
		wvalid = WORDS_PER_LINE - 1;

	    put_dma_req_in(coh_msg, req_addr.line, req_line, 0, done,
                           req_addr.w_off, wvalid);
	}

	// end of stall
	if (stall) {
	    wait(); wait();
	    op_rsp(RSP_DATA, evict_addr, evict_line, owner);
	}

	// eviction
	if (evict) {
	    switch (state) {

	    case SHARED:
		// inv to sharers
		for (int i = 0; i < MAX_N_L2; i++) {
		    if ((sharers & (1 << i)) != 0) {
			get_fwd_out(FWD_INV_LLC, evict_addr.line, i, i);
			wait();
		    }
		}
		break;

	    case EXCLUSIVE:
		// inv to owner
		get_fwd_out(FWD_GETM_LLC, evict_addr.line, owner, owner);

		// rsp from owner, no data
		op_rsp(RSP_INVACK, evict_addr, 0, owner);
		break;
	    
	    case MODIFIED:
		// inv to owner
		get_fwd_out(FWD_GETM_LLC, evict_addr.line, owner, owner);

		// rsp from owner, with data
		op_rsp(RSP_DATA, evict_addr, evict_line, owner);

		break;
	    }
	}

	// write back to memory
	if (evict && dirty) {
	    get_mem_req(LLC_WRITE, evict_addr.line, evict_line);
	    wait();
	}

	// read mem
	if (coh_msg == DMA_READ && (state == INVALID || evict)) {
	    get_mem_req(LLC_READ, req_addr.line, 0);
	    wait();
	    put_mem_rsp(rsp_line);
	}

	if (coh_msg == DMA_WRITE && wvalid != WORDS_PER_LINE - 1 && state == INVALID) {
	    get_mem_req(LLC_READ, req_addr.line, 0);
	    wait();
	    put_mem_rsp(0);
	}

	invack_cnt_t invack_cnt;
	invack_cnt[0] = done;

	if (llength == 1)
	    invack_cnt.range(WORD_BITS, 1) = wlength - 1;

	else if (i == 0)
	    invack_cnt.range(WORD_BITS, 1) = WORDS_PER_LINE - 1 - req_addr.w_off;

	else if (i == llength - 1)
	    invack_cnt.range(WORD_BITS, 1) = (init_offset + wlength) % WORDS_PER_LINE - 1;

	else
	    invack_cnt.range(WORD_BITS, 1) = WORDS_PER_LINE - 1;

	// rsp data to accelerator
	if (coh_msg == DMA_READ)
	    get_dma_rsp_out(RSP_DATA_DMA, req_addr.line, rsp_line, invack_cnt, 0, 0, req_addr.w_off);
    
	// update address to the next line (add 16 bytes)
	req_addr.set_incr(1);
	evict_addr.set_incr(1);
	req_addr.breakdown(req_addr.line);
	evict_addr.breakdown(evict_addr.line);
	req_line += 1;
	rsp_line += 1;
	evict_line += 1;

	wait(100);
    }
}

void llc_tb::get_rsp_out(coh_msg_t coh_msg, addr_t addr, line_t line, invack_cnt_t invack_cnt,
			 cache_id_t req_id, cache_id_t dest_id, word_offset_t woff)
{
    llc_rsp_out_t<CACHE_ID_WIDTH> rsp_out;

    llc_rsp_out_tb.get(rsp_out);

    if (rsp_out.coh_msg != coh_msg       ||
	rsp_out.addr   != addr.range(TAG_RANGE_HI, SET_RANGE_LO) ||
	rsp_out.line   != line           ||
	rsp_out.invack_cnt != invack_cnt ||
	rsp_out.req_id != req_id         ||
	rsp_out.dest_id != dest_id ||
	rsp_out.word_offset != woff
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
	CACHE_REPORT_ERROR("woff get rsp out", rsp_out.dest_id);
	CACHE_REPORT_ERROR("woff get rsp out gold", dest_id);
    }
    if (RPT_TB)
	CACHE_REPORT_VAR(sc_time_stamp(), "RSP_OUT", rsp_out);
}

void llc_tb::get_dma_rsp_out(coh_msg_t coh_msg, addr_t addr, line_t line, invack_cnt_t invack_cnt,
			 llc_coh_dev_id_t req_id, cache_id_t dest_id, word_offset_t woff)
{
    llc_rsp_out_t<LLC_COH_DEV_ID_WIDTH> rsp_out;

    llc_dma_rsp_out_tb.get(rsp_out);

    if (rsp_out.coh_msg != coh_msg       ||
	rsp_out.addr   != addr.range(TAG_RANGE_HI, SET_RANGE_LO) ||
	rsp_out.line   != line           ||
	rsp_out.invack_cnt != invack_cnt ||
	rsp_out.req_id != req_id         ||
	rsp_out.dest_id != dest_id ||
	rsp_out.word_offset != woff
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
	CACHE_REPORT_ERROR("woff get rsp out", rsp_out.dest_id);
	CACHE_REPORT_ERROR("woff get rsp out gold", dest_id);
    }
    if (RPT_TB)
	CACHE_REPORT_VAR(sc_time_stamp(), "RSP_OUT", rsp_out);
}

void llc_tb::get_fwd_out(mix_msg_t coh_msg, addr_t addr, cache_id_t req_id, cache_id_t dest_id)
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
    if (RPT_TB)
	CACHE_REPORT_VAR(sc_time_stamp(), "FWD_OUT", fwd_out);
}

void llc_tb::get_mem_req(bool hwrite, addr_t addr, line_t line)
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
    if (RPT_TB)
	CACHE_REPORT_VAR(sc_time_stamp(), "MEM_REQ", mem_req);
}

void llc_tb::put_mem_rsp(line_t line)
{
    llc_mem_rsp_t mem_rsp;
    mem_rsp.line = line;

    // rand_wait();

    llc_mem_rsp_tb.put(mem_rsp);

    if (RPT_TB)
	CACHE_REPORT_VAR(sc_time_stamp(), "MEM_RSP", mem_rsp);
}

void llc_tb::put_req_in(mix_msg_t coh_msg, addr_t addr, line_t line, cache_id_t req_id,
			hprot_t hprot, word_offset_t woff, word_offset_t wvalid)
{
    llc_req_in_t<CACHE_ID_WIDTH> req_in;
    req_in.coh_msg = coh_msg;
    req_in.hprot = hprot;
    req_in.addr = addr.range(TAG_RANGE_HI, SET_RANGE_LO);
    req_in.line = line;
    req_in.req_id = req_id;
    req_in.word_offset = woff;
    req_in.valid_words = wvalid;

    // rand_wait();

    llc_req_in_tb.put(req_in);

    if (RPT_TB)
	CACHE_REPORT_VAR(sc_time_stamp(), "REQ_IN", req_in);
}

void llc_tb::put_dma_req_in(mix_msg_t coh_msg, addr_t addr, line_t line, llc_coh_dev_id_t req_id,
                            hprot_t hprot, word_offset_t woff, word_offset_t wvalid)
{
    llc_req_in_t<LLC_COH_DEV_ID_WIDTH> req_in;
    req_in.coh_msg = coh_msg;
    req_in.hprot = hprot;
    req_in.addr = addr.range(TAG_RANGE_HI, SET_RANGE_LO);
    req_in.line = line;
    req_in.req_id = req_id;
    req_in.word_offset = woff;
    req_in.valid_words = wvalid;

    // rand_wait();

    llc_dma_req_in_tb.put(req_in);

    if (RPT_TB)
	CACHE_REPORT_VAR(sc_time_stamp(), "REQ_IN", req_in);
}

void llc_tb::put_rsp_in(coh_msg_t rsp_msg, addr_t addr, line_t line, cache_id_t req_id)
{
    llc_rsp_in_t rsp_in;
    rsp_in.coh_msg = rsp_msg;
    rsp_in.addr = addr.range(TAG_RANGE_HI, SET_RANGE_LO);
    rsp_in.line = line;
    rsp_in.req_id = req_id;

    // rand_wait();

    llc_rsp_in_tb.put(rsp_in);

    if (RPT_TB)
	CACHE_REPORT_VAR(sc_time_stamp(), "RSP_IN", rsp_in);
}
