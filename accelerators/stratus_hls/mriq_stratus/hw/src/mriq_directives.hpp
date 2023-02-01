// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __MRIQ_DIRECTIVES_HPP__
#define __MRIQ_DIRECTIVES_HPP__


#if(DMA_WIDTH == 32)
#define DMA_BEAT_PER_WORD 1
#define DMA_WORD_PER_BEAT 1
#define PLM_X_NAME "mriq_x_dma32"
#if(ARCH==0)
#if(PARAL==4)
#define PLM_K_NAME "mriq_SK_P4_k_dma32"
#elif(PARAL==8)
#define PLM_K_NAME "mriq_SK_P8_k_dma32"
#elif(PARAL==16)
#define PLM_K_NAME "mriq_SK_P16_k_dma32"
#endif // PARAL
#else
#if(PARAL==4)
#define PLM_K_NAME "mriq_LK_P4_k_dma32"
#elif(PARAL==8)
#define PLM_K_NAME "mriq_LK_P8_k_dma32"
#elif(PARAL==16)
#define PLM_K_NAME "mriq_LK_P16_k_dma32"
#endif // PARAL
#endif // ARCH
#elif(DMA_WIDTH == 64)
#define DMA_BEAT_PER_WORD 1
#define DMA_WORD_PER_BEAT 2
#define PLM_X_NAME "mriq_x_dma64"
#if(ARCH==0)
#if(PARAL==4)
#define PLM_K_NAME "mriq_SK_P4_k_dma64"
#elif(PARAL==8)
#define PLM_K_NAME "mriq_SK_P8_k_dma64"
#elif(PARAL==16)
#define PLM_K_NAME "mriq_SK_P16_k_dma64"
#endif // PARAL
#else
#if(PARAL==4)
#define PLM_K_NAME "mriq_LK_P4_k_dma64"
#elif(PARAL==8)
#define PLM_K_NAME "mriq_LK_P8_k_dma64"
#elif(PARAL==16)
#define PLM_K_NAME "mriq_LK_P16_k_dma64"
#endif // PARAL
#endif // ARCH
#endif // DMA_WIDTH


#if(ARCH==0)
#define PLM_X_WORD 128
#define PLM_K_WORD 3072
#elif(ARCH==1)
#define PLM_X_WORD 128 // increasing this param won't increase performance
#define PLM_K_WORD 1024
#endif



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

#endif /* STRATUS_HLS */

#endif /* __MRIQ_DIRECTIVES_HPP_ */
