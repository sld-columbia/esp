// Copyright (c) 2011-2024 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __LEAKY_CTRL_H__
#define __LEAKY_CTRL_H__

#pragma once

#include <systemc.h>
#include <nvhls_int.h>
#include <nvhls_connections.h>
#include <string>
#include <mc_scverify.h>

#include "ac_shared_bank_array.h"

#include "../inc/leakyrelu_data_types.h"
#include "../inc/leakyrelu_specs.h"
#include "../inc/leakyrelu_conf_info.h"

SC_MODULE(LeakyreluController)
{
    public:
    sc_in<bool>     CCS_INIT_S1(clk);
    sc_in<bool>     CCS_INIT_S1(rst);

    sc_out<bool>    CCS_INIT_S1(acc_done);
    Connections::In< ac_int<DMA_WIDTH> >    CCS_INIT_S1(dma_read_chnl);
    Connections::Out< ac_int<DMA_WIDTH> >   CCS_INIT_S1(dma_write_chnl);
    Connections::Out<dma_info_t>            CCS_INIT_S1(dma_read_ctrl);
    Connections::Out<dma_info_t>            CCS_INIT_S1(dma_write_ctrl);

	Connections::In <conf_info_t>               CCS_INIT_S1(conf_info_ctrl_dma2acc);
	Connections::In <conf_info_t>               CCS_INIT_S1(conf_info_ctrl_plm2vec);
	Connections::In <conf_info_t>               CCS_INIT_S1(conf_info_ctrl_acc2dma);
	Connections::Out <array_t<FPDATA, VEC_LEN>> CCS_INIT_S1(vec_in_a);
	Connections::Out <array_t<FPDATA, VEC_LEN>> CCS_INIT_S1(vec_in_b);
	Connections::In <array_t<FPDATA, VEC_LEN>>  CCS_INIT_S1(vec_out);

    Connections::Combinational<int32_t> ld2com_sync;
    Connections::Combinational<int32_t> com2st_sync;

    ac_shared_bank_array_2D<DATA_TYPE, bks, ebks> plm_a_ping;
    ac_shared_bank_array_2D<DATA_TYPE, bks, ebks> plm_b_ping;
	ac_shared_bank_array_2D<DATA_TYPE, bks, ebks> plm_o_ping;

    SC_HAS_PROCESS(LeakyreluController);
    LeakyreluController(const sc_module_name& name) : 
        sc_module(name),
        acc_done("acc_done"),
        dma_read_chnl("dma_read_chnl"),
        dma_write_chnl("dma_write_chnl"),
        dma_read_ctrl("dma_read_ctrl"),
        dma_write_ctrl("dma_write_ctrl")
    {
        SC_THREAD(dma2acc);
        sensitive << clk.pos();
        async_reset_signal_is(rst, false);

        SC_THREAD(plm2vec);
        sensitive << clk.pos();
        async_reset_signal_is(rst, false);
        
        SC_THREAD(acc2dma);
        sensitive << clk.pos();
        async_reset_signal_is(rst, false);
    }

    void dma2acc() {
        dma_read_chnl.Reset();
        dma_read_ctrl.Reset();
    
        conf_info_ctrl_dma2acc.Reset();
        
        ld2com_sync.ResetWrite();
        
        wait();
        while(1)
        {
            conf_info_t conf_reg = conf_info_ctrl_dma2acc.Pop();
            int32_t batch = conf_reg.batch;
            int32_t row = conf_reg.row;
            int32_t addrA = conf_reg.addrA;
            int32_t addrB = conf_reg.addrB;

            load(addrA, batch*row*VEC_LEN, plm_a_ping, true);
            load(addrB, batch*row*VEC_LEN, plm_b_ping, true);

            ld2com_sync.Push(1);  
        }   
    }
    
    template <typename SharedArray2D>
    void load(uint32_t base_addr, uint32_t size, SharedArray2D& plm, bool ping)
    {
        uint32_t len = round_up(size, DMA_WORD_PER_BEAT);
        
        //fprintf(stderr, "  ctrl_inst: dma2acc load size %d\n", len);

        for (int rem = len; rem > 0;) {
            uint32_t beats = (rem < PLM_WORD) ? rem : PLM_WORD;
            dma_info_t dma_info(base_addr / DMA_WORD_PER_BEAT, beats / DMA_WORD_PER_BEAT, DMA_SIZE, 0);
            dma_read_ctrl.Push(dma_info);
    
            for (uint32_t i = 0; i < beats; i += VEC_LEN) {
                for (uint32_t j = 0; j < VEC_DMA_RATIO; j++) {
                    ac_int<DMA_WIDTH> data_dma = dma_read_chnl.Pop();
    
                    #pragma hls_unroll yes
                    for (uint32_t k = 0; k < DMA_WORD_PER_BEAT; k++) {
                        uint32_t bank = DMA_WORD_PER_BEAT * j + k;
                        uint32_t addr = i / VEC_LEN;
                        plm[bank][addr] = data_dma.slc<DATA_WIDTH>(k * DATA_WIDTH);
                    }
                }
            }
            rem -= beats;
        }
        wait();
    }

    void plm2vec()
    {
        conf_info_ctrl_plm2vec.Reset();
        
        ld2com_sync.ResetRead();
        com2st_sync.ResetWrite();
        
        vec_in_a.Reset();
        vec_in_b.Reset();
        vec_out.Reset();
        
        wait();
        while(1)
        {
            conf_info_t conf_reg = conf_info_ctrl_plm2vec.Pop();

            int32_t batch = conf_reg.batch;
            int32_t row = conf_reg.row;
            //fprintf(stderr, "  ctrl_inst: plm2vec batch %d row %d\n", batch, row);

            ld2com_sync.Pop();       // wait for dma2acc

            for (int b=0; b<batch; b++){
                for (int r=0; r<row; r++){
    
                    int a_addr, a_bank;
                    int b_addr, b_bank;
    
                    FPDATA_WORD a_word[VEC_LEN], b_word[VEC_LEN];
                    FPDATA a_buf[VEC_LEN], b_buf[VEC_LEN];
                    array_t<FPDATA, VEC_LEN> in_a_itcn, in_b_itcn;
                    
                #pragma hls_unroll yes
                    for (int vec=0; vec<VEC_LEN; vec++){
                        a_addr = row*b + r;
                        a_bank = vec;
                        b_addr = row*b + r;
                        b_bank = vec;
                        
                        a_word[vec] = plm_a_ping[a_bank][a_addr];
                        b_word[vec] = plm_b_ping[b_bank][b_addr];
    
                    #ifdef FL_POINT
                        int2f(a_word[vec], a_buf[vec]);
                        int2f(b_word[vec], b_buf[vec]);
                    #else
                        int2fx(a_word[vec], a_buf[vec]);
                        int2fx(b_word[vec], b_buf[vec]);
                    #endif
    
                        in_a_itcn.data[vec] = a_buf[vec];
                        in_b_itcn.data[vec] = b_buf[vec];
                    }
                    vec_in_a.Push(in_a_itcn);
                    vec_in_b.Push(in_b_itcn);
                    
                    
                    FPDATA_WORD out_word[VEC_LEN];
                    FPDATA out[VEC_LEN];
                    array_t<FPDATA, VEC_LEN> out_itcn;
                    out_itcn = vec_out.Pop();
                    
                    int out_addr, out_bank;
                #pragma hls_unroll yes
                    for (int vec=0; vec<VEC_LEN; vec++){
                        out[vec] = out_itcn.data[vec];
                    #ifdef FL_POINT
                        f2int(out[vec], out_word[vec]);
                    #else
                        fx2int(out[vec], out_word[vec]);
                    #endif
    
                        out_addr = row*b + r;
                        out_bank = vec;

                        plm_o_ping[out_bank][out_addr] = out_word[vec];
                    }
                }
            }
            com2st_sync.Push(1);  
        }
    }


    void acc2dma()
    {
        dma_write_chnl.Reset();
        dma_write_ctrl.Reset();

        conf_info_ctrl_acc2dma.Reset();

        com2st_sync.ResetRead();
        acc_done.write(false);

        wait();
        while (1)
        {
            conf_info_t conf_reg = conf_info_ctrl_acc2dma.Pop();

            int32_t batch = conf_reg.batch;
            int32_t row = conf_reg.row;
            int32_t addrO = conf_reg.addrO;

            uint32_t mem_offset = addrO;

            com2st_sync.Pop();

        #if (DMA_WORD_PER_BEAT == 0)
            uint32_t len = batch*row*VEC_LEN;
        #else
            uint32_t len = round_up(batch*row*VEC_LEN, DMA_WORD_PER_BEAT);
        #endif

            //fprintf(stderr, "  ctrl_inst: acc2dma store size %d\n", len);

            for (int rem=len; rem>0; )
            {
                uint32_t beats = (rem < PLM_WORD) ? rem : PLM_WORD;
            #if (DMA_WORD_PER_BEAT == 0)
                dma_info_t dma_info(mem_offset * DMA_BEAT_PER_WORD, beats * DMA_BEAT_PER_WORD, DMA_SIZE, 0);
            #else
                dma_info_t dma_info(mem_offset / DMA_WORD_PER_BEAT, beats / DMA_WORD_PER_BEAT, DMA_SIZE, 0);
            #endif
                dma_write_ctrl.Push(dma_info);
        
            #if (DMA_WORD_PER_BEAT == 0)
                #pragma hls_pipeline_init_interval 1
                #pragma pipeline_stall_mode flush
                for (uint32_t i=0; i<beats; i++)
                {
                    ac_int<DATA_WIDTH> dataBV;
                }
            #else
                #pragma hls_pipeline_init_interval 1
                #pragma pipeline_stall_mode flush
                for (uint32_t i=0; i<beats; i+=VEC_LEN)
                {
                    for (uint32_t j=0; j<VEC_DMA_RATIO; j++)
                    {
                        ac_int<DMA_WIDTH> dataBV;

                    #pragma hls_unroll yes
                        for (uint32_t k=0; k<DMA_WORD_PER_BEAT; k++)
                        {
                            uint32_t bank = DMA_WORD_PER_BEAT*j+k;
                            uint32_t addr = i/VEC_LEN;
                            
                            dataBV.set_slc(k*DATA_WIDTH, plm_o_ping[bank][addr]);
                        }
                        dma_write_chnl.Push(dataBV);
                    }
                }
            #endif
                rem -= beats;
            }
            acc_done.write(true); wait();
            acc_done.write(false);
        }
    }
};

#endif
