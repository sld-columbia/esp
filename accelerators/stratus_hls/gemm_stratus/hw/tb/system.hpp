// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __SYSTEM_HPP__
#define __SYSTEM_HPP__

#include "gemm_data.hpp"
#include "fpdata.hpp"
#include "gemm_conf_info.hpp"
#include "gemm_debug_info.hpp"
#include "gemm.hpp"
#include "gemm_directives.hpp"
#include "gemm_pv.h"
#include "esp_templates.hpp"

#include "core/systems/esp_system.hpp"

#ifdef CADENCE
#include "gemm_wrap.h"
#endif

// Testbench constants
#define VERBOSE 1

// Decomment to activate feature

const size_t MEM_SIZE = 50000000;

class system_t : public esp_system<DMA_WIDTH, MEM_SIZE>
{
public:

    // ACC instance
#ifdef CADENCE
    gemm_wrapper *acc;
#else
    gemm *acc;
#endif

    // Constructor
    SC_HAS_PROCESS(system_t);
    system_t(sc_module_name name)
	: esp_system<DMA_WIDTH, MEM_SIZE>(name)
        {
	    // ACC
#ifdef CADENCE
	    acc = new gemm_wrapper("gemm_wrapper");
#else
	    acc = new gemm("gemm_wrapper");
#endif
	    // Binding ACC
	    acc->clk(clk);
	    acc->rst(acc_rst);
	    acc->dma_read_ctrl(dma_read_ctrl);
	    acc->dma_write_ctrl(dma_write_ctrl);
	    acc->dma_read_chnl(dma_read_chnl);
	    acc->dma_write_chnl(dma_write_chnl);
	    acc->conf_info(conf_info);
	    acc->conf_done(conf_done);
	    acc->acc_done(acc_done);
	    acc->debug(debug);
	}

    // Processes

    // Configure accelerator
    void config_proc();

    // Load internal memory
    void load_memory();

    // Dump internal memory
    void dump_memory();

    // Validate accelerator results
    int validate();

    // Accelerator-specific data
    unsigned batch_size;
    unsigned is_transposed;
    unsigned rowsA;
    unsigned colsA;
    unsigned rowsB;
    unsigned colsB;
    unsigned rowsB_actual;
    unsigned colsB_actual;
    unsigned size_inA;
    unsigned size_inB;
    unsigned size_out;

    // Mem index
    uint32_t indexA;
    uint32_t indexB;

    // Input matrix 1
    double_matrix_t * matrix_inA;

    // Input matrix 2
    double_matrix_t * matrix_inB;

    // Output matrix (acc)
    double_matrix_t * matrix_out;

    // Output matrix (pvc)
    double_matrix_t * matrix_out_gold;

    // Other Functions
};

#endif // __SYSTEM_HPP__
