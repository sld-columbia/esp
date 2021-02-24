// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include <string>
#include <cstring>
#include <sstream>
#include "system.hpp"
#include "validation.hpp"

#include "mojo.h"
#include "dwarf.h"

mojo::network *cnn;

std::string model_path = "../models/dwarf7.mojo";
std::string image_path = "truck.bin";


#define IMAGE_SIZE 3 * 32 * 32
#define TARGET_LAYER_6

int l=0;

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



void system_t::run_pv(int layer, bool fully_connected = false)
{

	if (fully_connected)
		
		gemm_pvt(layer,cnn->layer_sets[layer-1]->node.x, cnn->layer_sets[layer]->bias.x, cnn->layer_sets[layer]->relu, cnn->W[layer-1]->x,
			 cnn->W[layer-1]->rows, cnn->W[layer-1]->cols, cnn->W[layer-1]->get_size(),cnn->layer_sets[layer]->node.x);
	else //to modify with conv2d_pv
		convolution_compute(cnn->layer_sets[layer]->node.x,
				    cnn->layer_sets[layer]->bias.x,
				    cnn->layer_sets[layer - 1]->node.x,
				    cnn->W[layer - 1]->x,
				    cnn->layer_sets[layer]->node.cols,
				    cnn->layer_sets[layer]->node.rows,
				    cnn->layer_sets[layer - 1]->node.chans,
				    cnn->layer_sets[layer]->node.chans,
				    get_pool_size(cnn->layer_sets[layer]->node.cols,
						  cnn->layer_sets[layer]->node.rows,
						  cnn->layer_sets[layer]->do_pool,
						  cnn->layer_sets[layer]->do_pad),
				    get_pool_stride(cnn->layer_sets[layer]->node.cols,
						    cnn->layer_sets[layer]->node.rows,
						    cnn->layer_sets[layer]->do_pool,
						    cnn->layer_sets[layer]->do_pad),
				    cnn->layer_sets[layer]->do_pool,
				    cnn->layer_sets[layer]->do_pad);
}

// Functions
void system_t::load_memory()
{

        ESP_REPORT_INFO("Configuration");

	cnn = new mojo::network();
	assert(cnn->read(model_path));

	ESP_REPORT_INFO("DWARF7 model loaded");


	//dwarf
	//int l=0;
	float *image = new float[IMAGE_SIZE];
	std::ifstream infile(image_path.c_str(), std::ifstream::binary);
	assert(infile.read((char *) image, IMAGE_SIZE * sizeof(float)));
	cnn->forward_setup(image);
	delete[] image;

	ESP_REPORT_INFO("DWARF7 image: %s", image_path.c_str());


#ifndef TARGET_LAYER_1
	// convolution 34x34 (including pad of 2 pixels), kernel
	//  size 3x3, 32 output channels, relu
	run_pv(1);
#ifndef TARGET_LAYER_2
	// convolution 34x34 (including pad of 2 pixels), kernel
	// size 3x3, 32 output channels, relu, max pooling 2x2 (pad on output -> 18x18)
	run_pv(2);

	//
	// Convolution type 3
	//
#ifndef TARGET_LAYER_3
	// convolution 18x18 (including pad of 2 pixels), kernel
	//  size 3x3, 64 output channels, relu, max pooling 2x2 (pad on output -> 10x10)
	run_pv(3);

	//
	// Convolution type 4
	//
#ifndef TARGET_LAYER_4
	// convolution 10x10 (including pad of 2 pixels), kernel
	//  size 3x3, 128 output channels, relu, max pooling 2x2 (no pad on output -> 4x4)
	run_pv(4);

	//
	// Fully Connected
	//
#ifndef TARGET_LAYER_5
	// fully_connected 1x1, 2048 to 64 channels, relu
	run_pv(5, true);
	
#ifndef TARGET_LAYER_6
	// fully_connected 1x1, 64 to 10 channels, brokemax
	run_pv(6, true);
	//l=6;
#else
	l=6;
	setup_memory(6, true);
#endif // TARGET_LAYER_6
#else
	l=5;
	setup_memory(5, true);
#endif // TARGET_LAYER_5
#else
	setup_memory(4, false);
#endif // TARGET_LAYER_4
#else
	setup_memory(3, false);
#endif // TARGET_LAYER_3
#else
	setup_memory(2, false);
#endif // TARGET_LAYER_2
#else
	setup_memory(1, false);
#endif // TARGET_LAYER_1

}


