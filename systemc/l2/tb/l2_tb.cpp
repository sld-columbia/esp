/* Copyright 2017 Columbia University, SLD Group */

#include "l2_tb.hpp"

/*
 * Processes
 */

// #ifdef L2_DEBUG

// void l2_tb::l2_debug()
// {
//     sc_bv<ASSERT_WIDTH>   old_asserts  = 0;
//     sc_bv<ASSERT_WIDTH>   new_asserts  = 0;
//     sc_bv<BOOKMARK_WIDTH> old_bookmark = 0;
//     sc_bv<BOOKMARK_WIDTH> new_bookmark = 0;
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
void l2_tb::get_stats()
{
    l2_stats_tb.reset_get();

    wait();

    while(true) {
	
	bool tmp;

	l2_stats_tb.get(tmp);

	wait();
    }
}
#endif


void l2_tb::l2_test()
{
    const bool flush_partial = false;
    const bool flush_all = true;

    /*
     * Random seed
     */
    
    // initialize
    srand(time(NULL));

    /*
     * Local variables
     */

    // preparation variables
    addr_breakdown_t addr, addr1, addr2, addr3, addr4, addr_evict;
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

    /* T0.0) Simple read hits and misses. Fill 2 random sets. */
    CACHE_REPORT_INFO("T0.0) Read hits and misses. Fill a random set.");

    // preparation
    addr1 = rand_addr();

    // read misses (data and instructions)
    addr = addr1;

    for (int i = 0; i < L2_WAYS; ++i) {
	op(READ, MISS, 0, RSP_EDATA, 0, 0, WORD, addr, 0, line_of_addr(addr.line),
	   0, 0, 0, 0, 0, DATA);
	addr.tag_incr(1);
    }

    addr.set_incr(2); // move two sets ahead

    for (int i = 0; i < L2_WAYS; ++i) {
	op(READ, MISS, 0, RSP_DATA, 0, 0, WORD, addr, 0, line_of_addr(addr.line),
	   0, 0, 0, 0, 0, INSTR);
	addr.tag_incr(1);
    }

    // read hits (data and instructions)
    addr = addr1;

    for (int i = 0; i < L2_WAYS; ++i) {
	op(READ, HIT, 0, 0, 0, 0, WORD, addr, 0, line_of_addr(addr.line), 0, 0, 0, 0, 0, DATA);
	addr.tag_incr(1);
    }

    addr.set_incr(2); // move 2 sets ahead

    for (int i = 0; i < L2_WAYS; ++i) {
	op(READ, HIT, 0, 0, 0, 0, WORD, addr, 0, line_of_addr(addr.line), 0, 0, 0, 0, 0, INSTR);
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
	op(WRITE, HIT, 0, 0, 0, 0, WORD, addr, word, 0, 0, 0, 0, 0, 0, DATA);

	addr.tag_incr(1);
	word++;
    }

    // write hits (M)
    addr = addr1;
    word = word1;
    for (int i = 0; i < L2_WAYS; ++i) {
	op(WRITE, HIT, 0, 0, 0, 0, WORD, addr, word, 0, 0, 0, 0, 0, 0, DATA);

	addr.tag_incr(1);
	word++;
    }

    // next set
    addr.set_incr(1);

    // write misses
    for (int i = 0; i < L2_WAYS; ++i) {
	op(WRITE, MISS, 0, RSP_DATA, 0, 0, WORD, addr, word, line_of_addr(addr.line),
	   0, 0, 0, 0, 0, DATA);

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

	op(READ, HIT, 0, 0, 0, 0, WORD, addr, 0, line, 0, 0, 0, 0, 0, DATA);

	addr.tag_incr(1);
	word++;
    }

    /*
     * T1. Simple flush. 
     */
    CACHE_REPORT_INFO("T1) SIMPLE FLUSH.");    

    // issue partial flush, no instructions
    l2_flush_tb.put(flush_partial);

    // receive 1 PutM, send 1 PutAck
    addr = addr1;
    for (int i = 0; i < (2 * L2_WAYS); ++i) {
	if (i == L2_WAYS) addr.set_incr(1);

	op_flush(REQ_PUTM, addr.line);

	addr.tag_incr(1);
    }

    // issue total flush, instructions included
    l2_flush_tb.put(flush_all);

    addr = addr1;
    addr.set_incr(2);
    addr.tag_incr(L2_WAYS);

    for (int i = 0; i < L2_WAYS; ++i) {
	op_flush(REQ_PUTS, addr.line);
	addr.tag_incr(1);
    }

    wait();

    // verify writes correctness (read misses)
    addr = addr1;
    for (int i = 0; i < (2 * L2_WAYS); ++i) {
	if (i == L2_WAYS) addr.set_incr(1);

	op(READ, MISS, 0, RSP_EDATA, 0, 0, WORD, addr, 0, line_of_addr(addr.line),
	   0, 0, 0, 0, 0, DATA);

	addr.tag_incr(1);
    }

    // flush again
    l2_flush_tb.put(flush_partial);

    // // receive N_REQS PutM, send N_REQS PutAck
    // addr = addr1;
    // for (int i = 0; i < (2 * L2_WAYS) / N_REQS; ++i) {
    // 	if (i == L2_WAYS / N_REQS) addr.set_incr(1);

    // 	for (int j = 0; j < N_REQS; j++) {
    // 	    get_req_out(REQ_PUTS, addr.line, 0);
    // 	    wait();
    // 	    addr.tag_incr(1);
    // 	}

    // 	addr.tag_decr(N_REQS);

    // 	for (int j = 0; j < N_REQS; j++) {
    // 	    put_fwd_in(FWD_PUTACK, addr.line, 0);
    // 	    wait();
    // 	    addr.tag_incr(1);
    // 	}
    // }

    // This works also with 2 ways, unlike the part commented above
    addr = addr1;
    for (int i = 0; i < (2 * L2_WAYS); ++i) {
	if (i == L2_WAYS) addr.set_incr(1);

	get_req_out(REQ_PUTS, addr.line, 0);
	wait();

	put_fwd_in(FWD_PUTACK, addr.line, 0);
	wait();
	
	addr.tag_incr(1);
    }

    wait();

    /*
     * T2) Reads and writes. Fill whole cache.
     */
    CACHE_REPORT_INFO("T2) READS AND WRITES. FILL WHOLE CACHE.");

    CACHE_REPORT_INFO("T2.0) Fill 1/2 of sets by reading 1 word per line.");

    for (int wa = 0; wa < L2_WAYS; ++wa) {
    	for (int s = 0; s < L2_SETS/2; ++s) {
    	    addr.breakdown((wa << L2_TAG_RANGE_LO) + (s << SET_RANGE_LO));

	    op(READ, MISS, 0, RSP_EDATA, 0, 0, WORD, addr, 0, line_of_addr(addr.line), 
	       0, 0, 0, 0, 0, DATA);
    	}
    }

    CACHE_REPORT_INFO("T2.1) Write all words.");

    for (int wo = 0; wo < WORDS_PER_LINE; ++wo) {
    	for (int wa = 0; wa < L2_WAYS; ++wa) {
    	    for (int s = 0; s < L2_SETS; ++s) {
    		addr.breakdown((wo << W_OFF_RANGE_LO) + (wa << L2_TAG_RANGE_LO) + 
				   (s << SET_RANGE_LO));
		word = addr.word;

    		if (s >= L2_SETS/2 && wo == 0) {
		    op(WRITE, MISS, 0, RSP_DATA, 0, 0, WORD, addr, word, line_of_addr(addr.line), 
		       0, 0, 0, 0, 0, DATA);
    		} else {
		    op(WRITE, HIT, 0, 0, 0, 0, WORD, addr, word, 0, 0, 0, 0, 0, 0, DATA);
		}
    	    }
    	}
    }

    CACHE_REPORT_INFO("T2.2) Overwrite the half words per line of half sets.");

    for (int wo = 0; wo < WORDS_PER_LINE/2; ++wo) {
    	for (int wa = 0; wa < L2_WAYS; ++wa) {
    	    for (int s = 0; s < L2_SETS/2; ++s) {
    		addr.breakdown((wo << W_OFF_RANGE_LO) + (wa << L2_TAG_RANGE_LO) + (s << SET_RANGE_LO));
		word = addr.word + 1;

		op(WRITE, HIT, 0, 0, 0, 0, WORD, addr, word, 0, 0, 0, 0, 0, 0, DATA);
    	    }
    	}
    }

    CACHE_REPORT_INFO("T2.3) Read and check all words.");

    for (int wa = 0; wa < L2_WAYS; ++wa) {
	for (int s = 0; s < L2_SETS; ++s) {
	    addr.breakdown((wa << L2_TAG_RANGE_LO) + (s << SET_RANGE_LO));
	    line = line_of_addr(addr.line);

	    int wo;
	    if (s < L2_SETS/2) {
		for (wo = 0; wo < WORDS_PER_LINE/2; ++wo) {
		    write_word(line, addr.line + (wo << W_OFF_RANGE_LO) + 1, wo, 0, WORD);
		}
	    }

	    op(READ, HIT, 0, 0, 0, 0, WORD, addr, 0, line, 0, 0, 0, 0, 0, DATA);
	}
    }

    /*
     * T3) Flush whole cache.
     */
    CACHE_REPORT_INFO("T3) Flush whole cache.");    

    // issue flush
    l2_flush_tb.put(flush_all);

    // receive 1 PutM, send 1 PutAck
    for (int s = 0; s < L2_SETS; ++s) {
	for (int wa = 0; wa < L2_WAYS; ++wa) {
	    addr.breakdown((wa << L2_TAG_RANGE_LO) + (s << SET_RANGE_LO));

	    op_flush(REQ_PUTM, addr.line);
	}
    }

    wait();

    /*
     * T4) Less-than-word operations.
     */
    CACHE_REPORT_INFO("T4) Less-than-word reads and writes. Operations on a single set.");

    addr1 = rand_addr();

    CACHE_REPORT_INFO("T4.0) Byte and Halfword Read Miss.");

    addr = addr1;
    op(READ, MISS, 0, RSP_EDATA, 0, 0, BYTE, addr, 0, line_of_addr(addr.line), 0, 0, 0, 0, 0, DATA);

    addr.tag_incr(1);
    op(READ, MISS, 0, RSP_EDATA, 0, 0, HALFWORD, addr, 0, line_of_addr(addr.line),
       0, 0, 0, 0, 0, DATA);


    CACHE_REPORT_INFO("T4.1) Byte and Halfword Read Hit.");

    addr = addr1;
    op(READ, HIT, 0, 0, 0, 0, BYTE, addr, 0, line_of_addr(addr.line), 0, 0, 0, 0, 0, DATA);

    addr.tag_incr(1);
    op(READ, HIT, 0, 0, 0, 0, HALFWORD, addr, 0, line_of_addr(addr.line), 0, 0, 0, 0, 0, DATA);


    CACHE_REPORT_INFO("T4.2) Byte and Halfword Write Hit.");

    addr = addr1;
    op(WRITE, HIT, 0, 0, 0, 0, BYTE, addr, 0, 0, 0, 0, 0, 0, 0, DATA);

    addr.tag_incr(1);
    op(WRITE, HIT, 0, 0, 0, 0, HALFWORD, addr, 0, 0, 0, 0, 0, 0, 0, DATA);


    CACHE_REPORT_INFO("T4.3) Byte and Halfword Write Miss.");

    addr = addr1;
    addr.set_incr(1);
    op(WRITE, MISS, 0, RSP_DATA, 0, 0, BYTE, addr, 0, line_of_addr(addr.line), 0, 0, 0, 0, 0, DATA);

    addr.tag_incr(1);
    op(WRITE, MISS, 0, RSP_DATA, 0, 0, HALFWORD, addr, 0, line_of_addr(addr.line),
       0, 0, 0, 0, 0, DATA);


    CACHE_REPORT_INFO("T4.4) Verify writes.");

    offset_t off_tmp0, off_tmp1;

    addr = addr1;
    line = line_of_addr(addr.line);
    off_tmp0 = addr.w_off * BYTES_PER_WORD + addr.b_off;
    off_tmp1 = off_tmp0 + BYTES_PER_WORD - 2 * addr.b_off - 1;
    line.range(off_tmp1 * 8 + 7, off_tmp1 * 8) = 0;
    op(READ, HIT, 0, 0, 0, 0, WORD, addr, 0, line, 0, 0, 0, 0, 0, DATA);

    addr.tag_incr(1);
    off_tmp0 = addr.w_off * BYTES_PER_WORD + addr.b_off;
    off_tmp0.range(0,0) = 0;
    if (off_tmp0.range(B_OFF_RANGE_HI,B_OFF_RANGE_HI) == 0)
	off_tmp0.range(B_OFF_RANGE_HI,B_OFF_RANGE_HI) = 1;
    else
	off_tmp0.range(B_OFF_RANGE_HI,B_OFF_RANGE_HI) = 0;
    line = line_of_addr(addr.line);
    line.range(off_tmp0 * 8 + BITS_PER_HALFWORD - 1, off_tmp0 * 8) = 0;
    op(READ, HIT, 0, 0, 0, 0, WORD, addr, 0, line, 0, 0, 0, 0, 0, DATA);

    addr = addr1;
    addr.set_incr(1);
    line = line_of_addr(addr.line);
    off_tmp0 = addr.w_off * BYTES_PER_WORD + addr.b_off;
    off_tmp1 = off_tmp0 + BYTES_PER_WORD - 2 * addr.b_off - 1;
    line.range(off_tmp1 * 8 + 7, off_tmp1 * 8) = 0;
    op(READ, HIT, 0, 0, 0, 0, WORD, addr, 0, line, 0, 0, 0, 0, 0, DATA);

    addr.tag_incr(1);
    off_tmp0 = addr.w_off * BYTES_PER_WORD + addr.b_off;
    off_tmp0.range(0,0) = 0;
    if (off_tmp0.range(B_OFF_RANGE_HI,B_OFF_RANGE_HI) == 0)
	off_tmp0.range(B_OFF_RANGE_HI,B_OFF_RANGE_HI) = 1;
    else
	off_tmp0.range(B_OFF_RANGE_HI,B_OFF_RANGE_HI) = 0;
    line = line_of_addr(addr.line);   
    line.range(off_tmp0 * 8 + BITS_PER_HALFWORD - 1, off_tmp0 * 8) = 0;
    op(READ, HIT, 0, 0, 0, 0, WORD, addr, 0, line, 0, 0, 0, 0, 0, DATA);

    CACHE_REPORT_INFO("T4.5) Flush.");    

    // issue flush
    l2_flush_tb.put(flush_all);

    for (int i = 0; i < 4; ++i) {
	l2_req_out_t req_out = l2_req_out_tb.get();
	addr_t tmp_addr = req_out.addr << OFFSET_BITS;
	put_fwd_in(FWD_PUTACK, tmp_addr, 0);
	wait();
    }

    wait();

    /*
     * T5) Evictions.
     */
    CACHE_REPORT_INFO("T5) EVICTIONS.");

    CACHE_REPORT_INFO("T5.0) Evict twice a whole set.");

    // preparation
    addr1 = rand_addr();
    addr = addr1;

    for (int i = 0; i < L2_WAYS; ++i) {
	op(READ, MISS, 0, RSP_DATA, 0, 0, WORD, addr, 0, line_of_addr(addr.line), 0, 0, 0, 0, 0, DATA);

	addr.tag_incr(1);
    }

    for (int i = 0; i < L2_WAYS; ++i) {
	op(READ, MISS_EVICT, 0, RSP_EDATA, 0, REQ_PUTS, WORD, addr, 0, line_of_addr(addr.line), 
	   0, 0, 0, 0, 0, DATA);

	addr.tag_incr(1);
    }

    for (int i = 0; i < L2_WAYS; ++i) {
	op(WRITE, MISS_EVICT, 0, RSP_DATA, 0, REQ_PUTS, WORD, addr, addr.word, 
	   line_of_addr(addr.line), 0, 0, 0, 0, 0, DATA);

	addr.tag_incr(1);
    }

    for (int i = 0; i < L2_WAYS; ++i) {
	op(READ, MISS_EVICT, 0, RSP_EDATA, 0, REQ_PUTM, WORD, addr, 0, line_of_addr(addr.line), 
	   0, 0, 0, 0, 0, DATA);

	addr.tag_incr(1);
    }

    CACHE_REPORT_INFO("T5.1) Evict stalls.");

    addr1 = addr;
    addr.tag_decr(L2_WAYS);
    addr_breakdown_t addr_evict1 = addr;
    addr.set_incr(1);
    addr2 = addr;

    put_cpu_req(cpu_req1, READ, WORD, addr1.word, 0, DATA);
    get_inval(addr_evict1.line);
    get_req_out(REQ_PUTS, addr_evict1.line, 0);

    wait();

    put_cpu_req(cpu_req2, READ, WORD, addr2.word, 0, DATA);

    put_fwd_in(FWD_PUTACK, addr_evict1.line, 0);
    get_req_out(REQ_GETS, addr1.line, cpu_req1.hprot);

    wait();

    put_rsp_in(RSP_EDATA, addr1.line, line_of_addr(addr1.line), 0);
    get_rd_rsp(line_of_addr(addr1.line));

    get_req_out(REQ_GETS, addr2.line, cpu_req2.hprot);

    wait();

    put_rsp_in(RSP_EDATA, addr2.line, line_of_addr(addr2.line), 0);
    get_rd_rsp(line_of_addr(addr2.line));

    CACHE_REPORT_INFO("T5.2) Flush.");    

    // issue flush
    l2_flush_tb.put(flush_all);

    for (int i = 0; i < L2_WAYS + 1; ++i) {
	l2_req_out_t req_out = l2_req_out_tb.get();
	addr_t tmp_addr = req_out.addr << OFFSET_BITS;
	put_fwd_in(FWD_PUTACK, tmp_addr, 0);
	wait();
    }

    wait();

    /*
     * T6) Pipelined requests.
     */

    CACHE_REPORT_INFO("T6) PIPELINED REQUESTS.");

    CACHE_REPORT_INFO("T6.0) One read and multiple writes pipelined. Max requests stall.");

    addr1 = rand_addr();
    addr = addr1;
    int n_reqs = std::min(N_REQS, L2_SETS);

    // Issue n_reqs + 1 requests

    put_cpu_req(cpu_req, READ, WORD, addr.word, 0, DATA);
    get_req_out(REQ_GETS, addr.line, cpu_req.hprot);
    wait();

    for (int i = 0; i < n_reqs - 1; i++) {
	addr.set_incr(1);
	put_cpu_req(cpu_req, WRITE, WORD, addr.word, 0, DATA);
	get_req_out(REQ_GETM, addr.line, cpu_req.hprot);
	wait();
    }

    addr.set_incr(1);
    put_cpu_req(cpu_req, WRITE, WORD, addr.word, 0, DATA);
    wait();

    // Respond to n_reqs requests
    addr.set_decr(n_reqs);
    put_rsp_in(RSP_EDATA, addr.line, line_of_addr(addr.line), 0);
    get_rd_rsp(line_of_addr(addr.line));
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

	put_cpu_req(cpu_req, READ, WORD, addr.word, 0, DATA);
	line = line_of_addr(addr.line);
	line.range(addr.w_off*ADDR_BITS + ADDR_BITS - 1, addr.w_off*ADDR_BITS) = 0;
	get_rd_rsp(line);
	wait();
    }

    CACHE_REPORT_INFO("T6.2) Flush.");

    // issue flush
    l2_flush_tb.put(flush_all);

    for (int i = 0; i < n_reqs + 1; ++i) {
	l2_req_out_t req_out = l2_req_out_tb.get();
	addr_t tmp_addr = req_out.addr << OFFSET_BITS;
	put_fwd_in(FWD_PUTACK, tmp_addr, 0);
	wait();
    }

    wait();

