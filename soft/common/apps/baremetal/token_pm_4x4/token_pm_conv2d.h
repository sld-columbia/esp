/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>
#include <fixed_point.h>

/* User defined */

// Define data type (decomment the one needed)
// #define __UINT
// #define __INT
#define __FIXED
// #define __FLOAT

// Define bit width (decomment the one needed)
#ifndef __riscv
#define BITWIDTH 32
// #define BITWIDTH 64
#else
#define BITWIDTH 32
//#define BITWIDTH 64
#endif

/* End of user defined */

#ifdef __UINT
#if (BITWIDTH == 32)
typedef unsigned conv2d_token_t;
#elif (BITWIDTH == 64)
typedef long long unsigned conv2d_token_t;
#endif
#endif

#ifdef __INT
#if (BITWIDTH == 32)
typedef int conv2d_token_t;
#elif (BITWIDTH == 64)
typedef long long conv2d_token_t;
#endif
#endif

#ifdef __FIXED
#if (BITWIDTH == 32)
typedef int conv2d_token_t;
#define fx2float fixed32_to_float
#define float2fx float_to_fixed32
#define FX_IL 16
#elif (BITWIDTH == 64)
typedef long long conv2d_token_t;
#define fx2float fixed64_to_double
#define float2fx double_to_fixed64
#define FX_IL 32
#endif
#endif

#ifdef __FLOAT
#if (BITWIDTH == 32)
typedef float conv2d_token_t;
#elif (BITWIDTH == 64)
typedef double conv2d_token_t;
#endif
#endif

#if (BITWIDTH == 32)
typedef float native_t;
#elif (BITWIDTH == 64)
typedef double native_t;
#endif

static unsigned CONV2D_DMA_WORD_PER_BEAT(unsigned _st)
{
        return (sizeof(void *) / _st);
}

#define MAX_PRINTED_ERRORS 10
#define REL_ERROR_THRESHOLD 0.01
#define SLD_CONV2D 0x052
#define CONV2D_DEV_NAME "sld,conv2d_stratus"

/* <<--params-->> */
const int32_t n_channels = 2;
const int32_t feature_map_height = 6;
const int32_t feature_map_width = 6;
const int32_t n_filters = 2;
const int32_t filter_height = 3;
const int32_t filter_width = 3;
const int32_t pad_h = 1;
const int32_t pad_w = 1;
const int32_t is_padded = 1;
const int32_t stride_h = 1;
const int32_t stride_w = 1;
const int32_t dilation_h = 1;
const int32_t dilation_w = 1;
const int32_t conv2d_do_relu = 0;
const int32_t pool_type = 0;
//const int32_t batch_size = 1;
const int32_t batch_size = 70;

static unsigned in_words_adj;
static unsigned weights_words_adj;
static unsigned bias_words_adj;
static unsigned out_words_adj;
static unsigned in_len;
static unsigned weights_len;
static unsigned bias_len;
static unsigned out_len;
static unsigned in_size;
static unsigned weights_size;
static unsigned bias_size;
static unsigned out_size;
static unsigned weights_offset;
static unsigned bias_offset;
static unsigned out_offset;
static unsigned mem_size;

/* User defined registers */
/* <<--regs-->> */
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

static int conv2d_validate_buf(conv2d_token_t *out, native_t *gold)
{
	int j;
	native_t val;
	unsigned errors = 0;

        for (j = 0; j < out_len; j++) {
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


static unsigned conv2d_init_params()
{
	// Input data and golden output (aligned to DMA_WIDTH makes your life easier)
	if (CONV2D_DMA_WORD_PER_BEAT(sizeof(conv2d_token_t)) == 0) {
	    in_words_adj = n_channels * feature_map_height * feature_map_width;
	    weights_words_adj = n_filters * n_channels * filter_height * filter_width;
	    bias_words_adj = n_filters;
	    out_words_adj = n_filters * feature_map_height * feature_map_width;
	} else {
	    in_words_adj = round_up(n_channels * feature_map_height * feature_map_width,
				    CONV2D_DMA_WORD_PER_BEAT(sizeof(conv2d_token_t)));
	    weights_words_adj = round_up(n_filters * n_channels * filter_height * filter_width,
					 CONV2D_DMA_WORD_PER_BEAT(sizeof(conv2d_token_t)));
	    bias_words_adj = round_up(n_filters, CONV2D_DMA_WORD_PER_BEAT(sizeof(conv2d_token_t)));
	    out_words_adj = round_up(n_filters * feature_map_height * feature_map_width,
				     CONV2D_DMA_WORD_PER_BEAT(sizeof(conv2d_token_t)));
	}				  


	in_len = in_words_adj * (1);
	weights_len = weights_words_adj * (1);
	bias_len = bias_words_adj * (1);
	out_len = out_words_adj * (1);
	in_size = in_len * sizeof(conv2d_token_t);
	weights_size = weights_len * sizeof(conv2d_token_t);
	bias_size = bias_len * sizeof(conv2d_token_t);
	out_size = out_len * sizeof(conv2d_token_t);
	weights_offset = in_len;
	bias_offset = in_len + weights_len;
	out_offset  = in_len + weights_len + bias_len;
	mem_size = in_size + weights_size + bias_len + out_size;

	return mem_size;
}

void setup_conv2d(struct esp_device *dev, conv2d_token_t *mem_conv2d, unsigned **ptable, unsigned mem_size)
{
	mem_conv2d = aligned_malloc(mem_size);

	#include "conv2d_input.h"
	int i, size;
	size = (n_channels * feature_map_height * feature_map_width) +
		(n_channels * n_filters * filter_height * filter_width) +
		n_filters;

	//printf("  memory buffer base-address = %p\n", mem);

	// Allocate and populate page table
	ptable = aligned_malloc(NCHUNK(mem_size) * sizeof(unsigned *));
	for (i = 0; i < NCHUNK(mem_size); i++)
		ptable[i] = (unsigned *) &mem_conv2d[i * (CHUNK_SIZE / sizeof(conv2d_token_t))];
	//printf("  ptable = %p\n", ptable);
	//printf("  nchunk = %lu\n", NCHUNK(mem_size));


	//printf("  Generate input...\n");


	// Pass common configuration parameters

	iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
	iowrite32(dev, COHERENCE_REG, ACC_COH_RECALL);

	iowrite32(dev, PT_ADDRESS_REG, (unsigned long) ptable);
	iowrite32(dev, PT_NCHUNK_REG, NCHUNK(mem_size));
	iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);

	// Use the following if input and output data are not allocated at the default offsets
	iowrite32(dev, SRC_OFFSET_REG, 0x0);
	iowrite32(dev, DST_OFFSET_REG, 0x0);

	// Pass accelerator-specific configuration parameters
	/* <<--regs-config-->> */
	iowrite32(dev, CONV2D_N_CHANNELS_REG, n_channels);
	iowrite32(dev, CONV2D_FEATURE_MAP_HEIGHT_REG, feature_map_height);
	iowrite32(dev, CONV2D_FEATURE_MAP_WIDTH_REG, feature_map_width);
	iowrite32(dev, CONV2D_N_FILTERS_REG, n_filters);
	iowrite32(dev, CONV2D_FILTER_DIM_REG, filter_height);
	iowrite32(dev, CONV2D_IS_PADDED_REG, is_padded);
	iowrite32(dev, CONV2D_STRIDE_REG, stride_w);
	iowrite32(dev, CONV2D_DO_RELU_REG, conv2d_do_relu);
	iowrite32(dev, CONV2D_POOL_TYPE_REG, pool_type);
	iowrite32(dev, CONV2D_BATCH_SIZE_REG, batch_size);

}

