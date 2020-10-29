// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef _UTILS_HPP_
#define _UTILS_HPP_

#include <stdint.h>
#include "conv2d_data.hpp"
#include "fpdata.hpp"

// Initialization functions
void init_image(float* image, float* golden_image, const int channels, const int height, const int width, bool random);

void init_weights(float* weights, float* golden_weights, const int filters, const int channels, const int height, const int width, bool random);

void init_array(float* matrix, const int length, bool random);

// Print functions
void print_hw_image(const char* name, float* matrix, const int channels, const int height, const int width);
void print_sw_image(const char* name, float* matrix, const int channels, const int height, const int width);

void print_hw_weights(const char* name, float* matrix, const int filters, const int channels, const int height, const int width);
void print_sw_weights(const char* name, float* matrix, const int filters, const int channels, const int height, const int width);

void print_array(const char* name, float* image, const int length);

// Manipulation functions
void transpose_matrix(float* image, const int height, const int width);

// Comparison functions
int _validate(float* hw_data_array, float* sw_data_array, int num_elements);

typedef union
{
    float fval;
    unsigned int rawbits;
} float_union_t;

#endif // _UTILS_HPP_