/*
 * T7) Test every case of the Cache Coherence protocol
 */
    CACHE_REPORT_INFO("T7) Test every case of the Cache Coherence protocol.");

    // preparation
    do {
	addr1 = rand_addr();
	addr2 = rand_addr();
	addr3 = rand_addr();
	addr4 = rand_addr();
    } while (addr1.set == addr2.set || addr1.set == addr3.set || addr1.set == addr4.set || 
	     addr2.set == addr3.set || addr2.set == addr4.set || addr3.set == addr4.set);

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
	op(READ, MISS, 0, RSP_EDATA, 0, 0, WORD, addr, 0, line_of_addr(addr.line),
	   0, 0, 0, 0, 0, DATA);
	addr.tag_incr(1);

	// READ(I), RSP_DATA(ISD)
	op(READ, MISS, 0, RSP_DATA, 0, 0, WORD, addr, 0, line_of_addr(addr.line), 0, 0, 0, 0, 0, DATA);
	addr.tag_incr(1);
    }

    CACHE_REPORT_INFO("WRITE(I), RSP_DATA(IMAD), RSP_INVACK(IMAD), RSP_INVACK(IMA).");

    addr = addr2;
    word = word2;

    // This leaves a set with 8 MODIFIED lines
    for (int i = 0; i < 2; i++) { // Assuming 8 ways
	// WRITE(I), RSP_DATA(IMAD)
	op(WRITE, MISS, 0, RSP_DATA, 0, 0, WORD, addr, word++, line_of_addr(addr.line), 
	   0, 0, 0, 0, 0, DATA);
	addr.tag_incr(1);

	// WRITE(I), RSP_DATA(IMAD), RSP_INVACK(IMA)
	op(WRITE, MISS, DATA_FIRST, RSP_DATA, MAX_N_L2-1, 0, WORD, addr, word++, 
	   line_of_addr(addr.line), 0, 0, 0, 0, 0, DATA);
	addr.tag_incr(1);

	// WRITE(I), RSP_INVACK(IMAD), RSP_DATA(IMAD), RSP_INVACK(IMA)
	op(WRITE, MISS, DATA_HALFWAY, RSP_DATA, MAX_N_L2-1, 0, WORD, addr, word++,
	   line_of_addr(addr.line), 0, 0, 0, 0, 0, DATA);
	addr.tag_incr(1);

	// WRITE(I), RSP_INVACK(IMAD), RSP_DATA(IMAD)
	op(WRITE, MISS, DATA_LAST, RSP_DATA, MAX_N_L2-1, 0, WORD, addr, word++, 
	   line_of_addr(addr.line), 0, 0, 0, 0, 0, DATA);
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
	op(READ_ATOMIC, MISS, 0, RSP_DATA, 0, 0, WORD, addr, 0, line_of_addr(addr.line), 
	   0, 0, 0, 0, 0, DATA);
	// READ_ATOMIC(XMW)
	op(READ_ATOMIC, HIT, 0, 0, 0, 0, WORD, addr, 0, line_of_addr(addr.line), 0, 0, 0, 0, 0, DATA);
	// WRITE_ATOM(XMW)
	op(WRITE_ATOMIC, HIT, 0, 0, 0, 0, WORD, addr, word++, 0, 0, 0, 0, 0, 0, DATA);
	addr.tag_incr(1);

	// READ_ATOMIC(I), RSP_DATA(IMADW), RSP_INVACK(IMAW)
	op(READ_ATOMIC, MISS, DATA_FIRST, RSP_DATA, MAX_N_L2-1, 0, WORD, addr, 0,
	   line_of_addr(addr.line), 0, 0, 0, 0, 0, DATA);
	addr.tag_incr(1);

	// READ_ATOMIC(I), RSP_INVACK(IMADW), RSP_DATA(IMADW), RSP_INVACK(IMAW)
	// READ_ATOMIC with != address and ongoing atomic.
	op(READ_ATOMIC, MISS, DATA_HALFWAY, RSP_DATA, MAX_N_L2-1, 0, WORD, addr, 0, 
	   line_of_addr(addr.line), 0, 0, 0, 0, 0, DATA);
	// READ(XMW)
	op(READ, HIT, 0, 0, 0, 0, WORD, addr, 0, line_of_addr(addr.line), 0, 0, 0, 0, 0, DATA);
	addr.tag_incr(1);

	// READ_ATOMIC(I), RSP_INVACK(IMADW), RSP_DATA(IMADW)
	op(READ_ATOMIC, MISS, DATA_LAST, RSP_DATA, MAX_N_L2-1, 0, WORD, addr, 0,
	   line_of_addr(addr.line), 0, 0, 0, 0, 0, DATA);
	// WRITE(XMW)
	op(WRITE, HIT, 0, 0, 0, 0, WORD, addr, word++, 0, 0, 0, 0, 0, 0, DATA);
	addr.tag_incr(1);
    }

    CACHE_REPORT_INFO("FWD_INV(ISD), FWD_GETS(IMAD), FWD_GETM(IMAD).");
    CACHE_REPORT_INFO("FWD_INV(S), FWD_GETS(M), FWD_GETM(M).");

    addr = addr4;
    word = word4;
    id = MAX_N_L2-1;
    req_line = line_of_addr(addr.line);

    // FWD_INV(ISD), FWD_INV(S)
    op(READ, MISS, 0, RSP_DATA, 0, 0, WORD, addr, 0, req_line, FWD_STALL, FWD_INV, 0, id--, 0, DATA);

    // FWD_GETM(IMAD), FWD_GETM(M)
    fwd_line = req_line;
    write_word(fwd_line, word, addr.w_off, addr.b_off, WORD);
    op(WRITE, MISS, 0, RSP_DATA, 0, 0, WORD, addr, word++, req_line, FWD_STALL, FWD_GETM, 0, 
       id++, fwd_line, DATA);

    // FWD_GETS(IMAD), FWD_GETS(M)
    // this leaves a line in shared state
    fwd_line = req_line;
    write_word(fwd_line, word, addr.w_off, addr.b_off, WORD);
    op(WRITE, MISS, 0, RSP_DATA, 0, 0, WORD, addr, word++, req_line, FWD_STALL, FWD_GETS, 0, 
       id--, fwd_line, DATA);

    // TODO FWD_GETS(IMADW), FWD_GETS(IMA), FWD_GETS(IMAW), FWD_GETM(IMADW),
    // FWD_GETS(IMA), FWD_GETS(IMAW).

