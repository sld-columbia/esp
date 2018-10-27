/* Copyright 2017 Columbia University, SLD Group */

#include "synth.hpp"
#include "synth_directives.hpp"
#include "log2.h"

// Functions

#include "synth_functions.cpp"

// Processes

void synth::load_input()
{
    uint32_t pattern;
    uint32_t in_size;
    uint32_t access_factor;
    uint32_t burst_len;
    uint32_t compute_bound_factor;
    uint32_t irregular_seed;
    uint32_t reuse_factor;
    uint32_t ld_st_ratio;
    uint32_t stride_len;
    uint32_t in_place; 
    uint32_t offset;

    uint32_t nwords;
    uint32_t ntrans;
    uint32_t compute_bound_delay;
    uint32_t masked_seed;
    uint32_t index;
    uint32_t stride;
    uint32_t ld_st_ratio_cnt;
    uint32_t burst_len_log;

    // Reset
    {
	HLS_DEFINE_PROTOCOL("load-reset");

	this->reset_load_input();

	// PLM memories reset
	// No PLMs

	// User-defined reset code
	pattern = 0;
	in_size = 0;
	access_factor = 0;
	burst_len = 0;
	compute_bound_factor = 0;
	irregular_seed = 0;
	reuse_factor = 0;
	ld_st_ratio = 0;
	stride_len = 0;
	in_place = 0;
	offset = 0;

	nwords = 0;
	ntrans = 0;
	compute_bound_delay = 0;
	masked_seed = 0;
	index = 0;
	stride = 0;
	ld_st_ratio_cnt = 0;
	burst_len_log = 0;

	wait();
    }

    // Config
    {
	HLS_DEFINE_PROTOCOL("load-config");

	cfg.wait_for_config(); // config process
	conf_info_t config = this->conf_info.read();

	// User-defined config code
	pattern = config.pattern;
	in_size = config.in_size;
	access_factor = config.access_factor;
	burst_len = config.burst_len;
	compute_bound_factor = config.compute_bound_factor;
	irregular_seed = config.irregular_seed;
	reuse_factor = config.reuse_factor;
	ld_st_ratio = config.ld_st_ratio;
	stride_len = config.stride_len;
	in_place = config.in_place;
	offset = config.offset;

	// Logarithms
	burst_len_log = ilog2(burst_len);

	// Number of words to be read
	if (config.pattern = IRREGULAR)
	    nwords = in_size >> access_factor;
	else
	    nwords = in_size;

	// Number of DMA read transactions
	ntrans = nwords >> burst_len_log;

	// Delay between the end of a DMA read transaction and the issue of the
	// next. When this delay is > 0 it emulates a compute-bound accelerator.
	compute_bound_delay = burst_len * (compute_bound_factor - 1);

	// Seed for semi-random DMA load index
	masked_seed = (irregular_seed & (ntrans - 1)) << burst_len_log;
    }

    // Load
    {
	// Reuse loop
	for (uint32_t r = 0; r < reuse_factor; r++)
	{
	    HLS_LOAD_INPUT_REUSE_LOOP;

	    // Init index and stride counter
	    index = 0;
	    stride = 0;
	    ld_st_ratio_cnt = 0;

	    if (pattern == IRREGULAR) {
		index += masked_seed;
		index &= (nwords - 1);
	    }

	    // Bursts loop
	    for (uint32_t b = 0; b < ntrans; b++)
	    {
		HLS_LOAD_INPUT_BATCH_LOOP;

		{
		    HLS_DEFINE_PROTOCOL("load-dma-conf");

		    // Configure DMA transaction
		    dma_info_t dma_info(index + offset, burst_len);
		    this->dma_read_ctrl.put(dma_info);
		}

		// Words loop
		for (uint32_t i = 0; i < burst_len; i++)
		{
		    HLS_LOAD_INPUT_LOOP;

		    uint32_t data = this->dma_read_chnl.get().to_uint();
		    wait();
		}

		// Handshake to compute process
		ld_st_ratio_cnt++;

		if (ld_st_ratio_cnt == ld_st_ratio) {

		    if ((ld_st_ratio == 1 && in_place == 1) || (r == reuse_factor - 1))
			this->load_compute_handshake();

		    ld_st_ratio_cnt = 0;
		}

		// Compute-bound emulation
		for (uint32_t i = 0; i < compute_bound_delay; i++)
		{
		    HLS_LOAD_INPUT_LOOP;

		    wait();
		}

		// Index calculation
		if (pattern == STREAMING) {
		    
		    index += burst_len;

		} else if (pattern == STRIDED) {
		    
		    index += stride_len;
		    if (index >= in_size) {
			stride += burst_len;
			index = stride;
		    }

		} else { // pattern == IRREGULAR

		    index += masked_seed;
		    index &= (nwords - 1);
		}
	    }
	}
    }

    // Conclude
    {
	this->process_done();
    }
}



