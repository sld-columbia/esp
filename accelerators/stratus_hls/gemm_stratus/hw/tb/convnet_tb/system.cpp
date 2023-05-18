// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef __CONVNET_TEST
#define __CONVNET_TEST
#endif

#include <iostream>
#include <string>
#include <cstring>
#include <sstream>
#include <fstream>

#include "system.hpp"

#include "fc_convnet.hpp"
#include "conv_convnet.hpp"
#include "conv_convnet.cpp"
#include "load_model.hpp"


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
    	    ESP_REPORT_INFO("validation completed!");
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

    sc_dt::sc_bv<WORD_SIZE> data;

    indexA = 0;
    indexB = 0;

    if (load_double_matrix_t1(&matrix_inA, w_fc[N_FC_LAYERS-1],
			      batch_sz_c[N_CONV_LAYERS-1],d1[N_FC_LAYERS-1],
			      d2[N_FC_LAYERS-1],0) < 0)
    {
	ESP_REPORT_ERROR("reading matrix A failed!\n");
	sc_stop();
    }

    if (load_double_matrix_t1(&matrix_inB, out_conv[N_CONV_LAYERS-1],
			      batch_sz_c[N_CONV_LAYERS-1],
			      d2[N_FC_LAYERS-1],d3[N_FC_LAYERS-1],1) < 0)
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
    float* out=new float[2];
    float* out_gold=new float[2];

    run_pv(TARGET_LAYER,true);
    
    out_gold=out_fc[N_FC_LAYERS-1];

    for( int i = 0; i < 2; i = i + 1 ) {
	    out[i]=(float)matrix_out->data[i];
	    std::cout<<"gold | acc:"<<out_gold[i]<<" "<<out[i]<<std::endl;
    }
    printf("\n");

    return 0;

}
