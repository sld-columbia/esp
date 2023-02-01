// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "gemm.hpp"
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
    uint32_t index_d1_n;
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
    uint16_t m2_loop_iters, length_m2_dma;
    uint32_t index_m2_incr;
    uint16_t m2_plm_incr;

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
        index_d1_n = 0;
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
	m2_loop_iters = 0;
	length_m2_dma = 0;
	index_m2_incr = 0;
	m2_plm_incr = 0;

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
    			 load_cfg, loadable_rows, loadable_chunk, index_d1_incr,
			 m2_loop_iters, m2_plm_incr);

    	{
    	    HLS_DEFINE_PROTOCOL("load-config-sig");
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

    	index_d1_n = ld_offset1;
    	index_d2 = ld_offset2;
	index_m2_incr = matrix_d3;
	length_m2_dma = 1;

        // ESP_REPORT_INFO("WORDS_PER_DMA %d", WORDS_PER_DMA);

        // ESP_REPORT_INFO("LOAD %u %u %u %u %u %u %u %u %u %u %u",
    	// 		(unsigned) size_matrix1, (unsigned) size_matrix2,
    	// 		(unsigned) matrix_chk_in, (unsigned) matrix_rem_in1, (unsigned) matrix_rem_in2,
    	// 		(unsigned) matrix_chk_out, (unsigned) matrix_rem_out,
    	// 		(unsigned) load_cfg, (unsigned) loadable_rows,
    	// 		(unsigned) loadable_chunk, (unsigned) index_d1_incr);

    	load_compute_cfg_handshake();
    	load_store_cfg_handshake();
    }
    
    // Load
    for (uint24_t a = 0; a < ninputs; a++)
    {
    	index_d1 = index_d1_n;

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
    			    dma_info_t dma_info(index_d1_tmp >> WORDS_PER_DMA_LOG,
						round_up(length1, WORDS_PER_DMA) >> WORDS_PER_DMA_LOG,
						SIZE_WORD);
    			    this->dma_read_ctrl.put(dma_info);

                            // ESP_REPORT_INFO("load m1 %u %u",
                            // 		    (unsigned) index_d1_tmp, (unsigned) round_up(length1, WORDS_PER_DMA));
    			}

    			i = 0;

			bool misaligned = index_d1_tmp & 1 & (WORDS_PER_DMA - 1);

    			for (uint16_t k = 0; k < round_up(length1 + misaligned, WORDS_PER_DMA) >> WORDS_PER_DMA_LOG; ++k)
    			{
    			    sc_dt::sc_bv<DMA_WIDTH> data = this->dma_read_chnl.get();

    			    {
    				// This ensures the maximum throughput
    				HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "load-matrix1");
				HLS_BREAK_ARRAY_DEPENDENCY(input0);
				HLS_BREAK_ARRAY_DEPENDENCY(input1);

#if (WORDS_PER_DMA == 2)                                
				if (pingpong_m1) {

				    if (!(misaligned && !k))
					input0[i++] = data.range(31,0).to_uint();
				    if (i < DMA_CHUNK)
					input0[i++] = data.range(63,32).to_uint();
				} else {
				    if (!(misaligned && !k))
					input1[i++] = data.range(31,0).to_uint();
				    if (i < DMA_CHUNK)
					input1[i++] = data.range(63,32).to_uint();
				}
#else
				if (pingpong_m1) {
                                    input0[i++] = data.to_uint();
				} else {
                                    input1[i++] = data.to_uint();
				}
#endif
				// i+=2;
    			    }
			    wait(); // Only considered in behavioral simulation
    			}
    			pingpong_m1 = !pingpong_m1;
    		    }

    		    //
    		    // 2. Load chunks of the second matrix in PLMs input2 and input3
    		    //

    		    // TODO
    		    // This does not work when WORDS_PER_DMA != 1
		    if (transpose || matrix_d3 == 1) {
    			length_m2_dma = length2;
    			index_m2_incr = length2;
		    } else {
			if (load_cfg == LESS_THAN_ROW) {
			    m2_loop_iters = length2;
			} else if (load_cfg == LESS_THAN_MATRIX2) {
			    length_m2_dma = min(loadable_rows, matrix_d3 - d2);
			    // ESP_REPORT_INFO("here1 %d", length_m2_dma);
			}
		    }

		    int16_t base_i = 0;
    		    i = 0;
    		    for (uint16_t t = 0; t < m2_loop_iters; ++t)
    		    {
			i = base_i;
    			{
    			    HLS_DEFINE_PROTOCOL("load-matrix2-info");

    			    dma_info_t dma_info(index_m2_dma >> WORDS_PER_DMA_LOG,
    						round_up(length_m2_dma, WORDS_PER_DMA) >> WORDS_PER_DMA_LOG, SIZE_WORD);
    			    this->dma_read_ctrl.put(dma_info);

    			    // ESP_REPORT_INFO("load m2 %u %u",
    			    // 		    (unsigned) index_m2_dma, (unsigned) round_up(length_m2_dma, WORDS_PER_DMA));
    			}

			bool misaligned = index_m2_dma & 1 & (WORDS_PER_DMA - 1);

    			for (uint16_t k = 0; k < round_up(length_m2_dma + misaligned,
							  WORDS_PER_DMA) >> WORDS_PER_DMA_LOG; ++k)
    			{
    			    sc_dt::sc_bv<DMA_WIDTH> data = this->dma_read_chnl.get();

			    {
				// This ensures the maximum throughput
				HLS_DEFINE_PROTOCOL("protocol-load-matrix2");
				HLS_BREAK_ARRAY_DEPENDENCY(input2);
				HLS_BREAK_ARRAY_DEPENDENCY(input3);

#if (WORDS_PER_DMA != 2)
                                if (pingpong_m2)
                                    input2[i] = data.to_uint();
                                else
                                    input3[i] = data.to_uint();
                                i += m2_plm_incr;
#else        
				if (!(misaligned && !k)) {
				    if (pingpong_m2)
					input2[i] = data.range(31,0).to_uint();
				    else
					input3[i] = data.range(31,0).to_uint();
				    i += m2_plm_incr;
				}
				if (i < DMA_CHUNK) {
				    if (m2_plm_incr != 1) {
					wait();
				    }
				    if (pingpong_m2)
					input2[i] = data.range(63,32).to_uint();
				    else
					input3[i] = data.range(63,32).to_uint();
				    i += m2_plm_incr;
				}
#endif
				wait();
			    }
    			}

    			index_m2_dma += index_m2_incr;
			base_i++;
    		    }
		    
    		    // Call the compute_kernel process
    		    load_compute_handshake();

    		    // Change pingpong buffer
    		    pingpong_m2 = !pingpong_m2;

    		    // Update the indices
    		    index_d1_tmp += length1;
    		    if (transpose)
    			index_d2_tmp += length_m2_dma; 
    		}
    		if (!transpose)
    		    index_d2_tmp += loadable_rows;
    	    }
    	    index_d1 += index_d1_incr;
    	}
    	index_d2 += size_matrix2;
    	index_d1_n += size_matrix1;
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
    bool pingpong;
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
	pingpong = false;
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
    	    HLS_DEFINE_PROTOCOL("store-config-sig");
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

    	// ESP_REPORT_INFO("STORE %u %u %u", (unsigned) size_matrix_out,
    	// 		(unsigned) matrix_chk_out, (unsigned) matrix_rem_out);
    }

    // Store
    uint32_t index = 0;
    uint32_t index_simple = st_offset;
    uint16_t length = OUT_DMA_CHUNK;
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
    			// ESP_REPORT_INFO("STORE: before compute hs %u %u %u %u",
    			// 		(unsigned) d1, (unsigned) d2, (unsigned) d1i, (unsigned) chk);
    			store_compute_handshake();
    			// ESP_REPORT_INFO("STORE: after compute hs %u %u %u %u",
    			// 		(unsigned) d1, (unsigned) d2, (unsigned) d1i, (unsigned) chk);

    			{
    			    HLS_DEFINE_PROTOCOL("store-matrix-info");
    			    dma_info_t dma_info(index >> WORDS_PER_DMA_LOG,
						round_up(length, WORDS_PER_DMA) >> WORDS_PER_DMA_LOG,
						SIZE_WORD);
    			    this->dma_write_ctrl.put(dma_info);

    			    // ESP_REPORT_INFO("STORE index %u length %u",
    			    // 		    (unsigned) index, (unsigned) length);
    			}

    			i = 0;
    			for (uint16_t k = 0; k < round_up(length, WORDS_PER_DMA) >> WORDS_PER_DMA_LOG; ++k)
    			{
    			    sc_dt::sc_bv<DMA_WIDTH> data = 0;

    			    {
    				// This ensures the maximum throughput
    				HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "store-matrix");
				
				if (pingpong) {
				    data.range(31,0) = output0[i++];
#if (WORDS_PER_DMA == 2)
				    data.range(63,32) = output0[i++];
#endif
				} else {
				    data.range(31,0) = output1[i++];
#if (WORDS_PER_DMA == 2)
				    data.range(63,32) = output1[i++];
#endif
				}

    				wait(); // Only considered in behavioral simulation
    			    }

    			    this->dma_write_chnl.put(data);
    			}

			// toggle pingpong
			pingpong = !pingpong;

    			// update the index
    			index_simple += length;
    		    }
    		    index_d1i += matrix_d3;
    		}
    		index_d2 += loadable_rows;
    	    }
    	    index_d1 += (loadable_rows * matrix_d3);
    	}
    	index_a += (size_matrix_out / ninputs);
    }

    // Conclude
    {
    	this->accelerator_done();
    	this->process_done();
    }
}

