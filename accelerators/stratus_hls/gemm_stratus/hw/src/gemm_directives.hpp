// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __GEMM_DIRECTIVES_HPP__
#define __GEMM_DIRECTIVES_HPP__

// Macros
#if defined(STRATUS_HLS)

#if defined(HLS_DIRECTIVES_BASIC)

#define HLS_MAP_plm(_mem, _plm_block_name)      \
    HLS_MAP_TO_MEMORY(_mem, _plm_block_name)

#if (DMA_WIDTH == 64)
#if (WORD_SIZE == 32)

#if (DMA_CHUNK == 8)
#define OUT_DMA_CHUNK 8
#define OUT_PLM_NAME "plm_w32_d64_chk8"
#if (PARALLELISM == 1)
#define IN_PLM_NAME "plm_w32_d64_chk8_p1"
#elif (PARALLELISM == 4)
#define IN_PLM_NAME "plm_w32_d64_chk8_p4"
#elif (PARALLELISM == 8)
#define IN_PLM_NAME "plm_w32_d64_chk8_p8"
#else // (PARALLELISM == 16)
#define IN_PLM_NAME "plm_w32_d64_chk8_p16"
#endif

#elif (DMA_CHUNK == 16)
#define OUT_DMA_CHUNK 16
#define OUT_PLM_NAME "plm_w32_d64_chk16"
#if (PARALLELISM == 1)
#define IN_PLM_NAME "plm_w32_d64_chk16_p1"
#elif (PARALLELISM == 4)
#define IN_PLM_NAME "plm_w32_d64_chk16_p4"
#elif (PARALLELISM == 8)
#define IN_PLM_NAME "plm_w32_d64_chk16_p8"
#else // (PARALLELISM == 16)
#define IN_PLM_NAME "plm_w32_d64_chk16_p16"
#endif

#elif (DMA_CHUNK == 32)
#define OUT_DMA_CHUNK 32
#define OUT_PLM_NAME "plm_w32_d64_chk32"
#if (PARALLELISM == 1)
#define IN_PLM_NAME "plm_w32_d64_chk32_p1"
#elif (PARALLELISM == 4)
#define IN_PLM_NAME "plm_w32_d64_chk32_p4"
#elif (PARALLELISM == 8)
#define IN_PLM_NAME "plm_w32_d64_chk32_p8"
#else // (PARALLELISM == 16)
#define IN_PLM_NAME "plm_w32_d64_chk32_p16"
#endif

#elif (DMA_CHUNK == 64)
#define OUT_DMA_CHUNK 64
#define OUT_PLM_NAME "plm_w32_d64_chk64"
#if (PARALLELISM == 1)
#define IN_PLM_NAME "plm_w32_d64_chk64_p1"
#elif (PARALLELISM == 4)
#define IN_PLM_NAME "plm_w32_d64_chk64_p4"
#elif (PARALLELISM == 8)
#define IN_PLM_NAME "plm_w32_d64_chk64_p8"
#else // (PARALLELISM == 16)
#define IN_PLM_NAME "plm_w32_d64_chk64_p16"
#endif

#elif (DMA_CHUNK == 128)
#define OUT_DMA_CHUNK 128
#define OUT_PLM_NAME "plm_w32_d64_chk128"
#if (PARALLELISM == 1)
#define IN_PLM_NAME "plm_w32_d64_chk128_p1"
#elif (PARALLELISM == 4)
#define IN_PLM_NAME "plm_w32_d64_chk128_p4"
#elif (PARALLELISM == 8)
#define IN_PLM_NAME "plm_w32_d64_chk128_p8"
#else // (PARALLELISM == 16)
#define IN_PLM_NAME "plm_w32_d64_chk128_p16"
#endif

#elif (DMA_CHUNK == 512)
#define OUT_DMA_CHUNK 512
#define OUT_PLM_NAME "plm_w32_d64_chk512"
#if (PARALLELISM == 1)
#define IN_PLM_NAME "plm_w32_d64_chk512_p1"
#elif (PARALLELISM == 4)
#define IN_PLM_NAME "plm_w32_d64_chk512_p4"
#elif (PARALLELISM == 8)
#define IN_PLM_NAME "plm_w32_d64_chk512_p8"
#else // (PARALLELISM == 16)
#define IN_PLM_NAME "plm_w32_d64_chk512_p16"
#endif

