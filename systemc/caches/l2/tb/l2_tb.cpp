/* Copyright 2017 Columbia University, SLD Group */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
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

    // constants
    const word_t empty_word = 0;
    const line_t empty_line = 0;
    const hprot_t empty_hprot = 0;
    const addr_t empty_addr = 0;

    // preparation variables
    addr_breakdown_t addr, addr_tmp, addr1, addr2, addr3, addr4, addr5;
    word_t word, word_tmp;
    line_t line;

    l2_cpu_req_t cpu_req, cpu_req1, cpu_req2, cpu_req3, cpu_req4, cpu_req5;
    l2_req_out_t req_out;
    /*
     * Reset
     */

    reset_l2_test();


    /*
     * T0) Simple word reads and writes. No eviction. No pipelining.
     */
    CACHE_REPORT_INFO("T0) SIMPLE WORD READS AND WRITES.");

    /* T0.0) Simple read hits and misses. Fill a random set. */
    CACHE_REPORT_INFO("T0.0) Read hits and misses. Fill a random set.");

    // preparation
    addr = rand_addr();

    // read misses
    addr_tmp = addr;
    for (int i = 0; i < L2_WAYS; ++i) {
	op(READ, MISS, 0, WORD, CACHEABLE, addr_tmp, empty_word, make_line_of_addr(addr_tmp.line), RPT_TB);

	addr_tmp.tag_incr(1);
    }

    // read hits
    addr_tmp = addr;
    for (int i = 0; i < L2_WAYS; ++i) {
	op(READ, HIT, 0, WORD, CACHEABLE, addr_tmp, empty_word, make_line_of_addr(addr_tmp.line), RPT_TB);

	addr_tmp.tag_incr(1);
    }

    /* T0.1) Write hits and misses. Fill the set next to T0. */
    CACHE_REPORT_INFO("T0.1) Write hits and misses. Same and next sets wrt T0.");

    // preparation
    // addr =  same as before
    word = rand_word();

    // write hits
    addr_tmp = addr;
    word_tmp = word;
    for (int i = 0; i < L2_WAYS; ++i) {
	op(WRITE, HIT, 0, WORD, CACHEABLE, addr_tmp, word_tmp, empty_line, RPT_TB);

	addr_tmp.tag_incr(1);
	word_tmp++;
    }

    // next set
    addr_tmp.set_incr(1);

    // write misses
    for (int i = 0; i < L2_WAYS; ++i) {
	op(WRITE, MISS, 0, WORD, CACHEABLE, addr_tmp, word_tmp, make_line_of_addr(addr_tmp.line), RPT_TB);

	addr_tmp.tag_incr(1);
	word_tmp++;
    }

    // verify writes correctness (read hits)
    addr_tmp = addr;
    word_tmp = word;
    for (int i = 0; i < (2 * L2_WAYS); ++i) {
	if (i == L2_WAYS) addr_tmp.set_incr(1);

	line = make_line_of_addr(addr_tmp.line);
	write_word(line, word_tmp, addr_tmp.w_off, 0, WORD);

	op(READ, HIT, 0, WORD, CACHEABLE, addr_tmp, empty_word, line, RPT_TB);

	addr_tmp.tag_incr(1);
	word_tmp++;
    }

    /*
     * T1. Simple flush.
     */
    CACHE_REPORT_INFO("T1) SIMPLE FLUSH.");    

    // issue flush
    l2_flush_tb.put(1);

    // receive 1 PutM, send 1 PutAck
    addr_tmp = addr;
    for (int i = 0; i < (2 * L2_WAYS); ++i) {
	if (i == L2_WAYS) addr_tmp.set_incr(1);

	op_flush(REQ_PUTM, addr_tmp.line, RPT_TB);

	addr_tmp.tag_incr(1);
    }

    while(!flush_done) wait();

    // verify writes correctness (read misses)
    addr_tmp = addr;
    for (int i = 0; i < (2 * L2_WAYS); ++i) {
	if (i == L2_WAYS) addr_tmp.set_incr(1);

	op(READ, MISS, 0, WORD, CACHEABLE, addr_tmp, empty_word, make_line_of_addr(addr_tmp.line), RPT_TB);

	addr_tmp.tag_incr(1);
    }

    // flush again
    l2_flush_tb.put(1);

    // receive all PutS
    addr_tmp = addr;
    for (int i = 0; i < (2*L2_WAYS); ++i) {
	if (i == L2_WAYS) addr_tmp.set_incr(1);

    	get_req_out(REQ_PUTS, addr_tmp.line, empty_hprot, RPT_TB);
    	wait();

	addr_tmp.tag_incr(1);
    }

    // send all PutAck
    addr_tmp = addr;
    for (int i = 0; i < (2*L2_WAYS); ++i) {
	if (i == L2_WAYS) addr_tmp.set_incr(1);

    	put_rsp_in(RSP_PUTACK, addr_tmp.line, empty_line, RPT_TB);
    	wait();

	addr_tmp.tag_incr(1);
    }

    while(!flush_done) wait();

    /*
     * T2) Reads and writes. Fill whole cache.
     */
    CACHE_REPORT_INFO("T2) READS AND WRITES. FILL WHOLE CACHE.");

    CACHE_REPORT_INFO("T2.0) Fill 1/2 of sets by reading 1 word per line.");

    for (int wa = 0; wa < L2_WAYS; ++wa) {
    	for (int s = 0; s < SETS/2; ++s) {
    	    addr_tmp.breakdown((wa << TAG_RANGE_LO) + (s << SET_RANGE_LO));

	    op(READ, MISS, 0, WORD, CACHEABLE, addr_tmp, empty_word, make_line_of_addr(addr_tmp.line), RPT_TB);
    	}
    }

    CACHE_REPORT_INFO("T2.1) Write all words.");

    for (int wo = 0; wo < WORDS_PER_LINE; ++wo) {
    	for (int wa = 0; wa < L2_WAYS; ++wa) {
    	    for (int s = 0; s < SETS; ++s) {
    		addr_tmp.breakdown((wo << W_OFF_RANGE_LO) + (wa << TAG_RANGE_LO) + (s << SET_RANGE_LO));
		word_tmp = addr_tmp.word;

    		if (s >= SETS/2 && wo == 0) {
		    op(WRITE, MISS, 0, WORD, CACHEABLE, addr_tmp, word_tmp, make_line_of_addr(addr_tmp.line), RPT_TB);
    		} else {
		    op(WRITE, HIT, 0, WORD, CACHEABLE, addr_tmp, word_tmp, empty_line, RPT_TB);
		}
    	    }
    	}
    }

    CACHE_REPORT_INFO("T2.2) Overwrite the half words per line of half sets.");

    for (int wo = 0; wo < WORDS_PER_LINE/2; ++wo) {
    	for (int wa = 0; wa < L2_WAYS; ++wa) {
    	    for (int s = 0; s < SETS/2; ++s) {
    		addr_tmp.breakdown((wo << W_OFF_RANGE_LO) + (wa << TAG_RANGE_LO) + (s << SET_RANGE_LO));
		word_tmp = addr_tmp.word + 1;

		op(WRITE, HIT, 0, WORD, CACHEABLE, addr_tmp, word_tmp, empty_line, RPT_TB);
    	    }
    	}
    }

    CACHE_REPORT_INFO("T2.3) Read and check all words.");

    for (int wa = 0; wa < L2_WAYS; ++wa) {
	for (int s = 0; s < SETS; ++s) {
	    addr_tmp.breakdown((wa << TAG_RANGE_LO) + (s << SET_RANGE_LO));
	    line = make_line_of_addr(addr_tmp.line);

	    int wo;
	    if (s < SETS/2) {
		for (wo = 0; wo < WORDS_PER_LINE/2; ++wo) {
		    write_word(line, addr_tmp.line + (wo << W_OFF_RANGE_LO) + 1, wo, 0, WORD);
		}
	    }

	    op(READ, HIT, 0, WORD, CACHEABLE, addr_tmp, empty_word, line, RPT_TB);
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
	    addr_tmp.breakdown((wa << TAG_RANGE_LO) + (s << SET_RANGE_LO));

	    op_flush(REQ_PUTM, addr_tmp.line, RPT_TB);
	}
    }

    while(!flush_done) wait();

    /*
     * T4) Less-than-word operations.
     */
    CACHE_REPORT_INFO("T4) Less-than-word reads and writes. Operations on a single set.");

    addr = rand_addr();

    CACHE_REPORT_INFO("T4.0) Byte and Halfword Read Miss.");

    addr_tmp = addr;
    op(READ, MISS, 0, BYTE, CACHEABLE, addr_tmp, empty_word, make_line_of_addr(addr_tmp.line), RPT_TB);

    addr_tmp.tag_incr(1);
    op(READ, MISS, 0, HALFWORD, CACHEABLE, addr_tmp, empty_word, make_line_of_addr(addr_tmp.line), RPT_TB);


    CACHE_REPORT_INFO("T4.1) Byte and Halfword Read Hit.");

    addr_tmp = addr;
    op(READ, HIT, 0, BYTE, CACHEABLE, addr_tmp, empty_word, make_line_of_addr(addr_tmp.line), RPT_TB);

    addr_tmp.tag_incr(1);
    op(READ, HIT, 0, HALFWORD, CACHEABLE, addr_tmp, empty_word, make_line_of_addr(addr_tmp.line), RPT_TB);


    CACHE_REPORT_INFO("T4.2) Byte and Halfword Write Hit.");

    addr_tmp = addr;
    op(WRITE, HIT, 0, BYTE, CACHEABLE, addr_tmp, empty_word, empty_line, RPT_TB);

    addr_tmp.tag_incr(1);
    op(WRITE, HIT, 0, HALFWORD, CACHEABLE, addr_tmp, empty_word, empty_line, RPT_TB);


    CACHE_REPORT_INFO("T4.3) Byte and Halfword Write Miss.");

    addr_tmp.tag_incr(1);
    op(WRITE, MISS, 0, BYTE, CACHEABLE, addr_tmp, empty_word, make_line_of_addr(addr_tmp.line), RPT_TB);

    addr_tmp.tag_incr(1);
    op(WRITE, MISS, 0, HALFWORD, CACHEABLE, addr_tmp, empty_word, make_line_of_addr(addr_tmp.line), RPT_TB);


    CACHE_REPORT_INFO("T4.4) Verify writes.");

    addr_tmp = addr;
    line = make_line_of_addr(addr_tmp.line);
    line.range(addr_tmp.off*8 + 7, addr_tmp.off*8) = 0;
    op(READ, HIT, 0, WORD, CACHEABLE, addr_tmp, empty_word, line, RPT_TB);

    addr_tmp.tag_incr(1);
    addr_tmp.off.range(0,0) = 0;
    line = make_line_of_addr(addr_tmp.line);
    line.range(addr_tmp.off*8 + BITS_PER_HALFWORD - 1, addr_tmp.off*8) = 0;
    op(READ, HIT, 0, WORD, CACHEABLE, addr_tmp, empty_word, line, RPT_TB);

    addr_tmp = addr;
    addr_tmp.tag_incr(2);
    line = make_line_of_addr(addr_tmp.line);
    line.range(addr_tmp.off*8 + 7, addr_tmp.off*8) = 0;
    op(READ, HIT, 0, WORD, CACHEABLE, addr_tmp, empty_word, line, RPT_TB);

    addr_tmp.tag_incr(1);
    addr_tmp.off.range(0,0) = 0;
    line = make_line_of_addr(addr_tmp.line);
    line.range(addr_tmp.off*8 + BITS_PER_HALFWORD - 1, addr_tmp.off*8) = 0;
    op(READ, HIT, 0, WORD, CACHEABLE, addr_tmp, empty_word, line, RPT_TB);

    CACHE_REPORT_INFO("T4.5) Flush.");    

    // issue flush
    l2_flush_tb.put(1);

    for (int i = 0; i < 4; ++i) {
	l2_req_out_t req_out = l2_req_out_tb.get();
	put_rsp_in(RSP_PUTACK, req_out.addr, empty_line, RPT_TB);
	wait();
    }

    while(!flush_done) wait();

    /*
     * T5) Evictions.
     */
    CACHE_REPORT_INFO("T5) EVICTIONS.");

    CACHE_REPORT_INFO("T5.0) Evict twice a whole set.");

    // preparation
    addr = rand_addr();
    addr_tmp = addr;

    for (int i = 0; i < L2_WAYS; ++i) {
	op(READ, MISS, 0, WORD, CACHEABLE, addr_tmp, empty_word, make_line_of_addr(addr_tmp.line), RPT_TB);

	addr_tmp.tag_incr(1);
    }

    for (int i = 0; i < L2_WAYS; ++i) {
	op(WRITE, MISS_EVICT, REQ_PUTS, WORD, CACHEABLE, addr_tmp, addr_tmp.word, 
	   make_line_of_addr(addr_tmp.line), RPT_TB);

	addr_tmp.tag_incr(1);
    }

    for (int i = 0; i < L2_WAYS; ++i) {
	op(READ, MISS_EVICT, REQ_PUTM, WORD, CACHEABLE, addr_tmp, empty_word, 
	   make_line_of_addr(addr_tmp.line), RPT_TB);

	addr_tmp.tag_incr(1);
    }


    CACHE_REPORT_INFO("T5.1) Evict stalls.");

    addr1 = addr_tmp;
    addr_tmp.tag_decr(L2_WAYS);
    addr_breakdown_t addr_evict1 = addr_tmp;
    addr_tmp.set_incr(1);
    addr2 = addr_tmp;

    put_cpu_req(cpu_req1, READ, WORD, CACHEABLE, addr1.word, empty_word, RPT_TB);
    get_inval(addr_evict1.line, RPT_TB);
    get_req_out(REQ_PUTS, addr_evict1.line, 0, RPT_TB);

    wait();

    put_cpu_req(cpu_req2, READ, WORD, CACHEABLE, addr2.word, empty_word, RPT_TB);

    put_rsp_in(RSP_PUTACK, addr_evict1.line, 0, RPT_TB);
    get_req_out(REQ_GETS, addr1.line, cpu_req1.hprot, RPT_TB);

    wait();

    put_rsp_in(RSP_EDATA, addr1.line, make_line_of_addr(addr1.line), RPT_TB);
    get_rd_rsp(addr1, make_line_of_addr(addr1.line), RPT_TB);

    get_req_out(REQ_GETS, addr2.line, cpu_req2.hprot, RPT_TB);

    wait();

    put_rsp_in(RSP_EDATA, addr2.line, make_line_of_addr(addr2.line), RPT_TB);
    get_rd_rsp(addr2, make_line_of_addr(addr2.line), RPT_TB);

    CACHE_REPORT_INFO("T5.2) Flush.");    

    // issue flush
    l2_flush_tb.put(1);

    for (int i = 0; i < L2_WAYS + 1; ++i) {
	l2_req_out_t req_out = l2_req_out_tb.get();
	put_rsp_in(RSP_PUTACK, req_out.addr, empty_line, RPT_TB);
	wait();
    }

    while(!flush_done) wait();

    /*
     * T6) Pipelined requests.
     */

    CACHE_REPORT_INFO("T6) PIPELINED REQUESTS.");

    CACHE_REPORT_INFO("T6.0) One read and multiple writes pipelined. Max requests stall.");

    addr = rand_addr();
    addr_tmp = addr;

    // Issue N_REQS + 1 requests

    put_cpu_req(cpu_req, READ, WORD, CACHEABLE, addr_tmp.word, empty_word, RPT_TB);
    get_req_out(REQ_GETS, addr_tmp.line, cpu_req.hprot, RPT_TB);
    wait();

    for (int i = 0; i < N_REQS - 1; i++) {
	addr_tmp.set_incr(1);
	put_cpu_req(cpu_req, WRITE, WORD, CACHEABLE, addr_tmp.word, empty_word, RPT_TB);
	get_req_out(REQ_GETM, addr_tmp.line, cpu_req.hprot, RPT_TB);
	wait();
    }

    addr_tmp.set_incr(1);
    put_cpu_req(cpu_req, WRITE, WORD, CACHEABLE, addr_tmp.word, empty_word, RPT_TB);
    wait();

    // Respond to N_REQS requests
    addr_tmp.set_decr(N_REQS);
    put_rsp_in(RSP_EDATA, addr_tmp.line, make_line_of_addr(addr_tmp.line), RPT_TB);
    get_rd_rsp(addr_tmp, make_line_of_addr(addr_tmp.line), RPT_TB);
    wait();

    for (int i = 0; i < N_REQS - 1; i++) {
	addr_tmp.set_incr(1);
	put_rsp_in(RSP_DATA, addr_tmp.line, make_line_of_addr(addr_tmp.line), RPT_TB);
	wait();
    }

    // Manage the N_REQS + 1 request
    addr_tmp.set_incr(1);
    get_req_out(REQ_GETM, addr_tmp.line, cpu_req.hprot, RPT_TB);
    put_rsp_in(RSP_DATA, addr_tmp.line, make_line_of_addr(addr_tmp.line), RPT_TB);
    wait();

    CACHE_REPORT_INFO("T6.1) Verify writes.");

    addr_tmp = addr;
    for (int i = 0; i < N_REQS; i++) {
	addr_tmp.set_incr(1);

	put_cpu_req(cpu_req, READ, WORD, CACHEABLE, addr_tmp.word, empty_word, RPT_TB);
	line = make_line_of_addr(addr_tmp.line);
	line.range(addr_tmp.w_off*ADDR_BITS + ADDR_BITS - 1, addr_tmp.w_off*ADDR_BITS) = 0;
	get_rd_rsp(addr_tmp, line, RPT_TB);
	wait();
    }

    CACHE_REPORT_INFO("T6.2) Flush.");

    // issue flush
    l2_flush_tb.put(1);

    for (int i = 0; i < N_REQS + 1; ++i) {
	req_out = l2_req_out_tb.get();
	put_rsp_in(RSP_PUTACK, req_out.addr, empty_line, RPT_TB);
	wait();
    }

    while(!flush_done) wait();

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

    wait();
}

