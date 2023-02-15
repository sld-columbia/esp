//Copyright (c) 2011-2023 Columbia University, System Level Design Group
//SPDX-License-Identifier: Apache-2.0

#include "<accelerator_name>.hpp"
#include <mc_scverify.h>

void <acc_full_name>:: config() {
    conf_info.Reset();
    conf1.ResetWrite();
    conf2.ResetWrite();
    conf2b.ResetWrite();
    conf3.ResetWrite();
    conf3b.ResetWrite();

    sync01.ResetWrite();
    sync02.ResetWrite();
    sync02b.ResetWrite();
    sync03.ResetWrite();
    sync03b.ResetWrite();

    wait();

    while(1) {
        conf_info_t conf_di = conf_info.Pop();

        conf1.Push(conf_di);
        conf2.Push(conf_di);
        conf2b.Push(conf_di);
        conf3.Push(conf_di);
        conf3b.Push(conf_di);

        sync01.Push(1);
        sync02.Push(1);
        sync02b.Push(1);
        sync03.Push(1);
        sync03b.Push(1);

    }
}



void <acc_full_name>:: load() {
    bool ping_pong = false;
    dma_read_chnl.Reset();
    dma_read_ctrl.Reset();

    sync01.ResetRead();
    sync12.reset_sync_out();
    sync12b.reset_sync_out();

    conf1.ResetRead();

    in_ping_w.ResetWrite();
    in_pong_w.ResetWrite();

    wait();

    while(1) {
        sync01.Pop();

        bool ping = true;
        uint32_t offset = 0;

        conf_info_t conf=conf1.Pop();

        /* <<--local-params-->> */

        // Batching
        for (uint16_t b = 0; b < /* <<--number of transfers-->> */; b++)
        {
            wait();

#if (DMA_WORD_PER_BEAT == 0)
            uint32_t len = /* <<--data_in_size-->> */;
#else
            uint32_t len=round_up(/* <<--data_in_size-->> */, DMA_WORD_PER_BEAT);
#endif
            // Chunking
            for (int rem = len; rem > 0; rem -= PLM_IN_WORD)
            {
                uint32_t len1 = rem > PLM_IN_WORD ? PLM_IN_WORD : rem;

#if (DMA_WORD_PER_BEAT == 0)
                dma_info_t dma_info(offset * DMA_BEAT_PER_WORD, len1 * DMA_BEAT_PER_WORD, DMA_SIZE);
#else
                dma_info_t dma_info(offset / DMA_WORD_PER_BEAT, len1 / DMA_WORD_PER_BEAT, DMA_SIZE);
#endif

                offset +=len1;

                dma_read_ctrl.Push(dma_info);

#if (DMA_WORD_PER_BEAT == 0)
                #pragma hls_pipeline_init_interval 1
                #pragma pipeline_stallt_mode flush
                for (uint32_t i =0; i < len1; i++)
                {
                    ac_int<DATA_WIDTH> dataBv;

                    #pragma hls_pipeline_init_interval 1
                    #pragma pipeline_stallt_mode flush
                    for (uint32_t k=0; k< DMA_BEAT_PER_WORD; k++)
                    {
                        ac_int<DMA_WIDTH> data_m=dma_read_chnl.Pop();
                        dataBv.set_slc(k*DMA_WIDTH, data_m);
                    }

                    plm_WR<in_as,inwp> wreq;
                    wreq.indx[0]=i;
                    wreq.data[0]=dataBv;

                    if (ping_pong)
                        in_ping_w.Push(wreq);
                    else
                        in_pong_w.Push(wreq);
                }
#else
                #pragma hls_pipeline_init_interval 1
                #pragma pipeline_stallt_mode flush
                for (uint32_t i=0; i < len1; i+= DMA_WORD_PER_BEAT) {
                    DMA_WORD data_dma=dma_read_chnl.Pop();

                    plm_WR<in_as,inwp> wreq;

                    #pragma hls_unroll yes
                    for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++)
                    {
                        wreq.indx[k]=i+k;
                        wreq.data[k]=data_dma.slc<DATA_WIDTH>(k * DATA_WIDTH);
                    }
                    if (ping_pong)
                        in_ping_w.Push(wreq);
                    else
                        in_pong_w.Push(wreq);
                }

#endif

                sync12.sync_out();
                sync12b.sync_out();

                ping_pong = !ping_pong;
            }
        }
    }
}

