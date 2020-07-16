// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "gemm.hpp"

// Optional application-specific helper functions

//
// Computational kernels
//

void gemm::gemm_main(uint32_t length,
		     PLM_WORD *row,
		     PLM_WORD *col)
{
    for (uint32_t k = 0; k < DMA_CHUNK / WORDS_PER_DMA / PARALLELISM; ++k)
    {
        HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "main-loop");

	uint32_t plm_i_base = k * PARALLELISM;

	if (plm_i_base >= length)
	    break;

#if (WORDS_PER_DMA == 1)

	for (uint32_t m = 0; m < PARALLELISM; ++m)
	{
	    HLS_UNROLL_LOOP(ON);

	    uint32_t plm_i = plm_i_base + m;
	    FPDATA row_elem_1 = INT2FP(row[plm_i]);
	    FPDATA col_elem_1 = INT2FP(col[plm_i]);

	    if (plm_i < length) {
		MULTIPLY(mult_out[0][m], row_elem_1, col_elem_1);
	    }
	}

	for (uint32_t m = 0; m < PARALLELISM; ++m)
	{
	    HLS_UNROLL_LOOP(ON);

	    uint32_t plm_i = plm_i_base + m;
	    if (plm_i < length) {
		ADD(accumulator[0], accumulator[0], mult_out[0][m]);
	    }
	}
	
#elif (WORDS_PER_DMA == 2)

	for (uint32_t m = 0; m < PARALLELISM; ++m)
	{
	    HLS_UNROLL_LOOP(ON);

	    uint32_t plm_i = plm_i_base + m;
	    FPDATA row_elem_1 = INT2FP(row[plm_i].range(WORD_SIZE-1, 0));	
	    FPDATA col_elem_1 = INT2FP(col[plm_i].range(WORD_SIZE-1, 0));	
	    FPDATA row_elem_2 = INT2FP(row[plm_i].range(2 * WORD_SIZE-1, WORD_SIZE)); 
	    FPDATA col_elem_2 = INT2FP(col[plm_i].range(2 * WORD_SIZE-1, WORD_SIZE));

	    if (plm_i < length) {
		MULTIPLY(mult_out[0][m], row_elem_1, col_elem_1);
		MULTIPLY(mult_out[1][m], row_elem_2, col_elem_2);
	    }
	}

	for (uint32_t m = 0; m < PARALLELISM; ++m)
	{
	    HLS_UNROLL_LOOP(ON);

	    uint32_t plm_i = plm_i_base + m;
	    if (plm_i < length) {
		ADD(accumulator[0], accumulator[0], mult_out[0][m]);
		ADD(accumulator[1], accumulator[1], mult_out[1][m]);
	    }
	}
#endif
    }
}

//
// Utility functions
//

inline void gemm::calculate_config(uint32_t ninputs,
				   uint32_t matrix_d1,
				   uint32_t matrix_d2,
				   uint32_t matrix_d3,
				   uint32_t& size_matrix2,
				   uint32_t& matrix_out,
				   uint32_t& matrix_chk_in,
				   uint32_t& matrix_rem_in,
				   uint32_t& matrix_chk_out,
				   uint32_t& matrix_rem_out)
{
    size_matrix2 = matrix_d2 * matrix_d3;
    calculate_chunks(matrix_chk_in, matrix_rem_in, matrix_d2);

    matrix_out = matrix_d1 * matrix_d3 * ninputs;
    calculate_chunks(matrix_chk_out, matrix_rem_out, matrix_out);
}

inline void gemm::calculate_chunks(uint32_t  &matrix_chk,
				   uint32_t &matrix_rem,
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

inline void gemm::sync_compute_store(uint32_t &count)
{
    {
        ++count;

        if (count >= (DMA_CHUNK >> WORDS_PER_DMA_LOG))
        {
            count = 0;

            // Call the store_output process
            compute_store_handshake();

            // Wait for the store_output process
            compute_store_2_handshake();
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
