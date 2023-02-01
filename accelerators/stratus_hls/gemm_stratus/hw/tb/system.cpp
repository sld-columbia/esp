// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include <string>
#include <cstring>
#include <sstream>
#include "system.hpp"
#include "validation.hpp"

void system_t::config_proc()
{

    // Reset
    {
	conf_done.write(false);
	conf_info.write(conf_info_t());
	wait();
    }

    ESP_REPORT_INFO("reset done");

    // Config
    load_memory();
    {
    	// Custom configuration
    	conf_info_t config;

    	// Custom configuration
    	config.ninputs = matrix_inA->dims[0];
    	config.transpose = matrix_inB->is_transposed;
    	config.d1 = matrix_inA->dims[1];
    	config.d2 = matrix_inA->dims[2];
    	config.d3 = matrix_inB->dims[2];
    	config.ld_offset1 = 0;
    	config.ld_offset2 = indexA * WORDS_PER_DMA;
    	config.st_offset  = indexB * WORDS_PER_DMA;
    	config.do_relu = 0;

    	wait(); conf_info.write(config);
    	conf_done.write(true);
    }

    ESP_REPORT_INFO("config done");

    // Compute
    {
    	// Print information about begin time
    	sc_time begin_time = sc_time_stamp();
    	ESP_REPORT_TIME(begin_time, "BEGIN - gemm");

    	// Wait the termination of the accelerator
    	do { wait(); } while (!acc_done.read());
    	debug_info_t debug_code = debug.read();

    	// Print information about end time
    	sc_time end_time = sc_time_stamp();
    	ESP_REPORT_TIME(end_time, "END - gemm");

    	esc_log_latency(sc_object::basename(), clock_cycle(end_time - begin_time));
    	wait(); conf_done.write(false);
    }

    // Validate
    {
    	dump_memory(); // store the output in more suitable data structure if needed
    	// check the results with the golden model
    	if (validate())
    	{
    	    ESP_REPORT_ERROR("validation failed!");
    	} else
    	{
    	    ESP_REPORT_INFO("validation passed!");
    	}

    	debug_info_t debug_code = debug.read();
    	if (debug_code != 0) { goto free_and_terminate; }

    	store_double_matrix_t(matrix_out, esc_argv()[3]);
    	free_double_matrix_t(&matrix_out_gold);
    	free_double_matrix_t(&matrix_out);

    free_and_terminate:
    	free_double_matrix_t(&matrix_inA);
    	free_double_matrix_t(&matrix_inB);

    }

    // Conclude
    {
	sc_stop();
    }
}

// Functions
void system_t::load_memory()
{
    // Optional usage check
    if (esc_argc() != 4)
    {
        ESP_REPORT_ERROR("usage: %s <input1> <input2> <output> \n", esc_argv()[0]);
        sc_stop();
    }

    //  Memory allocation:
    //
    //  =========================   ^
    //  |     matrix (input1)   |   |  (matrix_inA->dim[0] * matrix_inA->dim[1])
    //  =========================   ^
    //  |     matrix (input2)   |   |  (matrix_inB->dim[0] * matrix_inB->dim[1])
    //  =========================   v
    //  |     matrix (output)   |   |  (matrix_inA->dim[0] * matrix_inB->dim[1])
    //  =========================   v

    sc_dt::sc_bv<WORD_SIZE> data;

    indexA = 0;
    indexB = 0;

    //
    // Matrix 1
    //

    ESP_REPORT_INFO("esc_argv %s", esc_argv()[1]);

    if (load_double_matrix_t(&matrix_inA, esc_argv()[1]) < 0)
    {
	ESP_REPORT_ERROR("reading matrix A failed!\n");
	sc_stop();
    }

    if (load_double_matrix_t(&matrix_inB, esc_argv()[2]) < 0)
    {
        ESP_REPORT_ERROR("reading matrix B failed!\n");
        sc_stop();
    }

    assert(matrix_inA->dims[2] == matrix_inB->dims[1]);

    // Set member variables
    batch_size = matrix_inA->dims[0];
    is_transposed = matrix_inB->is_transposed;
    rowsA = matrix_inA->dims[1];
    colsA = matrix_inA->dims[2];
    rowsB = matrix_inB->dims[1];
    colsB = matrix_inB->dims[2];
    rowsB_actual = is_transposed ? colsB : rowsB;
    colsB_actual =is_transposed ? rowsB : colsB;
    size_inA = rowsA * colsA;
    size_inB = colsA * colsB;
    size_out = rowsA * colsB;


    ESP_REPORT_INFO("Matrix A. Batch size: %d", batch_size);
    ESP_REPORT_INFO("Matrix A. # of rows:  %d", rowsA);
    ESP_REPORT_INFO("Matrix A. # of cols:  %d", colsA);

    ESP_REPORT_INFO("Matrix B. Batch size: %d", batch_size);
    ESP_REPORT_INFO("Matrix B. # of rows:  %d", rowsB);
    ESP_REPORT_INFO("Matrix B. # of cols:  %d", colsB);

    uint32_t k = 0;
    for (uint32_t b = 0; b < batch_size; ++b)
    {
    	for (uint32_t d1 = 0; d1 < rowsA; ++d1)
    	{
    	    for (uint32_t d2 = 0; d2 < colsA; ++d2)
    	    {
    		data = fp2bv<FPDATA, WORD_SIZE>(FPDATA((float) matrix_inA->data[k++]));

    		// TODO works only for WORDS_PER_DMA = {1, 2}
    		if (!((k-1) % WORDS_PER_DMA))
    		    (this->mem[indexA]) = data  | this->mem[indexA];
    		else
    		    (this->mem[indexA]) = (data << WORD_SIZE) | this->mem[indexA];

    		if ((k-1) % WORDS_PER_DMA == WORDS_PER_DMA - 1)
    		    indexA++;
    	    }
    	}
    }

    //
    // Matrix 2
    //

    indexB = indexA;

    k = 0;
    for (uint32_t b = 0; b < batch_size; ++b)
    {
    	for (uint32_t d1 = 0; d1 < rowsB_actual; ++d1)
    	{
    	    for (uint32_t d2 = 0; d2 < colsB_actual; ++d2)
    	    {
    		data = fp2bv<FPDATA, WORD_SIZE>(FPDATA(matrix_inB->data[k++]));

    		// TODO works only for WORDS_PER_DMA = {1, 2}
    		if (!((k-1) % WORDS_PER_DMA))
    		    (this->mem[indexB]) = data | this->mem[indexB];
    		else
    		    (this->mem[indexB]) = (data << WORD_SIZE) | this->mem[indexB];

    		if ((k-1) % WORDS_PER_DMA == WORDS_PER_DMA - 1)
    		    indexB++;
    	    }
    	}
    }

    ESP_REPORT_INFO("load memory completed");
}

