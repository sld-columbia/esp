// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef _UTILS_HPP_
#define _UTILS_HPP_

#include <stdint.h>
#include "conv2d_data.hpp"
#include "fpdata.hpp"
#include "conv2d_directives.hpp"
#include "conv2d.hpp"

// Initialization functions
void init_tensor(float* tensor, const int size, bool random);

// Print functions
void print_image(const char * name, float* image, const int batch_size, const int channels,
		 const int height, const int width, const bool fpdata);

void print_weights(const char * name, float* weights, const int filters, const int channels,
		   const int height, const int width, const bool fpdata);

void print_bias(const char * name, float* bias, const int n_filters, const bool fpdata);

void print_array(const char* name, float* image, const int length);

// Manipulation functions
void transpose_matrix(float* image, const int height, const int width);

// Comparison functions
int _validate(float* hw_data_array, float* sw_data_array, int batch_size, int filters, int output_h, int output_w);

typedef union
{
    float fval;
    unsigned int rawbits;
} float_union_t;

#endif // _UTILS_HPP_
