// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef __ESP_CFG_000_H__
#define __ESP_CFG_000_H__

#include "libesp.h"
#include "cholesky_stratus.h"

typedef int32_t token_t;

/* <<--params-def-->> */
#define ROWS 16

/* <<--params-->> */
int32_t rows = ROWS;

#define NACC 1

struct cholesky_stratus_access cholesky_cfg_000[] = {
         /* <<--descriptor-->> */
    {
        .rows = ROWS,
		.src_offset = 0,
		.dst_offset = 0,
		.esp.coherence = ACC_COH_FULL,
		.esp.p2p_store = 0,
		.esp.p2p_nsrcs = 0,
		.esp.p2p_srcs = {"", "", "", ""},
    }
};

esp_thread_info_t cfg_000[] = {
	{
        .run = true,
        .devname = "cholesky_stratus.0",
        .ioctl_req = CHOLESKY_STRATUS_IOC_ACCESS,
        .esp_desc = &(cholesky_cfg_000[0].esp),
    }
};

#endif /* __ESP_CFG_000_H__ */
