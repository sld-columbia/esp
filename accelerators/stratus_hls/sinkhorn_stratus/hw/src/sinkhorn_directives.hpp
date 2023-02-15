// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __SINKHORN_DIRECTIVES_HPP__
#define __SINKHORN_DIRECTIVES_HPP__


#if (DMA_WIDTH == 64)
#define DMA_BEAT_PER_WORD 1
#define DMA_WORD_PER_BEAT 2
#define LOG_DMA_WORD_PER_BEAT 1
#define PLM_IN_X_NAME "sinkhorn_inputx_plm_dma64"
#define PLM_IN_Y_NAME "sinkhorn_inputy_plm_dma64"
#define PLM_OUT_NAME "sinkhorn_output_plm_dma64"
#define PLM_OUT2_NAME "sinkhorn_output2_plm_dma64"
#elif (DMA_WIDTH == 32)
#define DMA_BEAT_PER_WORD 1
#define DMA_WORD_PER_BEAT 1
#define LOG_DMA_WORD_PER_BEAT 0
#define PLM_IN_Y_NAME "sinkhorn_input_plm_dma32"
#define PLM_IN_X_NAME "sinkhorn_input_plm_dma32"
#define PLM_OUT_NAME "sinkhorn_output_plm_dma32"
#define PLM_OUT2_NAME "sinkhorn_output_plm_dma32"
#endif


#if defined(STRATUS_HLS)

#define HLS_MAP_inputx_plm(_mem)                     \
    HLS_MAP_TO_MEMORY(_mem, PLM_IN_X_NAME)

#define HLS_MAP_inputy_plm(_mem)                     \
    HLS_MAP_TO_MEMORY(_mem, PLM_IN_Y_NAME)

#define HLS_MAP_output_plm(_mem)                     \
    HLS_MAP_TO_MEMORY(_mem, PLM_OUT_NAME)

#define HLS_MAP_output2_plm(_mem)                     \
    HLS_MAP_TO_MEMORY(_mem, PLM_OUT2_NAME)

#define HLS_MAP_intermed_plm(_mem)                     \
    HLS_MAP_TO_MEMORY(_mem, "sinkhorn_intermed_plm")

#define HLS_MAP_intermed2_plm(_mem)                     \
    HLS_MAP_TO_MEMORY(_mem, "sinkhorn_intermed2_plm")

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

#define HLS_MAP_inputx_plm(_mem)
#define HLS_MAP_inputy_plm(_mem)
#define HLS_MAP_output_plm(_mem)
#define HLS_MAP_output2_plm(_mem)
#define HLS_MAP_intermed_plm(_mem)
#define HLS_MAP_intermed2_plm(_mem)
#define HLS_PROTO(_s)
#define HLS_FLAT(_a)
#define HLS_BREAK_DEP(_a)
#define HLS_UNROLL_SIMPLE

#endif /* STRATUS_HLS */

#endif /* __SINKHORN_DIRECTIVES_HPP_ */
