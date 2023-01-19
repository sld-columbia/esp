// Copyright (c) 2011-2022 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef __ESP_CFG_000_H__
#define __ESP_CFG_000_H__

#include "libesp.h"
#include "gt_vortex_rtl.h"

typedef int32_t token_t;

/* <<--params-def-->> */
#define VX_BUSY_INT_M 0
#define BASE_ADDR_M 0xa0100b30
#define START_VORTEX_M 1

/* <<--params-->> */
const int32_t VX_BUSY_INT = VX_BUSY_INT_M;
const int32_t BASE_ADDR = BASE_ADDR_M;
const int32_t START_VORTEX = START_VORTEX_M;

#define NACC 1

struct gt_vortex_rtl_access gt_vortex_cfg_000[] = {
	{
		/* <<--descriptor-->> */
		.VX_BUSY_INT = VX_BUSY_INT,
		.BASE_ADDR = BASE_ADDR,
		.START_VORTEX = START_VORTEX,
		.src_offset = 0,
		.dst_offset = 0,
		.esp.coherence = ACC_COH_NONE,
		.esp.p2p_store = 0,
		.esp.p2p_nsrcs = 0,
		.esp.p2p_srcs = {"", "", "", ""},
	}
};

esp_thread_info_t cfg_000[] = {
	{
		.run = true,
		.devname = "gt_vortex_rtl.0",
		.ioctl_req = GT_VORTEX_RTL_IOC_ACCESS,
		.esp_desc = &(gt_vortex_cfg_000[0].esp),
	}
};

#endif /* __ESP_CFG_000_H__ */
