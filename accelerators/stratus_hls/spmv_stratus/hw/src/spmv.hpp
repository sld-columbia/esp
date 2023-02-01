// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __SPMV_HPP__
#define __SPMV_HPP__

#include "fpdata.hpp"
#include "spmv_conf_info.hpp"
#include "spmv_debug_info.hpp"
#include "esp_templates.hpp"
#include "spmv_directives.hpp"

#define PLM_ROWS_SIZE 256
#define PLM_COLS_SIZE 1024
#define PLM_VALS_SIZE 1024
#define PLM_VECT_SIZE 8192
#define PLM_OUT_SIZE 256

class spmv : public esp_accelerator_3P<DMA_WIDTH>
{
    public:

    // Computation <-> Computation

    // Constructor
    SC_HAS_PROCESS(spmv);
    spmv(const sc_module_name& name)
	: esp_accelerator_3P<DMA_WIDTH>(name)
	, cfg("config")
        {
            // Signal binding
            cfg.bind_with(*this);

	    // Binding for memories
            HLS_MAP_ROWS0;
            HLS_MAP_ROWS1;
            HLS_MAP_COLS0;
            HLS_MAP_COLS1;
            HLS_MAP_VALS0;
            HLS_MAP_VALS1;
            HLS_MAP_VECT0;
            HLS_MAP_VECT1;
            HLS_MAP_OUT0;
            HLS_MAP_OUT1;
        }

    // Processes

    // Load the input data
    void load_input();

    // Realize the computation
    void compute_kernel();

    // Store the output data
    void store_output();

    // Configure spmv
    esp_config_proc cfg;

    // Functions

    // Private local memories
    uint32_t ROWS0[PLM_ROWS_SIZE];
    uint32_t ROWS1[PLM_ROWS_SIZE];
    uint32_t COLS0[PLM_COLS_SIZE];
    uint32_t COLS1[PLM_COLS_SIZE];
    FPDATA_WORD VALS0[PLM_VALS_SIZE];
    FPDATA_WORD VALS1[PLM_VALS_SIZE];
    FPDATA_WORD VECT0[PLM_VECT_SIZE];
    FPDATA_WORD VECT1[PLM_VALS_SIZE]; // not a mistake
    FPDATA_WORD OUT0[PLM_OUT_SIZE];
    FPDATA_WORD OUT1[PLM_OUT_SIZE];
};

#endif /* __SPMV_HPP__ */