inline void l2_tb::rand_wait()
{
    int waits = rand() % 5;
    
    for (int i=0; i < waits; i++) wait();
}

addr_breakdown_t l2_tb::rand_addr()
{
    addr_t addr = (rand() % (1 << ADDR_BITS-1)); // MSB always set to 0
    addr_breakdown_t addr_br;
    addr_br.breakdown(addr);
    return addr_br;
}

word_t l2_tb::rand_word()
{
    word_t word = (rand() % (1 << BITS_PER_WORD-1));

    return word;
}

void l2_tb::put_cpu_req(l2_cpu_req_t &cpu_req, cpu_msg_t cpu_msg, hsize_t hsize, 
			bool cacheable, addr_t addr, word_t word, bool rpt)
{
    cpu_req.cpu_msg = cpu_msg;
    cpu_req.hsize = hsize;
    // TODO: vary data/opcode field
    cpu_req.hprot = cacheable ? (DEFAULT_HPROT | CACHEABLE_MASK) : DEFAULT_HPROT;
    cpu_req.addr = addr;
    cpu_req.word = word;

    rand_wait();

    l2_cpu_req_tb.put(cpu_req);

    if (rpt)
	CACHE_REPORT_VAR(sc_time_stamp(), "CPU_REQ", cpu_req);
}

