// Copyright (c) 2011-2024 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef __DUMMY_MULTICAST_P2P_H__
#define __DUMMY_MULTICAST_P2P_H__

#include "libesp.h"
#include "dummy_stratus.h"

/* TODO: read HLS config from registers instead */
typedef uint64_t token_t;
typedef uint64_t native_t;

/* <<--params-def-->> */
#define BATCH 1
#define TOKENS 64
#define mask 0x0LL

#define NACC 3

struct dummy_stratus_access dummy_cfg_p2p[] = {
	{
		/* <<--descriptor-->> */
		.batch = BATCH,
    	.tokens = TOKENS,
		.src_offset = 0,
		.dst_offset = 0,
		.esp.coherence = ACC_COH_RECALL,
		.esp.p2p_store = 1,
		.esp.p2p_nsrcs = 0,
		.esp.p2p_srcs = {"", "", "", ""},
		.esp.p2p_mcast_dests = 2,
	},
	{
		/* <<--descriptor-->> */
		.batch = BATCH,
    	.tokens = TOKENS,
		.src_offset = 0,
		.dst_offset = TOKENS * BATCH * sizeof(token_t),
		.esp.coherence = ACC_COH_RECALL,
		.esp.p2p_store = 0,
		.esp.p2p_nsrcs = 1,
		.esp.p2p_srcs = {"dummy_stratus.0", "", "", ""},
		.esp.p2p_mcast_dests = 0,
	},
	{
		/* <<--descriptor-->> */
		.batch = BATCH,
    	.tokens = TOKENS,
		.src_offset = 0,
		.dst_offset = TOKENS * BATCH * sizeof(token_t) * 2,
		.esp.coherence = ACC_COH_RECALL,
		.esp.p2p_store = 0,
		.esp.p2p_nsrcs = 1,
		.esp.p2p_srcs = {"dummy_stratus.0", "", "", ""},
		.esp.p2p_mcast_dests = 0,
	}
};

esp_thread_info_t cfg_p2p[] = {
	{
		.run = true,
		.devname = "dummy_stratus.0",
		.ioctl_req = DUMMY_STRATUS_IOC_ACCESS,
		.esp_desc = &(dummy_cfg_p2p[0].esp),
	},
	{
		.run = true,
		.devname = "dummy_stratus.1",
		.ioctl_req = DUMMY_STRATUS_IOC_ACCESS,
		.esp_desc = &(dummy_cfg_p2p[1].esp),
	},
	{
		.run = true,
		.devname = "dummy_stratus.2",
		.ioctl_req = DUMMY_STRATUS_IOC_ACCESS,
		.esp_desc = &(dummy_cfg_p2p[2].esp),
	}

};

#endif /* __DUMMY_MULTICAST_P2P_H__ */
