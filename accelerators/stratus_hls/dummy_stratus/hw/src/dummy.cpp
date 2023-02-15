// Copyright (c) 2011-2023 Columbia University, System Level Design Group
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
        batch = config.batch;
    }

    // Load
    bool ping = true;
    uint32_t offset = 0;
    for (int n = 0; n < batch; n++)
        for (int b = tokens; b > 0; b -= PLM_SIZE)
        {
            HLS_PROTO("load-dma");

            uint32_t len = b > PLM_SIZE ? PLM_SIZE : b;
            dma_info_t dma_info(offset * DMA_BEAT_PER_WORD, len * DMA_BEAT_PER_WORD, DMA_SIZE);
            offset += len;

            this->dma_read_ctrl.put(dma_info);

            for (uint16_t i = 0; i < len; i++) {
                uint64_t data;
                sc_dt::sc_bv<64> data_bv;

#if (DMA_WIDTH == 64)
                data_bv = this->dma_read_chnl.get();
#elif (DMA_WIDTH == 32)
                data_bv.range(31, 0) = this->dma_read_chnl.get();
                wait();
                data_bv.range(63, 32) = this->dma_read_chnl.get();
#endif
                wait();
                data = data_bv.to_uint64();

                if (ping)
                    plm0[i] = data;
                else
                    plm1[i] = data;
            }
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
        batch = config.batch;
    }

    // Store
    bool ping = true;
    uint32_t offset = 0;
    for (int n = 0; n < batch; n++)
        for (int b = tokens; b > 0; b -= PLM_SIZE)
        {
            HLS_PROTO("store-dma");
            this->store_compute_handshake();

            uint32_t len = b > PLM_SIZE ? PLM_SIZE : b;
            dma_info_t dma_info(offset * DMA_BEAT_PER_WORD, len * DMA_BEAT_PER_WORD, DMA_SIZE);
            offset += len;

            this->dma_write_ctrl.put(dma_info);

            for (uint16_t i = 0; i < len; i++) {

                wait();
                uint64_t data;
                if (ping)
                    data = plm0[i];
                else
                    data = plm1[i];
                sc_dt::sc_bv<64> data_bv(data);

#if (DMA_WIDTH == 64)
                this->dma_write_chnl.put(data_bv);
#elif (DMA_WIDTH == 32)
                this->dma_write_chnl.put(data_bv.range(31, 0));
                wait();
                this->dma_write_chnl.put(data_bv.range(64, 32));
#endif
            }
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
