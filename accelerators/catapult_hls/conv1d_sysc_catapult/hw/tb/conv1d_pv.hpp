// Copyright (c) 2011-2025 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __CONV1D_PV_HPP__
#define __CONV1D_PV_HPP__

#include <cmath>

// Golden reference for 1D convolution
inline void conv1d_golden(
    float *input,
    float *weights,
    float *bias,
    float *output,
    int n_channels,
    int feature_map_len,
    int n_filters,
    int kernel_size,
    int stride)
{
    int out_len = feature_map_len / stride;
    int pad_needed = (out_len - 1) * stride + kernel_size - feature_map_len;
    int pad_left = (pad_needed > 0) ? pad_needed / 2 : 0;

    // Convolution
    for (int i = 0; i < n_filters; i++) {
        for (int j = 0; j < out_len; j++) {
            float sum = 0.0f;
            for (int k = 0; k < n_channels; k++) {
                for (int l = 0; l < kernel_size; l++) {
                    int l_in = j * stride - pad_left + l;
                    if (l_in < 0 || l_in >= feature_map_len)
                        continue; // zero padding for out-of-bounds
                    int input_idx = k * feature_map_len + l_in;
                    int weight_idx = i * n_channels * kernel_size + k * kernel_size + l;
                    sum += input[input_idx] * weights[weight_idx];
                }
            }
            output[i * out_len + j] = sum;
        }
    }

    // Bias addition and Leaky ReLU
    for (int i = 0; i < n_filters; i++) {
        for (int j = 0; j < out_len; j++) {
            float val = output[i * out_len + j] + bias[i];
            if (val < 0.0f) {
                val = val * 0.3f;
            }
            output[i * out_len + j] = val;
        }
    }
}

#endif // __CONV1D_PV_HPP__
