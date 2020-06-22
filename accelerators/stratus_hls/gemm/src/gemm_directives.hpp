// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __GEMM_DIRECTIVES_HPP__
#define __GEMM_DIRECTIVES_HPP__

// Macros
#if defined(STRATUS_HLS)

#if defined(HLS_DIRECTIVES_BASIC)

#if (DMA_WIDTH == 32)

#if (DMA_CHUNK == 128)

// define differently depending on chunk size
#define HLS_MAP_IN0 HLS_MAP_TO_MEMORY(input0, "plm_w32_chk128_1w1r")
#define HLS_MAP_IN1 HLS_MAP_TO_MEMORY(input1, "plm_w32_chk128_1w1r")
#define HLS_MAP_IN2 HLS_MAP_TO_MEMORY(input2, "plm_w32_chk128_1w1r")
#define HLS_MAP_IN3 HLS_MAP_TO_MEMORY(input3, "plm_w32_chk128_1w1r")
#define HLS_MAP_OUT HLS_MAP_TO_MEMORY(output, "plm_w32_chk128_1w1r")

#elif (DMA_CHUNK == 512)

// define differently depending on chunk size
#define HLS_MAP_IN0 HLS_MAP_TO_MEMORY(input0, "plm_w32_chk512_1w1r")
#define HLS_MAP_IN1 HLS_MAP_TO_MEMORY(input1, "plm_w32_chk512_1w1r")
#define HLS_MAP_IN2 HLS_MAP_TO_MEMORY(input2, "plm_w32_chk512_1w1r")
#define HLS_MAP_IN3 HLS_MAP_TO_MEMORY(input3, "plm_w32_chk512_1w1r")
#define HLS_MAP_OUT HLS_MAP_TO_MEMORY(output, "plm_w32_chk512_1w1r")

#elif (DMA_CHUNK == 2048)

// define differently depending on chunk size
#define HLS_MAP_IN0 HLS_MAP_TO_MEMORY(input0, "plm_w32_chk2048_1w1r")
#define HLS_MAP_IN1 HLS_MAP_TO_MEMORY(input1, "plm_w32_chk2048_1w1r")
#define HLS_MAP_IN2 HLS_MAP_TO_MEMORY(input2, "plm_w32_chk2048_1w1r")
#define HLS_MAP_IN3 HLS_MAP_TO_MEMORY(input3, "plm_w32_chk2048_1w1r")
#define HLS_MAP_OUT HLS_MAP_TO_MEMORY(output, "plm_w32_chk2048_1w1r")

#elif (DMA_CHUNK == 8192)

// define differently depending on chunk size
#define HLS_MAP_IN0 HLS_MAP_TO_MEMORY(input0, "plm_w32_chk8192_1w1r")
#define HLS_MAP_IN1 HLS_MAP_TO_MEMORY(input1, "plm_w32_chk8192_1w1r")
#define HLS_MAP_IN2 HLS_MAP_TO_MEMORY(input2, "plm_w32_chk8192_1w1r")
#define HLS_MAP_IN3 HLS_MAP_TO_MEMORY(input3, "plm_w32_chk8192_1w1r")
#define HLS_MAP_OUT HLS_MAP_TO_MEMORY(output, "plm_w32_chk8192_1w1r")

#else

#error Unsupported or undefined HLS configuration

#endif

#elif (DMA_WIDTH == 64)

#if (DMA_CHUNK == 128)

// define differently depending on chunk size
#define HLS_MAP_IN0 HLS_MAP_TO_MEMORY(input0, "plm_w64_chk128_1w1r")
#define HLS_MAP_IN1 HLS_MAP_TO_MEMORY(input1, "plm_w64_chk128_1w1r")
#define HLS_MAP_IN2 HLS_MAP_TO_MEMORY(input2, "plm_w64_chk128_1w1r")
#define HLS_MAP_IN3 HLS_MAP_TO_MEMORY(input3, "plm_w64_chk128_1w1r")
#define HLS_MAP_OUT HLS_MAP_TO_MEMORY(output, "plm_w64_chk128_1w1r")

#elif (DMA_CHUNK == 512)

