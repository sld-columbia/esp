// Copyright (c) 2011-2021 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "esp_headers.hpp"

#include "sha1_cxx_catapult.hpp"
#include "sha1.h"

#include <mc_scverify.h>

// TODO: workaround to make sha1 visible
#include "sha1.cpp"

template <class T1, class T2>
void compute_wrapper(uint32 in_bytes, T1 &input, T2 &output) {
    ESP_REPORT_INFO(VOFF, "in_bytes: %u", ESP_TO_UINT32(in_bytes));

    sha1(in_bytes, input.data, output.data);

    ESP_REPORT_INFO(VOFF, "in  %02X", ESP_TO_UINT32(input.data[0]));
    ESP_REPORT_INFO(VOFF, "in  %02X", ESP_TO_UINT32(input.data[1]));
    ESP_REPORT_INFO(VOFF, "in  %02X", ESP_TO_UINT32(input.data[2]));
    ESP_REPORT_INFO(VOFF, "in  %02X", ESP_TO_UINT32(input.data[3]));

    ESP_REPORT_INFO(VOFF, "out %02X", ESP_TO_UINT32(output.data[0]));
    ESP_REPORT_INFO(VOFF, "out %02X", ESP_TO_UINT32(output.data[1]));
    ESP_REPORT_INFO(VOFF, "out %02X", ESP_TO_UINT32(output.data[2]));
    ESP_REPORT_INFO(VOFF, "out %02X", ESP_TO_UINT32(output.data[3]));
    ESP_REPORT_INFO(VOFF, "out %02X", ESP_TO_UINT32(output.data[4]));
}

