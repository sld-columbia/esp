//Copyright (c) 2011-2024 Columbia University, System Level Design Group
//SPDX-License-Identifier: Apache-2.0

#ifndef __TESTBENCH_HPP__
#define __TESTBENCH_HPP__

#pragma once

#include <systemc.h>
#include "leakyrelu_conf_info.h"
#include "leakyrelu_specs.h"
#include "leakyrelu_data_types.h"
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

        SC_THREAD(kernel_processing);
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
        batch = 4;
        row = 2;
    }

    void kernel_processing(void);

    conf_info_t load_config(void);
    void compile_config(void);
    void load_memory(float *file_arr, uint32_t base_addr, uint32_t size);
    void generate_data(void);
    void pv_leaky_relu(float *in_a, float*in_b, float *out);
    void validate_kernel(void);

    // Accelerator-specific data
    /* <<--params-->> */
    uint32_t batch;
    uint32_t row;
    uint32_t addrA, addrB, addrO;
    uint32_t sw_in_a_size, sw_in_b_size, sw_out_size;
    uint32_t in_a_size, in_b_size, out_size;

    float* in_a;
    float* in_b;
    ac_int<DATA_WIDTH,false> *acc_out ;
};

#endif

