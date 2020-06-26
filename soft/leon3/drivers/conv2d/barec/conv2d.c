/* Copyright (c) 2011-2019 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#ifndef __riscv
#include <stdio.h>
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>

typedef int32_t token_t;

static unsigned DMA_WORD_PER_BEAT(unsigned _st)
{
        return (sizeof(void *) / _st);
}


#define SLD_CONV2D 0x052
#define DEV_NAME "sld,conv2d"

/* <<--params-->> */
const int32_t n_channels = 1;
const int32_t n_filters = 1;
const int32_t filter_height = 1;
const int32_t dilation_h = 1;
const int32_t stride_w = 1;
const int32_t pad_w = 1;
const int32_t feature_map_height = 1;
const int32_t pad_h = 1;
const int32_t stride_h = 1;
const int32_t filter_width = 1;
const int32_t dilation_w = 1;
const int32_t feature_map_width = 1;

static unsigned in_words_adj;
static unsigned out_words_adj;
static unsigned in_len;
static unsigned out_len;
static unsigned in_size;
static unsigned out_size;
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
#define CONV2D_N_CHANNELS_REG 0x6c
#define CONV2D_N_FILTERS_REG 0x68
#define CONV2D_FILTER_HEIGHT_REG 0x64
#define CONV2D_DILATION_H_REG 0x60
#define CONV2D_STRIDE_W_REG 0x5c
#define CONV2D_PAD_W_REG 0x58
#define CONV2D_FEATURE_MAP_HEIGHT_REG 0x54
#define CONV2D_PAD_H_REG 0x50
#define CONV2D_STRIDE_H_REG 0x4c
#define CONV2D_FILTER_WIDTH_REG 0x48
#define CONV2D_DILATION_W_REG 0x44
#define CONV2D_FEATURE_MAP_WIDTH_REG 0x40


static int validate_buf(token_t *out, token_t *gold)
{
	int i;
	int j;
	unsigned errors = 0;

	for (i = 0; i < 1; i++)
		for (j = 0; j < n_channels * feature_map_height * feature_map_width; j++)
			if (gold[i * out_words_adj + j] != out[i * out_words_adj + j])
				errors++;

	return errors;
}


static void init_buf (token_t *in, token_t * gold)
{
	int i;
	int j;

	for (i = 0; i < 1; i++)
		for (j = 0; j < n_channels * feature_map_height * feature_map_width; j++)
			in[i * in_words_adj + j] = (token_t) j;

	for (i = 0; i < 1; i++)
		for (j = 0; j < n_channels * feature_map_height * feature_map_width; j++)
			gold[i * out_words_adj + j] = (token_t) j;
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
	token_t *gold;
	unsigned errors = 0;

	if (DMA_WORD_PER_BEAT(sizeof(token_t)) == 0) {
		in_words_adj = n_channels * feature_map_height * feature_map_width;
		out_words_adj = n_channels * feature_map_height * feature_map_width;
	} else {
		in_words_adj = round_up(n_channels * feature_map_height * feature_map_width, DMA_WORD_PER_BEAT(sizeof(token_t)));
		out_words_adj = round_up(n_channels * feature_map_height * feature_map_width, DMA_WORD_PER_BEAT(sizeof(token_t)));
	}
	in_len = in_words_adj * (1);
	out_len = out_words_adj * (1);
	in_size = in_len * sizeof(token_t);
	out_size = out_len * sizeof(token_t);
	out_offset  = in_len;
	mem_size = (out_offset * sizeof(token_t)) + out_size;


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
