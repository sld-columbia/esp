// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __GEMM_DATA_HPP__
#define __GEMM_DATA_HPP__

#include <systemc.h>

// Data types

#if defined(FIXED_POINT)

const unsigned int FPDATA_WL = WORD_SIZE;
const unsigned int FPDATA_IL = WORD_SIZE / 2;
const unsigned int FPDATA_FL = WORD_SIZE - FPDATA_IL;
typedef sc_dt::sc_int<DMA_WIDTH> PLM_WORD;

#elif defined(FLOAT_POINT)

#if (WORD_SIZE == 32)
const unsigned int FPDATA_ML = 23;
const unsigned int FPDATA_EL = 8;
#elif (WORD_SIZE == 64)
const unsigned int FPDATA_ML = 52
const unsigned int FPDATA_EL = 12;
#endif

typedef sc_dt::sc_uint<DMA_WIDTH> PLM_WORD;

#endif

#endif // __GEMM_DATA_HPP__
