// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "gemm.hpp"
#include "gemm_directives.hpp"
#include "gemm_functions.hpp"

// Processes

void gemm::load_input()
{
    bool pingpong;
    uint32_t i;
    uint32_t ninputs;
    uint32_t length;
    uint32_t index_d1;
    uint32_t index_d2;
    uint32_t index_d1_tmp;
    uint32_t index_d2_tmp;
    uint32_t matrix_d1;
    uint32_t matrix_d2;
    uint32_t matrix_d3;
    uint32_t matrix_out;
    uint32_t size_matrix2;
    uint32_t matrix_chk_in;
    uint32_t matrix_rem_in;
    uint32_t matrix_chk_out;
    uint32_t matrix_rem_out;
    uint32_t ld_offset1;
    uint32_t ld_offset2;
    uint32_t transpose;

    // Reset
    {
	HLS_DEFINE_PROTOCOL("load-reset");

	this->reset_load_input();
	load_compute_cfg_done.req.reset_req();
	load_store_cfg_done.req.reset_req();

	// PLM memories reset

	// User-defined reset code
	i = 0;
	ninputs = 0;
        length = 0;
        index_d1 = 0;
        index_d2 = 0;
        index_d1_tmp = 0;
        index_d2_tmp = 0;
        matrix_d1 = 0;
        matrix_d2 = 0;
        matrix_d3 = 0;
        matrix_out = 0;
	size_matrix2 = 0;
        matrix_chk_in = 0;
        matrix_rem_in = 0;
        matrix_chk_out = 0;
        matrix_rem_out = 0;
        ld_offset1 = 0;
        ld_offset2 = 0;
	transpose = 0;
	pingpong = false;

	wait();
    }

    // Config
    {
	HLS_DEFINE_PROTOCOL("load-config");

	cfg.wait_for_config(); // config process
	conf_info_t config = this->conf_info.read();

	// User-defined config code
	ninputs = config.ninputs;
        matrix_d1 = config.d1;
        matrix_d2 = config.d2;
        matrix_d3 = config.d3;
        ld_offset1 = config.ld_offset1;
        ld_offset2 = config.ld_offset2;
	transpose = config.transpose;
    }

    {
	calculate_config(ninputs, matrix_d1, matrix_d2, matrix_d3,
			 size_matrix2, matrix_out, matrix_chk_in, matrix_rem_in,
			 matrix_chk_out, matrix_rem_out);

	size_matrix2_sig.write(size_matrix2);
	matrix_chk_in_sig.write(matrix_chk_in);
	matrix_rem_in_sig.write(matrix_rem_in);
	matrix_chk_out_sig.write(matrix_chk_out);
	matrix_rem_out_sig.write(matrix_rem_out);

	index_d1 = ld_offset1;
	index_d2 = ld_offset2;
	// size_matrix2 = matrix_d2 * matrix_d3;
	// calculate_chunks(matrix_chk, matrix_rem, matrix_d2);

	load_compute_cfg_handshake();
	load_store_cfg_handshake();
    }

    // Load
    for (uint16_t a = 0; a < ninputs; a++)
    {
	for (uint32_t d1 = 0; d1 < matrix_d1; ++d1)
	{
	    index_d2_tmp = index_d2;

	    for (uint32_t d2 = 0; d2 < matrix_d3; ++d2)
	    {
		index_d1_tmp = index_d1;

		length = DMA_CHUNK;

		uint32_t index_m2_dma = index_d2_tmp;

		for (uint32_t chk = 0; chk < matrix_chk_in; ++chk)
		{
		    //
		    // 1. Load chunks of the first matrix in PLMs input0 and input1
		    //

		    // If true the next is the last (smaller) chunk
		    if (chk == matrix_chk_in - 1 && matrix_rem_in != 0)
			length = matrix_rem_in;

		    {
			HLS_DEFINE_PROTOCOL("load-matrix1-info");
			dma_info_t dma_info(index_d1_tmp, length >> WORDS_PER_DMA_LOG, SIZE_WORD);
			this->dma_read_ctrl.put(dma_info);
		    }

		    sc_dt::sc_bv<DMA_WIDTH> data_high;
		    i = 0;

		    for (uint32_t k = 0; k < length >> WORDS_PER_DMA_LOG; ++k)
		    {
			sc_dt::sc_bv<DMA_WIDTH> data = this->dma_read_chnl.get();

			{
			    // This ensures the maximum throughput
			    HLS_CONSTRAIN_LATENCY(0, 1, "load-matrix1");

			    if (pingpong)
				input0[i++] = data.to_uint64();
			    else
				input1[i++] = data.to_uint64();

			    wait(); // Only considered in behavioral simulation
			}
		    }

		    //
		    // 2. Load chunks of the second matrix in PLMs input2 and input3
		    //

		    // TODO
		    // This does not work when WORDS_PER_DMA != 1
		    uint32_t m2_loop_iters, length_m2_dma, index_m2_incr;
			
		    if (!transpose) {
			m2_loop_iters = length;
			length_m2_dma = 1;
			index_m2_incr = matrix_d3;
		    } else {
			m2_loop_iters = 1;
			length_m2_dma = length;
			index_m2_incr = length;
		    }

		    i = 0;
		    for (uint32_t t = 0; t < m2_loop_iters; ++t)
		    {
			{
			    HLS_DEFINE_PROTOCOL("load-matrix2-info");

			    dma_info_t dma_info(index_m2_dma, // + t * matrix_d2,
						length_m2_dma >> WORDS_PER_DMA_LOG, SIZE_WORD);
			    this->dma_read_ctrl.put(dma_info);
			}

			for (uint32_t k = 0; k < length_m2_dma >> WORDS_PER_DMA_LOG; ++k)
			{
			    sc_dt::sc_bv<DMA_WIDTH> data = this->dma_read_chnl.get();

			    {
				// This ensures the maximum throughput
				HLS_CONSTRAIN_LATENCY(0, 1, "load-matrix2");

				if (pingpong)
				    input2[i++] = data.to_uint64();
				else
				    input3[i++] = data.to_uint64();

				wait(); // Only considered in behavioral simulation
			    }
			}

			index_m2_dma += index_m2_incr;
		    }
		    
		    // Call the compute_kernel process
		    load_compute_handshake();

		    // Change pingpong buffer
		    pingpong = !pingpong;

		    // Update the indices
		    index_d1_tmp += length >> WORDS_PER_DMA_LOG;
		    if (transpose)
			index_d2_tmp += length_m2_dma >> WORDS_PER_DMA_LOG;
		}
		if (!transpose)
		    index_d2_tmp += 1;
	    }
	    index_d1 += (matrix_d2 >> WORDS_PER_DMA_LOG);
	}
	index_d2 += (size_matrix2 >> WORDS_PER_DMA_LOG);
    }

    // Conclude
    {
	HLS_DEFINE_PROTOCOL("load-done");
	this->process_done();
    }
}

