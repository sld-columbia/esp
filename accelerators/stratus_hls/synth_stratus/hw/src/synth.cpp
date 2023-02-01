// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "synth.hpp"
#include "synth_directives.hpp"
#include "log2.h"

// Functions

#include "synth_functions.hpp"

// Processes
#ifdef COLLECT_LATENCY 
void synth::latency_collector()
{
    bool load_exec;
    bool compute_exec;
    bool store_exec;

    {
    HLS_DEFINE_PROTOCOL("latency-collector-reset");
    load_exec = false;
    compute_exec = false; 
    store_exec = false; 
    load.reset();
    compute.reset();
    store.reset();

    wait();
    }

    while(true){
        HLS_DEFINE_PROTOCOL("latency-collector");
        load_exec = this->sig_load.read();
        compute_exec = this->sig_compute.read();
        store_exec = this->sig_store.read();

        while (!load.nb_can_put()) wait();
        load.nb_put(load_exec);
        
        while (!compute.nb_can_put()) wait();
        compute.nb_put(compute_exec);
        
        while (!store.nb_can_put()) wait();
        store.nb_put(store_exec);
        wait();
    }
}
#endif 

void synth::load_input()
{
    uint32_t pattern;
    uint32_t in_size;
    uint32_t access_factor;
    uint32_t burst_len;
    uint32_t irregular_seed;
    uint32_t reuse_factor;
    uint32_t ld_st_ratio;
    uint32_t stride_len;
    uint32_t in_place; 
    uint32_t offset;
    uint32_t rd_data;
    uint32_t wr_data;

    uint32_t nwords;
    uint32_t ntrans;
    uint32_t masked_seed;
    uint32_t index;
    uint32_t stride;
    uint32_t burst_len_log;
    uint32_t rd_err;
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
	irregular_seed = 0;
	reuse_factor = 0;
	stride_len = 0;
	in_place = 0;
	ld_st_ratio = 0;
    offset = 0;
    rd_data = 0;

	nwords = 0;
	ntrans = 0;
	masked_seed = 0;
	index = 0;
	stride = 0;
	burst_len_log = 0;
    rd_err = 0; 
#ifdef COLLECT_LATENCY
    this->sig_load.write(false);
#endif
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
	irregular_seed = config.irregular_seed;
	reuse_factor = config.reuse_factor;
	stride_len = config.stride_len;
	ld_st_ratio = config.ld_st_ratio;
    in_place = config.in_place;
	offset = config.offset;
    rd_data = config.rd_data;
    wr_data = config.wr_data;

	// Logarithms
	burst_len_log = ilog2(burst_len);

	// Number of words to be read
	if (config.pattern == IRREGULAR)
	    nwords = in_size >> access_factor;
	else
	    nwords = in_size;

	// Number of DMA read transactions
	ntrans = nwords >> burst_len_log;

	// Seed for semi-random DMA load index
	masked_seed = (irregular_seed & (ntrans - 1)) << burst_len_log;
    
    if (pattern == IRREGULAR){
        in_place = 0;     
    }
    
    if (ld_st_ratio > 1 && in_place == 1)
	    reuse_factor = 1;
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

	    if (pattern == IRREGULAR) {
		index += masked_seed;
		index &= (nwords - 1);
	    }
        
        {
        HLS_DEFINE_PROTOCOL("load-start");
#ifdef COLLECT_LATENCY
        this->sig_load.write(true);
#endif
        }

        // Bursts loop
	    for (uint32_t b = 0; b < ntrans; b++)
	    {
		HLS_LOAD_INPUT_BATCH_LOOP;
		
        {
		    HLS_DEFINE_PROTOCOL("load-dma-conf");

		    // Configure DMA transaction
		    dma_info_t dma_info(index + offset, burst_len, SIZE_WORD);
		    this->dma_read_ctrl.put(dma_info);
		}
        
        // Words loop
		for (uint32_t i = 0; i < burst_len; i++)
		{
		    HLS_LOAD_INPUT_LOOP;
		    {
			HLS_LOAD_DMA;
			uint32_t data = this->dma_read_chnl.get().to_uint();
			wait();
		   
            //validate read data
            if ((!in_place || r == 0) && data != rd_data){
                rd_err = data;
            } else if (in_place && r > 0 && data != wr_data){
                rd_err = data;
            }
            rd_errs.write(rd_err); 
		    }
        }
        
        {
        HLS_DEFINE_PROTOCOL("load-stop");
#ifdef COLLECT_LATENCY
        this->sig_load.write(false);
#endif
        }

       this->load_compute_handshake();
       {
        HLS_DEFINE_PROTOCOL("load-resume");
#ifdef COLLECT_LATENCY
        this->sig_load.write(true);
#endif
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
        
    {
    HLS_DEFINE_PROTOCOL("load-done");
#ifdef COLLECT_LATENCY
    this->sig_load.write(false);
#endif
    }

    // Conclude
    {
	this->process_done();
    }
}



void synth::store_output()
{

    uint32_t pattern;
    uint32_t burst_len;
    uint32_t in_size;
    uint32_t out_size;
    uint32_t reuse_factor;
    uint32_t in_place;
    uint32_t ld_st_ratio;
    uint32_t offset;
    uint32_t rd_err;
    uint32_t stride_len;

    uint32_t nwords;
    uint32_t ntrans;
    uint32_t index;
    uint32_t burst_len_log;
    uint32_t wr_data;
    uint32_t stride;
    // Reset
    {
	HLS_DEFINE_PROTOCOL("store-reset");

	this->reset_store_output();

	// PLM memories reset

	// User-defined reset code
	pattern = 0;
    burst_len = 0;
	in_size = 0;
	out_size = 0;
	reuse_factor = 0;
	in_place = 0;
	ld_st_ratio = 0;
    offset = 0;
    rd_err = 0;
    stride_len = 0;

	nwords = 0;
	ntrans = 0;
    index = 0;
	burst_len_log = 0;
    wr_data = 0;   
    stride = 0;
#ifdef COLLECT_LATENCY
    this->sig_store.write(false);
#endif
    wait();
    }

    // Config
    {
	HLS_DEFINE_PROTOCOL("store-config");

	cfg.wait_for_config(); // config process
	conf_info_t config = this->conf_info.read();

    pattern = config.pattern;
	burst_len = config.burst_len;
	in_size = config.in_size;
	out_size = config.out_size;
	reuse_factor = config.reuse_factor;
	in_place = config.in_place;
	ld_st_ratio = config.ld_st_ratio;
	offset = config.offset;
    wr_data = config.wr_data;
	stride_len = config.stride_len;
   	
    if (ld_st_ratio > 1 && in_place == 1)
	    reuse_factor = 1;

    if (pattern == IRREGULAR){
        in_place = 0;     
    }

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

	    stride = 0;
        if (!in_place)
		    index = in_size;
	    else 
		    index = 0;

	    for (uint32_t b = 0; b < ntrans; b++)
	    {
		HLS_STORE_OUTPUT_BATCH_LOOP;

		this->store_compute_handshake();
        
        {
        HLS_DEFINE_PROTOCOL("store-start");
#ifdef COLLECT_LATENCY
        this->sig_store.write(true);
#endif
        }
        
        {
	    HLS_DEFINE_PROTOCOL("store-dma-conf");
        rd_err = rd_errs.read();
		// Configure DMA transaction
		dma_info_t dma_info(index + offset, burst_len, SIZE_WORD);
		this->dma_write_ctrl.put(dma_info);
		}
        
        for (uint32_t i = 0; i < burst_len; i++)
		{
		    HLS_STORE_OUTPUT_LOOP;

		    {
			HLS_STORE_DMA;
            if (r == reuse_factor - 1 && b == ntrans - 1 && i == burst_len - 1 && rd_err > 0){
                this->dma_write_chnl.put(rd_err);
            }else{
                this->dma_write_chnl.put(wr_data);
            }
            wait();
		    }
		}

	    // Index calculation
		if (in_place) {
            if (pattern == STREAMING) {
                
                index += burst_len;

            } else if (pattern == STRIDED) {
                
                index += stride_len;
                if (index >= out_size) {
                stride += burst_len;
                index = stride;
                }

            } 
        } else {
            index += burst_len;
        }

        {
        HLS_DEFINE_PROTOCOL("store-stop");
#ifdef COLLECT_LATENCY
        this->sig_store.write(false);
#endif
        }
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
    uint32_t in_size;
    uint32_t reuse_factor;
    uint32_t ld_st_ratio;
    uint32_t in_place;
    uint32_t compute_bound_factor;

    uint32_t nwords;
    uint32_t ntrans;
    uint32_t burst_len_log;
    uint32_t compute_bound_delay;
    uint32_t ld_st_ratio_cnt;

    // Reset
    {
	HLS_DEFINE_PROTOCOL("compute-reset");

	this->reset_compute_kernel();

	// PLM memories reset

	// User-defined reset code
	burst_len = 0;
	in_size = 0;
	reuse_factor = 0;
	in_place = 0;
    ld_st_ratio = 0;
	compute_bound_factor = 0;

	nwords = 0;
	ntrans = 0;
	burst_len_log = 0;
    ld_st_ratio_cnt = 0;
	compute_bound_delay = 0;
#ifdef COLLECT_LATENCY
    this->sig_compute.write(false);
#endif
	wait();
    }

    // Config
    {
	HLS_DEFINE_PROTOCOL("compute-config");

	cfg.wait_for_config(); // config process
	conf_info_t config = this->conf_info.read();

	// User-defined config code
	burst_len = config.burst_len;
	in_size = config.in_size;
	reuse_factor = config.reuse_factor;
	in_place = config.in_place;
    ld_st_ratio = config.ld_st_ratio;
	compute_bound_factor = config.compute_bound_factor;

    if (ld_st_ratio > 1 && in_place == 1)
	    reuse_factor = 1;

	// Logarithms
	burst_len_log = ilog2(burst_len);

    // Delay between the end of a DMA read transaction and the issue of the
	// next. When this delay is > 0 it emulates a compute-bound accelerator.
	compute_bound_delay = burst_len * (compute_bound_factor - 1);

	nwords = in_size;
	ntrans = nwords >> burst_len_log;
    }

    // Compute
    {
	// Reuse loop
	for (uint32_t r = 0; r < reuse_factor; r++)
	{
	    ld_st_ratio_cnt = 0;

	    for (uint32_t b = 0; b < ntrans; b++)
	    {

		    this->compute_load_handshake();
            {
            HLS_DEFINE_PROTOCOL("compute_start");
#ifdef COLLECT_LATENCY
            this->sig_compute.write(true);
#endif
             }
            // Computing phase implementation
		    // Compute-bound emulation
            for (uint32_t i = 0; i < compute_bound_delay; i++)
	    	{
		        HLS_LOAD_INPUT_LOOP;
                {
                HLS_DEFINE_PROTOCOL("compute-bound-delay");
                wait();
		        }
            }
    		// Handshake to compute process
	    	ld_st_ratio_cnt++;
        
            {
            HLS_DEFINE_PROTOCOL("compute_stop");
#ifdef COLLECT_LATENCY
            this->sig_compute.write(false);
#endif
            }

		    if (ld_st_ratio_cnt == ld_st_ratio) {
		        this->compute_store_handshake();
                ld_st_ratio_cnt = 0;		
            }

	    }
	}
	
    // Conclude
    {
	this->process_done();
    }
    }
}
