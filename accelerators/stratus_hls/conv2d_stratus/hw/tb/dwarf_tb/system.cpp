// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include <sstream>
#include <cstring>
#include "mojo.h"
#include "dwarf.h"

#include "system.hpp"

#include "fc_dwarf.hpp"
#include "conv_dwarf.hpp"

// Mojo network
mojo::network *cnn;

std::string model_path = "../tb/dwarf_tb/model/dwarf7.mojo";
std::string image_path = "../tb/dwarf_tb/data/cat.bin";

#define IMAGE_SIZE 3 * 32 * 32

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

        channels = cnn->layer_sets[TARGET_LAYER-1]->node.chans;
        height = cnn->layer_sets[TARGET_LAYER]->node.rows-2;
        width = cnn->layer_sets[TARGET_LAYER]->node.cols-2;
        num_filters = cnn->layer_sets[TARGET_LAYER]->node.chans;
        kernel_h = 3;
        kernel_w = 3;
        pad_h = 1;
        pad_w = 1;
        stride_h = 1;
        stride_w = 1;
        dilation_h = 1;
        dilation_w = 1;
	do_relu = 1;
	pool_type = cnn->layer_sets[TARGET_LAYER]->do_pool;
	output_h = (height + 2 * pad_h - (dilation_h * (kernel_h - 1) + 1)) / stride_h + 1;
	output_w = (width + 2 * pad_w - (dilation_w * (kernel_w - 1) + 1)) / stride_w + 1;
	output_pool_h = pool_type ? output_h / 2 : output_h;
	output_pool_w = pool_type ? output_w / 2 : output_w;
	batch_size = 1;

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

	int l=layer;

        if (fully_connected)
                gemm_pvt(l,0,cnn->layer_sets[l-1]->node.x,cnn->layer_sets[l-1]->node.x,
			 cnn->layer_sets[l]->node.x, cnn->W[l-1]->x,cnn->layer_sets[l]->bias.x,
			 cnn->layer_sets[l]->relu,1,cnn->W[l-1]->rows, cnn->W[l-1]->cols,
			 cnn->W[l-1]->get_size());
        else 
	{
		int ps;
		if (l==1)
			ps=1;
		else
			ps=0;

		conv_pvt(l,ps,cnn->layer_sets[l-1]->node.x,cnn->layer_sets[l-1]->node.x,
			 cnn->layer_sets[l]->node.x,cnn->W[l-1]->x,cnn->layer_sets[l]->bias.x,
			 cnn->layer_sets[l-1]->node.chans,cnn->layer_sets[l]->node.chans,
			 cnn->layer_sets[l-1]->node.cols,cnn->layer_sets[l-1]->node.rows,
			 cnn->layer_sets[l]->node.cols,cnn->layer_sets[l]->node.rows,1,1,
			 cnn->layer_sets[l]->do_pad,cnn->layer_sets[l]->do_pad,
			 cnn->W[l-1]->get_size(),cnn->W[l-1]->cols,cnn->W[l-1]->rows,
			 1,1,1,1,1,cnn->layer_sets[l]->do_pool,cnn->layer_sets[l-1]->do_pool);
	}

}


