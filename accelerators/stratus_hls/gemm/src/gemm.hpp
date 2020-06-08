// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __GEMM_HPP__
#define __GEMM_HPP__

#include "gemm_data.hpp"
#include "fpdata.hpp"
#include "gemm_conf_info.hpp"
#include "gemm_debug_info.hpp"
#include "esp_templates.hpp"
#include "gemm_directives.hpp"

class gemm : public esp_accelerator_3P<DMA_WIDTH>
{
public:

    // Constructor
    SC_HAS_PROCESS(gemm);
    gemm(const sc_module_name& name)
	: esp_accelerator_3P<DMA_WIDTH>(name)
	, cfg("config")
	, output_done("output_done")
        {
            // Signal binding
            cfg.bind_with(*this);
	    output_done.bind_with<DMA_WIDTH>(*this);

	    // Flatten arrays
	    HLS_FLATTEN_ARRAY(mult_out);
	    HLS_FLATTEN_ARRAY(accumulator);

	    // Map memories
	    HLS_MAP_IN0;
	    HLS_MAP_IN1;
	    HLS_MAP_IN2;
	    HLS_MAP_IN3;
	    HLS_MAP_OUT;
        }

    // Processes

    // Load the input data
    void load_input();

    // Computation
    void compute_kernel();

    // Store the output data
    void store_output();

    // Configure gemm
    esp_config_proc cfg;

    // Custom handshakes
    handshake_t output_done;

    // Functions

    // Calculate the number of chunks and remaining cols
    inline void calculate_chunks(uint32_t &matrix_chk,
				 uint32_t &matrix_rem, uint32_t matrix_d2);

    // Synchronize compute_kernel and store_output processes
    inline void sync_compute_store(uint32_t &count);

    // Handshake callable from compute_kernel
    inline void compute_store_2_handshake();

    // Handshake callable from store_output
    inline void store_compute_2_handshake();

    // Matrix multiplication kernel
    void gemm_main(uint32_t length,
		   PLM_WORD *row,
		   PLM_WORD *col);

    // Private local memories

    PLM_WORD input0[DMA_CHUNK / WORDS_PER_DMA];
    PLM_WORD input1[DMA_CHUNK / WORDS_PER_DMA];
    PLM_WORD input2[DMA_CHUNK / WORDS_PER_DMA];
    PLM_WORD input3[DMA_CHUNK / WORDS_PER_DMA];
    PLM_WORD output[DMA_CHUNK / WORDS_PER_DMA];
    FPDATA mult_out[WORDS_PER_DMA][PARALLELISM];
    FPDATA accumulator[WORDS_PER_DMA];
};

#endif /* __GEMM_HPP__ */
