// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "nightvision.hpp"
#include "nightvision_directives.hpp"

// Functions

#include "nightvision_functions.hpp"

// Processes

void nightvision::load_input()
{
    uint32_t n_Images;
    uint32_t n_Rows;
    uint32_t n_Cols;

    // Reset
    {
        HLS_PROTO("load-reset");

        this->reset_load_input();
        accel_ready.ack.reset_ack();

        // User-defined reset code
        n_Images = 0;
        n_Rows   = 0;
        n_Cols   = 0;

        wait();
    }

    // Config
    {
        HLS_PROTO("load-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
        n_Images = config.n_Images;
        n_Rows   = config.n_Rows;
        n_Cols   = config.n_Cols;
    }

    // Load
    uint32_t dma_addr = 0;
    for (uint16_t a = 0; a < n_Images; a++) {
        HLS_PROTO("load-dma");

        this->load_store_handshake();

        uint32_t plm_addr = 0;

        for (uint16_t b = 0; b < n_Rows; b++) {

            // Configure DMA transaction
            dma_info_t dma_info(dma_addr, n_Cols / WORDS_PER_DMA, SIZE_HWORD);
            this->dma_read_ctrl.put(dma_info);

            for (uint32_t i = plm_addr; i < (plm_addr + n_Cols); i += WORDS_PER_DMA) {
                sc_bv<DMA_WIDTH> data = this->dma_read_chnl.get();
                HLS_BREAK_DEP(mem_buff_1);
                HLS_BREAK_DEP(mem_buff_2);
                wait();

                for (uint8_t k = 0; k < WORDS_PER_DMA; k++) {
                    HLS_UNROLL_SIMPLE;
                    // Write to PLM
                    mem_buff_1[i + k] =
                        data.range(((k + 1) << MAX_PXL_WIDTH_LOG) - 1, k << MAX_PXL_WIDTH_LOG).to_uint();
                    mem_buff_2[i + k] = 0;
                }
            }
            dma_addr += n_Cols / WORDS_PER_DMA;
            plm_addr += n_Cols;
        }

        this->load_compute_handshake();
    }

    // Conclude
    {
        HLS_PROTO("load-done");
        this->process_done();
    }
}

void nightvision::store_output()
{
    uint32_t n_Images;
    uint32_t n_Rows;
    uint32_t n_Cols;

    // Reset
    {
        HLS_PROTO("store-reset");

        this->reset_store_output();
        accel_ready.req.reset_req();

        // User-defined reset code
        n_Images = 0;
        n_Rows   = 0;
        n_Cols   = 0;

        wait();
    }

    // Config
    {
        HLS_PROTO("store-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
        n_Images = config.n_Images;
        n_Rows   = config.n_Rows;
        n_Cols   = config.n_Cols;
    }

    // Store
    uint32_t dma_addr = 0;
    for (uint16_t a = 0; a < n_Images; a++) {
        HLS_PROTO("store-dma");

        this->store_load_handshake();
        this->store_compute_handshake();

        uint32_t plm_addr = 0;
        for (uint16_t b = 0; b < n_Rows; b++) {
            // Configure DMA transaction
            dma_info_t dma_info(dma_addr, n_Cols / WORDS_PER_DMA, SIZE_HWORD);

            this->dma_write_ctrl.put(dma_info);

            for (uint32_t i = plm_addr; i < (plm_addr + n_Cols); i += WORDS_PER_DMA) {
                sc_bv<DMA_WIDTH> data;

                wait();
                for (uint8_t k = 0; k < WORDS_PER_DMA; k++) {
                    HLS_UNROLL_SIMPLE;
                    // Read from PLM
                    data.range(((k + 1) << MAX_PXL_WIDTH_LOG) - 1, k << MAX_PXL_WIDTH_LOG) =
                        sc_bv<MAX_PXL_WIDTH>(mem_buff_1[i + k]);
                }

                this->dma_write_chnl.put(data);
            }
            dma_addr += n_Cols / WORDS_PER_DMA;
            plm_addr += n_Cols;
        }
    }

    // Conclude
    {
        HLS_PROTO("store-done");
        this->accelerator_done();
        this->process_done();
    }
}

void nightvision::compute_kernel()
{
    uint32_t n_Images;
    uint32_t n_Rows;
    uint32_t n_Cols;
    uint32_t plm_size;
    uint32_t index_last_row;
    bool     do_dwt;

    // Reset
    {
        HLS_PROTO("compute-reset");

        this->reset_compute_kernel();

        // User-defined reset code
        n_Images = 0;
        n_Rows   = 0;
        n_Cols   = 0;
        do_dwt   = 0;

        wait();
    }

    {
        HLS_PROTO("compute-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
        n_Images       = config.n_Images;
        n_Rows         = config.n_Rows;
        n_Cols         = config.n_Cols;
        do_dwt         = config.do_dwt;
        plm_size       = n_Cols * n_Rows;
        index_last_row = plm_size - n_Cols;
    }

    // Compute
    for (uint16_t a = 0; a < n_Images; a++) {
        this->compute_load_handshake();

        // Computing phase implementation
        kernel_nf(n_Rows, n_Cols);
        kernel_hist(n_Rows, n_Cols);
        kernel_histEq(n_Rows, n_Cols);
        if (do_dwt)
            kernel_dwt(n_Rows, n_Cols);

        this->compute_store_handshake();
    }

    // Conclude
    {
        HLS_PROTO("compute-done");
        this->process_done();
    }
}