void <acc_full_name>::compute_dataReq() {

    bool ping_pong = false;
    sync12.reset_sync_in();
    sync23.reset_sync_out();
    sync23b.reset_sync_out();

    sync02.ResetRead();
    conf2.ResetRead();

    in_ping_ra.ResetWrite();
    in_pong_ra.ResetWrite();

    wait();

    while(1) {

        sync02.Pop();

        conf_info_t conf=conf2.Pop();

        /* <<--local-params-->> */

        // Batching
        for (uint16_t b = 0; b < /* <<--number of transfers-->> */; b++)
        {
            wait();

            // Chunking
            for (int in_rem = /* <<--data_in_size-->> */ ; in_rem > 0; in_rem -= PLM_IN_WORD)
            {

                uint32_t in_len  = in_rem  > PLM_IN_WORD  ? PLM_IN_WORD  : in_rem;

                sync12.sync_in();

                //Send read memory requests to input PLM
                #pragma hls_pipeline_init_interval 1
                #pragma pipeline_stall_mode stall
                for (uint32_t i=0; i < in_len; i++) {

                    wait();

                    FPDATA_WORD op[2];

                    plm_RRq<in_as,inrp> rreq;

                    rreq.indx[0]=i;

                    if (ping_pong)
                        in_ping_ra.Push(rreq);
                    else
                        in_pong_ra.Push(rreq);

                }

                sync23.sync_out();
                sync23b.sync_out();
                ping_pong = !ping_pong;
            }
        }
    }
}

void <acc_full_name>:: compute() {

    bool ping_pong = false;
    bool out_ping_pong = false;
    sync12b.reset_sync_in();
    sync2b3.reset_sync_out();
    sync2b3b.reset_sync_out();

    sync02b.ResetRead();
    conf2b.ResetRead();

    out_ping_w.ResetWrite();
    out_pong_w.ResetWrite();
    in_ping_rd.ResetRead();
    in_pong_rd.ResetRead();

    wait();

    while(1) {

        sync02b.Pop();

        conf_info_t conf=conf2b.Pop();

        /* <<--local-params-->> */

        // Batching
        for (uint16_t b = 0; b < /* <<--number of transfers-->> */; b++)
        {
            wait();

            uint32_t in_length = /* <<--data_in_size-->> */;

            // Chunking
            for (int in_rem = in_length; in_rem > 0; in_rem -= PLM_IN_WORD)
            {

                uint32_t in_len  = in_rem  > PLM_IN_WORD  ? PLM_IN_WORD  : in_rem;

                sync12b.sync_in();

                // Compute Kernel
                for (uint32_t  i=0; i < in_len; i+=1) {

                    FPDATA_WORD op;

                    if (ping_pong)
                        op=in_ping_rd.Pop().data[0];
                    else
                        op=in_pong_rd.Pop().data[0];

                    plm_WR<out_as, outwp> rreq;
                    rreq.indx[0]=i;
                    rreq.data[0]=op;

                    if (i < /* <<--data_out_size-->> */){

                        if (out_ping_pong)
                            out_ping_w.Push(rreq);
                        else
                            out_pong_w.Push(rreq);

                    }
                }
                // End Compute Kernel

                sync2b3.sync_out();
                sync2b3b.sync_out();

                ping_pong = !ping_pong;
            }

            out_ping_pong = !out_ping_pong;
        }
    }
}

void <acc_full_name>:: store_dataReq() {

    bool ping_pong = false;
    sync23.reset_sync_in();
    sync2b3.reset_sync_in();

    sync03.ResetRead();
    conf3.ResetRead();

    out_pong_ra.ResetWrite();
    out_ping_ra.ResetWrite();

    wait();

    while(1) {

        sync03.Pop();

        conf_info_t conf=conf3.Pop();

        /* <<--local-params-->> */

        // Batching
        for (uint16_t b = 0; b < /* <<--number of transfers-->> */; b++)
        {
            wait();

#if (DMA_WORD_PER_BEAT == 0)
            uint32_t length = /* <<--data_out_size-->> */;
#else
            uint32_t length = round_up(/* <<--data_out_size-->> */, DMA_WORD_PER_BEAT);
#endif
            // Chunking
            for (int rem = length; rem > 0; rem -= PLM_OUT_WORD)
            {

                sync23.sync_in();
                sync2b3.sync_in();

                uint32_t len = rem > PLM_OUT_WORD ? PLM_OUT_WORD : rem;

#if (DMA_WORD_PER_BEAT == 0)
                #pragma hls_pipeline_init_interval 1
                #pragma pipeline_stall_mode stall
                for (uint32_t i = 0; i < len; i++)
                {
                    FPDATA_WORD dataBv;
                    plm_RRq<out_as,outrp> rreq;
                    rreq.indx[0]=i;

                    if(ping_pong)
                        out_ping_ra.Push(rreq);
                    else
                        out_pong_ra.Push(rreq);

                }

#else
                #pragma hls_pipeline_init_interval 1
                #pragma pipeline_stall_mode stall
                for (uint32_t i = 0; i < len; i += DMA_WORD_PER_BEAT)
                {
                    DMA_WORD dataBv;

                    plm_RRq<out_as,outrp> rreq;
                    for (int k = 0; k < DMA_WORD_PER_BEAT; k++)
                    {
                        rreq.indx[k]=i+k;
                    }

                    if(ping_pong)
                        out_ping_ra.Push(rreq);
                    else
                        out_pong_ra.Push(rreq);
                }

#endif
            }
            ping_pong = !ping_pong;
        }
    }
}


