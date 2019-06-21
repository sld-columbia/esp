// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: MIT

#include "visionchip.hpp"
#include "visionchip_directives.hpp"

// Functions

#include "visionchip_functions.cpp"

// Processes

void visionchip::load_input()
{
    uint32_t n_Images;
    uint32_t n_Rows;
    uint32_t n_Cols;

    // Reset
    {
        HLS_DEFINE_PROTOCOL("load-reset");

        this->reset_load_input();
        accel_ready.ack.reset_ack();

        // User-defined reset code
        n_Images = 0;
        n_Rows = 0;
        n_Cols = 0;

        wait();
    }

    // Config
    {
        HLS_DEFINE_PROTOCOL("load-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
        n_Images = config.n_Images;
        n_Rows = config.n_Rows;
        n_Cols = config.n_Cols;
    }

    // Load
    uint32_t dma_addr = 0;
    for (uint16_t a = 0; a < n_Images; a++)
    {
        this->load_store_handshake();

        uint32_t plm_addr = 0;
        for (uint16_t b = 0; b < n_Rows; b++)
        {
            HLS_LOAD_INPUT_BATCH_LOOP;

            {
                HLS_DEFINE_PROTOCOL("load-dma-conf");

                // Configure DMA transaction
                dma_info_t dma_info(dma_addr, n_Cols);

                this->dma_read_ctrl.put(dma_info);
            }

            for (uint32_t i = plm_addr; i < (plm_addr + n_Cols); i++)
            {
                HLS_LOAD_INPUT_LOOP;

                int32_t data = this->dma_read_chnl.get().to_int();
                {
                    HLS_LOAD_INPUT_PLM_WRITE;

                    // Write to PLM
                    wait();
                    mem_buff_1[i] = (int16_t) data;
                }
            }

            dma_addr += n_Cols;
            plm_addr += n_Cols;
        }
        this->load_compute_handshake();
    }

    // Conclude
    {
        this->process_done();
    }
}



void visionchip::store_output()
{
    uint32_t n_Images;
    uint32_t n_Rows;
    uint32_t n_Cols;

    // Reset
    {
        HLS_DEFINE_PROTOCOL("store-reset");

        this->reset_store_output();
        accel_ready.req.reset_req();

        // User-defined reset code
        n_Images = 0;
        n_Rows = 0;
        n_Cols = 0;

        wait();
    }

    // Config
    {
        HLS_DEFINE_PROTOCOL("store-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
        n_Images = config.n_Images;
        n_Rows = config.n_Rows;
        n_Cols = config.n_Cols;
    }

    // Store
    uint32_t dma_addr = 0;
    for (uint16_t a = 0; a < n_Images; a++)
    {
        this->store_load_handshake();
        this->store_compute_handshake();

        uint32_t plm_addr = 0;
        for (uint16_t b = 0; b < n_Rows; b++)
        {
            HLS_STORE_OUTPUT_BATCH_LOOP;

            {
                HLS_DEFINE_PROTOCOL("store-dma-conf");

                // Configure DMA transaction
                dma_info_t dma_info(dma_addr, n_Cols);

                this->dma_write_ctrl.put(dma_info);
            }
            for (uint32_t i = plm_addr; i < (plm_addr + n_Cols); i++)
            {
                HLS_STORE_OUTPUT_LOOP;

                sc_bv<DMA_WIDTH> data;
                {
                    HLS_STORE_OUTPUT_PLM_READ;
                    // Read from PLM
                    data = sc_bv<DMA_WIDTH>((int32_t) mem_buff_1[i]);
                    wait();
                }
                this->dma_write_chnl.put(data);
            }
            dma_addr += n_Cols;
            plm_addr += n_Cols;
        }
    }

    // Conclude
    {
        this->accelerator_done();
        this->process_done();
    }
}


void visionchip::compute_kernel()
{
    uint32_t n_Images;
    uint32_t n_Rows;
    uint32_t n_Cols;
    uint32_t plm_size;
    uint32_t index_last_row;

    // Reset
    {
        HLS_DEFINE_PROTOCOL("compute-reset");

        this->reset_compute_kernel();

        // User-defined reset code
        n_Images = 0;
        n_Rows = 0;
        n_Cols = 0;

        wait();
    }

    {
        HLS_DEFINE_PROTOCOL("compute-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
        n_Images = config.n_Images;
        n_Rows = config.n_Rows;
        n_Cols = config.n_Cols;
        plm_size = n_Cols * n_Rows;
        index_last_row = plm_size - n_Cols;
    }

    //Compute
    for (uint16_t a = 0; a < n_Images; a++)
    {
        // Reset PLMs
        // reset mem_buff_2 memory
        for(uint32_t i = 0 ; i < plm_size; i++)
        {
            mem_buff_2[i] = 0;
            wait();
        }

        // reset mem_hist
        for(uint32_t i = 0; i < PLM_HIST_SIZE; i++)
        {
            mem_hist_1[i] = 0;
            wait();
        }

        this->compute_load_handshake();

        // Computing phase implementation
        kernel_nf(n_Rows, n_Cols);
        kernel_hist(n_Rows, n_Cols);
        kernel_histEq(n_Rows, n_Cols);
        kernel_dwt(n_Rows, n_Cols);

        this->compute_store_handshake();
    }

    // Conclude
    {
        this->process_done();
    }
}
