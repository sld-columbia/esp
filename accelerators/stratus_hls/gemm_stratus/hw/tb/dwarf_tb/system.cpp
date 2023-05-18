// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include <string>
#include <cstring>
#include <sstream>
#include "mojo.h"
#include "dwarf.h"

#include "system.hpp"

#include "fc_dwarf.hpp"
#include "conv_dwarf.hpp"
// #include "validate_hw_gemm.hpp"

mojo::network *cnn;

std::string model_path = "../tb/dwarf_tb/model/dwarf7.mojo";
std::string image_path = "../tb/dwarf_tb/data/ship.bin";


#define IMAGE_SIZE 3 * 32 * 32

void system_t::config_proc()
{
    // Reset
    {
	conf_done.write(false);
	conf_info.write(conf_info_t());
	wait();
    }

    ESP_REPORT_INFO("reset done");

    ESP_REPORT_INFO("Configuration");

    cnn = new mojo::network();
    assert(cnn->read(model_path));
    l=TARGET_LAYER;

    ESP_REPORT_INFO("DWARF7 model loaded");


    //dwarf
    float *image = new float[IMAGE_SIZE];
    std::ifstream infile(image_path.c_str(), std::ifstream::binary);
    assert(infile.read((char *) image, IMAGE_SIZE * sizeof(float)));
    cnn->forward_setup(image);
    delete[] image;

    ESP_REPORT_INFO("DWARF7 image: %s", image_path.c_str());

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



void system_t::run_pv(int layer, bool fully_connected = false)
{

	uint32_t ln=layer;

	if (fully_connected)
		
		gemm_pvt(ln,0,cnn->layer_sets[ln-1]->node.x,cnn->layer_sets[ln-1]->node.x,
			 cnn->layer_sets[ln]->node.x, cnn->W[ln-1]->x,cnn->layer_sets[ln]->bias.x,
			 cnn->layer_sets[ln]->relu,1,cnn->W[ln-1]->rows,cnn->W[ln-1]->cols,
			 cnn->W[ln-1]->get_size());
	else 
	{
                int prev_soft;
		if (ln==1)
			prev_soft=1;
		else
			prev_soft=0;

		conv_pvt(ln,prev_soft,cnn->layer_sets[ln-1]->node.x,cnn->layer_sets[ln-1]->node.x,
			 cnn->layer_sets[ln]->node.x,cnn->W[ln-1]->x,cnn->layer_sets[ln]->bias.x,
			 cnn->layer_sets[ln-1]->node.chans,cnn->layer_sets[ln]->node.chans,
			 cnn->layer_sets[ln-1]->node.cols,cnn->layer_sets[ln-1]->node.rows,
			 cnn->layer_sets[ln]->node.cols,cnn->layer_sets[ln]->node.rows,1,1,
			 cnn->layer_sets[ln]->do_pad,cnn->layer_sets[ln]->do_pad,
			 cnn->W[ln-1]->get_size(),cnn->W[ln-1]->cols,cnn->W[ln-1]->rows,
			 1,1,1,1,1,cnn->layer_sets[ln]->do_pool,cnn->layer_sets[ln-1]->do_pool);
	}
}

// Functions
void system_t::load_memory()
{


#ifndef TARGET_LAYER_1
	run_pv(1,false);
#ifndef TARGET_LAYER_2
	run_pv(2,false);
#ifndef TARGET_LAYER_3
	run_pv(3,false);
#ifndef TARGET_LAYER_4
	run_pv(4,false);
#ifndef TARGET_LAYER_5
	run_pv(5, true);
#ifndef TARGET_LAYER_6
	run_pv(6, true);
#else
	setup_memory(6, true);
#endif 
#else
	setup_memory(5, true);
#endif 
#else
	setup_memory(4, false);
#endif 
#else
	setup_memory(3, false);
#endif 
#else
	setup_memory(2, false);
#endif 
#else
	setup_memory(1, false);
#endif 

}


void system_t::setup_memory(int target_layer, bool fully_connected)
{

    sc_dt::sc_bv<WORD_SIZE> data;
    uint32_t ln=target_layer;

    indexA = 0;
    indexB = 0;

    //
    // Matrix 1
    //

//    ESP_REPORT_INFO("esc_argv %s", esc_argv()[1]);

    if (load_double_matrix_t1(&matrix_inA, cnn->W[ln-1]->x,1,cnn->W[ln-1]->rows,cnn->W[ln-1]->cols,0) < 0)
    {
	ESP_REPORT_ERROR("reading matrix A failed!\n");
	sc_stop();
    }

    if (load_double_matrix_t1(&matrix_inB, cnn->layer_sets[ln-1]->node.x,1,cnn->W[ln-1]->cols,1,1) < 0)
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
    int relu=cnn->layer_sets[l]->relu;
    int wr=cnn->W[l-1]->rows;
    float* out=new float[wr-1];
    float* layer_bias=cnn->layer_sets[l]->bias.x;

    //Run reamining layers with programmer's view

    for (int i=l;i<=6;i++)
    {
	    if (i<=4)
		    run_pv(i,false);
	    else
		    run_pv(i,true);
    }

    std::cout << "Programmer's view-based network results:" << std::endl;
    int first = mojo::arg_max(cnn->layer_sets[6]->node.x, cnn->out_size());
    std::cout << "  1: label|score: \t\"" << labels[first] << "\" | " << cnn->layer_sets[6]->node.x[first] << std::endl;

    cnn->layer_sets[6]->node.x[first] = -1;
    int second = mojo::arg_max(cnn->layer_sets[6]->node.x, cnn->out_size());
    std::cout << "  2: label|score: \t\"" << labels[second] << "\" | " << cnn->layer_sets[6]->node.x[second] << std::endl;


    //Run remaining layers with programmer's view and accelerator input

    for( int i = 0; i < wr; i = i + 1 ) {
    	    out[i]=(float)matrix_out->data[i];
    }

    cnn->layer_sets[l]->node.x=out;
    gemm_pp(out,layer_bias,wr,relu);

    for (int i=l+1;i<=6;i++)
    {
	    if (i<=4)
		    run_pv(i,false);
	    else
		    run_pv(i,true);
    }

    std::cout << "\n \nProgrammer's view + layer "<<l<<" accelerator invocation results\
:" << std::endl;
    int first_n = mojo::arg_max(cnn->layer_sets[6]->node.x, cnn->out_size());
    std::cout << "  1: label|score: \t\"" << labels[first_n] << "\" | " << cnn->layer_sets[6]->node.x[first_n] << std::endl;

    cnn->layer_sets[6]->node.x[first_n] = -1;
    int second_n = mojo::arg_max(cnn->layer_sets[6]->node.x, cnn->out_size());
    std::cout << "  2: label|score: \t\"" << labels[second_n] << "\" | " << cnn->layer_sets[6]->node.x[second_n] << std::endl;

    return 0;

}