void gemm::compute_kernel()
{
    bool pingpong_m1, pingpong_m2, pingpong_out;
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
        pingpong_out = false;
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

	wait();

        // ESP_REPORT_INFO("COMPUTE %u %u %u %u %u",
    	// 		(unsigned) matrix_chk_in, (unsigned) matrix_rem_in1, (unsigned) matrix_rem_in2,
    	// 		(unsigned) load_cfg, (unsigned) loadable_rows);
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

    		if (load_cfg != LESS_THAN_ROW)
    		    compute_load_handshake();

    		for (uint16_t d1i = 0; d1i < loaded_rows_d1; d1i++)
    		{
    		    plm_offset_m1 = d1i * matrix_d2;

    		    for (uint16_t d2i = 0; d2i < loaded_rows_d3; d2i++)
    		    {
    			plm_offset_m2 = d2i * matrix_d2;

			// reset accumulator register
			accumulator = 0;

    			for (uint24_t chk = 0; chk < matrix_chk_in; ++chk)
    			{
    			    // If true the next is the last (smaller) chunk
    			    if (load_cfg == LESS_THAN_ROW) {
    				if (chk == matrix_chk_in - 1 && matrix_rem_in2 != 0) {
    				    length = matrix_rem_in2;
    				} else {
    				    length = DMA_CHUNK;
    				}
    				pingpong_m1 = !pingpong_m1;
    				pingpong_m2 = !pingpong_m2;
    				compute_load_handshake();
    			    } else if (load_cfg == LESS_THAN_MATRIX2) {
    				length = matrix_d2;
    				if (!d1i && !d2i) {
    				    if (!d2)
    					pingpong_m1 = !pingpong_m1;
    				    pingpong_m2 = !pingpong_m2;
    				}
    			    } else { // load_cfg ==  MORE_THAN_MATRIX2
    				length = matrix_d2;
    				if (!d1i && !d2i) {
    				    pingpong_m1 = !pingpong_m1;
    				    pingpong_m2 = !pingpong_m2;
    				}
    			    }

			    uint16_t plm_i_row = plm_offset_m1;
			    uint16_t plm_i_col = plm_offset_m2;
			    for (uint16_t k = 0; k < (length + PARALLELISM - 1) / PARALLELISM; ++k)
			    {
				//HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "constrain-mac");
#ifdef FIXED_POINT
 				HLS_PIPELINE_LOOP(HARD_STALL, 2, "pipeline-mac-fixed");
#else
 				HLS_PIPELINE_LOOP(HARD_STALL, 2, "pipeline-mac-float");
#endif
				HLS_BREAK_ARRAY_DEPENDENCY(input0);
				HLS_BREAK_ARRAY_DEPENDENCY(input1);
				HLS_BREAK_ARRAY_DEPENDENCY(input2);
				HLS_BREAK_ARRAY_DEPENDENCY(input3);

				if (pingpong_m1) {
				    row[0] = INT2FP(input0[plm_i_row++]);
				    row[1] = INT2FP(input0[plm_i_row++]);
#if (PARALLELISM >= 4)
				    row[2] = INT2FP(input0[plm_i_row++]);
				    row[3] = INT2FP(input0[plm_i_row++]);
#endif
#if (PARALLELISM >= 8)
				    row[4] = INT2FP(input0[plm_i_row++]);
				    row[5] = INT2FP(input0[plm_i_row++]);
				    row[6] = INT2FP(input0[plm_i_row++]);
				    row[7] = INT2FP(input0[plm_i_row++]);
#endif
#if (PARALLELISM >= 16)
				    row[8] = INT2FP(input0[plm_i_row++]);
				    row[9] = INT2FP(input0[plm_i_row++]);
				    row[10] = INT2FP(input0[plm_i_row++]);
				    row[11] = INT2FP(input0[plm_i_row++]);
				    row[12] = INT2FP(input0[plm_i_row++]);
				    row[13] = INT2FP(input0[plm_i_row++]);
				    row[14] = INT2FP(input0[plm_i_row++]);
				    row[15] = INT2FP(input0[plm_i_row++]);
#endif
				} else {
				    row[0] = INT2FP(input1[plm_i_row++]);
				    row[1] = INT2FP(input1[plm_i_row++]);
#if (PARALLELISM >= 4)
				    row[2] = INT2FP(input1[plm_i_row++]);
				    row[3] = INT2FP(input1[plm_i_row++]);
#endif
#if (PARALLELISM >= 8)
				    row[4] = INT2FP(input1[plm_i_row++]);
				    row[5] = INT2FP(input1[plm_i_row++]);
				    row[6] = INT2FP(input1[plm_i_row++]);
				    row[7] = INT2FP(input1[plm_i_row++]);
#endif
#if (PARALLELISM >= 16)
				    row[8] = INT2FP(input1[plm_i_row++]);
				    row[9] = INT2FP(input1[plm_i_row++]);
				    row[10] = INT2FP(input1[plm_i_row++]);
				    row[11] = INT2FP(input1[plm_i_row++]);
				    row[12] = INT2FP(input1[plm_i_row++]);
				    row[13] = INT2FP(input1[plm_i_row++]);
				    row[14] = INT2FP(input1[plm_i_row++]);
				    row[15] = INT2FP(input1[plm_i_row++]);
#endif

				}
				if (pingpong_m2) {
				    col[0] = INT2FP(input2[plm_i_col++]);
				    col[1] = INT2FP(input2[plm_i_col++]);
#if (PARALLELISM >= 4)
				    col[2] = INT2FP(input2[plm_i_col++]);
				    col[3] = INT2FP(input2[plm_i_col++]);
#endif
#if (PARALLELISM >= 8)
				    col[4] = INT2FP(input2[plm_i_col++]);
				    col[5] = INT2FP(input2[plm_i_col++]);
				    col[6] = INT2FP(input2[plm_i_col++]);
				    col[7] = INT2FP(input2[plm_i_col++]);
#endif
#if (PARALLELISM >= 16)
				    col[8] = INT2FP(input2[plm_i_col++]);
				    col[9] = INT2FP(input2[plm_i_col++]);
				    col[10] = INT2FP(input2[plm_i_col++]);
				    col[11] = INT2FP(input2[plm_i_col++]);
				    col[12] = INT2FP(input2[plm_i_col++]);
				    col[13] = INT2FP(input2[plm_i_col++]);
				    col[14] = INT2FP(input2[plm_i_col++]);
				    col[15] = INT2FP(input2[plm_i_col++]);
#endif
				} else {
				    col[0] = INT2FP(input3[plm_i_col++]);
				    col[1] = INT2FP(input3[plm_i_col++]);
#if (PARALLELISM >= 4)
				    col[2] = INT2FP(input3[plm_i_col++]);
				    col[3] = INT2FP(input3[plm_i_col++]);
#endif
#if (PARALLELISM >= 8)
				    col[4] = INT2FP(input3[plm_i_col++]);
				    col[5] = INT2FP(input3[plm_i_col++]);
				    col[6] = INT2FP(input3[plm_i_col++]);
				    col[7] = INT2FP(input3[plm_i_col++]);
#endif
#if (PARALLELISM >= 16)
				    col[8] = INT2FP(input3[plm_i_col++]);
				    col[9] = INT2FP(input3[plm_i_col++]);
				    col[10] = INT2FP(input3[plm_i_col++]);
				    col[11] = INT2FP(input3[plm_i_col++]);
				    col[12] = INT2FP(input3[plm_i_col++]);
				    col[13] = INT2FP(input3[plm_i_col++]);
				    col[14] = INT2FP(input3[plm_i_col++]);
				    col[15] = INT2FP(input3[plm_i_col++]);
#endif
				}

				uint16_t plm_i = k * PARALLELISM + 1;
				mult_out[0] = row[0] * col[0];
				if (plm_i < length)
				    mult_out[1] =  row[1] * col[1];
				else
				    mult_out[1] = 0;
#if (PARALLELISM >= 4)
				if (plm_i + 1 < length)
				    mult_out[2] = row[2] * col[2];
				else
				    mult_out[2] = 0;
				if (plm_i + 2 < length)
				    mult_out[3] = row[3] * col[3];
				else
				    mult_out[3] = 0;
#endif
#if (PARALLELISM >= 8)
				if (plm_i + 3 < length)
				    mult_out[4] = row[4] * col[4];
				else
				    mult_out[4] = 0;
				if (plm_i + 4 < length)
				    mult_out[5] = row[5] * col[5];
				else
				    mult_out[5] = 0;
				if (plm_i + 5 < length)
				    mult_out[6] = row[6] * col[6];
				else
				    mult_out[6] = 0;
				if (plm_i + 6 < length)
				    mult_out[7] = row[7] * col[7];
				else
				    mult_out[7] = 0;
#endif
#if (PARALLELISM >= 16)
				if (plm_i + 7 < length)
				    mult_out[8] = row[8] * col[8];
				else
				    mult_out[8] = 0;
				if (plm_i + 8 < length)
				    mult_out[9] = row[9] * col[9];
				else
				    mult_out[9] = 0;
				if (plm_i + 9 < length)
				    mult_out[10] = row[10] * col[10];
				else
				    mult_out[10] = 0;
				if (plm_i + 10 < length)
				    mult_out[11] = row[11] * col[11];
				else
				    mult_out[11] = 0;
				if (plm_i + 11 < length)
				    mult_out[12] = row[12] * col[12];
				else
				    mult_out[12] = 0;
				if (plm_i + 12 < length)
				    mult_out[13] = row[13] * col[13];
				else
				    mult_out[13] = 0;
				if (plm_i + 13 < length)
				    mult_out[14] = row[14] * col[14];
				else
				    mult_out[14] = 0;
				if (plm_i + 14 < length)
				    mult_out[15] = row[15] * col[15];
				else
				    mult_out[15] = 0;
#endif

#if (PARALLELISM == 2)
				accumulator += mult_out[0] + mult_out[1];
#elif (PARALLELISM == 4)
				FPDATA add_tmp0 = mult_out[0] + mult_out[1];
				FPDATA add_tmp1 = mult_out[2] + mult_out[3];
				accumulator += add_tmp0 + add_tmp1;
#elif (PARALLELISM == 8)
				FPDATA add_tmp0 = mult_out[0] + mult_out[1];
				FPDATA add_tmp1 = mult_out[2] + mult_out[3];
				FPDATA add_tmp2 = mult_out[4] + mult_out[5];
				FPDATA add_tmp3 = mult_out[6] + mult_out[7];
				FPDATA add_tmp4 = add_tmp0 + add_tmp1;
				FPDATA add_tmp5 = add_tmp2 + add_tmp3;
				accumulator += add_tmp4 + add_tmp5;
#elif (PARALLELISM == 16)
				FPDATA add_tmp0 = mult_out[0] + mult_out[1];
				FPDATA add_tmp1 = mult_out[2] + mult_out[3];
				FPDATA add_tmp2 = mult_out[4] + mult_out[5];
				FPDATA add_tmp3 = mult_out[6] + mult_out[7];
				FPDATA add_tmp4 = mult_out[8] + mult_out[9];
				FPDATA add_tmp5 = mult_out[10] + mult_out[11];
				FPDATA add_tmp6 = mult_out[12] + mult_out[13];
				FPDATA add_tmp7 = mult_out[14] + mult_out[15];
				FPDATA add_tmp8 = add_tmp0 + add_tmp1;
				FPDATA add_tmp9 = add_tmp2 + add_tmp3;
				FPDATA add_tmp10 = add_tmp4 + add_tmp5;
				FPDATA add_tmp11 = add_tmp6 + add_tmp7;
				FPDATA add_tmp12 = add_tmp8 + add_tmp9;
				FPDATA add_tmp13 = add_tmp10 + add_tmp11;
				accumulator += add_tmp12 + add_tmp13;
#endif
			    }

    			}

			// ReLU
			accumulator = (do_relu && accumulator < (FPDATA) 0) ? (FPDATA) 0 : accumulator;

			// Write to output PLM
			if (pingpong_out) {
			    output0[store_count] = FP2INT(accumulator);
			} else {
			    output1[store_count] = FP2INT(accumulator);
			}

    			// Call the store_output process and wait for the store_output process
    			// -> output PLM is not in pingpong

			sync_compute_store(store_count, loaded_rows_d3, load_cfg,
					   loadable_rows, pingpong_out);
    		    }
    		}
    	    }
    	}
    }

    // Force to store the last chunk
    if (store_count) {
    	store_count = OUT_DMA_CHUNK - 1;
    	sync_compute_store(store_count, 1, load_cfg, loadable_rows, pingpong_out);
    }

    // Conclude
    {
	this->process_done();
    }
}
