// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include <sstream>
#include "system.hpp"
#include "../../common/utils.h"     /* validate_buffer, init_parameters */
#include "../../common/init_buff.h" /* init_buffer func */


// helper functions

void system_t::load_mem(float *in, int offset, int32_t base_index, int32_t size)
{
  FPDATA_S data_fp;
  sc_dt::sc_bv<FPDATA_S_WL> data_bv;

  int16_t mem_i = 0;

  // base_index is the base for mem[].
  // offset is the offset for one variable.


  for(int16_t i=0; i < size; i+=DMA_WORD_PER_BEAT) {
       for (int k = 0; k < DMA_WORD_PER_BEAT; k++) {
	  // convert floating to fx 
          data_fp = FPDATA_S(in[offset + i + k]);
	  // convert fx to bv
	  fp2bv<FPDATA_S, FPDATA_S_WL>(data_fp, data_bv);
	  mem[base_index + mem_i].range((k+1) * FPDATA_S_WL - 1, k * FPDATA_S_WL) = data_bv;

       }  
       mem_i++;
  }

}



// Process
void system_t::config_proc()
{

    // Reset
    {
        conf_done.write(false);
        conf_info.write(conf_info_t());
        wait();
    }

    ESP_REPORT_INFO("reset done");

    // Config
    load_memory();
    {
        conf_info_t config;
        // Custom configuration
        /* <<--params-->> */

        config.num_batch_k = num_batch_k;
        config.batch_size_k = batch_size_k;
        config.num_batch_x = num_batch_x;
        config.batch_size_x = batch_size_x;

        wait(); conf_info.write(config);
        conf_done.write(true);
    }

    ESP_REPORT_INFO("config done");

    // Compute
    {
        // Print information about begin time
        sc_time begin_time = sc_time_stamp();
        ESP_REPORT_TIME(begin_time, "BEGIN - mriq");

        // Wait the termination of the accelerator
        do { wait(); } while (!acc_done.read());
        debug_info_t debug_code = debug.read();

        // Print information about end time
        sc_time end_time = sc_time_stamp();
        ESP_REPORT_TIME(end_time, "END - mriq");

        esc_log_latency(sc_object::basename(), clock_cycle(end_time - begin_time));
        wait(); conf_done.write(false);
    }

    // Validate
    {
        dump_memory(); // store the output in more suitable data structure if needed
        // check the results with the golden model

        if (validate())
        {
            ESP_REPORT_ERROR("validation failed!");
        } else
        {
            ESP_REPORT_INFO("validation passed!");
        }
    }

    // Conclude
    {
        sc_stop();
    }
}

// Functions
void system_t::load_memory()
{
    // Optional usage check
#ifdef CADENCE
    if (esc_argc() != 3) {
        ESP_REPORT_INFO("usage: %s\n", esc_argv()[0]);
        sc_stop();
    }
#endif

    // init corresponding parameters
    init_parameters(batch_size_x, num_batch_x, 
		    batch_size_k, num_batch_k,
		    &in_words_adj, &out_words_adj,
		    &in_len, &out_len,
		    &in_size, &out_size,
		    &out_offset,
		    &mem_size,
		    DMA_WORD_PER_BEAT);

    // load input data to array "in" and golden output to array "gold"
    in = new float[in_len];
    gold = new float[out_len];

    init_buffer(in, gold, esc_argv()[1], esc_argv()[2],
		batch_size_x, num_batch_x, 
		batch_size_k, num_batch_k);

    // store bv data into mem
    load_mem(in, 0, 0, in_len);
    delete [] in;

    ESP_REPORT_INFO("load memory completed");
}


void system_t::dump_memory()
{
    // dump data to out with float type

    out = new float[out_len];

    uint32_t offset = in_len;

    offset = offset / DMA_WORD_PER_BEAT;

    sc_dt::sc_bv<FPDATA_L_WL> data_bv;   

    // layout of output
    /*
     ************ -
     ***  Qr  *** | batch_size_x, batch 0
     ************ -
     ***  Qi  *** | batch_size_x, batch 0
     ************ -
     ***  Qr  *** | batch_size_x, batch 1
     ************ -
     ***  Qi  *** | batch_size_x, batch 1
     ************ -
    */

    for(int r = 0; r < num_batch_x; r++) {
      
	for (int i = 0; i < batch_size_x / DMA_WORD_PER_BEAT; i++) {    

	    for(int j = 0; j < DMA_WORD_PER_BEAT; j++) {

		int32_t index = 2 * r * batch_size_x + i * DMA_WORD_PER_BEAT + j;

		data_bv = mem[offset + i].range((j + 1) * FPDATA_L_WL - 1, j * FPDATA_L_WL);

		FPDATA_L data_fp = bv2fp<FPDATA_L, FPDATA_L_WL>(data_bv);

		out[index] = (float) data_fp;  
	    }
	}

	offset += batch_size_x / DMA_WORD_PER_BEAT;
	//

	for (int i = 0; i < batch_size_x / DMA_WORD_PER_BEAT; i++) {    
	    for (int j = 0; j < DMA_WORD_PER_BEAT; j++) {

	      int32_t index = (2 * r + 1) * batch_size_x + i * DMA_WORD_PER_BEAT + j;
		data_bv = mem[offset + i].range((j + 1) * FPDATA_L_WL - 1, j * FPDATA_L_WL);

		FPDATA_L data_fp = bv2fp<FPDATA_L, FPDATA_L_WL>(data_bv);
		out[index] = (float) data_fp;
		
	    }
	}
	offset += batch_size_x / DMA_WORD_PER_BEAT;
    }

    ESP_REPORT_INFO("dump memory completed");

}

int system_t::validate()
{
    // Check for mismatches
    int ret;
    ret = validate_buffer(out, gold, out_len);

    delete [] out;
    delete [] gold;

    return ret;
}