void l2_tb::get_req_out(coh_msg_t coh_msg, addr_t addr, hprot_t hprot, bool rpt)
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

void l2_tb::put_rsp_in(coh_msg_t coh_msg, addr_t addr, line_t line, bool rpt)
{
    l2_rsp_in_t rsp_in;
    
    rsp_in.coh_msg = coh_msg;
    rsp_in.addr = addr;
    rsp_in.invack_cnt = 0;
    rsp_in.line = line;

    l2_rsp_in_tb.put(rsp_in);

    if (rpt) CACHE_REPORT_VAR(sc_time_stamp(), "RSP_IN", rsp_in);
}

void l2_tb::get_rd_rsp(addr_breakdown_t addr, line_t line, bool rpt)
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

void l2_tb::get_inval(addr_t addr, bool rpt)
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


void l2_tb::op(cpu_msg_t cpu_msg, sc_uint<2> beh, coh_msg_t put_msg, hsize_t hsize, bool cacheable, 
	       addr_breakdown_t req_addr, word_t req_word, line_t rsp_line, bool rpt)
{
    // tb output channels
    l2_cpu_req_t cpu_req;

    // 
    addr_t cpu_addr;
    coh_msg_t coh_req, coh_rsp;

    
    if      (hsize == BYTE)     cpu_addr = req_addr.byte;
    else if (hsize == HALFWORD)	cpu_addr = req_addr.hword;
    else if (hsize == WORD)	cpu_addr = req_addr.word;
    else CACHE_REPORT_ERROR("Wrong hsize.", hsize);

    if (cpu_msg == READ) {
	coh_req = REQ_GETS;
	coh_rsp = RSP_EDATA;
    } else if (cpu_msg == WRITE) {
	coh_req = REQ_GETM;
	coh_rsp = RSP_DATA;
    } else {
	CACHE_REPORT_ERROR("Wrong cpu_msg.", cpu_msg);
    }


    // CPU REQ
    put_cpu_req(cpu_req, cpu_msg, hsize, cacheable, cpu_addr, req_word, rpt);

    if (beh == MISS_EVICT) {
	addr_breakdown_t req_addr_tmp = req_addr;
	req_addr_tmp.tag_decr(L2_WAYS); 

	// INVAL
	get_inval(req_addr_tmp.line, rpt);

	// REQ OUT
	get_req_out(put_msg, req_addr_tmp.line, 0, rpt);

	// RSP IN
	put_rsp_in(RSP_PUTACK, req_addr_tmp.line, 0, rpt);

	wait();
    }

    if (beh == MISS || beh == MISS_EVICT) {
	// REQ OUT
	get_req_out(coh_req, req_addr.line, cpu_req.hprot, rpt);
	
	// RSP IN
	put_rsp_in(coh_rsp, req_addr.line, rsp_line, rpt);
    }

    if (cpu_msg == READ)
	get_rd_rsp(req_addr, rsp_line, rpt);
    
    wait();
}

void l2_tb::op_flush(coh_msg_t coh_msg, addr_t addr_line, bool rpt)
{
    get_req_out(coh_msg, addr_line, 0, rpt);

    put_rsp_in(RSP_PUTACK, addr_line, 0, rpt);

    wait();
}

line_t l2_tb::make_line_of_addr(addr_t addr) 
{
    line_t line;

    for (int i = 0; i < WORDS_PER_LINE; ++i)
	write_word(line, addr + (i * WORD_OFFSET), i, 0, WORD);

    return line;
}
