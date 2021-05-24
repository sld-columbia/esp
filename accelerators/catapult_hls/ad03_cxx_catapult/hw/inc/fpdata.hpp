// Copyright (c) 2011-2021 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __SOFTMAX_FPDATA_HPP__
#define __SOFTMAX_FPDATA_HPP__

#include "ac_fixed.h"

// Data types

const unsigned int WL = 8;

// Please notice that although we use fixed-point precision there are no decimal bits <8,8>
const unsigned int FPDATA_WL = 8;
const unsigned int FPDATA_IN_IL = 8;
const unsigned int FPDATA_IN_PL = (FPDATA_WL - FPDATA_IN_IL);
const unsigned int FPDATA_OUT_IL = 8;
const unsigned int FPDATA_OUT_PL = (FPDATA_WL - FPDATA_OUT_IL);
typedef ac_fixed<FPDATA_WL, FPDATA_IN_IL, true, AC_TRN, AC_WRAP> FPDATA_IN;
typedef ac_fixed<FPDATA_WL, FPDATA_OUT_IL, false, AC_TRN, AC_WRAP> FPDATA_OUT;

//typedef ac_int<WL> FPDATA_WORD;


#include "defines.h"

#endif // __SOFTMAX_FPDATA_HPP__
