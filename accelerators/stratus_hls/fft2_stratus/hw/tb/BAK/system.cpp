// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include <random>
#include <sstream>
#include "system.hpp"

// Helper random generator
static std::uniform_real_distribution<float> *dis;
static std::random_device rd;
static std::mt19937 *gen;


static void init_random_distribution(void)
{
    const float LO = -10.0;
    const float HI = 10.0;

    gen = new std::mt19937(rd());
    dis = new std::uniform_real_distribution<float>(LO, HI);
}

static float gen_random_float(void)
{
    return (*dis)(*gen);
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
        config.logn_samples = logn_samples;
        config.num_ffts = num_ffts;
        config.do_inverse = do_inverse;
        config.do_shift = do_shift;
        config.scale_factor = scale_factor;

        wait(); 
        conf_info.write(config);
        conf_done.write(true);
    }

    ESP_REPORT_INFO("config done");

    // Compute
    {
        // Print information about begin time
        sc_time begin_time = sc_time_stamp();
        ESP_REPORT_TIME(begin_time, "BEGIN - fft2");

        // Wait the termination of the accelerator
        do { wait(); } while (!acc_done.read());
        debug_info_t debug_code = debug.read();

        // Print information about end time
        sc_time end_time = sc_time_stamp();
        ESP_REPORT_TIME(end_time, "END - fft2");

        esc_log_latency(sc_object::basename(), clock_cycle(end_time - begin_time));
        wait(); 
        conf_done.write(false);
    }

    // Validate
    {
        const double ERROR_COUNT_TH = 0.02;
        dump_memory(); // store the output in more suitable data structure if needed
        // check the results with the golden model
        int errs = validate();
        double pct_err = ((double)errs / (double)(2 * num_ffts * num_samples));
        if (pct_err > ERROR_COUNT_TH)
        {
            ESP_REPORT_ERROR("DMA %u FX %u nFFT %u logn %u : Exceeding error count threshold : %d of %u = %g vs %g : validation failed!", DMA_WIDTH, FX_WIDTH, num_ffts, logn_samples, errs, (2 * num_ffts * num_samples), pct_err, ERROR_COUNT_TH);
        } else {
            ESP_REPORT_INFO("DMA %u FX %u nFFT %u logn %u : Not exceeding error count threshold : %d of %u = %g vs %g: validation passed!", DMA_WIDTH, FX_WIDTH, num_ffts, logn_samples, errs, (2 * num_ffts * num_samples), pct_err, ERROR_COUNT_TH);
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
    in_words_adj  = 2 * num_ffts * num_samples;
    out_words_adj = 2 * num_ffts * num_samples;
#else
    in_words_adj  = round_up(2 * num_ffts * num_samples, DMA_WORD_PER_BEAT);
    out_words_adj = round_up(2 * num_ffts * num_samples, DMA_WORD_PER_BEAT);
#endif

    in_size  = in_words_adj;
    out_size = out_words_adj;
    printf("TEST : MEM : MEM_SIZE = %u : in_size = %u  out_size = %u  gold_size = %u\n", MEM_SIZE, in_size, out_size, out_size);
    if (in_size > MEM_SIZE) {
        ESP_REPORT_INFO("ERROR : Specified in_size is %u and MEM_SIZE is %u -- in_size must be <= MEM_SIZE", in_size, MEM_SIZE);
    }
    if (out_size > MEM_SIZE) {
        ESP_REPORT_INFO("ERROR : Specified out_size is %u and MEM_SIZE is %u -- out_size must be <= MEM_SIZE", out_size, MEM_SIZE);
    }

    init_random_distribution();
    in = new float[in_size];
    printf("TEST : MEM : in[%d] @ %p  :: in[%d] @ %p\n", 0, &in[0], (in_size-1), &in[in_size-1]);
    for (int j = 0; j < 2 * num_ffts * num_samples; j++) {
        in[j] = gen_random_float();
        //in[j] = ((float)j); ///10000.0;
    }

    // Compute golden output
    gold = new float[out_size];
    memcpy(gold, in, out_size * sizeof(float));

    fft2_comp(gold, num_ffts, num_samples, logn_samples, do_inverse, do_shift); // do_bitrev is always true

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
            data_bv.range((j+1) * DATA_WIDTH - 1, j * DATA_WIDTH) = fp2bv<FPDATA, WORD_SIZE>(FPDATA(in[i * DMA_WORD_PER_BEAT + j]));
        mem[i] = data_bv;
    }
#endif

    ESP_REPORT_INFO("load memory completed");
}

void system_t::dump_memory()
{
    // Get results from memory
    out = new float[out_size];
    uint32_t offset = 0;

#if (DMA_WORD_PER_BEAT == 0)
    offset = offset * DMA_BEAT_PER_WORD;
    for (int i = 0; i < out_size; i++)  {
        sc_dt::sc_bv<DATA_WIDTH> data_bv;

        for (int j = 0; j < DMA_BEAT_PER_WORD; j++)
            data_bv.range((j + 1) * DMA_WIDTH - 1, j * DMA_WIDTH) = mem[offset + DMA_BEAT_PER_WORD * i + j];

        FPDATA out_fx = bv2fp<FPDATA, WORD_SIZE>(data_bv);
        out[i] = (float) out_fx;
    }
#else
    offset = offset / DMA_WORD_PER_BEAT;
    for (int i = 0; i < out_size / DMA_WORD_PER_BEAT; i++)
        for (int j = 0; j < DMA_WORD_PER_BEAT; j++) {
            FPDATA out_fx = bv2fp<FPDATA, WORD_SIZE>(mem[offset + i].range((j + 1) * DATA_WIDTH - 1, j * DATA_WIDTH));
            out[i * DMA_WORD_PER_BEAT + j] = (float) out_fx;
        }
#endif

    ESP_REPORT_INFO("dump memory completed");
}

int system_t::validate()
{
    // Check for mismatches
    uint32_t errors = 0;
    const float ERR_TH = 0.05;

    for (int nf = 0; nf < num_ffts; nf++ ){
        for (int j = 0; j < 2 * num_samples; j++) {
            int idx = 2 * nf * num_samples + j;
            if ((fabs(gold[idx] - out[idx]) / fabs(gold[idx])) > ERR_TH) {
                if (errors < 10) {
                    ESP_REPORT_INFO(" ERROR %u : fft %u : idx %u : gold %g  out %g", errors, nf, idx, gold[idx], out[idx]);
                }
                errors++;
            }
        }
    }

    ESP_REPORT_INFO("DMA %u FX %u nFFT %u logn %u : Relative error > %f for %d output values out of %d\n", DMA_WIDTH, FX_WIDTH, num_ffts,logn_samples,  ERR_TH, errors, 2*num_ffts*num_samples);

    delete [] in;
    delete [] out;
    delete [] gold;

    return errors;
}
