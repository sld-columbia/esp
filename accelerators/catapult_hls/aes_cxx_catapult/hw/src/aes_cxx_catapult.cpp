// Copyright (c) 2011-2021 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "esp_headers.hpp"

#include "aes_cxx_catapult.hpp"
#include "aes.h"

#include <mc_scverify.h>

// TODO: workaround to make aes visible
#include "aes.cpp"

#define ZERO data_t(0)

void compute_wrapper(uint32_t oper_mode, uint32_t encryption, uint32_t key_bytes, uint32_t iv_bytes, uint32_t in_bytes, uint32_t aad_bytes, uint32_t tag_bytes, plm_key_t &key, plm_iv_t &iv, plm_in_t &in, plm_out_t &out, plm_aad_t &aad, plm_tag_t &tag) {
    ESP_REPORT_INFO(VON, "oper_mode: %u", ESP_TO_UINT32(oper_mode));
    ESP_REPORT_INFO(VON, "encryption: %u", ESP_TO_UINT32(encryption));
    ESP_REPORT_INFO(VON, "key_bytes: %u", ESP_TO_UINT32(key_bytes));
    ESP_REPORT_INFO(VON, "in_bytes: %u", ESP_TO_UINT32(in_bytes));
    
    aes(oper_mode, encryption, key_bytes, iv_bytes, in_bytes, aad_bytes, tag_bytes, key.data, iv.data, in.data, out.data, aad.data, tag.data);

    ESP_REPORT_INFO(VOFF, "key[0]  %02X", ESP_TO_UINT32(key.data[0]));
    ESP_REPORT_INFO(VOFF, "key[1]  %02X", ESP_TO_UINT32(key.data[1]));
    ESP_REPORT_INFO(VOFF, "key[2]  %02X", ESP_TO_UINT32(key.data[2]));
    ESP_REPORT_INFO(VOFF, "key[3]  %02X", ESP_TO_UINT32(key.data[3]));
    
    ESP_REPORT_INFO(VOFF, "in[0]  %02X", ESP_TO_UINT32(in.data[0]));
    ESP_REPORT_INFO(VOFF, "in[1]  %02X", ESP_TO_UINT32(in.data[1]));
    ESP_REPORT_INFO(VOFF, "in[2]  %02X", ESP_TO_UINT32(in.data[2]));
    ESP_REPORT_INFO(VOFF, "in[3]  %02X", ESP_TO_UINT32(in.data[3]));
    ESP_REPORT_INFO(VOFF, "in[4]  %02X", ESP_TO_UINT32(in.data[4]));
    ESP_REPORT_INFO(VOFF, "in[5]  %02X", ESP_TO_UINT32(in.data[5]));
    ESP_REPORT_INFO(VOFF, "in[6]  %02X", ESP_TO_UINT32(in.data[6]));
    ESP_REPORT_INFO(VOFF, "in[7]  %02X", ESP_TO_UINT32(in.data[7]));

    ESP_REPORT_INFO(VOFF, "out[0] %02X", ESP_TO_UINT32(out.data[0]));
    ESP_REPORT_INFO(VOFF, "out[1] %02X", ESP_TO_UINT32(out.data[1]));
    ESP_REPORT_INFO(VOFF, "out[2] %02X", ESP_TO_UINT32(out.data[2]));
    ESP_REPORT_INFO(VOFF, "out[3] %02X", ESP_TO_UINT32(out.data[3]));
    ESP_REPORT_INFO(VOFF, "out[4] %02X", ESP_TO_UINT32(out.data[4]));
    ESP_REPORT_INFO(VOFF, "out[5] %02X", ESP_TO_UINT32(out.data[5]));
    ESP_REPORT_INFO(VOFF, "out[6] %02X", ESP_TO_UINT32(out.data[6]));
    ESP_REPORT_INFO(VOFF, "out[7] %02X", ESP_TO_UINT32(out.data[7]));
}

#define ECB_OPERATION_MODE 1
#define CTR_OPERATION_MODE 2
#define CBC_OPERATION_MODE 3
#define GCM_OPERATION_MODE 4

