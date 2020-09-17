// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include <sstream>
#include "system.hpp"

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
        config.input_rows = input_rows;
        config.output_rows = output_rows;

        wait(); conf_info.write(config);
        conf_done.write(true);
    }

    ESP_REPORT_INFO("config done");

    // Compute
    {
        // Print information about begin time
        sc_time begin_time = sc_time_stamp();
        ESP_REPORT_TIME(begin_time, "BEGIN - cholesky_small");

        // Wait the termination of the accelerator
        do { wait(); } while (!acc_done.read());
        debug_info_t debug_code = debug.read();

        // Print information about end time
        sc_time end_time = sc_time_stamp();
        ESP_REPORT_TIME(end_time, "END - cholesky_small");

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
    if (esc_argc() != 1)
    {
        ESP_REPORT_INFO("usage: %s\n", esc_argv()[0]);
        sc_stop();
    }
#endif

    // Input data and golden output (aligned to DMA_WIDTH makes your life easier)
#if (DMA_WORD_PER_BEAT == 0)
    in_words_adj = input_rows * input_rows;
    out_words_adj = output_rows * output_rows;
#else
    in_words_adj = round_up(input_rows * input_rows, DMA_WORD_PER_BEAT);
    out_words_adj = round_up(output_rows * output_rows, DMA_WORD_PER_BEAT);
#endif

    in_size = in_words_adj * (1);
    out_size = out_words_adj * (1);


ifstream f("/home/esp2020/pa2562/esp-1/accelerators/stratus_hls/cholesky_small/tb/inputnew.txt");
    if (!f) {
        cout << "Cannot open input file.\n";
        return;
    }
ifstream fo("/home/esp2020/pa2562/esp-1/accelerators/stratus_hls/cholesky_small/tb/outputnew.txt");
    if (!fo) {
        cout << "Cannot open input file.\n";
        return;
    }

    in = new float[in_size];
    for (int i = 0; i < 1; i++)
        for (int j = 0; j < input_rows * input_rows; j++)
          f>>  in[i * in_words_adj + j] ;

    // Compute golden output
    gold = new float[out_size];
    for (int i = 0; i < 1; i++)
        for (int j = 0; j < output_rows * output_rows; j++)
           fo>>  gold[i * out_words_adj + j] ;

    // Memory initialization:
#if (DMA_WORD_PER_BEAT == 0)
    for (int i = 0; i < in_size; i++)  {
        sc_dt::sc_bv<DATA_WIDTH> data_bv(in[i]);
        for (int j = 0; j < DMA_BEAT_PER_WORD; j++)
            mem[DMA_BEAT_PER_WORD * i + j] = data_bv.range((j + 1) * DMA_WIDTH - 1, j * DMA_WIDTH);
    }
#else
    for (int i = 0; i < in_size / DMA_WORD_PER_BEAT; i++)  {
        sc_dt::sc_bv<DMA_WIDTH> data_bv;
        for (int j = 0; j < DMA_WORD_PER_BEAT; j++)
            data_bv.range((j+1) * DATA_WIDTH - 1, j * DATA_WIDTH) = fp2bv<FPDATA, WORD_SIZE>(FPDATA( in[i * DMA_WORD_PER_BEAT + j]));
        mem[i] = data_bv;
    }
#endif

    ESP_REPORT_INFO("load memory completed");
}

void system_t::dump_memory()
{
    // Get results from memory
    out = new float[out_size];
    uint32_t offset = in_size;

#if (DMA_WORD_PER_BEAT == 0)
    offset = offset * DMA_BEAT_PER_WORD;
    for (int i = 0; i < out_size; i++)  {
        sc_dt::sc_bv<DATA_WIDTH> data_bv;

        for (int j = 0; j < DMA_BEAT_PER_WORD; j++)
            data_bv.range((j + 1) * DMA_WIDTH - 1, j * DMA_WIDTH) = mem[offset + DMA_BEAT_PER_WORD * i + j];

        out[i] = data_bv.to_int64();
    }
#else
    offset = offset / DMA_WORD_PER_BEAT;
    for (int i = 0; i < out_size / DMA_WORD_PER_BEAT; i++)
        for (int j = 0; j < DMA_WORD_PER_BEAT; j++) {
           FPDATA out_fx =  bv2fp<FPDATA, WORD_SIZE>(mem[offset + i].range((j + 1) * DATA_WIDTH - 1, j * DATA_WIDTH).to_int64());
out[i * DMA_WORD_PER_BEAT + j] = (float) out_fx;
}
#endif

    ESP_REPORT_INFO("dump memory completed");
}

int system_t::validate()
{
    // Check for mismatches
    uint32_t errors = 0;
   const float ERR_TH = 0.01f; //1%
    for (int i = 0; i < 1; i++)
        for (int j = 0; j < output_rows * output_rows; j++) {
		cout << " GOLDEN  || " << gold[i * out_words_adj + j] << "   DESIGN  || " <<  out[i * out_words_adj + j] << "\n" ;
		if ((fabs(gold[i* out_words_adj + j] - out[i* out_words_adj +j]) / fabs(gold[i * out_words_adj +j])) > ERR_TH) {
                                errors++;
                        }
	}

    delete [] in;
    delete [] out;
    delete [] gold;

    return errors;
}
