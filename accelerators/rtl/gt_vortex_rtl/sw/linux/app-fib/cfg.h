// Copyright (c) 2011-2026 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef __ESP_CFG_000_H__
#define __ESP_CFG_000_H__

#include "libesp.h"
#include "gt_vortex_rtl.h"

typedef int32_t token_t;


#define NACC 1

/* Single-descriptor launch configuration consumed by esp_run(). */
struct gt_vortex_rtl_access gt_vortex_cfg_000[] = {
	{
		/* <<--descriptor-->> */
		.BASE_ADDR = 0,
		.START_VORTEX = 1,
		.STARTUP_ADDR0 = 0,
		.STARTUP_ADDR1 = 0,
		.STARTUP_ARG0 = 0,
		.STARTUP_ARG1 = 0,
		.MPM_CLASS = 0,
		.esp.coherence = ACC_COH_NONE,
		.esp.p2p_store = 0,
		.esp.p2p_nsrcs = 0,
		.esp.p2p_srcs = {"", "", "", ""},
	}
};

/* Thread metadata for ESP's generic user-space launcher helper. */
esp_thread_info_t cfg_000[] = {
	{
		.run = true,
		.devname = "gt_vortex_rtl.0",
		.ioctl_req = GT_VORTEX_RTL_IOC_ACCESS,
		.esp_desc = &(gt_vortex_cfg_000[0].esp),
	}
};

#endif /* __ESP_CFG_000_H__ */
