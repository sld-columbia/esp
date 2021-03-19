// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include <sstream>
#include <cstring>
#include "validation.hpp"
#include "system.hpp"
#include "mojo.h"
#include "conv_pvt.hpp"
//#include <math.h>
//#include "mojo_utils.h"
#include "dwarf.h"
//#include "gemm_pvt.cpp"
#include "gemm_pvt.c"
// Mojo network
mojo::network *cnn;

std::string model_path = "../models/dwarf7.mojo";
std::string image_path = "truck.bin";


#define IMAGE_SIZE 3 * 32 * 32

//define a target layer between 1 and 4 for this testbench
#define TARGET_LAYER_1


#ifdef TARGET_LAYER_1
        int l_n=1;
#endif

#ifdef TARGET_LAYER_2
        int l_n=2;
#endif

#ifdef TARGET_LAYER_3
        int l_n=3;
#endif

#ifdef TARGET_LAYER_4
        int l_n=4;
#endif

// #ifdef TARGET_LAYER_5
//         int l_n=5;
// #endif

// #ifdef TARGET_LAYER_6
//         int l_n=6;
// #endif

// Process
void system_t::config_proc()
{
    // Reset
    {
        conf_done.write(false);
        conf_info.write(conf_info_t());
        wait();
    }

    ESP_REPORT_INFO("reset done");

    // Arguments
    {
	// Optional usage check
#ifdef CADENCE
	if (esc_argc() != 3)
	{
	    ESP_REPORT_INFO("usage: %s <testbench-name>\n", esc_argv()[0]);
	    sc_stop();
	}
#endif

	uint32_t CONV_F_HEIGHT;
	uint32_t CONV_F_WIDTH;
	uint32_t CONV_F_CHANNELS;
	uint32_t CONV_K_HEIGHT;
	uint32_t CONV_K_WIDTH;
	uint32_t CONV_K_IN_CHANNELS;
	uint32_t CONV_K_OUT_CHANNELS;
	uint32_t DO_RELU;
	uint32_t POOL_TYPE;
	uint32_t BATCH_SIZE;

	ESP_REPORT_INFO("Argv[1] = %s", esc_argv()[1]);
	ESP_REPORT_INFO("Argv[2] = %s", esc_argv()[2]);

	if (!strcmp(esc_argv()[1], "XL")) {
	    CONV_F_HEIGHT = 224;
	    CONV_F_WIDTH = 224;
	    CONV_F_CHANNELS = 3;
	    CONV_K_OUT_CHANNELS = 8;
	} else if (!strcmp(esc_argv()[1], "L")) {
	    CONV_F_HEIGHT = 40;
	    CONV_F_WIDTH = 40;
	    CONV_F_CHANNELS = 16;
	    CONV_K_OUT_CHANNELS = 4;
	} else if (!strcmp(esc_argv()[1], "M")) {
	    CONV_F_HEIGHT = 28;
	    CONV_F_WIDTH = 28;
	    CONV_F_CHANNELS = 16;
	    CONV_K_OUT_CHANNELS = 4;
	} else if (!strcmp(esc_argv()[1], "S")) {
	    CONV_F_HEIGHT = 24;
	    CONV_F_WIDTH = 24;
	    CONV_F_CHANNELS = 4;
	    CONV_K_OUT_CHANNELS = 8;
	} else { // if (!strcmp(esc_argv()[1], "XS")) {
	    CONV_F_HEIGHT = 10;
	    CONV_F_WIDTH = 10;
	    CONV_F_CHANNELS = 2;
	    CONV_K_OUT_CHANNELS = 8;
	}

	if (!strcmp(esc_argv()[2], "1x1")) {
	    CONV_K_HEIGHT = 1;
	    CONV_K_WIDTH = 1;
	} else if (!strcmp(esc_argv()[2], "3x3")) {
	    CONV_K_HEIGHT = 3;
	    CONV_K_WIDTH = 3;
	} else { // if (!strcmp(esc_argv()[2], "5x5")) {
	    CONV_K_HEIGHT = 5;
	    CONV_K_WIDTH = 5;
	}

// import model and set config parameters

        ESP_REPORT_INFO("Configuration");

        cnn = new mojo::network();
        assert(cnn->read(model_path));

        ESP_REPORT_INFO("DWARF7 model loaded");

        float *image = new float[IMAGE_SIZE];
	std::ifstream infile(image_path.c_str(), std::ifstream::binary);
        assert(infile.read((char *) image, IMAGE_SIZE * sizeof(float)));
        cnn->forward_setup(image);
        delete[] image;

        ESP_REPORT_INFO("DWARF7 image: %s", image_path.c_str());

        CONV_K_IN_CHANNELS = cnn->layer_sets[l_n-1]->node.chans;
	DO_RELU = 1;
        POOL_TYPE = cnn->layer_sets[l_n]->do_pool;
	BATCH_SIZE = 1;

        channels = cnn->layer_sets[l_n-1]->node.chans;//CONV_F_CHANNELS;
        height = cnn->layer_sets[l_n]->node.rows-2;//*cnn->layer_sets[l_n]->do_pad;//CONV_F_HEIGHT;
        width = cnn->layer_sets[l_n]->node.cols-2;//*cnn->layer_sets[l_n]->do_pad;//CONV_F_WIDTH;
        num_filters = cnn->layer_sets[l_n]->node.chans;//CONV_K_OUT_CHANNELS;
        kernel_h = 3;//CONV_K_HEIGHT;
        kernel_w = 3;//CONV_K_WIDTH;
        pad_h = 1;//CONV_K_HEIGHT/2;
        pad_w = 1;//CONV_K_WIDTH/2;
        stride_h = 1;
        stride_w = 1;
        dilation_h = 1;
        dilation_w = 1;
	do_relu = DO_RELU;
	pool_type = POOL_TYPE;
	output_h = (height + 2 * pad_h - (dilation_h * (kernel_h - 1) + 1)) / stride_h + 1;
	output_w = (width + 2 * pad_w - (dilation_w * (kernel_w - 1) + 1)) / stride_w + 1;
	output_pool_h = pool_type ? output_h / 2 : output_h;
	output_pool_w = pool_type ? output_w / 2 : output_w;
	batch_size = BATCH_SIZE;

///



    }

    // Config
    load_memory();
    {
        conf_info_t config;
        // Custom configuration
        /* <<--params-->> */
        config.n_channels = channels;
        config.feature_map_height = height;
        config.feature_map_width = width;
        config.n_filters = num_filters;
        config.filter_dim = kernel_h;
        config.is_padded = (pad_h != 0);
        config.stride = stride_h;
        config.do_relu = do_relu;
        config.pool_type = pool_type;
        config.batch_size = batch_size;

        wait(); conf_info.write(config);
        conf_done.write(true);
    }

    ESP_REPORT_INFO("config done");

    // Compute
    {
        // Print information about begin time
        sc_time begin_time = sc_time_stamp();
        ESP_REPORT_TIME(begin_time, "BEGIN - conv2d");

        // Wait the termination of the accelerator
        do { wait(); } while (!acc_done.read());
        debug_info_t debug_code = debug.read();

        // Print information about end time
        sc_time end_time = sc_time_stamp();
        ESP_REPORT_TIME(end_time, "END - conv2d");

        esc_log_latency(sc_object::basename(), clock_cycle(end_time - begin_time));
        wait(); conf_done.write(false);
    }

    ESP_REPORT_INFO("HW Accelerator done");

    // Validate
    {
        dump_memory(); // store the output in more suitable data structure if needed

	
// #ifdef XS
// 	print_image("output-hw", hw_output, batch_size, num_filters, output_pool_h, output_pool_w, true);
// 	print_image("output-sw", sw_output, batch_size, num_filters, output_pool_h, output_pool_w, false);
// 	printf("\n");
// #endif

        // check the results with the golden model
        if (validate())
        {
            ESP_REPORT_ERROR("validation failed!");
        } else
        {
            ESP_REPORT_INFO("validation passed!");
        }
    }

    // Conclude
    {
        sc_stop();
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


void system_t::run_pv(int layer, bool fully_connected = false)
{

        if (fully_connected)

                gemm_pvt(layer,cnn->layer_sets[layer-1]->node.x, cnn->layer_sets[layer]->bias.x, cnn->layer_sets[layer]->relu, cnn->W[layer-1]->x,cnn->W[layer-1]->rows, cnn->W[layer-1]->cols, cnn->W[layer-1]->get_size(),cnn->layer_sets[layer]->node.x);
        else 	
		run_pv_conv(cnn,layer);

}


void system_t::setup_memory(int target_layer, bool fully_connected)
{

    int k_size=(cnn->W[target_layer-1]->cols) *(cnn->W[target_layer-1]->rows);
    int weight_size=cnn->W[target_layer-1]->get_size();
    int out_ch=cnn->layer_sets[target_layer]->node.chans;
    int in_ch=cnn->layer_sets[target_layer-1]->node.chans;

    float* w_pv=new float[weight_size];                                      

    // //weights matrix reshape

    reshape_weights(w_pv,cnn->W[target_layer-1]->x,in_ch,out_ch,k_size);

    //run programmer's view for target layer 

    run_pv_conv(cnn,target_layer);

    in_words_adj = (batch_size * channels * height * width);
    weights_words_adj = num_filters * channels * kernel_h * kernel_w;
    bias_words_adj = num_filters;
    out_words_adj =batch_size * num_filters * output_h * output_w;

    in_size = in_words_adj * (1);
    weights_size = weights_words_adj * (1);
    bias_size = bias_words_adj * (1);
    out_size = out_words_adj * (1);

    //start memory load 

    int i,j;
    for (i = 0; i < in_size / DMA_WORD_PER_BEAT; i++)  {
    	// ESP_REPORT_INFO("tb load in %i : %f", i, (float) input[i]);
        sc_dt::sc_bv<DMA_WIDTH> data_bv = fp2bv<FPDATA, DATA_WIDTH>(FPDATA(cnn->layer_sets[target_layer-1]->node.x[i]));
        for (j = 0; j < DMA_WORD_PER_BEAT; j++)
            data_bv.range((j+1) * DATA_WIDTH - 1, j * DATA_WIDTH) =
    		fp2bv<FPDATA, DATA_WIDTH>(FPDATA(cnn->layer_sets[target_layer-1]->node.x[i * DMA_WORD_PER_BEAT + j]));
        mem[i] = data_bv;
    }

    for (; i < (in_size + weights_size) / DMA_WORD_PER_BEAT; i++)  {
    	// ESP_REPORT_INFO("tb load we %i : %f",
    	// i, (float) weights[i - in_size / DMA_WORD_PER_BEAT]);
        sc_dt::sc_bv<DMA_WIDTH> data_bv =
    	    fp2bv<FPDATA, DATA_WIDTH>(FPDATA(w_pv[i - in_size / DMA_WORD_PER_BEAT]));
        for (j = 0; j < DMA_WORD_PER_BEAT; j++)
            data_bv.range((j+1) * DATA_WIDTH - 1, j * DATA_WIDTH) =
    		fp2bv<FPDATA, DATA_WIDTH>(FPDATA(w_pv[i * DMA_WORD_PER_BEAT + j - in_size]));
        mem[i] = data_bv;
    }

    for (; i < (in_size + weights_size + bias_size) / DMA_WORD_PER_BEAT; i++)  {
	// ESP_REPORT_INFO("tb load we %i : %f",
	// i, (float) bias[i - (in_size + weights_size) / DMA_WORD_PER_BEAT]);
        sc_dt::sc_bv<DMA_WIDTH> data_bv =
	    fp2bv<FPDATA, DATA_WIDTH>(
		FPDATA(cnn->layer_sets[target_layer]->bias.x[i - (in_size + weights_size) / DMA_WORD_PER_BEAT]));
        for (j = 0; j < DMA_WORD_PER_BEAT; j++)
            data_bv.range((j+1) * DATA_WIDTH - 1, j * DATA_WIDTH) =
		fp2bv<FPDATA, DATA_WIDTH>(
		    FPDATA(cnn->layer_sets[target_layer]->bias.x[i * DMA_WORD_PER_BEAT + j - in_size - weights_size]));
        mem[i] = data_bv;
    }


    ESP_REPORT_INFO("setup memory completed");
}

void system_t::dump_memory()
{
    // Get results from memory
    uint32_t offset = in_size + weights_size + bias_size;
    // ESP_REPORT_INFO("DUMP MEM: offset %u", offset);

    // sw_output = (float*) malloc(out_size * sizeof(float));
    hw_output = (float*) malloc(out_size * sizeof(float));

    offset = offset / DMA_WORD_PER_BEAT;
    for (int i = 0; i < out_size / DMA_WORD_PER_BEAT; i++) {
        for (int j = 0; j < DMA_WORD_PER_BEAT; j++) {
            FPDATA fpdata_elem = bv2fp<FPDATA, DATA_WIDTH>
		(mem[offset + i].range((j + 1) * DATA_WIDTH - 1, j * DATA_WIDTH));
            hw_output[i * DMA_WORD_PER_BEAT + j] = (float) fpdata_elem.to_double();
	    
	}
    }
// #endif
    
	
        // run_pv(5,true);
	// cnn->layer_sets[target_

	// run_pv(5,true);
	// run_pv(6,true);

    ESP_REPORT_INFO("dump memory completed");
}

int system_t::validate()
{

    int pool_out=cnn->layer_sets[l_n]->do_pool;
    int out_pad_h=1;

    int out_ch=cnn->layer_sets[l_n]->node.chans;
    int layer_out_rows=cnn->layer_sets[l_n]->node.cols;
    int layer_out_cols=cnn->layer_sets[l_n]->node.rows;
    int cnn_out_size=(layer_out_cols-2) * (layer_out_rows-2) * out_ch;

    validate_hw(l_n,hw_output,cnn->layer_sets[l_n]->node.x,layer_out_rows,layer_out_cols,out_pad_h,out_ch,pool_out,cnn_out_size);


	for (int i=l_n+1;i<=6;i++)
	{
		if (i<=4)
			run_pv(i,false);
		else
			run_pv(i,true);
	}

    std::cout << "Programmer's view-based network results:" << std::endl;
    int first = mojo::arg_max(cnn->layer_sets[6]->node.x, cnn->out_size());
    std::cout << "  1: label|score: \t\"" << labels[first] << "\" | " << cnn->layer_sets[6]->node.x[first] << std::endl;

    // find next best
    cnn->layer_sets[6]->node.x[first] = -1;
    int second = mojo::arg_max(cnn->layer_sets[6]->node.x, cnn->out_size());
    std::cout << "  2: label|score: \t\"" << labels[second] << "\" | " << cnn->layer_sets[6]->node.x[second] << std::endl;


    cnn->layer_sets[l_n]->node.x=hw_output;

	for (int i=l_n+1;i<=6;i++)
	{
		if (i<=4)
			run_pv(i,false);
		else
			run_pv(i,true);
	}

	std::cout << "\n \nProgrammer's view + layer "<<l_n<<" accelerator invocation results:" << std::endl;
    int first_n = mojo::arg_max(cnn->layer_sets[6]->node.x, cnn->out_size());
    std::cout << "  1: label|score: \t\"" << labels[first_n] << "\" | " << cnn->layer_sets[6]->node.x[first_n] << std::endl;

    // find next best
    cnn->layer_sets[6]->node.x[first_n] = -1;
    int second_n = mojo::arg_max(cnn->layer_sets[6]->node.x, cnn->out_size());
    std::cout << "  2: label|score: \t\"" << labels[second_n] << "\" | " << cnn->layer_sets[6]->node.x[second_n] << std::endl;

    return 0;
 }
