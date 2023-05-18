// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include <sstream>
#include "system.hpp"
#include <iostream>
#include <fstream>


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
	} else if (!strcmp(esc_argv()[1], "custom")) {
	    CONV_F_HEIGHT = 6;
	    CONV_F_WIDTH = 6;
	    CONV_F_CHANNELS = 2;
	    CONV_K_OUT_CHANNELS = 2;
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

	CONV_K_IN_CHANNELS = CONV_F_CHANNELS;
	DO_RELU = 0;
	POOL_TYPE = 0;
	BATCH_SIZE = 1;

	channels = CONV_F_CHANNELS;
        height = CONV_F_HEIGHT;
        width = CONV_F_WIDTH;
        num_filters = CONV_K_OUT_CHANNELS;
        kernel_h = CONV_K_HEIGHT;
        kernel_w = CONV_K_WIDTH;
        pad_h = CONV_K_HEIGHT/2;
        pad_w = CONV_K_WIDTH/2;
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
        // config.load_dma_mode = 0;
        // config.store_dma_mode = 0;

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
    // sw_conv_layer_fpdata(input, channels, height, width, kernel_h, kernel_w, pad_h, pad_w,
    // 		  stride_h, stride_w, dilation_h, dilation_w, num_filters,
    //            weights, bias, hw_output, do_relu);
    ESP_REPORT_INFO("HW Accelerator done");

    // Compute in SW
    sw_conv_layer(input, channels, height, width, kernel_h, kernel_w, pad_h, pad_w,
		  stride_h, stride_w, dilation_h, dilation_w, num_filters,
		  weights, bias, sw_output, do_relu, pool_type, batch_size);
    ESP_REPORT_INFO("SW done");



    ofstream myfile;
    myfile.open ("out_gold.h");

    for (int i=0; i<out_size; i++)
        myfile << "gold["<<i<<"] = "<<sw_output[i]<<";\n";

    myfile.close();


    // printf("Performance: data-in : moved %u (%u bytes) / memory footprint %u (%u bytes) / PLM locality %.2f%%",
    // 	   data_in_movement, data_in_movement * sizeof(FPDATA), channels * height * width, channels * height *
    // 	   width * sizeof(FPDATA),100*(channels * height * width)/((float)data_in_movement));
    // printf("Performance: weights : moved %u (%u bytes) / memory footprint %u (%u bytes) / PLM locality %.2f%%",
    // 	   weights_movement, weights_movement * sizeof(FPDATA), num_filters * channels * kernel_h * kernel_w,
    // 	   num_filters * channels * kernel_h * kernel_w * sizeof(FPDATA),
    // 	   100*(num_filters * channels * kernel_h * kernel_w)/((float)weights_movement));
    // printf("Performance: data-out: moved %u (%u bytes) / memory footprint %u (%u bytes) / PLM locality %.2f%%",
    // 	   data_out_movement, data_out_movement * sizeof(FPDATA), num_filters * height * width,  num_filters *
    // 	   height * width * sizeof(FPDATA), 100*(num_filters*height*width)/((float)data_out_movement));


    // Validate
    {
        dump_memory(); // store the output in more suitable data structure if needed

#ifdef XS
	print_image("output-hw", hw_output, batch_size, num_filters, output_pool_h, output_pool_w, true);
	print_image("output-sw", sw_output, batch_size, num_filters, output_pool_h, output_pool_w, false);
	printf("\n");
#endif

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
    int i, j;

    // Input data and golden output (aligned to DMA_WIDTH makes your life easier)
#if (DMA_WORD_PER_BEAT == 0)
    in_words_adj = batch_size * channels * height * width;
    weights_words_adj = num_filters * channels * kernel_h * kernel_w;
    bias_words_adj = num_filters;
    out_words_adj = num_filters * output_h * output_w;
#else
    in_words_adj = round_up(batch_size * round_up(channels * round_up(height * width, DMA_WORD_PER_BEAT), DMA_WORD_PER_BEAT), DMA_WORD_PER_BEAT);
    weights_words_adj = round_up(num_filters * channels * kernel_h * kernel_w, DMA_WORD_PER_BEAT);
    bias_words_adj = round_up(num_filters, DMA_WORD_PER_BEAT);
    out_words_adj = round_up(batch_size * round_up(num_filters * round_up(output_h * output_w, DMA_WORD_PER_BEAT), DMA_WORD_PER_BEAT), DMA_WORD_PER_BEAT);
#endif

    in_size = in_words_adj * (1);
    weights_size = weights_words_adj * (1);
    bias_size = bias_words_adj * (1);
    out_size = out_words_adj * (1);

    input = (float*) malloc(in_size * sizeof(float));
    weights = (float*) malloc(weights_size * sizeof(float));
    bias = (float*) malloc(bias_size * sizeof(float));
    sw_output = (float*) malloc(out_size * sizeof(float));
    hw_output = (float*) malloc(out_size * sizeof(float));

    in = (float*) malloc(200 * sizeof(float));
    gold= (float*) malloc(200 * sizeof(float));

    in[0] =  0;
    in[1] =  1;
    in[2] =  2;
    in[3] =  3;
    in[4] =  4;
    in[5] =  5;
    in[6] =  6;
    in[7] =  7;
    in[8] =  0;
    in[9] =  1;
    in[10] =  2;
    in[11] =  3;
    in[12] =  4;
    in[13] =  5;
    in[14] =  6;
    in[15] =  7;
    in[16] =  0;
    in[17] =  1;
    in[18] =  2;
    in[19] =  3;
    in[20] =  4;
    in[21] =  5;
    in[22] =  6;
    in[23] =  7;
    in[24] =  0;
    in[25] =  1;
    in[26] =  2;
    in[27] =  3;
    in[28] =  4;
    in[29] =  5;
    in[30] =  6;
    in[31] =  7;
    in[32] =  0;
    in[33] =  1;
    in[34] =  2;
    in[35] =  3;
    in[36] =  4;
    in[37] =  5;
    in[38] =  6;
    in[39] =  7;
    in[40] =  0;
    in[41] =  1;
    in[42] =  2;
    in[43] =  3;
    in[44] =  4;
    in[45] =  5;
    in[46] =  6;
    in[47] =  7;
    in[48] =  0;
    in[49] =  1;
    in[50] =  2;
    in[51] =  3;
    in[52] =  4;
    in[53] =  5;
    in[54] =  6;
    in[55] =  7;
    in[56] =  0;
    in[57] =  1;
    in[58] =  2;
    in[59] =  3;
    in[60] =  4;
    in[61] =  5;
    in[62] =  6;
    in[63] =  7;
    in[64] =  0;
    in[65] =  1;
    in[66] =  2;
    in[67] =  3;
    in[68] =  4;
    in[69] =  5;
    in[70] =  6;
    in[71] =  7;
// weights 2x2x3x3
    in[72] =  0.594184;
    in[73] =  0.477919;
    in[74] =  0.978544;
    in[75] =  0.194331;
    in[76] =  0.579522;
    in[77] =  0.015637;
    in[78] =  0.894881;
    in[79] =  0.505898;
    in[80] =  0.442344;
    in[81] =  0.795308;
    in[82] =  0.959499;
    in[83] =  0.845903;
    in[84] =  0.0113338;
    in[85] =  0.781664;
    in[86] =  0.36783;
    in[87] =  0.381876;
    in[88] =  0.138025;
    in[89] =  0.185136;
    in[90] =  0.845644;
    in[91] =  0.326279;
    in[92] =  0.946868;
    in[93] =  0.133039;
    in[94] =  0.267401;
    in[95] =  0.409488;
    in[96] =  0.467174;
    in[97] =  0.962629;
    in[98] =  0.61841;
    in[99] =  0.418975;
    in[100] =  0.373705;
    in[101] =  0.0665198;
    in[102] =  0.684322;
    in[103] =  0.967888;
    in[104] =  0.544438;
    in[105] =  0.662866;
    in[106] =  0.162219;
    in[107] =  0.12396;

// biases 2
    in[108] =  0;
    in[109] =  0;

    gold[0] = 11.9447;
    gold[1] = 17.6004;
    gold[2] = 18.0517;
    gold[3] = 12.4485;
    gold[4] = 10.6936;
    gold[5] = 11.021;
    gold[6] = 19.7199;
    gold[7] = 33.8221;
    gold[8] = 38.3358;
    gold[9] = 35.625;
    gold[10] = 33.0517;
    gold[11] = 16.116;
    gold[12] = 21.4011;
    gold[13] = 28.3836;
    gold[14] = 32.6059;
    gold[15] = 33.8221;
    gold[16] = 38.3358;
    gold[17] = 28.73;
    gold[18] = 18.0412;
    gold[19] = 25.7374;
    gold[20] = 28.6339;
    gold[21] = 28.3836;
    gold[22] = 32.6059;
    gold[23] = 22.29;
    gold[24] = 27.5145;
    gold[25] = 35.625;
    gold[26] = 33.0517;
    gold[27] = 25.7374;
    gold[28] = 28.6339;
    gold[29] = 22.401;
    gold[30] = 15.2995;
    gold[31] = 24.5508;
    gold[32] = 26.5163;
    gold[33] = 24.7961;
    gold[34] = 23.7217;
    gold[35] = 13.392;
    gold[36] = 17.8042;
    gold[37] = 23.7794;
    gold[38] = 22.0822;
    gold[39] = 19.9932;
    gold[40] = 18.2539;
    gold[41] = 11.77;
    gold[42] = 17.8807;
    gold[43] = 26.0861;
    gold[44] = 32.9287;
    gold[45] = 35.3668;
    gold[46] = 33.6579;
    gold[47] = 21.762;
    gold[48] = 18.8157;
    gold[49] = 27.3744;
    gold[50] = 32.4483;
    gold[51] = 26.0861;
    gold[52] = 32.9287;
    gold[53] = 26.997;
    gold[54] = 19.3747;
    gold[55] = 31.1951;
    gold[56] = 32.4338;
    gold[57] = 27.3744;
    gold[58] = 32.4483;
    gold[59] = 17.657;
    gold[60] = 24.0052;
    gold[61] = 35.3668;
    gold[62] = 33.6579;
    gold[63] = 31.1951;
    gold[64] = 32.4338;
    gold[65] = 21.088;
    gold[66] = 10.8142;
    gold[67] = 15.2837;
    gold[68] = 19.129;
    gold[69] = 23.5171;
    gold[70] = 26.512;
    gold[71] = 17.3371;

    if (!strcmp(esc_argv()[1], "custom")) {
        // for (int i=0; i<in_size;i++)
        //     input[i]=in[i];
        // for (int i=0; i<weights_size;i++)
        //     weights[i]=in[72+i];
        // for (int i=0; i<bias_size;i++)
        //     bias[i]=in[108+i];

        for (int i=0; i<in_size;i++)
            input[i]=gold[i];
        for (int i=0; i<weights_size;i++)
            weights[i]=in[72+i];
        for (int i=0; i<bias_size;i++)
            bias[i]=in[108+i];
    }
    else
    {
        init_tensor(input, in_size, true);
        init_tensor(weights, weights_size, true);
        init_tensor(bias, bias_size, true);
    }

#ifdef XS
    print_image("input-hw", input, batch_size, channels, height, width, false);
    print_weights("weights-hw", weights, num_filters, channels, kernel_h, kernel_w, false);
    print_bias("bias-hw", bias, num_filters, false);
    printf("\n");
#endif

    // Memory initialization:
#if (DMA_WORD_PER_BEAT == 0)
    for (i = 0; i < in_size; i++)  {
        sc_dt::sc_bv<DATA_WIDTH> data_bv =
	    fp2bv<FPDATA, DATA_WIDTH>(FPDATA(input[i]));
        for (j = 0; j < DMA_BEAT_PER_WORD; j++)
            mem[DMA_BEAT_PER_WORD * i + j] =
		data_bv.range((j + 1) * DMA_WIDTH - 1, j * DMA_WIDTH);
    }
    for (; i < in_size + weights_size; i++)  {
        sc_dt::sc_bv<DATA_WIDTH> data_bv =
	    fp2bv<FPDATA, DATA_WIDTH>(FPDATA(weights[i - in_size]));
        for (j = 0; j < DMA_BEAT_PER_WORD; j++)
            mem[DMA_BEAT_PER_WORD * i + j] =
		data_bv.range((j + 1) * DMA_WIDTH - 1, j * DMA_WIDTH);
    }
    for (; i < in_size + weights_size + bias_size; i++)  {
        sc_dt::sc_bv<DATA_WIDTH> data_bv =
	    fp2bv<FPDATA, DATA_WIDTH>(FPDATA(bias[i - in_size - weights_size]));
        for (j = 0; j < DMA_BEAT_PER_WORD; j++)
            mem[DMA_BEAT_PER_WORD * i + j] =
		data_bv.range((j + 1) * DMA_WIDTH - 1, j * DMA_WIDTH);
    }
#else
    for (i = 0; i < in_size / DMA_WORD_PER_BEAT; i++)  {
	// ESP_REPORT_INFO("tb load in %i : %f", i, (float) input[i]);
        sc_dt::sc_bv<DMA_WIDTH> data_bv = fp2bv<FPDATA, DATA_WIDTH>(FPDATA(input[i]));
        for (j = 0; j < DMA_WORD_PER_BEAT; j++)
            data_bv.range((j+1) * DATA_WIDTH - 1, j * DATA_WIDTH) =
		fp2bv<FPDATA, DATA_WIDTH>(FPDATA(input[i * DMA_WORD_PER_BEAT + j]));
        mem[i] = data_bv;
    }
    for (; i < (in_size + weights_size) / DMA_WORD_PER_BEAT; i++)  {
	// ESP_REPORT_INFO("tb load we %i : %f",
	// i, (float) weights[i - in_size / DMA_WORD_PER_BEAT]);
        sc_dt::sc_bv<DMA_WIDTH> data_bv =
	    fp2bv<FPDATA, DATA_WIDTH>(FPDATA(weights[i - in_size / DMA_WORD_PER_BEAT]));
        for (j = 0; j < DMA_WORD_PER_BEAT; j++)
            data_bv.range((j+1) * DATA_WIDTH - 1, j * DATA_WIDTH) =
		fp2bv<FPDATA, DATA_WIDTH>(FPDATA(weights[i * DMA_WORD_PER_BEAT + j - in_size]));
        mem[i] = data_bv;
    }
    for (; i < (in_size + weights_size + bias_size) / DMA_WORD_PER_BEAT; i++)  {
	// ESP_REPORT_INFO("tb load we %i : %f",
	// i, (float) bias[i - (in_size + weights_size) / DMA_WORD_PER_BEAT]);
        sc_dt::sc_bv<DMA_WIDTH> data_bv =
	    fp2bv<FPDATA, DATA_WIDTH>(
		FPDATA(bias[i - (in_size + weights_size) / DMA_WORD_PER_BEAT]));
        for (j = 0; j < DMA_WORD_PER_BEAT; j++)
            data_bv.range((j+1) * DATA_WIDTH - 1, j * DATA_WIDTH) =
		fp2bv<FPDATA, DATA_WIDTH>(
		    FPDATA(bias[i * DMA_WORD_PER_BEAT + j - in_size - weights_size]));
        mem[i] = data_bv;
    }
#endif

    ESP_REPORT_INFO("load memory completed");
}

void system_t::dump_memory()
{
    // Get results from memory
    uint32_t offset = in_size + weights_size + bias_size;
    // ESP_REPORT_INFO("DUMP MEM: offset %u", offset);

#if (DMA_WORD_PER_BEAT == 0)
    offset = offset * DMA_BEAT_PER_WORD;
    for (int i = 0; i < out_size; i++)  {
        sc_dt::sc_bv<DATA_WIDTH> data_bv;

        for (int j = 0; j < DMA_BEAT_PER_WORD; j++)
            data_bv.range((j + 1) * DMA_WIDTH - 1, j * DMA_WIDTH) =
		mem[offset + DMA_BEAT_PER_WORD * i + j];

        FPDATA fpdata_elem = bv2fp<FPDATA, DATA_WIDTH>(data_bv);
        hw_output[i] = (float) fpdata_elem.to_double();
    }
#else
    offset = offset / DMA_WORD_PER_BEAT;
    for (int i = 0; i < out_size / DMA_WORD_PER_BEAT; i++) {
        for (int j = 0; j < DMA_WORD_PER_BEAT; j++) {
            FPDATA fpdata_elem = bv2fp<FPDATA, DATA_WIDTH>
		(mem[offset + i].range((j + 1) * DATA_WIDTH - 1, j * DATA_WIDTH));
            hw_output[i * DMA_WORD_PER_BEAT + j] = (float) fpdata_elem.to_double();
	}
    }
#endif

    ESP_REPORT_INFO("dump memory completed");
}

int system_t::validate()
{
    // Check for mismatches
    uint32_t errors = 0;

    errors = _validate(hw_output, sw_output, batch_size, num_filters, output_pool_h, output_pool_w);

    // for (int i = 0; i < 1; i++)
    //     for (int j = 0; j < channels * height * width; j++)
    //         if (gold[i * out_words_adj + j] != out[i * out_words_adj + j])
    //             errors++;

    // delete [] in;
    // delete [] out;
    // delete [] gold;

    free(input);
    free(weights);
    free(bias);
    free(sw_output);
    free(hw_output);

    return errors;
}
