// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "golden.hpp"
#include <stdio.h>

void sw_conv_layer (
    const float* input, const int channels, const int height, const int width,
    const int kernel_h, const int kernel_w, const int pad_h, const int pad_w,
    const int stride_h, const int stride_w, const int dilation_h, const int dilation_w,
    const int num_filters, const float* weights, const float* biases, float* output,
    const bool do_relu)
{

    const int channel_size = height * width;
    const int filter_size = channels * kernel_w * kernel_h;
    const int output_h = (height + 2 * pad_h - (dilation_h * (kernel_h - 1) + 1)) / stride_h + 1;
    const int output_w = (width + 2 * pad_w - (dilation_w * (kernel_w - 1) + 1)) / stride_w + 1;


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
                                out_value += input[channel * channel_size + input_row * width +
						   input_col] * weights[num_filter * filter_size + k];
                            }
                            k++;
                        }
                    }
                }
		out_value += biases[num_filter];

		if (do_relu && out_value < 0)
		    out_value = 0;

                output[num_filter * output_w * output_h +
		       output_row * output_w + output_col] = out_value;
            }
        }
    }
}

void sw_conv_layer_fpdata (
    const FPDATA* input, const int channels, const int height, const int width,
    const int kernel_h, const int kernel_w, const int pad_h, const int pad_w,
    const int stride_h, const int stride_w,  const int dilation_h, const int dilation_w,
    const int num_filters, const FPDATA* weights, const FPDATA* biases, FPDATA* output,
    const bool do_relu)
{
    const int channel_size = height * width;
    const int filter_size = channels * kernel_w * kernel_h;
    const int output_h = (height + 2 * pad_h - (dilation_h * (kernel_h - 1) + 1)) / stride_h + 1;
    const int output_w = (width + 2 * pad_w - (dilation_w * (kernel_w - 1) + 1)) / stride_w + 1;


    for (int num_filter = 0; num_filter < num_filters; num_filter++) {
        for (int output_row = 0; output_row < output_h; output_row++) {
            for (int output_col = 0; output_col< output_w; output_col++) {
                int k = 0;
                FPDATA out_value = 0;
                for (int channel = 0; channel < channels; channel++) {
                    for (int kernel_row = 0; kernel_row < kernel_h; kernel_row++) {
                        for (int kernel_col = 0; kernel_col < kernel_w; kernel_col++) {
                            int input_row = (output_row * stride_h) - pad_h + kernel_row * dilation_h;
                            int input_col = (output_col * stride_w) - pad_w + kernel_col * dilation_w;
                            if (!(!sw_is_a_ge_zero_and_a_lt_b(input_row, height) ||
				  (sw_is_a_ge_zero_and_a_lt_b(input_row, height) &&
				   !sw_is_a_ge_zero_and_a_lt_b(input_col, width)))) {
                                out_value += input[channel * channel_size + input_row * width +
						   input_col] * weights[num_filter * filter_size + k];
                            }
                            k++;
                        }
                    }
                }
		out_value += biases[num_filter];

		if (do_relu && out_value < FPDATA(0.0))
		    out_value = FPDATA(0.0);

                output[num_filter * output_w * output_h +
		       output_row * output_w + output_col] = out_value;
            }
        }
    }
}
