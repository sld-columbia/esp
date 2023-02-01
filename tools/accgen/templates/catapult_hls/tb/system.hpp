//Copyright (c) 2011-2023 Columbia University, System Level Design Group
//SPDX-License-Identifier: Apache-2.0

#ifndef __SYSTEM_T_HPP__
#define __SYSTEM_T_HPP__

#pragma once

#include "<accelerator_name>_data_types.hpp"
#include "<accelerator_name>_specs.hpp"
#include "<accelerator_name>_conf_info.hpp"
#include "esp_dma_info_sysc.hpp"
#include "esp_dma_controller.hpp"
#include "testbench.hpp"
#include "<accelerator_name>.hpp"
#include <mc_scverify.h>

SC_MODULE(system_t)
{
  sc_clock        clk;
  sc_signal<bool> CCS_INIT_S1(rst);

  testbench testbench_inst;

  CCS_DESIGN(<acc_full_name>) CCS_INIT_S1(acc);

  Connections::Combinational<ac_int<DMA_WIDTH>>        CCS_INIT_S1(dma_read_chnl);
  Connections::Combinational<ac_int<DMA_WIDTH>>        CCS_INIT_S1(dma_write_chnl);
  Connections::Combinational<dma_info_t>        CCS_INIT_S1(dma_read_ctrl);
  Connections::Combinational<dma_info_t>        CCS_INIT_S1(dma_write_ctrl);
  Connections::Combinational<conf_info_t>        CCS_INIT_S1(conf_info);
  sc_signal<bool>        CCS_INIT_S1(acc_done);

  SC_HAS_PROCESS(system_t);
  system_t(const sc_module_name& name) :
      sc_module (name)
      ,clk("clk", 5.00, SC_NS, 0.5, 0, SC_NS, true)
      ,testbench_inst("testbench_inst") {

      Connections::set_sim_clk(&clk);
      sc_object_tracer<sc_clock> trace_clk(clk);

      testbench_inst.clk(clk);
      testbench_inst.rst_bar(rst);
      testbench_inst.conf_info(conf_info);
      testbench_inst.dma_read_chnl(dma_read_chnl);
      testbench_inst.dma_write_chnl(dma_write_chnl);
      testbench_inst.dma_read_ctrl(dma_read_ctrl);
      testbench_inst.dma_write_ctrl(dma_write_ctrl);
      testbench_inst.acc_done(acc_done);

      acc.clk(clk);
      acc.rst(rst);
      acc.conf_info(conf_info);
      acc.dma_read_chnl(dma_read_chnl);
      acc.dma_write_chnl(dma_write_chnl);
      acc.dma_read_ctrl(dma_read_ctrl);
      acc.dma_write_ctrl(dma_write_ctrl);
      acc.acc_done(acc_done);

      SC_THREAD(reset);
    }

    void reset() {
        rst.write(0);
        wait(50, SC_NS);                        // WAIT
        rst.write(1);
    }
};

#endif
