// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: MIT

#ifndef __ESP_FIXED_LIB_HPP__
#define __ESP_FIXED_LIB_HPP__

#include <cstdlib>
#include <cstddef>
#include <systemc.h>

#define MAX32 0x7FFFFFFF
#define MIN32 0x80000000

static int32_t fixed32_add(int32_t a, int32_t b)
{
    const int BITWIDTH = 32;

    sc_dt::sc_int<BITWIDTH + 1> c;

    c = a + b;

    if (c.range(BITWIDTH, BITWIDTH - 1) == 0x01)
	c = MAX32;

    else if (c.range(BITWIDTH, BITWIDTH-1) == 0x10)
	c = MIN32;
    
    return (int32_t) c;
}

static int32_t fixed32_mul(int32_t a, int32_t b, unsigned frac_bits)
{
    const int BITWIDTH = 32;

    sc_dt::sc_int<2 * BITWIDTH> c_ext;
    sc_dt::sc_int<2 * BITWIDTH> a_ext = a;
    sc_dt::sc_int<2 * BITWIDTH> b_ext = b;

    c_ext = a_ext * b_ext;

    c_ext = c_ext >> frac_bits;

    sc_dt::sc_int<BITWIDTH> c;
    
    // // if (c_ext.range(BITWIDTH, BITWIDTH - 1) == 0x01)
    // if (c_ext > (int32_t) MAX32)
    // 	c = MAX32;

    // // else if (c_ext.range(BITWIDTH, BITWIDTH-1) == 0x10)
    // else if (c_ext < (int32_t) MIN32)
    // 	c = MIN32;

    // else
	c = c_ext;

    return c;
}

#endif // __ESP_FIXED_LIB_HPP__
