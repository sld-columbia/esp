// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include <sstream>
#include <cstring>
#include <algorithm>

#include "system.hpp"

#include "fc_convnet.hpp"
#include "conv_convnet.hpp"
#include "conv_convnet.cpp"
#include "load_model.hpp"

//KEEP IN MIND THAT FOR CONVENET INPUT AND OUTPUT DIMENSIONS OF A LAYER FEATURE ARE THE SAME

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

    {

        ESP_REPORT_INFO("Configuration");

	l=TARGET_LAYER;
        channels = chans_c[l-1];
        height = height_c[l-1];
        width = width_c[l-1]; 
        num_filters = n_flt_c[l-1];
        kernel_h = flt_dim_c[l-1];//CONV_K_HEIGHT;
        kernel_w = flt_dim_c[l-1];//CONV_K_WIDTH;
        pad_h = pad_c[l-1];//CONV_K_HEIGHT/2;
        pad_w = pad_c[l-1];//CONV_K_WIDTH/2;
        stride_h = stride_c[l-1];
        stride_w = stride_c[l-1];
        dilation_h = dil_c[l-1];
        dilation_w = dil_c[l-1];
	do_relu = 0; //to be modified after included batchnorm
	pool_type = 0; //to be modified after included batchnorm
	output_h = (height_c[l-1] + 2 * pad_c[l-1] - (dil_c[l-1] * (flt_dim_c[l-1] - 1) + 1))/ stride_c[l-1] + 1;
	output_w = (width_c[l-1] + 2 * pad_c[l-1] - (dil_c[l-1] * (flt_dim_c[l-1] - 1) + 1)) / stride_c[l-1] + 1;
	output_pool_h = pool_type ? output_h / 2 : output_h;
	output_pool_w = pool_type ? output_w / 2 : output_w;
	batch_size = 1;

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

        // hw_output = new float[out_size]();

        dump_memory(); // store the output in more suitable data structure if needed

	ESP_REPORT_INFO("memory dumped");


	int l=TARGET_LAYER;

	batch_norm(chans_c[l-1],height_c[l-1],width_c[l-1],flt_dim_c[l-1],
		   flt_dim_c[l-1],pad_c[l-1],pad_c[l-1],stride_c[l-1],stride_c[l-1],
		   dil_c[l-1],dil_c[l-1],n_flt_c[l-1],out_conv[l-1],batch_sz_c[l-1],
		   relu_c[l-1],pool_c[l-1]);


	if (TARGET_LAYER!=1)
 	{
		sw_conv_layer(out_conv[l-2],chans_s[l-1],height_s[l-1],width_s[l-1],
			      flt_dim_s[l-1],flt_dim_s[l-1],pad_s[l-1],pad_s[l-1],
			      stride_s[l-1],stride_s[l-1],dil_s[l-1],dil_s[l-1],
			      n_flt_s[l-1],w_skip[l-1],dummy_b, out_skip[l-1],
			      relu_s[l-1],pool_s[l-1],batch_sz_s[l-1],batch_norm_s[l-1]);


		for (int j=0;j<n_flt_c[l-1] * height_c[l-1] * width_c[l-1];j++)
			out_conv[l-1][j]=out_conv[l-1][j]+out_skip[l-1][j];

		if (pool_out_c[l-1]==1)
			do_pooling_2x2(out_conv[l-1],batch_sz_c[l-1],n_flt_c[l-1],
				       height_c[l-1],pool_out_c[l-1]);
		else if (pool_out_c[l-1]==3)
			do_pooling_8x8(out_conv[l-1],batch_sz_c[l-1],n_flt_c[l-1],
				       height_c[l-1]);


	}




	ESP_REPORT_INFO("batch norm done");

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

        // model allocations
	w_conv = new float*[N_CONV_LAYERS];
	w_skip = new float*[N_CONV_LAYERS]; //remember to not use first one 

	w_fc = new float*[N_FC_LAYERS];

	//intermediate output layers for both convolutional and skip layers 
	out_conv = new float*[N_CONV_LAYERS];
	out_skip = new float*[N_CONV_LAYERS];
	out_fc = new float*[N_FC_LAYERS];

	image = new float[chans_c[0] * height_c[0] * width_c[0]];
	dummy_b = new float[n_flt_c[N_CONV_LAYERS-1]]();

	for(int i = 0; i < N_CONV_LAYERS; i++)
	{
		w_conv[i]=new float [chans_c[i] * n_flt_c[i] * flt_dim_c[i] * flt_dim_c[i]];
		w_skip[i]=new float [chans_s[i] * n_flt_s[i] * flt_dim_s[i] * flt_dim_s[i]];

		out_conv[i]=new float [n_flt_c[i] * height_c[i] * width_c[i]];
		out_skip[i]=new float [n_flt_s[i] * height_s[i] * width_s[i]];

	}

	for(int i = 0; i < N_FC_LAYERS; i++)
	{
		w_fc[i] = new float [d1[i] * d2[i]];
		out_fc[i] = new float [d1[i]];
	}


        load_model(image,w_conv[0],w_conv[1],w_skip[1],w_conv[2],
		   w_skip[2],w_conv[3],w_skip[3],w_fc[0]);



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


void system_t::run_pv(int layer, bool fully_connected)
{

	std::cout << "\n RUN PV " << layer << "\n";

	float* input;

	int l=layer;
	int l_fc=layer-N_CONV_LAYERS-1;

        if (fully_connected)
	{
		gemm_pvt(0,1,out_conv[l-2],out_conv[l-2],out_fc[l_fc],
			 w_fc[l_fc],dummy_b,relu_fc[l_fc],0,d1[l_fc],
			 d2[l_fc],d1[l_fc]*d2[l_fc]);
	}
	else
        {
                if (l==1)    //get the input image as input 
                        input=image;   
                else             // get the input from the previous l output
                        input=out_conv[l-2];

		sw_conv_layer(input,chans_c[l-1],height_c[l-1],width_c[l-1],
			      flt_dim_c[l-1],flt_dim_c[l-1],pad_c[l-1],pad_c[l-1],
			      stride_c[l-1],stride_c[l-1],dil_c[l-1],dil_c[l-1],
			      n_flt_c[l-1],w_conv[l-1],dummy_b,out_conv[l-1],
			      relu_c[l-1],pool_c[l-1],batch_sz_c[l-1],
			      batch_norm_c[l-1]);
	     
	     if (l!=1)       //run the skip l
	     {
		     sw_conv_layer(input,chans_s[l-1],height_s[l-1],width_s[l-1],
				   flt_dim_s[l-1],flt_dim_s[l-1],pad_s[l-1],pad_s[l-1],
				   stride_s[l-1],stride_s[l-1],dil_s[l-1],dil_s[l-1],
				   n_flt_s[l-1],w_skip[l-1],dummy_b, out_skip[l-1],
				   relu_s[l-1],pool_s[l-1],batch_sz_s[l-1],
				   batch_norm_s[l-1]);


		     for (int j=0;j<n_flt_c[l-1] * height_c[l-1] * width_c[l-1];j++)
			     out_conv[l-1][j]=out_conv[l-1][j]+out_skip[l-1][j];

		     if (pool_out_c[l-1]==1)
			     do_pooling_2x2(out_conv[l-1],batch_sz_c[l-1],n_flt_c[l-1],
					    height_c[l-1],pool_out_c[l-1]);
		     else if (pool_out_c[l-1]==3)
			     do_pooling_8x8(out_conv[l-1],batch_sz_c[l-1],
					    n_flt_c[l-1],height_c[l-1]);
	     }

        }
}



void system_t::setup_memory(int target_layer, bool fully_connected)
{

    int k_size=kernel_h*kernel_w;
    int weight_size=channels*num_filters; 
    int out_ch=num_filters;
    int in_ch=channels;


    in_words_adj = (batch_size * channels * height * width);
    weights_words_adj = num_filters * channels * kernel_h * kernel_w;
    bias_words_adj = num_filters;
    out_words_adj =batch_size * num_filters * output_h * output_w;

    in_size = in_words_adj * (1);
    weights_size = weights_words_adj * (1);
    bias_size = bias_words_adj * (1);
    out_size = out_words_adj * (1);
    out_offset = in_size + weights_size + bias_size;

    float* input_acc;
    float* w_acc=w_conv[TARGET_LAYER-1];
    

    std::cout<< "\n SETUP MEMORY: " << target_layer << "\n";

    //start memory load 
    if (TARGET_LAYER==1)
    {
	    input_acc=image;
    }
    else
    {
	    input_acc=out_conv[TARGET_LAYER-2];
    }

    int i,j;
    for (i = 0; i < in_size / DMA_WORD_PER_BEAT; i++)  {
        sc_dt::sc_bv<DMA_WIDTH> data_bv = fp2bv<FPDATA, DATA_WIDTH>(FPDATA(input_acc[i]));
        for (j = 0; j < DMA_WORD_PER_BEAT; j++)
	{
		data_bv.range((j+1) * DATA_WIDTH - 1, j * DATA_WIDTH) =
			fp2bv<FPDATA, DATA_WIDTH>(FPDATA(input_acc[i * DMA_WORD_PER_BEAT + j]));
	}
        mem[i] = data_bv;

    }

    for (; i < (in_size + weights_size) / DMA_WORD_PER_BEAT; i++)  {
        sc_dt::sc_bv<DMA_WIDTH> data_bv =
    	    fp2bv<FPDATA, DATA_WIDTH>(FPDATA(w_acc[i - in_size / DMA_WORD_PER_BEAT]));
        for (j = 0; j < DMA_WORD_PER_BEAT; j++)
            data_bv.range((j+1) * DATA_WIDTH - 1, j * DATA_WIDTH) =
    		fp2bv<FPDATA, DATA_WIDTH>(FPDATA(w_acc[i * DMA_WORD_PER_BEAT + j - in_size]));
        mem[i] = data_bv;

    }

    for (; i < (in_size + weights_size + bias_size) / DMA_WORD_PER_BEAT; i++)  {
        sc_dt::sc_bv<DMA_WIDTH> data_bv =
	    fp2bv<FPDATA, DATA_WIDTH>(FPDATA(0));
        for (j = 0; j < DMA_WORD_PER_BEAT; j++)
            data_bv.range((j+1) * DATA_WIDTH - 1, j * DATA_WIDTH) =
		fp2bv<FPDATA, DATA_WIDTH>(FPDATA(0));
        mem[i] = data_bv;
    }


    ESP_REPORT_INFO("setup memory completed");
}

void system_t::dump_memory()
{
    // Get results from memory
   
    for (int i = 0; i < out_size / DMA_WORD_PER_BEAT; i++) {
        for (int j = 0; j < DMA_WORD_PER_BEAT; j++) {
            FPDATA fpdata_elem = bv2fp<FPDATA, DATA_WIDTH>
		(mem[out_offset / DMA_WORD_PER_BEAT + i].range((j + 1) * DATA_WIDTH - 1, j * DATA_WIDTH));
            out_conv[TARGET_LAYER-1][i * DMA_WORD_PER_BEAT + j] = (float) fpdata_elem.to_double();	    

	}
    }


    ESP_REPORT_INFO("dump memory completed");
}

int system_t::validate()
{

     float out_acc[d1[N_FC_LAYERS - 1]];
     float* out_gold=new float[d1[N_FC_LAYERS - 1]];

     //run rest of NN in sw 
     for (int i=TARGET_LAYER; i<N_CONV_LAYERS; i++)
	     run_pv(i+1,false); 	     

     for (int i=N_CONV_LAYERS; i<N_CONV_LAYERS+N_FC_LAYERS; i++)
	     run_pv(i+1,true); 	     

     for (int i=0; i<d1[N_FC_LAYERS-1]; i++)
	     out_acc[i]=out_fc[N_FC_LAYERS-1][i]; 	     

     //run NN in sw
     for (int i=0; i<N_CONV_LAYERS; i++)
	     run_pv(i+1,false); 	     

     for (int i=N_CONV_LAYERS; i<N_CONV_LAYERS+N_FC_LAYERS; i++)
     	     run_pv(i+1,true); 	     

     out_gold = out_fc[N_FC_LAYERS-1];

     for( int i = 0; i < d1[N_FC_LAYERS-1]; i = i + 1 ) {
	     std::cout<<"gold | acc:"<<out_gold[i]<<" "<<out_acc[i]<<std::endl;
     }
     printf("\n");

    return 0;
 }