// define differently depending on chunk size
#define HLS_MAP_IN0 HLS_MAP_TO_MEMORY(input0, "plm_w64_chk512_1w1r")
#define HLS_MAP_IN1 HLS_MAP_TO_MEMORY(input1, "plm_w64_chk512_1w1r")
#define HLS_MAP_IN2 HLS_MAP_TO_MEMORY(input2, "plm_w64_chk512_1w1r")
#define HLS_MAP_IN3 HLS_MAP_TO_MEMORY(input3, "plm_w64_chk512_1w1r")
#define HLS_MAP_OUT HLS_MAP_TO_MEMORY(output, "plm_w64_chk512_1w1r")

#elif (DMA_CHUNK == 2048)

// define differently depending on chunk size
#define HLS_MAP_IN0 HLS_MAP_TO_MEMORY(input0, "plm_w64_chk2048_1w1r")
#define HLS_MAP_IN1 HLS_MAP_TO_MEMORY(input1, "plm_w64_chk2048_1w1r")
#define HLS_MAP_IN2 HLS_MAP_TO_MEMORY(input2, "plm_w64_chk2048_1w1r")
#define HLS_MAP_IN3 HLS_MAP_TO_MEMORY(input3, "plm_w64_chk2048_1w1r")
#define HLS_MAP_OUT HLS_MAP_TO_MEMORY(output, "plm_w64_chk2048_1w1r")

#elif (DMA_CHUNK == 8192)

// define differently depending on chunk size
#define HLS_MAP_IN0 HLS_MAP_TO_MEMORY(input0, "plm_w64_chk8192_1w1r")
#define HLS_MAP_IN1 HLS_MAP_TO_MEMORY(input1, "plm_w64_chk8192_1w1r")
#define HLS_MAP_IN2 HLS_MAP_TO_MEMORY(input2, "plm_w64_chk8192_1w1r")
#define HLS_MAP_IN3 HLS_MAP_TO_MEMORY(input3, "plm_w64_chk8192_1w1r")
#define HLS_MAP_OUT HLS_MAP_TO_MEMORY(output, "plm_w64_chk8192_1w1r")

#else

#error Unsupported or undefined HLS configuration
    
#endif

#endif

#endif /* HLS_DIRECTIVES_* */

#else /* !STRATUS_HLS */

#ifndef HLS_MAP_IN0
#define HLS_MAP_IN0
#endif
#ifndef HLS_MAP_IN1
#define HLS_MAP_IN1
#endif
#ifndef HLS_MAP_IN2
#define HLS_MAP_IN2
#endif
#ifndef HLS_MAP_IN3
#define HLS_MAP_IN3
#endif
#ifndef HLS_MAP_OUT
#define HLS_MAP_OUT
#endif

#endif /* STRATUS_HLS */

//
// Macros
//

// User defined constants
#ifndef WORD_SIZE
#define WORD_SIZE 32
#endif

#define WORDS_PER_DMA (DMA_WIDTH / WORD_SIZE)
#define WORDS_PER_DMA_LOG (slog_2<WORDS_PER_DMA>::value)

// log of chunk size
#define DMA_CHUNK_LOG (slog_2<DMA_CHUNK>::value)

// floating/fixed point conversions
#define INT2FP(x) int2fp<FPDATA, WORD_SIZE>(x)
#define FP2INT(x) fp2int<FPDATA, WORD_SIZE>(x)

// arithmetic operators
#ifdef FIXED_POINT
#define ACCUMULATE(add, mul1, mul2)					\
    add = add + (mul1 * mul2)

#define MULTIPLY(mul_out, mul1, mul2)		\
    mul_out = (mul1 * mul2)

#define ADD(add_out, add1, add2)		\
    add_out = (add1 + add2)


// use this to substitute fixed-point from Stratus
// add = (PLM_WORD) fixed32_add((int32_t) add, fixed32_mul((int32_t) mul1, (int32_t) mul2, FPDATA_FL))

#else // FLOAT_POINT

#ifdef TECH_IS_FPGA

#define ACCUMULATE(add, mul1, mul2)			\
    add = esp_f32_add(add, esp_f32_mul(mul1, mul2))

#define MULTIPLY(mul_out, mul1, mul2)		\
    mul_out = esp_f32_mul(mul1, mul2)

#define ADD(add_out, add1, add2)		\
    add_out = esp_f32_add(add1, add2)

#else // ASIC
#define ACCUMULATE(add, mul1, mul2)		\
    add = add + (mul1 * mul2)

#define MULTIPLY(mul_out, mul1, mul2)		\
    mul_out = (mul1 * mul2)

#define ADD(add_out, add1, add2)		\
    add_out = (add1 + add2)

#endif
#endif

#endif /* __GEMM_DIRECTIVES_HPP_ */
