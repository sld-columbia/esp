// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __GEMM_HPP__
#define __GEMM_HPP__

#include "gemm_data.hpp"
#include "fpdata.hpp"
#include "gemm_conf_info.hpp"
#include "gemm_debug_info.hpp"
#include "esp_templates.hpp"
#include "gemm_directives.hpp"
#include "common.hpp"

#define __round_mask(x, y) ((y)-1)
#define round_up(x, y) ((((x)-1) | __round_mask(x, y))+1)

class gemm : public esp_accelerator_3P<DMA_WIDTH>
{
public:

    // Constructor
    SC_HAS_PROCESS(gemm);
    gemm(const sc_module_name& name)
	: esp_accelerator_3P<DMA_WIDTH>(name)
	, cfg("config")
	, output_done("output_done")
	, load_compute_cfg_done("load_compute_cfg_done")
	, load_store_cfg_done("load_store_cfg_done")
        {
            // Signal binding
            cfg.bind_with(*this);
	    output_done.bind_with<DMA_WIDTH>(*this);
	    load_compute_cfg_done.bind_with<DMA_WIDTH>(*this);
	    load_store_cfg_done.bind_with<DMA_WIDTH>(*this);

	    // Flatten arrays
	    HLS_FLATTEN_ARRAY(mult_out);
	    HLS_FLATTEN_ARRAY(row);
	    HLS_FLATTEN_ARRAY(col);

	    // Map memories
	    HLS_MAP_plm(input0, IN_PLM_NAME);
	    HLS_MAP_plm(input1, IN_PLM_NAME);
	    HLS_MAP_plm(input2, IN_PLM_NAME);
	    HLS_MAP_plm(input3, IN_PLM_NAME);
	    HLS_MAP_plm(output0, OUT_PLM_NAME);
	    HLS_MAP_plm(output1, OUT_PLM_NAME);
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
    handshake_t load_compute_cfg_done;
    handshake_t load_store_cfg_done;

    // Functions

    // Calculate the number of chunks and remaining cols
    inline void calculate_config(uint24_t ninputs,
				 uint24_t matrix_d1,
				 uint24_t matrix_d2,
				 uint24_t matrix_d3,
				 bool transpose,
				 uint32_t& size_matrix1,
				 uint32_t& size_matrix2,
				 uint32_t& size_matrix_out,
				 uint24_t& matrix_chk_in,
				 uint16_t& matrix_rem_in1,
				 uint16_t& matrix_rem_in2,
				 uint24_t& matrix_chk_out,
				 uint16_t& matrix_rem_out,
				 uint8_t& load_cfg,
				 uint16_t& loadable_rows,
				 uint16_t& loadable_chunk,
				 uint16_t& index_d1_incr,
				 uint16_t& m2_loop_iters,
				 uint16_t& m2_plm_incr);
    inline void calculate_chunks(uint24_t &matrix_chk, uint16_t &matrix_rem,
				 uint32_t matrix_d2, bool in_or_out);

    // Synchronize compute_kernel and store_output processes
    inline void sync_compute_store(uint16_t &count, uint16_t loaded_rows,
				   uint8_t load_cfg, uint16_t loadable_rows,
				   bool &pingpong);

    // Handshake callable from compute_kernel
    inline void compute_store_2_handshake();

    // Handshake callable from store_output
    inline void store_compute_2_handshake();

    // Configuration handshakes
    inline void load_compute_cfg_handshake();
    inline void compute_load_cfg_handshake();
    inline void load_store_cfg_handshake();
    inline void store_load_cfg_handshake();

    // Private local memories
    PLM_WORD input0[DMA_CHUNK];
    PLM_WORD input1[DMA_CHUNK];
    PLM_WORD input2[DMA_CHUNK];
    PLM_WORD input3[DMA_CHUNK];
    PLM_WORD output0[OUT_DMA_CHUNK];
    PLM_WORD output1[OUT_DMA_CHUNK];
    FPDATA row[PARALLELISM];
    FPDATA col[PARALLELISM];
    FPDATA mult_out[PARALLELISM];
    FPDATA accumulator;

    // Custom configuration signals
    sc_signal<uint32_t> size_matrix_out_sig;
    sc_signal<uint32_t> size_matrix1_sig;
    sc_signal<uint32_t> size_matrix2_sig;
    sc_signal<uint24_t> matrix_chk_in_sig;
    sc_signal<uint16_t> matrix_rem_in1_sig;
    sc_signal<uint16_t> matrix_rem_in2_sig;
    sc_signal<uint24_t> matrix_chk_out_sig;
    sc_signal<uint16_t> matrix_rem_out_sig;
    sc_signal<uint8_t> load_cfg_sig;
    sc_signal<uint16_t> loadable_rows_sig;
    sc_signal<uint16_t> loadable_chunk_sig;
    sc_signal<uint16_t> index_d1_incr_sig;
};

#endif /* __GEMM_HPP__ */