/***************/
/* from SHARED */
/***************/

    CACHE_REPORT_INFO("READ(S), WRITE(S), RSP_DATA(SMAD), RSP_INVACK(SMAD), RSP_INVACK(SMA)");
    CACHE_REPORT_INFO("FWD_GETS(SMAD), FWD_GETM(SMAD), FWD_INV(SMAD)");

    // READ(S), WRITE(S), FWD_GETS(SMAD), FWD_GETS(M)
    // this starts from a line in shared state
    op(READ, HIT, 0, 0, 0, 0, WORD, addr, 0, fwd_line, FWD_NONE, 0, 0, 0, 0, DATA);
    fwd_line = req_line;
    write_word(fwd_line, word, addr.w_off, addr.b_off, WORD);
    op(WRITE, MISS, 0, RSP_DATA, 0, 0, WORD, addr, word++, req_line, FWD_STALL, 
       FWD_GETS, 0, id++, fwd_line, DATA);

    // WRITE(S), FWD_GETM(SMAD), FWD_GETM(M)
    fwd_line = req_line;
    write_word(fwd_line, word, addr.w_off, addr.b_off, WORD);
    op(WRITE, MISS, 0, RSP_DATA, 0, 0, WORD, addr, word++, req_line, FWD_STALL, FWD_GETM, MODIFIED, 
       id--, fwd_line, DATA);

    // TODO FWD_GETS(SMADW), FWD_GETS(SMA), FWD_GETS(SMAW), FWD_GETM(SMADW),
    // FWD_GETS(SMA), FWD_GETS(SMAW).

    CACHE_REPORT_INFO("RSP_DATA(SMAD), RSP_INVACK(SMAD), RSP_INVACK(SMA), FWD_INV(SMAD).");

    addr = addr1;
    word = word1;

    // this starts from 4 lines in shared state and leaves them in modified state
    addr.tag_incr(1);
    req_line = line_of_addr(addr.line);
    op(WRITE, MISS, DATA_FIRST, RSP_DATA, MAX_N_L2-2, 0, WORD, addr, word++, req_line, 
       0, 0, 0, 0, 0, DATA);

    addr.tag_incr(2);
    req_line = line_of_addr(addr.line);
    op(WRITE, MISS, DATA_HALFWAY, RSP_DATA, MAX_N_L2-1, 0, WORD, addr, word++, req_line, 
       0, 0, 0, 0, 0, DATA);

    addr.tag_incr(2);
    req_line = line_of_addr(addr.line);
    op(WRITE, MISS, DATA_LAST, RSP_DATA, MAX_N_L2-2, 0, WORD, addr, word++, req_line, 
       0, 0, 0, 0, 0, DATA);

    addr.tag_incr(2);
    req_line = line_of_addr(addr.line);
    op(WRITE, MISS, 0, RSP_DATA, 0, 0, WORD, addr, word++, req_line, FWD_STALL, FWD_INV,
       0,        id++, 0, DATA);

    CACHE_REPORT_INFO("READ_ATOM(S), RSP_DATA(SMADW), RSP_INVACK(SMADW), RSP_INVACK(SMAW).");
    CACHE_REPORT_INFO("FWD_INV(SMADW), FWD_GETS(XMW), FWD_GETM(XMW).");

    addr = addr4;
    word = word4;
    invack = MAX_N_L2-1;

    // this starts from an empty set
    for (int i = 0; i < 8; i++) {
	op(READ, MISS, 0, RSP_DATA, 0, 0, WORD, addr, 0, line_of_addr(addr.line), 0, 0, 0, 0, 0, DATA);
	addr.tag_incr(1);
    }

    addr = addr4;

    req_line = line_of_addr(addr.line);
    fwd_line = req_line;
    write_word(fwd_line, word, addr.w_off, addr.b_off, WORD);
    op(READ_ATOMIC, MISS, 0, RSP_DATA, 0, 0, WORD, addr, 0, req_line, 0, 0, 0, 0, 0, DATA);
    op(WRITE_ATOMIC, HIT, 0, 0, 0, 0, WORD, addr, word++, 0, FWD_STALL_XMW, FWD_GETS, 0,
       id--, fwd_line, DATA);

    addr.tag_incr(1);
    req_line = line_of_addr(addr.line);
    fwd_line = req_line;
    write_word(fwd_line, word, addr.w_off, addr.b_off, WORD);
    op(READ_ATOMIC, MISS, DATA_FIRST, RSP_DATA, invack, 0, WORD, addr, 0, req_line,
       0, 0, 0, 0, 0, DATA);
    op(WRITE_ATOMIC, HIT, 0, 0, 0, 0, WORD, addr, word++, 0, FWD_STALL_XMW, FWD_GETM, 0,
       id++, fwd_line, DATA);

    addr.tag_incr(1);
    req_line = line_of_addr(addr.line);
    op(READ_ATOMIC, MISS, DATA_HALFWAY, RSP_DATA, invack, 0, WORD, addr, 0, req_line,
       0, 0, 0, 0, 0, DATA);

    addr.tag_incr(1);
    req_line = line_of_addr(addr.line);
    op(READ_ATOMIC, MISS, DATA_LAST, RSP_DATA, invack, 0, WORD, addr, 0, req_line,
       0, 0, 0, 0, 0, DATA);
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
    op(READ_ATOMIC, HIT, 0, 0, 0, 0, WORD, addr, 0, req_line, 0, 0, 0, 0, 0, DATA);
    op(WRITE_ATOMIC, HIT, 0, 0, 0, 0, WORD, addr, word++, 0, 0, 0, 0, 0, 0, DATA);
    write_word(req_line, word-1, addr.w_off, addr.b_off, WORD);
    op(READ, HIT, 0, 0, 0, 0, WORD, addr, 0, req_line, 0, 0, 0, 0, 0, DATA);

    addr.tag_incr(2);
    req_line = line_of_addr(addr.line);
    op(READ, HIT, 0, 0, 0, 0, WORD, addr, 0, req_line, FWD_NOSTALL, FWD_GETS, 0, id--, req_line, DATA);

    addr.tag_incr(2);
    req_line = line_of_addr(addr.line);
    op(READ, HIT, 0, 0, 0, 0, WORD, addr, 0, req_line, FWD_NOSTALL, FWD_GETM, 0, id++, req_line, DATA);

    addr.tag_incr(1);
    req_line = line_of_addr(addr.line);
    write_word(req_line, word1 + 2, addr.w_off, addr.b_off, WORD);
    op(READ_ATOMIC, HIT, 0, 0, 0, 0, WORD, addr, 0, req_line, 0, 0, 0, 0, 0, DATA);
    op(WRITE_ATOMIC, HIT, 0, 0, 0, 0, WORD, addr, word++, 0, 0, 0, 0, 0, 0, DATA);
    write_word(req_line, word-1, addr.w_off, addr.b_off, WORD);
    op(READ, HIT, 0, 0, 0, 0, WORD, addr, 0, req_line, 0, 0, 0, 0, 0, DATA);

    CACHE_REPORT_INFO("Flush all cache");

    flush(30, flush_all); // 7 (addr1 set) + 8 (addr2 set) + 8 (addr3 set) + 7 (addr4 set)

