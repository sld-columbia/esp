// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __NIGHTVISION_DIRECTIVES_HPP__
#define __NIGHTVISION_DIRECTIVES_HPP__

#define MAX_PXL_WIDTH (1 << MAX_PXL_WIDTH_LOG)
#define WORDS_PER_DMA (DMA_WIDTH >> MAX_PXL_WIDTH_LOG)
#define PLM_HIST_SIZE (1 << MAX_PXL_WIDTH)

typedef sc_uint<16> pixel_t;

#if defined(STRATUS_HLS)

    #if (PLM_IMG_SIZE == 1024)

        #if (WORDS_PER_DMA == 2)
            #define HLS_MAP_mem_buff_1 HLS_MAP_TO_MEMORY(mem_buff_1, "plm_data16_1024_2w2r")
            #define HLS_MAP_mem_buff_2 HLS_MAP_TO_MEMORY(mem_buff_2, "plm_data16_1024_2w2r")
        #elif (WORDS_PER_DMA == 4)
            #define HLS_MAP_mem_buff_1 HLS_MAP_TO_MEMORY(mem_buff_1, "plm_data16_1024_4w4r")
            #define HLS_MAP_mem_buff_2 HLS_MAP_TO_MEMORY(mem_buff_2, "plm_data16_1024_4w4r")
        #elif (WORDS_PER_DMA == 8)
            #define HLS_MAP_mem_buff_1 HLS_MAP_TO_MEMORY(mem_buff_1, "plm_data16_1024_8w8r")
            #define HLS_MAP_mem_buff_2 HLS_MAP_TO_MEMORY(mem_buff_2, "plm_data16_1024_8w8r")
        #else // WORDS_PER_DMA
            #error Unsupported DMA width
        #endif // WORDS_PER_DMA

    #elif (PLM_IMG_SIZE == 19200)

        #if (WORDS_PER_DMA == 2)
            #define HLS_MAP_mem_buff_1 HLS_MAP_TO_MEMORY(mem_buff_1, "plm_data16_19200_2w2r")
            #define HLS_MAP_mem_buff_2 HLS_MAP_TO_MEMORY(mem_buff_2, "plm_data16_19200_2w2r")
        #elif (WORDS_PER_DMA == 4)
            #define HLS_MAP_mem_buff_1 HLS_MAP_TO_MEMORY(mem_buff_1, "plm_data16_19200_4w4r")
            #define HLS_MAP_mem_buff_2 HLS_MAP_TO_MEMORY(mem_buff_2, "plm_data16_19200_4w4r")
        #elif (WORDS_PER_DMA == 8)
            #define HLS_MAP_mem_buff_1 HLS_MAP_TO_MEMORY(mem_buff_1, "plm_data16_19200_8w8r")
            #define HLS_MAP_mem_buff_2 HLS_MAP_TO_MEMORY(mem_buff_2, "plm_data16_19200_8w8r")
        #else // WORDS_PER_DMA
            #error Unsupported DMA width
        #endif // WORDS_PER_DMA

    #else // PLM_IMG_SIZE == 307200

        #if (WORDS_PER_DMA == 2)
            #define HLS_MAP_mem_buff_1 HLS_MAP_TO_MEMORY(mem_buff_1, "plm_data16_2w2r")
            #define HLS_MAP_mem_buff_2 HLS_MAP_TO_MEMORY(mem_buff_2, "plm_data16_2w2r")
        #elif (WORDS_PER_DMA == 4)
            #define HLS_MAP_mem_buff_1 HLS_MAP_TO_MEMORY(mem_buff_1, "plm_data16_4w4r")
            #define HLS_MAP_mem_buff_2 HLS_MAP_TO_MEMORY(mem_buff_2, "plm_data16_4w4r")
        #elif (WORDS_PER_DMA == 8)
            #define HLS_MAP_mem_buff_1 HLS_MAP_TO_MEMORY(mem_buff_1, "plm_data16_8w8r")
            #define HLS_MAP_mem_buff_2 HLS_MAP_TO_MEMORY(mem_buff_2, "plm_data16_8w8r")
        #else // WORDS_PER_DMA
            #error Unsupported DMA width
        #endif // WORDS_PER_DMA

    #endif // PLM_IMG_SIZE

    #if (PLM_HIST_SIZE == 256)
        #define HLS_MAP_mem_hist_1 HLS_MAP_TO_MEMORY(mem_hist_1, "plm_hist_256_1w1r")
        #define HLS_MAP_mem_hist_2 HLS_MAP_TO_MEMORY(mem_hist_2, "plm_hist_256_1w1r")
    #else
        #define HLS_MAP_mem_hist_1 HLS_MAP_TO_MEMORY(mem_hist_1, "plm_hist_1w1r")
        #define HLS_MAP_mem_hist_2 HLS_MAP_TO_MEMORY(mem_hist_2, "plm_hist_1w1r")
    #endif

    #define HLS_PROTO(_s) HLS_DEFINE_PROTOCOL(_s)

    #define HLS_FLAT(_a) HLS_FLATTEN_ARRAY(_a);

    #define HLS_BREAK_DEP(_a) HLS_BREAK_ARRAY_DEPENDENCY(_a)

    #define HLS_UNROLL_SIMPLE HLS_UNROLL_LOOP(ON)

    #if defined(HLS_DIRECTIVES_BASIC)

        #define HLS_PIPE_H1(_s)

        #define HLS_PIPE_H2(_s)

        #define HLS_DWT_XPOSE_CONSTR(_m, _s)

    #elif defined(HLS_DIRECTIVES_FAST)

        #define HLS_PIPE_H1(_s) HLS_PIPELINE_LOOP(HARD_STALL, 1, _s);

        #define HLS_PIPE_H2(_s) HLS_PIPELINE_LOOP(HARD_STALL, 2, _s);

        #define HLS_DWT_XPOSE_CONSTR(_m, _s) HLS_CONSTRAIN_ARRAY_MAX_DISTANCE(_m, 2, _s);

    #else

        #error Unsupported or undefined HLS configuration

    #endif // HLS_DIRECTIVES_*

#else // !STRATUS_HLS

    #define HLS_MAP_mem_buff_1
    #define HLS_MAP_mem_buff_2
    #define HLS_MAP_mem_hist_1
    #define HLS_MAP_mem_hist_2

    #define HLS_PROTO(_s)
    #define HLS_FLAT(_a)
    #define HLS_BREAK_DEP(_a)
    #define HLS_UNROLL_SIMPLE
    #define HLS_PIPE_H1(_s)
    #define HLS_PIPE_H2(_s)

    #define HLS_DWT_XPOSE_CONSTR(_m, _s)

#endif // STRATUS_HLS

#endif // __NIGHTVISION_DIRECTIVES_HPP__
