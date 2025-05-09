// Copyright (c) 2011-2024 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __ACCSPECS__
#define __ACCSPECS__

#include <mc_connections.h>
#include "nvhls_connections.h"
#include <nvhls_int.h>
#include <nvhls_types.h>
#include <nvhls_vector.h>

#include "esp_dma_info_sysc.hpp"
#include "leakyrelu_conf_info.h"


#define __round_mask(x, y) ((y)-1)
#define round_up(x, y) ((((x)-1) | __round_mask(x, y))+1)

// dma configuration
#define DMA_SIZE SIZE_DWORD
#define DATA_WIDTH 32
// accelerator configuration
#define VEC_LEN 16
#define PLM_WORD 1024
#define VEC_DMA_RATIO VEC_LEN/DMA_WORD_PER_BEAT

const unsigned int bks = VEC_LEN;
const unsigned int ebks = PLM_WORD/VEC_LEN;


#if (DMA_WIDTH == 32)
/* <<--defines_32-->> */
#define DMA_BEAT_PER_WORD 1 
#define DMA_WORD_PER_BEAT 1 

#elif (DMA_WIDTH == 64)
/* <<--defines_64-->> */
#if (DATA_WIDTH == 32)
#define DMA_BEAT_PER_WORD 0
#define DMA_WORD_PER_BEAT 2
#elif (DATA_WIDTH == 16)
#define DMA_BEAT_PER_WORD 0
#define DMA_WORD_PER_BEAT 4
#endif 

#elif (DMA_WIDTH == 128)
/* <<--defines_128-->> */
#if (DATA_WIDTH == 32)
#define DMA_BEAT_PER_WORD 0
#define DMA_WORD_PER_BEAT 4
#elif (DATA_WIDTH == 16)
#define DMA_BEAT_PER_WORD 0
#define DMA_WORD_PER_BEAT 8
#endif 

#elif (DMA_WIDTH == 256)
/* <<--defines_256-->> */
#if (DATA_WIDTH == 32)
#define DMA_BEAT_PER_WORD 0
#define DMA_WORD_PER_BEAT 8
#elif (DATA_WIDTH == 16)
#define DMA_BEAT_PER_WORD 0
#define DMA_WORD_PER_BEAT 16
#endif 

#elif (DMA_WIDTH == 512)
/* <<--defines_512 ->> */
#define DMA_BEAT_PER_WORD 0 
#define DMA_WORD_PER_BEAT 16 
#endif

// memory configuration for each parameter
// #define MEM_SIZE 787200/(DMA_WIDTH/32)
#define MEM_SIZE 2621440*4

typedef NVUINTW(DATA_WIDTH) DATA_TYPE;

#endif