/************/
/* Eviction */
/************/    

    // evict(S), evict(E), evict(M), flush(S), flush(E), flush(M) 
    // are already tested in the first part.

    CACHE_REPORT_INFO("FWD_INV(SIA), PUTACK(IIA), FWD_GETS(MIA), FWD_GETM(MIA)");

    addr = addr1;

    // fill a set
    for (int i = 0; i < L2_WAYS; ++i) {
	op(READ, MISS, 0, RSP_DATA, 0, 0, WORD, addr, 0, line_of_addr(addr.line), 0, 0, 0, 0, 0, DATA);

	addr.tag_incr(1);
    }

    op(READ, MISS_EVICT, 0, RSP_DATA, 0, REQ_PUTS, WORD, addr, 0, line_of_addr(addr.line), 
       FWD_STALL_EVICT, FWD_INV, 0, 0, 0, DATA);

    addr.set_incr(1);

    // fill a set
    for (int i = 0; i < L2_WAYS; ++i) {
	op(WRITE, MISS, 0, RSP_DATA, 0, 0, WORD, addr, addr.word, line_of_addr(addr.line),
	   0, 0, 0, 0, 0, DATA);

	addr.tag_incr(1);
    }

    addr_evict = addr;
    addr_evict.tag_decr(L2_WAYS);

    op(READ, MISS_EVICT, 0, RSP_DATA, 0, REQ_PUTM, WORD, addr, addr.word, line_of_addr(addr.line),
       FWD_STALL_EVICT, FWD_GETS, 0, 1, line_of_addr(addr_evict.line), DATA);

    addr.tag_incr(1);
    addr_evict.tag_incr(1);

    op(READ, MISS_EVICT, 0, RSP_DATA, 0, REQ_PUTM, WORD, addr, addr.word, line_of_addr(addr.line),
       FWD_STALL_EVICT, FWD_GETM, 0, 0, line_of_addr(addr_evict.line), DATA);

    CACHE_REPORT_INFO("Flush all cache");

    flush(16, flush_all); // 7 (addr1 set) + 8 (addr2 set) + 8 (addr3 set) + 7 (addr4 set)

