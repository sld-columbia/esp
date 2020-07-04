/* Copyright (c) 2011-2019 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#ifndef __riscv
#include <stdio.h>
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
typedef unsigned token_t;
#elif (BITWIDTH == 64)
typedef long long unsigned token_t;
#endif
#endif

#ifdef __INT
#if (BITWIDTH == 32)
typedef int token_t;
#elif (BITWIDTH == 64)
typedef long long token_t;
#endif
#endif

#ifdef __FIXED
#if (BITWIDTH == 32)
typedef int token_t;
#define fx2float fixed32_to_float
#define float2fx float_to_fixed32
#define FX_IL 16
#elif (BITWIDTH == 64)
typedef long long token_t;
#define fx2float fixed64_to_double
#define float2fx double_to_fixed64
#define FX_IL 32
#endif
#endif

#ifdef __FLOAT
#if (BITWIDTH == 32)
typedef float token_t;
#elif (BITWIDTH == 64)
typedef double token_t;
#endif
#endif

#if (BITWIDTH == 32)
typedef float native_t;
#elif (BITWIDTH == 64)
typedef double native_t;
#endif

static unsigned DMA_WORD_PER_BEAT(unsigned _st)
{
        return (sizeof(void *) / _st);
}

#define MAX_PRINTED_ERRORS 10
#define REL_ERROR_THRESHOLD 0.01
#define SLD_CONV2D 0x052
#define DEV_NAME "sld,conv2d"

/* <<--params-->> */
const int32_t n_channels = 2;
const int32_t feature_map_height = 6;
const int32_t feature_map_width = 6;
const int32_t n_filters = 2;
const int32_t filter_height = 3;
const int32_t filter_width = 3;
const int32_t pad_h = 1;
const int32_t pad_w = 1;
const int32_t stride_h = 1;
const int32_t stride_w = 1;
const int32_t dilation_h = 1;
const int32_t dilation_w = 1;

static unsigned in_words_adj;
static unsigned weights_words_adj;
static unsigned out_words_adj;
static unsigned in_len;
static unsigned weights_len;
static unsigned out_len;
static unsigned in_size;
static unsigned weights_size;
static unsigned out_size;
static unsigned weights_offset;
static unsigned out_offset;
static unsigned mem_size;

/* Size of the contiguous chunks for scatter/gather */
#define CHUNK_SHIFT 20
#define CHUNK_SIZE BIT(CHUNK_SHIFT)
#define NCHUNK(_sz) ((_sz % CHUNK_SIZE == 0) ?		\
			(_sz / CHUNK_SIZE) :		\
			(_sz / CHUNK_SIZE) + 1)

/* User defined registers */
/* <<--regs-->> */
#define CONV2D_N_CHANNELS_REG 0x40
#define CONV2D_FEATURE_MAP_HEIGHT_REG 0x44
#define CONV2D_FEATURE_MAP_WIDTH_REG 0x48
#define CONV2D_N_FILTERS_REG 0x4c
#define CONV2D_FILTER_HEIGHT_REG 0x50
#define CONV2D_FILTER_WIDTH_REG 0x54
#define CONV2D_PAD_H_REG 0x58
#define CONV2D_PAD_W_REG 0x5c
#define CONV2D_STRIDE_H_REG 0x60
#define CONV2D_STRIDE_W_REG 0x64
#define CONV2D_DILATION_H_REG 0x68
#define CONV2D_DILATION_W_REG 0x6c



static int validate_buf(token_t *out, native_t *gold)
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
#ifndef __riscv
			printf("%d : %d\n", (int) val, (int) gold[j]);
#else
			print_uart_int((int) val); print_uart(" : ");
			print_uart_int((int) gold[j]); print_uart("\n");
#endif
                }
            }
	}

	return errors;
}


static void init_buf (token_t *in, native_t * gold)
{
#include "input.h"
#include "gold.h"
}