#elif (DMA_CHUNK == 2048)
#define OUT_DMA_CHUNK 256
#define OUT_PLM_NAME "plm_w32_d64_chk256"
#if (PARALLELISM == 1)
#define IN_PLM_NAME "plm_w32_d64_chk2048_p1"
#elif (PARALLELISM == 4)
#define IN_PLM_NAME "plm_w32_d64_chk2048_p4"
#elif (PARALLELISM == 8)
#define IN_PLM_NAME "plm_w32_d64_chk2048_p8"
#else // (PARALLELISM == 16)
#define IN_PLM_NAME "plm_w32_d64_chk2048_p16"
#endif

#elif (DMA_CHUNK == 4096)
#define OUT_DMA_CHUNK 256
#define OUT_PLM_NAME "plm_w32_d64_chk256"
#if (PARALLELISM == 1)
#define IN_PLM_NAME "plm_w32_d64_chk4096_p1"
#elif (PARALLELISM == 4)
#define IN_PLM_NAME "plm_w32_d64_chk4096_p4"
#elif (PARALLELISM == 8)
#define IN_PLM_NAME "plm_w32_d64_chk4096_p8"
#else // (PARALLELISM == 16)
#define IN_PLM_NAME "plm_w32_d64_chk4096_p16"
#endif

#else // (DMA_CHUNK == 8192)
#define OUT_DMA_CHUNK 512
#define OUT_PLM_NAME "plm_w32_d64_chk512"
#if (PARALLELISM == 1)
#define IN_PLM_NAME "plm_w32_d64_chk8192_p1"
#elif (PARALLELISM == 2)
#define IN_PLM_NAME "plm_w32_d64_chk8192_p2"
#elif (PARALLELISM == 4)
#define IN_PLM_NAME "plm_w32_d64_chk8192_p4"
#elif (PARALLELISM == 8)
#define IN_PLM_NAME "plm_w32_d64_chk8192_p8"
#else // (PARALLELISM == 16)
#define IN_PLM_NAME "plm_w32_d64_chk8192_p16"
#endif

#endif

#endif
#endif

#if (DMA_WIDTH == 32)
#if (WORD_SIZE == 32)

#if (DMA_CHUNK == 8)
#define OUT_DMA_CHUNK 8
#define OUT_PLM_NAME "plm_w32_d32_chk8"
#if (PARALLELISM == 1)
#define IN_PLM_NAME "plm_w32_d32_chk8_p1"
#elif (PARALLELISM == 4)
#define IN_PLM_NAME "plm_w32_d32_chk8_p4"
#elif (PARALLELISM == 8)
#define IN_PLM_NAME "plm_w32_d32_chk8_p8"
#else // (PARALLELISM == 16)
#define IN_PLM_NAME "plm_w32_d32_chk8_p16"
#endif

#elif (DMA_CHUNK == 16)
#define OUT_DMA_CHUNK 16
#define OUT_PLM_NAME "plm_w32_d32_chk16"
#if (PARALLELISM == 1)
#define IN_PLM_NAME "plm_w32_d32_chk16_p1"
#elif (PARALLELISM == 4)
#define IN_PLM_NAME "plm_w32_d32_chk16_p4"
#elif (PARALLELISM == 8)
#define IN_PLM_NAME "plm_w32_d32_chk16_p8"
#else // (PARALLELISM == 16)
#define IN_PLM_NAME "plm_w32_d32_chk16_p16"
#endif

#elif (DMA_CHUNK == 32)
#define OUT_DMA_CHUNK 32
#define OUT_PLM_NAME "plm_w32_d32_chk32"
#if (PARALLELISM == 1)
#define IN_PLM_NAME "plm_w32_d32_chk32_p1"
#elif (PARALLELISM == 4)
#define IN_PLM_NAME "plm_w32_d32_chk32_p4"
#elif (PARALLELISM == 8)
#define IN_PLM_NAME "plm_w32_d32_chk32_p8"
#else // (PARALLELISM == 16)
#define IN_PLM_NAME "plm_w32_d32_chk32_p16"
#endif

#elif (DMA_CHUNK == 64)
#define OUT_DMA_CHUNK 64
#define OUT_PLM_NAME "plm_w32_d32_chk64"
#if (PARALLELISM == 1)
#define IN_PLM_NAME "plm_w32_d32_chk64_p1"
#elif (PARALLELISM == 4)
#define IN_PLM_NAME "plm_w32_d32_chk64_p4"
#elif (PARALLELISM == 8)
#define IN_PLM_NAME "plm_w32_d32_chk64_p8"
#else // (PARALLELISM == 16)
#define IN_PLM_NAME "plm_w32_d32_chk64_p16"
#endif

