// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "gemm.hpp"

// Optional application-specific helper functions

//
// Computational kernels
//

void gemm::gemm_main(uint16_t length,
		     PLM_WORD *row,
		     PLM_WORD *col)
{
    for (uint16_t k = 0; k < DMA_CHUNK / WORDS_PER_DMA / PARALLELISM; ++k)
    {
        HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "main-loop");

	// std::cout << "gemm_main k " << k << " length " << length << std::endl;

	uint16_t plm_i_base = k * PARALLELISM;

	if (plm_i_base >= length)
	    break;

#if (WORDS_PER_DMA == 1)

	for (uint8_t m = 0; m < PARALLELISM; ++m)
	{
	    HLS_UNROLL_LOOP(ON);

	    // std::cout << "gemm_main wordsperdma1 m " << m << std::endl;

	    uint16_t plm_i = plm_i_base + m;
	    FPDATA row_elem_1 = INT2FP(row[plm_i]);
	    FPDATA col_elem_1 = INT2FP(col[plm_i]);

	    if (plm_i < length) {
		// std::cout << "multiply " << row_elem_1 << " , " << col_elem_1 << std::endl;
		MULTIPLY(mult_out[0][m], row_elem_1, col_elem_1);
	    }
	}

	for (uint8_t m = 0; m < PARALLELISM; ++m)
	{
	    HLS_UNROLL_LOOP(ON);

	    uint16_t plm_i = plm_i_base + m;
	    if (plm_i < length) {
		ACCUMULATE(accumulator[0], mult_out[0][m]);
	    }
	}
	
#elif (WORDS_PER_DMA == 2)

	for (uint8_t m = 0; m < PARALLELISM; ++m)
	{
	    HLS_UNROLL_LOOP(ON);

	    // std::cout << "gemm_main wordsperdma2 m " << m << std::endl;

	    uint16_t plm_i = plm_i_base + m;
	    PLM_WORD row_word = row[plm_i];
	    PLM_WORD col_word = col[plm_i];

	    FPDATA row_elem_1 = INT2FP(row_word.range(WORD_SIZE - 1, 0));	
	    FPDATA col_elem_1 = INT2FP(col_word.range(WORD_SIZE - 1, 0));	
	    FPDATA row_elem_2 = INT2FP(row_word.range((WORD_SIZE << 1) - 1, WORD_SIZE)); 
	    FPDATA col_elem_2 = INT2FP(col_word.range((WORD_SIZE << 1) - 1, WORD_SIZE));

	    if (plm_i < length) {
		MULTIPLY(mult_out[0][m], row_elem_1, col_elem_1);
		MULTIPLY(mult_out[1][m], row_elem_2, col_elem_2);
	    }
	}

	for (uint8_t m = 0; m < PARALLELISM; ++m)
	{
	    HLS_UNROLL_LOOP(ON);

	    uint16_t plm_i = plm_i_base + m;
	    if (plm_i < length) {
		ACCUMULATE(accumulator[0], mult_out[0][m]);
		ACCUMULATE(accumulator[1], mult_out[1][m]);
	    }
	}
#endif
    }
}

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
				   uint16_t& index_d1_incr)
{
    size_matrix1 = matrix_d1 * matrix_d2;
    size_matrix2 = matrix_d2 * matrix_d3;
    size_matrix_out = matrix_d1 * matrix_d3 * ninputs;

    if (matrix_d2 > DMA_CHUNK ||
	!transpose) {
	load_cfg = LESS_THAN_ROW;
	loadable_rows = 1;
	loadable_chunk = DMA_CHUNK;
	calculate_chunks(matrix_chk_in, matrix_rem_in1, matrix_d2);
	matrix_rem_in2 = matrix_rem_in1;
	index_d1_incr = matrix_d2;
    } else if (size_matrix2 > DMA_CHUNK) {
	load_cfg = LESS_THAN_MATRIX2;
	loadable_rows = DMA_CHUNK / matrix_d2;
	if (loadable_rows != 1)
	    loadable_rows = (loadable_rows >> 1) << 1;
	loadable_chunk = loadable_rows * matrix_d2;
	matrix_chk_in = 1;
	matrix_rem_in1 = size_matrix1 % loadable_chunk;
	matrix_rem_in2 = size_matrix2 % loadable_chunk;
	index_d1_incr = loadable_chunk;
    } else {
	load_cfg = MORE_THAN_MATRIX2;
	loadable_rows = matrix_d3;
	loadable_chunk = size_matrix2;
	matrix_chk_in = 1;
	matrix_rem_in1 = size_matrix1;
	matrix_rem_in2 = size_matrix2;
	index_d1_incr = loadable_chunk;
    }

    index_d1_incr = index_d1_incr >> WORDS_PER_DMA_LOG;

    calculate_chunks(matrix_chk_out, matrix_rem_out, size_matrix_out);
}

inline void gemm::calculate_chunks(uint24_t  &matrix_chk,
				   uint16_t &matrix_rem,
				   uint32_t matrix_d2)
{
     uint32_t matrix_mul;

     {
        HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "calc-chunks");

        // calculating the number of chunks (ceil)
        matrix_chk = matrix_d2 >> DMA_CHUNK_LOG;

        // calculating the number of cols (covered the by the chunks)
        matrix_mul = matrix_chk << DMA_CHUNK_LOG;

        // calculating the remaining cols (size of the last chunk)
        matrix_rem = matrix_d2 - matrix_mul;

        // adding the last chunk if it is necessary
        if (matrix_rem != 0) { ++matrix_chk; }
    }
}

inline void gemm::sync_compute_store(uint16_t &count, uint16_t loaded_rows,
				     uint8_t load_cfg, uint16_t loadable_rows)
{
    ++count;

    if (load_cfg == LESS_THAN_MATRIX2 && loadable_rows != 1) {
	if (count == (loaded_rows >> WORDS_PER_DMA_LOG)) {
            count = 0;
	    ESP_REPORT_INFO("COMPUTE2: before store hs %u", (unsigned) count);
            // Call the store_output process
            compute_store_handshake();
	    ESP_REPORT_INFO("COMPUTE2: after store hs %u", (unsigned) count);
	    ESP_REPORT_INFO("COMPUTE2: before store hs2 %u", (unsigned) count);
            // Wait for the store_output process
            compute_store_2_handshake();
	    ESP_REPORT_INFO("COMPUTE2: after store hs2 %u", (unsigned) count);
	}
    } else {
        if (count == (DMA_CHUNK >> WORDS_PER_DMA_LOG)) {
            count = 0;
	    ESP_REPORT_INFO("COMPUTE: before store hs");
            // Call the store_output process
            compute_store_handshake();
	    ESP_REPORT_INFO("COMPUTE: after store hs");
	    ESP_REPORT_INFO("COMPUTE: before store hs2");
            // Wait for the store_output process
            compute_store_2_handshake();
	    ESP_REPORT_INFO("COMPUTE: after store hs2");
        }
    }
}

inline void gemm::compute_store_2_handshake()
{
    HLS_DEFINE_PROTOCOL("compute-store-2-handshake");

    output_done.ack.ack();
}

inline void gemm::store_compute_2_handshake()
{
    HLS_DEFINE_PROTOCOL("store-compute-2-handshake");

    output_done.req.req();
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
