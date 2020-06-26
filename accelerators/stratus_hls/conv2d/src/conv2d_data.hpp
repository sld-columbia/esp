// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __CONV2D_DATA_HPP__
#define __CONV2D_DATA_HPP__

#include <systemc.h>

// Data types

#if defined(FIXED_POINT)

const unsigned int FPDATA_WL = DATA_WIDTH;
const unsigned int FPDATA_IL = DATA_WIDTH / 2;
const unsigned int FPDATA_FL = DATA_WIDTH - FPDATA_IL;
typedef sc_dt::sc_int<DMA_WIDTH> PLM_WORD;

#elif defined(FLOAT_POINT)

#if (DATA_WIDTH == 32)
const unsigned int FPDATA_ML = 23;
const unsigned int FPDATA_EL = 8;
#elif (DATA_WIDTH == 64)
const unsigned int FPDATA_ML = 52;
const unsigned int FPDATA_EL = 12;
#endif

typedef sc_dt::sc_uint<DMA_WIDTH> PLM_WORD;

#endif

#endif // __CONV2D_DATA_HPP__