void system_t::dump_memory()
{
    // Get results from memory
    FPDATA elem;
    sc_dt::sc_bv<DMA_WIDTH> data;

    std::cout <<  "Dump memory " << std::endl;

    size_t sizes[M_DIMS] = {batch_size, rowsA, colsB};

    create_double_matrix_t(&matrix_out, sizes, M_DIMS);

    uint32_t k = 0;
    for (uint32_t i = 0; i < round_up((batch_size * rowsA * colsB), WORDS_PER_DMA)
	     / WORDS_PER_DMA; ++i)
    {
	data = this->mem[indexB++];

	for (uint32_t w = 0; w < WORDS_PER_DMA; ++w) {

	    bv2fp<FPDATA, WORD_SIZE>(elem, data.range((w+1) * WORD_SIZE - 1, w * WORD_SIZE));

	    if (k < batch_size*rowsA*colsB)
		matrix_out->data[k++] = elem.to_double();
	}
    }

    ESP_REPORT_INFO("dump memory completed");
}

int system_t::validate()
{
    double rel_error = 0.0;
    double avg_error = 0.0;
    double max_error = 0.0;
    uint32_t tot_errors = 0;

    std::cout << "Validate" << std::endl;

    // Compute golden output
    // Call the programmer's view function
    gemm_pv(matrix_inA, matrix_inB, &matrix_out_gold);

    // Check for mismatches
    for (uint32_t d2 = 0; d2 < size_out * batch_size; ++d2)
    {
        if (check_error_threshold(matrix_out->data[d2], matrix_out_gold->data[d2], rel_error))
        {
            if (tot_errors < REPORT_THRESHOLD)
            {
                ESP_REPORT_INFO("gemm[%d] = %lf (%lf) error: %.2lf%%", d2,
                  matrix_out->data[d2], matrix_out_gold->data[d2], rel_error * 100);
            }

            tot_errors++;
        }

	// ESP_REPORT_INFO("gemm[%d] = %lf (%lf) error: %.2lf%%", d2,
	// 		matrix_out->data[d2], matrix_out_gold->data[d2], rel_error * 100);

        // Tracking the maximum error w.r.t. the programmer's view
        if (rel_error > max_error) { max_error = rel_error; }

        // Tracking the average error w.r.t. the programmer's view
        avg_error += rel_error;
    }

    avg_error /= (double) (size_out * batch_size);

    // Report results
    ESP_REPORT_INFO("errors #%d out of #%d", tot_errors, size_out * batch_size);
    ESP_REPORT_INFO("average error: %.2lf%%", avg_error * 100);
    ESP_REPORT_INFO("maximum error: %.2lf%%", max_error * 100);

    if (tot_errors > 0)
        { ESP_REPORT_ERROR("validation failed!"); }
    else
        { ESP_REPORT_INFO("validation succeeded!"); }

    ESP_REPORT_INFO("total memory #%d bytes",
      (unsigned int) (indexB * 4UL) / 1000UL);

    return tot_errors;
}