void gemm::store_output()
{
    uint32_t i;
    uint32_t index;
    uint32_t length;
    uint32_t matrix_chk_out;
    uint32_t matrix_rem_out;
    uint32_t matrix_out;
    uint32_t st_offset;

    // Reset
    {
    	HLS_DEFINE_PROTOCOL("store-reset");

    	this->reset_store_output();
        output_done.req.reset_req();
	load_store_cfg_done.ack.reset_ack();

    	// PLM memories reset

    	// User-defined reset code
	i = 0;
        index = 0;
        length = 0;
        matrix_chk_out = 0;
        matrix_rem_out = 0;
        matrix_out = 0;
        st_offset = 0;

    	wait();
    }

    // Config
    {
    	HLS_DEFINE_PROTOCOL("store-config");

    	cfg.wait_for_config(); // config process
    	conf_info_t config = this->conf_info.read();

	// User-defined config code
        st_offset = config.st_offset;

	store_load_cfg_handshake();

        // Calculating number of outputs to generate
	matrix_out = matrix_out_sig.read();
	matrix_chk_out = matrix_chk_out_sig.read();
	matrix_rem_out = matrix_rem_out_sig.read();
    }

    // Store
    index = st_offset;
    length = DMA_CHUNK;

    for (uint32_t chk = 0; chk < matrix_chk_out; ++chk)
    {
	// If true the next is the last (smaller) chunk
	if (chk == matrix_chk_out - 1 && matrix_rem_out != 0)
	    length = matrix_rem_out;

	// Wait the compute_process
	store_compute_handshake();

	{
	    HLS_DEFINE_PROTOCOL("store-matrix-info");
	    dma_info_t dma_info(index, length >> WORDS_PER_DMA_LOG, SIZE_WORD);
	    this->dma_write_ctrl.put(dma_info);
	}

	i = 0;
	for (uint32_t k = 0; k < length >> WORDS_PER_DMA_LOG; ++k)
	{
	    sc_dt::sc_bv<DMA_WIDTH> data = 0;

	    {
		// This ensures the maximum throughput
		HLS_CONSTRAIN_LATENCY(0, 1, "store-matrix");

		data = output[i++];

		wait(); // Only considered in behavioral simulation
	    }

	    this->dma_write_chnl.put(data);
	}

	// release compute_process
	store_compute_2_handshake();

	// update the index
	index += length >> WORDS_PER_DMA_LOG;
    }

    // Conclude
    {
    	this->accelerator_done();
    	this->process_done();
    }
}

