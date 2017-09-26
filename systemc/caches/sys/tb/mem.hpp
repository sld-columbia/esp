/* Copyright 2017 Columbia University, SLD Group */

#ifndef __MEM_HPP__
#define __MEM_HPP__

#include "cache_utils.hpp"

#define MEM_WORD_CNT (1 << 18) // 1MB

class mem : public sc_module
{

public:

	// Clock signal
	sc_in<bool> clk;

	// Reset signal
	sc_in<bool> rst;

	//
	// Signals
	//

	// From mem
	put_initiator<llc_mem_rsp_t>	mem_rsp;

	// To mem
	get_initiator<llc_mem_req_t>    mem_req;

	// Local memory

	// Constructor
	SC_CTOR(mem)
		: clk("clk")
		, rst("rst")
		, mem_rsp("mem_rsp")
		, mem_req("mem_req")
		, data(new word_t[MEM_WORD_CNT])
		{
			// Cache controller process
			SC_CTHREAD(access, clk.pos());
			reset_signal_is(rst, false);

			// Assign clock and reset to put_get ports
			mem_rsp.clk_rst(clk, rst);
			mem_req.clk_rst(clk, rst);
		}

	// Processes
	void access();

	// Functions
	word_t peek(unsigned address);
	void force(unsigned address, word_t data_in);

	// Memory array
	word_t *data;
};

#endif /* __MEM_HPP__ */
