// Copyright (c) 2011-2025 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __TOP_HPP__
#define __TOP_HPP__

#pragma once

#include "accelerator_name_data_types.hpp"
#include "accelerator_name_specs.hpp"
#include "accelerator_name_conf_info.hpp"
#include "ac_shared_bank_array.h"


#define __round_mask(x, y) ((y)-1)
#define round_up(x, y)     ((((x)-1) | __round_mask(x, y)) + 1)

SC_MODULE(acc_full_name)
{
  public:
    sc_in<bool> CCS_INIT_S1(clk);
    sc_in<bool> CCS_INIT_S1(rst);
    sc_out<bool> CCS_INIT_S1(acc_done);

    Connections::In<conf_info_t> CCS_INIT_S1(conf_info);
    Connections::In<ac_int<DMA_WIDTH>> CCS_INIT_S1(dma_read_chnl);
    Connections::Out<ac_int<DMA_WIDTH>> CCS_INIT_S1(dma_write_chnl);
    Connections::Out<dma_info_t> CCS_INIT_S1(dma_read_ctrl);
    Connections::Out<dma_info_t> CCS_INIT_S1(dma_write_ctrl);

    void config(void);
    void load(void);
    void compute(void);
    void store(void);

    SC_CTOR(acc_full_name)
    {

        SC_THREAD(config);
        sensitive << clk.pos();
        async_reset_signal_is(rst, false);

        SC_THREAD(load);
        sensitive << clk.pos();
        async_reset_signal_is(rst, false);

        SC_THREAD(compute);
        sensitive << clk.pos();
        async_reset_signal_is(rst, false);

        SC_THREAD(store);
        sensitive << clk.pos();
        async_reset_signal_is(rst, false);

    }

    Connections::SyncChannel CCS_INIT_S1(sync12);
    Connections::SyncChannel CCS_INIT_S1(sync23);

    Connections::Combinational<bool> CCS_INIT_S1(sync01);
    Connections::Combinational<bool> CCS_INIT_S1(sync02);
    Connections::Combinational<bool> CCS_INIT_S1(sync03);

    Connections::Combinational<conf_info_t> CCS_INIT_S1(conf1);
    Connections::Combinational<conf_info_t> CCS_INIT_S1(conf2);
    Connections::Combinational<conf_info_t> CCS_INIT_S1(conf3);


    ac_shared_bank_array_2D<FPDATA_WORD, inbks, inebks> plm_in_ping;
    ac_shared_bank_array_2D<FPDATA_WORD, inbks, inebks> plm_in_pong;

    ac_shared_bank_array_2D<FPDATA_WORD, outbks, outebks> plm_out_ping;
    ac_shared_bank_array_2D<FPDATA_WORD, outbks, outebks> plm_out_pong;

//
};

#endif
