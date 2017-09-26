/* Copyright 2017 Columbia University, SLD Group */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "sys_tb.hpp"


//
// Processes
//

void sys_tb::sys_test()
{
	//
	// Random seed
	//

	// initialize
	srand(time(NULL));

	//
	// Local variables
	//

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
	//
	// Reset
	//

	reset_sys_test();


	//
	// T0) Simple word reads and writes. No eviction. No pipelining.
	//
	CACHE_REPORT_INFO("T0) SIMPLE WORD READS AND WRITES.");

	// T0.0) Simple read hits and misses. Fill a random set.//
	CACHE_REPORT_INFO("T0.0) Read hits and misses. Fill a random set.");

	// preparation
	addr = rand_addr();

	// End simulation
	sc_stop();
}

//
// Functions
//

inline void sys_tb::reset_sys_test()
{
	for (int i = 0; i < N_CPU; i++) {
		l2_cpu_req_tb[i]->reset_put();
		l2_flush_tb[i]->reset_put();
		l2_rd_rsp_tb[i]->reset_get();
		l2_inval_tb[i]->reset_get();
	}
	llc_rst_tb.reset_put();
	llc_rst_tb_done.reset_get();

	wait();

	for (int i = 0; i < N_CPU; i++)
		l2_flush_tb[i]->put(true);
	llc_rst_tb.put(true);

	for (int i = 0; i < N_CPU; i++)
		while (!l2_flush_done[i]->read())
			wait();
	bool dummy;
	llc_rst_tb_done.get(dummy);
}
