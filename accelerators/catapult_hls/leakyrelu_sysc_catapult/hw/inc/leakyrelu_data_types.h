// Copyright (c) 2011-2024 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __DATATYPES__
#define __DATATYPES__

// #define FL_POINT
#include "ac_int.h"
#include "ac_fixed.h"
#include "ac_float.h"
#include "ac_std_float.h"
#include "ac_math.h"

#include "leakyrelu_specs.h"

#define FPDATA_WL DATA_WIDTH
#define FPDATA_IL DATA_WIDTH/2

typedef ac_int<DMA_WIDTH> DMA_WORD;
typedef ac_int<FPDATA_WL> FPDATA_WORD;

#ifdef FL_POINT
    #if (DATA_WIDTH == 32) 
        typedef ac_ieee_float32 FPDATA;
    #elif (DATA_WIDTH == 16)
        typedef ac_ieee_float16 FPDATA;
    #endif
    
    typedef ac_fixed<FPDATA_WL, FPDATA_IL> FXPDATA;

    inline void int2f(const FPDATA_WORD& in, FPDATA& out) {
        out.set_data(in);
    }
    inline void f2int(const FPDATA& in, FPDATA_WORD& out) {
        out = in.data();
    }
    inline void int2fx(const FPDATA_WORD& in,  FXPDATA& out)
    { out.set_slc(0, in.slc<FPDATA_WL>(0)); }

    inline void fx2int(const FXPDATA& in, FPDATA_WORD& out)
    { out.set_slc(0, in.slc<FPDATA_WL>(0)); }

#else
    typedef ac_fixed<FPDATA_WL, FPDATA_IL> FPDATA;

    inline void bv2fp(const FPDATA_WORD& data_in, FPDATA &data_out)
    {
        for (int i = 0; i < FPDATA_WL; i++)
            data_out.set_slc(i,data_in.slc<1>(i));
    }

    inline void int2fx(const FPDATA_WORD& in,  FPDATA& out)
    { out.set_slc(0, in.slc<FPDATA_WL>(0)); }

    inline void fx2int(const FPDATA& in, FPDATA_WORD& out)
    { out.set_slc(0, in.slc<FPDATA_WL>(0)); }
#endif

#endif
