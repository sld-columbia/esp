// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __CONV2D_DATA_HPP__
#define __CONV2D_DATA_HPP__

#include <systemc.h>

// Data types

#if defined(FIXED_POINT)

const unsigned int FPDATA_WL = DATA_WIDTH;
const unsigned int FPDATA_IL = DATA_WIDTH / 2;
const unsigned int FPDATA_FL = DATA_WIDTH - FPDATA_IL;

#elif defined(FLOAT_POINT)

#if (DATA_WIDTH == 32)
const unsigned int FPDATA_ML = 23;
const unsigned int FPDATA_EL = 8;
#elif (DATA_WIDTH == 64)
const unsigned int FPDATA_ML = 52;
const unsigned int FPDATA_EL = 11;
#endif

#endif

// Custom SC data types
typedef sc_dt::sc_uint<2> uint2_t;
typedef sc_dt::sc_uint<4> uint4_t;
typedef sc_dt::sc_uint<12> uint12_t;
typedef sc_dt::sc_uint<20> uint20_t;
typedef sc_dt::sc_uint<24> uint24_t;
typedef sc_dt::sc_uint<28> uint28_t;
typedef sc_dt::sc_int<2> int2_t;
typedef sc_dt::sc_int<4> int4_t;
typedef sc_dt::sc_int<12> int12_t;
typedef sc_dt::sc_int<20> int20_t;
typedef sc_dt::sc_int<24> int24_t;
typedef sc_dt::sc_int<28> int28_t;

#endif // __CONV2D_DATA_HPP__
