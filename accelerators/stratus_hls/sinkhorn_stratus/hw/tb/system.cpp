// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include <sstream>
#include <iostream>
#include <vector>
#include <sstream>
#include <fstream>
#include <stdio.h>

#include "system.hpp"
#include "input.h"

std::ofstream ofs;

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

    // Load input data
    load_memory();

    // Config

    {
        FPDATA data_fp(gamma);
        //uint32_t data = 0x00000000 | (uint32_t) i;
        sc_dt::sc_bv<FPDATA_WL> data_bv;
        fp2bv<FPDATA, FPDATA_WL, FPDATA_WL>(data_fp, data_bv);

        conf_info_t config(p_rows, q_cols, m_rows, data_bv, maxiter, p2p_in, p2p_out, p2p_iter, store_state);
        wait();
        conf_info.write(config);
        conf_done.write(true);
    }

    ESP_REPORT_INFO("config done");

    // Compute
    {
        // Print information about begin time
        sc_time begin_time = sc_time_stamp();
        ESP_REPORT_TIME(begin_time, "BEGIN - sinkhorn");

        // Wait the termination of the accelerator
        do { wait(); } while (!acc_done.read());
        debug_info_t debug_code = debug.read();

        // Print information about end time
        sc_time end_time = sc_time_stamp();
        ESP_REPORT_TIME(end_time, "END - sinkhorn");

        esc_log_latency(sc_object::basename(), clock_cycle(end_time - begin_time));
        wait();
        conf_done.write(false);
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
        delete [] P;
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

    //  Memory initialization:
    //  =================  ^
    //  |  inputX data     |  | p_rows * m_rows * sizeof(uint32_t)
    //  =================  v
    //  =================  ^
    //  |  inputY data     |  | q_cols * m_rows * sizeof(uint32_t)
    //  =================  v
    //  =================  ^
    //  |  output P data   |  | p_rows * q_cols * sizeof(uint32_t)
    //  =================  v
    //  =================  ^
    //  |  output CP data  |  | sizeof(uint32_t)
    //  =================  v

    // Input data and golden output (aligned to DMA_WIDTH makes your life easier)
#if (DMA_WORD_PER_BEAT == 0)
    inX_words_adj = p_rows * m_rows;
    inY_words_adj = q_cols * m_rows;
    in_words_adj = inX_words_adj + inY_words_adj;
    out_words_adj = p_rows * q_cols + 1;
#else
    // inX_words_adj = round_up(p_rows * m_rows, DMA_WORD_PER_BEAT);
    // inY_words_adj = round_up(q_cols * m_rows, DMA_WORD_PER_BEAT);
    inX_words_adj = p_rows * m_rows;
    inY_words_adj = q_cols * m_rows;
    in_words_adj = round_up(inX_words_adj+inY_words_adj, DMA_WORD_PER_BEAT);
    out_words_adj = round_up(p_rows * q_cols + 1, DMA_WORD_PER_BEAT);
#endif

    inX_size = inX_words_adj * (1);
    inY_size = inY_words_adj * (1);
    in_size = in_words_adj * (1);
    out_size = out_words_adj * (1);

    // inX = new FPDATA[inX_size];
    // inY = new FPDATA[inY_size];
    in = new FPDATA[in_size];

    // -- Allocate memory
    int X_size = p_rows * m_rows;
    int Y_size = q_cols * m_rows;
    int total_in_size = X_size + Y_size;
    int P_size = p_rows * q_cols;

    ESP_REPORT_INFO("------------ read inputs start ------------");


    // X and Y initialization
    for (int i = 0; i < 1; i++)
    {
        int j, k;
        for (j = 0; j < X_size; j++)
        {
            float data;
            data = inputX[i * inX_words_adj + j];

            FPDATA data_fp(data);
            //inX[i * inX_words_adj + j] = data_fp;
            in[i * in_words_adj + j] = data_fp;
        }

        for (k = 0; k < Y_size; k++)
        {
            float data;
            data = inputY[i * inY_words_adj + k];

            FPDATA data_fp(data);
            in[i * in_words_adj + j + k] = data_fp;
        }

    }

    // Memory initialization:
#if (DMA_WORD_PER_BEAT == 0)
    for (int i = 0; i < in_size; i++)  {
        sc_dt::sc_bv<DATA_WIDTH> data_bv;
        fp2bv<FPDATA, FPDATA_WL, FPDATA_WL>(in[i], data_bv);
        //sc_dt::sc_bv<DATA_WIDTH> data_bv(in[i]);
        for (int j = 0; j < DMA_BEAT_PER_WORD; j++)
            mem[DMA_BEAT_PER_WORD * i + j] = data_bv.range((j + 1) * DMA_WIDTH - 1, j * DMA_WIDTH);
    }
#else
    for (int i = 0; i < in_size / DMA_WORD_PER_BEAT; i++)  {
        sc_dt::sc_bv<DMA_WIDTH> data_bv;
        //  fp2bv<FPDATA, FPDATA_WL, FPDATA_WL>(in[i], data_bv);
        //sc_dt::sc_bv<DMA_WIDTH> data_bv(in[i]);
        for (int j = 0; j < DMA_WORD_PER_BEAT; j++)
        {
            sc_dt::sc_bv<DATA_WIDTH> data_bv32;
            float tmp;
            fp2native(in[i * DMA_WORD_PER_BEAT + j], tmp);
            // ESP_REPORT_INFO("/nIndex %d: value %.20f", i * DMA_WORD_PER_BEAT + j, tmp);
            fp2bv<FPDATA, FPDATA_WL, FPDATA_WL>(in[i * DMA_WORD_PER_BEAT + j], data_bv32);
            data_bv.range((j+1) * DATA_WIDTH - 1, j * DATA_WIDTH) = data_bv32;
        }
        mem[i] = data_bv;
    }
#endif

    ESP_REPORT_INFO("Offset in memory is %d", in_size / DMA_WORD_PER_BEAT);

    ESP_REPORT_INFO("load memory completed");
}

