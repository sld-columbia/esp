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
    addr_breakdown_t addr, addr_tmp;
    word_t word, word_tmp;
    line_t line;

    /*
     * Reset
     */

    reset_llc_test();


    // End simulation
    sc_stop();
}

/*
 * Functions
 */

inline void llc_tb::reset_llc_test()
{
    llc_req_in_tb.reset();
    // llc_rsp_in_tb.reset();
    llc_mem_rsp_tb.reset();
    llc_rsp_out_tb.reset();
    // llc_fwd_out_tb.reset();
    llc_mem_req_tb.reset();

    wait();
}
