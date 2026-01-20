// Copyright (c) 2011-2025 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef __ESP_CFG_000_H__
#define __ESP_CFG_000_H__

#include "libesp.h"
#include "conv1d_sysc_catapult.h"

typedef int32_t token_t;

/* <<--params-def-->> */
#define KERNEL_SIZE 0
#define N_CHANNELS 0
#define STRIDE 1
#define IS_RELU 0
#define ADDRB 0
#define ADDRO 0
#define ADDRI 0
#define ADDRW 0
#define BATCH_SIZE 1
#define N_FILTERS 0
#define FEATURE_MAP_LEN 0
#define PADDING 0

/* <<--params-->> */
const int32_t kernel_size = KERNEL_SIZE;
const int32_t n_channels = N_CHANNELS;
const int32_t stride = STRIDE;
const int32_t is_relu = IS_RELU;
const int32_t addrB = ADDRB;
const int32_t addrO = ADDRO;
const int32_t addrI = ADDRI;
const int32_t addrW = ADDRW;
const int32_t batch_size = BATCH_SIZE;
const int32_t n_filters = N_FILTERS;
const int32_t feature_map_len = FEATURE_MAP_LEN;
const int32_t padding = PADDING;

#define NACC 1

struct conv1d_sysc_catapult_access conv1d_cfg_000[] = {{
    /* <<--descriptor-->> */
		.kernel_size = KERNEL_SIZE,
		.n_channels = N_CHANNELS,
		.stride = STRIDE,
		.is_relu = IS_RELU,
		.addrB = ADDRB,
		.addrO = ADDRO,
		.addrI = ADDRI,
		.addrW = ADDRW,
		.batch_size = BATCH_SIZE,
		.n_filters = N_FILTERS,
		.feature_map_len = FEATURE_MAP_LEN,
		.padding = PADDING,
    .src_offset    = 0,
    .dst_offset    = 0,
    .esp.coherence = ACC_COH_NONE,
    .esp.p2p_store = 0,
    .esp.p2p_nsrcs = 0,
    .esp.p2p_srcs  = {"", "", "", ""},
}};

esp_thread_info_t cfg_000[] = {{
    .run       = true,
    .devname   = "conv1d_sysc_catapult.0",
    .ioctl_req = CONV1D_SYSC_CATAPULT_IOC_ACCESS,
    .esp_desc  = &(conv1d_cfg_000[0].esp),
}};

#endif /* __ESP_CFG_000_H__ */
