//Copyright (c) 2011-2023 Columbia University, System Level Design Group
//SPDX-License-Identifier: Apache-2.0

#ifndef __TESTBENCH_HPP__
#define __TESTBENCH_HPP__

#pragma once

#include <systemc.h>
#include "<accelerator_name>_conf_info.hpp"
#include "<accelerator_name>_specs.hpp"
#include "<accelerator_name>_data_types.hpp"
#include "esp_dma_info_sysc.hpp"
#include "esp_dma_controller.hpp"

#define __round_mask(x, y) ((y)-1)
#define round_up(x, y) ((((x)-1) | __round_mask(x, y))+1)

SC_MODULE(testbench)
{
    sc_in<bool> CCS_INIT_S1(clk);
    sc_in<bool> CCS_INIT_S1(rst_bar);

    Connections::Out<conf_info_t>        CCS_INIT_S1(conf_info);
    Connections::Out<ac_int<DMA_WIDTH>>       CCS_INIT_S1(dma_read_chnl);
    Connections::In<ac_int<DMA_WIDTH>>        CCS_INIT_S1(dma_write_chnl);
    Connections::In<dma_info_t >        CCS_INIT_S1(dma_read_ctrl);
    Connections::In<dma_info_t >        CCS_INIT_S1(dma_write_ctrl);
    sc_in<bool>     CCS_INIT_S1(acc_done);

    sc_signal<bool> acc_rst;

    // Shared memory buffer model
    ac_int<DMA_WIDTH> *mem;

    // DMA controller instace
    esp_dma_controller<DMA_WIDTH, MEM_SIZE > *dmac;

    // SC_CTOR(testbench) {
    SC_HAS_PROCESS(testbench);
    testbench(const sc_module_name& name):
        sc_module(name)
        , mem(new ac_int<DMA_WIDTH>[MEM_SIZE])
        , dmac(new esp_dma_controller<DMA_WIDTH, MEM_SIZE>("dma-controller", mem))
    {

        SC_THREAD(proc);
        sensitive << clk.pos();
        async_reset_signal_is(rst_bar, false);

        dmac->clk(clk);
        dmac->rst(rst_bar);
        dmac->dma_read_ctrl(dma_read_ctrl);
        dmac->dma_read_chnl(dma_read_chnl);
        dmac->dma_write_ctrl(dma_write_ctrl);
        dmac->dma_write_chnl(dma_write_chnl);
        dmac->acc_done(acc_done);
        dmac->acc_rst(acc_rst);

        /* <<--params-default-->> */

    }

    void proc(void);
    // Accelerator-specific data
    /* <<--params-->> */


    uint32_t in_words_adj;
    uint32_t out_words_adj;
    uint32_t in_size;
    uint32_t out_size;
    ac_int<DATA_WIDTH,false> *in;
    ac_int<DATA_WIDTH,false> *out;
    ac_int<DATA_WIDTH,false> *gold ; // all DATA_WIDTH


};

#endif

