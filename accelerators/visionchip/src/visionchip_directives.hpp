// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: MIT

#ifndef __VISIONCHIP_DIRECTIVES_HPP__
#define __VISIONCHIP_DIRECTIVES_HPP__

#if defined(STRATUS_HLS)

#if defined(HLS_DIRECTIVES_BASIC)

#define HLS_LOAD_INPUT_BATCH_LOOP		\
    HLS_UNROLL_LOOP(OFF)
#define HLS_LOAD_INPUT_LOOP			\
    HLS_UNROLL_LOOP(OFF)
#define HLS_LOAD_INPUT_PLM_WRITE                                \
    HLS_CONSTRAIN_LATENCY(0, 1, "constraint-load-mem-access")

#define HLS_STORE_OUTPUT_BATCH_LOOP		\
    HLS_UNROLL_LOOP(OFF)
#define HLS_STORE_OUTPUT_LOOP			\
    HLS_UNROLL_LOOP(OFF)
#define HLS_STORE_OUTPUT_PLM_READ                               \
    HLS_CONSTRAIN_LATENCY(0, 1, "constraint-store-mem-access")

#define HLS_UNROLL_LOOP_SIMPLE                  \
    HLS_UNROLL_LOOP(ON)

#else

#error Unsupported or undefined HLS configuration

#endif /* HLS_DIRECTIVES_* */

#else /* !STRATUS_HLS */

#define HLS_LOAD_INPUT_BATCH_LOOP
#define HLS_LOAD_INPUT_LOOP
#define HLS_LOAD_INPUT_PLM_WRITE

#define HLS_STORE_OUTPUT_BATCH_LOOP
#define HLS_STORE_OUTPUT_LOOP
#define HLS_STORE_OUTPUT_PLM_READ

#define HLS_UNROLL_LOOP_SIMPLE

#endif /* STRATUS_HLS */

#endif /* __VISIONCHIP_DIRECTIVES_HPP_ */