void gemm::compute_kernel()
{
    bool pingpong;
    uint32_t i;
    uint32_t ninputs;
    uint32_t length;
    uint32_t matrix_d1;
    uint32_t matrix_d2;
    uint32_t matrix_d3;
    uint32_t do_relu;
    uint32_t matrix_chk_in;
    uint32_t matrix_rem_in;
    uint32_t store_count;

    // Reset
    {
    	HLS_DEFINE_PROTOCOL("compute-reset");

    	this->reset_compute_kernel();
	output_done.ack.reset_ack();
	load_compute_cfg_done.ack.reset_ack();

    	// PLM memories reset

    	// User-defined reset code
        pingpong = false;
	i = 0;
    	ninputs = 0;
        matrix_d1 = 0;
        matrix_d2 = 0;
        matrix_d3 = 0;
	do_relu = 0;
        matrix_chk_in = 0;
        matrix_rem_in = 0;
        store_count = 0;

    	wait();
    }

    // Config
    {
    	HLS_DEFINE_PROTOCOL("compute-config");

    	cfg.wait_for_config(); // config process
    	conf_info_t config = this->conf_info.read();

    	// User-defined config code
    	ninputs = config.ninputs;
        matrix_d1 = config.d1;
        matrix_d3 = config.d3;
	do_relu = config.do_relu;

	compute_load_cfg_handshake();

	matrix_chk_in = matrix_chk_in_sig.read();
	matrix_rem_in = matrix_rem_in_sig.read();
    }

    // Compute
    for (uint16_t a = 0; a < ninputs; a++)
    {
	for (uint32_t d1 = 0; d1 < matrix_d1; ++d1)
	{
	    for (uint32_t d2 = 0; d2 < matrix_d3; ++d2)
	    {
		{
		    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "reset-acc");

		    for (uint8_t i = 0; i < WORDS_PER_DMA; ++i)
		    {
			HLS_UNROLL_LOOP(ON, "reduce");
			accumulator[i] = FPDATA(0.0);
		    }
		}

		length = DMA_CHUNK;

		for (uint32_t chk = 0; chk < matrix_chk_in; ++chk)
		{
		    // If true the next is the last (smaller) chunk
		    if (chk == matrix_chk_in - 1 && matrix_rem_in != 0)
			length = matrix_rem_in;

		    // Wait the load_input process
		    compute_load_handshake();

		    if (pingpong)
			gemm_main(length >> WORDS_PER_DMA_LOG, (PLM_WORD*) input0, (PLM_WORD*) input2);
		    else
			gemm_main(length >> WORDS_PER_DMA_LOG, (PLM_WORD*) input1, (PLM_WORD*) input3);

		    pingpong = !pingpong;
		}

		{
		    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "reduce-acc");

		    for (uint8_t i = 1; i < WORDS_PER_DMA; ++i)
		    {
			HLS_UNROLL_LOOP(ON, "reduce");
			accumulator[0] += accumulator[i];
		    }
		}

		if (do_relu && accumulator[0] < 0)
		    accumulator[0] = 0;

		unsigned pos = d2 % WORDS_PER_DMA;
		output[store_count].range((pos+1) * WORD_SIZE - 1, pos * WORD_SIZE) =
		    FP2INT(accumulator[0]);
		    
		// Call the store_output process and wait for the store_output process
		// -> output PLM is not in pingpong
		if (pos == WORDS_PER_DMA - 1) {
		    sync_compute_store(store_count);
		}
	    }
	}
    }

    // Force to store the last chunk
    if (store_count) {
	store_count = (DMA_CHUNK >> WORDS_PER_DMA_LOG) - 1;
	sync_compute_store(store_count);
    }

    // Conclude
    {
	this->process_done();
    }
}
