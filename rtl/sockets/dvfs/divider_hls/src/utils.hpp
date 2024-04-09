/* Copyright 2017 Columbia University, SLD Group */

#ifndef __UTILS_HPP__
#define __UTILS_HPP__

#include <systemc.h>
#include <stdint.h>
#include <cynw_flex_channels.h>

// Unsigned integers

#define uint8_t unsigned char

#define uint16_t unsigned short

#define uint32_t unsigned int

#define uint64_t unsigned long long

// Signed integers

#define int8_t char

#define int16_t short

#define int32_t int

#define int64_t long long

// Custom sc_uint types

#define DIVIDEND_WIDTH 13
#define DIVISOR_WIDTH 7
#define QUOTIENT_WIDTH 6

typedef sc_uint<DIVIDEND_WIDTH> dividend_t;
typedef sc_uint<DIVISOR_WIDTH> divisor_t;
typedef sc_uint<QUOTIENT_WIDTH> quotient_t;

#endif // __UTILS_HPP__
