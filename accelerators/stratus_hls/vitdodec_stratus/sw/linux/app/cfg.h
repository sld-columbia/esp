// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef __ESP_CFG_000_H__
#define __ESP_CFG_000_H__

#include "libesp.h"
#include "vitdodec_stratus.h"

typedef int8_t token_t;

/* <<--params-def-->> */
#define CBPS 48
#define NTRACEBACK 5
#define DATA_BITS 288

/* <<--params-->> */
const int32_t cbps = CBPS;
const int32_t ntraceback = NTRACEBACK;
const int32_t data_bits = DATA_BITS;

#define NACC 1

struct vitdodec_stratus_access vitdodec_cfg_000[] = {
	{
		/* <<--descriptor-->> */
		.cbps = CBPS,
		.ntraceback = NTRACEBACK,
		.data_bits = DATA_BITS,
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
		.devname = "vitdodec_stratus.0",
		.ioctl_req = VITDODEC_STRATUS_IOC_ACCESS,
		.esp_desc = &(vitdodec_cfg_000[0].esp),
	}
};

#endif /* __ESP_CFG_000_H__ */