void system_t::dump_memory()
{
    // Get results from memory
    out = new FPDATA[out_size];
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
        for (int j = 0; j < DMA_WORD_PER_BEAT; j++)
        {
            sc_dt::sc_bv<DATA_WIDTH> data_bv;
            data_bv = mem[offset + i].range((j + 1) * DATA_WIDTH - 1, j * DATA_WIDTH).to_uint();
            FPDATA data_fp;
            bv2fp<FPDATA, FPDATA_WL, FPDATA_WL>(data_bv, data_fp);
            out[i * DMA_WORD_PER_BEAT + j] = data_fp;
            // ESP_REPORT_INFO("value: %d, i: %d, X size is %d, Y size is %d", mem[offset + i].range((j + 1) * DATA_WIDTH - 1, j * DATA_WIDTH).to_uint(), i, inX_size, inY_size);
        }
#endif

    ESP_REPORT_INFO("dump memory completed");
}

int system_t::validate()
{
    uint32_t errors = 0;
    int P_size = p_rows * q_cols;
    float sumP = 0, sumE = 0;
    P = (float *) calloc(P_size, sizeof(uint32_t));

    // Check for mismatches
    for (int i = 0; i < P_size + 1; i++)
    {
        float data_float;
        //    ESP_REPORT_INFO("%d", i);
        fp2native(out[i], data_float);
        if (i < P_size)
        {
            float err;
            // ESP_REPORT_INFO("output = %f , gold = %f", data_float, outputP[i]);
            P[i] = data_float;
            sumP += P[i];
            err = (P[i] - outputP[i])/P[i];
            sumE += err * err;
        }
        // if (P[i] != (uint32_t)i && i < 10) {
        //     ESP_REPORT_INFO("P Error: %d: %d.", i, P[i]);
        //     errors++;
        // }
        else
            CP_sum = data_float;
    }

    ESP_REPORT_INFO("sum of P: Actual = %f, Expected = %f, Error = %f ", sumP, 1.0, 100*(1.0-sumP)/1.0);
    ESP_REPORT_INFO("Error of P: %f , not normalized: %f", sqrt(sumE)/(229*177), sumE);
    ESP_REPORT_INFO("CP_sum: Actual = %f, Expected = %f, Error = %f", CP_sum, 0.868033, 100*(0.868033-CP_sum)/0.868033);

    float P_error =  100*(sqrt(sumE))/(229*177);
    float sum_P_error = 100*(1.0-sumP)/1.0;
    float CP_error = 100*(0.868033-CP_sum)/0.868033;

    if(P_error > 3 || CP_error > 3)
        errors++;

    // if(sum != (uint32_t)CP_sum)
    // {
    //     ESP_REPORT_INFO("CP_sum Error: %d: %d.", CP_sum, sum);
    //     errors++;
    // }

    return errors;
}
