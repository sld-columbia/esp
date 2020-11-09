// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef SRC_GOLDEN_CONV_LAYER_H_
#define SRC_GOLDEN_CONV_LAYER_H_

#include <stdlib.h>
#include "conv2d_data.hpp"
#include "fpdata.hpp"

inline bool sw_is_a_ge_zero_and_a_lt_b(int a, int b) {
    return static_cast<unsigned>(a) < static_cast<unsigned>(b);
}


void sw_conv_layer(const float* input, const int channels, const int height, const int width, const int kernel_h, const int kernel_w, const int pad_h, const int pad_w, const int stride_h, const int stride_w, const int dilation_h, const int dilation_w, const int num_filters, const float* weights, const float* biases, float* output, const bool do_relu);

void sw_conv_layer_fpdata(const FPDATA* input, const int channels, const int height, const int width, const int kernel_h, const int kernel_w, const int pad_h, const int pad_w, const int stride_h, const int stride_w, const int dilation_h, const int dilation_w, const int num_filters, const FPDATA* weights, const FPDATA* biases, FPDATA* output, const bool do_relu);

void sw_conv_layer_ver2(float* input, const int channels, const int height, const int width, const int kernel_h, const int kernel_w, const int pad_h, const int pad_w, const int stride_h, const int stride_w, const int dilation_h, const int dilation_w, const int num_filters, float* weights, float* biases, float* output, const bool do_relu);

#endif /* SRC_GOLDEN_CONV_LAYER_H_ */
