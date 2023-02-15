// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include <sstream>
#include "system.hpp"



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

	CONV_K_IN_CHANNELS = CONV_F_CHANNELS;
	DO_RELU = 0;
	POOL_TYPE = 1;
	BATCH_SIZE = 2;

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

    init_tensor(input, in_size, true);
    init_tensor(weights, weights_size, true);
    init_tensor(bias, bias_size, true);

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
