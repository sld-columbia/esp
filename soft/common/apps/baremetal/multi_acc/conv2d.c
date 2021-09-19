/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include "multi_acc.h"
#include "conv2d.h"

int sw_is_a_ge_zero_and_a_lt_b (int a, int b) {
    return (a >= 0 && a < b);
}

float max_of_4(float a, float b, float c, float d) {
    if (a >= b && a >= c && a >= d) {
        return a;
    }
    if (b >= c && b >= d) {
        return b;
    }
    if (c >= d) {
        return c;
    }
    return d;
}

float avg_of_4(float a, float b, float c, float d) {
    return (a + b + c + d) / 4;
}

void pooling_2x2(float *in, float *out, unsigned size, unsigned type) {

    unsigned i, j, out_i;
    float a, b, c, d;
    for (i = 0; i < size - 1; i += 2) {
        for (j = 0; j < size - 1; j += 2) {
	    a = in[i * size + j];
	    b = in[(i + 1) * size + j];
	    c = in[i * size + (j + 1)];
	    d = in[(i + 1) * size + (j + 1)];
	    out_i = (i / 2) * (size/2) + (j / 2);
	    if (type == 1)
		out[out_i] = max_of_4(a, b, c, d);
	    else
		out[out_i] = avg_of_4(a, b, c, d);
	}
    }
}

void sw_conv_layer (
    const float* input, const int channels, const int height, const int width,
    const int kernel_h, const int kernel_w, const int pad_h, const int pad_w,
    const int stride_h, const int stride_w, const int dilation_h, const int dilation_w,
    const int num_filters, const float* weights, const float* biases, float* output,
    const int do_relu, const int pool_type, const int batch_size)
{

    const int channel_size = round_up(height * width, DMA_WORD_PER_BEAT(sizeof(token_t)));
    const int filter_size = channels * kernel_w * kernel_h;
    const int output_h = (height + 2 * pad_h - (dilation_h * (kernel_h - 1) + 1)) / stride_h + 1;
    const int output_w = (width + 2 * pad_w - (dilation_w * (kernel_w - 1) + 1)) / stride_w + 1;
    const int out_channel_size = round_up(output_w * output_h, DMA_WORD_PER_BEAT(sizeof(token_t)));
    const int pool_channel_size = round_up((output_w/2) * (output_h/2), DMA_WORD_PER_BEAT(sizeof(token_t)));

    for (int batch_i = 0;  batch_i < batch_size; batch_i++) {
	for (int num_filter = 0; num_filter < num_filters; num_filter++) {
	    for (int output_row = 0; output_row < output_h; output_row++) {
		for (int output_col = 0; output_col< output_w; output_col++) {
		    int k = 0;
		    float out_value = 0;
		    for (int channel = 0; channel < channels; channel++) {
			for (int kernel_row = 0; kernel_row < kernel_h; kernel_row++) {
			    for (int kernel_col = 0; kernel_col < kernel_w; kernel_col++) {
				int input_row = (output_row * stride_h) - pad_h + kernel_row * dilation_h;
				int input_col = (output_col * stride_w) - pad_w + kernel_col * dilation_w;
				if (!(!sw_is_a_ge_zero_and_a_lt_b(input_row, height) ||
				      (sw_is_a_ge_zero_and_a_lt_b(input_row, height) &&
				       !sw_is_a_ge_zero_and_a_lt_b(input_col, width)))) {
				    out_value += input[batch_i * channels * channel_size + channel * channel_size +
						       input_row * width + input_col] *
					weights[num_filter * filter_size + k];
				}
				k++;
			    }
			}
		    }
		    out_value += biases[num_filter];

		    if (do_relu && out_value < 0)
			out_value = 0;

		    output[batch_i * num_filters * out_channel_size + num_filter * out_channel_size +
			   output_row * output_w + output_col] = out_value;
		}
	    }

	    if (pool_type)
		pooling_2x2(&output[batch_i * num_filters * out_channel_size + num_filter * out_channel_size],
			    &output[batch_i * num_filters * pool_channel_size + num_filter * pool_channel_size],
			    output_w, pool_type);
	}
    }
}

void sw_run_conv2d(int32_t n_channels, int32_t feature_map_height, int32_t feature_map_width,
		   int32_t n_filters, int32_t filter_dim, int32_t is_padded, int32_t stride,
		   int32_t do_relu, int32_t pool_type, int32_t batch_size,
		   native_t *in, native_t *weights, native_t *bias, native_t *out)
{
    struct timespec th_start, th_end;
    int32_t pad_dim = 0;

    if (is_padded) {
	pad_dim = filter_dim / 2;
    }

    sw_conv_layer(in, n_channels, feature_map_height, feature_map_width, filter_dim, filter_dim,
		  pad_dim, pad_dim, stride, stride, 1, 1, n_filters, weights, bias, out,
		  do_relu, pool_type, batch_size);
}

int validate_buf_conv2d(token_t *out, native_t *gold)
{
	int j;
	native_t val;
	unsigned errors = 0;

        for (j = 0; j < out_len_conv2d; j++) {
#ifdef __FIXED
	    val = fx2float(out[j], FX_IL);
#else
            val = out[j];
#endif
            if (!gold[j] && val ||
		(((gold[j] - val) / gold[j]) > REL_ERROR_THRESHOLD ||
		((gold[j] - val) / gold[j]) < -REL_ERROR_THRESHOLD))
		{
                errors++;
                if (errors <= MAX_PRINTED_ERRORS) {
                    printf("%d : %d\n", (int) val, (int) gold[j]);
                }
            }
	}

	return errors;
}


void init_buf_conv2d (token_t *in, native_t *sw_buf)
{
//#include "input.h"
//#include "gold.h"

	int i;

	for (i = 0; i < weights_offset_conv2d; ++i) {
	    in[i] = float2fx(i % 14, FX_IL);
	    sw_buf[i] = i % 14;
	}
	for (; i < bias_offset_conv2d; ++i) {
	    in[i] = float2fx((i % 10) / 10, FX_IL);
	    sw_buf[i] = (i % 10) / 10;
	}
	for (; i < out_offset_conv2d; ++i) {
	    in[i] = float2fx(0, FX_IL);
	    sw_buf[i] = 0;
	}
}