/*
 * T8) Repeat some tests from T7 to test FWD_GETM_LLC and FWD_INV_LLC
 */
    CACHE_REPORT_INFO("T8) Repeat some tests from T7 to test FWD_GETM_LLC and FWD_INV_LLC.");

    // preparation
    do {
	addr1 = rand_addr();
	addr2 = rand_addr();
	addr3 = rand_addr();
	addr4 = rand_addr();
    } while (addr1.set == addr2.set || addr1.set == addr3.set || addr1.set == addr4.set || 
	     addr2.set == addr3.set || addr2.set == addr4.set || addr3.set == addr4.set);

    word1 = rand_word();
    word2 = rand_word();
    word3 = rand_word();
    word4 = rand_word();

    CACHE_REPORT_INFO("FWD_INV(ISD), FWD_GETS(IMAD), FWD_GETM_LLC(IMAD).");
    CACHE_REPORT_INFO("FWD_INV(S), FWD_GETS(M), FWD_GETM_LLC(M).");

/****************/
/* from INVALID */
/****************/

    CACHE_REPORT_INFO("READ(I), RSP_EDATA(ISD), RSP_DATA(ISD).");

    addr = addr1;
    
    // This leaves a set with 4 EXCLUSIVE and 4 SHARED lines
    for (int i = 0; i < 4; i++) { // Assuming 8 ways
	// READ(I), RSP_EDATA(ISD)
	op(READ, MISS, 0, RSP_EDATA, 0, 0, WORD, addr, 0, line_of_addr(addr.line),
	   0, 0, 0, 0, 0, DATA);
	addr.tag_incr(1);

	// READ(I), RSP_DATA(ISD)
	op(READ, MISS, 0, RSP_DATA, 0, 0, WORD, addr, 0, line_of_addr(addr.line), 0, 0, 0, 0, 0, DATA);
	addr.tag_incr(1);
    }

    CACHE_REPORT_INFO("WRITE(I), RSP_DATA(IMAD), RSP_INVACK(IMAD), RSP_INVACK(IMA).");

    addr = addr2;
    word = word2;

    // This leaves a set with 8 MODIFIED lines
    for (int i = 0; i < 2; i++) { // Assuming 8 ways
	// WRITE(I), RSP_DATA(IMAD)
	op(WRITE, MISS, 0, RSP_DATA, 0, 0, WORD, addr, word++, line_of_addr(addr.line), 
	   0, 0, 0, 0, 0, DATA);
	addr.tag_incr(1);

	// WRITE(I), RSP_DATA(IMAD), RSP_INVACK(IMA)
	op(WRITE, MISS, DATA_FIRST, RSP_DATA, MAX_N_L2-1, 0, WORD, addr, word++, 
	   line_of_addr(addr.line), 0, 0, 0, 0, 0, DATA);
	addr.tag_incr(1);

	// WRITE(I), RSP_INVACK(IMAD), RSP_DATA(IMAD), RSP_INVACK(IMA)
	op(WRITE, MISS, DATA_HALFWAY, RSP_DATA, MAX_N_L2-1, 0, WORD, addr, word++,
	   line_of_addr(addr.line), 0, 0, 0, 0, 0, DATA);
	addr.tag_incr(1);

	// WRITE(I), RSP_INVACK(IMAD), RSP_DATA(IMAD)
	op(WRITE, MISS, DATA_LAST, RSP_DATA, MAX_N_L2-1, 0, WORD, addr, word++, 
	   line_of_addr(addr.line), 0, 0, 0, 0, 0, DATA);
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
	op(READ_ATOMIC, MISS, 0, RSP_DATA, 0, 0, WORD, addr, 0, line_of_addr(addr.line), 
	   0, 0, 0, 0, 0, DATA);
	// READ_ATOMIC(XMW)
	op(READ_ATOMIC, HIT, 0, 0, 0, 0, WORD, addr, 0, line_of_addr(addr.line), 0, 0, 0, 0, 0, DATA);
	// WRITE_ATOM(XMW)
	op(WRITE_ATOMIC, HIT, 0, 0, 0, 0, WORD, addr, word++, 0, 0, 0, 0, 0, 0, DATA);
	addr.tag_incr(1);

	// READ_ATOMIC(I), RSP_DATA(IMADW), RSP_INVACK(IMAW)
	op(READ_ATOMIC, MISS, DATA_FIRST, RSP_DATA, MAX_N_L2-1, 0, WORD, addr, 0,
	   line_of_addr(addr.line), 0, 0, 0, 0, 0, DATA);
	addr.tag_incr(1);

	// READ_ATOMIC(I), RSP_INVACK(IMADW), RSP_DATA(IMADW), RSP_INVACK(IMAW)
	// READ_ATOMIC with != address and ongoing atomic.
	op(READ_ATOMIC, MISS, DATA_HALFWAY, RSP_DATA, MAX_N_L2-1, 0, WORD, addr, 0, 
	   line_of_addr(addr.line), 0, 0, 0, 0, 0, DATA);
	// READ(XMW)
	op(READ, HIT, 0, 0, 0, 0, WORD, addr, 0, line_of_addr(addr.line), 0, 0, 0, 0, 0, DATA);
	addr.tag_incr(1);

	// READ_ATOMIC(I), RSP_INVACK(IMADW), RSP_DATA(IMADW)
	op(READ_ATOMIC, MISS, DATA_LAST, RSP_DATA, MAX_N_L2-1, 0, WORD, addr, 0,
	   line_of_addr(addr.line), 0, 0, 0, 0, 0, DATA);
	// WRITE(XMW)
	op(WRITE, HIT, 0, 0, 0, 0, WORD, addr, word++, 0, 0, 0, 0, 0, 0, DATA);
	addr.tag_incr(1);
    }

    addr = addr4;
    word = word4;
    id = MAX_N_L2-1;
    req_line = line_of_addr(addr.line);

    // FWD_INV_LLC(ISD), FWD_INV_LLC(S)
    op(READ, MISS, 0, RSP_DATA, 0, 0, WORD, addr, 0, req_line, FWD_STALL, FWD_INV_LLC,
       0, id--, 0, DATA);

    // FWD_GETM_LLC(IMAD), FWD_GETM_LLC(M)
    fwd_line = req_line;
    write_word(fwd_line, word, addr.w_off, addr.b_off, WORD);
    op(WRITE, MISS, 0, RSP_DATA, 0, 0, WORD, addr, word++, req_line, FWD_STALL, FWD_GETM_LLC,
       MODIFIED, id++, fwd_line, DATA);

    // FWD_GETS(IMAD), FWD_GETS(M)
    // this leaves a line in shared state
    fwd_line = req_line;
    write_word(fwd_line, word, addr.w_off, addr.b_off, WORD);
    op(WRITE, MISS, 0, RSP_DATA, 0, 0, WORD, addr, word++, req_line, FWD_STALL, FWD_GETS, 0, 
       id--, fwd_line, DATA);

    // TODO FWD_GETS(IMADW), FWD_GETS(IMA), FWD_GETS(IMAW),
    // FWD_GETM_LLC(IMADW), FWD_GETS(IMA), FWD_GETS(IMAW).

