// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "conv2d.hpp"

// Optional application-specific helper functions

inline void conv2d::compute_dimensions(
    const uint16_t height, const uint16_t width, const uint16_t n_channels,
    const bool is_padded, const uint4_t stride, const uint4_t filter_dim,
    const uint16_t n_filters, const uint2_t pool_type, const uint16_t batch_size,
    uint16_t *output_w, uint4_t *pad,
    uint16_t *feature_size, uint16_t *filter_size, uint32_t *filters_size, 
    uint16_t *max_cacheable_rows, uint16_t *max_cacheable_rows_init,
    uint16_t *max_cacheable_size,  uint16_t *max_cacheable_size_init,
    uint16_t *max_cacheable_filters, uint16_t *max_cacheable_filters_size,
    uint16_t *max_cacheable_bias_chunks, uint16_t *max_cacheable_bias_size,
    uint16_t *total_input_chunks, uint16_t *total_filters_chunks,
    uint16_t *feature_offset_incr, uint16_t *feature_offset_incr_init,
    uint16_t *channel_offset_incr, uint16_t *out_channel_offset_incr,
    uint16_t *out_channel_pool_offset_incr,
    uint32_t *filters_offset_start_base, uint32_t *bias_offset_start_base,
    uint32_t *feature_offset_start_base,
    uint12_t *loadable_chan, uint12_t *chan_iters, uint12_t *chan_rem,
    uint16_t *loadable_chan_sz, uint16_t *chan_rem_sz)
{
    uint8_t filter_dim2 = (uint8_t) filter_dim * filter_dim;
    /* Spatial dimensions of the output activation map */
    *pad = is_padded ? (filter_dim >> 1) : 0;
    *output_w = ((uint16_t) (width + 2 * *pad - filter_dim)) / stride + 1;

    /* Size (in number of words) of an input */
    *feature_size = height * width;

    /* Size (in number of weights) of each filter */
    *filter_size = n_channels * filter_dim2;
    *filters_size = *filter_size * n_filters;

    /* Max number of input rows cacheable in the input PLM */
    uint16_t max_io_channels = max(n_channels, n_filters);
    uint16_t io_channel_size = max_io_channels * width;
    *max_cacheable_rows = min(((uint16_t) INPUT_PLM_SIZE) / ((uint16_t) io_channel_size), height);

    *chan_iters = 1;
    *chan_rem = n_channels;
    *loadable_chan = n_channels;
    if (*max_cacheable_rows < filter_dim + 1) {
	*loadable_chan = ((uint16_t) INPUT_PLM_SIZE) / ((uint16_t) (width * (filter_dim + 1)));
	*chan_iters = ((uint16_t) (n_channels - 1)) / ((uint12_t) *loadable_chan) + 1;
	*chan_rem = n_channels - (*loadable_chan * (*chan_iters - 1));
	*max_cacheable_rows = filter_dim + 1;
    }
    *loadable_chan_sz = (uint16_t) *loadable_chan * filter_dim2;
    *chan_rem_sz = (uint16_t) *chan_rem * filter_dim2;

    *max_cacheable_rows_init = *max_cacheable_rows;

    /* Max number of input rows cacheable in the input PLM */
    // TODO optimize
    uint16_t cacheable_outputs = OUTPUT_PLM_SIZE / ((uint16_t) *output_w *
						    *max_cacheable_rows);
    uint16_t cacheable_filters = WEIGHTS_PLM_SIZE / (*filter_size);
    *max_cacheable_filters = (min(min(cacheable_filters, n_filters),
    				  min(cacheable_outputs, BIAS_PLM_SIZE)) >> 1) << 1;
    *max_cacheable_filters_size = *filter_size * *max_cacheable_filters;

    if (*max_cacheable_rows < height) {
    	if ((*max_cacheable_rows & 1) == 1) {
    	    *max_cacheable_rows -= 1;
    	    if (!is_padded)
    		*max_cacheable_rows_init -= 1;
    	} else {
    	    if (is_padded && (filter_dim == 3))
    		*max_cacheable_rows_init -= 1;
    	}
    }

    *max_cacheable_size = *max_cacheable_rows * width;
    *max_cacheable_size_init = *max_cacheable_rows_init * width;

    /* Amount of input chunks to be loaded in the input PLM */
    uint16_t max_cacheable_rows_norm = (*max_cacheable_rows) - filter_dim + 1;
    uint16_t max_cacheable_rows_norm_init = (*max_cacheable_rows_init) - filter_dim + 1;

    if (*max_cacheable_rows == height) {
    	*total_input_chunks = 1;
    } else {
    	*total_input_chunks = ((uint16_t) (height - *max_cacheable_rows_init - 1)) /
	    max_cacheable_rows_norm + 2;
    }

    /* Amount of filter chunks to be loaded in the filter PLM */
    *total_filters_chunks = ((uint16_t) (n_filters - 1)) / (*max_cacheable_filters) + 1;

    *max_cacheable_bias_chunks = BIAS_PLM_SIZE / *max_cacheable_filters;
    if (*max_cacheable_bias_chunks >= *total_filters_chunks)
    	*max_cacheable_bias_size = n_filters;
    else
    	*max_cacheable_bias_size = *max_cacheable_bias_chunks * *max_cacheable_filters;

    /* Load offsets */
    *channel_offset_incr = round_up(*feature_size, DMA_WORD_PER_BEAT);
    *out_channel_offset_incr = round_up(*output_w * *output_w, DMA_WORD_PER_BEAT);
    uint16_t output_pool_w = pool_type ? *output_w >> 1 : *output_w;
    *out_channel_pool_offset_incr = round_up(output_pool_w * output_pool_w, DMA_WORD_PER_BEAT);

    *feature_offset_incr = max_cacheable_rows_norm * width;
    *feature_offset_incr_init = max_cacheable_rows_norm_init * width;
    *filters_offset_start_base =  *channel_offset_incr * n_channels * batch_size;
    *bias_offset_start_base = *filters_offset_start_base + *filters_size;
    *feature_offset_start_base = *filters_offset_start_base + *filters_size + n_filters;

    /* Check if configuration is valid */
#ifndef STRATUS_HLS
    // assert(width * n_channels * filter_dim <= INPUT_PLM_SIZE);
    // assert(*filter_size <= WEIGHTS_PLM_SIZE - PARALLELISM);
    // assert(*filter_size <= PATCH_PLM_SIZE);
    // assert(*filter_size <= MAC_PLM_SIZE);
#endif
}

