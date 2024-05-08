// Copyright (c) 2011-2021 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "esp_headers.hpp"

#include "aes.h"
#include "crypto_cxx_catapult.hpp"
#include "sha1.h"
#include "sha2.h"

#include <mc_scverify.h>

// TODO: workaround to make sha1, sha2, aes visible
//#include "sha1.cpp"
//#include "sha2.cpp"
//#include "aes.cpp"

#define ZERO data_t(0)

template <class T1, class T2> void sha1_compute_wrapper(uint32 in_bytes, T1 &input, T2 &output)
{
    ESP_REPORT_INFO(VOFF, "sha1_in_bytes: %u", ESP_TO_UINT32(in_bytes));

    sha1(in_bytes, input.data, output.data);
}

template <class T1, class T2>
void sha2_compute_wrapper(uint32 in_bytes, uint32 out_bytes, T1 &input, T2 &output)
{
    ESP_REPORT_INFO(VOFF, "sha2_in_bytes: %u", ESP_TO_UINT32(in_bytes));
    ESP_REPORT_INFO(VOFF, "sha2_out_bytes: %u", ESP_TO_UINT32(out_bytes));

    sha2(in_bytes, out_bytes, input.data, output.data);
}

void aes_compute_wrapper(uint32 oper_mode, uint32 encryption, uint32 key_bytes, uint32 iv_bytes,
                         uint32 in_bytes, uint32 aad_bytes, uint32 tag_bytes, aes_plm_key_t &key,
                         aes_plm_iv_t &iv, aes_plm_in_t &in, aes_plm_out_t &out, aes_plm_aad_t &aad,
                         aes_plm_tag_t &tag)
{
    ESP_REPORT_INFO(VON, "aes_oper_mode: %u", ESP_TO_UINT32(oper_mode));
    ESP_REPORT_INFO(VON, "aes_encryption: %u", ESP_TO_UINT32(encryption));
    ESP_REPORT_INFO(VON, "aes_key_bytes: %u", ESP_TO_UINT32(key_bytes));
    ESP_REPORT_INFO(VON, "aes_in_bytes: %u", ESP_TO_UINT32(in_bytes));

    aes(oper_mode, encryption, key_bytes, iv_bytes, in_bytes, aad_bytes, tag_bytes, key.data,
        iv.data, in.data, out.data, aad.data, tag.data);
}

#define CRYPTO_SHA1_MODE 1
#define CRYPTO_SHA2_MODE 2
#define CRYPTO_AES_MODE  3

#define AES_ECB_OPERATION_MODE 1
#define AES_CTR_OPERATION_MODE 2
#define AES_CBC_OPERATION_MODE 3
#define AES_GCM_OPERATION_MODE 4