/***************/
/* from SHARED */
/***************/

    CACHE_REPORT_INFO("READ(S), WRITE(S), RSP_DATA(SMAD), RSP_INVACK(SMAD), RSP_INVACK(SMA)");
    CACHE_REPORT_INFO("FWD_GETS(SMAD), FWD_GETM_LLC(SMAD), FWD_INV_LLC(SMAD)");

    // READ(S), WRITE(S), FWD_GETS(SMAD), FWD_GETS(M)
    // this starts from a line in shared state
    op(READ, HIT, 0, 0, 0, 0, WORD, addr, 0, fwd_line, FWD_NONE, 0, 0, 0, 0, DATA);
    fwd_line = req_line;
    write_word(fwd_line, word, addr.w_off, addr.b_off, WORD);
    op(WRITE, MISS, 0, RSP_DATA, 0, 0, WORD, addr, word++, req_line, FWD_STALL, 
       FWD_GETS, 0, id++, fwd_line, DATA);

    // WRITE(S), FWD_GETM_LLC(SMAD), FWD_GETM_LLC(M)
    fwd_line = req_line;
    write_word(fwd_line, word, addr.w_off, addr.b_off, WORD);
    op(WRITE, MISS, 0, RSP_DATA, 0, 0, WORD, addr, word++, req_line, FWD_STALL, FWD_GETM_LLC,
       MODIFIED, id--, fwd_line, DATA);

    // TODO FWD_GETS(SMADW), FWD_GETS(SMA), FWD_GETS(SMAW),
    // FWD_GETM_LLC(SMADW), FWD_GETS(SMA), FWD_GETS(SMAW).

    CACHE_REPORT_INFO("RSP_DATA(SMAD), RSP_INVACK(SMAD), RSP_INVACK(SMA), FWD_INV_LLC(SMAD).");

    addr = addr1;
    word = word1;

    // this starts from 4 lines in shared state and leaves them in modified state
    addr.tag_incr(1);
    req_line = line_of_addr(addr.line);
    op(WRITE, MISS, DATA_FIRST, RSP_DATA, MAX_N_L2-2, 0, WORD, addr, word++, req_line, 
       0, 0, 0, 0, 0, DATA);

    addr.tag_incr(2);
    req_line = line_of_addr(addr.line);
    op(WRITE, MISS, DATA_HALFWAY, RSP_DATA, MAX_N_L2-1, 0, WORD, addr, word++, req_line, 
       0, 0, 0, 0, 0, DATA);

    addr.tag_incr(2);
    req_line = line_of_addr(addr.line);
    op(WRITE, MISS, DATA_LAST, RSP_DATA, MAX_N_L2-2, 0, WORD, addr, word++, req_line, 
       0, 0, 0, 0, 0, DATA);

    addr.tag_incr(2);
    req_line = line_of_addr(addr.line);
    op(WRITE, MISS, 0, RSP_DATA, 0, 0, WORD, addr, word++, req_line, FWD_STALL, FWD_INV_LLC,
       0,        id++, 0, DATA);

    CACHE_REPORT_INFO("READ_ATOM(S), RSP_DATA(SMADW), RSP_INVACK(SMADW), RSP_INVACK(SMAW).");
    CACHE_REPORT_INFO("FWD_INV_LLC(SMADW), FWD_GETS(XMW), FWD_GETM_LLC(XMW).");

    addr = addr4;
    word = word4;
    invack = MAX_N_L2-1;

    // this starts from an empty set
    for (int i = 0; i < 8; i++) {
	op(READ, MISS, 0, RSP_DATA, 0, 0, WORD, addr, 0, line_of_addr(addr.line), 0, 0, 0, 0, 0, DATA);
	addr.tag_incr(1);
    }

    addr = addr4;

    req_line = line_of_addr(addr.line);
    fwd_line = req_line;
    write_word(fwd_line, word, addr.w_off, addr.b_off, WORD);
    op(READ_ATOMIC, MISS, 0, RSP_DATA, 0, 0, WORD, addr, 0, req_line, 0, 0, 0, 0, 0, DATA);
    op(WRITE_ATOMIC, HIT, 0, 0, 0, 0, WORD, addr, word++, 0, FWD_STALL_XMW, FWD_GETS, 0,
       id--, fwd_line, DATA);

    addr.tag_incr(1);
    req_line = line_of_addr(addr.line);
    fwd_line = req_line;
    write_word(fwd_line, word, addr.w_off, addr.b_off, WORD);
    op(READ_ATOMIC, MISS, DATA_FIRST, RSP_DATA, invack, 0, WORD, addr, 0, req_line,
       0, 0, 0, 0, 0, DATA);
    op(WRITE_ATOMIC, HIT, 0, 0, 0, 0, WORD, addr, word++, 0, FWD_STALL_XMW, FWD_GETM_LLC,
       MODIFIED, id++, fwd_line, DATA);

    addr.tag_incr(1);
    req_line = line_of_addr(addr.line);
    op(READ_ATOMIC, MISS, DATA_HALFWAY, RSP_DATA, invack, 0, WORD, addr, 0, req_line,
       0, 0, 0, 0, 0, DATA);

    addr.tag_incr(1);
    req_line = line_of_addr(addr.line);
    op(READ_ATOMIC, MISS, DATA_LAST, RSP_DATA, invack, 0, WORD, addr, 0, req_line,
       0, 0, 0, 0, 0, DATA);
    // this ends with 4 valid lines 

