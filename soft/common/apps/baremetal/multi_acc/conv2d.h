/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#ifndef __CONV2D_H__
#define __CONV2D_H__

#include "multi_acc.h"

#define SLD_CONV2D 0x052
#define DEV_NAME_CONV2D "sld,conv2d_stratus"

static int32_t batch_size;
static int32_t n_channels;
static int32_t feature_map_height;
static int32_t feature_map_width;
static int32_t n_filters;
static int32_t filter_height;
static int32_t filter_width;
static int32_t pad_h;
static int32_t pad_w;
static int32_t is_padded;
static int32_t stride_h;
static int32_t stride_w;
static int32_t dilation_h;
static int32_t dilation_w;
static int32_t do_relu_conv2d;
static int32_t pool_type;

static unsigned in_len_conv2d;
static unsigned weights_len_conv2d;
static unsigned bias_len_conv2d;
static unsigned out_len_conv2d;
static unsigned in_size_conv2d;
static unsigned weights_size_conv2d;
static unsigned bias_size_conv2d;
static unsigned out_size_conv2d;
static unsigned weights_offset_conv2d;
static unsigned bias_offset_conv2d;
static unsigned out_offset_conv2d;
static unsigned mem_size_conv2d;

/* User defined registers */
#define CONV2D_N_CHANNELS_REG 0x40
#define CONV2D_FEATURE_MAP_HEIGHT_REG 0x44
#define CONV2D_FEATURE_MAP_WIDTH_REG 0x48
#define CONV2D_N_FILTERS_REG 0x4c
#define CONV2D_FILTER_DIM_REG 0x50
#define CONV2D_IS_PADDED_REG 0x54
#define CONV2D_STRIDE_REG 0x58
#define CONV2D_DO_RELU_REG 0x5c
#define CONV2D_POOL_TYPE_REG 0x60
#define CONV2D_BATCH_SIZE_REG 0x64

int sw_is_a_ge_zero_and_a_lt_b (int a, int b);
float max_of_4(float a, float b, float c, float d);
float avg_of_4(float a, float b, float c, float d);
void pooling_2x2(float *in, float *out, unsigned size, unsigned type);
void sw_conv_layer (
    const float* input, const int channels, const int height, const int width,
    const int kernel_h, const int kernel_w, const int pad_h, const int pad_w,
    const int stride_h, const int stride_w, const int dilation_h, const int dilation_w,
    const int num_filters, const float* weights, const float* biases, float* output,
    const int do_relu, const int pool_type, const int batch_size);
void sw_run_conv2d(int32_t n_channels, int32_t feature_map_height, int32_t feature_map_width,
		   int32_t n_filters, int32_t filter_dim, int32_t is_padded, int32_t stride,
		   int32_t do_relu, int32_t pool_type, int32_t batch_size,
			  native_t *in, native_t *weights, native_t *bias, native_t *out);
int validate_buf_conv2d(token_t *out, native_t *gold);
void init_buf_conv2d (token_t *in, native_t *sw_buf);

#endif // __CONV2D_H__