void system_t::setup_memory(int target_layer, bool fully_connected)
{

    int k_size=(cnn->W[target_layer-1]->cols) *(cnn->W[target_layer-1]->rows);
    int weight_size=cnn->W[target_layer-1]->get_size();
    int out_ch=cnn->layer_sets[target_layer]->node.chans;
    int in_ch=cnn->layer_sets[target_layer-1]->node.chans;

    float* w_pv=new float[weight_size];                                      

    //weights matrix reshape

    int in_cols=cnn->layer_sets[target_layer-1]->node.cols;
    int in_rows=cnn->layer_sets[target_layer-1]->node.rows;
    int out_pad_w=cnn->layer_sets[target_layer]->do_pad;
    int pool_in = cnn->layer_sets[target_layer-1]->do_pool;

    int in_sz=in_cols*in_rows* in_ch;
    float* in_acc=new float[in_sz-1];

    for (int i=0;i<in_sz;i++)
        in_acc[i]= cnn->layer_sets[target_layer-1]->node.x[i];

    if (TARGET_LAYER==1)
        reshape_input(in_acc,pool_in,in_rows,in_cols,1,1,in_ch);

    reshape_weights(w_pv,cnn->W[target_layer-1]->x,in_ch,out_ch,k_size);

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
        sc_dt::sc_bv<DMA_WIDTH> data_bv = fp2bv<FPDATA, DATA_WIDTH>(FPDATA(cnn->layer_sets[target_layer-1]->node.x[i]));
        for (j = 0; j < DMA_WORD_PER_BEAT; j++)
            data_bv.range((j+1) * DATA_WIDTH - 1, j * DATA_WIDTH) =
    		fp2bv<FPDATA, DATA_WIDTH>(FPDATA(in_acc[i * DMA_WORD_PER_BEAT + j]));
    		// fp2bv<FPDATA, DATA_WIDTH>(FPDATA(cnn->layer_sets[target_layer-1]->node.x[i * DMA_WORD_PER_BEAT + j]));
        mem[i] = data_bv;
    }

    for (; i < (in_size + weights_size) / DMA_WORD_PER_BEAT; i++)  {
        sc_dt::sc_bv<DMA_WIDTH> data_bv =
    	    fp2bv<FPDATA, DATA_WIDTH>(FPDATA(w_pv[i - in_size / DMA_WORD_PER_BEAT]));
        for (j = 0; j < DMA_WORD_PER_BEAT; j++)
            data_bv.range((j+1) * DATA_WIDTH - 1, j * DATA_WIDTH) =
    		fp2bv<FPDATA, DATA_WIDTH>(FPDATA(w_pv[i * DMA_WORD_PER_BEAT + j - in_size]));
        mem[i] = data_bv;
    }

    for (; i < (in_size + weights_size + bias_size) / DMA_WORD_PER_BEAT; i++)  {
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
   
    hw_output = (float*) malloc(out_size * sizeof(float));

    offset = offset / DMA_WORD_PER_BEAT;
    for (int i = 0; i < out_size / DMA_WORD_PER_BEAT; i++) {
        for (int j = 0; j < DMA_WORD_PER_BEAT; j++) {
            FPDATA fpdata_elem = bv2fp<FPDATA, DATA_WIDTH>
		(mem[offset + i].range((j + 1) * DATA_WIDTH - 1, j * DATA_WIDTH));
            hw_output[i * DMA_WORD_PER_BEAT + j] = (float) fpdata_elem.to_double();
	    
	}
    }

    ESP_REPORT_INFO("dump memory completed");
}

int system_t::validate()
{

    int pool_out=cnn->layer_sets[TARGET_LAYER]->do_pool;
    int out_pad_h=1;

    int out_ch=cnn->layer_sets[TARGET_LAYER]->node.chans;
    int layer_out_rows=cnn->layer_sets[TARGET_LAYER]->node.cols;
    int layer_out_cols=cnn->layer_sets[TARGET_LAYER]->node.rows;
    int cnn_out_size=(layer_out_cols-2) * (layer_out_rows-2) * out_ch;

    //Run reamining layers with programmer's view

    for (int i=TARGET_LAYER;i<=6;i++)
    {
	    if (i<=4)
		    run_pv(i,false);
	    else
		    run_pv(i,true);
    }

    std::cout << "Programmer's view-based network results:" << std::endl;
    int first = mojo::arg_max(cnn->layer_sets[6]->node.x, cnn->out_size());
    std::cout << "  1: label|score: \t\"" << labels[first] 
	      << "\" | " << cnn->layer_sets[6]->node.x[first] << std::endl;

    // find next best
    cnn->layer_sets[6]->node.x[first] = -1;
    int second = mojo::arg_max(cnn->layer_sets[6]->node.x, cnn->out_size());
    std::cout << "  2: label|score: \t\"" << labels[second] << "\" | " 
	      << cnn->layer_sets[6]->node.x[second] << std::endl;


    //Run remaining layers with programmer's view and accelerator input
    cnn->layer_sets[TARGET_LAYER]->node.x=hw_output;

	for (int i=TARGET_LAYER+1;i<=6;i++)
	{
		if (i<=4)
			run_pv(i,false);
		else
			run_pv(i,true);
	}

	std::cout << "\n \nProgrammer's view + layer "<<TARGET_LAYER<<" accelerator invocation results:" << std::endl;
    int first_n = mojo::arg_max(cnn->layer_sets[6]->node.x, cnn->out_size());
    std::cout << "  1: label|score: \t\"" << labels[first_n] << "\" | " << cnn->layer_sets[6]->node.x[first_n] << std::endl;

    // find next best
    cnn->layer_sets[6]->node.x[first_n] = -1;
    int second_n = mojo::arg_max(cnn->layer_sets[6]->node.x, cnn->out_size());
    std::cout << "  2: label|score: \t\"" << labels[second_n] << "\" | " << cnn->layer_sets[6]->node.x[second_n] << std::endl;

    return 0;
 }
