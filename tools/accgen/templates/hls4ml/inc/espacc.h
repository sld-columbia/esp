// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef INC_ESPACC_H
#define INC_ESPACC_H

#include "../inc/espacc_config.h"
#include <cstdio>

#include <ap_fixed.h>
#include <ap_int.h>

#include "defines.h"

// Data types and constants
#define VALUES_PER_WORD (DMA_SIZE / DATA_BITWIDTH)
#if ((SIZE_IN_CHUNK_DATA % VALUES_PER_WORD) == 0)
#define SIZE_IN_CHUNK (SIZE_IN_CHUNK_DATA / VALUES_PER_WORD)
#else
#define SIZE_IN_CHUNK (SIZE_IN_CHUNK_DATA / VALUES_PER_WORD + 1)
#endif
#if ((SIZE_OUT_CHUNK_DATA % VALUES_PER_WORD) == 0)
#define SIZE_OUT_CHUNK (SIZE_OUT_CHUNK_DATA / VALUES_PER_WORD)
#else
#define SIZE_OUT_CHUNK (SIZE_OUT_CHUNK_DATA / VALUES_PER_WORD + 1)
#endif

// data word
#if (IS_TYPE_FIXED_POINT ==  1)
typedef ap_fixed<DATA_BITWIDTH,DATA_BITWIDTH-FRAC_BITS> word_t;
#elif (IS_TYPE_UINT == 1)
typedef ap_uint<DATA_BITWIDTH> word_t;
#elif (IS_TYPE_FLOAT == 1)
#if (DATA_BITWIDTH == 32)
typedef float word_t;
#else
#error "Floating point word bitwidth not supported. Only 32 is supported."
#endif
#else // (IS_TYPE_INT == 1)
typedef ap_int<DATA_BITWIDTH> word_t;
#endif

typedef struct dma_word {
    word_t word[VALUES_PER_WORD];
} dma_word_t;

typedef word_t in_data_word;
typedef word_t out_data_word;

// Ctrl
typedef struct dma_info {
    ap_uint<32> index;
    ap_uint<32> length;
    ap_uint<32> size;
} dma_info_t;

// The 'size' variable of 'dma_info' indicates the bit-width of the words
// processed by the accelerator. Here are the encodings:
#define SIZE_BYTE   0
#define SIZE_HWORD  1
#define SIZE_WORD   2
#define SIZE_DWORD  3

#if (DATA_BITWIDTH == 8)
#define SIZE_WORD_T SIZE_BYTE
#elif (DATA_BITWIDTH == 16)
#define SIZE_WORD_T SIZE_HWORD
#elif (DATA_BITWIDTH == 32)
#define SIZE_WORD_T SIZE_WORD
#else // if (DATA_BITWIDTH == 64)
#define SIZE_WORD_T SIZE_DWORD
#endif

void top(dma_word_t *out, dma_word_t *in1,
	 const unsigned conf_info_nbursts,
	 dma_info_t &load_ctrl, dma_info_t &store_ctrl);

void compute(input_t _inbuff[SIZE_IN_CHUNK_DATA],
	     result_t _outbuff[SIZE_OUT_CHUNK_DATA]);

#endif
