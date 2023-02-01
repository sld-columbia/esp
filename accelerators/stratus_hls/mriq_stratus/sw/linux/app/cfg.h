// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef __ESP_CFG_000_H__
#define __ESP_CFG_000_H__

#include "libesp.h"
#include "mriq_stratus.h"

typedef int32_t token_t;

/* <<--params-def-->> */


#define NUM_BATCH_K 1
#define BATCH_SIZE_K 16
#define NUM_BATCH_X 1
#define BATCH_SIZE_X 4



/* <<--params-->> */


const int32_t num_batch_k = NUM_BATCH_K;
const int32_t batch_size_k = BATCH_SIZE_K;
const int32_t num_batch_x = NUM_BATCH_X;
const int32_t batch_size_x = BATCH_SIZE_X;

#define NACC 1

struct mriq_stratus_access mriq_cfg_000[] = {
	{
		/* <<--descriptor-->> */
		.num_batch_k = NUM_BATCH_K,
		.batch_size_k = BATCH_SIZE_K,
		.num_batch_x = NUM_BATCH_X,
		.batch_size_x = BATCH_SIZE_X,
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
		.devname = "mriq_stratus.0",
		.ioctl_req = MRIQ_STRATUS_IOC_ACCESS,
		.esp_desc = &(mriq_cfg_000[0].esp),
	}
};

#endif /* __ESP_CFG_000_H__ */