#pragma hls_design top
#ifdef __CUSTOM_SIM__
void aes_cxx_catapult(
#else
void CCS_BLOCK(aes_cxx_catapult)(
#endif
    ac_channel<conf_info_t> &conf_info,
    ac_channel<dma_info_t> &dma_read_ctrl,
    ac_channel<dma_info_t> &dma_write_ctrl,
    ac_channel<dma_data_t> &dma_read_chnl,
    ac_channel<dma_data_t> &dma_write_chnl,
    ac_sync &acc_done) {

    // Bookkeeping variables
    uint32_t dma_read_data_index = 0;
    uint32_t dma_read_data_length = 0;
    uint32_t dma_write_data_index= 0;
    uint32_t dma_write_data_length = 0;
    bool dma_read_ctrl_done = false;
    bool dma_write_ctrl_done = false;

    // DMA configuration
    dma_info_t dma_read_info = {0, 0, 0};
    dma_info_t dma_write_info = {0, 0, 0};

    // Accelerator configuration
    conf_info_t config;
    uint32_t oper_mode = 0;
    uint32_t encryption = 0;
    uint32_t key_bytes = 0;
    uint32_t iv_bytes = 0;
    uint32_t in_bytes = 0;
    uint32_t output_bytes = 0;
    uint32_t aad_bytes = 0;
    uint32_t tag_bytes = 0;

    // Private Local Memories
    plm_key_t plm_key;
    plm_iv_t plm_iv;
    plm_in_t plm_in;
    plm_out_t plm_out;
    plm_aad_t plm_aad;
    plm_tag_t plm_tag;

    // Read accelerator configuration
#ifndef __SYNTHESIS__
    while (!conf_info.available(1)) {} // Hardware stalls until data ready
#endif

    config = conf_info.read();
    oper_mode = config.oper_mode;
    encryption = config.encryption;
    key_bytes = config.key_bytes; 
    in_bytes = config.in_bytes;
    iv_bytes = config.iv_bytes;
    aad_bytes = config.aad_bytes;
    tag_bytes = config.tag_bytes;

    output_bytes = in_bytes;

    ESP_REPORT_INFO(VON, "conf_info.oper_mode = %u", ESP_TO_UINT32(oper_mode));
    ESP_REPORT_INFO(VON, "conf_info.encryption = %u", ESP_TO_UINT32(encryption));
    ESP_REPORT_INFO(VON, "conf_info.key_bytes = %u", ESP_TO_UINT32(key_bytes));
    ESP_REPORT_INFO(VON, "conf_info.iv_bytes = %u", ESP_TO_UINT32(iv_bytes));
    ESP_REPORT_INFO(VON, "conf_info.in_bytes = %u", ESP_TO_UINT32(in_bytes));
    ESP_REPORT_INFO(VON, "conf_info.aad_bytes = %u", ESP_TO_UINT32(aad_bytes));
    ESP_REPORT_INFO(VON, "conf_info.tag_bytes = %u", ESP_TO_UINT32(tag_bytes));

    // Configure DMA read channel (CTRL)
    // - DMA_WIDTH for EPOCHS is 64 bits
    // - AES input word is 32 bits
    // - Each DMA transaction is 2 input words
    // - Do some math (ceil) to get the number of data and DMA words given key_bytes
    dma_read_data_index = 0;
    dma_read_data_length = (key_bytes + 4 - 1) / 4; // ceil(key_bytes / 4)
    dma_read_info = {(dma_read_data_index + 2 - 1) / 2, (dma_read_data_length + 2 - 1) / 2, SIZE_WORD}; // ceil(dma_read_data_legnth / 2)
    dma_read_ctrl_done = false;
LOAD_KEY_CTRL_LOOP:
    do { dma_read_ctrl_done = dma_read_ctrl.nb_write(dma_read_info); } while (!dma_read_ctrl_done);

    ESP_REPORT_INFO(VON, "DMA read ctrl: data index = %u, data length = %u, size [0=8b, 1=16b, 2=32b, 3=64b] = %llu", ESP_TO_UINT32(dma_read_info.index), ESP_TO_UINT32(dma_read_info.length), dma_read_info.size.to_uint64());

    if (dma_read_ctrl_done) { // Force serialization between DMA control and DATA data transfer
LOAD_KEY_LOOP:
        for (uint16_t i = 0; i < PLM_KEY_SIZE; i+=2) {

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
            plm_key.data[i+0] = data_0;
            plm_key.data[i+1] = data_1;

            ESP_REPORT_INFO(VOFF, "plm_in[%u] = %02X", ESP_TO_UINT32(i)+0, data_0.to_uint());
            ESP_REPORT_INFO(VOFF, "plm_in[%u] = %02X", ESP_TO_UINT32(i)+1, data_1.to_uint());
        }
    }


    // Configure DMA read channel (CTRL)
    // - DMA_WIDTH for EPOCHS is 64 bits
    // - AES input word is 32 bits
    // - Each DMA transaction is 2 input words
    // - Do some math (ceil) to get the number of data and DMA words given iv_bytes
    if (oper_mode == CTR_OPERATION_MODE || oper_mode == CBC_OPERATION_MODE) {
	dma_read_data_index = (key_bytes + 4 - 1) / 4;
        dma_read_data_length = (iv_bytes + 4 - 1) / 4; // ceil(iv_bytes / 4)
        dma_read_info = {(dma_read_data_index + 2 - 1) / 2, (dma_read_data_length + 2 - 1) / 2, SIZE_WORD}; // ceil(dma_read_data_legnth / 2)
        dma_read_ctrl_done = false;
LOAD_IV_CTRL_LOOP:
        do { dma_read_ctrl_done = dma_read_ctrl.nb_write(dma_read_info); } while (!dma_read_ctrl_done);

        ESP_REPORT_INFO(VON, "DMA read ctrl: data index = %u, data length = %u, size [0=8b, 1=16b, 2=32b, 3=64b] = %llu", ESP_TO_UINT32(dma_read_info.index), ESP_TO_UINT32(dma_read_info.length), dma_read_info.size.to_uint64());

        if (dma_read_ctrl_done) { // Force serialization between DMA control and DATA data transfer
LOAD_IV_LOOP:
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
                plm_iv.data[i+0] = data_0;
                plm_iv.data[i+1] = data_1;

                ESP_REPORT_INFO(VOFF, "plm_in[%u] = %02X", ESP_TO_UINT32(i)+0, data_0.to_uint());
                ESP_REPORT_INFO(VOFF, "plm_in[%u] = %02X", ESP_TO_UINT32(i)+1, data_1.to_uint());
            }
        }
    }

    // Configure DMA read channel (CTRL)
    // - DMA_WIDTH for EPOCHS is 64 bits
    // - AES input word is 32 bits
    // - Each DMA transaction is 2 input words
    // - Do some math (ceil) to get the number of data and DMA words given key_bytes
    dma_read_data_index = (key_bytes + 4 - 1) / 4 + (iv_bytes + 4 - 1) / 4;
    dma_read_data_length = (in_bytes + 4 - 1) / 4; // ceil(key_bytes / 4)
    dma_read_info = {(dma_read_data_index + 2 - 1) / 2, (dma_read_data_length + 2 - 1) / 2, SIZE_WORD}; // ceil(dma_read_data_legnth / 2)
    dma_read_ctrl_done = false;
LOAD_INPUT_CTRL_LOOP:
    do { dma_read_ctrl_done = dma_read_ctrl.nb_write(dma_read_info); } while (!dma_read_ctrl_done);

    ESP_REPORT_INFO(VON, "DMA read ctrl: data index = %u, data length = %u, size [0=8b, 1=16b, 2=32b, 3=64b] = %llu", ESP_TO_UINT32(dma_read_info.index), ESP_TO_UINT32(dma_read_info.length), dma_read_info.size.to_uint64());

    if (dma_read_ctrl_done) { // Force serialization between DMA control and DATA data transfer
LOAD_INPUT_LOOP:
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

    compute_wrapper(oper_mode, encryption, key_bytes, iv_bytes, in_bytes, aad_bytes, tag_bytes, plm_key, plm_iv, plm_in, plm_out, plm_aad, plm_tag);

    // Configure DMA write channel (CTRL)
    // - DMA_WIDTH for EPOCHS is 64 bits
    // - AES output word is 32 bits
    // - Each DMA transaction is 2 output words
    // - Do some math (ceil) to get the number of data and DMA words given out_bytes
    dma_write_data_index = (key_bytes + 4 - 1) / 4 + (iv_bytes + 4 - 1) / 4 + (in_bytes + 4 - 1) / 4;
    dma_write_data_length = (output_bytes + 4 - 1) / 4; // ceil(out_bytes / 4)
    dma_write_info = {(dma_write_data_index + 2 - 1) / 2, (dma_write_data_length + 2 - 1) / 2, SIZE_WORD};
    dma_write_ctrl_done = false;
STORE_CTRL_LOOP:
    do { dma_write_ctrl_done = dma_write_ctrl.nb_write(dma_write_info); } while (!dma_write_ctrl_done);

    ESP_REPORT_INFO(VON, "DMA write ctrl: data index = %u, data length = %u, size [0=8b, 1=16b, 2=32b, 3=64b] = %llu", ESP_TO_UINT32(dma_write_info.index), ESP_TO_UINT32(dma_write_info.length), dma_write_info.size.to_uint64());

    if (dma_write_ctrl_done) { // Force serialization between DMA control and DATA data transfer
STORE_LOOP:
        for (uint16_t i = 0; i < PLM_OUT_SIZE; i+=2) {

            if (i >= dma_write_data_length) break;

            assert(DMA_WIDTH == 64 && "DMA_WIDTH should be 64 bits");

            // PLM (in)
            // |<--- 0 --->|
            // |<--- 1 --->|
            //  ...
            //
            // DMA word
            // |<--- 0 --->|<--- 1 --->|
            //  ...

            ac_int<DMA_WIDTH, false> data_dma = 0;

            data_t data_0(plm_out.data[i+0]);
            //data_t data_1((i+1 >= dma_write_data_length)?ZERO:plm_out.data[i+1]);
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
