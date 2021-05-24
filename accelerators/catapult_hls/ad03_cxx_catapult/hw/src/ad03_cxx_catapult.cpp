// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "esp_headers.hpp"

#include "ad03_cxx_catapult.hpp"
#include "anomaly_detector.h"

#include <mc_scverify.h>

template <class T1, class T2>
void compute_wrapper(T1 &input, T2 &output) {
    unsigned short const_size_in_1;
    unsigned short const_size_out_1;
    layer22_t tmp[PLM_SIZE];
    anomaly_detector(input.data, tmp, const_size_in_1, const_size_out_1);
OUTPUT_CAST_LOOP:
    for (unsigned i = 0; i < PLM_SIZE; i++)
        output.data[i] = tmp[i];
}

#if 0
template <class W_PLM_TYPE, int W_PLM_SIZE, int DMA_INDEX>
void read_weights(plm_t<W_PLM_TYPE, W_PLM_SIZE> &plm_w, ac_channel<dma_info_t> &dma_read_ctrl, ac_channel<dma_data_t> &dma_read_chnl) {
    // Configure DMA read channel (CTRL)
    dma_info_t dma_read_info = {DMA_INDEX, W_PLM_SIZE, DMA_SIZE};
    bool dma_read_ctrl_done = false;
LOAD_CTRL_LOOP:
    do { dma_read_ctrl_done = dma_read_ctrl.nb_write(dma_read_info); } while (!dma_read_ctrl_done);
    ESP_REPORT_INFO(VON, "DMA read ctrl: data index = %u, data length = %u, size [0=8b, 1=16b, 2=32b, 3=64b] = %llu", ESP_TO_UINT32(dma_read_info.index), ESP_TO_UINT32(dma_read_info.length), dma_read_info.size.to_uint64());

    if (dma_read_ctrl_done) { // Force serialization between DMA control and DATA data transfer
LOAD_LOOP:
        for (uint16_t i = 0; i < W_PLM_SIZE; i++) {

            ac_int<W_PLM_TYPE::width, false> data_ac;
#ifndef __SYNTHESIS__
            while (!dma_read_chnl.available(1)) {}; // Hardware stalls until data ready
#endif
            data_ac = dma_read_chnl.read().template slc<8>(0);

            W_PLM_TYPE data;
            data.set_slc(0, data_ac);

            plm_w.data[i] = data;

            ESP_REPORT_INFO(VOFF, "plm_in[%u] = %f", ESP_TO_UINT32(i), data.to_double());
        }
    }
}
#endif