#ifndef NEWCOMPUTE
inline void conv2d::patch_extractor(
    const uint16_t channels, const uint16_t height, const uint16_t width,
    const uint16_t channel_size, const uint16_t ping_input,
    const uint16_t output_row,  const uint16_t output_col,
    const uint4_t pad, const uint4_t kernel_dim)
{
    uint16_t index = 0;
    uint16_t channel_base = 0;
    for(uint16_t channel = 0; channel < channels; channel++) {
        for (uint16_t kernel_row = 0; kernel_row < kernel_dim; kernel_row++) {
	    int input_row = output_row - pad + kernel_row;
	    int input_col = output_col - pad;
	    uint16_t plm_index = (uint16_t) channel_base +
		((uint16_t) input_row * width) + input_col;

            for (uint16_t kernel_col = 0; kernel_col < kernel_dim; kernel_col++) {

		FPDATA_WORD value;
		if (input_row >=0 && input_row < height && input_col >= 0 &&
		    input_col < width) {
		    if (ping_input)
			value = plm_in_ping[plm_index];
		    else
			value = plm_in_pong[plm_index];
		} else {
		    value = 0;
		}

		// std::cout << "PATCH " << index << " " << INT2FP(value) << std::endl;

                plm_patch[index++] = value;

		input_col++;
		plm_index++;

		wait();
            }
        }
	channel_base += channel_size;
    }
}
 
inline void conv2d::multiple_multiplier_accumulator(
    const uint16_t ping_weights, const uint16_t ping_bias, const uint16_t ping_output,
    const uint16_t filter_size, const uint16_t num_filters,
    const uint16_t filter_chunk, const uint16_t cacheable_filters,
    const uint16_t plm_bias_index, const uint16_t output_plm_offset,
    const uint16_t loadable_output_size, const bool do_relu)
{
    uint16_t output_plm_address;
    output_plm_address = output_plm_offset;
    for (uint16_t f = 0; f < cacheable_filters; f++) {
        FPDATA result_relu;
	FPDATA bias;
	FPDATA result_bias;
	FPDATA result_mac = 0;

        // elementwise_multiplier(ping_weights, filter_size, f);
	uint16_t start_address = filter_size * f;

	for (uint16_t i = 0; i < filter_size; i++) {
	    FPDATA weight;
	    if (ping_weights)
		weight = INT2FP(plm_weights_ping[start_address++]);
	    else
		weight = INT2FP(plm_weights_pong[start_address++]);
	    plm_mac[i] = FP2INT(INT2FP(plm_patch[i]) * weight);
	    // std::cout << "MULTIPLY patch * weight = res : " << INT2FP(plm_patch[i]) <<
	    // 	" " << INT2FP(weight) << " " << INT2FP(plm_mac[i]) << std::endl;
	    wait();
	}

	// accumulator(filter_size, &result);
	for(uint16_t i = 0; i < filter_size; i++) {
	    result_mac += INT2FP(plm_mac[i]);
	    // std::cout << "ACCUM i " << i << " val " << INT2FP(plm_mac[i]) <<
	    // 	" res " << INT2FP(result_mac) << std::endl;
	    wait();
	}

	if (ping_bias)
	    bias = INT2FP(plm_bias_ping[plm_bias_index + f]);
	else
	    bias = INT2FP(plm_bias_pong[plm_bias_index + f]);
	result_bias = result_mac + bias;
	if (do_relu && result_bias < 0)
	    result_relu = FPDATA(0);
	else
	    result_relu = result_bias;

	// ESP_REPORT_INFO("MAC out value %f", (float) result_relu.to_double());
	// ESP_REPORT_INFO("MAC out plm i: %u", output_plm_address);

	if (ping_output)
	    plm_out_ping[output_plm_address] = FP2INT(result_relu);
	else
	    plm_out_pong[output_plm_address] = FP2INT(result_relu);
	output_plm_address += loadable_output_size;
	wait();
    }
}
#endif

inline void conv2d::load_compute_cfg_handshake()
{
    HLS_DEFINE_PROTOCOL("load-compute-cfg-handshake");

    load_compute_cfg_done.req.req();
}

inline void conv2d::compute_load_cfg_handshake()
{
    HLS_DEFINE_PROTOCOL("compute-load-cfg-handshake");

    load_compute_cfg_done.ack.ack();
}

inline void conv2d::load_store_cfg_handshake()
{
    HLS_DEFINE_PROTOCOL("load-store-cfg-handshake");

    load_store_cfg_done.req.req();
}

inline void conv2d::store_load_cfg_handshake()
{
    HLS_DEFINE_PROTOCOL("store-load-cfg-handshake");

    load_store_cfg_done.ack.ack();
}
