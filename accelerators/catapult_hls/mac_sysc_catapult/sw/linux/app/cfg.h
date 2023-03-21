// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef __ESP_CFG_000_H__
#define __ESP_CFG_000_H__

#include "libesp.h"
#include "mac_sysc_catapult.h"

typedef int32_t token_t;

/* <<--params-def-->> */
#define MAC_N 1
#define MAC_VEC 8
#define MAC_LEN 16

/* <<--params-->> */
const int32_t mac_n = MAC_N;
const int32_t mac_vec = MAC_VEC;
const int32_t mac_len = MAC_LEN;

#define NACC 1

struct mac_sysc_catapult_access mac_cfg_000[] = {
	{
		/* <<--descriptor-->> */
		.mac_n = MAC_N,
		.mac_vec = MAC_VEC,
		.mac_len = MAC_LEN,
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
		.devname = "mac_sysc_catapult.0",
		.ioctl_req = MAC_SYSC_CATAPULT_IOC_ACCESS,
		.esp_desc = &(mac_cfg_000[0].esp),
	}
};

#endif /* __ESP_CFG_000_H__ */
