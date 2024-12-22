// Copyright (c) 2011-2024 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __SPMV_DIRECTIVES_HPP__
#define __SPMV_DIRECTIVES_HPP__

#if defined(STRATUS)

    // Memory allocation

    #define HLS_MAP_ROWS0 HLS_MAP_TO_MEMORY(ROWS0, "plm_256_1w1r")
    #define HLS_MAP_ROWS1 HLS_MAP_TO_MEMORY(ROWS1, "plm_256_1w1r")
    #define HLS_MAP_COLS0 HLS_MAP_TO_MEMORY(COLS0, "plm_1024_1w1r")
    #define HLS_MAP_COLS1 HLS_MAP_TO_MEMORY(COLS1, "plm_1024_1w1r")
    #define HLS_MAP_VALS0 HLS_MAP_TO_MEMORY(VALS0, "plm_1024_1w1r")
    #define HLS_MAP_VALS1 HLS_MAP_TO_MEMORY(VALS1, "plm_1024_1w1r")
    #define HLS_MAP_VECT0 HLS_MAP_TO_MEMORY(VECT0, "plm_8192_1w1r")
    #define HLS_MAP_VECT1 HLS_MAP_TO_MEMORY(VECT1, "plm_8192_1w1r")
    #define HLS_MAP_OUT0  HLS_MAP_TO_MEMORY(OUT0, "plm_256_1w1r")
    #define HLS_MAP_OUT1  HLS_MAP_TO_MEMORY(OUT1, "plm_256_1w1r")

    // Load

    #define HLS_LOAD_RESET            HLS_DEFINE_PROTOCOL("load-reset")
    #define HLS_LOAD_CONFIG           HLS_DEFINE_PROTOCOL("load-config")
    #define HLS_LOAD_DMA              HLS_DEFINE_PROTOCOL("load-dma-conf")
    #define HLS_LOAD_INPUT_BATCH_LOOP HLS_UNROLL_LOOP(OFF)
    #define HLS_LOAD_INPUT_LOOP       HLS_UNROLL_LOOP(OFF)
    #define HLS_LOAD_ROWS_PLM_WRITE                                              \
        HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "constraint-load-rows-access"); \
        HLS_BREAK_ARRAY_DEPENDENCY(ROWS0);                                       \
        HLS_BREAK_ARRAY_DEPENDENCY(ROWS1)
    #define HLS_LOAD_COLS_PLM_WRITE                                              \
        HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "constraint-load-cols-access"); \
        HLS_BREAK_ARRAY_DEPENDENCY(COLS0);                                       \
        HLS_BREAK_ARRAY_DEPENDENCY(COLS1)
    #define HLS_LOAD_VALS_PLM_WRITE                                              \
        HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "constraint-load-vals-access"); \
        HLS_BREAK_ARRAY_DEPENDENCY(VALS0);                                       \
        HLS_BREAK_ARRAY_DEPENDENCY(VALS1)
    #define HLS_LOAD_VECT_PLM_READ                                                \
        HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "constraint-load-vect-raccess"); \
        HLS_BREAK_ARRAY_DEPENDENCY(ROWS0);                                        \
        HLS_BREAK_ARRAY_DEPENDENCY(ROWS1)
    #define HLS_LOAD_VECT_PLM_WRITE                                               \
        HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "constraint-load-vect-waccess"); \
        HLS_BREAK_ARRAY_DEPENDENCY(VECT0);                                        \
        HLS_BREAK_ARRAY_DEPENDENCY(VECT1)

    // Store

    #define HLS_STORE_RESET             HLS_DEFINE_PROTOCOL("store-reset")
    #define HLS_STORE_CONFIG            HLS_DEFINE_PROTOCOL("store-config")
    #define HLS_STORE_DMA               HLS_DEFINE_PROTOCOL("store-dma-conf")
    #define HLS_STORE_OUTPUT_BATCH_LOOP HLS_UNROLL_LOOP(OFF)
    #define HLS_STORE_OUTPUT_LOOP       HLS_UNROLL_LOOP(OFF)
    #define HLS_STORE_OUTPUT_PLM_READ                                            \
        HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "constraint-store-mem-access"); \
        HLS_BREAK_ARRAY_DEPENDENCY(OUT0);                                        \
        HLS_BREAK_ARRAY_DEPENDENCY(OUT1)

    // Compute

    #define HLS_COMPUTE_RESET  HLS_DEFINE_PROTOCOL("compute-reset")
    #define HLS_COMPUTE_CONFIG HLS_DEFINE_PROTOCOL("compute-config")

    // Datapath micro-architecture

    #if defined(HLS_DIRECTIVES_BASIC)

        #define HLS_COMPUTE_SPMV_LOOP HLS_UNROLL_LOOP(OFF)
        #define HLS_COMPUTE_MAIN               \
            HLS_UNROLL_LOOP(OFF);              \
            HLS_BREAK_ARRAY_DEPENDENCY(ROWS0); \
            HLS_BREAK_ARRAY_DEPENDENCY(ROWS1); \
            HLS_BREAK_ARRAY_DEPENDENCY(OUT0);  \
            HLS_BREAK_ARRAY_DEPENDENCY(OUT1)
        #define HLS_COMPUTE_RW_CHUNK                                                   \
            HLS_UNROLL_LOOP(OFF);                                                      \
            HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "constraint-COMPUTE-mem-access"); \
            HLS_BREAK_ARRAY_DEPENDENCY(VALS0);                                         \
            HLS_BREAK_ARRAY_DEPENDENCY(VALS1);                                         \
            HLS_BREAK_ARRAY_DEPENDENCY(VECT0);                                         \
            HLS_BREAK_ARRAY_DEPENDENCY(VECT1)

    #endif /* HLS_DIRECTIVES_BASIC */

