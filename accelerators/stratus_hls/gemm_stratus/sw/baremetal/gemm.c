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
// #define BITWIDTH 64
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

typedef float native_t;

static unsigned DMA_WORD_PER_BEAT(unsigned _st)
{
        return (sizeof(void *) / _st);
}

#define MAX_PRINTED_ERRORS 10

#define SLD_GEMM 0x051
#define DEV_NAME "sld,gemm_stratus"

/* <<--params-->> */
const int32_t do_relu = 0;
const int32_t transpose = 1;
const int32_t ninputs = 2;
const int32_t d3 = 8;
const int32_t d2 = 8;
const int32_t d1 = 8;
int32_t st_offset;
const int32_t ld_offset1 = 0;
int32_t ld_offset2;

static unsigned in_words_adj;
static unsigned out_words_adj;
static unsigned in_len, in1_len;
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

static void sw_run(int32_t do_relu, int32_t transpose, int32_t ninputs,
		   int32_t d3, int32_t d2, int32_t d1,
		   native_t *in1, native_t *in2, native_t *out)
{
    int i, j, k, l;
    struct timespec th_start, th_end;
    native_t *in1_l, *in2_l, *out_l;

    for (l = 0; l < ninputs; ++l)
    {
	in1_l = &in1[l * d1 * d2];
	in2_l = &in2[l * d2 * d3];
	out_l = &out[l * d1 * d3];

	for (i = 0; i < d1; ++i)
	{
	    for (j = 0; j < d3; ++j)
	    {
		native_t accumulator = 0.0;

		for (k = 0; k < d2; ++k)
		{
		    int mtx_in1_i = i * d2 + k;
		    int mtx_in2_i = transpose ? (j * d2 + k) : (k * d3 + j);

		    accumulator += in1_l[mtx_in1_i] * in2_l[mtx_in2_i];
		}

		out_l[i * d3 + j] = accumulator;
	    }
	}
    }
}

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

            if (gold[j] != val) {
                errors++;
                if (errors <= MAX_PRINTED_ERRORS) {
		    printf("%d : %d : %d\n", j, (int) val, (int) gold[j]);
		}
            }
	}

	return errors;
}


static void init_buf (token_t *in, native_t *sw_buf)
{
    int i;

#include "input.h"

#ifdef __FIXED
    for (i = 0; i < ninputs * (d1*d2 + d2*d3); i++) {
	sw_buf[i] = in[i];
        in[i] = float2fx(in[i], FX_IL);
    }
#endif

//#include "gold.h"
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
	native_t *gold, *sw_buf;
	unsigned errors = 0;
	unsigned coherence;

	st_offset = ninputs * (d1 * d2 + d2 * d3);
	ld_offset2 = ninputs * (d1 * d2);
	
	in1_len = round_up(ninputs * d1 * d2, DMA_WORD_PER_BEAT(sizeof(token_t)));
	in_len = round_up(ninputs * (d1*d2 + d2*d3), DMA_WORD_PER_BEAT(sizeof(token_t)));
	out_len = round_up(ninputs * d1 * d3, DMA_WORD_PER_BEAT(sizeof(token_t)));
	in_size = in_len * sizeof(token_t);
	out_size = out_len * sizeof(token_t);
	out_offset  = in_len;
	mem_size = (out_offset * sizeof(token_t)) + out_size;

	// Search for the device
	printf("Scanning device tree... \n");

	ndev = probe(&espdevs, VENDOR_SLD, SLD_GEMM, DEV_NAME);
	if (ndev == 0) {
		printf("gemm not found\n");
		return 0;
	}

	dev = &espdevs[0];

	// Check DMA capabilities
	if (ioread32(dev, PT_NCHUNK_MAX_REG) == 0) {
	    printf("  -> scatter-gather DMA is disabled. Abort.\n");
	    return 0;
	}

	if (ioread32(dev, PT_NCHUNK_MAX_REG) < NCHUNK(mem_size)) {
	    printf("  -> Not enough TLB entries available. Abort.\n");
	    return 0;
	}

	// Allocate memory
	/* gold = aligned_malloc(out_size); */
	sw_buf = aligned_malloc(mem_size);
	mem = aligned_malloc(mem_size);
	printf("  memory buffer base-address = %p\n", mem);
	printf("  sw memory buffer base-address = %p\n", sw_buf);
	printf("  memory buffer base-address for gold = %p\n", gold);

	// Allocate and populate page table
	ptable = aligned_malloc(NCHUNK(mem_size) * sizeof(unsigned *));
	for (i = 0; i < NCHUNK(mem_size); i++)
	    ptable[i] = (unsigned *) &mem[i * (CHUNK_SIZE / sizeof(token_t))];

	printf("  ptable = %p\n", ptable);
	printf("  nchunk = %lu\n", NCHUNK(mem_size));

	/* TODO: Restore full test once ESP caches are integrated */
	coherence = ACC_COH_NONE;
		
	printf("  Generate input...\n");

	init_buf(mem, sw_buf);

	// Pass common configuration parameters
	iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
	iowrite32(dev, COHERENCE_REG, coherence);

	iowrite32(dev, PT_ADDRESS_REG, (unsigned long) ptable);

	iowrite32(dev, PT_NCHUNK_REG, NCHUNK(mem_size));
	iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);

	// Use the following if input and output data are not allocated at the default offsets
	iowrite32(dev, SRC_OFFSET_REG, 0);
	iowrite32(dev, DST_OFFSET_REG, 0);

	// Pass accelerator-specific configuration parametxers
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
	esp_flush(coherence);

	// Start accelerators
	printf("  Start...\n");

	iowrite32(dev, CMD_REG, CMD_MASK_START);

	// Wait for completion
	done = 0;
	while (!done) {
	    done = ioread32(dev, STATUS_REG);
	    done &= STATUS_MASK_DONE;
	}
	iowrite32(dev, CMD_REG, 0x0);

	printf("  Done\n");

	printf("  Start software execution\n");
	sw_run(do_relu, transpose, ninputs, d3, d2, d1,
	       sw_buf, &sw_buf[in1_len], &sw_buf[in_len]);
	printf("  Completed software execution\n");

	/* Validation */
	printf("  validating...\n");
	errors = validate_buf(&mem[out_offset], &sw_buf[out_offset]);

	if (errors)
	    printf("  ... FAIL\n");
	else
	    printf("  ... PASS\n");

	aligned_free(ptable);
	aligned_free(mem);
	aligned_free(sw_buf);
	/* aligned_free(gold); */

	return 0;
}