void <acc_full_name>:: store() {

    bool ping_pong = false;
    dma_write_chnl.Reset();
    dma_write_ctrl.Reset();

    sync23b.reset_sync_in();
    sync2b3b.reset_sync_in();

    sync03b.ResetRead();
    conf3b.ResetRead();

    out_pong_rd.ResetRead();
    out_ping_rd.ResetRead();

    acc_done.write(false);

    wait();

    while(1) {

        sync03b.Pop();

        conf_info_t conf=conf3b.Pop();

        /* <<--local-params-->> */

#if (DMA_WORD_PER_BEAT == 0)
        uint32_t store_offset = /* <<--data_in_size-->> */ *  /* <<--number of transfers-->> */;
#else
        uint32_t store_offset = round_up(/* <<--data_in_size-->> */, DMA_WORD_PER_BEAT) *  /* <<--number of transfers-->> */;
#endif
        uint32_t offset = store_offset;

        // Batching
        for (uint16_t b = 0; b < /* <<--number of transfers-->> */; b++)
        {
            wait();


#if (DMA_WORD_PER_BEAT == 0)
            uint32_t length = /* <<--data_out_size-->> */;
#else
            uint32_t length = round_up(/* <<--data_out_size-->> */, DMA_WORD_PER_BEAT);
#endif
            // Chunking
            for (int rem = length; rem > 0; rem -= PLM_OUT_WORD)
            {

                sync23b.sync_in();
                sync2b3b.sync_in();

                uint32_t len = rem > PLM_OUT_WORD ? PLM_OUT_WORD : rem;
#if (DMA_WORD_PER_BEAT == 0)
                dma_info_t dma_info(offset * DMA_BEAT_PER_WORD, len * DMA_BEAT_PER_WORD, DMA_SIZE);
#else
                dma_info_t dma_info(offset / DMA_WORD_PER_BEAT, len / DMA_WORD_PER_BEAT, DMA_SIZE);
#endif
                offset += len;

                plm_RRs<outrp> rrsp;
                dma_write_ctrl.Push(dma_info);

#if (DMA_WORD_PER_BEAT == 0)
                #pragma hls_pipeline_init_interval 1
                #pragma pipeline_stall_mode stall
                for (uint32_t i = 0; i < len; i++)
                {
                    FPDATA_WORD dataBv;

                    if(ping_pong)
                        dataBv=out_ping_rd.Pop().data[0];
                    else
                        dataBv=out_pong_rd.Pop().data[0];

                    #pragma hls_pipeline_init_interval 1
                    #pragma pipeline_stall_mode flush
                    for (uint16_t k = 0; k < DMA_BEAT_PER_WORD; k++)
                    {
                        dma_write_chnl.Push(dataBv.slc<DMA_WIDTH>(k*DMA_WIDTH));
                    }

                }

#else
                #pragma hls_pipeline_init_interval 1
                #pragma pipeline_stall_mode stall
                for (uint32_t i = 0; i < len; i += DMA_WORD_PER_BEAT)
                {
                    DMA_WORD dataBv;

                    if(ping_pong)
                        rrsp=out_ping_rd.Pop();
                    else
                        rrsp=out_pong_rd.Pop();

                    for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++)
                    {
                        dataBv.set_slc(k *DATA_WIDTH,rrsp.data[k]);
                    }

                    dma_write_chnl.Push(dataBv);
                }

#endif
            }
            ping_pong = !ping_pong;
        }
        wait();

        acc_done.write(true); wait();
        acc_done.write(false);
    }
}



