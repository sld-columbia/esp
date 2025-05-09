// Copyright (c) 2011-2024 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef __ESP_CFG_000_H__
#define __ESP_CFG_000_H__

#include "libesp.h"
#include "leakyrelu_sysc_catapult.h"

typedef int32_t token_t;

/* <<--params-->> */
const int32_t leaky_row = 2;
const int32_t leaky_batch = 4;


struct leakyrelu_sysc_catapult_access leakyrelu_cfg_000[] = {
	{
		/* <<--descriptor-->> */
		.batch	= leaky_batch;
		.row	= leaky_row;
		.addrA	= leaky_row * leaky_batch * 16 * 0;
		.addrB	= leaky_row * leaky_batch * 16 * 1;
		.addrO	= leaky_row * leaky_batch * 16 * 2;
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
		.devname = "leakyrelu_sysc_catapult.0",
		.ioctl_req = LEAKYRELU_SYSC_CATAPULT_IOC_ACCESS,
		.esp_desc = &(leakyrelu_cfg_000[0].esp),
	}
};

#endif /* __ESP_CFG_000_H__ */