/**************************/
/* MODIFIED and EXCLUSIVE */
/**************************/

    // READ(E) and WRITE(E) have been already tested

    CACHE_REPORT_INFO("READ_ATOMIC(E), FWD_GETS(E), FWD_GETM_LLC(E).");

    addr = addr1;
    word = word1;

    // this starts from 4 lines in shared state and leaves them in modified state
    req_line = line_of_addr(addr.line);
    op(READ_ATOMIC, HIT, 0, 0, 0, 0, WORD, addr, 0, req_line, 0, 0, 0, 0, 0, DATA);
    op(WRITE_ATOMIC, HIT, 0, 0, 0, 0, WORD, addr, word++, 0, 0, 0, 0, 0, 0, DATA);
    write_word(req_line, word-1, addr.w_off, addr.b_off, WORD);
    op(READ, HIT, 0, 0, 0, 0, WORD, addr, 0, req_line, 0, 0, 0, 0, 0, DATA);

    addr.tag_incr(2);
    req_line = line_of_addr(addr.line);
    op(READ, HIT, 0, 0, 0, 0, WORD, addr, 0, req_line, FWD_NOSTALL, FWD_GETS, 0, id--, req_line, DATA);

    addr.tag_incr(2);
    req_line = line_of_addr(addr.line);
    op(READ, HIT, 0, 0, 0, 0, WORD, addr, 0, req_line, FWD_NOSTALL, FWD_GETM_LLC,
       EXCLUSIVE, id++, req_line, DATA);

    addr.tag_incr(1);
    req_line = line_of_addr(addr.line);
    write_word(req_line, word1 + 2, addr.w_off, addr.b_off, WORD);
    op(READ_ATOMIC, HIT, 0, 0, 0, 0, WORD, addr, 0, req_line, 0, 0, 0, 0, 0, DATA);
    op(WRITE_ATOMIC, HIT, 0, 0, 0, 0, WORD, addr, word++, 0, 0, 0, 0, 0, 0, DATA);
    write_word(req_line, word-1, addr.w_off, addr.b_off, WORD);
    op(READ, HIT, 0, 0, 0, 0, WORD, addr, 0, req_line, 0, 0, 0, 0, 0, DATA);

    CACHE_REPORT_INFO("Flush all cache");

    flush(30, flush_all); // 7 (addr1 set) + 8 (addr2 set) + 8 (addr3 set) + 7 (addr4 set)

/************/
/* Eviction */
/************/    

    // evict(S), evict(E), evict(M), flush(S), flush(E), flush(M) 
    // are already tested in the first part.

    CACHE_REPORT_INFO("FWD_INV_LLC(SIA), PUTACK(IIA), FWD_GETS(MIA), FWD_GETM_LLC(MIA)");

    addr = addr1;

    // fill a set
    for (int i = 0; i < L2_WAYS; ++i) {
	op(READ, MISS, 0, RSP_DATA, 0, 0, WORD, addr, 0, line_of_addr(addr.line), 0, 0, 0, 0, 0, DATA);

	addr.tag_incr(1);
    }

    op(READ, MISS_EVICT, 0, RSP_DATA, 0, REQ_PUTS, WORD, addr, 0, line_of_addr(addr.line), 
       FWD_STALL_EVICT, FWD_INV_LLC, 0, 0, 0, DATA);

    addr.set_incr(1);

    // fill a set
    for (int i = 0; i < L2_WAYS; ++i) {
	op(WRITE, MISS, 0, RSP_DATA, 0, 0, WORD, addr, addr.word, line_of_addr(addr.line),
	   0, 0, 0, 0, 0, DATA);

	addr.tag_incr(1);
    }

    addr_evict = addr;
    addr_evict.tag_decr(L2_WAYS);

    op(READ, MISS_EVICT, 0, RSP_DATA, 0, REQ_PUTM, WORD, addr, addr.word, line_of_addr(addr.line),
       FWD_STALL_EVICT, FWD_GETS, 0, 1, line_of_addr(addr_evict.line), DATA);

    addr.tag_incr(1);
    addr_evict.tag_incr(1);

    op(READ, MISS_EVICT, 0, RSP_DATA, 0, REQ_PUTM, WORD, addr, addr.word, line_of_addr(addr.line),
       FWD_STALL_EVICT, FWD_GETM_LLC, MODIFIED, 0, line_of_addr(addr_evict.line), DATA);

    CACHE_REPORT_INFO("Flush all cache");

    flush(13, flush_all); // 7 (addr1 set) + 8 (addr2 set) + 8 (addr3 set) + 7 (addr4 set)

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
			addr_t addr, word_t word, hprot_t hprot)
{
    cpu_req.cpu_msg = cpu_msg;
    cpu_req.hsize = hsize;
    cpu_req.hprot = hprot;
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
	req_out.addr != addr.range(TAG_RANGE_HI, SET_RANGE_LO)) {

	CACHE_REPORT_ERROR("get req out", req_out.addr);
	CACHE_REPORT_ERROR("get req out gold", addr.range(TAG_RANGE_HI, SET_RANGE_LO));
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
	rsp_out.addr != addr.range(TAG_RANGE_HI, SET_RANGE_LO) ||
	(rsp_out.line != line && rsp_out.coh_msg == RSP_DATA)) {

	CACHE_REPORT_ERROR("get rsp out", rsp_out.addr);
	CACHE_REPORT_ERROR("get rsp out gold", addr.range(TAG_RANGE_HI, SET_RANGE_LO));
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

void l2_tb::put_fwd_in(mix_msg_t coh_msg, addr_t addr, cache_id_t req_id)
{
    l2_fwd_in_t fwd_in;
    
    fwd_in.coh_msg = coh_msg;
    fwd_in.addr = addr.range(TAG_RANGE_HI, SET_RANGE_LO);
    fwd_in.req_id = req_id;

    l2_fwd_in_tb.put(fwd_in);

    if (rpt) CACHE_REPORT_VAR(sc_time_stamp(), "FWD_IN", fwd_in);
}

void l2_tb::put_rsp_in(coh_msg_t coh_msg, addr_t addr, line_t line, invack_cnt_t invack_cnt)
{
    l2_rsp_in_t rsp_in;
    
    rsp_in.coh_msg = coh_msg;
    rsp_in.addr = addr.range(TAG_RANGE_HI, SET_RANGE_LO);
    rsp_in.invack_cnt = invack_cnt;
    rsp_in.line = line;

    l2_rsp_in_tb.put(rsp_in);

    if (rpt) CACHE_REPORT_VAR(sc_time_stamp(), "RSP_IN", rsp_in);
}

void l2_tb::get_rd_rsp(line_t line)
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

    if (inval != addr.range(TAG_RANGE_HI, SET_RANGE_LO)) {
	CACHE_REPORT_ERROR("get inval", inval);
	CACHE_REPORT_ERROR("get inval gold", addr.range(TAG_RANGE_HI, SET_RANGE_LO));
    }

    if (rpt)
	CACHE_REPORT_VAR(sc_time_stamp(), "INVAL", inval);
}


