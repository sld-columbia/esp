// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "gemm.hpp"
#include "gemm_directives.hpp"
#include "gemm_functions.hpp"

// Processes

void gemm::load_input()
{
    bool pingpong_m1;
    bool pingpong_m2;
    uint16_t i;
    uint24_t ninputs;
    uint16_t length1;
    uint16_t length2;
    uint32_t index_d1;
    uint32_t index_d2;
    uint32_t index_d1_tmp;
    uint32_t index_d2_tmp;
    uint24_t matrix_d1;
    uint24_t matrix_d2;
    uint24_t matrix_d3;
    uint32_t size_matrix_out;
    uint32_t size_matrix1;
    uint32_t size_matrix2;
    uint24_t matrix_chk_in;
    uint16_t matrix_rem_in1;
    uint16_t matrix_rem_in2;
    uint24_t matrix_chk_out;
    uint16_t matrix_rem_out;
    uint8_t load_cfg;
    uint16_t loadable_rows;
    uint16_t loadable_chunk;
    uint16_t index_d1_incr;
    uint32_t ld_offset1;
    uint32_t ld_offset2;
    bool transpose;

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
        length1 = 0; 
        length2 = 0; 
        index_d1 = 0;
        index_d2 = 0;
        index_d1_tmp = 0;
        index_d2_tmp = 0;
        matrix_d1 = 0;
        matrix_d2 = 0;
        matrix_d3 = 0;
        size_matrix_out = 0;
	size_matrix1 = 0;
	size_matrix2 = 0;
        matrix_chk_in = 0;
        matrix_rem_in1 = 0;
        matrix_rem_in2 = 0;
        matrix_chk_out = 0;
        matrix_rem_out = 0;
	load_cfg = 0;
	loadable_rows = 0;
	loadable_chunk = 0;
	index_d1_incr = 0;
        ld_offset1 = 0;
        ld_offset2 = 0;
	transpose = 0;
	pingpong_m1 = false;
	pingpong_m2 = false;

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
	calculate_config(ninputs, matrix_d1, matrix_d2, matrix_d3, transpose,
			 size_matrix1, size_matrix2, size_matrix_out, 
			 matrix_chk_in, matrix_rem_in1, matrix_rem_in2,
			 matrix_chk_out, matrix_rem_out,
			 load_cfg, loadable_rows, loadable_chunk, index_d1_incr);

	{
	    HLS_DEFINE_PROTOCOL();
	    size_matrix_out_sig.write(size_matrix_out);
	    size_matrix1_sig.write(size_matrix1);
	    size_matrix2_sig.write(size_matrix2);
	    matrix_chk_in_sig.write(matrix_chk_in);
	    matrix_rem_in1_sig.write(matrix_rem_in1);
	    matrix_rem_in2_sig.write(matrix_rem_in2);
	    matrix_chk_out_sig.write(matrix_chk_out);
	    matrix_rem_out_sig.write(matrix_rem_out);
	    load_cfg_sig.write(load_cfg);
	    loadable_rows_sig.write(loadable_rows);
	    loadable_chunk_sig.write(loadable_chunk);
	    index_d1_incr_sig.write(index_d1_incr);
	    wait();
	}

	index_d1 = ld_offset1;
	index_d2 = ld_offset2;

	// ESP_REPORT_INFO("LOAD %u %u %u %u %u %u %u %u %u %u %u",
	// 		size_matrix1, size_matrix2,
	// 		matrix_chk_in, matrix_rem_in1, matrix_rem_in2,
	// 		matrix_chk_out, matrix_rem_out,
	// 		load_cfg, loadable_rows,
	// 		loadable_chunk, index_d1_incr);

	load_compute_cfg_handshake();
	load_store_cfg_handshake();
    }
    
    // Load
    for (uint24_t a = 0; a < ninputs; a++)
    {
	for (uint24_t d1 = 0; d1 < matrix_d1; d1 += loadable_rows)
	{
	    index_d2_tmp = index_d2;

	    for (uint24_t d2 = 0; d2 < matrix_d3; d2 += loadable_rows)
	    {
		index_d1_tmp = index_d1;

		length1 = loadable_chunk;
		length2 = loadable_chunk;

		uint32_t index_m2_dma = index_d2_tmp;

		for (uint24_t chk = 0; chk < matrix_chk_in; ++chk)
		{
		    // If true the next is the last (smaller) chunk
		    if (load_cfg == LESS_THAN_ROW && chk == matrix_chk_in - 1 &&
			matrix_rem_in2 != 0) {
			length1 = matrix_rem_in1;
			length2 = matrix_rem_in2;
		    } else if (load_cfg != LESS_THAN_ROW) {
			if (d1 + loadable_rows > matrix_d1)
			    length1 = matrix_rem_in1;
			if (d2 + loadable_rows > matrix_d3)
			    length2 = matrix_rem_in2;
		    }

		    //
		    // 1. Load chunks of the first matrix in PLMs input0 and input1
		    //

		    if (!(d2 && load_cfg == LESS_THAN_MATRIX2)) {

			{
			    HLS_DEFINE_PROTOCOL("load-matrix1-info");
			    dma_info_t dma_info(index_d1_tmp, length1 >> WORDS_PER_DMA_LOG, SIZE_WORD);
			    this->dma_read_ctrl.put(dma_info);

			    // ESP_REPORT_INFO("load m1 %u %u", index_d1_tmp, length);
			}

			sc_dt::sc_bv<DMA_WIDTH> data_high;
			i = 0;

			for (uint16_t k = 0; k < length1 >> WORDS_PER_DMA_LOG; ++k)
			{
			    sc_dt::sc_bv<DMA_WIDTH> data = this->dma_read_chnl.get();

			    {
				// This ensures the maximum throughput
				HLS_CONSTRAIN_LATENCY(0, 1, "load-matrix1");

				if (pingpong_m1)
				    input0[i++] = data.to_uint64();
				else
				    input1[i++] = data.to_uint64();

				wait(); // Only considered in behavioral simulation
			    }
			}
			pingpong_m1 = !pingpong_m1;
		    }

		    //
		    // 2. Load chunks of the second matrix in PLMs input2 and input3
		    //

		    // TODO
		    // This does not work when WORDS_PER_DMA != 1
		    uint16_t m2_loop_iters, length_m2_dma;
		    uint32_t index_m2_incr;
			
		    if (!transpose && matrix_d3 != 1) {
			length_m2_dma = min(loadable_rows, matrix_d3 - 1 - d1);
			m2_loop_iters = length2 / length_m2_dma;
			index_m2_incr = matrix_d3;
		    } else {
			length_m2_dma = length2;
			m2_loop_iters = 1;
			index_m2_incr = length2;
		    }

		    i = 0;
		    for (uint16_t t = 0; t < m2_loop_iters; ++t)
		    {
			{
			    HLS_DEFINE_PROTOCOL("load-matrix2-info");

			    dma_info_t dma_info(index_m2_dma,
						length_m2_dma >> WORDS_PER_DMA_LOG, SIZE_WORD);
			    this->dma_read_ctrl.put(dma_info);

			    // ESP_REPORT_INFO("load m2 %u %u", index_m2_dma, length_m2_dma);
			}

			for (uint16_t k = 0; k < length_m2_dma >> WORDS_PER_DMA_LOG; ++k)
			{
			    sc_dt::sc_bv<DMA_WIDTH> data = this->dma_read_chnl.get();

			    {
				// This ensures the maximum throughput
				HLS_CONSTRAIN_LATENCY(0, 1, "load-matrix2");

				if (pingpong_m2)
				    input2[i++] = data.to_uint64();
				else
				    input3[i++] = data.to_uint64();


				wait(); // Only considered in behavioral simulation
			    }
			}

			index_m2_dma += index_m2_incr;
		    }
		    
		    // Call the compute_kernel process
		    // ESP_REPORT_INFO("LOAD: before compute hs d1 %u d2 %u", d1, d2);
		    load_compute_handshake();
		    // ESP_REPORT_INFO("LOAD: after compute hs d1 %u d2 %u", d1, d2);

		    // Change pingpong buffer
		    pingpong_m2 = !pingpong_m2;

		    // Update the indices
		    index_d1_tmp += length1 >> WORDS_PER_DMA_LOG;
		    if (transpose)
			index_d2_tmp += length_m2_dma >> WORDS_PER_DMA_LOG; 
		}
		if (!transpose)
		    index_d2_tmp += loadable_rows;
	    }
	    index_d1 += index_d1_incr;
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
    uint16_t i;
    uint24_t ninputs;
    uint24_t matrix_d1;
    uint24_t matrix_d2;
    uint24_t matrix_d3;
    uint32_t st_offset;
    uint24_t matrix_chk_out;
    uint16_t matrix_rem_out;
    uint32_t size_matrix_out;
    uint8_t load_cfg;
    uint16_t loadable_rows;

    // Reset
    {
    	HLS_DEFINE_PROTOCOL("store-reset");

    	this->reset_store_output();
        output_done.req.reset_req();
	load_store_cfg_done.ack.reset_ack();

    	// PLM memories reset

    	// User-defined reset code
	i = 0;
	ninputs = 0;
        matrix_d1 = 0;
        matrix_d2 = 0;
        matrix_d3 = 0;
        st_offset = 0;
        matrix_chk_out = 0;
        matrix_rem_out = 0;
        size_matrix_out = 0;
	load_cfg = 0;
	loadable_rows = 0;

    	wait();
    }

    // Config
    {
    	HLS_DEFINE_PROTOCOL("store-config");

    	cfg.wait_for_config(); // config process
    	conf_info_t config = this->conf_info.read();

	// User-defined config code
	ninputs = config.ninputs;
        matrix_d1 = config.d1;
        matrix_d2 = config.d2;
        matrix_d3 = config.d3;
        st_offset = config.st_offset;

	store_load_cfg_handshake();

        // Calculating number of outputs to generate
	{
	    HLS_DEFINE_PROTOCOL();
	    matrix_chk_out = matrix_chk_out_sig.read();
	    matrix_rem_out = matrix_rem_out_sig.read();
	    size_matrix_out = size_matrix_out_sig.read();
	    load_cfg = load_cfg_sig.read();
	    loadable_rows = loadable_rows_sig.read();
	    wait();
	}

	if (load_cfg == LESS_THAN_MATRIX2 && loadable_rows != 1) {
	    matrix_chk_out = 1;
	} else {
	    ninputs = 1;
	    matrix_d1 = 1;
	    matrix_d3 = 1;
	    loadable_rows = 1;
	}

	// ESP_REPORT_INFO("STORE %u %u %u",
	// 		size_matrix_out, matrix_chk_out, matrix_rem_out);
    }

    // Store
    uint32_t index = 0;
    uint32_t index_simple = st_offset;
    uint16_t length = DMA_CHUNK;
    uint32_t index_a = st_offset;

    for (uint24_t a = 0; a < ninputs; a++)
    {
	uint32_t index_d1 = index_a;
	for (uint24_t d1 = 0; d1 < matrix_d1; d1 += loadable_rows)
	{
	    uint16_t loaded_rows_d1 = min(loadable_rows, matrix_d1 - d1);
	    uint32_t index_d2 = index_d1;
	    for (uint24_t d2 = 0; d2 < matrix_d3; d2 += loadable_rows)
	    {
		uint16_t loaded_rows_d3 = min(loadable_rows, matrix_d3 - d2);
		uint32_t index_d1i = index_d2;
		for (uint16_t d1i = 0; d1i < loaded_rows_d1; d1i++)
		{
		    for (uint24_t chk = 0; chk < matrix_chk_out; ++chk)
		    {
			// If true the next is the last (smaller) chunk
			if (load_cfg == LESS_THAN_MATRIX2 && loadable_rows != 1) {
			    length = loaded_rows_d3;
			    index = index_d1i;
			} else {
			    index = index_simple; 
			    if (chk == matrix_chk_out - 1 && matrix_rem_out != 0)
				length = matrix_rem_out;
			}

			// Wait the compute_process
			// ESP_REPORT_INFO("STORE: before compute hs %u %u %u %u", d1, d2, d1i, chk);
			store_compute_handshake();
			// ESP_REPORT_INFO("STORE: after compute hs %u %u %u %u", d1, d2, d1i, chk);

			{
			    HLS_DEFINE_PROTOCOL("store-matrix-info");
			    dma_info_t dma_info(index, length >> WORDS_PER_DMA_LOG, SIZE_WORD);
			    this->dma_write_ctrl.put(dma_info);

			    // ESP_REPORT_INFO("STORE index %u length %u", index, length);
			}

			i = 0;
			for (uint16_t k = 0; k < length >> WORDS_PER_DMA_LOG; ++k)
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
			// ESP_REPORT_INFO("STORE: before compute hs2 %u %u %u %u", d1, d2, d1i, chk);
			store_compute_2_handshake();
			// ESP_REPORT_INFO("STORE: after compute hs2 %u %u %u %u", d1, d2, d1i, chk);

			// update the index
			index_simple += length >> WORDS_PER_DMA_LOG;
		    }
		    index_d1i += matrix_d3;
		}
		index_d2 += loadable_rows;
	    }
	    index_d1 += (loadable_rows * matrix_d3);
	}
	index_a += size_matrix_out;
    }

    // Conclude
    {
    	this->accelerator_done();
    	this->process_done();
    }
}

void gemm::compute_kernel()
{
    bool pingpong_m1, pingpong_m2;
    uint24_t ninputs;
    uint16_t length;
    uint24_t matrix_d1;
    uint24_t matrix_d2;
    uint24_t matrix_d3;
    bool do_relu;
    uint24_t matrix_chk_in;
    uint16_t matrix_rem_in1;
    uint16_t matrix_rem_in2;
    uint16_t store_count;
    uint8_t load_cfg;
    uint16_t loadable_rows;

    // Reset
    {
    	HLS_DEFINE_PROTOCOL("compute-reset");

    	this->reset_compute_kernel();
	output_done.ack.reset_ack();
	load_compute_cfg_done.ack.reset_ack();

    	// PLM memories reset

    	// User-defined reset code
        pingpong_m1 = true;
        pingpong_m2 = true;
    	ninputs = 0;
        matrix_d1 = 0;
        matrix_d2 = 0;
        matrix_d3 = 0;
	do_relu = 0;
        matrix_chk_in = 0;
        matrix_rem_in1 = 0;
        matrix_rem_in2 = 0;
        store_count = 0;
	load_cfg = 0;
	loadable_rows = 0;

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
        matrix_d2 = config.d2;
        matrix_d3 = config.d3;
	do_relu = config.do_relu;

	compute_load_cfg_handshake();

	matrix_chk_in = matrix_chk_in_sig.read();
	matrix_rem_in1 = matrix_rem_in1_sig.read();
	matrix_rem_in2 = matrix_rem_in2_sig.read();
	load_cfg = load_cfg_sig.read();
	loadable_rows = loadable_rows_sig.read();

	// ESP_REPORT_INFO("COMPUTE %u %u %u %u",
	// 		matrix_chk_in, matrix_rem_in1, matrix_rem_in2,
	// 		load_cfg, loadable_rows);
    }

    // Compute
    for (uint24_t a = 0; a < ninputs; a++)
    {
	uint16_t plm_offset_m1 = 0;
	uint16_t plm_offset_m2 = 0;

	for (uint24_t d1 = 0; d1 < matrix_d1; d1 += loadable_rows)
	{
	    uint16_t loaded_rows_d1 = min(loadable_rows, matrix_d1 - d1);

	    for (uint24_t d2 = 0; d2 < matrix_d3; d2 += loadable_rows)
	    {
		uint16_t loaded_rows_d3 = min(loadable_rows, matrix_d3 - d2);

		for (uint16_t d1i = 0; d1i < loaded_rows_d1; d1i++)
		{
		    plm_offset_m1 = d1i * matrix_d2;

		    for (uint16_t d2i = 0; d2i < loaded_rows_d3; d2i++)
		    {
			plm_offset_m2 = d2i * matrix_d2;

			{
			    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "reset-acc");

			    for (uint8_t i = 0; i < WORDS_PER_DMA; ++i)
			    {
				HLS_UNROLL_LOOP(ON, "reduce");
				accumulator[i] = FPDATA(0.0);
			    }
			}

			for (uint24_t chk = 0; chk < matrix_chk_in; ++chk)
			{
			    // ESP_REPORT_INFO("COMPUTE: before load hs d1 %u d2 %u", d1, d2);
			    // If true the next is the last (smaller) chunk
			    if (load_cfg == LESS_THAN_ROW) {
				if (chk == matrix_chk_in - 1 && matrix_rem_in2 != 0) {
				    length = matrix_rem_in2;
				} else {
				    length = DMA_CHUNK;
				}
				pingpong_m1 = !pingpong_m1;
				pingpong_m2 = !pingpong_m2;
				if (!d2i)
				    compute_load_handshake();
			    } else if (load_cfg == LESS_THAN_MATRIX2) {
				length = matrix_d2;
				if (!d1i && !d2i) {
				    if (!d2)
					pingpong_m1 = !pingpong_m1;
				    pingpong_m2 = !pingpong_m2;
				    compute_load_handshake();
				}
			    } else { // load_cfg ==  MORE_THAN_MATRIX2
				length = matrix_d2;
				if (!d1i && !d2i) {
				    pingpong_m1 = !pingpong_m1;
				    pingpong_m2 = !pingpong_m2;
				    compute_load_handshake();
				}
			    }
			    // ESP_REPORT_INFO("COMPUTE: before load hs d1 %u d2 %u", d1, d2);

			    PLM_WORD *inA, *inB;
		    
			    // if (pingpong_m1)
			    // 	inA = &input0[plm_offset_m1];
			    // else
			    // 	inA = &input1[plm_offset_m1];

			    // if (pingpong_m2)
			    // 	inB = &input2[plm_offset_m2];
			    // else
			    // 	inB = &input3[plm_offset_m2];

			    // ESP_REPORT_INFO("COMPUTE: pingpong %u %u offset %u %u",
			    // 		    pingpong_m1, pingpong_m2, plm_offset_m1, plm_offset_m2);

			    // gemm_main(length >> WORDS_PER_DMA_LOG, inA, inB);

			    if (pingpong_m1 && pingpong_m2)
				gemm_main(length >> WORDS_PER_DMA_LOG, &input0[plm_offset_m1], &input2[plm_offset_m2]);
			    else if (pingpong_m1 && !pingpong_m2)
				gemm_main(length >> WORDS_PER_DMA_LOG, &input0[plm_offset_m1], &input3[plm_offset_m2]);
			    else if (!pingpong_m1 && pingpong_m2)
				gemm_main(length >> WORDS_PER_DMA_LOG, &input1[plm_offset_m1], &input2[plm_offset_m2]);
			    else
				gemm_main(length >> WORDS_PER_DMA_LOG, &input1[plm_offset_m1], &input3[plm_offset_m2]);			
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

		        // std:cout << "accumulator[0] " << accumulator[0] << std::endl;

			uint8_t pos = d2 % WORDS_PER_DMA;
			output[store_count].range((pos+1) * WORD_SIZE - 1, pos * WORD_SIZE) =
			    FP2INT(accumulator[0]);
		    
			// Call the store_output process and wait for the store_output process
			// -> output PLM is not in pingpong
			if (pos == WORDS_PER_DMA - 1) {
			    // ESP_REPORT_INFO("sync_comput_store %u %u %u %u %u ", d1, d2, d1i, d2i, loaded_rows_d3);
			    sync_compute_store(store_count, loaded_rows_d3, load_cfg, loadable_rows);
			}
		    }
		}
	    }
	}
    }

    // Force to store the last chunk
    if (store_count) {
	store_count = (DMA_CHUNK >> WORDS_PER_DMA_LOG) - 1;
	sync_compute_store(store_count, 1, load_cfg, loadable_rows);
    }

    // Conclude
    {
	this->process_done();
    }
}
