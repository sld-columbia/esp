// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __FFT_DATA_HPP__
#define __FFT_DATA_HPP__

#include <systemc.h>

#ifdef WORD_SIZE
#define WORDS_PER_DMA (DMA_WIDTH / WORD_SIZE)
#define WORDS_PER_DMA_LOG (slog_2<WORDS_PER_DMA>::value)
#endif

// Data types

#if defined(FIXED_POINT)

const unsigned int FPDATA_WL = WORD_SIZE;
#if (FX_WIDTH == 32)
const unsigned int FPDATA_IL = FX32_IL;
#else
const unsigned int FPDATA_IL = FX64_IL;
#endif
const unsigned int FPDATA_FL = FPDATA_WL - FPDATA_IL;

#elif defined(FLOAT_POINT)

#if (WORD_SIZE == 32)
const unsigned int FPDATA_ML = 23;
const unsigned int FPDATA_EL = 8;
#elif (WORD_SIZE == 64)
const unsigned int FPDATA_ML = 52;
const unsigned int FPDATA_EL = 11;
#endif

#endif

#endif // __FFT_DATA_HPP__
