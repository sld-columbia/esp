// Copyright (c) 2011-2024 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __TOP_H__
#define __TOP_H__

#pragma once

#include <systemc.h>
#include <nvhls_int.h>
#include <nvhls_connections.h>
#include <string>
#include <mc_scverify.h>

#include "leakyrelu_data_types.h"
#include "leakyrelu_specs.h"
#include "leakyrelu_conf_info.h"

#include "leakyrelu_cfg.h"
#include "leakyrelu_ctrl.h"
#include "leakyrelu_com.h"

SC_MODULE(leakyrelu_sysc_catapult)
{
    public:
    sc_in<bool>     CCS_INIT_S1(clk);
    sc_in<bool>     CCS_INIT_S1(rst);
    sc_out<bool>    CCS_INIT_S1(acc_done);

    Connections::In<conf_info_t >           CCS_INIT_S1(conf_info);
    Connections::In< ac_int<DMA_WIDTH> >    CCS_INIT_S1(dma_read_chnl);
    Connections::Out< ac_int<DMA_WIDTH> >   CCS_INIT_S1(dma_write_chnl);
    Connections::Out<dma_info_t>            CCS_INIT_S1(dma_read_ctrl);
    Connections::Out<dma_info_t>            CCS_INIT_S1(dma_write_ctrl);

    Connections::Combinational<conf_info_t >  CCS_INIT_S1(conf_info_ctrl_dma2acc);
    Connections::Combinational<conf_info_t >  CCS_INIT_S1(conf_info_ctrl_plm2vec);
    Connections::Combinational<conf_info_t >  CCS_INIT_S1(conf_info_ctrl_acc2dma);
	Connections::Combinational <array_t<FPDATA, VEC_LEN>> CCS_INIT_S1(vec_in_a);
	Connections::Combinational <array_t<FPDATA, VEC_LEN>> CCS_INIT_S1(vec_in_b);
	Connections::Combinational <array_t<FPDATA, VEC_LEN>> CCS_INIT_S1(vec_out);

    LeakyreluConfig        cfg_inst;
    LeakyreluEngine        vec_inst;
    LeakyreluController    ctrl_inst;

    SC_HAS_PROCESS(leakyrelu_sysc_catapult);
    leakyrelu_sysc_catapult(const sc_module_name& name):
        sc_module(name),
        conf_info("conf_info"),
        dma_read_chnl("dma_read_chnl"),
        dma_write_chnl("dma_write_chnl"),
        dma_read_ctrl("dma_read_ctrl"),
        dma_write_ctrl("dma_write_ctrl"),
        cfg_inst("cfg_inst"),
        vec_inst("vec_inst"),
        ctrl_inst("ctrl_inst")
    {

        cfg_inst.clk(clk);
        cfg_inst.rst(rst);
        cfg_inst.conf_info(conf_info);
        cfg_inst.conf_info_ctrl_dma2acc(conf_info_ctrl_dma2acc);
        cfg_inst.conf_info_ctrl_plm2vec(conf_info_ctrl_plm2vec);
        cfg_inst.conf_info_ctrl_acc2dma(conf_info_ctrl_acc2dma);

        ctrl_inst.clk(clk);
        ctrl_inst.rst(rst);
        ctrl_inst.dma_read_chnl(dma_read_chnl);
        ctrl_inst.dma_write_chnl(dma_write_chnl);
        ctrl_inst.dma_read_ctrl(dma_read_ctrl);
        ctrl_inst.dma_write_ctrl(dma_write_ctrl);
        ctrl_inst.conf_info_ctrl_dma2acc(conf_info_ctrl_dma2acc);
        ctrl_inst.conf_info_ctrl_plm2vec(conf_info_ctrl_plm2vec);
        ctrl_inst.conf_info_ctrl_acc2dma(conf_info_ctrl_acc2dma);
        ctrl_inst.vec_in_a(vec_in_a);
        ctrl_inst.vec_in_b(vec_in_b);
        ctrl_inst.vec_out(vec_out);
        ctrl_inst.acc_done(acc_done);

        vec_inst.clk(clk);
        vec_inst.rst(rst);
        vec_inst.vec_in_a(vec_in_a);
        vec_inst.vec_in_b(vec_in_b);
        vec_inst.vec_out(vec_out);
    }
};

#endif