int main(int argc, char * argv[])
{
	int i;
	int n;
	int ndev;
	struct esp_device *espdevs;
	struct esp_device *dev;
	unsigned done;
	unsigned **ptable;
	token_t *mem;
	native_t *gold;
	unsigned errors = 0;

	// Input data and golden output (aligned to DMA_WIDTH makes your life easier)
	if (DMA_WORD_PER_BEAT(sizeof(token_t)) == 0) {
	    in_words_adj = n_channels * feature_map_height * feature_map_width;
	    weights_words_adj = n_filters * n_channels * filter_height * filter_width;
	    out_words_adj = n_filters * feature_map_height * feature_map_width;
	} else {
	    in_words_adj = round_up(n_channels * feature_map_height * feature_map_width,
				    DMA_WORD_PER_BEAT(sizeof(token_t)));
	    weights_words_adj = round_up(n_filters * n_channels * filter_height * filter_width,
					 DMA_WORD_PER_BEAT(sizeof(token_t)));
	    out_words_adj = round_up(n_filters * feature_map_height * feature_map_width,
				     DMA_WORD_PER_BEAT(sizeof(token_t)));
	}

	in_len = in_words_adj * (1);
	weights_len = weights_words_adj * (1);
	out_len = out_words_adj * (1);
	in_size = in_len * sizeof(token_t);
	weights_size = weights_len * sizeof(token_t);
	out_size = out_len * sizeof(token_t);
	weights_offset = in_len;
	out_offset  = in_len + weights_len;
	mem_size = in_size + weights_size + out_size;


	// Search for the device
#ifndef __riscv
	printf("Scanning device tree... \n");
#else
	print_uart("Scanning device tree... \n");
#endif

	ndev = probe(&espdevs, SLD_CONV2D, DEV_NAME);
	if (ndev == 0) {
#ifndef __riscv
		printf("conv2d not found\n");
#else
		print_uart("conv2d not found\n");
#endif
		return 0;
	}

	for (n = 0; n < ndev; n++) {

		dev = &espdevs[n];

		// Check DMA capabilities
		if (ioread32(dev, PT_NCHUNK_MAX_REG) == 0) {
#ifndef __riscv
			printf("  -> scatter-gather DMA is disabled. Abort.\n");
#else
			print_uart("  -> scatter-gather DMA is disabled. Abort.\n");
#endif
			return 0;
		}

		if (ioread32(dev, PT_NCHUNK_MAX_REG) < NCHUNK(mem_size)) {
#ifndef __riscv
			printf("  -> Not enough TLB entries available. Abort.\n");
#else
			print_uart("  -> Not enough TLB entries available. Abort.\n");
#endif
			return 0;
		}

		// Allocate memory
		gold = aligned_malloc(out_size);
		mem = aligned_malloc(mem_size);
#ifndef __riscv
		printf("  memory buffer base-address = %p\n", mem);
#else
		print_uart("  memory buffer base-address = "); print_uart_addr((uintptr_t) mem); print_uart("\n");
#endif
		// Alocate and populate page table
		ptable = aligned_malloc(NCHUNK(mem_size) * sizeof(unsigned *));
		for (i = 0; i < NCHUNK(mem_size); i++)
			ptable[i] = (unsigned *) &mem[i * (CHUNK_SIZE / sizeof(token_t))];
#ifndef __riscv
		printf("  ptable = %p\n", ptable);
		printf("  nchunk = %lu\n", NCHUNK(mem_size));
#else
		print_uart("  ptable = "); print_uart_addr((uintptr_t) ptable); print_uart("\n");
		print_uart("  nchunk = "); print_uart_int(NCHUNK(mem_size)); print_uart("\n");
#endif

#ifndef __riscv
		printf("  Generate input...\n");
#else
		print_uart("  Generate input...\n");
#endif
		init_buf(mem, gold);

		// Pass common configuration parameters

		iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
		iowrite32(dev, COHERENCE_REG, ACC_COH_NONE);

#ifndef __sparc
		iowrite32(dev, PT_ADDRESS_REG, (unsigned long long) ptable);
#else
		iowrite32(dev, PT_ADDRESS_REG, (unsigned) ptable);
#endif
		iowrite32(dev, PT_NCHUNK_REG, NCHUNK(mem_size));
		iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);

		// Use the following if input and output data are not allocated at the default offsets
		iowrite32(dev, SRC_OFFSET_REG, 0x0);
		iowrite32(dev, DST_OFFSET_REG, 0x0);

		// Pass accelerator-specific configuration parameters
		/* <<--regs-config-->> */
		iowrite32(dev, CONV2D_N_CHANNELS_REG, n_channels);
		iowrite32(dev, CONV2D_N_FILTERS_REG, n_filters);
		iowrite32(dev, CONV2D_FILTER_HEIGHT_REG, filter_height);
		iowrite32(dev, CONV2D_DILATION_H_REG, dilation_h);
		iowrite32(dev, CONV2D_STRIDE_W_REG, stride_w);
		iowrite32(dev, CONV2D_PAD_W_REG, pad_w);
		iowrite32(dev, CONV2D_FEATURE_MAP_HEIGHT_REG, feature_map_height);
		iowrite32(dev, CONV2D_PAD_H_REG, pad_h);
		iowrite32(dev, CONV2D_STRIDE_H_REG, stride_h);
		iowrite32(dev, CONV2D_FILTER_WIDTH_REG, filter_width);
		iowrite32(dev, CONV2D_DILATION_W_REG, dilation_w);
		iowrite32(dev, CONV2D_FEATURE_MAP_WIDTH_REG, feature_map_width);

		// Flush (customize coherence model here)
		esp_flush(ACC_COH_NONE);

		// Start accelerators
#ifndef __riscv
		printf("  Start...\n");
#else
		print_uart("  Start...\n");
#endif
		iowrite32(dev, CMD_REG, CMD_MASK_START);

		// Wait for completion
		done = 0;
		while (!done) {
			done = ioread32(dev, STATUS_REG);
			done &= STATUS_MASK_DONE;
		}
		iowrite32(dev, CMD_REG, 0x0);

#ifndef __riscv
		printf("  Done\n");
		printf("  validating...\n");
#else
		print_uart("  Done\n");
		print_uart("  validating...\n");
#endif

		/* Validation */
		errors = validate_buf(&mem[out_offset], gold);
#ifndef __riscv
		if (errors)
			printf("  ... FAIL\n");
		else
			printf("  ... PASS\n");
#else
		if (errors)
			print_uart("  ... FAIL\n");
		else
			print_uart("  ... PASS\n");
#endif

		aligned_free(ptable);
		aligned_free(mem);
		aligned_free(gold);
	}

	return 0;
}
