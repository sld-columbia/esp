// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __DATATYPES__
#define __DATATYPES__

#include "ac_int.h"
#include "ac_fixed.h"
#include "<accelerator_name>_specs.hpp"

#define FPDATA_WL DATA_WIDTH
#define FPDATA_IL DATA_WIDTH/2

typedef ac_int<DMA_WIDTH> DMA_WORD;
typedef ac_int<FPDATA_WL> FPDATA_WORD;
typedef ac_fixed<FPDATA_WL, FPDATA_IL> FPDATA;

inline void int2fx(const FPDATA_WORD& in, FPDATA& out)
{ out.set_slc(0,in.slc<FPDATA_WL>(0)); }

inline void fx2int(const FPDATA& in, FPDATA_WORD& out)
{ out.set_slc(0,in.slc<FPDATA_WL>(0)); }

#endif
