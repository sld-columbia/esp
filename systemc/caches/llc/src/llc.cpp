/* Copyright 2017 Columbia University, SLD Group */

#include "llc.hpp"

/*
 * Processes
 */

void llc::ctrl()
{
    // empty variables
    const invack_cnt_t empty_invack_cnt = 0;
    const invack_cnt_t max_invack_cnt = MAX_INVACK_CNT;
    const word_t empty_word = 0;
    const line_t empty_line = 0;
    const hprot_t empty_hprot = 0;
    const tag_t empty_tag = 0;

    // Reset all signals and channels
    this->reset_io();

    // Reset state memory
    this->reset_states();

    // Main loop
    while(true) {

    }

    /* 
     * End of main loop
     */

}

/*
 * Functions
 */

inline void llc::reset_io()
{
    RESET_IO;

    llc_req_in.reset();
    // llc_rsp_in.reset();
    llc_mem_rsp.reset();
    llc_rsp_out.reset();
    // llc_fwd_out.reset();
    llc_mem_req.reset();

    asserts.write(0);
    bookmark.write(0);
    custom_dbg.write(0);

    tags.port1.reset();
    tags.port2.reset();
    tags.port3.reset();
    tags.port4.reset();
    tags.port5.reset();
    tags.port6.reset();
    tags.port7.reset();
    tags.port8.reset();
    tags.port9.reset();

    states.port1.reset();
    states.port2.reset();
    states.port3.reset();
    states.port4.reset();
    states.port5.reset();
    states.port6.reset();
    states.port7.reset();
    states.port8.reset();
    states.port9.reset();

    hprots.port1.reset();
    hprots.port2.reset();
    hprots.port3.reset();
    hprots.port4.reset();
    hprots.port5.reset();
    hprots.port6.reset();
    hprots.port7.reset();
    hprots.port8.reset();
    hprots.port9.reset();

    lines.port1.reset();
    lines.port2.reset();
    lines.port3.reset();
    lines.port4.reset();
    lines.port5.reset();
    lines.port6.reset();
    lines.port7.reset();
    lines.port8.reset();
    lines.port9.reset();

    sharers.port1.reset();
    sharers.port2.reset();
    sharers.port3.reset();
    sharers.port4.reset();
    sharers.port5.reset();
    sharers.port6.reset();
    sharers.port7.reset();
    sharers.port8.reset();
    sharers.port9.reset();

    owners.port1.reset();
    owners.port2.reset();
    owners.port3.reset();
    owners.port4.reset();
    owners.port5.reset();
    owners.port6.reset();
    owners.port7.reset();
    owners.port8.reset();
    owners.port9.reset();


    evict_ways.port1.reset();
    evict_ways.port2.reset();

    wait();
}

inline void llc::reset_states()
{
    RESET_STATES;

    for (int i=0; i<SETS; i++) { // do not unroll
	for (int j=0; j<LLC_WAYS; j++) { // do not unroll
	    {
		RESET_STATES_LOOP;
		states.port1[0][(i << LLC_WAY_BITS) + j] = INVALID;
		wait();
	    }
	}
    }
}
