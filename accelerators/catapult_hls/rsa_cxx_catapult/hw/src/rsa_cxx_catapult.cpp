// Copyright (c) 2011-2021 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "esp_headers.hpp"

#include "rsa_cxx_catapult.hpp"
#include "rsa.h"

#include <mc_scverify.h>

// TODO: workaround to make rsa visible
//#include "rsa.cpp"

#define ZERO data_t(0)

void compute_wrapper(uint32 encryption, uint32 padding, uint32 pubpriv, uint32 n_bytes, uint32 e_bytes, uint32 in_bytes, plm_r_t &r, plm_n_t &n, plm_e_t &e, plm_in_t &in, plm_out_t &out) {
    //ESP_REPORT_INFO(VON, "encryption: %u", ESP_TO_UINT32(encryption));
    //ESP_REPORT_INFO(VON, "padding: %u", ESP_TO_UINT32(padding));
    //ESP_REPORT_INFO(VON, "pubpriv: %u", ESP_TO_UINT32(pubpriv));
    //ESP_REPORT_INFO(VON, "n_bytes: %u", ESP_TO_UINT32(n_bytes));
    //ESP_REPORT_INFO(VON, "e_bytes: %u", ESP_TO_UINT32(e_bytes));
    //ESP_REPORT_INFO(VON, "in_bytes: %u", ESP_TO_UINT32(in_bytes));

    rsa(encryption, padding, pubpriv, n_bytes, e_bytes, in_bytes, r.data, n.data, e.data, in.data, out.data);
}

