// Copyright (c) 2011-2025 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __ACCSPECS__
#define __ACCSPECS__

#include <mc_connections.h>
#include "nvhls_connections.h"
#include <nvhls_int.h>
#include <nvhls_types.h>
#include <nvhls_vector.h>
#include "accelerator_name_conf_info.hpp"
#include "esp_dma_info_sysc.hpp"
#include <ArbitratedScratchpadDP.h>

#define MAX(a, b) ((a) > (b) ? (a) : (b))

/* <<--defines-->> */
#define MEM_SIZE /* <<--mem-footprint-->> */ / (DMA_WIDTH / 8)

#define DMA_BEAT_PER_WORD MAX(1, (DATA_WIDTH / DMA_WIDTH))
#define DMA_WORD_PER_BEAT (DMA_WIDTH / DATA_WIDTH)

#define IN_BKS MAX(1,DMA_WORD_PER_BEAT)
#define OUT_BKS MAX(1,DMA_WORD_PER_BEAT)

const unsigned int inbks   = IN_BKS;
const unsigned int outbks  = OUT_BKS;
const unsigned int inebks  = PLM_IN_WORD / IN_BKS;
const unsigned int outebks = PLM_OUT_WORD / OUT_BKS;

#endif
