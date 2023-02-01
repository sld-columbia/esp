// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __DUMMY_DIRECTIVES_HPP__
#define __DUMMY_DIRECTIVES_HPP__


#if (DMA_WIDTH == 64)
#define DMA_BEAT_PER_WORD 1
#define DMA_SIZE SIZE_DWORD
#elif (DMA_WIDTH == 32)
#define DMA_BEAT_PER_WORD 2
#define DMA_SIZE SIZE_WORD
#endif


#if defined(STRATUS_HLS)

#define HLS_MAP_plm(_mem)                       \
    HLS_MAP_TO_MEMORY(_mem, "dummy_plm")

#define HLS_PROTO(_s)                           \
    HLS_DEFINE_PROTOCOL(_s)

#define HLS_FLAT(_a)                            \
    HLS_FLATTEN_ARRAY(_a);

#define HLS_BREAK_DEP(_a)                       \
    HLS_BREAK_ARRAY_DEPENDENCY(_a)

#define HLS_UNROLL_SIMPLE                       \
    HLS_UNROLL_LOOP(ON)

#if defined(HLS_DIRECTIVES_BASIC)

#else

#error Unsupported or undefined HLS configuration

#endif /* HLS_DIRECTIVES_* */

#else /* !STRATUS_HLS */

#define HLS_MAP_plm(_mem)
#define HLS_PROTO(_s)
#define HLS_FLAT(_a)
#define HLS_BREAK_DEP(_a)
#define HLS_UNROLL_SIMPLE

#endif /* STRATUS_HLS */

#endif /* __DUMMY_DIRECTIVES_HPP_ */