void l2_tb::op(cpu_msg_t cpu_msg, int beh, int rsp_beh, coh_msg_t rsp_msg, invack_cnt_t invack_cnt, 
	       coh_msg_t put_msg, hsize_t hsize, addr_breakdown_t req_addr, word_t req_word, 
	       line_t rsp_line, int fwd_beh, mix_msg_t fwd_msg, state_t fwd_state, cache_id_t fwd_id, 
	       line_t fwd_line, hprot_t hprot)
{
    l2_cpu_req_t cpu_req;
    addr_t cpu_addr;
    coh_msg_t coh_req, coh_rsp;
    
    cpu_addr = req_addr.word + req_addr.b_off;

    if (hsize == BYTE) ;
    else if (hsize == HALFWORD)	cpu_addr.range(0, 0) = 0;
    else if (hsize == WORD)	cpu_addr.range(1, 0) = 0;
    else CACHE_REPORT_ERROR("Wrong hsize.", hsize);

    if (cpu_msg == READ) {
	coh_req = REQ_GETS;
    } else if (cpu_msg == WRITE || cpu_msg ==  READ_ATOMIC) {
	coh_req = REQ_GETM;
    }

    if (fwd_beh == FWD_STALL_XMW) {
	put_fwd_in(fwd_msg, req_addr.line, fwd_id);
	wait();
    }

    put_cpu_req(cpu_req, cpu_msg, hsize, cpu_addr, req_word, hprot);

    if (beh == MISS_EVICT) {
	addr_breakdown_t req_addr_tmp = req_addr;
	req_addr_tmp.tag_decr(L2_WAYS); 

	get_inval(req_addr_tmp.line);

	get_req_out(put_msg, req_addr_tmp.line, 0);

	if (fwd_beh == FWD_STALL_EVICT) {

	    put_fwd_in(fwd_msg, req_addr_tmp.line, fwd_id);

	    wait();

	    if (fwd_msg == FWD_INV) {

		get_rsp_out(RSP_INVACK, fwd_id, 1, req_addr_tmp.line, 0);

	    } else if (fwd_msg == FWD_GETS) {
		
		get_rsp_out(RSP_DATA, fwd_id, 1, req_addr_tmp.line, fwd_line);

		wait();

		get_rsp_out(RSP_DATA, 0, 0, req_addr_tmp.line, fwd_line);

	    } else if (fwd_msg == FWD_GETM) {

		get_rsp_out(RSP_DATA, fwd_id, 1, req_addr_tmp.line, fwd_line);

	    } else if (fwd_msg == FWD_INV_LLC) {
		// nothing to do

	    } else if (fwd_msg == FWD_GETM_LLC) {

		if (fwd_state == EXCLUSIVE) 
		    get_rsp_out(RSP_INVACK, 0, 0, req_addr_tmp.line, 0);

		else // MODIFIED
		    get_rsp_out(RSP_DATA, 0, 0, req_addr_tmp.line, fwd_line);
	    }
	}

	put_fwd_in(FWD_PUTACK, req_addr_tmp.line, 0);

	wait();
    }

    if (beh == MISS || beh == MISS_EVICT) {

	get_req_out(coh_req, req_addr.line, cpu_req.hprot);

	if (fwd_beh == FWD_STALL) {
	    put_fwd_in(fwd_msg, req_addr.line, fwd_id);
	    wait();
	}
	
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

	put_rsp_in(rsp_msg, req_addr.line, rsp_line, invack_cnt);

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

    if (cpu_msg == READ || cpu_msg == READ_ATOMIC)
	get_rd_rsp(rsp_line);

    if (fwd_beh == FWD_NOSTALL) {
	put_fwd_in(fwd_msg, req_addr.line, fwd_id);
	wait();
    }    

    if (fwd_beh != FWD_NONE && fwd_beh != FWD_STALL_EVICT) {
	
	if (fwd_msg == FWD_INV) {

	    if (cpu_msg == READ) {
		get_inval(req_addr.line);
	    }
	    get_rsp_out(RSP_INVACK, fwd_id, 1, req_addr.line, 0);

	} else if (fwd_msg == FWD_GETS) {

	    get_rsp_out(RSP_DATA, fwd_id, 1, req_addr.line, fwd_line);

	    wait();

	    get_rsp_out(RSP_DATA, 0, 0, req_addr.line, fwd_line);

	} else if (fwd_msg == FWD_GETM) {

	    get_inval(req_addr.line);

	    get_rsp_out(RSP_DATA, fwd_id, 1, req_addr.line, fwd_line);

	} else if (fwd_msg == FWD_INV_LLC) {

	    if (cpu_msg == READ) {
		get_inval(req_addr.line);
	    }

	} else if (fwd_msg == FWD_GETM_LLC) {

	    get_inval(req_addr.line);

	    if (fwd_state == EXCLUSIVE) 
		get_rsp_out(RSP_INVACK, 0, 0, req_addr.line, 0);
	    else // MODIFIED
		get_rsp_out(RSP_DATA, 0, 0, req_addr.line, fwd_line);
	}
    }
    
    wait();
}

void l2_tb::op_flush(coh_msg_t coh_msg, addr_t addr)
{
    get_req_out(coh_msg, addr, 0);

    put_fwd_in(FWD_PUTACK, addr, 0);

    wait();
}

void l2_tb::flush(int n_lines, bool is_flush_all)
{
    // issue flush
    l2_flush_tb.put(is_flush_all);

    for (int i = 0; i < n_lines; ++i) {
	l2_req_out_t req_out = l2_req_out_tb.get();
	addr_t tmp_addr = req_out.addr << OFFSET_BITS;
	put_fwd_in(FWD_PUTACK, tmp_addr, 0);
	wait();
    }

    wait();

    if (rpt)
	CACHE_REPORT_INFO("Flush done.");
}
