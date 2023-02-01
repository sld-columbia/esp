// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef __ESP_CFG_000_H__
#define __ESP_CFG_000_H__

#include "libesp.h"
#include "fft_chisel.h"

typedef int32_t token_t;

/* <<--params-def-->> */
#define LOG_LEN 5
#define LEN (1 << LOG_LEN)

/* <<--params-->> */
const int32_t len = LEN;
const int32_t log_len = LOG_LEN;

#define NACC 1

struct fft_chisel_access fft_cfg_000[] = {
	{
		/* <<--descriptor-->> */
		.stride = LEN,
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
		.devname = "fft_chisel.0",
		.ioctl_req = FFT_CHISEL_IOC_ACCESS,
		.esp_desc = &(fft_cfg_000[0].esp),
	}
};

#endif /* __ESP_CFG_000_H__ */
