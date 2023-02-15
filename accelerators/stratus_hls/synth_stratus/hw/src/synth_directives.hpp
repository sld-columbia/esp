// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __SYNTH_DIRECTIVES_HPP__
#define __SYNTH_DIRECTIVES_HPP__

#if defined(STRATUS_HLS)

#if defined(HLS_DIRECTIVES_BASIC)

#define HLS_LOAD_INPUT_REUSE_LOOP		\
    HLS_UNROLL_LOOP(OFF)
#define HLS_LOAD_INPUT_BATCH_LOOP		\
    HLS_UNROLL_LOOP(OFF)
#define HLS_LOAD_INPUT_LOOP			\
    HLS_UNROLL_LOOP(OFF)
#define HLS_LOAD_DMA				\
    HLS_DEFINE_PROTOCOL("load-dma-protocol")

#define HLS_STORE_OUTPUT_BATCH_LOOP		\
    HLS_UNROLL_LOOP(OFF)
#define HLS_STORE_OUTPUT_LOOP			\
    HLS_UNROLL_LOOP(OFF)
#define HLS_STORE_DMA				\
    HLS_DEFINE_PROTOCOL("store-dma-protocol")

#define HLS_UNROLL_LOOP_SIMPLE                  \
    HLS_UNROLL_LOOP(ON)

#else

#error Unsupported or undefined HLS configuration

#endif /* HLS_DIRECTIVES_* */

#else /* !STRATUS_HLS */

#define HLS_LOAD_INPUT_REUSE_LOOP
#define HLS_LOAD_INPUT_BATCH_LOOP
#define HLS_LOAD_INPUT_LOOP
#define HLS_LOAD_DMA

#define HLS_STORE_OUTPUT_BATCH_LOOP
#define HLS_STORE_OUTPUT_LOOP
#define HLS_STORE_DMA

#define HLS_UNROLL_LOOP_SIMPLE

#endif /* STRATUS_HLS */

#endif /* __SYNTH_DIRECTIVES_HPP_ */
