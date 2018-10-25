/* Copyright 2017 Columbia University, SLD Group */

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
#define HLS_COMPUTE_BOUND_LOOP			\
    HLS_UNROLL_LOOP(OFF);			\
    HLS_DEFINE_PROTOCOL("proto-compute-bound-loop")

#define HLS_STORE_OUTPUT_BATCH_LOOP		\
    HLS_UNROLL_LOOP(OFF)
#define HLS_STORE_OUTPUT_LOOP			\
    HLS_UNROLL_LOOP(OFF)
#define HLS_STORE_OUTPUT_PLM_READ				\
    HLS_CONSTRAIN_LATENCY(0, 1, "constraint-store-mem-access")

#define HLS_UNROLL_LOOP_SIMPLE                  \
    HLS_UNROLL_LOOP(ON)

#else

#error Unsupported or undefined HLS configuration

#endif /* HLS_DIRECTIVES_* */

#else /* !STRATUS_HLS */

#define HLS_LOAD_INPUT_REUSE_LOOP
#define HLS_LOAD_INPUT_BATCH_LOOP
#define HLS_LOAD_INPUT_LOOP
#define HLS_COMPUTE_BOUND_LOOP

#define HLS_STORE_OUTPUT_BATCH_LOOP
#define HLS_STORE_OUTPUT_LOOP
#define HLS_STORE_OUTPUT_PLM_READ

#define HLS_UNROLL_LOOP_SIMPLE

#endif /* STRATUS_HLS */

#endif /* __SYNTH_DIRECTIVES_HPP_ */
