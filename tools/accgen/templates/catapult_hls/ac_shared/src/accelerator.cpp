// Copyright (c) 2011-2025 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "accelerator_name.hpp"
#include <mc_scverify.h>

void acc_full_name::config()
{
    conf_info.Reset();
    conf1.ResetWrite();
    conf2.ResetWrite();
    conf3.ResetWrite();

    sync01.ResetWrite();
    sync02.ResetWrite();
    sync03.ResetWrite();

    wait();

    while (1) {
        conf_info_t conf_di = conf_info.Pop();

        conf1.Push(conf_di);
        conf2.Push(conf_di);
        conf3.Push(conf_di);

        sync01.Push(1);
        sync02.Push(1);
        sync03.Push(1);
    }
}

void acc_full_name::load()
{
    bool ping_pong = false;
    dma_read_chnl.Reset();
    dma_read_ctrl.Reset();

    sync01.ResetRead();
    sync12.reset_sync_out();

    conf1.ResetRead();

    wait();

    while (1) {
        sync01.Pop();

        bool ping       = true;
        uint32_t offset = 0;

        conf_info_t conf = conf1.Pop();

        /* <<--local-params-->> */

        // Batching
        for (uint16_t b = 0; b < /* <<--number of transfers-->> */; b++) {
            wait();

#if (DMA_WORD_PER_BEAT == 0)
            uint32_t len = /* <<--data_in_size-->> */;
#else
            uint32_t len = round_up(/* <<--data_in_size-->> */, DMA_WORD_PER_BEAT);
#endif

            // Chunking
            for (int rem = len; rem > 0; rem -= PLM_IN_WORD) {
                uint32_t len1 = rem > PLM_IN_WORD ? PLM_IN_WORD : rem;
#if (DMA_WORD_PER_BEAT == 0)
                dma_info_t dma_info(offset * DMA_BEAT_PER_WORD, len1 * DMA_BEAT_PER_WORD, DMA_SIZE,
                                    0);
#else
                dma_info_t dma_info(offset / DMA_WORD_PER_BEAT, len1 / DMA_WORD_PER_BEAT, DMA_SIZE,
                                    0);
#endif

                offset += len1;

                dma_read_ctrl.Push(dma_info);

#if (DMA_WORD_PER_BEAT == 0)
    #pragma hls_pipeline_init_interval 1
    #pragma pipeline_stallt_mode flush
                for (uint32_t i = 0; i < len1; i++) {
                    ac_int<DATA_WIDTH> dataBv;

    #pragma hls_pipeline_init_interval 1
    #pragma pipeline_stallt_mode flush
                    for (uint32_t k = 0; k < DMA_BEAT_PER_WORD; k++) {
                        ac_int<DMA_WIDTH> data_m = dma_read_chnl.Pop();
                        dataBv.set_slc(k * DMA_WIDTH, data_m);
                    }

                    if (ping_pong)
                        plm_in_ping[0][i] = dataBv;
                    else
                        plm_in_pong[0][i] = dataBv;

                }
#else
    #pragma hls_pipeline_init_interval 1
    #pragma pipeline_stallt_mode flush
                for (uint32_t i = 0; i < len1; i += DMA_WORD_PER_BEAT) {
                    // DMA_WORD dataBv;
                    DMA_WORD dataBv = dma_read_chnl.Pop();


    #pragma hls_unroll yes
                    for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++) {
                        ac_int<DATA_WIDTH> dataBv_int = dataBv.slc<DATA_WIDTH>(k * DATA_WIDTH);

                        if (ping_pong)
                            plm_in_ping[k][i/DMA_WORD_PER_BEAT] = dataBv_int;
                        else
                            plm_in_pong[k][i/DMA_WORD_PER_BEAT] = dataBv_int;

                    }
                }
#endif
                sync12.sync_out();
                ping_pong = !ping_pong;
            }
        }
    }
}