#pragma hls_design top
#ifdef __CUSTOM_SIM__
void ad03_cxx_catapult(
#else
void CCS_BLOCK(ad03_cxx_catapult)(
#endif
    ac_channel<conf_info_t> &conf_info,
    ac_channel<dma_info_t> &dma_read_ctrl,
    ac_channel<dma_info_t> &dma_write_ctrl,
    ac_channel<dma_data_t> &dma_read_chnl,
    ac_channel<dma_data_t> &dma_write_chnl,
    ac_sync &acc_done) {

    // Bookkeeping variables
    uint32_t dma_read_data_index = 0;
    uint32_t dma_read_data_length = PLM_SIZE;
    uint32_t dma_write_data_index= 0;
    uint32_t dma_write_data_length = PLM_SIZE;

    // DMA configuration
    dma_info_t dma_read_info = {0, 0, 0};
    dma_info_t dma_write_info = {0, 0, 0};

    conf_info_t config;
    uint32_t mode = 0;
    uint32_t batch = 0;

    // Private Local Memories
    plm_in_t plm_in;
    plm_out_t plm_out;

#if 0
    plm_w2_t plm_w2;
    plm_b2_t plm_b2;
    plm_s4_t plm_s4;
    plm_b4_t plm_b4;
    plm_w6_t plm_w6;
    plm_b6_t plm_b6;
    plm_s8_t plm_s8;
    plm_b8_t plm_b8;
    plm_w10_t plm_w10;
    plm_b10_t plm_b10;
    plm_s12_t plm_s12;
    plm_b12_t plm_b12;
    plm_w14_t plm_w14;
    plm_b14_t plm_b14;
    plm_s16_t plm_s16;
    plm_b16_t plm_b16;
    plm_w18_t plm_w18;
    plm_b18_t plm_b18;
    plm_s20_t plm_s20;
    plm_b20_t plm_b20;
    plm_w22_t plm_w22;
    plm_b22_t plm_b22;
#endif

    // Read accelerator configuration
#ifndef __SYNTHESIS__
    while (!conf_info.available(1)) {} // Hardware stalls until data ready
#endif

    config = conf_info.read();
    batch = config.batch;
    mode = config.mode;

    ESP_REPORT_INFO(VON, "conf_info.mode = %u (0=full, 1=weights, 2=inference)", ESP_TO_UINT32(mode));
    ESP_REPORT_INFO(VON, "conf_info.batch = %u", ESP_TO_UINT32(batch));
#if 0
    if (mode == W_MODE || mode == F_MODE) {
        read_weights<weight2_t, 8192, 0>(plm_w2, dma_read_ctrl, dma_read_chnl);
        read_weights<bias2_t, 64, 0>(plm_b2, dma_read_ctrl, dma_read_chnl);
        read_weights<batch_normalization_scale_t, 64, 0, 64, HALF>(plm_s4);
        read_weights<batch_normalization_bias_t, 64, 0, 64, HALF>(plm_b4);
        read_weights<weight6_t, 4096, 0, 4096, BYTE>(plm_w6);
        read_weights<bias6_t, 64, 0, 64, BYTE>(plm_b6);
        read_weights<batch_normalization_1_scale_t, 64, 0, 64, HALF>(plm_s8);
        read_weights<batch_normalization_1_bias_t, 64, 0, 64, HALF>(plm_b8);
        read_weights<weight10_t, 512, 0, 512, BYTE>(plm_w10);
        read_weights<bias10_t, 8, 0, 8, BYTE>(plm_b10);
        read_weights<batch_normalization_2_scale_t, 8, 0, 8, HALF>(plm_s12);
        read_weights<batch_normalization_2_bias_t, 8, 0, 8, HALF>(plm_b12);
        read_weights<weight14_t, 512, 0, 512, BYTE>(plm_w14);
        read_weights<bias14_t, 64, 0, 64, BYTE>(plm_b14);
        read_weights<batch_normalization_3_scale_t, 64, 0, 64, HALF>(plm_s16);
        read_weights<batch_normalization_2_bias_t, 64, 0, 64, HALF>(plm_b16);
        read_weights<weight18_t, 4096, 0, 4096, BYTE>(plm_w18);
        read_weights<bias18_t, 64, 0, 64, BYTE>(plm_b18);
        read_weights<batch_normalization_4_scale_t, 64, 0, 64, HALF>(plm_s20);
        read_weights<batch_normalization_5_bias_t, 64, 0, 64, HALF>(plm_b20);
        read_weights<weight22_t, 8192, 0, 8192, BYTE>(plm_w22);
        read_weights<bias22_t, 128, 0, 128, HALF>(plm_b22);
    }
#endif

    if (mode == I_MODE || mode == F_MODE) {
BATCH_LOOP:
        for (uint32_t b = 0; b < BATCH_MAX; b++) {

            if (b >= batch) break;

            // Configure DMA read channel (CTRL)
            // DMA_WIDTH for Ibex is 32 bits
            // AD03 input word is 8 bits
            // Each DMA transaction is 4 input words
            dma_read_data_index = (dma_read_data_length / 4) * b;
            dma_read_info = {dma_read_data_index, (dma_read_data_length / 4), SIZE_BYTE};
            bool dma_read_ctrl_done = false;
LOAD_CTRL_LOOP:
            do { dma_read_ctrl_done = dma_read_ctrl.nb_write(dma_read_info); } while (!dma_read_ctrl_done);

            ESP_REPORT_INFO(VON, "DMA read ctrl: data index = %u, data length = %u, size [0=8b, 1=16b, 2=32b, 3=64b] = %llu", ESP_TO_UINT32(dma_read_info.index), ESP_TO_UINT32(dma_read_info.length), dma_read_info.size.to_uint64());

            if (dma_read_ctrl_done) { // Force serialization between DMA control and DATA data transfer
LOAD_LOOP:
                for (uint16_t i = 0; i < PLM_SIZE; i+=4) {

                    if (i >= dma_read_data_length) break;

                    assert(DMA_WIDTH == 32 && "DMA_WIDTH for Ibex should be 32 bits");

                    ac_int<DMA_WIDTH, false> data_ac;
#ifndef __SYNTHESIS__
                    while (!dma_read_chnl.available(1)) {}; // Hardware stalls until data ready
#endif
                    data_ac = dma_read_chnl.read().template slc<DMA_WIDTH>(0);

                    // DMA word
                    // |<--- 0 --->|<--- 1 --->|<--- 2 --->|<--- 3 --->|
                    //  ...
                    //
                    // PLM (in)
                    // |<--- 0 --->|
                    // |<--- 1 --->|
                    // |<--- 2 --->|
                    // |<--- 3 --->|
                    //  ...
                    FPDATA_IN data_0;
                    FPDATA_IN data_1;
                    FPDATA_IN data_2;
                    FPDATA_IN data_3;
                    data_3.set_slc(0, data_ac.template slc<WL>(WL*0));
                    data_2.set_slc(0, data_ac.template slc<WL>(WL*1));
                    data_1.set_slc(0, data_ac.template slc<WL>(WL*2));
                    data_0.set_slc(0, data_ac.template slc<WL>(WL*3));
                    plm_in.data[i+0] = data_0;
                    plm_in.data[i+1] = data_1;
                    plm_in.data[i+2] = data_2;
                    plm_in.data[i+3] = data_3;

                    ESP_REPORT_INFO(VOFF, "plm_in[%u] = %d", ESP_TO_UINT32(i)+0, (char)data_0.to_int());
                    ESP_REPORT_INFO(VOFF, "plm_in[%u] = %d", ESP_TO_UINT32(i)+1, (char)data_1.to_int());
                    ESP_REPORT_INFO(VOFF, "plm_in[%u] = %d", ESP_TO_UINT32(i)+2, (char)data_2.to_int());
                    ESP_REPORT_INFO(VOFF, "plm_in[%u] = %d", ESP_TO_UINT32(i)+3, (char)data_3.to_int());
                }
            }

            compute_wrapper<plm_in_t, plm_out_t>(plm_in, plm_out);

            // Configure DMA write channel (CTRL)
            // DMA_WIDTH for Ibex is 32 bits
            // AD03 output word is 8 bits
            // Each DMA transaction is 4 output words
            dma_write_data_index = ((dma_read_data_length / 4) * batch) + (dma_write_data_length / 4) * b;
            dma_write_info = {dma_write_data_index, (dma_write_data_length / 4), SIZE_BYTE};
            bool dma_write_ctrl_done = false;
STORE_CTRL_LOOP:
            do { dma_write_ctrl_done = dma_write_ctrl.nb_write(dma_write_info); } while (!dma_write_ctrl_done);

            ESP_REPORT_INFO(VON, "DMA write ctrl: data index = %u, data length = %u, size [0=8b, 1=16b, 2=32b, 3=64b] = %llu", ESP_TO_UINT32(dma_write_info.index), ESP_TO_UINT32(dma_write_info.length), dma_write_info.size.to_uint64());

            if (dma_write_ctrl_done) { // Force serialization between DMA control and DATA data transfer
STORE_LOOP:
                for (uint16_t i = 0; i < PLM_SIZE; i+=4) {

                    if (i >= dma_write_data_length) break;

                    assert(DMA_WIDTH == 32 && "DMA_WIDTH should be 32 bits");

                    // PLM (in)
                    // |<--- 0 --->|
                    // |<--- 1 --->|
                    // |<--- 2 --->|
                    // |<--- 3 --->|
                    //  ...
                    //
                    // DMA word
                    // |<--- 0 --->|<--- 1 --->|<--- 2 --->|<--- 3 --->|
                    //  ...

                    FPDATA_OUT data_0 = plm_out.data[i+0];
                    FPDATA_OUT data_1 = plm_out.data[i+1];
                    FPDATA_OUT data_2 = plm_out.data[i+2];
                    FPDATA_OUT data_3 = plm_out.data[i+3];

                    ac_int<DMA_WIDTH, false> data_ac;
                    data_ac.set_slc(WL*0, data_3.template slc<WL>(0));
                    data_ac.set_slc(WL*1, data_2.template slc<WL>(0));
                    data_ac.set_slc(WL*2, data_1.template slc<WL>(0));
                    data_ac.set_slc(WL*3, data_0.template slc<WL>(0));

                    dma_write_chnl.write(data_ac);

                    ESP_REPORT_INFO(VOFF, "plm_out[%u] = %d", ESP_TO_UINT32(i)+0, (char)data_0.to_int());
                    ESP_REPORT_INFO(VOFF, "plm_out[%u] = %d", ESP_TO_UINT32(i)+1, (char)data_1.to_int());
                    ESP_REPORT_INFO(VOFF, "plm_out[%u] = %d", ESP_TO_UINT32(i)+2, (char)data_2.to_int());
                    ESP_REPORT_INFO(VOFF, "plm_out[%u] = %d", ESP_TO_UINT32(i)+3, (char)data_3.to_int());
                }
            }
        }
    }

    acc_done.sync_out();
}