#endif /* STRATUS */

#ifndef HLS_MAP_ROWS0
    #define HLS_MAP_ROWS0
#endif
#ifndef HLS_MAP_ROWS1
    #define HLS_MAP_ROWS1
#endif
#ifndef HLS_MAP_COLS0
    #define HLS_MAP_COLS0
#endif
#ifndef HLS_MAP_COLS1
    #define HLS_MAP_COLS1
#endif
#ifndef HLS_MAP_VALS0
    #define HLS_MAP_VALS0
#endif
#ifndef HLS_MAP_VALS1
    #define HLS_MAP_VALS1
#endif
#ifndef HLS_MAP_VECT0
    #define HLS_MAP_VECT0
#endif
#ifndef HLS_MAP_VECT1
    #define HLS_MAP_VECT1
#endif
#ifndef HLS_MAP_OUT0
    #define HLS_MAP_OUT0
#endif
#ifndef HLS_MAP_OUT1
    #define HLS_MAP_OUT1
#endif

#ifndef HLS_LOAD_RESET
    #define HLS_LOAD_RESET
#endif
#ifndef HLS_LOAD_CONFIG
    #define HLS_LOAD_CONFIG
#endif
#ifndef HLS_LOAD_DMA
    #define HLS_LOAD_DMA
#endif
#ifndef HLS_LOAD_INPUT_BATCH_LOOP
    #define HLS_LOAD_INPUT_BATCH_LOOP
#endif
#ifndef HLS_LOAD_INPUT_LOOP
    #define HLS_LOAD_INPUT_LOOP
#endif
#ifndef HLS_LOAD_ROWS_PLM_WRITE
    #define HLS_LOAD_ROWS_PLM_WRITE
#endif
#ifndef HLS_LOAD_COLS_PLM_WRITE
    #define HLS_LOAD_COLS_PLM_WRITE
#endif
#ifndef HLS_LOAD_VALS_PLM_WRITE
    #define HLS_LOAD_VALS_PLM_WRITE
#endif
#ifndef HLS_LOAD_VECT_PLM_READ
    #define HLS_LOAD_VECT_PLM_READ
#endif
#ifndef HLS_LOAD_VECT_PLM_WRITE
    #define HLS_LOAD_VECT_PLM_WRITE
#endif

#ifndef HLS_STORE_RESET
    #define HLS_STORE_RESET
#endif
#ifndef HLS_STORE_CONFIG
    #define HLS_STORE_CONFIG
#endif
#ifndef HLS_STORE_DMA
    #define HLS_STORE_DMA
#endif
#ifndef HLS_STORE_OUTPUT_BATCH_LOOP
    #define HLS_STORE_OUTPUT_BATCH_LOOP
#endif
#ifndef HLS_STORE_OUTPUT_LOOP
    #define HLS_STORE_OUTPUT_LOOP
#endif
#ifndef HLS_STORE_OUTPUT_PLM_READ
    #define HLS_STORE_OUTPUT_PLM_READ
#endif

#ifndef HLS_COMPUTE_RESET
    #define HLS_COMPUTE_RESET
#endif
#ifndef HLS_COMPUTE_CONFIG
    #define HLS_COMPUTE_CONFIG
#endif

#ifndef HLS_COMPUTE_SPMV_LOOP
    #define HLS_COMPUTE_SPMV_LOOP
#endif
#ifndef HLS_COMPUTE_MAP_REGS
    #define HLS_COMPUTE_MAP_REGS
#endif
#ifndef HLS_COMPUTE_MAIN
    #define HLS_COMPUTE_MAIN
#endif
#ifndef HLS_COMPUTE_RW_CHUNK
    #define HLS_COMPUTE_RW_CHUNK
#endif

#endif /* __SPMV_DIRECTIVES_HPP__ */
