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
// #define BITWIDTH 32
#define BITWIDTH 64
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
#define fx2float fixed32_to_double
#define float2fx double_to_fixed32
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

typedef double native_t;

static unsigned DMA_WORD_PER_BEAT(unsigned _st)
{
        return (sizeof(void *) / _st);
}

#define MAX_PRINTED_ERRORS 10

#define SLD_GEMM 0x067
#define DEV_NAME "sld,gemm"

/* <<--params-->> */
const int32_t do_relu = 0;
const int32_t transpose = 1;
const int32_t ninputs = 2;
const int32_t d3 = 4;
const int32_t d2 = 4;
const int32_t d1 = 4;
const int32_t st_offset = ninputs * (d1 * d2 + d2 * d3);
const int32_t ld_offset1 = 0;
const int32_t ld_offset2 = ninputs * (d1 * d2);

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
#define GEMM_TRANSPOSE_REG 0x60
#define GEMM_DO_RELU_REG 0x5c
#define GEMM_ST_OFFSET_REG 0x58
#define GEMM_LD_OFFSET2_REG 0x54
#define GEMM_LD_OFFSET1_REG 0x50
#define GEMM_D3_REG 0x4c
#define GEMM_D2_REG 0x48
#define GEMM_D1_REG 0x44
#define GEMM_NINPUTS_REG 0x40

static int validate_buf(token_t *out, native_t *gold)
{
	int i;
	int j;
	native_t val;
	unsigned errors = 0;

        for (j = 0; j < out_len; j++) {
#ifdef __FIXED
	    val = fx2float(out[j], FX_IL);
#else
            val = out[j];
#endif
            if (gold[j] != val) {
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
    int i;
    native_t cnt;

    cnt = 1;
    for (i = 0; i < ninputs * (d1*d2 + d2*d3); i++) {
#ifdef __FIXED
        in[i] = float2fx(cnt, FX_IL);
#else
	in[i] = cnt;
#endif
        cnt++;
        if (cnt == 17)
            cnt = 1;
    }

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

	if (DMA_WORD_PER_BEAT(sizeof(token_t)) <= 1) {
		in_words_adj = ninputs * (d1*d2 + d2*d3);
		out_words_adj = ninputs * d1 * d3;
	} else {
		in_words_adj = round_up(ninputs * (d1*d2 + d2*d3), DMA_WORD_PER_BEAT(sizeof(token_t)));
		out_words_adj = round_up(ninputs * d1 * d3, DMA_WORD_PER_BEAT(sizeof(token_t)));
	}
	in_len = in_words_adj;
	out_len = out_words_adj;
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

	ndev = probe(&espdevs, SLD_GEMM, DEV_NAME);
	if (ndev == 0) {
#ifndef __riscv
		printf("gemm not found\n");
#else
		print_uart("gemm not found\n");
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
		iowrite32(dev, GEMM_DO_RELU_REG, do_relu);
		iowrite32(dev, GEMM_TRANSPOSE_REG, transpose);
		iowrite32(dev, GEMM_NINPUTS_REG, ninputs);
		iowrite32(dev, GEMM_D3_REG, d3);
		iowrite32(dev, GEMM_D2_REG, d2);
		iowrite32(dev, GEMM_D1_REG, d1);
		iowrite32(dev, GEMM_ST_OFFSET_REG, st_offset);
		iowrite32(dev, GEMM_LD_OFFSET1_REG, ld_offset1);
		iowrite32(dev, GEMM_LD_OFFSET2_REG, ld_offset2);

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
