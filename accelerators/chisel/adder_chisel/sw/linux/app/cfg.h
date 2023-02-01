// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef __ESP_CFG_000_H__
#define __ESP_CFG_000_H__

#include "libesp.h"
#include "adder_chisel.h"

typedef int32_t token_t;

/* <<--params-def-->> */
#define SIZE 1024

/* <<--params-->> */
const int32_t readAddr = 0;
const int32_t writeAddr = 0;

#define NACC 1

struct adder_chisel_access adder_cfg_000[] = {
	{
		/* <<--descriptor-->> */
		.size = SIZE,
		.readAddr = 0,
		.writeAddr = 0,
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
		.devname = "adder_chisel.0",
		.ioctl_req = ADDER_CHISEL_IOC_ACCESS,
		.esp_desc = &(adder_cfg_000[0].esp),
	}
};

#endif /* __ESP_CFG_000_H__ */
