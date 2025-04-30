// Copyright (c) 2011-2025 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef __ESP_CFG_000_H__
#define __ESP_CFG_000_H__

#include "libesp.h"
#include "macfin3_sysc_catapult.h"

typedef int32_t token_t;

/* <<--params-def-->> */
#define MAC_N 16
#define MAC_VEC 64
#define MAC_LEN 10

/* <<--params-->> */
const int32_t mac_n = MAC_N;
const int32_t mac_vec = MAC_VEC;
const int32_t mac_len = MAC_LEN;

#define NACC 1

struct macfin3_sysc_catapult_access macfin3_cfg_000[] = {{
    /* <<--descriptor-->> */
		.mac_n = MAC_N,
		.mac_vec = MAC_VEC,
		.mac_len = MAC_LEN,
    .src_offset    = 0,
    .dst_offset    = 0,
    .esp.coherence = ACC_COH_NONE,
    .esp.p2p_store = 0,
    .esp.p2p_nsrcs = 0,
    .esp.p2p_srcs  = {"", "", "", ""},
}};

esp_thread_info_t cfg_000[] = {{
    .run       = true,
    .devname   = "macfin3_sysc_catapult.0",
    .ioctl_req = MACFIN_SYSC_CATAPULT_IOC_ACCESS,
    .esp_desc  = &(macfin3_cfg_000[0].esp),
}};

#endif /* __ESP_CFG_000_H__ */
