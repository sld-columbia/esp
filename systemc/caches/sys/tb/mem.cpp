/* Copyright 2017 Columbia University, SLD Group */

#include "mem.hpp"

/*
 * Processes
 */

void mem::access()
{
	// Reset
	mem_req.reset_get();
	mem_rsp.reset_put();

	for (int i = 0; i < MEM_WORD_CNT; i++)
		data[i] = i;

	wait();

	while(true) {
		// TODO add random delay
		wait();
		llc_mem_req_t req = mem_req.get();
		line_t line;

		// Get line alined address
		unsigned line_address = req.addr >> (WORD_BITS + BYTE_BITS);

		if (req.hwrite)
			for (int i = 0; i < WORDS_PER_LINE; i++)
				data[line_address + i] = read_word(req.line, i);
		else
			for (int i = 0; i < WORDS_PER_LINE; i++)
				line.range((i + 1) * BITS_PER_WORD - 1, i * BITS_PER_WORD) = data[line_address + i];

		llc_mem_rsp_t rsp;
		rsp.line = line;
		mem_rsp.put(rsp);
	}
}

word_t mem::peek(unsigned address)
{
	return data[address];
}

void mem::force(unsigned address, word_t data_in)
{
	data[address] = data_in;
}
