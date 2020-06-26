// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "golden.hpp"
#include <stdio.h>

void sw_conv_layer (const float* input,
        const int channels, const int height, const int width,
        const int kernel_h, const int kernel_w,
        const int pad_h, const int pad_w,
        const int stride_h, const int stride_w,
        const int dilation_h, const int dilation_w,
        const int num_filters, const float* weights,
        float* output) {

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
                            int input_row = output_row - pad_h + kernel_row * dilation_h;
                            int input_col = output_col - pad_w + kernel_col * dilation_w;
                            if (!(!sw_is_a_ge_zero_and_a_lt_b(input_row, height) || (sw_is_a_ge_zero_and_a_lt_b(input_row, height) && !sw_is_a_ge_zero_and_a_lt_b(input_col, width)))) {
                                out_value += input[channel * channel_size + input_row * width + input_col] * weights[num_filter * filter_size + k];
                            }
                            k++;
                        }
                    }
                }
                output[num_filter * output_w * output_h + output_row * output_w + output_col] = out_value;
            }
        }
    }
}

void sw_conv_layer_fpdata (const FPDATA* input,
        const int channels, const int height, const int width,
        const int kernel_h, const int kernel_w,
        const int pad_h, const int pad_w,
        const int stride_h, const int stride_w,
        const int dilation_h, const int dilation_w,
        const int num_filters, const FPDATA* weights,
        FPDATA* output) {

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
                            int input_row = output_row - pad_h + kernel_row * dilation_h;
                            int input_col = output_col - pad_w + kernel_col * dilation_w;
                            if (!(!sw_is_a_ge_zero_and_a_lt_b(input_row, height) || (sw_is_a_ge_zero_and_a_lt_b(input_row, height) && !sw_is_a_ge_zero_and_a_lt_b(input_col, width)))) {
                                out_value += input[channel * channel_size + input_row * width + input_col] * weights[num_filter * filter_size + k];
                            }
                            k++;
                        }
                    }
                }
                output[num_filter * output_w * output_h + output_row * output_w + output_col] = out_value;
            }
        }
    }
}


void conv_3x3(float *matrix, float *kernel, float *out, unsigned size) {

    unsigned i, j;
    float sum;
    float zeropad[224 + 2][224 + 2] = { { 0.0 } };

    for (i = 0; i < size; i++) {
        for (j = 0; j < size; j++) {
            zeropad[i + 1][j + 1] = matrix[i * size + j];
        }
    }

    for (i = 0; i < size; i++) {
        for (j = 0; j < size; j++) {
            printf("[%u,%u]\n", i, j);
#if 1
            sum = (zeropad[i    ][j    ] * kernel[0 * 3 + 0]) +
                  (zeropad[i    ][j + 1] * kernel[0 * 3 + 1]) +
                  (zeropad[i    ][j + 2] * kernel[0 * 3 + 2]) +
                  (zeropad[i + 1][j    ] * kernel[1 * 3 + 0]) +
                  (zeropad[i + 1][j + 1] * kernel[1 * 3 + 1]) +
                  (zeropad[i + 1][j + 2] * kernel[1 * 3 + 2]) +
                  (zeropad[i + 2][j    ] * kernel[2 * 3 + 0]) +
                  (zeropad[i + 2][j + 1] * kernel[2 * 3 + 1]) +
                  (zeropad[i + 2][j + 2] * kernel[2 * 3 + 2]);
#else
            sum = (zeropad[i    ][j    ] * kernel[2 * 3 + 2]) +
                  (zeropad[i    ][j + 1] * kernel[2 * 3 + 1]) +
                  (zeropad[i    ][j + 2] * kernel[2 * 3 + 0]) +
                  (zeropad[i + 1][j    ] * kernel[1 * 3 + 2]) +
                  (zeropad[i + 1][j + 1] * kernel[1 * 3 + 1]) +
                  (zeropad[i + 1][j + 2] * kernel[1 * 3 + 0]) +
                  (zeropad[i + 2][j    ] * kernel[0 * 3 + 2]) +
                  (zeropad[i + 2][j + 1] * kernel[0 * 3 + 1]) +
                  (zeropad[i + 2][j + 2] * kernel[0 * 3 + 0]);
#endif
            out[i * size + j] += sum;
        }
    }
}

void sw_conv_layer_ver2(float* input, const int channels, const int height, const int width, const int kernel_h, const int kernel_w, const int pad_h, const int pad_w, const int stride_h, const int stride_w, const int dilation_h, const int dilation_w, const int num_filters, float* weights, float* output) {
    int i, j;

    memset(output, 0, num_filters*height*width * sizeof(float));

    for (i = 0; i < num_filters; i++) {
        printf("F: %u\n", i);
        for (j = 0; j < channels; j++) {
            printf("C: %u\n", j);
            conv_3x3(input + j * height * width, weights + i * channels * kernel_h * kernel_w + j * kernel_h * kernel_w, output + i * height * width, height);
        }
    }
}
