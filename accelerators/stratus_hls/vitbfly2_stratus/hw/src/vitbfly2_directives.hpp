// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __VITBFLY2_DIRECTIVES_HPP__
#define __VITBFLY2_DIRECTIVES_HPP__

#define WORDS_PER_DMA (DMA_WIDTH >> 3)

#if defined(STRATUS_HLS)

// #define HLS_MAP_symbols                     \
//     HLS_FLATTEN_ARRAY(symbols)

// #define HLS_MAP_mm0                         \
//     HLS_FLATTEN_ARRAY(mm0)

// #define HLS_MAP_mm1                         \
//     HLS_FLATTEN_ARRAY(mm1)

// #define HLS_MAP_pp0                         \
//     HLS_FLATTEN_ARRAY(pp0)

// #define HLS_MAP_pp1                         \
//     HLS_FLATTEN_ARRAY(pp1)

// #define HLS_MAP_d_brtab27                   \
//     HLS_FLATTEN_ARRAY(d_brtab27)


#if (WORDS_PER_DMA == 4)

#define HLS_MAP_symbols                                 \
    HLS_MAP_TO_MEMORY(symbols, "vitbfly2_plm_block_4p")

#define HLS_MAP_mm0                                     \
    HLS_MAP_TO_MEMORY(mm0, "vitbfly2_plm_block_4p")

#define HLS_MAP_mm1                                     \
    HLS_MAP_TO_MEMORY(mm1, "vitbfly2_plm_block_4p")

#define HLS_MAP_pp0                                     \
    HLS_MAP_TO_MEMORY(pp0, "vitbfly2_plm_block_4p")

#define HLS_MAP_pp1                                     \
    HLS_MAP_TO_MEMORY(pp1, "vitbfly2_plm_block_4p")

#define HLS_MAP_d_brtab27                               \
    HLS_MAP_TO_MEMORY(d_brtab27, "vitbfly2_plm_block_4p")

#elif (WORDS_PER_DMA == 8)

#define HLS_MAP_symbols                                 \
    HLS_MAP_TO_MEMORY(symbols, "vitbfly2_plm_block_8p")

#define HLS_MAP_mm0                                     \
    HLS_MAP_TO_MEMORY(mm0, "vitbfly2_plm_block_8p")

#define HLS_MAP_mm1                                     \
    HLS_MAP_TO_MEMORY(mm1, "vitbfly2_plm_block_8p")

#define HLS_MAP_pp0                                     \
    HLS_MAP_TO_MEMORY(pp0, "vitbfly2_plm_block_8p")

#define HLS_MAP_pp1                                     \
    HLS_MAP_TO_MEMORY(pp1, "vitbfly2_plm_block_8p")

#define HLS_MAP_d_brtab27                               \
    HLS_MAP_TO_MEMORY(d_brtab27, "vitbfly2_plm_block_8p")

#else

#error DMA_WIDTH not supported

#endif // WORDS_PER_DMA


#if defined(HLS_DIRECTIVES_BASIC)

#define HLS_UNROLL_LOOP_SIMPLE                  \
	HLS_UNROLL_LOOP(ON)

#else

#error Unsupported or undefined HLS configuration

#endif /* HLS_DIRECTIVES_* */

#else /* !STRATUS_HLS */

#define HLS_MAP_symbols
#define HLS_MAP_mm0
#define HLS_MAP_mm1
#define HLS_MAP_pp0
#define HLS_MAP_pp1
#define HLS_MAP_d_brtab27
#define HLS_UNROLL_LOOP_SIMPLE

#endif /* STRATUS_HLS */

#endif /* __VITBFLY2_DIRECTIVES_HPP_ */
