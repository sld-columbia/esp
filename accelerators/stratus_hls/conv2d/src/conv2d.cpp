// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "conv2d.hpp"
#include "conv2d_directives.hpp"

// Functions

#include "conv2d_functions.hpp"

// Processes

void conv2d::load_input()
{

    // Reset
    {
        HLS_PROTO("load-reset");

        this->reset_load_input();

        // explicit PLM ports reset if any

        // User-defined reset code

        wait();
    }

    // Config
    /* <<--params-->> */
    int32_t n_channels;
    int32_t n_filters;
    int32_t filter_height;
    int32_t dilation_h;
    int32_t stride_w;
    int32_t pad_w;
    int32_t feature_map_height;
    int32_t pad_h;
    int32_t stride_h;
    int32_t filter_width;
    int32_t dilation_w;
    int32_t feature_map_width;
    {
        HLS_PROTO("load-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
        /* <<--local-params-->> */
        n_channels = config.n_channels;
        n_filters = config.n_filters;
        filter_height = config.filter_height;
        dilation_h = config.dilation_h;
        stride_w = config.stride_w;
        pad_w = config.pad_w;
        feature_map_height = config.feature_map_height;
        pad_h = config.pad_h;
        stride_h = config.stride_h;
        filter_width = config.filter_width;
        dilation_w = config.dilation_w;
        feature_map_width = config.feature_map_width;
    }

    // Load
    {
        HLS_PROTO("load-dma");
        wait();

        bool ping = true;
        uint32_t offset = 0;

        // Batching
        for (uint16_t b = 0; b < 1; b++)
        {
            wait();
#if (DMA_WORD_PER_BEAT == 0)
            uint32_t length = n_channels * feature_map_height * feature_map_width;
#else
            uint32_t length = round_up(n_channels * feature_map_height * feature_map_width, DMA_WORD_PER_BEAT);
#endif
            // Chunking
            for (int rem = length; rem > 0; rem -= PLM_IN_WORD)
            {
                wait();
                // Configure DMA transaction
                uint32_t len = rem > PLM_IN_WORD ? PLM_IN_WORD : rem;
#if (DMA_WORD_PER_BEAT == 0)
                // data word is wider than NoC links
                dma_info_t dma_info(offset * DMA_BEAT_PER_WORD, len * DMA_BEAT_PER_WORD, DMA_SIZE);
#else
                dma_info_t dma_info(offset / DMA_WORD_PER_BEAT, len / DMA_WORD_PER_BEAT, DMA_SIZE);
#endif
                offset += len;

                this->dma_read_ctrl.put(dma_info);

#if (DMA_WORD_PER_BEAT == 0)
                // data word is wider than NoC links
                for (uint16_t i = 0; i < len; i++)
                {
                    sc_dt::sc_bv<DATA_WIDTH> dataBv;

                    for (uint16_t k = 0; k < DMA_BEAT_PER_WORD; k++)
                    {
                        dataBv.range((k+1) * DMA_WIDTH - 1, k * DMA_WIDTH) = this->dma_read_chnl.get();
                        wait();
                    }

                    // Write to PLM
                    if (ping)
                        plm_in_ping[i] = dataBv.to_int64();
                    else
                        plm_in_pong[i] = dataBv.to_int64();
                }
#else
                for (uint16_t i = 0; i < len; i += DMA_WORD_PER_BEAT)
                {
                    HLS_BREAK_DEP(plm_in_ping);
                    HLS_BREAK_DEP(plm_in_pong);

                    sc_dt::sc_bv<DMA_WIDTH> dataBv;

                    dataBv = this->dma_read_chnl.get();
                    wait();

                    // Write to PLM (all DMA_WORD_PER_BEAT words in one cycle)
                    for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++)
                    {
                        HLS_UNROLL_SIMPLE;
                        if (ping)
                            plm_in_ping[i + k] = dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64();
                        else
                            plm_in_pong[i + k] = dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64();
                    }
                }
#endif
                this->load_compute_handshake();
                ping = !ping;
            }
        }
    }

    // Conclude
    {
        this->process_done();
    }
}



