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

    while(true) {
	new_asserts = asserts.read();
	new_bookmark = bookmark.read();

	if (old_asserts != new_asserts) {
	    old_asserts = new_asserts;
	    // CACHE_REPORT_DEBUG(sc_time_stamp(), "assert", new_asserts);
	}

	if (old_bookmark != new_bookmark) {
	    old_bookmark = new_bookmark;
	    // CACHE_REPORT_DEBUG(sc_time_stamp(), "bookmark", new_bookmark);
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

    // tb output channels
    l2_cpu_req_t cpu_req;
    l2_fwd_in_t fwd_in;
    l2_rsp_in_t rsp_in;
    bool	flush;

    // tb input channels
    l2_rd_rsp_t rd_rsp;
    l2_wr_rsp_t wr_rsp;
    l2_inval_t inval;
    l2_req_out_t req_out;
    l2_rsp_out_t rsp_out;

    // constants
    const word_t empty_word = 0;
    const line_t empty_line = 0;
    const hprot_t empty_hprot = 0;
    const addr_t empty_addr = 0;

    //
    addr_t addr, word_addr, line_addr;
    word_t word;

    /*
     * Reset
     */

    reset_l2_test();


    /*
     * Simple word reads and writes. No eviction. No pipelining.
     */

    /* S0. Read miss + read hit. Fill a random set. */
    CACHE_REPORT_INFO("S0: READ MISS + READ HIT. FILL A RANDOM SET..");

    addr = rand_addr(word_addr, line_addr);

    // Read misses
    for (int i = 0; i < L2_WAYS; ++i) {
    	put_cpu_req(cpu_req, READ, WORD, word_addr + (i*TAG_OFFSET), CACHEABLE, empty_word, RPT);
    	get_req_out(req_out, REQ_GETS, cpu_req.addr, cpu_req.hprot, RPT);
    	put_rsp_in(rsp_in, RSP_EDATA, req_out.addr, empty_line, RPT);
    	get_rd_rsp(rd_rsp, addr, word_addr + (i*TAG_OFFSET), RPT);
    	wait();
    }

    // Read hits
    for (int i = 0; i < L2_WAYS; ++i) {
    	put_cpu_req(cpu_req, READ, WORD, word_addr + (i*TAG_OFFSET), CACHEABLE, empty_word, RPT);
    	get_rd_rsp(rd_rsp, addr, word_addr + (i*TAG_OFFSET), RPT);
    	wait();
    }

    /* S1. Write miss + write hit. Fill the set next to S0. */
    CACHE_REPORT_INFO("S1: WRITE MISS + WRITE HIT. FILL THE NEXT SET.");

    /* S2. Write miss + write hit. Same set as S0. */
    CACHE_REPORT_INFO("S2: WRITE MISS + WRITE HIT. SAME SET AS S0.");

    word = rand_word();
    addr_t addr_wr = addr;

    int sets_j = 2;
    // writes
    for (int j = 0; j < sets_j; ++j) {
    	// Write misses
    	if (j) {
    	    for (int i = 0; i < L2_WAYS; ++i) {
    		put_cpu_req(cpu_req, WRITE, WORD, word_addr + (i*TAG_OFFSET), CACHEABLE, word + i + j*L2_WAYS, RPT);
    		get_req_out(req_out, REQ_GETM, cpu_req.addr, cpu_req.hprot, RPT);
    		put_rsp_in(rsp_in, RSP_DATA, req_out.addr, empty_line, RPT);
    		get_wr_rsp(wr_rsp, addr, RPT);
    		wait();
    	    }
    	}
    	// Write hits
    	for (int i = 0; i < L2_WAYS; ++i) {
    	    put_cpu_req(cpu_req, WRITE, WORD, word_addr + (i*TAG_OFFSET), CACHEABLE, word + i + j*L2_WAYS, RPT);
    	    get_wr_rsp(wr_rsp, addr, RPT);
    	    wait();
    	}

    	addr += SET_OFFSET; word_addr += SET_OFFSET; line_addr += SET_OFFSET;
    }

    addr -= SET_OFFSET * sets_j; word_addr -= SET_OFFSET * sets_j; line_addr -= SET_OFFSET * sets_j;

    /* S2. Write miss + write hit. Same set as S0. */
    CACHE_REPORT_INFO("S1-2: READ HITS. VERIFY WRITES CORRECTNESS.");

    // verify writes correctness (read hits)
    for (int j = 0; j < sets_j; ++j) {
    	for (int i = 0; i < L2_WAYS; ++i) {
    	    put_cpu_req(cpu_req, READ, WORD, word_addr + (i*TAG_OFFSET), CACHEABLE, empty_word, RPT);
    	    get_rd_rsp(rd_rsp, addr, word + i + j*L2_WAYS, RPT);
    	    wait();
    	}

    	addr += SET_OFFSET; word_addr += SET_OFFSET; line_addr += SET_OFFSET;
    }

    addr -= SET_OFFSET * sets_j; word_addr -= SET_OFFSET * sets_j; line_addr -= SET_OFFSET * sets_j;

    // flush
    CACHE_REPORT_INFO("S1-2: FLUSH.");
    l2_flush_tb.put(1);

    // receive and answer PutM
    for (int k = 0; k < sets_j*L2_WAYS/2; ++k) {
	    get_req_out(req_out, REQ_PUTM, empty_addr, empty_hprot, RPT);
	    wait();

	    get_req_out(req_out, REQ_PUTM, empty_addr, empty_hprot, RPT);
	    wait();

	    put_rsp_in(rsp_in, RSP_PUTACK, req_out.addr, empty_line, RPT);
	    wait();

	    put_rsp_in(rsp_in, RSP_PUTACK, req_out.addr, empty_line, RPT);
	    wait();
    }

    // confirm that the flush happened correctly (read hits)
    for (int j = 0; j < sets_j; ++j) {
    	for (int i = 0; i < L2_WAYS; ++i) {
    	    put_cpu_req(cpu_req, READ, WORD, word_addr + (i*TAG_OFFSET), CACHEABLE, empty_word, RPT);
	    get_req_out(req_out, REQ_GETS, cpu_req.addr, cpu_req.hprot, RPT);
	    put_rsp_in(rsp_in, RSP_EDATA, req_out.addr, empty_line, RPT);
    	    get_rd_rsp(rd_rsp, addr, word_addr + (i*TAG_OFFSET), RPT);
    	    wait();
    	}

    	addr += SET_OFFSET; word_addr += SET_OFFSET; line_addr += SET_OFFSET;
    }

    // flush
    CACHE_REPORT_INFO("S1-2: FLUSH.");
    l2_flush_tb.put(1);

    // receive and answer PutM
    for (int k = 0; k < sets_j*L2_WAYS; ++k) {
	get_req_out(req_out, REQ_PUTM, empty_addr, empty_hprot, RPT);
	wait();
    }

    for (int k = 0; k < sets_j*L2_WAYS; ++k) {
	put_rsp_in(rsp_in, RSP_PUTACK, req_out.addr, empty_line, RPT);
	wait();
    }

    /* S3. Mix of reads and writes. Fill the whole cache. */
    CACHE_REPORT_INFO("S3. FILL THE CACHE: READ HALF WORD, WRITE ALL WORDS, OVERWRITE ALL WORDS, READ AND CHECK ALL WORDS.");

    // read 1/16 of the words in the cache from 1/2 of sets
    for (int wa = 0; wa < L2_WAYS; ++wa) {
    	for (int s = 0; s < SETS/2; ++s) {
    	    word_addr = (wa << TAG_RANGE_LO) + (s << SET_RANGE_LO);
    	    word = word_addr;

    	    put_cpu_req(cpu_req, READ, WORD, word_addr, CACHEABLE, empty_word, RPT);
    	    get_req_out(req_out, REQ_GETS, cpu_req.addr, cpu_req.hprot, RPT);
    	    put_rsp_in(rsp_in, RSP_EDATA, req_out.addr, empty_line, RPT);
    	    get_rd_rsp(rd_rsp, word_addr, word, RPT);
    	    wait();
    	}
    }

    // write all words
    for (int wo = 0; wo < WORDS_PER_LINE; ++wo) {
    	for (int wa = 0; wa < L2_WAYS; ++wa) {
    	    for (int s = 0; s < SETS; ++s) {
    		word_addr = (wo << W_OFF_RANGE_LO) + (wa << TAG_RANGE_LO) + (s << SET_RANGE_LO);
    		word = word_addr;

    		put_cpu_req(cpu_req, WRITE, WORD, word_addr, CACHEABLE, word, RPT);
    		if (s >= SETS/2 && wo == 0) {
    		    get_req_out(req_out, REQ_GETM, cpu_req.addr, cpu_req.hprot, RPT);
    		    put_rsp_in(rsp_in, RSP_DATA, req_out.addr, empty_line, RPT);
    		}
    		get_wr_rsp(wr_rsp, word_addr, RPT);
    		wait();
    	    }
    	}
    }

    // overwrite half of the words in the cache
    // write all words
    for (int wo = 0; wo < WORDS_PER_LINE/2; ++wo) {
    	for (int wa = 0; wa < L2_WAYS; ++wa) {
    	    for (int s = 0; s < SETS/2; ++s) {
    		word_addr = (wo << W_OFF_RANGE_LO) + (wa << TAG_RANGE_LO) + (s << SET_RANGE_LO);
    		word = word_addr + 1;

    		put_cpu_req(cpu_req, WRITE, WORD, word_addr, CACHEABLE, word, RPT);
    		get_wr_rsp(wr_rsp, word_addr, RPT);
    		wait();
    	    }
    	}
    }

    // read and check all words
    // read a quarter of the words in the cache
    for (int wo = 0; wo < WORDS_PER_LINE; ++wo) {
    	for (int wa = 0; wa < L2_WAYS; ++wa) {
    	    for (int s = 0; s < SETS; ++s) {
    		word_addr = (wo << W_OFF_RANGE_LO) + (wa << TAG_RANGE_LO) + (s << SET_RANGE_LO);
    		if (s < SETS/2 and wo < WORDS_PER_LINE/2)
    		    word = word_addr + 1;
    		else 
    		    word = word_addr;

    		put_cpu_req(cpu_req, READ, WORD, word_addr, CACHEABLE, empty_word, RPT);
    		get_rd_rsp(rd_rsp, word_addr, word, RPT);
    		wait();
    	    }
    	}
    }

    // flush
    CACHE_REPORT_INFO("S3: FLUSH.");
    l2_flush_tb.put(1);

    int cnt = 0;
    
    // receive and answer PutM
    for (int k = 0; k < SETS * L2_WAYS; ++k) {
	    get_req_out(req_out, REQ_PUTM, empty_addr, empty_hprot, RPT);
	    wait();

	    put_rsp_in(rsp_in, RSP_PUTACK, req_out.addr, empty_line, RPT);
	    wait();

	    cnt++;
    }


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
    l2_wr_rsp_tb.reset_get();
    l2_inval_tb.reset_get();
    l2_req_out_tb.reset_get();
    l2_rsp_out_tb.reset_get();

    wait();
}

inline void l2_tb::rand_wait()
{
    int waits = rand() % 10;
    
    for (int i=0; i < waits; i++) {
	wait();
    }
}

addr_t l2_tb::rand_addr(addr_t &word_addr, addr_t &line_addr)
{
    addr_t addr = (rand() % (1 << ADDR_BITS-1)); // MSB always set to 0

    word_addr = addr;
    word_addr.range(B_OFF_RANGE_HI, B_OFF_RANGE_LO) = 0;

    line_addr = addr;
    line_addr.range(OFF_RANGE_HI, OFF_RANGE_LO) = 0;

    return addr;
}

word_t l2_tb::rand_word()
{
    word_t word = (rand() % (1 << BITS_PER_WORD-1));

    return word;
}


void l2_tb::put_cpu_req(l2_cpu_req_t &cpu_req, cpu_msg_t cpu_msg, hsize_t hsize, 
			addr_t addr, bool cacheable, word_t word, bool rpt)
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

void l2_tb::get_req_out(l2_req_out_t &req_out, coh_msg_t coh_msg, addr_t addr, hprot_t hprot, bool rpt)
{
    req_out = l2_req_out_tb.get();

    if (coh_msg == REQ_GETS || coh_msg == REQ_GETM) {
	if (req_out.coh_msg != coh_msg ||
	    req_out.hprot   != hprot ||
	    req_out.addr.range(LINE_RANGE_HI,LINE_RANGE_LO) != addr.range(LINE_RANGE_HI,LINE_RANGE_LO)) {

	    CACHE_REPORT_ERROR("get req out", req_out.addr);
	    CACHE_REPORT_ERROR("get req out gold", addr);
	}
    }

    if (rpt)
	CACHE_REPORT_VAR(sc_time_stamp(), "REQ_OUT", req_out);
}

void l2_tb::put_rsp_in(l2_rsp_in_t &rsp_in, coh_msg_t coh_msg, addr_t addr, line_t line, bool rpt)
{
    addr_t addr_line = addr;
    addr_line.range(OFF_RANGE_HI, OFF_RANGE_LO) = 0;

    rsp_in.coh_msg = coh_msg;
    rsp_in.addr = addr;
    rsp_in.invack_cnt = 0;
    for (int i = 0; i < WORDS_PER_LINE; ++i)
	write_word(rsp_in.line, addr_line + (i * WORD_OFFSET), i);

    l2_rsp_in_tb.put(rsp_in);

    if (rpt)
	CACHE_REPORT_VAR(sc_time_stamp(), "RSP_IN", rsp_in);
}

void l2_tb::get_rd_rsp(l2_rd_rsp_t &rd_rsp, addr_t addr, word_t word, bool rpt)
{
    word_t word_tmp;
    word_offset_t w_off_tmp;

    l2_rd_rsp_tb.get(rd_rsp);

    w_off_tmp = addr.range(W_OFF_RANGE_HI, W_OFF_RANGE_LO);

    word_tmp = read_word(rd_rsp.line, w_off_tmp);

    if (word_tmp != word) {
	CACHE_REPORT_ERROR("get rd rsp", word_tmp);
	CACHE_REPORT_ERROR("get rd rsp gold", word);
    }

    if (rpt)
	CACHE_REPORT_VAR(sc_time_stamp(), "RD_RSP", rd_rsp);
}

void l2_tb::get_wr_rsp(l2_wr_rsp_t &wr_rsp, addr_t addr, bool rpt)
{
    l2_wr_rsp_tb.get(wr_rsp);

    if (wr_rsp.set != addr.range(SET_RANGE_HI, SET_RANGE_LO)) {
	CACHE_REPORT_ERROR("get wr rsp", wr_rsp.set);
	CACHE_REPORT_ERROR("get wr rsp gold", addr.range(SET_RANGE_HI, SET_RANGE_LO));
    }

    if (rpt)
	CACHE_REPORT_VAR(sc_time_stamp(), "WR_RSP", wr_rsp);
}