#pragma hls_design top
#ifdef __CUSTOM_SIM__
void rsa_cxx_catapult(
#else
void CCS_BLOCK(rsa_cxx_catapult)(
#endif
    ac_channel<conf_info_t> &conf_info,
    ac_channel<dma_info_t> &dma_read_ctrl,
    ac_channel<dma_info_t> &dma_write_ctrl,
    ac_channel<dma_data_t> &dma_read_chnl,
    ac_channel<dma_data_t> &dma_write_chnl,
    ac_sync &acc_done) {

    // Bookkeeping variables
    uint32 dma_read_data_index = 0;
    uint32 dma_read_data_length = 0;
    uint32 dma_write_data_index= 0;
    uint32 dma_write_data_length = 0;
    bool dma_read_ctrl_done = false;
    bool dma_write_ctrl_done = false;

    // DMA configuration
    dma_info_t dma_read_info = {0, 0, 0};
    dma_info_t dma_write_info = {0, 0, 0};

    // Accelerator configuration
    conf_info_t config;
    uint32 in_bytes = 0;
    uint32 e_bytes = 0;
    uint32 n_bytes = 0;
    uint32 pubpriv = 0;
    uint32 padding = 0;
    uint32 encryption = 0;

    uint32 out_bytes = 0;

    // Private Local Memories
    plm_in_t plm_in;
    plm_e_t plm_e;
    plm_n_t plm_n;
    plm_r_t plm_r;
    plm_out_t plm_out;

    // Read accelerator configuration
#ifndef __SYNTHESIS__
    while (!conf_info.available(1)) {} // Hardware stalls until data ready
#endif

    config = conf_info.read();
    in_bytes = config.in_bytes;
    e_bytes = config.e_bytes;
    n_bytes = config.n_bytes;
    pubpriv = config.pubpriv;
    padding = config.padding;
    encryption = config.encryption;

    out_bytes = n_bytes;

    ESP_REPORT_INFO(VOFF, "conf_info.in_bytes = %u", ESP_TO_UINT32(in_bytes));
    ESP_REPORT_INFO(VOFF, "conf_info.e_bytes = %u", ESP_TO_UINT32(e_bytes));
    ESP_REPORT_INFO(VOFF, "conf_info.n_bytes = %u", ESP_TO_UINT32(n_bytes));
    ESP_REPORT_INFO(VOFF, "conf_info.pubpriv = %u", ESP_TO_UINT32(pubpriv));
    ESP_REPORT_INFO(VOFF, "conf_info.padding = %u", ESP_TO_UINT32(padding));
    ESP_REPORT_INFO(VOFF, "conf_info.encryption = %u", ESP_TO_UINT32(encryption));

    // Configure DMA read channel (CTRL)
    // - DMA_WIDTH for EPOCHS is 64 bits
    // - AES input word is 32 bits
    // - Each DMA transaction is 2 input words
    // - Do some math (ceil) to get the number of data and DMA words given in_bytes
    dma_read_data_index = 0;
    dma_read_data_length = (in_bytes + 4 - 1) / 4; // ceil(in_bytes / 4)
    dma_read_info = {(dma_read_data_index + 2 - 1) / 2, (dma_read_data_length + 2 - 1) / 2, SIZE_WORD}; // ceil(dma_read_data_legnth / 2)
    dma_read_ctrl_done = false;
LOAD_IN_CTRL_LOOP:
    do { dma_read_ctrl_done = dma_read_ctrl.nb_write(dma_read_info); } while (!dma_read_ctrl_done);

    ESP_REPORT_INFO(VOFF, "DMA read ctrl: data index = %u, data length = %u, size [0=8b, 1=16b, 2=32b, 3=64b] = %llu", ESP_TO_UINT32(dma_read_info.index), ESP_TO_UINT32(dma_read_info.length), dma_read_info.size.to_uint64());

    if (dma_read_ctrl_done) { // Force serialization between DMA control and DATA data transfer
LOAD_IN_LOOP:
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

    // Configure DMA read channel (CTRL)
    // - DMA_WIDTH for EPOCHS is 64 bits
    // - AES input word is 32 bits
    // - Each DMA transaction is 2 input words
    // - Do some math (ceil) to get the number of data and DMA words given e_bytes
    dma_read_data_index = (in_bytes + 4 - 1) / 4;
    dma_read_data_length = (e_bytes + 4 - 1) / 4; // ceil(e_bytes / 4)
    dma_read_info = {(dma_read_data_index + 2 - 1) / 2, (dma_read_data_length + 2 - 1) / 2, SIZE_WORD}; // ceil(dma_read_data_legnth / 2)
    dma_read_ctrl_done = false;
LOAD_E_CTRL_LOOP:
    do { dma_read_ctrl_done = dma_read_ctrl.nb_write(dma_read_info); } while (!dma_read_ctrl_done);

    ESP_REPORT_INFO(VOFF, "DMA read ctrl: data index = %u, data length = %u, size [0=8b, 1=16b, 2=32b, 3=64b] = %llu", ESP_TO_UINT32(dma_read_info.index), ESP_TO_UINT32(dma_read_info.length), dma_read_info.size.to_uint64());

    if (dma_read_ctrl_done) { // Force serialization between DMA control and DATA data transfer
LOAD_E_LOOP:
        for (uint16_t i = 0; i < PLM_E_SIZE; i+=2) {

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
            plm_e.data[i+0] = data_0;
            plm_e.data[i+1] = data_1;

            ESP_REPORT_INFO(VOFF, "plm_e[%u] = %02X", ESP_TO_UINT32(i)+0, data_0.to_uint());
            ESP_REPORT_INFO(VOFF, "plm_e[%u] = %02X", ESP_TO_UINT32(i)+1, data_1.to_uint());
        }
    }

    // Configure DMA read channel (CTRL)
    // - DMA_WIDTH for EPOCHS is 64 bits
    // - AES input word is 32 bits
    // - Each DMA transaction is 2 input words
    // - Do some math (ceil) to get the number of data and DMA words given n_bytes
    dma_read_data_index = (in_bytes + 4 - 1) / 4 + (e_bytes + 4 - 1) / 4;
    dma_read_data_length = (n_bytes + 4 - 1) / 4; // ceil(n_bytes / 4)
    dma_read_info = {(dma_read_data_index + 2 - 1) / 2, (dma_read_data_length + 2 - 1) / 2, SIZE_WORD}; // ceil(dma_read_data_legnth / 2)
    dma_read_ctrl_done = false;
LOAD_N_CTRL_LOOP:
    do { dma_read_ctrl_done = dma_read_ctrl.nb_write(dma_read_info); } while (!dma_read_ctrl_done);

    ESP_REPORT_INFO(VOFF, "DMA read ctrl: data index = %u, data length = %u, size [0=8b, 1=16b, 2=32b, 3=64b] = %llu", ESP_TO_UINT32(dma_read_info.index), ESP_TO_UINT32(dma_read_info.length), dma_read_info.size.to_uint64());

    if (dma_read_ctrl_done) { // Force serialization between DMA control and DATA data transfer
LOAD_N_LOOP:
        for (uint16_t i = 0; i < PLM_N_SIZE; i+=2) {

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
            plm_n.data[i+0] = data_0;
            plm_n.data[i+1] = data_1;

            ESP_REPORT_INFO(VOFF, "plm_n[%u] = %02X", ESP_TO_UINT32(i)+0, data_0.to_uint());
            ESP_REPORT_INFO(VOFF, "plm_n[%u] = %02X", ESP_TO_UINT32(i)+1, data_1.to_uint());
        }
    }

    // Configure DMA read channel (CTRL)
    // - DMA_WIDTH for EPOCHS is 64 bits
    // - AES input word is 32 bits
    // - Each DMA transaction is 2 input words
    // - Do some math (ceil) to get the number of data and DMA words given r_bytes
    dma_read_data_index = (in_bytes + 4 - 1) / 4 + (e_bytes + 4 - 1) / 4 + (n_bytes + 4 - 1) / 4;
    dma_read_data_length = (n_bytes + 4 - 1) / 4; // ceil(r_bytes / 4)
    dma_read_info = {(dma_read_data_index + 2 - 1) / 2, (dma_read_data_length + 2 - 1) / 2, SIZE_WORD}; // ceil(dma_read_data_legnth / 2)
    dma_read_ctrl_done = false;
LOAD_R_CTRL_LOOP:
    do { dma_read_ctrl_done = dma_read_ctrl.nb_write(dma_read_info); } while (!dma_read_ctrl_done);

    ESP_REPORT_INFO(VOFF, "DMA read ctrl: data index = %u, data length = %u, size [0=8b, 1=16b, 2=32b, 3=64b] = %llu", ESP_TO_UINT32(dma_read_info.index), ESP_TO_UINT32(dma_read_info.length), dma_read_info.size.to_uint64());

    if (dma_read_ctrl_done) { // Force serialization between DMA control and DATA data transfer
LOAD_R_LOOP:
        for (uint16_t i = 0; i < PLM_R_SIZE; i+=2) {

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
            plm_r.data[i+0] = data_0;
            plm_r.data[i+1] = data_1;

            ESP_REPORT_INFO(VOFF, "plm_r[%u] = %08X", ESP_TO_UINT32(i)+0, data_0.to_uint());
            ESP_REPORT_INFO(VOFF, "plm_r[%u] = %08X", ESP_TO_UINT32(i)+1, data_1.to_uint());
        }
    }

    compute_wrapper(encryption, padding, pubpriv, n_bytes, e_bytes, in_bytes, plm_r, plm_n, plm_e, plm_in, plm_out);

    // Configure DMA write channel (CTRL)
    // - DMA_WIDTH for EPOCHS is 64 bits
    // - AES output word is 32 bits
    // - Each DMA transaction is 2 output words
    // - Do some math (ceil) to get the number of data and DMA words given out_bytes
    dma_write_data_index = (in_bytes + 4 - 1) / 4 + (e_bytes + 4 - 1) / 4 + (n_bytes + 4 - 1) / 4 + (n_bytes + 4 - 1) / 4;
    dma_write_data_length = (out_bytes + 4 - 1) / 4; // ceil(out_bytes / 4)
    dma_write_info = {(dma_write_data_index + 2 - 1) / 2, (dma_write_data_length + 2 - 1) / 2, SIZE_WORD};
    dma_write_ctrl_done = false;
STORE_CTRL_LOOP:
    do { dma_write_ctrl_done = dma_write_ctrl.nb_write(dma_write_info); } while (!dma_write_ctrl_done);

    ESP_REPORT_INFO(VOFF, "DMA write ctrl: data index = %u, data length = %u, size [0=8b, 1=16b, 2=32b, 3=64b] = %llu", ESP_TO_UINT32(dma_write_info.index), ESP_TO_UINT32(dma_write_info.length), dma_write_info.size.to_uint64());

    if (dma_write_ctrl_done) { // Force serialization between DMA control and DATA data transfer
STORE_LOOP:
        for (uint16_t i = 0; i < PLM_OUT_SIZE; i+=2) {

            if (i >= dma_write_data_length) break;

            assert(DMA_WIDTH == 64 && "DMA_WIDTH should be 64 bits");

            // PLM (out)
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