void conv2d::store_output()
{
    // Reset
    {
        HLS_PROTO("store-reset");

        this->reset_store_output();

        // explicit PLM ports reset if any

        // User-defined reset code

        wait();
    }

    // Config
    /* <<--params-->> */
    int32_t n_channels;
    int32_t n_filters;
    int32_t filter_height;
    int32_t dilation_h;
    int32_t stride_w;
    int32_t pad_w;
    int32_t feature_map_height;
    int32_t pad_h;
    int32_t stride_h;
    int32_t filter_width;
    int32_t dilation_w;
    int32_t feature_map_width;
    {
        HLS_PROTO("store-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
        /* <<--local-params-->> */
        n_channels = config.n_channels;
        n_filters = config.n_filters;
        filter_height = config.filter_height;
        dilation_h = config.dilation_h;
        stride_w = config.stride_w;
        pad_w = config.pad_w;
        feature_map_height = config.feature_map_height;
        pad_h = config.pad_h;
        stride_h = config.stride_h;
        filter_width = config.filter_width;
        dilation_w = config.dilation_w;
        feature_map_width = config.feature_map_width;
    }

    // Store
    {
        HLS_PROTO("store-dma");
        wait();

        bool ping = true;
#if (DMA_WORD_PER_BEAT == 0)
        uint32_t store_offset = (n_channels * feature_map_height * feature_map_width) * 1;
#else
        uint32_t store_offset = round_up(n_channels * feature_map_height * feature_map_width, DMA_WORD_PER_BEAT) * 1;
#endif
        uint32_t offset = store_offset;

        wait();
        // Batching
        for (uint16_t b = 0; b < 1; b++)
        {
            wait();
#if (DMA_WORD_PER_BEAT == 0)
            uint32_t length = n_channels * feature_map_height * feature_map_width;
#else
            uint32_t length = round_up(n_channels * feature_map_height * feature_map_width, DMA_WORD_PER_BEAT);
#endif
            // Chunking
            for (int rem = length; rem > 0; rem -= PLM_OUT_WORD)
            {

                this->store_compute_handshake();

                // Configure DMA transaction
                uint32_t len = rem > PLM_OUT_WORD ? PLM_OUT_WORD : rem;
#if (DMA_WORD_PER_BEAT == 0)
                // data word is wider than NoC links
                dma_info_t dma_info(offset * DMA_BEAT_PER_WORD, len * DMA_BEAT_PER_WORD, DMA_SIZE);
#else
                dma_info_t dma_info(offset / DMA_WORD_PER_BEAT, len / DMA_WORD_PER_BEAT, DMA_SIZE);
#endif
                offset += len;

                this->dma_write_ctrl.put(dma_info);

#if (DMA_WORD_PER_BEAT == 0)
                // data word is wider than NoC links
                for (uint16_t i = 0; i < len; i++)
                {
                    // Read from PLM
                    sc_dt::sc_int<DATA_WIDTH> data;
                    wait();
                    if (ping)
                        data = plm_out_ping[i];
                    else
                        data = plm_out_pong[i];
                    sc_dt::sc_bv<DATA_WIDTH> dataBv(data);

                    uint16_t k = 0;
                    for (k = 0; k < DMA_BEAT_PER_WORD - 1; k++)
                    {
                        this->dma_write_chnl.put(dataBv.range((k+1) * DMA_WIDTH - 1, k * DMA_WIDTH));
                        wait();
                    }
                    // Last beat on the bus does not require wait(), which is
                    // placed before accessing the PLM
                    this->dma_write_chnl.put(dataBv.range((k+1) * DMA_WIDTH - 1, k * DMA_WIDTH));
                }
#else
                for (uint16_t i = 0; i < len; i += DMA_WORD_PER_BEAT)
                {
                    sc_dt::sc_bv<DMA_WIDTH> dataBv;

                    // Read from PLM
                    wait();
                    for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++)
                    {
                        HLS_UNROLL_SIMPLE;
                        if (ping)
                            dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH) = plm_out_ping[i + k];
                        else
                            dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH) = plm_out_pong[i + k];
                    }
                    this->dma_write_chnl.put(dataBv);
                }
#endif
                ping = !ping;
            }
        }
    }

    // Conclude
    {
        this->accelerator_done();
        this->process_done();
    }
}


void conv2d::compute_kernel()
{
    // Reset
    {
        HLS_PROTO("compute-reset");

        this->reset_compute_kernel();

        // explicit PLM ports reset if any

        // User-defined reset code

        wait();
    }

    // Config
    /* <<--params-->> */
    int32_t n_channels;
    int32_t n_filters;
    int32_t filter_height;
    int32_t dilation_h;
    int32_t stride_w;
    int32_t pad_w;
    int32_t feature_map_height;
    int32_t pad_h;
    int32_t stride_h;
    int32_t filter_width;
    int32_t dilation_w;
    int32_t feature_map_width;
    {
        HLS_PROTO("compute-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
        /* <<--local-params-->> */
        n_channels = config.n_channels;
        n_filters = config.n_filters;
        filter_height = config.filter_height;
        dilation_h = config.dilation_h;
        stride_w = config.stride_w;
        pad_w = config.pad_w;
        feature_map_height = config.feature_map_height;
        pad_h = config.pad_h;
        stride_h = config.stride_h;
        filter_width = config.filter_width;
        dilation_w = config.dilation_w;
        feature_map_width = config.feature_map_width;
    }


    // Compute
    bool ping = true;
    {
        for (uint16_t b = 0; b < 1; b++)
        {
            uint32_t in_length = n_channels * feature_map_height * feature_map_width;
            uint32_t out_length = n_channels * feature_map_height * feature_map_width;
            int out_rem = out_length;

            for (int in_rem = in_length; in_rem > 0; in_rem -= PLM_IN_WORD)
            {

                uint32_t in_len  = in_rem  > PLM_IN_WORD  ? PLM_IN_WORD  : in_rem;
                uint32_t out_len = out_rem > PLM_OUT_WORD ? PLM_OUT_WORD : out_rem;

                this->compute_load_handshake();

                // Computing phase implementation
                for (int i = 0; i < in_len; i++) {
                    if (ping)
                        plm_out_ping[i] = plm_in_ping[i];
                    else
                        plm_out_pong[i] = plm_in_pong[i];
                }

                out_rem -= PLM_OUT_WORD;
                this->compute_store_handshake();
                ping = !ping;
            }
        }

        // Conclude
        {
            this->process_done();
        }
    }
}
