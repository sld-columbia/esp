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
//#define __INT
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
typedef unsigned gemm_token_t;
#elif (BITWIDTH == 64)
typedef long long unsigned gemm_token_t;
#endif
#endif

#ifdef __INT
#if (BITWIDTH == 32)
typedef int gemm_token_t;
#elif (BITWIDTH == 64)
typedef long long gemm_token_t;
#endif
#endif

#ifdef __FIXED
#if (BITWIDTH == 32)
typedef int gemm_token_t;
#define fx2float fixed32_to_float
#define float2fx float_to_fixed32
#define FX_IL 16
#elif (BITWIDTH == 64)
typedef long long gemm_token_t;
#define fx2float fixed64_to_double
#define float2fx double_to_fixed64
#define FX_IL 32
#endif
#endif

#ifdef __FLOAT
#if (BITWIDTH == 32)
typedef float gemm_token_t;
#elif (BITWIDTH == 64)
typedef double gemm_token_t;
#endif
#endif

typedef float native_t;

static unsigned GEMM_DMA_WORD_PER_BEAT(unsigned _st)
{
        return (sizeof(void *) / _st);
}

#define MAX_PRINTED_ERRORS 10

#define SLD_GEMM 0x051
#define NV_DEV_GEMM "sld,gemm_stratus"

/* <<--params-->> */
const int32_t gemm_do_relu = 0;
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
static unsigned in_len;
static unsigned out_len;
static unsigned in_size;
static unsigned out_size;
static unsigned out_offset;
static unsigned mem_size;

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

static int gemm_validate_buf(gemm_token_t *out, native_t *gold)
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


static void gemm_init_buf (gemm_token_t *in, native_t * gold)
{
    int i;

#include "gemm_input.h"

#ifdef __FIXED
    for (i = 0; i < ninputs * (d1*d2 + d2*d3); i++) {
        in[i] = float2fx(in[i], FX_IL);
    }
#endif

#include "gemm_gold.h"
}


static unsigned gemm_init_params()
{
	st_offset = ninputs * (d1 * d2 + d2 * d3);
	ld_offset2 = ninputs * (d1 * d2);
	
	if (GEMM_DMA_WORD_PER_BEAT(sizeof(gemm_token_t)) <= 1) {
		in_words_adj = ninputs * (d1*d2 + d2*d3);
		out_words_adj = ninputs * d1 * d3;
	} else {
		in_words_adj = round_up(ninputs * (d1*d2 + d2*d3), GEMM_DMA_WORD_PER_BEAT(sizeof(gemm_token_t)));
		out_words_adj = round_up(ninputs * d1 * d3, GEMM_DMA_WORD_PER_BEAT(sizeof(gemm_token_t)));
	}
	in_len = in_words_adj;
	out_len = out_words_adj;
	in_size = in_len * sizeof(gemm_token_t);
	out_size = out_len * sizeof(gemm_token_t);
	out_offset  = in_len;
	mem_size = (out_offset * sizeof(gemm_token_t)) + out_size;

	return mem_size;
}

void setup_gemm(struct esp_device *dev, gemm_token_t *mem_gemm, unsigned **ptable, unsigned mem_size)
{
    // Allocate memory
    mem_gemm = aligned_malloc(mem_size);
    int i;

    // Allocate and populate page table
    ptable = aligned_malloc(NCHUNK(mem_size) * sizeof(unsigned *));
    for (i = 0; i < NCHUNK(mem_size); i++)
        ptable[i] = (unsigned *) &mem_gemm[i * (CHUNK_SIZE / sizeof(gemm_token_t))];

    unsigned coherence = ACC_COH_RECALL;
    #ifdef DEBUG
   	 printf("  ptable = %p\n", ptable);
   	 printf("  nchunk = %lu\n", NCHUNK(mem_size));
    #endif

    // Pass accelerator-specific configuration parametxers
    /* <<--regs-config-->> */
    iowrite32(dev, GEMM_DO_RELU_REG, gemm_do_relu);
    iowrite32(dev, GEMM_TRANSPOSE_REG, transpose);
    iowrite32(dev, GEMM_NINPUTS_REG, ninputs);
    iowrite32(dev, GEMM_D3_REG, d3);
    iowrite32(dev, GEMM_D2_REG, d2);
    iowrite32(dev, GEMM_D1_REG, d1);
    iowrite32(dev, GEMM_ST_OFFSET_REG, st_offset);
    iowrite32(dev, GEMM_LD_OFFSET1_REG, ld_offset1);
    iowrite32(dev, GEMM_LD_OFFSET2_REG, ld_offset2);
    #ifdef DEBUG
   	 printf("Passed accelerator specific params\n");
    #endif

    // Pass common configuration parameters

    #ifdef DEBUG
   	 printf("Common params: DEVID: 0x%x, Coherence: %u\n", DEVID_REG, coherence);
    #endif

    iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
    iowrite32(dev, COHERENCE_REG, coherence);

    iowrite32(dev, PT_ADDRESS_REG, (unsigned long) ptable);

    iowrite32(dev, PT_NCHUNK_REG, NCHUNK(mem_size));
    iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);

    // Use the following if input and output data are not allocated at the default offsets
    iowrite32(dev, SRC_OFFSET_REG, 0);
    iowrite32(dev, DST_OFFSET_REG, 0);

    #ifdef DEBUG
   	 printf("Passed common params\n");
    #endif

}