void synth::store_output()
{

    uint32_t burst_len;
    uint32_t in_size;
    uint32_t out_size;
    uint32_t reuse_factor;
    uint32_t ld_st_ratio;
    uint32_t in_place;
    uint32_t offset;

    uint32_t nwords;
    uint32_t ntrans;
    uint32_t index;
    uint32_t burst_len_log;

    // Reset
    {
	HLS_DEFINE_PROTOCOL("store-reset");

	this->reset_store_output();

	// PLM memories reset

	// User-defined reset code
	burst_len = 0;
	in_size = 0;
	out_size = 0;
	reuse_factor = 0;
	ld_st_ratio = 0;
	in_place = 0;
	offset = 0;

	nwords = 0;
	ntrans = 0;
	index = 0;
	burst_len_log = 0;

	wait();
    }

    // Config
    {
	HLS_DEFINE_PROTOCOL("store-config");

	cfg.wait_for_config(); // config process
	conf_info_t config = this->conf_info.read();

	burst_len = config.burst_len;
	in_size = config.in_size;
	out_size = config.out_size;
	reuse_factor = config.reuse_factor;
	ld_st_ratio = config.ld_st_ratio;
	in_place = config.in_place;
	offset = config.offset;

	if (ld_st_ratio != 1 || in_place != 1)
	    reuse_factor = 1;

	// Logarithms
	burst_len_log = ilog2(burst_len);

	nwords = out_size;
	ntrans = nwords >> burst_len_log;
    }

    // Store
    {
	// Reuse loop
	for (uint32_t r = 0; r < reuse_factor; r++)
	{

	    if (!in_place)
		index = in_size;
	    else
		index = 0;

	    for (uint32_t b = 0; b < ntrans; b++)
	    {
		HLS_STORE_OUTPUT_BATCH_LOOP;

		this->store_compute_handshake();

		{
		    HLS_DEFINE_PROTOCOL("store-dma-conf");

		    // Configure DMA transaction
		    dma_info_t dma_info(index + offset, burst_len);
		    this->dma_write_ctrl.put(dma_info);
		}
		for (uint32_t i = 0; i < burst_len; i++)
		{
		    HLS_STORE_OUTPUT_LOOP;

		    uint32_t data = 0xdade0123;
		    this->dma_write_chnl.put(data);
		    wait();
		}

		index += burst_len;
	    }
	}
    }

    // Conclude
    {
	this->accelerator_done();
	this->process_done();
    }
}


void synth::compute_kernel()
{
    uint32_t burst_len;
    uint32_t out_size;
    uint32_t reuse_factor;
    uint32_t ld_st_ratio;
    uint32_t in_place;

    uint32_t nwords;
    uint32_t ntrans;
    uint32_t index;
    uint32_t burst_len_log;

    // Reset
    {
	HLS_DEFINE_PROTOCOL("compute-reset");

	this->reset_compute_kernel();

	// PLM memories reset

	// User-defined reset code
	burst_len = 0;
	out_size = 0;
	reuse_factor = 0;
	ld_st_ratio = 0;
	in_place = 0;

	nwords = 0;
	ntrans = 0;
	index = 0;
	burst_len_log = 0;

	wait();
    }

    // Config
    {
	HLS_DEFINE_PROTOCOL("compute-config");

	cfg.wait_for_config(); // config process
	conf_info_t config = this->conf_info.read();

	// User-defined config code
	burst_len = config.burst_len;
	out_size = config.out_size;
	reuse_factor = config.reuse_factor;
	ld_st_ratio = config.ld_st_ratio;
	in_place = config.in_place;

	if (ld_st_ratio != 1 || in_place != 1)
	    reuse_factor = 1;

	// Logarithms
	burst_len_log = ilog2(burst_len);

	nwords = out_size;
	ntrans = nwords >> burst_len_log;
    }


    // Compute
    {
	// Reuse loop
	for (uint32_t r = 0; r < reuse_factor; r++)
	{

	    for (uint32_t b = 0; b < ntrans; b++)
	    {

		this->compute_load_handshake();

		// Computing phase implementation

		this->compute_store_handshake();
	    }

	    // Conclude
	    {
		this->process_done();
	    }
	}
    }
}