#pragma hls_design top
#ifdef __CUSTOM_SIM__
void sha1_cxx_catapult(
#else
void CCS_BLOCK(sha1_cxx_catapult)(
#endif
    //ac_channel<conf_info_t> &conf_info,
    conf_info_t &conf_info,
    ac_channel<dma_info_t> &dma_read_ctrl,
    ac_channel<dma_info_t> &dma_write_ctrl,
    ac_channel<dma_data_t> &dma_read_chnl,
    ac_channel<dma_data_t> &dma_write_chnl,
    ac_sync &acc_done) {

    // Bookkeeping variables
    uint32 dma_read_data_index = 0;
    uint32 dma_read_data_length = 0;
    uint32 dma_write_data_index= 0;
    uint32 dma_write_data_length = PLM_OUT_SIZE;

    // DMA configuration
    dma_info_t dma_read_info = {0, 0, 0, 0};
    dma_info_t dma_write_info = {0, 0, 0, 0};

    // Accelerator configuration
    conf_info_t config;
    uint32 in_bytes = 0;

    // Private Local Memories
    plm_in_t plm_in;
    plm_out_t plm_out;

    // Read accelerator configuration
#ifndef __SYNTHESIS__
    while (!conf_info.available(1)) {} // Hardware stalls until data ready
#endif

    config = conf_info;//conf_info.read();
    in_bytes = config.in_bytes;

    ESP_REPORT_INFO(VOFF, "conf_info.in_bytes = %u", ESP_TO_UINT32(in_bytes));

    // Configure DMA read channel (CTRL)
    // - DMA_WIDTH for EPOCHS is 64 bits
    // - SHA1 input word is 32 bits
    // - Each DMA transaction is 2 input words
    // - Do some math (ceil) to get the number of data and DMA words given in_bytes
    dma_read_data_index = 0;
    dma_read_data_length = (in_bytes + 4 - 1) / 4; // ceil(in_bytes / 4)
    dma_read_info = {dma_read_data_index, (dma_read_data_length + 2 - 1) / 2, SIZE_WORD, 0}; // ceil(dma_read_data_legnth / 2)
    bool dma_read_ctrl_done = false;
LOAD_CTRL_LOOP:
    do { dma_read_ctrl_done = dma_read_ctrl.nb_write(dma_read_info); } while (!dma_read_ctrl_done);

    ESP_REPORT_INFO(VON, "DMA read ctrl: data index = %u, data length = %u, size [0=8b, 1=16b, 2=32b, 3=64b] = %llu", ESP_TO_UINT32(dma_read_info.index), ESP_TO_UINT32(dma_read_info.length), dma_read_info.size.to_uint64());

    if (dma_read_ctrl_done) { // Force serialization between DMA control and DATA data transfer
LOAD_LOOP:
        for (uint16_t i = 0; i < PLM_IN_SIZE; i+=2) {

            if (i >= dma_read_data_length) break;

            assert(DMA_WIDTH == 64 && "DMA_WIDTH should be 64 bits");

            ac_int<DMA_WIDTH, false> data_dma;
#ifndef __SYNTHESIS__
            while (!dma_read_chnl.available(1)) {}; // Hardware stalls until data ready
#endif
            data_dma = dma_read_chnl.read().template slc<DMA_WIDTH>(0);

            // DMA word
            // |<--- 0 --->|<--- 1 --->|
            //  ...
            //
            // PLM (in)
            // |<--- 0 --->|
            // |<--- 1 --->|
            //  ...
            data_t data_0;
            data_t data_1;
            data_0 = data_dma.template slc<WL>(WL*0).to_uint();
            data_1 = data_dma.template slc<WL>(WL*1).to_uint();
            plm_in.data[i+0] = data_0;
            plm_in.data[i+1] = data_1;

            ESP_REPORT_INFO(VOFF, "plm_in[%u] = %02X", ESP_TO_UINT32(i)+0, data_0.to_uint());
            ESP_REPORT_INFO(VOFF, "plm_in[%u] = %02X", ESP_TO_UINT32(i)+1, data_1.to_uint());
        }
    }

    compute_wrapper<plm_in_t, plm_out_t>(in_bytes, plm_in, plm_out);

    // Configure DMA write channel (CTRL)
    // - DMA_WIDTH for EPOCHS is 64 bits
    // - SHA1 output word is 32 bits
    // - Each DMA transaction is 2 output words
    // - There are 3 DMA-word as output (last 32bits are zeros)
    dma_write_data_index = dma_read_data_length;
    dma_write_data_length = PLM_OUT_SIZE;
    dma_write_info = {(dma_write_data_index + 2 - 1) / 2, (dma_write_data_length + 2 - 1) / 2, SIZE_WORD, 0};
    bool dma_write_ctrl_done = false;
STORE_CTRL_LOOP:
    do { dma_write_ctrl_done = dma_write_ctrl.nb_write(dma_write_info); } while (!dma_write_ctrl_done);

    ESP_REPORT_INFO(VON, "DMA write ctrl: data index = %u, data length = %u, size [0=8b, 1=16b, 2=32b, 3=64b] = %llu", ESP_TO_UINT32(dma_write_info.index), ESP_TO_UINT32(dma_write_info.length), dma_write_info.size.to_uint64());

    if (dma_write_ctrl_done) { // Force serialization between DMA control and DATA data transfer
STORE_LOOP:
        for (uint16_t i = 0; i < PLM_OUT_SIZE; i+=2) {

            // TODO: not necessary because PLM_OUT_SIZE == dma_write_data_lenght == 6 == 5 + 1
            //if (i >= dma_write_data_length) break;

            assert(DMA_WIDTH == 64 && "DMA_WIDTH should be 64 bits");
            assert(PLM_OUT_SIZE == 6 && "PLM_OUT_SIZE should be 6 32-bit words (5 + 1 extra dummy word)");

            // PLM (in)
            // |<--- 0 --->|
            // |<--- 1 --->|
            //  ...
            //
            // DMA word
            // |<--- 0 --->|<--- 1 --->|
            //  ...

            // TODO: The PLM now is 6 words
            // Output PLM / results are an even number of words (5)
            // Zeros the 64-bit DMA word when necessary
            ac_int<DMA_WIDTH, false> data_dma = 0;

            data_t data_0(plm_out.data[i+0]);
            data_t data_1(plm_out.data[i+1]);

            data_dma.set_slc(WL*0, data_0.template slc<WL>(0));
            data_dma.set_slc(WL*1, data_1.template slc<WL>(0));

            ESP_REPORT_INFO(VOFF, "plm_out[%u] = %02X", ESP_TO_UINT32(i)+0, data_0.to_uint());
            ESP_REPORT_INFO(VOFF, "plm_out[%u] = %02X", ESP_TO_UINT32(i)+1, data_1.to_uint());

            dma_write_chnl.write(data_dma);
        }
    }

    acc_done.sync_out();
}
