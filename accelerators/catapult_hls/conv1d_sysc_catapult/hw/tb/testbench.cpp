// Copyright (c) 2011-2025 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "testbench.hpp"
#include "ac_math/ac_random.h"
#include <mc_connections.h>
#include <mc_scverify.h>

void testbench::proc()
{
    conf_info.Reset();

    wait();

    CCS_LOG("--------------------------------");
    CCS_LOG("ESP - conv1d [Catapult HLS SystemC]");
    CCS_LOG("--------------------------------");

#if (DMA_WORD_PER_BEAT == 0)
    in_words_adj  = batch_size * feature_map_len * n_channels;
    out_words_adj = batch_size * feature_map_len * n_filters;
#else
    in_words_adj  = round_up(batch_size * feature_map_len * n_channels, DMA_WORD_PER_BEAT);
    out_words_adj = round_up(batch_size * feature_map_len * n_filters, DMA_WORD_PER_BEAT);
#endif

    in_size  = in_words_adj * (batch_size);
    out_size = out_words_adj * (batch_size);

    CCS_LOG("  - DMA width: " << DMA_WIDTH);
    CCS_LOG("  - DATA width: " << DATA_WIDTH);
    CCS_LOG("--------------------------------");

    in   = new ac_int<DATA_WIDTH, false>[in_size];
    gold = new ac_int<DATA_WIDTH, false>[out_size];
    FPDATA data;

    // Initialize input
    for (uint32_t i = 0; i < batch_size; i++) {
        for (uint32_t j = 0; j < batch_size * feature_map_len * n_channels; j += 1) {
            ac_random(data);
            FPDATA_WORD data_int32;
            data_int32.set_slc(0, data.slc<DATA_WIDTH>(0));
            in[i * in_words_adj + j] = data_int32;
        }
    }

    // Compute golden output
    for (uint32_t i = 0; i < batch_size; i++)
        for (uint32_t j = 0; j < batch_size * feature_map_len * n_filters; j++)
            gold[i * out_words_adj + j] = in[i * in_words_adj + j];

#if (DMA_WORD_PER_BEAT == 0)
    for (uint32_t i = 0; i < in_size; i++) {
        ac_int<DATA_WIDTH> data_bv = in[i];
        for (int j = 0; j < DMA_BEAT_PER_WORD; j++)
            mem[DMA_BEAT_PER_WORD * i + j] = data_bv.slc<DMA_WIDTH>(j * DMA_WIDTH);
    }
#else
    for (uint32_t i = 0; i < in_size / DMA_WORD_PER_BEAT; i++) {
        ac_int<DMA_WIDTH> data_bv;
        for (int j = 0; j < DMA_WORD_PER_BEAT; j++) {
            data_bv.set_slc(j * DATA_WIDTH, in[i * DMA_WORD_PER_BEAT + j]);
            FPDATA in_fx;
            int2fx(in[i * DMA_WORD_PER_BEAT + j], in_fx);
        }
        mem[i] = data_bv;
    }
#endif

    CCS_LOG("load memory completed");

    {
        conf_info_t config;

        /* <<--params-->> */
        config.kernel_size = kernel_size;
        config.n_channels = n_channels;
        config.stride = stride;
        config.is_relu = is_relu;
        config.addrB = addrB;
        config.addrO = addrO;
        config.addrI = addrI;
        config.addrW = addrW;
        config.batch_size = batch_size;
        config.n_filters = n_filters;
        config.feature_map_len = feature_map_len;
        config.padding = padding;

        conf_info.Push(config);
    }

    CCS_LOG("config done");

    do {
        wait();
    } while (!acc_done.read());

    int err    = 0;
    int offset = in_size;

    out = new ac_int<DATA_WIDTH, false>[out_size];

#if (DMA_WORD_PER_BEAT == 0)
    offset = offset * DMA_BEAT_PER_WORD;
    for (uint32_t i = 0; i < out_size; i++) {
        ac_int<DATA_WIDTH> data_bv;

        for (int j = 0; j < DMA_BEAT_PER_WORD; j++)
            data_bv.set_slc(j * DMA_WIDTH, mem[offset + DMA_BEAT_PER_WORD * i + j]);

        out[i] = data_bv.to_int64();
    }
#else
    offset = offset / DMA_WORD_PER_BEAT;
    for (uint32_t i = 0; i < out_size / DMA_WORD_PER_BEAT; i++)
        for (uint32_t j = 0; j < DMA_WORD_PER_BEAT; j++) {
            out[i * DMA_WORD_PER_BEAT + j] = mem[offset + i].slc<DATA_WIDTH>(j * DATA_WIDTH);
        }
#endif

    CCS_LOG("dump memory completed");

    for (uint32_t i = 0; i < batch_size; i++)
        for (uint32_t j = 0; j < batch_size * feature_map_len * n_filters; j++) {
            FPDATA out_gold_fx = 0;
            int2fx(gold[i * out_words_adj + j], out_gold_fx);
            FPDATA out_res_fx = 0;

            int2fx(out[i * out_words_adj + j], out_res_fx);

            if (gold[i * out_words_adj + j] != out[i * out_words_adj + j]) err++;
        }

    if (err > 0) CCS_LOG("SIMULATION FAILED ! \n - errors " << err);
    else
        CCS_LOG("SIMULATION PASSED ! ");

    sc_stop();

    wait();
}
