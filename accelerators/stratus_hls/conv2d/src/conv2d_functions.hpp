// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "conv2d.hpp"

// Optional application-specific helper functions

inline void conv2d::compute_dimensions(uint16_t height, uint16_t width, uint16_t channels, uint8_t pad_h,
				       uint8_t pad_w, uint8_t stride_h, uint8_t stride_w,
				       uint8_t dilation_h, uint8_t dilation_w,
				       uint8_t filter_height, uint8_t filter_width, uint16_t num_filters,
				       uint16_t *output_h, uint16_t *output_w,
				       uint16_t *filter_size, uint16_t *max_cacheable_rows, uint16_t *max_cacheable_size,
				       uint16_t *max_cacheable_filters, uint16_t *total_input_chunks,
				       uint16_t *total_filters_chunks) {

    /* Check if configuration is valid */
#ifndef STRATUS_HLS
    assert(height * channels * 3 <= INPUT_PLM_SIZE);
    assert(filter_height * filter_width * channels <= WEIGHTS_PLM_SIZE);
#endif

    /* Spatial dimensions of the output activation map */
    *output_h = (height + 2 * pad_h - (dilation_h * (filter_height - 1) + 1)) / stride_h + 1;
    *output_w = (width  + 2 * pad_w - (dilation_w * (filter_width  - 1) + 1)) / stride_w + 1;

    /* Size (in number of weights) of each filter */
    *filter_size = channels * filter_width * filter_height;

    /* Max number of input rows cacheable in the input PLM */
    *max_cacheable_rows = min(INPUT_PLM_SIZE / (channels * width), height);
    *max_cacheable_size = *max_cacheable_rows * width;

    /* Max number of input rows cacheable in the input PLM */
    unsigned tmp = WEIGHTS_PLM_SIZE / (*filter_size);
    *max_cacheable_filters = (min(min(tmp, num_filters), channels) >> 1) << 1;

    /* Amount of input chunks to be loaded in the input PLM */
    *total_input_chunks = ((height - 3)/((*max_cacheable_rows) - 2)) + 1;

    /* Amount of filter chunks to be loaded in the filter PLM */
    *total_filters_chunks = ((num_filters - 1) / (*max_cacheable_filters)) + 1;
}

inline void conv2d::patch_extractor(const uint16_t channels, const uint16_t height, const uint16_t width,
		     const uint16_t channel_size, const uint16_t ping_input,
		     const uint16_t output_row,  const uint16_t output_col,
		     const uint16_t pad_h, const uint16_t pad_w,
		     const uint16_t dilation_h, const uint16_t dilation_w,
		     const uint16_t kernel_h, const uint16_t kernel_w)
{
    // const uint16_t kernel_h = 3;
    // const uint16_t kernel_w = 3;

    uint16_t index = 0;
    uint16_t channel_base = 0;
    for(uint16_t channel = 0; channel < channels; channel++) {
        for (uint16_t kernel_row = 0; kernel_row < kernel_h; kernel_row++) {
            for (uint16_t kernel_col = 0; kernel_col < kernel_w; kernel_col++) {
                int input_row = output_row - pad_h + kernel_row * dilation_h;
                int input_col = output_col - pad_w + kernel_col * dilation_w;

		FPDATA_WORD value;
		if (input_row >=0 && input_row < height && input_col >= 0 && input_col < width)
		    if (ping_input)
			value = plm_in_ping[channel_base + input_row * width + input_col];
		    else
			value = plm_in_pong[channel_base + input_row * width + input_col];
		else
		    value = 0;


		// ESP_REPORT_INFO("PATCH %u %f", index, (float) value);

                plm_patch[index++] = value;
		wait();
            }
        }
	channel_base += channel_size;
    }
}

inline void conv2d::multiple_multiplier_accumulator(
    const uint16_t ping_weights, const uint16_t ping_output,
    const uint16_t filter_size, const uint16_t num_filters,
    const uint16_t filter_chunk, const uint16_t max_cacheable_filters,
    const uint16_t output_plm_offset, const uint16_t loadable_output_size)
{
    uint16_t output_plm_address;
    uint16_t cacheable_filters = min(num_filters - filter_chunk * max_cacheable_filters,
				     max_cacheable_filters);

    output_plm_address = output_plm_offset;
    for (uint16_t f = 0; f < cacheable_filters; f++) {

        FPDATA mmac_plm;

        // elementwise_multiplier(ping_weights, filter_size, f);
	uint16_t start_address = filter_size * f;

	for (uint16_t i = 0; i < filter_size; i++) {

	    FPDATA weight;

	    if (ping_weights)
		weight = INT2FP(plm_weights_ping[start_address++]);
	    else
		weight = INT2FP(plm_weights_pong[start_address++]);

	    plm_mac[i] = FP2INT(INT2FP(plm_patch[i]) * weight);

	    // ESP_REPORT_INFO("MULTIPLY patch * weight = res : %f * %f = %f",
	    // 		    (float) plm_patch[i], (float) weight, (float) plm_mac[i]);

	    wait();
	}


	// accumulator(filter_size, &result);
	FPDATA result = 0;
	FPDATA result_local = 0;
	for(uint16_t i = 0; i < filter_size; i++) {
	    result_local += INT2FP(plm_mac[i]);
	    // ESP_REPORT_INFO("ACCUM i %u val %f res %f", i, (float) plm_mac[i], (float) result_local);
	    wait();
	}
	result = result_local;

	mmac_plm = result;

	// ESP_REPORT_INFO("MAC out value %f", (float) mmac_plm.to_double());
	// ESP_REPORT_INFO("MAC out plm i: %u", output_plm_address);

	if (ping_output)
	    plm_out_ping[output_plm_address] = FP2INT(mmac_plm);
	else
	    plm_out_pong[output_plm_address] = FP2INT(mmac_plm);

	output_plm_address += loadable_output_size;

	wait();
    }
}
