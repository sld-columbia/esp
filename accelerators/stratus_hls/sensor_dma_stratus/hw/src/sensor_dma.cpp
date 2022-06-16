// Copyright (c) 2011-2021 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "sensor_dma.hpp"
#include "sensor_dma_directives.hpp"

// Functions

#include "sensor_dma_functions.hpp"

// Processes

void sensor_dma::load_input()
{

    // Reset
    {
        HLS_PROTO("load-reset");

        this->reset_load_input();

        wait();
    }

    // Config
    /* <<--params-->> */
    int32_t rd_sp_offset;
    int32_t rd_wr_enable;
    int32_t rd_size;
    int32_t src_offset;
    {
        HLS_PROTO("load-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
        /* <<--local-params-->> */
        rd_sp_offset = config.rd_sp_offset;
        rd_wr_enable = config.rd_wr_enable;
        rd_size = config.rd_size;
        src_offset = config.src_offset;
    }

    // Load - only if rd_wr_enable is 0
    if(rd_wr_enable == 0)
    {
        HLS_PROTO("load-dma");
        wait();

        // Calculating the length of our transfer
        uint32_t length = round_up(rd_size, DMA_WORD_PER_BEAT);

        // Configure DMA transaction
        dma_info_t dma_info(src_offset / DMA_WORD_PER_BEAT, length / DMA_WORD_PER_BEAT, DMA_SIZE);

        this->dma_read_ctrl.put(dma_info);

        for (uint16_t i = 0; i < length; i += DMA_WORD_PER_BEAT)
        {
            sc_dt::sc_bv<DMA_WIDTH> dataBv;

            dataBv = this->dma_read_chnl.get();
            wait();

            // Write to PLM (all DMA_WORD_PER_BEAT words in one cycle)
            for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++)
            {
                HLS_UNROLL_SIMPLE;
                plm[rd_sp_offset + i + k] = dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64();
            }
        }

        this->accelerator_done();
    }

    // Conclude
    {
        this->process_done();
    }
}



void sensor_dma::store_output()
{
    // Reset
    {
        HLS_PROTO("store-reset");

        this->reset_store_output();

        wait();
    }

    // Config
    /* <<--params-->> */
    int32_t rd_wr_enable;
    int32_t wr_size;
    int32_t wr_sp_offset;
    int32_t dst_offset;
    {
        HLS_PROTO("store-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
        /* <<--local-params-->> */
        rd_wr_enable = config.rd_wr_enable;
        wr_size = config.wr_size;
        wr_sp_offset = config.wr_sp_offset;
        dst_offset = config.dst_offset;
    }

    // Store - only if rd_wr_enable is 1
    if(rd_wr_enable == 1)
    {
        HLS_PROTO("store-dma");
        wait();

        // Calculating the length of our transfer
        uint32_t length = round_up(wr_size, DMA_WORD_PER_BEAT);

        // Configure DMA transaction
        dma_info_t dma_info(dst_offset / DMA_WORD_PER_BEAT, length / DMA_WORD_PER_BEAT, DMA_SIZE);

        this->dma_write_ctrl.put(dma_info);

        for (uint16_t i = 0; i < length; i += DMA_WORD_PER_BEAT)
        {
            sc_dt::sc_bv<DMA_WIDTH> dataBv;

            wait();

            // Write to PLM (all DMA_WORD_PER_BEAT words in one cycle)
            for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++)
            {
                HLS_UNROLL_SIMPLE;
                dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH) = plm[wr_sp_offset + i + k];
            }

            this->dma_write_chnl.put(dataBv);
        }

        this->accelerator_done();
    }

    // Conclude
    {
        this->process_done();
    }
}


void sensor_dma::compute_kernel()
{
    // Reset
    {
        HLS_PROTO("compute-reset");

        this->reset_compute_kernel();

        wait();
    } 

    // Conclude
    {
        this->process_done();
    } 
}
