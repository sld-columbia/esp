// Copyright (c) 2011-2025 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef __ESP_CFG_000_H__
#define __ESP_CFG_000_H__

#include "libesp.h"
#include "vecadd_rtl.h"

typedef int32_t token_t;

/* <<--params-def-->> */
#define VECTOR_SIZE 1024
#define CHUNK_SIZE  0

/* <<--params-->> */
const int32_t vector_size = VECTOR_SIZE;
const int32_t chunk_size  = CHUNK_SIZE;

#define NACC 1

struct vecadd_rtl_access vecadd_cfg_000[] = {{
    /* <<--descriptor-->> */
    .vector_size   = VECTOR_SIZE,
    .chunk_size    = CHUNK_SIZE,
    .src_offset    = 0,
    .dst_offset    = 0,
    .esp.coherence = ACC_COH_NONE,
    .esp.p2p_store = 0,
    .esp.p2p_nsrcs = 0,
    .esp.p2p_srcs  = {"", "", "", ""},
}};

esp_thread_info_t cfg_000[] = {{
    .run       = true,
    .devname   = "vecadd_rtl.0",
    .ioctl_req = VECADD_RTL_IOC_ACCESS,
    .esp_desc  = &(vecadd_cfg_000[0].esp),
}};

#endif /* __ESP_CFG_000_H__ */
