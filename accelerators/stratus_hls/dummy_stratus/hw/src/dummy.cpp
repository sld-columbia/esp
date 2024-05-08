// Copyright (c) 2011-2024 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "dummy.hpp"
#include "dummy_directives.hpp"

// Functions

#include "dummy_functions.hpp"

// Processes

void dummy::load_input()
{

    // Reset
    {
        HLS_PROTO("load-reset");

        this->reset_load_input();

        wait();
    }

    // Config
    uint32_t tokens;
    uint32_t batch;
    {
        HLS_PROTO("load-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        tokens = config.tokens;
        batch  = config.batch;
    }

    // Load
    bool ping       = true;
    uint32_t offset = 0;
    for (int n = 0; n < batch; n++)
        for (int b = tokens; b > 0; b -= PLM_SIZE) {
            HLS_PROTO("load-dma");

            uint32_t len = b > PLM_SIZE ? PLM_SIZE : b;
#if (DMA_WORD_PER_BEAT == 0)
            dma_info_t dma_info(offset * DMA_BEAT_PER_WORD, len * DMA_BEAT_PER_WORD, DMA_SIZE);
#else
            dma_info_t dma_info(offset / DMA_WORD_PER_BEAT, len / DMA_WORD_PER_BEAT, DMA_SIZE);
#endif
            offset += len;

            this->dma_read_ctrl.put(dma_info);
#if (DMA_WORD_PER_BEAT == 0)
            for (uint16_t i = 0; i < len; i += DMA_WORD_PER_BEAT) {
                sc_dt::sc_bv<64> data_bv;
                for (uint16_t k = 0; k < DMA_BEAT_PER_WORD; k++) {
                    data_bv.range((k + 1) * DMA_WIDTH - 1, k * DMA_WIDTH) =
                        this->dma_read_chnl.get();
                    wait();
                }
                if (ping) plm0[i] = data_bv.to_int64();
                else
                    plm1[i] = data_bv.to_int64();
            }
#else
            for (uint16_t i = 0; i < len; i += DMA_WORD_PER_BEAT) {
                HLS_BREAK_DEP(plm0);
                HLS_BREAK_DEP(plm1);

                uint64_t data;
                sc_dt::sc_bv<DMA_WIDTH> data_bv;

                data_bv = this->dma_read_chnl.get();
                wait();
                for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++) {
                    HLS_UNROLL_SIMPLE;
                    if (ping) plm0[i + k] = data_bv.range((k + 1) * 64 - 1, k * 64).to_int64();
                    else
                        plm1[i + k] = data_bv.range((k + 1) * 64 - 1, k * 64).to_int64();
                }
            }
#endif
            this->load_compute_handshake();
            ping = !ping;
        }

    // Conclude
    {
        this->process_done();
    }
}

void dummy::store_output()
{
    // Reset
    {
        HLS_PROTO("store-reset");

        this->reset_store_output();

        wait();
    }

    // Config
    uint32_t tokens;
    uint32_t batch;
    {
        HLS_PROTO("store-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        tokens = config.tokens;
        batch  = config.batch;
    }

    // Store
    bool ping       = true;
    uint32_t offset = 0;
    for (int n = 0; n < batch; n++)
        for (int b = tokens; b > 0; b -= PLM_SIZE) {
            HLS_PROTO("store-dma");
            this->store_compute_handshake();

            uint32_t len = b > PLM_SIZE ? PLM_SIZE : b;
#if (DMA_WORD_PER_BEAT == 0)
            dma_info_t dma_info(offset * DMA_BEAT_PER_WORD, len * DMA_BEAT_PER_WORD, DMA_SIZE);
#else
            dma_info_t dma_info(offset / DMA_WORD_PER_BEAT, len / DMA_WORD_PER_BEAT, DMA_SIZE);
#endif
            offset += len;

            this->dma_write_ctrl.put(dma_info);
#if (DMA_WORD_PER_BEAT == 0)
            for (uint16_t i = 0; i < len; i += DMA_WORD_PER_BEAT) {
                sc_dt::sc_int<64> data;
                wait();
                if (ping) data = plm0[i];
                else
                    data = plm1[i];

                sc_dt::sc_bv<DMA_WIDTH> data_bv(data);

                for (uint16_t k = 0; k < DMA_BEAT_PER_WORD; k++) {
                    this->dma_write_chnl.put(data_bv.range((k + 1) * DMA_WIDTH - 1, k * DMA_WIDTH));
                    wait();
                }
            }
#else
            for (uint16_t i = 0; i < len; i += DMA_WORD_PER_BEAT) {
                sc_dt::sc_bv<DMA_WIDTH> data_bv;
                wait();
                for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++) {
                    HLS_UNROLL_SIMPLE;
                    if (ping) data_bv.range((k + 1) * 64 - 1, k * 64) = plm0[i + k];
                    else
                        data_bv.range((k + 1) * 64 - 1, k * 64) = plm1[i + k];
                }
                this->dma_write_chnl.put(data_bv);
            }
#endif
            ping = !ping;
        }

    // Conclude
    {
        this->accelerator_done();
        this->process_done();
    }
}

void dummy::compute_kernel()
{
    // Reset
    {
        HLS_PROTO("compute-reset");

        this->reset_compute_kernel();

        wait();
    }

    // Config
    {
        HLS_PROTO("compute-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();
    }

    // Compute (dummy does nothing)
    while (true) {
        this->compute_load_handshake();
        this->compute_store_handshake();
    }
}