void system_t::setup_memory(int target_layer, bool fully_connected)
{
//old
    // // Optional usage check
    // if (esc_argc() != 4)
    // {
    //     ESP_REPORT_ERROR("usage: %s <input1> <input2> <output> \n", esc_argv()[0]);
    //     sc_stop();
    // }

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

//    ESP_REPORT_INFO("esc_argv %s", esc_argv()[1]);

    if (load_double_matrix_t1(&matrix_inA, cnn->W[target_layer-1]->x,1,cnn->W[target_layer-1]->rows,cnn->W[target_layer-1]->cols,0) < 0)
    {
	ESP_REPORT_ERROR("reading matrix A failed!\n");
	sc_stop();
    }

    if (load_double_matrix_t1(&matrix_inB, cnn->layer_sets[target_layer-1]->node.x,1,cnn->W[target_layer-1]->cols,1,1) < 0)
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
    int relu=cnn->layer_sets[l]->relu;
    int wr=cnn->W[l-1]->rows;
    float* out=new float[wr-1];
    float* layer_bias=cnn->layer_sets[l]->bias.x;

    run_pv(l,true);

    float* out_gold=cnn->layer_sets[l]->node.x;

    for( int i = 0; i < wr; i = i + 1 ) {
	    out[i]=(float)matrix_out->data[i];
	    //std::cout<< out[i]<< std::endl;
    }
    printf("\n");

    for (int i = 0; i < wr; i++) {
	    if (relu) {
		    if (out[i] + layer_bias[i] < 0)
			    out[i] = 0;
		    else
			    out[i] += layer_bias[i];
	    }
    }
    printf("\n");
    // Softmax for layer without relu
    if (!relu)
    {
	    for (int i = 0; i < wr; i++) {
		    float max = out[0];
		    for (int j = 1; j < wr; j++)
			    if (out[j] > max)
				    max = out[j];

		    float denom = 0;
		    for (int j = 0; j <wr; j++)
			    denom += exp(out[j] - max);

		    out[i] = exp(out[i] - max) / denom;
//                      printf("%f ",out[i]);
	    }
    }

    
    //Validate network outputs

    //get golden output (entirely executed with pv)
    //get outputs obtained by invoking the accelerator
    int out_size=cnn->layer_sets[l]->node.get_size();
    float* outacc=new float[out_size];


    if (l==5)
    {
	    //std::cout<<"ciao1"<<std::endl;
	    gemm_pvt(6,out, cnn->layer_sets[6]->bias.x, cnn->layer_sets[6]->relu, cnn->W[6-1]->x,
    		 cnn->W[6-1]->rows, cnn->W[6-1]->cols, cnn->W[6-1]->get_size(),outacc);

	    run_pv(6,true);
	    //std::cout<<"ciao2"<<std::endl;
    }
    else
	    outacc=out;

    //Validate Layer

    std::cout << "Validate target layer: "<<l<< std::endl;

    
    // Check for mismatches
    for (uint32_t d2 = 0; d2 < size_out * batch_size; ++d2)
    {
        if (check_error_threshold(out[d2], out_gold[d2], rel_error))
        {
            if (tot_errors < REPORT_THRESHOLD)
            {
                ESP_REPORT_INFO("gemm[%d] = %lf (%lf) error: %.2lf%%", d2,
                  out[d2], out_gold[d2], rel_error * 100);
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


//Validate Network outputs

    
    std::cout << "Validate Network output: "<< std::endl <<std::endl;

    int size_out_net=cnn->W[5]->rows * cnn->layer_sets[6]->node.cols;
    
    // Check for mismatches
    for (uint32_t d2 = 0; d2 < size_out_net * batch_size; ++d2)
    {
        if (check_error_threshold(outacc[d2], cnn->layer_sets[6]->node.x[d2], rel_error))
        {
            if (tot_errors < REPORT_THRESHOLD)
            {
                ESP_REPORT_INFO("gemm[%d] = %lf (%lf) error: %.2lf%%", d2,
                  outacc[d2], cnn->layer_sets[6]->node.x[d2], rel_error * 100);
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



    std::cout << "Accelerators'based network results:" << std::endl;
    int first = mojo::arg_max(outacc, cnn->out_size());
    std::cout << "  1: label|score: \t\"" << labels[first] << "\" | " << outacc[first] << std::endl;

    // find next best
    outacc[first] = -1;
    int second = mojo::arg_max(outacc, cnn->out_size());
    std::cout << "  2: label|score: \t\"" << labels[second] << "\" | " << outacc[second] << std::endl;


    std::cout << " \nPv's based network results:" << std::endl;
    int first_g = mojo::arg_max(cnn->layer_sets[6]->node.x, cnn->out_size());
    std::cout << "  1: label|score: \t\"" << labels[first_g] << "\" | " << cnn->layer_sets[6]->node.x[first_g] << std::endl;

    // find next best
    cnn->layer_sets[6]->node.x[first_g] = -1;
    int second_g = mojo::arg_max(cnn->layer_sets[6]->node.x, cnn->out_size());
    std::cout << "  2: label|score: \t\"" << labels[second_g] << "\" | " << cnn->layer_sets[6]->node.x[second_g] <<\
	    std::endl;


    return tot_errors;
}
