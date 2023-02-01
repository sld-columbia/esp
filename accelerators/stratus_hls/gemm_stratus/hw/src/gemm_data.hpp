// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __GEMM_DATA_HPP__
#define __GEMM_DATA_HPP__

#include <systemc.h>

#ifdef WORD_SIZE
#define WORDS_PER_DMA (DMA_WIDTH / WORD_SIZE)
#define WORDS_PER_DMA_LOG (slog_2<WORDS_PER_DMA>::value)
#endif

// Data types

#if defined(FIXED_POINT)

const unsigned int FPDATA_WL = WORD_SIZE;
const unsigned int FPDATA_IL = WORD_SIZE / 2;
const unsigned int FPDATA_FL = WORD_SIZE - FPDATA_IL;
typedef sc_dt::sc_int<WORD_SIZE> PLM_WORD;

#elif defined(FLOAT_POINT)

#if (WORD_SIZE == 32)
const unsigned int FPDATA_ML = 23;
const unsigned int FPDATA_EL = 8;
#elif (WORD_SIZE == 64)
const unsigned int FPDATA_ML = 52;
const unsigned int FPDATA_EL = 11;
#endif

typedef sc_dt::sc_uint<WORD_SIZE> PLM_WORD;

#endif

// Custom SC data types
typedef sc_dt::sc_uint<20> uint20_t;
typedef sc_dt::sc_uint<24> uint24_t;
typedef sc_dt::sc_uint<28> uint28_t;

#endif // __GEMM_DATA_HPP__