void acc_full_name::compute()
{

    bool ping_pong = false;
    bool out_ping_pong = false;
    sync12.reset_sync_in();
    sync23.reset_sync_out();
    sync02.ResetRead();

    conf2.ResetRead();

    wait();

    while (1) {

        sync02.Pop();

        conf_info_t conf = conf2.Pop();

        /* <<--local-params-->> */

        // Batching
        for (uint16_t b = 0; b < /* <<--number of transfers-->> */; b++) {
            wait();

            uint32_t in_length = /* <<--data_in_size-->> */;


            // Chunking
            for (int in_rem = in_length; in_rem > 0; in_rem -= PLM_IN_WORD) {

                uint32_t in_len = in_rem > PLM_IN_WORD ? PLM_IN_WORD : in_rem;

                sync12.sync_in();

                // Compute Kernel
                uint32_t vec_num=0;
                uint32_t vec_idx=0;


                for (uint32_t i=0; i < in_len; i+=1) {

                    FPDATA_WORD op;

#if (DMA_WORD_PER_BEAT <= 1)
                    if (ping_pong)
                        op=plm_in_ping[0][i];
                    else
                        op=plm_in_pong[0][i];

                    if (i < mac_vec)
                        if (out_ping_pong)
                            plm_out_ping[0][i] = op;
                        else
                            plm_out_pong[0][i] = op;
#else //(DMA_WORD_PER_BEAT == 2)

                    if (ping_pong)
                        op=plm_in_ping[vec_idx][vec_num];
                    else
                        op=plm_in_pong[vec_idx][vec_num];

                    if (vec_num < /* <<--data_out_size-->> */ /DMA_WORD_PER_BEAT)
                        if (out_ping_pong)
                            plm_out_ping[vec_idx][vec_num] = op;
                        else
                            plm_out_pong[vec_idx][vec_num] = op;

                    vec_idx = (vec_idx+1) % DMA_WORD_PER_BEAT;
                    vec_num = vec_idx==0 ? vec_num+1 : vec_num;
#endif

                }
                // End Compute Kernel

                sync23.sync_out();
                ping_pong = !ping_pong;
            }

            out_ping_pong = !out_ping_pong;
        }
    }
}

void acc_full_name::store()
{

    bool ping_pong = false;
    dma_write_chnl.Reset();
    dma_write_ctrl.Reset();

    sync23.reset_sync_in();

    sync03.ResetRead();
    conf3.ResetRead();

    acc_done.write(false);

    wait();

    while (1) {

        sync03.Pop();

        conf_info_t conf = conf3.Pop();

        /* <<--local-params-->> */

#if (DMA_WORD_PER_BEAT == 0)
        uint32_t store_offset = /* <<--data_in_size-->> */ */* <<--number of transfers-->> */;
        uint32_t length = /* <<--data_out_size-->> */;
#else
        uint32_t store_offset = round_up(/* <<--data_in_size-->> */, DMA_WORD_PER_BEAT) */* <<--number of transfers-->> */;
        uint32_t length = round_up(/* <<--data_out_size-->> */, DMA_WORD_PER_BEAT);
#endif

        uint32_t offset = store_offset;

        // Batching
        for (uint16_t b = 0; b < /* <<--number of transfers-->> */; b++) {
            wait();
            // Chunking
            for (int rem = length; rem > 0; rem -= PLM_OUT_WORD) {

                sync23.sync_in();

                uint32_t len = rem > PLM_OUT_WORD ? PLM_OUT_WORD : rem;

#if (DMA_WORD_PER_BEAT == 0)
                dma_info_t dma_info(offset * DMA_BEAT_PER_WORD, len * DMA_BEAT_PER_WORD, DMA_SIZE,
                                    0);
#else
                dma_info_t dma_info(offset / DMA_WORD_PER_BEAT, len / DMA_WORD_PER_BEAT, DMA_SIZE,
                                    0);
#endif
                offset += len;

                dma_write_ctrl.Push(dma_info);
//
#if (DMA_WORD_PER_BEAT == 0)
    #pragma hls_pipeline_init_interval 1
    #pragma pipeline_stall_mode stall
                for (uint32_t i = 0; i < len; i++) {
                    FPDATA_WORD dataBv;

                    if (ping_pong)
                        dataBv = plm_out_ping[0][i];
                    else
                        dataBv = plm_out_pong[0][i];

    #pragma hls_pipeline_init_interval 1
    #pragma pipeline_stall_mode flush
                    for (uint16_t k = 0; k < DMA_BEAT_PER_WORD; k++) {
                        dma_write_chnl.Push(dataBv.slc<DMA_WIDTH>(k * DMA_WIDTH));
                    }
                }

#else
#pragma hls_pipeline_init_interval 1
#pragma pipeline_stall_mode stall
                uint32_t out_idx=0;
                for (uint32_t i = 0; i < len; i += DMA_WORD_PER_BEAT) {
                    FPDATA_WORD dataBv_int;
                    DMA_WORD dataBv;

                    for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++) {
                        if (ping_pong)
                            dataBv_int = plm_out_ping[k][out_idx];
                        else
                            dataBv_int = plm_out_pong[k][out_idx];

                        dataBv.set_slc(k * DATA_WIDTH, dataBv_int);
                    }

                    dma_write_chnl.Push(dataBv);
                    out_idx++;
                }

#endif
            }
            ping_pong = !ping_pong;
        }
        wait();

        acc_done.write(true);
        wait();
        acc_done.write(false);
    }
}