#pragma hls_design top
#ifdef __CUSTOM_SIM__
void crypto_cxx_catapult(
#else
void CCS_BLOCK(crypto_cxx_catapult)(
#endif
    ac_channel<conf_info_t> &conf_info, ac_channel<dma_info_t> &dma_read_ctrl,
    ac_channel<dma_info_t> &dma_write_ctrl, ac_channel<dma_data_t> &dma_read_chnl,
    ac_channel<dma_data_t> &dma_write_chnl, ac_sync &acc_done)
{

    // Bookkeeping variables
    uint32 dma_read_data_index   = 0;
    uint32 dma_read_data_length  = 0;
    uint32 dma_write_data_index  = 0;
    uint32 dma_write_data_length = SHA1_PLM_OUT_SIZE;

    // DMA configuration
    dma_info_t dma_read_info  = {0, 0, 0};
    dma_info_t dma_write_info = {0, 0, 0};

    // Accelerator configuration
    conf_info_t config;
    uint32 crypto_algo      = 0;
    uint32 sha1_in_bytes    = 0;
    uint32 sha2_in_bytes    = 0;
    uint32 sha2_out_bytes   = 0;
    uint32 aes_oper_mode    = 0;
    uint32 aes_encryption   = 0;
    uint32 aes_key_bytes    = 0;
    uint32 aes_iv_bytes     = 0;
    uint32 aes_in_bytes     = 0;
    uint32 aes_output_bytes = 0;
    uint32 aes_aad_bytes    = 0;
    uint32 aes_tag_bytes    = 0;

    // Private Local Memories
    sha1_plm_in_t sha1_plm_in;
    sha1_plm_out_t sha1_plm_out;
    sha2_plm_in_t sha2_plm_in;
    sha2_plm_out_t sha2_plm_out;
    aes_plm_key_t aes_plm_key;
    aes_plm_iv_t aes_plm_iv;
    aes_plm_in_t aes_plm_in;
    aes_plm_out_t aes_plm_out;
    aes_plm_aad_t aes_plm_aad;
    aes_plm_tag_t aes_plm_tag;

    // Read accelerator configuration
#ifndef __SYNTHESIS__
    while (!conf_info.available(1)) {} // Hardware stalls until data ready
#endif

    config      = conf_info.read();
    crypto_algo = config.crypto_algo;

    if (crypto_algo == CRYPTO_SHA1_MODE) {

        sha1_in_bytes = config.sha1_in_bytes;

        ESP_REPORT_INFO(VOFF, "conf_info.sha1_in_bytes = %u", ESP_TO_UINT32(sha1_in_bytes));

        // Configure DMA read channel (CTRL)
        // - DMA_WIDTH for EPOCHS is 64 bits
        // - SHA1 input word is 32 bits
        // - Each DMA transaction is 2 input words
        // - Do some math (ceil) to get the number of data and DMA words given in_bytes
        dma_read_data_index     = 0;
        dma_read_data_length    = (sha1_in_bytes + 4 - 1) / 4; // ceil(in_bytes / 4)
        dma_read_info           = {dma_read_data_index, (dma_read_data_length + 2 - 1) / 2,
                         SIZE_WORD}; // ceil(dma_read_data_legnth / 2)
        bool dma_read_ctrl_done = false;
SHA1_LOAD_CTRL_LOOP:
        do {
            dma_read_ctrl_done = dma_read_ctrl.nb_write(dma_read_info);
        } while (!dma_read_ctrl_done);

        ESP_REPORT_INFO(VON,
                        "DMA read ctrl: data index = %u, data length = %u, size [0=8b, 1=16b, "
                        "2=32b, 3=64b] = %llu",
                        ESP_TO_UINT32(dma_read_info.index), ESP_TO_UINT32(dma_read_info.length),
                        dma_read_info.size.to_uint64());

        if (dma_read_ctrl_done) { // Force serialization between DMA control and DATA data transfer
SHA1_LOAD_LOOP:
            for (uint16_t i = 0; i < SHA1_PLM_IN_SIZE; i += 2) {

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
                data_0                  = data_dma.template slc<WL>(WL * 0).to_uint();
                data_1                  = data_dma.template slc<WL>(WL * 1).to_uint();
                sha1_plm_in.data[i + 0] = data_0;
                sha1_plm_in.data[i + 1] = data_1;

                ESP_REPORT_INFO(VOFF, "sha1_plm_in[%u] = %02X", ESP_TO_UINT32(i) + 0,
                                data_0.to_uint());
                ESP_REPORT_INFO(VOFF, "sha1_plm_in[%u] = %02X", ESP_TO_UINT32(i) + 1,
                                data_1.to_uint());
            }
        }

        sha1_compute_wrapper<sha1_plm_in_t, sha1_plm_out_t>(sha1_in_bytes, sha1_plm_in,
                                                            sha1_plm_out);

        // Configure DMA write channel (CTRL)
        // - DMA_WIDTH for EPOCHS is 64 bits
        // - SHA1 output word is 32 bits
        // - Each DMA transaction is 2 output words
        // - There are 3 DMA-word as output (last 32bits are zeros)
        dma_write_data_index  = dma_read_data_length;
        dma_write_data_length = SHA1_PLM_OUT_SIZE;
        dma_write_info = {(dma_write_data_index + 2 - 1) / 2, (dma_write_data_length + 2 - 1) / 2,
                          SIZE_WORD};
        bool dma_write_ctrl_done = false;
SHA1_STORE_CTRL_LOOP:
        do {
            dma_write_ctrl_done = dma_write_ctrl.nb_write(dma_write_info);
        } while (!dma_write_ctrl_done);

        ESP_REPORT_INFO(VON,
                        "DMA write ctrl: data index = %u, data length = %u, size [0=8b, 1=16b, "
                        "2=32b, 3=64b] = %llu",
                        ESP_TO_UINT32(dma_write_info.index), ESP_TO_UINT32(dma_write_info.length),
                        dma_write_info.size.to_uint64());

        if (dma_write_ctrl_done) { // Force serialization between DMA control and DATA data transfer
SHA1_STORE_LOOP:
            for (uint16_t i = 0; i < SHA1_PLM_OUT_SIZE; i += 2) {

                // TODO: not necessary because PLM_OUT_SIZE == dma_write_data_lenght == 6 == 5 + 1
                // if (i >= dma_write_data_length) break;

                assert(DMA_WIDTH == 64 && "DMA_WIDTH should be 64 bits");
                assert(SHA1_PLM_OUT_SIZE == 6 &&
                       "PLM_OUT_SIZE should be 6 32-bit words (5 + 1 extra dummy word)");

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

                data_t data_0(sha1_plm_out.data[i + 0]);
                data_t data_1(sha1_plm_out.data[i + 1]);

                data_dma.set_slc(WL * 0, data_0.template slc<WL>(0));
                data_dma.set_slc(WL * 1, data_1.template slc<WL>(0));

                ESP_REPORT_INFO(VOFF, "sha1_plm_in[%u] = %02X", ESP_TO_UINT32(i) + 0,
                                data_0.to_uint());
                ESP_REPORT_INFO(VOFF, "sha1_plm_in[%u] = %02X", ESP_TO_UINT32(i) + 1,
                                data_1.to_uint());

                dma_write_chnl.write(data_dma);
            }
        }
    }
    else if (crypto_algo == CRYPTO_SHA2_MODE) {

        sha2_in_bytes  = config.sha2_in_bytes;
        sha2_out_bytes = config.sha2_out_bytes;

        ESP_REPORT_INFO(VOFF, "conf_info.sha2_in_bytes = %u", ESP_TO_UINT32(sha2_in_bytes));
        ESP_REPORT_INFO(VOFF, "conf_info.sha2_out_bytes = %u", ESP_TO_UINT32(sha2_out_bytes));

        // Configure DMA read channel (CTRL)
        // - DMA_WIDTH for EPOCHS is 64 bits
        // - SHA2 input word is 32 bits
        // - Each DMA transaction is 2 input words
        // - Do some math (ceil) to get the number of data and DMA words given in_bytes
        dma_read_data_index     = 0;
        dma_read_data_length    = (sha2_in_bytes + 4 - 1) / 4; // ceil(in_bytes / 4)
        dma_read_info           = {dma_read_data_index, (dma_read_data_length + 2 - 1) / 2,
                         SIZE_WORD}; // ceil(dma_read_data_legnth / 2)
        bool dma_read_ctrl_done = false;
SHA2_LOAD_CTRL_LOOP:
        do {
            dma_read_ctrl_done = dma_read_ctrl.nb_write(dma_read_info);
        } while (!dma_read_ctrl_done);

        ESP_REPORT_INFO(VON,
                        "DMA read ctrl: data index = %u, data length = %u, size [0=8b, 1=16b, "
                        "2=32b, 3=64b] = %llu",
                        ESP_TO_UINT32(dma_read_info.index), ESP_TO_UINT32(dma_read_info.length),
                        dma_read_info.size.to_uint64());

        if (dma_read_ctrl_done) { // Force serialization between DMA control and DATA data transfer
SHA2_LOAD_LOOP:
            for (uint16_t i = 0; i < SHA2_PLM_IN_SIZE; i += 2) {

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
                data_0                  = data_dma.template slc<WL>(WL * 0).to_uint();
                data_1                  = data_dma.template slc<WL>(WL * 1).to_uint();
                sha2_plm_in.data[i + 0] = data_0;
                sha2_plm_in.data[i + 1] = data_1;

                ESP_REPORT_INFO(VOFF, "sha2_plm_in[%u] = %02X", ESP_TO_UINT32(i) + 0,
                                data_0.to_uint());
                ESP_REPORT_INFO(VOFF, "sha2_plm_in[%u] = %02X", ESP_TO_UINT32(i) + 1,
                                data_1.to_uint());
            }
        }

        sha2_compute_wrapper<sha2_plm_in_t, sha2_plm_out_t>(sha2_in_bytes, sha2_out_bytes,
                                                            sha2_plm_in, sha2_plm_out);

        // Configure DMA write channel (CTRL)
        // - DMA_WIDTH for EPOCHS is 64 bits
        // - SHA2 output word is 32 bits
        // - Each DMA transaction is 2 output words
        // - Do some math (ceil) to get the number of data and DMA words given out_bytes
        dma_write_data_index  = dma_read_data_length;
        dma_write_data_length = (sha2_out_bytes + 4 - 1) / 4; // ceil(out_bytes / 4)
        dma_write_info = {(dma_write_data_index + 2 - 1) / 2, (dma_write_data_length + 2 - 1) / 2,
                          SIZE_WORD};
        bool dma_write_ctrl_done = false;
SHA2_STORE_CTRL_LOOP:
        do {
            dma_write_ctrl_done = dma_write_ctrl.nb_write(dma_write_info);
        } while (!dma_write_ctrl_done);

        ESP_REPORT_INFO(VON,
                        "DMA write ctrl: data index = %u, data length = %u, size [0=8b, 1=16b, "
                        "2=32b, 3=64b] = %llu",
                        ESP_TO_UINT32(dma_write_info.index), ESP_TO_UINT32(dma_write_info.length),
                        dma_write_info.size.to_uint64());

        if (dma_write_ctrl_done) { // Force serialization between DMA control and DATA data transfer
SHA2_STORE_LOOP:
            for (uint16_t i = 0; i < SHA2_PLM_OUT_SIZE; i += 2) {

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

                data_t data_0(sha2_plm_out.data[i + 0]);
                data_t data_1((i + 1 >= dma_write_data_length) ? ZERO : sha2_plm_out.data[i + 1]);

                data_dma.set_slc(WL * 0, data_0.template slc<WL>(0));
                data_dma.set_slc(WL * 1, data_1.template slc<WL>(0));

                ESP_REPORT_INFO(VOFF, "sha2_plm_out[%u] = %02X", ESP_TO_UINT32(i) + 0,
                                data_0.to_uint());
                ESP_REPORT_INFO(VOFF, "sha2_plm_out[%u] = %02X", ESP_TO_UINT32(i) + 1,
                                data_1.to_uint());

                dma_write_chnl.write(data_dma);
            }
        }
    }
    else if (crypto_algo == CRYPTO_AES_MODE) {

        aes_oper_mode  = config.aes_oper_mode;
        aes_encryption = config.encryption;
        aes_key_bytes  = config.aes_key_bytes;
        aes_in_bytes   = config.aes_in_bytes;
        aes_iv_bytes   = config.aes_iv_bytes;
        aes_aad_bytes  = config.aes_aad_bytes;
        aes_tag_bytes  = config.aes_tag_bytes;

        aes_output_bytes = aes_in_bytes;

        ESP_REPORT_INFO(VON, "conf_info.aes_oper_mode = %u", ESP_TO_UINT32(aes_oper_mode));
        ESP_REPORT_INFO(VON, "conf_info.aes_encryption = %u", ESP_TO_UINT32(aes_encryption));
        ESP_REPORT_INFO(VON, "conf_info.aes_key_bytes = %u", ESP_TO_UINT32(aes_key_bytes));
        ESP_REPORT_INFO(VON, "conf_info.aes_iv_bytes = %u", ESP_TO_UINT32(aes_iv_bytes));
        ESP_REPORT_INFO(VON, "conf_info.aes_in_bytes = %u", ESP_TO_UINT32(aes_in_bytes));
        ESP_REPORT_INFO(VON, "conf_info.aes_aad_bytes = %u", ESP_TO_UINT32(aes_aad_bytes));
        ESP_REPORT_INFO(VON, "conf_info.aes_tag_bytes = %u", ESP_TO_UINT32(aes_tag_bytes));

        // Configure DMA read channel (CTRL)
        // - DMA_WIDTH for EPOCHS is 64 bits
        // - AES input word is 32 bits
        // - Each DMA transaction is 2 input words
        // - Do some math (ceil) to get the number of data and DMA words given key_bytes
        dma_read_data_index  = 0;
        dma_read_data_length = (aes_key_bytes + 4 - 1) / 4; // ceil(aes_key_bytes / 4)
        dma_read_info = {(dma_read_data_index + 2 - 1) / 2, (dma_read_data_length + 2 - 1) / 2,
                         SIZE_WORD}; // ceil(dma_read_data_legnth / 2)
        bool dma_read_ctrl_done = false;
AES_LOAD_KEY_CTRL_LOOP:
        do {
            dma_read_ctrl_done = dma_read_ctrl.nb_write(dma_read_info);
        } while (!dma_read_ctrl_done);

        ESP_REPORT_INFO(VON,
                        "DMA read ctrl: data index = %u, data length = %u, size [0=8b, 1=16b, "
                        "2=32b, 3=64b] = %llu",
                        ESP_TO_UINT32(dma_read_info.index), ESP_TO_UINT32(dma_read_info.length),
                        dma_read_info.size.to_uint64());

        if (dma_read_ctrl_done) { // Force serialization between DMA control and DATA data transfer
AES_LOAD_KEY_LOOP:
            for (uint16_t i = 0; i < AES_PLM_KEY_SIZE; i += 2) {

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
                data_0                  = data_dma.template slc<WL>(WL * 0).to_uint();
                data_1                  = data_dma.template slc<WL>(WL * 1).to_uint();
                aes_plm_key.data[i + 0] = data_0;
                aes_plm_key.data[i + 1] = data_1;

                ESP_REPORT_INFO(VOFF, "aes_plm_in[%u] = %02X", ESP_TO_UINT32(i) + 0,
                                data_0.to_uint());
                ESP_REPORT_INFO(VOFF, "aes_plm_in[%u] = %02X", ESP_TO_UINT32(i) + 1,
                                data_1.to_uint());
            }
        }

        // Configure DMA read channel (CTRL)
        // - DMA_WIDTH for EPOCHS is 64 bits
        // - AES input word is 32 bits
        // - Each DMA transaction is 2 input words
        // - Do some math (ceil) to get the number of data and DMA words given iv_bytes
        if (aes_oper_mode == AES_CTR_OPERATION_MODE || aes_oper_mode == AES_CBC_OPERATION_MODE) {
            dma_read_data_index  = (aes_key_bytes + 4 - 1) / 4;
            dma_read_data_length = (aes_iv_bytes + 4 - 1) / 4; // ceil(aes_iv_bytes / 4)
            dma_read_info = {(dma_read_data_index + 2 - 1) / 2, (dma_read_data_length + 2 - 1) / 2,
                             SIZE_WORD}; // ceil(dma_read_data_legnth / 2)
            bool dma_read_ctrl_done = false;
AES_LOAD_IV_CTRL_LOOP:
            do {
                dma_read_ctrl_done = dma_read_ctrl.nb_write(dma_read_info);
            } while (!dma_read_ctrl_done);

            ESP_REPORT_INFO(VON,
                            "DMA read ctrl: data index = %u, data length = %u, size [0=8b, 1=16b, "
                            "2=32b, 3=64b] = %llu",
                            ESP_TO_UINT32(dma_read_info.index), ESP_TO_UINT32(dma_read_info.length),
                            dma_read_info.size.to_uint64());

            if (dma_read_ctrl_done) { // Force serialization between DMA control and DATA data
                                      // transfer
AES_LOAD_IV_LOOP:
                for (uint16_t i = 0; i < AES_PLM_IV_SIZE; i += 2) {

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
                    data_0                 = data_dma.template slc<WL>(WL * 0).to_uint();
                    data_1                 = data_dma.template slc<WL>(WL * 1).to_uint();
                    aes_plm_iv.data[i + 0] = data_0;
                    aes_plm_iv.data[i + 1] = data_1;

                    ESP_REPORT_INFO(VOFF, "aes_plm_in[%u] = %02X", ESP_TO_UINT32(i) + 0,
                                    data_0.to_uint());
                    ESP_REPORT_INFO(VOFF, "aes_plm_in[%u] = %02X", ESP_TO_UINT32(i) + 1,
                                    data_1.to_uint());
                }
            }
        }

        // Configure DMA read channel (CTRL)
        // - DMA_WIDTH for EPOCHS is 64 bits
        // - AES input word is 32 bits
        // - Each DMA transaction is 2 input words
        // - Do some math (ceil) to get the number of data and DMA words given key_bytes
        dma_read_data_index  = (aes_key_bytes + 4 - 1) / 4 + (aes_iv_bytes + 4 - 1) / 4;
        dma_read_data_length = (aes_in_bytes + 4 - 1) / 4; // ceil(key_bytes / 4)
        dma_read_info      = {(dma_read_data_index + 2 - 1) / 2, (dma_read_data_length + 2 - 1) / 2,
                         SIZE_WORD}; // ceil(dma_read_data_legnth / 2)
        dma_read_ctrl_done = false;
AES_LOAD_INPUT_CTRL_LOOP:
        do {
            dma_read_ctrl_done = dma_read_ctrl.nb_write(dma_read_info);
        } while (!dma_read_ctrl_done);

        ESP_REPORT_INFO(VON,
                        "DMA read ctrl: data index = %u, data length = %u, size [0=8b, 1=16b, "
                        "2=32b, 3=64b] = %llu",
                        ESP_TO_UINT32(dma_read_info.index), ESP_TO_UINT32(dma_read_info.length),
                        dma_read_info.size.to_uint64());

        if (dma_read_ctrl_done) { // Force serialization between DMA control and DATA data transfer
AES_LOAD_INPUT_LOOP:
            for (uint16_t i = 0; i < AES_PLM_IN_SIZE; i += 2) {

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
                data_0                 = data_dma.template slc<WL>(WL * 0).to_uint();
                data_1                 = data_dma.template slc<WL>(WL * 1).to_uint();
                aes_plm_in.data[i + 0] = data_0;
                aes_plm_in.data[i + 1] = data_1;

                ESP_REPORT_INFO(VOFF, "aes_plm_in[%u] = %02X", ESP_TO_UINT32(i) + 0,
                                data_0.to_uint());
                ESP_REPORT_INFO(VOFF, "aes_plm_in[%u] = %02X", ESP_TO_UINT32(i) + 1,
                                data_1.to_uint());
            }
        }

        aes_compute_wrapper(aes_oper_mode, aes_encryption, aes_key_bytes, aes_iv_bytes,
                            aes_in_bytes, aes_aad_bytes, aes_tag_bytes, aes_plm_key, aes_plm_iv,
                            aes_plm_in, aes_plm_out, aes_plm_aad, aes_plm_tag);

        // Configure DMA write channel (CTRL)
        // - DMA_WIDTH for EPOCHS is 64 bits
        // - AES output word is 32 bits
        // - Each DMA transaction is 2 output words
        // - Do some math (ceil) to get the number of data and DMA words given out_bytes
        dma_write_data_index =
            (aes_key_bytes + 4 - 1) / 4 + (aes_iv_bytes + 4 - 1) / 4 + (aes_in_bytes + 4 - 1) / 4;
        dma_write_data_length = (aes_output_bytes + 4 - 1) / 4; // ceil(out_bytes / 4)
        dma_write_info = {(dma_write_data_index + 2 - 1) / 2, (dma_write_data_length + 2 - 1) / 2,
                          SIZE_WORD};
        bool dma_write_ctrl_done = false;
AES_STORE_CTRL_LOOP:
        do {
            dma_write_ctrl_done = dma_write_ctrl.nb_write(dma_write_info);
        } while (!dma_write_ctrl_done);

        ESP_REPORT_INFO(VON,
                        "DMA write ctrl: data index = %u, data length = %u, size [0=8b, 1=16b, "
                        "2=32b, 3=64b] = %llu",
                        ESP_TO_UINT32(dma_write_info.index), ESP_TO_UINT32(dma_write_info.length),
                        dma_write_info.size.to_uint64());

        if (dma_write_ctrl_done) { // Force serialization between DMA control and DATA data transfer
AES_STORE_LOOP:
            for (uint16_t i = 0; i < AES_PLM_OUT_SIZE; i += 2) {

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

                data_t data_0(aes_plm_out.data[i + 0]);
                // data_t data_1((i+1 >= dma_write_data_length)?ZERO:plm_out.data[i+1]);
                data_t data_1(aes_plm_out.data[i + 1]);

                data_dma.set_slc(WL * 0, data_0.template slc<WL>(0));
                data_dma.set_slc(WL * 1, data_1.template slc<WL>(0));

                ESP_REPORT_INFO(VOFF, "aes_plm_out[%u] = %02X", ESP_TO_UINT32(i) + 0,
                                data_0.to_uint());
                ESP_REPORT_INFO(VOFF, "aes_plm_out[%u] = %02X", ESP_TO_UINT32(i) + 1,
                                data_1.to_uint());

                dma_write_chnl.write(data_dma);
            }
        }
    }

    acc_done.sync_out();
}
