/* Copyright 2017 Columbia University, SLD Group */

#include "l2_tb.hpp"

/*
 * Processes
 */

void l2_tb::l2_debug()
{
    sc_bv<ASSERT_WIDTH>   old_asserts  = 0;
    sc_bv<ASSERT_WIDTH>   new_asserts  = 0;
    sc_bv<BOOKMARK_WIDTH> old_bookmark = 0;
    sc_bv<BOOKMARK_WIDTH> new_bookmark = 0;
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

void l2_tb::l2_test()
{
    /*
     * Random seed
     */
    
    // initialize
    srand(time(NULL));

    /*
     * Local variables
     */

    // preparation variables
    addr_breakdown_t addr, addr1, addr2, addr3, addr4;
    word_t word, word1, word2, word3, word4;
    line_t line, req_line, fwd_line;
    l2_cpu_req_t cpu_req, cpu_req1, cpu_req2, cpu_req3, cpu_req4;
    l2_req_out_t req_out;
    cache_id_t id;
    invack_cnt_t invack;

    /*
     * Reset
     */

    reset_l2_test();

    /*
     * T0) Simple word reads and writes. No eviction. No pipelining. 1 CPU.
     */
    CACHE_REPORT_INFO("T0) SIMPLE WORD READS AND WRITES.");

    /* T0.0) Simple read hits and misses. Fill a random set. */
    CACHE_REPORT_INFO("T0.0) Read hits and misses. Fill a random set.");

    // preparation
    addr1 = rand_addr();

    // read misses
    addr = addr1;
    for (int i = 0; i < L2_WAYS; ++i) {
	op(READ, MISS, 0, RSP_EDATA, 0, 0, WORD, addr, 0, line_of_addr(addr.line), 0, 0, 0, 0);
	addr.tag_incr(1);
    }

    // read hits
    addr = addr1;
    for (int i = 0; i < L2_WAYS; ++i) {
	op(READ, HIT, 0, 0, 0, 0, WORD, addr, 0, line_of_addr(addr.line), 0, 0, 0, 0);
	addr.tag_incr(1);
    }

    /* T0.1) Write hits and misses. Fill the set next to T0. */
    CACHE_REPORT_INFO("T0.1) Write hits and misses. Same and next sets wrt T0.");

    // preparation
    // addr =  same as before
    word1 = rand_word();

    // write hits (E)
    addr = addr1;
    word = word1;
    for (int i = 0; i < L2_WAYS; ++i) {
	op(WRITE, HIT, 0, 0, 0, 0, WORD, addr, word, 0, 0, 0, 0, 0);

	addr.tag_incr(1);
	word++;
    }

    // write hits (M)
    addr = addr1;
    word = word1;
    for (int i = 0; i < L2_WAYS; ++i) {
	op(WRITE, HIT, 0, 0, 0, 0, WORD, addr, word, 0, 0, 0, 0, 0);

	addr.tag_incr(1);
	word++;
    }

    // next set
    addr.set_incr(1);

    // write misses
    for (int i = 0; i < L2_WAYS; ++i) {
	op(WRITE, MISS, 0, RSP_DATA, 0, 0, WORD, addr, word, line_of_addr(addr.line), 0, 0, 0, 0);

	addr.tag_incr(1);
	word++;
    }

    // verify writes correctness (read hits)
    addr = addr1;
    word = word1;
    for (int i = 0; i < (2 * L2_WAYS); ++i) {
	if (i == L2_WAYS) addr.set_incr(1);

	line = line_of_addr(addr.line);
	write_word(line, word, addr.w_off, 0, WORD);

	op(READ, HIT, 0, 0, 0, 0, WORD, addr, 0, line, 0, 0, 0, 0);

	addr.tag_incr(1);
	word++;
    }

    /*
     * T1. Simple flush.
     */
    CACHE_REPORT_INFO("T1) SIMPLE FLUSH.");    

    // issue flush
    l2_flush_tb.put(1);

    // receive 1 PutM, send 1 PutAck
    addr = addr1;
    for (int i = 0; i < (2 * L2_WAYS); ++i) {
	if (i == L2_WAYS) addr.set_incr(1);

	op_flush(REQ_PUTM, addr.line);

	addr.tag_incr(1);
    }

    while(!flush_done) wait();

    // verify writes correctness (read misses)
    addr = addr1;
    for (int i = 0; i < (2 * L2_WAYS); ++i) {
	if (i == L2_WAYS) addr.set_incr(1);

	op(READ, MISS, 0, RSP_EDATA, 0, 0, WORD, addr, 0, line_of_addr(addr.line), 0, 0, 0, 0);

	addr.tag_incr(1);
    }

    // flush again
    l2_flush_tb.put(1);

    // receive all PutS
    addr = addr1;
    for (int i = 0; i < (2*L2_WAYS); ++i) {
	if (i == L2_WAYS) addr.set_incr(1);

    	get_req_out(REQ_PUTS, addr.line, 0);
    	wait();

	addr.tag_incr(1);
    }

    // send all PutAck
    addr = addr1;
    for (int i = 0; i < (2*L2_WAYS); ++i) {
	if (i == L2_WAYS) addr.set_incr(1);

    	put_rsp_in(RSP_PUTACK, addr.line, 0, 0);
    	wait();

	addr.tag_incr(1);
    }

    while(!flush_done) wait();

    /*
     * T2) Reads and writes. Fill whole cache.
     */
    CACHE_REPORT_INFO("T2) READS AND WRITES. FILL WHOLE CACHE.");

    CACHE_REPORT_INFO("T2.0) Fill 1/2 of sets by reading 1 word per line.");

    for (int wa = 0; wa < L2_WAYS; ++wa) {
    	for (int s = 0; s < SETS/2; ++s) {
    	    addr.breakdown((wa << TAG_RANGE_LO) + (s << SET_RANGE_LO));

	    op(READ, MISS, 0, RSP_EDATA, 0, 0, WORD, addr, 0, line_of_addr(addr.line), 0, 0, 0, 0);
    	}
    }

    CACHE_REPORT_INFO("T2.1) Write all words.");

    for (int wo = 0; wo < WORDS_PER_LINE; ++wo) {
    	for (int wa = 0; wa < L2_WAYS; ++wa) {
    	    for (int s = 0; s < SETS; ++s) {
    		addr.breakdown((wo << W_OFF_RANGE_LO) + (wa << TAG_RANGE_LO) + 
				   (s << SET_RANGE_LO));
		word = addr.word;

    		if (s >= SETS/2 && wo == 0) {
		    op(WRITE, MISS, 0, RSP_DATA, 0, 0, WORD, addr, word, line_of_addr(addr.line), 0, 0, 0, 0);
    		} else {
		    op(WRITE, HIT, 0, 0, 0, 0, WORD, addr, word, 0, 0, 0, 0, 0);
		}
    	    }
    	}
    }

    CACHE_REPORT_INFO("T2.2) Overwrite the half words per line of half sets.");

    for (int wo = 0; wo < WORDS_PER_LINE/2; ++wo) {
    	for (int wa = 0; wa < L2_WAYS; ++wa) {
    	    for (int s = 0; s < SETS/2; ++s) {
    		addr.breakdown((wo << W_OFF_RANGE_LO) + (wa << TAG_RANGE_LO) + (s << SET_RANGE_LO));
		word = addr.word + 1;

		op(WRITE, HIT, 0, 0, 0, 0, WORD, addr, word, 0, 0, 0, 0, 0);
    	    }
    	}
    }

    CACHE_REPORT_INFO("T2.3) Read and check all words.");

    for (int wa = 0; wa < L2_WAYS; ++wa) {
	for (int s = 0; s < SETS; ++s) {
	    addr.breakdown((wa << TAG_RANGE_LO) + (s << SET_RANGE_LO));
	    line = line_of_addr(addr.line);

	    int wo;
	    if (s < SETS/2) {
		for (wo = 0; wo < WORDS_PER_LINE/2; ++wo) {
		    write_word(line, addr.line + (wo << W_OFF_RANGE_LO) + 1, wo, 0, WORD);
		}
	    }

	    op(READ, HIT, 0, 0, 0, 0, WORD, addr, 0, line, 0, 0, 0, 0);
	}
    }


    /*
     * T3) Flush whole cache.
     */
    CACHE_REPORT_INFO("T3) Flush whole cache.");    

    // issue flush
    l2_flush_tb.put(1);

    // receive 1 PutM, send 1 PutAck
    for (int s = 0; s < SETS; ++s) {
	for (int wa = 0; wa < L2_WAYS; ++wa) {
	    addr.breakdown((wa << TAG_RANGE_LO) + (s << SET_RANGE_LO));

	    op_flush(REQ_PUTM, addr.line);
	}
    }

    while(!flush_done) wait();

    /*
     * T4) Less-than-word operations.
     */
    CACHE_REPORT_INFO("T4) Less-than-word reads and writes. Operations on a single set.");

    addr1 = rand_addr();

    CACHE_REPORT_INFO("T4.0) Byte and Halfword Read Miss.");

    addr = addr1;
    op(READ, MISS, 0, RSP_EDATA, 0, 0, BYTE, addr, 0, line_of_addr(addr.line), 0, 0, 0, 0);

    addr.tag_incr(1);
    op(READ, MISS, 0, RSP_EDATA, 0, 0, HALFWORD, addr, 0, line_of_addr(addr.line), 0, 0, 0, 0);


    CACHE_REPORT_INFO("T4.1) Byte and Halfword Read Hit.");

    addr = addr1;
    op(READ, HIT, 0, 0, 0, 0, BYTE, addr, 0, line_of_addr(addr.line), 0, 0, 0, 0);

    addr.tag_incr(1);
    op(READ, HIT, 0, 0, 0, 0, HALFWORD, addr, 0, line_of_addr(addr.line), 0, 0, 0, 0);


    CACHE_REPORT_INFO("T4.2) Byte and Halfword Write Hit.");

    addr = addr1;
    op(WRITE, HIT, 0, 0, 0, 0, BYTE, addr, 0, 0, 0, 0, 0, 0);

    addr.tag_incr(1);
    op(WRITE, HIT, 0, 0, 0, 0, HALFWORD, addr, 0, 0, 0, 0, 0, 0);


    CACHE_REPORT_INFO("T4.3) Byte and Halfword Write Miss.");

    addr = addr1;
    addr.set_incr(1);
    op(WRITE, MISS, 0, RSP_DATA, 0, 0, BYTE, addr, 0, line_of_addr(addr.line), 0, 0, 0, 0);

    addr.tag_incr(1);
    op(WRITE, MISS, 0, RSP_DATA, 0, 0, HALFWORD, addr, 0, line_of_addr(addr.line), 0, 0, 0, 0);


    CACHE_REPORT_INFO("T4.4) Verify writes.");

    offset_t off_tmp;

    addr = addr1;
    line = line_of_addr(addr.line);
    off_tmp = addr.off + BYTES_PER_WORD - 2 * addr.b_off - 1;
    line.range(off_tmp*8 + 7, off_tmp*8) = 0;
    op(READ, HIT, 0, 0, 0, 0, WORD, addr, 0, line, 0, 0, 0, 0);

    addr.tag_incr(1);
    addr.off.range(0,0) = 0;
    if (addr.off.range(B_OFF_RANGE_HI,B_OFF_RANGE_HI) == 0)
	addr.off.range(B_OFF_RANGE_HI,B_OFF_RANGE_HI) = 1;
    else
	addr.off.range(B_OFF_RANGE_HI,B_OFF_RANGE_HI) = 0;
    line = line_of_addr(addr.line);
    line.range(addr.off*8 + BITS_PER_HALFWORD - 1, addr.off*8) = 0;
    op(READ, HIT, 0, 0, 0, 0, WORD, addr, 0, line, 0, 0, 0, 0);

    addr = addr1;
    addr.set_incr(1);
    line = line_of_addr(addr.line);
    off_tmp = addr.off + BYTES_PER_WORD - 2 * addr.b_off - 1;
    line.range(off_tmp*8 + 7, off_tmp*8) = 0;
    op(READ, HIT, 0, 0, 0, 0, WORD, addr, 0, line, 0, 0, 0, 0);

    addr.tag_incr(1);
    addr.off.range(0,0) = 0;
    if (addr.off.range(B_OFF_RANGE_HI,B_OFF_RANGE_HI) == 0)
	addr.off.range(B_OFF_RANGE_HI,B_OFF_RANGE_HI) = 1;
    else
	addr.off.range(B_OFF_RANGE_HI,B_OFF_RANGE_HI) = 0;
    line = line_of_addr(addr.line);   
    line.range(addr.off*8 + BITS_PER_HALFWORD - 1, addr.off*8) = 0;
    op(READ, HIT, 0, 0, 0, 0, WORD, addr, 0, line, 0, 0, 0, 0);

    CACHE_REPORT_INFO("T4.5) Flush.");    

    // issue flush
    l2_flush_tb.put(1);

    for (int i = 0; i < 4; ++i) {
	l2_req_out_t req_out = l2_req_out_tb.get();
	put_rsp_in(RSP_PUTACK, req_out.addr, 0, 0);
	wait();
    }

    while(!flush_done) wait();

    /*
     * T5) Evictions.
     */
    CACHE_REPORT_INFO("T5) EVICTIONS.");

    CACHE_REPORT_INFO("T5.0) Evict twice a whole set.");

    // preparation
    addr1 = rand_addr();
    addr = addr1;

    for (int i = 0; i < L2_WAYS; ++i) {
	op(READ, MISS, 0, RSP_EDATA, 0, 0, WORD, addr, 0, line_of_addr(addr.line), 0, 0, 0, 0);

	addr.tag_incr(1);
    }

    for (int i = 0; i < L2_WAYS; ++i) {
	op(WRITE, MISS_EVICT, 0, RSP_DATA, 0, REQ_PUTS, WORD, addr, addr.word, line_of_addr(addr.line), 0, 0, 0, 0);

	addr.tag_incr(1);
    }

    for (int i = 0; i < L2_WAYS; ++i) {
	op(READ, MISS_EVICT, 0, RSP_EDATA, 0, REQ_PUTM, WORD, addr, 0, line_of_addr(addr.line), 0, 0, 0, 0);

	addr.tag_incr(1);
    }


    CACHE_REPORT_INFO("T5.1) Evict stalls.");

    addr1 = addr;
    addr.tag_decr(L2_WAYS);
    addr_breakdown_t addr_evict1 = addr;
    addr.set_incr(1);
    addr2 = addr;

    put_cpu_req(cpu_req1, READ, WORD, addr1.word, 0);
    get_inval(addr_evict1.line);
    get_req_out(REQ_PUTS, addr_evict1.line, 0);

    wait();

    put_cpu_req(cpu_req2, READ, WORD, addr2.word, 0);

    put_rsp_in(RSP_PUTACK, addr_evict1.line, 0, 0);
    get_req_out(REQ_GETS, addr1.line, cpu_req1.hprot);

    wait();

    put_rsp_in(RSP_EDATA, addr1.line, line_of_addr(addr1.line), 0);
    get_rd_rsp(addr1, line_of_addr(addr1.line));

    get_req_out(REQ_GETS, addr2.line, cpu_req2.hprot);

    wait();

    put_rsp_in(RSP_EDATA, addr2.line, line_of_addr(addr2.line), 0);
    get_rd_rsp(addr2, line_of_addr(addr2.line));

    CACHE_REPORT_INFO("T5.2) Flush.");    

    // issue flush
    l2_flush_tb.put(1);

    for (int i = 0; i < L2_WAYS + 1; ++i) {
	l2_req_out_t req_out = l2_req_out_tb.get();
	put_rsp_in(RSP_PUTACK, req_out.addr, 0, 0);
	wait();
    }

    while(!flush_done) wait();

    /*
     * T6) Pipelined requests.
     */

    CACHE_REPORT_INFO("T6) PIPELINED REQUESTS.");

    CACHE_REPORT_INFO("T6.0) One read and multiple writes pipelined. Max requests stall.");

    addr1 = rand_addr();
    addr = addr1;
    int n_reqs = std::min(N_REQS, SETS);

    // Issue n_reqs + 1 requests

    put_cpu_req(cpu_req, READ, WORD, addr.word, 0);
    get_req_out(REQ_GETS, addr.line, cpu_req.hprot);
    wait();

    for (int i = 0; i < n_reqs - 1; i++) {
	addr.set_incr(1);
	put_cpu_req(cpu_req, WRITE, WORD, addr.word, 0);
	get_req_out(REQ_GETM, addr.line, cpu_req.hprot);
	wait();
    }

    addr.set_incr(1);
    put_cpu_req(cpu_req, WRITE, WORD, addr.word, 0);
    wait();

    // Respond to n_reqs requests
    addr.set_decr(n_reqs);
    put_rsp_in(RSP_EDATA, addr.line, line_of_addr(addr.line), 0);
    get_rd_rsp(addr, line_of_addr(addr.line));
    wait();

    for (int i = 0; i < n_reqs - 1; i++) {
	addr.set_incr(1);
	put_rsp_in(RSP_DATA, addr.line, line_of_addr(addr.line), 0);
	wait();
    }

    // Manage the n_reqs + 1 request
    addr.set_incr(1);
    get_req_out(REQ_GETM, addr.line, cpu_req.hprot);
    put_rsp_in(RSP_DATA, addr.line, line_of_addr(addr.line), 0);
    wait();

    CACHE_REPORT_INFO("T6.1) Verify writes.");

    addr = addr1;
    for (int i = 0; i < n_reqs; i++) {
	addr.set_incr(1);

	put_cpu_req(cpu_req, READ, WORD, addr.word, 0);
	line = line_of_addr(addr.line);
	line.range(addr.w_off*ADDR_BITS + ADDR_BITS - 1, addr.w_off*ADDR_BITS) = 0;
	get_rd_rsp(addr, line);
	wait();
    }

    CACHE_REPORT_INFO("T6.2) Flush.");

    // issue flush
    l2_flush_tb.put(1);

    for (int i = 0; i < n_reqs + 1; ++i) {
	req_out = l2_req_out_tb.get();
	put_rsp_in(RSP_PUTACK, req_out.addr, 0, 0);
	wait();
    }

    while(!flush_done) wait();

/*
 * Test every case of the Cache Coherence protocol
 */

    // preparation
    do {
	addr1 = rand_addr();
	addr2 = rand_addr();
	addr3 = rand_addr();
	addr4 = rand_addr();
    } while (addr1.set == addr2.set || addr1.set == addr3.set || addr1.set == addr4.set);

    word1 = rand_word();
    word2 = rand_word();
    word3 = rand_word();
    word4 = rand_word();

/*
 * The following are not tested because the set_conflict management prevents them for occurring: 
 * READ, WRITE and READ_ATOMIC with any intermediate state other than XMW.
 */


/****************/
/* from INVALID */
/****************/

    CACHE_REPORT_INFO("READ(I), RSP_EDATA(ISD), RSP_DATA(ISD).");

    addr = addr1;
    
    // This leaves a set with 4 EXCLUSIVE and 4 SHARED lines
    for (int i = 0; i < 4; i++) { // Assuming 8 ways
	// READ(I), RSP_EDATA(ISD)
	op(READ, MISS, 0, RSP_EDATA, 0, 0, WORD, addr, 0, line_of_addr(addr.line), 0, 0, 0, 0);
	addr.tag_incr(1);

	// READ(I), RSP_DATA(ISD)
	op(READ, MISS, 0, RSP_DATA, 0, 0, WORD, addr, 0, line_of_addr(addr.line), 0, 0, 0, 0);
	addr.tag_incr(1);
    }

    CACHE_REPORT_INFO("WRITE(I), RSP_DATA(IMAD), RSP_INVACK(IMAD), RSP_INVACK(IMA).");

    addr = addr2;
    word = word2;

    // This leaves a set with 8 MODIFIED lines
    for (int i = 0; i < 2; i++) { // Assuming 8 ways
	// WRITE(I), RSP_DATA(IMAD)
	op(WRITE, MISS, 0, RSP_DATA, 0, 0, WORD, addr, word++, line_of_addr(addr.line), 0, 0, 0, 0);
	addr.tag_incr(1);

	// WRITE(I), RSP_DATA(IMAD), RSP_INVACK(IMA)
	op(WRITE, MISS, DATA_FIRST, RSP_DATA, N_CPU-1, 0, WORD, addr, word++, line_of_addr(addr.line), 0, 0, 0, 0);
	addr.tag_incr(1);

	// WRITE(I), RSP_INVACK(IMAD), RSP_DATA(IMAD), RSP_INVACK(IMA)
	op(WRITE, MISS, DATA_HALFWAY, RSP_DATA, N_CPU-1, 0, WORD, addr, word++, line_of_addr(addr.line), 0, 0, 0, 0);
	addr.tag_incr(1);

	// WRITE(I), RSP_INVACK(IMAD), RSP_DATA(IMAD)
	op(WRITE, MISS, DATA_LAST, RSP_DATA, N_CPU-1, 0, WORD, addr, word++, line_of_addr(addr.line), 0, 0, 0, 0);
	addr.tag_incr(1);
    }

    CACHE_REPORT_INFO("READ_ATOMIC(I), RSP_DATA(IMADW), RSP_INVACK(IMADW), RSP_INVACK(IMAW).");
    CACHE_REPORT_INFO("READ(XMW), WRITE(XMW), READ_ATOMIC(XMW), WRITE_ATOM(XMW).");
    CACHE_REPORT_INFO("READ_ATOMIC with != address and ongoing atomic.");

    addr = addr3;
    word = word3;

    // This leaves a set with 8 MODIFIED lines
    for (int i = 0; i < 2; i++) { // Assuming 8 ways

	// READ_ATOMIC(I), RSP_DATA(IMADW)
	op(READ_ATOMIC, MISS, 0, RSP_DATA, 0, 0, WORD, addr, 0, line_of_addr(addr.line), 0, 0, 0, 0);
	// READ_ATOMIC(XMW)
	op(READ_ATOMIC, HIT, 0, 0, 0, 0, WORD, addr, 0, line_of_addr(addr.line), 0, 0, 0, 0);
	// WRITE_ATOM(XMW)
	op(WRITE_ATOMIC, HIT, 0, 0, 0, 0, WORD, addr, word++, 0, 0, 0, 0, 0);
	addr.tag_incr(1);

	// READ_ATOMIC(I), RSP_DATA(IMADW), RSP_INVACK(IMAW)
	op(READ_ATOMIC, MISS, DATA_FIRST, RSP_DATA, N_CPU-1, 0, WORD, addr, 0, line_of_addr(addr.line), 0, 0, 0, 0);
	addr.tag_incr(1);

	// READ_ATOMIC(I), RSP_INVACK(IMADW), RSP_DATA(IMADW), RSP_INVACK(IMAW)
	// READ_ATOMIC with != address and ongoing atomic.
	op(READ_ATOMIC, MISS, DATA_HALFWAY, RSP_DATA, N_CPU-1, 0, WORD, addr, 0, line_of_addr(addr.line), 0, 0, 0, 0);
	// READ(XMW)
	op(READ, HIT, 0, 0, 0, 0, WORD, addr, 0, line_of_addr(addr.line), 0, 0, 0, 0);
	addr.tag_incr(1);

	// READ_ATOMIC(I), RSP_INVACK(IMADW), RSP_DATA(IMADW)
	op(READ_ATOMIC, MISS, DATA_LAST, RSP_DATA, N_CPU-1, 0, WORD, addr, 0, line_of_addr(addr.line), 0, 0, 0, 0);
	// WRITE(XMW)
	op(WRITE, HIT, 0, 0, 0, 0, WORD, addr, word++, 0, 0, 0, 0, 0);
	addr.tag_incr(1);
    }

    CACHE_REPORT_INFO("FWD_INV(ISD), FWD_GETS(IMAD), FWD_GETM(IMAD).");
    CACHE_REPORT_INFO("FWD_INV(S), FWD_GETS(M), FWD_GETM(M).");

    addr = addr4;
    word = word4;
    id = N_CPU-1;
    req_line = line_of_addr(addr.line);

    // FWD_INV(ISD), FWD_INV(S)
    op(READ, MISS, 0, RSP_DATA, 0, 0, WORD, addr, 0, req_line, FWD_STALL, FWD_INV, id--, 0);

    // FWD_GETM(IMAD), FWD_GETM(M)
    fwd_line = req_line;
    // CACHE_REPORT_VAR(sc_time_stamp(), "addr.w_off: ", addr.w_off);
    // CACHE_REPORT_VAR(sc_time_stamp(), "addr.b_off: ", addr.b_off);
    write_word(fwd_line, word, addr.w_off, addr.b_off, WORD);
    op(WRITE, MISS, 0, RSP_DATA, 0, 0, WORD, addr, word++, req_line, FWD_STALL, FWD_GETM, id++, fwd_line);

    // FWD_GETS(IMAD), FWD_GETS(M)
    // this leaves a line in shared state
    fwd_line = req_line;
    write_word(fwd_line, word, addr.w_off, addr.b_off, WORD);
    op(WRITE, MISS, 0, RSP_DATA, 0, 0, WORD, addr, word++, req_line, FWD_STALL, FWD_GETS, id--, fwd_line);

    // TODO FWD_GETS(IMADW), FWD_GETS(IMA), FWD_GETS(IMAW), FWD_GETM(IMADW), FWD_GETS(IMA), FWD_GETS(IMAW).

/***************/
/* from SHARED */
/***************/

    CACHE_REPORT_INFO("READ(S), WRITE(S), RSP_DATA(SMAD), RSP_INVACK(SMAD), RSP_INVACK(SMA)");
    CACHE_REPORT_INFO("FWD_GETS(SMAD), FWD_GETM(SMAD), FWD_INV(SMAD)");

    // READ(S), WRITE(S), FWD_GETS(SMAD), FWD_GETS(M)
    // this starts from a line in shared state
    op(READ, HIT, 0, 0, 0, 0, WORD, addr, 0, fwd_line, FWD_NONE, 0, 0, 0);
    fwd_line = req_line;
    write_word(fwd_line, word, addr.w_off, addr.b_off, WORD);
    op(WRITE, MISS, 0, RSP_DATA, 0, 0, WORD, addr, word++, req_line, FWD_STALL, FWD_GETS, id++, fwd_line);

    // WRITE(S), FWD_GETM(SMAD), FWD_GETM(M)
    fwd_line = req_line;
    write_word(fwd_line, word, addr.w_off, addr.b_off, WORD);
    op(WRITE, MISS, 0, RSP_DATA, 0, 0, WORD, addr, word++, req_line, FWD_STALL, FWD_GETM, id--, fwd_line);

    // TODO FWD_GETS(SMADW), FWD_GETS(SMA), FWD_GETS(SMAW), FWD_GETM(SMADW), FWD_GETS(SMA), FWD_GETS(SMAW).

    CACHE_REPORT_INFO("RSP_DATA(SMAD), RSP_INVACK(SMAD), RSP_INVACK(SMA), FWD_INV(SMAD).");

    addr = addr1;
    word = word1;

    // this starts from 4 lines in shared state and leaves them in modified state
    addr.tag_incr(1);
    req_line = line_of_addr(addr.line);
    op(WRITE, MISS, DATA_FIRST, RSP_DATA, N_CPU-2, 0, WORD, addr, word++, req_line, 0, 0, 0, 0);

    addr.tag_incr(2);
    req_line = line_of_addr(addr.line);
    op(WRITE, MISS, DATA_HALFWAY, RSP_DATA, N_CPU-1, 0, WORD, addr, word++, req_line, 0, 0, 0, 0);

    addr.tag_incr(2);
    req_line = line_of_addr(addr.line);
    op(WRITE, MISS, DATA_LAST, RSP_DATA, N_CPU-2, 0, WORD, addr, word++, req_line, 0, 0, 0, 0);

    addr.tag_incr(2);
    req_line = line_of_addr(addr.line);
    op(WRITE, MISS, 0, RSP_DATA, 0, 0, WORD, addr, word++, req_line, FWD_STALL, FWD_INV, id++, 0);

    CACHE_REPORT_INFO("READ_ATOM(S), RSP_DATA(SMADW), RSP_INVACK(SMADW), RSP_INVACK(SMAW).");
    CACHE_REPORT_INFO("FWD_INV(SMADW), FWD_GETS(XMW), FWD_GETM(XMW).");

    addr = addr4;
    word = word4;
    invack = N_CPU-1;

    // this starts from an empty set
    for (int i = 0; i < 8; i++) {
	op(READ, MISS, 0, RSP_DATA, 0, 0, WORD, addr, 0, line_of_addr(addr.line), 0, 0, 0, 0);
	addr.tag_incr(1);
    }

    addr = addr4;

    req_line = line_of_addr(addr.line);
    fwd_line = req_line;
    write_word(fwd_line, word, addr.w_off, addr.b_off, WORD);
    op(READ_ATOMIC, MISS, 0, RSP_DATA, 0, 0, WORD, addr, 0, req_line, 0, 0, 0, 0);
    op(WRITE_ATOMIC, HIT, 0, 0, 0, 0, WORD, addr, word++, 0, FWD_STALL_XMW, FWD_GETS, id--, fwd_line);

    addr.tag_incr(1);
    req_line = line_of_addr(addr.line);
    fwd_line = req_line;
    write_word(fwd_line, word, addr.w_off, addr.b_off, WORD);
    op(READ_ATOMIC, MISS, DATA_FIRST, RSP_DATA, invack, 0, WORD, addr, 0, req_line, 0, 0, 0, 0);
    op(WRITE_ATOMIC, HIT, 0, 0, 0, 0, WORD, addr, word++, 0, FWD_STALL_XMW, FWD_GETM, id++, fwd_line);

    addr.tag_incr(1);
    req_line = line_of_addr(addr.line);
    op(READ_ATOMIC, MISS, DATA_HALFWAY, RSP_DATA, invack, 0, WORD, addr, 0, req_line, 0, 0, 0, 0);

    addr.tag_incr(1);
    req_line = line_of_addr(addr.line);
    op(READ_ATOMIC, MISS, DATA_LAST, RSP_DATA, invack, 0, WORD, addr, 0, req_line, 0, 0, 0, 0);
    // this ends with 4 valid lines 


/**************************/
/* MODIFIED and EXCLUSIVE */
/**************************/

    // READ(E) and WRITE(E) have been already tested

    CACHE_REPORT_INFO("READ_ATOMIC(E), FWD_GETS(E), FWD_GETM(E).");

    addr = addr1;
    word = word1;

    // this starts from 4 lines in shared state and leaves them in modified state
    req_line = line_of_addr(addr.line);
    op(READ_ATOMIC, HIT, 0, 0, 0, 0, WORD, addr, 0, req_line, 0, 0, 0, 0);
    op(WRITE_ATOMIC, HIT, 0, 0, 0, 0, WORD, addr, word++, 0, 0, 0, 0, 0);
    write_word(req_line, word-1, addr.w_off, addr.b_off, WORD);
    op(READ, HIT, 0, 0, 0, 0, WORD, addr, 0, req_line, 0, 0, 0, 0);

    addr.tag_incr(2);
    req_line = line_of_addr(addr.line);
    op(READ, HIT, 0, 0, 0, 0, WORD, addr, 0, req_line, FWD_NOSTALL, FWD_GETS, id--, req_line);

    addr.tag_incr(2);
    req_line = line_of_addr(addr.line);
    op(READ, HIT, 0, 0, 0, 0, WORD, addr, 0, req_line, FWD_NOSTALL, FWD_GETM, id++, req_line);

    addr.tag_incr(1);
    req_line = line_of_addr(addr.line);
    write_word(req_line, word1 + 2, addr.w_off, addr.b_off, WORD);
    op(READ_ATOMIC, HIT, 0, 0, 0, 0, WORD, addr, 0, req_line, 0, 0, 0, 0);
    op(WRITE_ATOMIC, HIT, 0, 0, 0, 0, WORD, addr, word++, 0, 0, 0, 0, 0);
    write_word(req_line, word-1, addr.w_off, addr.b_off, WORD);
    op(READ, HIT, 0, 0, 0, 0, WORD, addr, 0, req_line, 0, 0, 0, 0);

    CACHE_REPORT_INFO("Flush all cache");

    flush(30); // 7 (addr1 set) + 8 (addr2 set) + 8 (addr3 set) + 7 (addr4 set)

/**********************/
/* Eviction and flush */
/**********************/    

    // evict(S), evict(E), evict(M), flush(S), flush(E), flush(M) 
    // are already tested in the first part.

    // End simulation
    sc_stop();
}

/*
 * Functions
 */

inline void l2_tb::reset_l2_test()
{
    l2_cpu_req_tb.reset_put();
    l2_fwd_in_tb.reset_put();
    l2_rsp_in_tb.reset_put();
    l2_flush_tb.reset_put();
    l2_rd_rsp_tb.reset_get();
    l2_inval_tb.reset_get();
    l2_req_out_tb.reset_get();
    l2_rsp_out_tb.reset_get();

    rpt = RPT_TB;

    wait();
}

void l2_tb::put_cpu_req(l2_cpu_req_t &cpu_req, cpu_msg_t cpu_msg, hsize_t hsize, 
			addr_t addr, word_t word)
{
    cpu_req.cpu_msg = cpu_msg;
    cpu_req.hsize = hsize;
    // TODO: vary data/opcode field
    cpu_req.hprot = DEFAULT_HPROT | CACHEABLE_MASK;
    cpu_req.addr = addr;
    cpu_req.word = word;

    rand_wait();

    l2_cpu_req_tb.put(cpu_req);

    if (rpt)
	CACHE_REPORT_VAR(sc_time_stamp(), "CPU_REQ", cpu_req);
}

void l2_tb::get_req_out(coh_msg_t coh_msg, addr_t addr, hprot_t hprot)
{
    l2_req_out_t req_out;

    req_out = l2_req_out_tb.get();

    if (req_out.coh_msg != coh_msg ||
	req_out.hprot   != hprot ||
	req_out.addr != addr) {

	CACHE_REPORT_ERROR("get req out", req_out.addr);
	CACHE_REPORT_ERROR("get req out gold", addr);
	CACHE_REPORT_ERROR("get req out", req_out.coh_msg);
	CACHE_REPORT_ERROR("get req out gold", coh_msg);
	CACHE_REPORT_ERROR("get req out", req_out.hprot);
	CACHE_REPORT_ERROR("get req out gold", hprot);
    }

    if (rpt)
	CACHE_REPORT_VAR(sc_time_stamp(), "REQ_OUT", req_out);
}

void l2_tb::get_rsp_out(coh_msg_t coh_msg, cache_id_t req_id, bool to_req, addr_t addr, 
			line_t line)
{
    l2_rsp_out_t rsp_out;

    rsp_out = l2_rsp_out_tb.get();

    if (rsp_out.coh_msg != coh_msg ||
	(rsp_out.req_id != req_id && to_req) ||
	rsp_out.addr != addr ||
	(rsp_out.line != line && rsp_out.coh_msg == RSP_DATA)) {

	CACHE_REPORT_ERROR("get rsp out", rsp_out.addr);
	CACHE_REPORT_ERROR("get rsp out gold", addr);
	CACHE_REPORT_ERROR("get rsp out", rsp_out.coh_msg);
	CACHE_REPORT_ERROR("get rsp out gold", coh_msg);
	CACHE_REPORT_ERROR("get rsp out", rsp_out.req_id);
	CACHE_REPORT_ERROR("get rsp out gold", req_id);
	CACHE_REPORT_ERROR("get rsp out", rsp_out.to_req);
	CACHE_REPORT_ERROR("get rsp out gold", to_req);
	CACHE_REPORT_ERROR("get rsp out", rsp_out.line);
	CACHE_REPORT_ERROR("get rsp out gold", line);
    }

    if (rpt)
	CACHE_REPORT_VAR(sc_time_stamp(), "RSP_OUT", rsp_out);
}

void l2_tb::put_fwd_in(coh_msg_t coh_msg, addr_t addr, cache_id_t req_id)
{
    l2_fwd_in_t fwd_in;
    
    fwd_in.coh_msg = coh_msg;
    fwd_in.addr = addr;
    fwd_in.req_id = req_id;

    l2_fwd_in_tb.put(fwd_in);

    if (rpt) CACHE_REPORT_VAR(sc_time_stamp(), "FWD_IN", fwd_in);
}

void l2_tb::put_rsp_in(coh_msg_t coh_msg, addr_t addr, line_t line, invack_cnt_t invack_cnt)
{
    l2_rsp_in_t rsp_in;
    
    rsp_in.coh_msg = coh_msg;
    rsp_in.addr = addr;
    rsp_in.invack_cnt = invack_cnt;
    rsp_in.line = line;

    // CACHE_REPORT_INFO("before put rsp in");

    l2_rsp_in_tb.put(rsp_in);

    // CACHE_REPORT_INFO("after put rsp in");

    if (rpt) CACHE_REPORT_VAR(sc_time_stamp(), "RSP_IN", rsp_in);
}

void l2_tb::get_rd_rsp(addr_breakdown_t addr, line_t line)
{
    l2_rd_rsp_t rd_rsp;

    l2_rd_rsp_tb.get(rd_rsp);

    if (rd_rsp.line != line) {
	CACHE_REPORT_ERROR("get rd rsp", rd_rsp.line);
	CACHE_REPORT_ERROR("get rd rsp gold", line);
    }

    if (rpt)
	CACHE_REPORT_VAR(sc_time_stamp(), "RD_RSP", rd_rsp);
}

void l2_tb::get_inval(addr_t addr)
{
    l2_inval_t inval;
    
    l2_inval_tb.get(inval);

    if (inval != addr) {
	CACHE_REPORT_ERROR("get inval", inval);
	CACHE_REPORT_ERROR("get inval gold", addr);
    }

    if (rpt)
	CACHE_REPORT_VAR(sc_time_stamp(), "INVAL", inval);
}


void l2_tb::op(cpu_msg_t cpu_msg, int beh, int rsp_beh, coh_msg_t rsp_msg, invack_cnt_t invack_cnt, 
	       coh_msg_t put_msg, hsize_t hsize, addr_breakdown_t req_addr, word_t req_word, 
	       line_t rsp_line, int fwd_beh, coh_msg_t fwd_msg, cache_id_t fwd_id, line_t fwd_line)
{
    l2_cpu_req_t cpu_req;
    addr_t cpu_addr;
    coh_msg_t coh_req, coh_rsp;
    
    if      (hsize == BYTE)     cpu_addr = req_addr.byte;
    else if (hsize == HALFWORD)	cpu_addr = req_addr.hword;
    else if (hsize == WORD)	cpu_addr = req_addr.word;
    else CACHE_REPORT_ERROR("Wrong hsize.", hsize);

    if (cpu_msg == READ) {
	coh_req = REQ_GETS;
    } else if (cpu_msg == WRITE || cpu_msg ==  READ_ATOMIC) {
	coh_req = REQ_GETM;
    }

    if (fwd_beh == FWD_STALL_XMW) {
	put_fwd_in(fwd_msg, req_addr.line, fwd_id);
	wait(); wait();
    }

    // CPU REQ
    put_cpu_req(cpu_req, cpu_msg, hsize, cpu_addr, req_word);

    if (beh == MISS_EVICT) {
	addr_breakdown_t req_addr_tmp = req_addr;
	req_addr_tmp.tag_decr(L2_WAYS); 

	// INVAL
	get_inval(req_addr_tmp.line);

	// REQ OUT (put)
	get_req_out(put_msg, req_addr_tmp.line, 0);

	// RSP IN (put ack)
	put_rsp_in(RSP_PUTACK, req_addr_tmp.line, 0, 0);

	wait();
    }

    if (beh == MISS || beh == MISS_EVICT) {
	// REQ OUT (get)
	get_req_out(coh_req, req_addr.line, cpu_req.hprot);

	// FWD IN (stall)
	if (fwd_beh == FWD_STALL) {
	    put_fwd_in(fwd_msg, req_addr.line, fwd_id);
	    wait(); wait();
	}
	
	// RSP IN (inv ack)
	if (invack_cnt && rsp_beh == DATA_FIRST) {
	    for (int i = 0; i < invack_cnt; i++) {
		put_rsp_in(RSP_INVACK, req_addr.line, 0, 0);
		wait();
	    }
	} else if (invack_cnt && rsp_beh == DATA_HALFWAY) {
	    for (int i = 0; i < invack_cnt / 2; i++) {
		put_rsp_in(RSP_INVACK, req_addr.line, 0, 0);
		wait();
	    }
	}

	wait();

	// RSP IN (data)
	put_rsp_in(rsp_msg, req_addr.line, rsp_line, invack_cnt);

	// RSP IN (inv ack)
	if (invack_cnt && rsp_beh == DATA_LAST) {
	    wait();
	    for (int i = 0; i < invack_cnt; i++) {
		put_rsp_in(RSP_INVACK, req_addr.line, 0, 0);
		wait();
	    }
	} else if (invack_cnt && rsp_beh == DATA_HALFWAY) {
	    wait();
	    for (int i = invack_cnt / 2; i < invack_cnt; i++) {
		put_rsp_in(RSP_INVACK, req_addr.line, 0, 0);
		wait();
	    }
	}
    }

    // RD RSP
    if (cpu_msg == READ || cpu_msg == READ_ATOMIC)
	get_rd_rsp(req_addr, rsp_line);

    // FWD IN
    if (fwd_beh == FWD_NOSTALL)
	    put_fwd_in(fwd_msg, req_addr.line, fwd_id);

    // RSP OUT, INVAL
    if (fwd_beh != FWD_NONE) {
	
	if (fwd_msg == FWD_INV) {
	    if (cpu_msg == READ) {
		get_inval(req_addr.line);
	    }
	    get_rsp_out(RSP_INVACK, fwd_id, 1, req_addr.line, 0);
	} else if (fwd_msg == FWD_GETS) {

	    get_rsp_out(RSP_DATA, fwd_id, 1, req_addr.line, fwd_line);

	    wait();

	    get_rsp_out(RSP_DATA, 0, 0, req_addr.line, fwd_line);

	} else { // fwd_msg == FWD_GETM

	    get_inval(req_addr.line);

	    get_rsp_out(RSP_DATA, fwd_id, 1, req_addr.line, fwd_line);
	}
    }
    
    wait();
}

void l2_tb::op_flush(coh_msg_t coh_msg, addr_t addr_line)
{
    get_req_out(coh_msg, addr_line, 0);

    put_rsp_in(RSP_PUTACK, addr_line, 0, 0);

    wait();
}

void l2_tb::flush(int n_lines)
{
    // issue flush
    l2_flush_tb.put(1);

    if (rpt)
	CACHE_REPORT_INFO("Flush put.");

    for (int i = 0; i < n_lines; ++i) {
	l2_req_out_t req_out = l2_req_out_tb.get();
	put_rsp_in(RSP_PUTACK, req_out.addr, 0, 0);
	wait();
    }

    while(!flush_done) wait();

    if (rpt)
	CACHE_REPORT_INFO("Flush done.");
}
