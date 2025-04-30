// Copyright (c) 2011-2025 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __TOP_HPP__
#define __TOP_HPP__

#pragma once

#include "./DataPath.h"
#include "./Ctrl.h"

#include "macfin3_data_types.h"
#include "macfin3_specs.h"
#include "macfin3_conf_info.h"
#include "ac_shared_bank_array.h"


#define __round_mask(x, y) ((y)-1)
#define round_up(x, y)     ((((x)-1) | __round_mask(x, y)) + 1)

SC_MODULE(macfin3_sysc_catapult)
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

    Connections::Combinational<conf_info_t> CCS_INIT_S1(conf_info_intra);
    Connections::Combinational<bool> CCS_INIT_S1(sync00);
    Connections::Combinational<FPDATA_WORD> CCS_INIT_S1(in_wr_req);
    Connections::Combinational<read_data> CCS_INIT_S1(in_rd_rsp);
    // Connections::Combinational<FPDATA_WORD> CCS_INIT_S1(out_wr_req);

    Ctrl CCS_INIT_S1(Controller);
    DataPath CCS_INIT_S1(DataPath_inst);

    SC_CTOR(macfin3_sysc_catapult)
    {

        Controller.clk(clk);
        Controller.rst(rst);
        Controller.acc_done(acc_done);
        Controller.conf_info(conf_info);
        Controller.dma_read_chnl(dma_read_chnl);
        Controller.dma_write_chnl(dma_write_chnl);
        Controller.dma_read_ctrl(dma_read_ctrl);
        Controller.dma_write_ctrl(dma_write_ctrl);
        Controller.conf_info_out(conf_info_intra);
        Controller.sync00(sync00);
        Controller.in_wr_req(in_wr_req);
        Controller.in_rd_rsp(in_rd_rsp);
        // Controller.out_wr_req(out_wr_req);

        DataPath_inst.clk(clk);
        DataPath_inst.rst(rst);
        DataPath_inst.conf_info_in(conf_info_intra);
        DataPath_inst.sync00(sync00);
        DataPath_inst.in_wr_req(in_wr_req);
        DataPath_inst.in_rd_rsp(in_rd_rsp);
        // DataPath_inst.out_wr_req(out_wr_req);

    }

    // Connections::SyncChannel CCS_INIT_S1(sync12);
    // Connections::SyncChannel CCS_INIT_S1(sync23);

    // Connections::Combinational<bool> CCS_INIT_S1(sync01);
    // Connections::Combinational<bool> CCS_INIT_S1(sync02);
    // Connections::Combinational<bool> CCS_INIT_S1(sync03);

    // Connections::Combinational<conf_info_t> CCS_INIT_S1(conf1);
    // Connections::Combinational<conf_info_t> CCS_INIT_S1(conf2);
    // Connections::Combinational<conf_info_t> CCS_INIT_S1(conf3);


    // ac_shared_bank_array_2D<FPDATA_WORD, inbks, inebks> plm_in_ping;
    // ac_shared_bank_array_2D<FPDATA_WORD, inbks, inebks> plm_in_pong;

    // ac_shared_bank_array_2D<FPDATA_WORD, outbks, outebks> plm_out_ping;
    // ac_shared_bank_array_2D<FPDATA_WORD, outbks, outebks> plm_out_pong;

};




#endif