#elif (DMA_CHUNK == 128)
#define OUT_DMA_CHUNK 128
#define OUT_PLM_NAME "plm_w32_d32_chk128"
#if (PARALLELISM == 1)
#define IN_PLM_NAME "plm_w32_d32_chk128_p1"
#elif (PARALLELISM == 4)
#define IN_PLM_NAME "plm_w32_d32_chk128_p4"
#elif (PARALLELISM == 8)
#define IN_PLM_NAME "plm_w32_d32_chk128_p8"
#else // (PARALLELISM == 16)
#define IN_PLM_NAME "plm_w32_d32_chk128_p16"
#endif

#elif (DMA_CHUNK == 512)
#define OUT_DMA_CHUNK 512
#define OUT_PLM_NAME "plm_w32_d32_chk512"
#if (PARALLELISM == 1)
#define IN_PLM_NAME "plm_w32_d32_chk512_p1"
#elif (PARALLELISM == 4)
#define IN_PLM_NAME "plm_w32_d32_chk512_p4"
#elif (PARALLELISM == 8)
#define IN_PLM_NAME "plm_w32_d32_chk512_p8"
#else // (PARALLELISM == 16)
#define IN_PLM_NAME "plm_w32_d32_chk512_p16"
#endif

#elif (DMA_CHUNK == 2048)
#define OUT_DMA_CHUNK 256
#define OUT_PLM_NAME "plm_w32_d32_chk256"
#if (PARALLELISM == 1)
#define IN_PLM_NAME "plm_w32_d32_chk2048_p1"
#elif (PARALLELISM == 4)
#define IN_PLM_NAME "plm_w32_d32_chk2048_p4"
#elif (PARALLELISM == 8)
#define IN_PLM_NAME "plm_w32_d32_chk2048_p8"
#else // (PARALLELISM == 16)
#define IN_PLM_NAME "plm_w32_d32_chk2048_p16"
#endif

#elif (DMA_CHUNK == 4096)
#define OUT_DMA_CHUNK 256
#define OUT_PLM_NAME "plm_w32_d32_chk256"
#if (PARALLELISM == 1)
#define IN_PLM_NAME "plm_w32_d32_chk4096_p1"
#elif (PARALLELISM == 4)
#define IN_PLM_NAME "plm_w32_d32_chk4096_p4"
#elif (PARALLELISM == 8)
#define IN_PLM_NAME "plm_w32_d32_chk4096_p8"
#else // (PARALLELISM == 16)
#define IN_PLM_NAME "plm_w32_d32_chk4096_p16"
#endif

#else // (DMA_CHUNK == 8192)
#define OUT_DMA_CHUNK 512
#define OUT_PLM_NAME "plm_w32_d32_chk512"
#if (PARALLELISM == 1)
#define IN_PLM_NAME "plm_w32_d32_chk8192_p1"
#elif (PARALLELISM == 2)
#define IN_PLM_NAME "plm_w32_d32_chk8192_p2"
#elif (PARALLELISM == 4)
#define IN_PLM_NAME "plm_w32_d32_chk8192_p4"
#elif (PARALLELISM == 8)
#define IN_PLM_NAME "plm_w32_d32_chk8192_p8"
#else // (PARALLELISM == 16)
#define IN_PLM_NAME "plm_w32_d32_chk8192_p16"
#endif

#endif

#endif
#endif


#endif // HLS_DIRECTIVES_BASIC

#else /* !STRATUS_HLS */

#define HLS_MAP_plm(_mem, _plm_block_name)
#define OUT_DMA_CHUNK DMA_CHUNK

#endif /* STRATUS_HLS */

//
// Macros
//

// Load configuration
#define LESS_THAN_ROW 0
#define LESS_THAN_MATRIX2 1
#define MORE_THAN_MATRIX2 2

// log of chunk size
#define DMA_CHUNK_LOG (slog_2<DMA_CHUNK>::value)
#define OUT_DMA_CHUNK_LOG (slog_2<OUT_DMA_CHUNK>::value)

// floating/fixed point conversions
#define INT2FP(x) int2fp<FPDATA, WORD_SIZE>(x)
#define FP2INT(x) fp2int<FPDATA, WORD_SIZE>(x)

// arithmetic operators
#ifdef FIXED_POINT
#define MAC(add, mul1, mul2)					\
    add = add + (mul1 * mul2)

#define MULTIPLY(mul_out, mul1, mul2)		\
    mul_out = (mul1 * mul2)

#define ACCUMULATE(add1, add2)		\
    add1 = (add1 + add2)

#else // FLOAT_POINT

#define MAC(add, mul1, mul2)		\
    add = add + (mul1 * mul2)

#define MULTIPLY(mul_out, mul1, mul2)		\
    mul_out = (mul1 * mul2)

#define ACCUMULATE(add1, add2)		\
    add1 = (add1 + add2)

#endif

#endif /* __GEMM_DIRECTIVES_HPP_ */
