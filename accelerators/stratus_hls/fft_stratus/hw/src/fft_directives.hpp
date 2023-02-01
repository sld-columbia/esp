// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __FFT_DIRECTIVES_HPP__
#define __FFT_DIRECTIVES_HPP__

#if (DMA_WIDTH == 32)
#if (FX_WIDTH == 64)
#define DMA_BEAT_PER_WORD 2
#define DMA_WORD_PER_BEAT 0
#define PLM_IN_NAME "fft_plm_block_in_fx64"
#define PLM_OUT_NAME "fft_plm_block_out_fx64"
#elif (FX_WIDTH == 32)
#define DMA_BEAT_PER_WORD 1
#define DMA_WORD_PER_BEAT 1
#define PLM_IN_NAME "fft_plm_block_in_fx32"
#define PLM_OUT_NAME "fft_plm_block_out_fx32"
#endif // FX_WIDTH
#elif (DMA_WIDTH == 64)
#if (FX_WIDTH == 64)
#define DMA_BEAT_PER_WORD 1
#define DMA_WORD_PER_BEAT 1
#define PLM_IN_NAME "fft_plm_block_in_fx64"
#define PLM_OUT_NAME "fft_plm_block_out_fx64"
#elif (FX_WIDTH == 32)
#define DMA_BEAT_PER_WORD 1
#define DMA_WORD_PER_BEAT 2
#define PLM_IN_NAME "fft_plm_block_in_fx32"
#define PLM_OUT_NAME "fft_plm_block_out_fx32"
#endif // FX_WIDTH
#endif // DMA_WIDTH

#if defined(STRATUS_HLS)

#define HLS_MAP_plm(_mem, _plm_block_name)      \
    HLS_MAP_TO_MEMORY(_mem, _plm_block_name)

#define HLS_PROTO(_s)                           \
    HLS_DEFINE_PROTOCOL(_s)

#define HLS_FLAT(_a)                            \
    HLS_FLATTEN_ARRAY(_a);

#define HLS_BREAK_DEP(_a)                       \
    HLS_BREAK_ARRAY_DEPENDENCY(_a)

#define HLS_UNROLL_SIMPLE                       \
    HLS_UNROLL_LOOP(ON)

#define HLS_UNROLL_N(_n, _name)                 \
    HLS_UNROLL_LOOP(AGGRESSIVE, _n, _name)

#if defined(HLS_DIRECTIVES_BASIC)

#else

#error Unsupported or undefined HLS configuration

#endif /* HLS_DIRECTIVES_* */

#else /* !STRATUS_HLS */

#define HLS_MAP_plm(_mem, _plm_block_name)
#define HLS_PROTO(_s)
#define HLS_FLAT(_a)
#define HLS_BREAK_DEP(_a)
#define HLS_UNROLL_SIMPLE
#define HLS_UNROLL_N(_n, _name)

#endif /* STRATUS_HLS */

#endif /* __FFT_DIRECTIVES_HPP_ */
