// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "gemm.hpp"

// Optional application-specific helper functions

//
// Utility functions
//

inline void gemm::calculate_config(uint24_t ninputs,
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
				   uint16_t& m2_plm_incr)
{
    size_matrix1 = matrix_d1 * matrix_d2;
    size_matrix2 = matrix_d2 * matrix_d3;
    size_matrix_out = matrix_d1 * matrix_d3 * ninputs;

    m2_loop_iters = 1;
    m2_plm_incr = 1;

    bool d3_odd = matrix_d3 % 2;
    bool is_less_than_matrix2 = (size_matrix2 > DMA_CHUNK || !transpose);

    if ((matrix_d2 > DMA_CHUNK) || (is_less_than_matrix2 && d3_odd)) {
	load_cfg = LESS_THAN_ROW;
	loadable_rows = 1;
	loadable_chunk = DMA_CHUNK;
	calculate_chunks(matrix_chk_in, matrix_rem_in1, matrix_d2, 0);
	matrix_rem_in2 = matrix_rem_in1;
	index_d1_incr = matrix_d2;
    } else if (is_less_than_matrix2) {
	load_cfg = LESS_THAN_MATRIX2;
	if (size_matrix2 > DMA_CHUNK) {
	    loadable_rows = DMA_CHUNK / matrix_d2;
	    if (loadable_rows != 1)
		loadable_rows = (loadable_rows >> 1) << 1;
	} else {
	    loadable_rows = matrix_d3;
	}
	loadable_chunk = loadable_rows * matrix_d2;
	matrix_chk_in = 1;
	matrix_rem_in1 = size_matrix1 % loadable_chunk;
	matrix_rem_in2 = size_matrix2 % loadable_chunk;
	index_d1_incr = loadable_chunk;
	if (!transpose) {
	    m2_loop_iters = matrix_d2;
	    m2_plm_incr = matrix_d2;
	}
    } else {
	load_cfg = MORE_THAN_MATRIX2;
	loadable_rows = matrix_d3;
	loadable_chunk = size_matrix2;
	matrix_chk_in = 1;
	matrix_rem_in1 = size_matrix1 % loadable_chunk;
	matrix_rem_in2 = size_matrix2;
	index_d1_incr = loadable_chunk;
    }

    calculate_chunks(matrix_chk_out, matrix_rem_out, size_matrix_out, 1);
}

inline void gemm::calculate_chunks(uint24_t  &matrix_chk,
				   uint16_t &matrix_rem,
				   uint32_t matrix_d2,
				   bool in_or_out)
{
     uint32_t matrix_mul;
     {
        HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "calc-chunks");

	if (!in_or_out) {
	    // calculating the number of chunks (ceil)
	    matrix_chk = matrix_d2 >> DMA_CHUNK_LOG;
	    // calculating the number of cols (covered the by the chunks)
	    matrix_mul = matrix_chk << DMA_CHUNK_LOG;
	} else {
	    // calculating the number of chunks (ceil)
	    matrix_chk = matrix_d2 >> OUT_DMA_CHUNK_LOG;
	    // calculating the number of cols (covered the by the chunks)
	    matrix_mul = matrix_chk << OUT_DMA_CHUNK_LOG;
	}

        // calculating the remaining cols (size of the last chunk)
        matrix_rem = matrix_d2 - matrix_mul;

        // adding the last chunk if it is necessary
        if (matrix_rem != 0) { ++matrix_chk; }
    }
}

inline void gemm::sync_compute_store(uint16_t &count, uint16_t loaded_rows,
				     uint8_t load_cfg, uint16_t loadable_rows,
				     bool &pingpong)
{
    count++;
    if (load_cfg == LESS_THAN_MATRIX2 && loadable_rows != 1) {
	if (count == loaded_rows) {
            count = 0;
	    // ESP_REPORT_INFO("COMPUTE2: before store hs %u", (unsigned) count);
            // Call the store_output process
            compute_store_handshake();
	    // ESP_REPORT_INFO("COMPUTE2: after store hs %u", (unsigned) count);
	    pingpong = !pingpong;
	}
    } else {
        if (count == OUT_DMA_CHUNK) {
            count = 0;
	    // ESP_REPORT_INFO("COMPUTE: before store hs");
            // Call the store_output process
            compute_store_handshake();
	    // ESP_REPORT_INFO("COMPUTE: after store hs");
	    pingpong = !pingpong;
        }
    }
}

inline void gemm::load_compute_cfg_handshake()
{
    HLS_DEFINE_PROTOCOL("load-compute-cfg-handshake");

    load_compute_cfg_done.req.req();
}

inline void gemm::compute_load_cfg_handshake()
{
    HLS_DEFINE_PROTOCOL("compute-load-cfg-handshake");

    load_compute_cfg_done.ack.ack();
}

inline void gemm::load_store_cfg_handshake()
{
    HLS_DEFINE_PROTOCOL("load-store-cfg-handshake");

    load_store_cfg_done.req.req();
}

inline void gemm::store_load_cfg_handshake()
{
    HLS_DEFINE_PROTOCOL("store-load-cfg-handshake");

    load_store_cfg_done.ack.ack();
}
