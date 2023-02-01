// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef __MULTIFFT_STRATUS_CFG_H__
#define __MULTIFFT_STRATUS_CFG_H__

#include "libesp.h"
#include "fft_stratus.h"

/* TODO: read HLS config from registers instead */
#define FFT_FX_WIDTH == 32
typedef int token_t;
typedef float native_t;
#define fx2float fixed32_to_float
#define float2fx float_to_fixed32
#define FX_IL 12

/* <<--params-def-->> */
#define LOG_LEN 7
#define LEN (1 << LOG_LEN)
#define DO_BITREV 1
#define NUM_BATCHES 1

/* <<--params-->> */
const int32_t len = LEN;
const int32_t log_len = LOG_LEN;

#define NACC 3

struct fft_stratus_access fft_cfg_coh[] = {
	{
		/* <<--descriptor-->> */
		.batch_size = NUM_BATCHES,
		.do_bitrev = DO_BITREV,
		.log_len = LOG_LEN,
		.src_offset = 0,
		.dst_offset = 0,
		.esp.coherence = ACC_COH_NONE,
		.esp.p2p_store = 0,
		.esp.p2p_nsrcs = 0,
		.esp.p2p_srcs = {"", "", "", ""},
	},
	{
		/* <<--descriptor-->> */
		.batch_size = NUM_BATCHES,
		.do_bitrev = DO_BITREV,
		.log_len = LOG_LEN,
		.src_offset = 0,
		.dst_offset = 0,
		.esp.coherence = ACC_COH_LLC,
		.esp.p2p_store = 0,
		.esp.p2p_nsrcs = 0,
		.esp.p2p_srcs = {"", "", "", ""},
	},
	{
		/* <<--descriptor-->> */
		.batch_size = NUM_BATCHES,
		.do_bitrev = DO_BITREV,
		.log_len = LOG_LEN,
		.src_offset = 0,
		.dst_offset = 0,
		.esp.coherence = ACC_COH_FULL,
		.esp.p2p_store = 0,
		.esp.p2p_nsrcs = 0,
		.esp.p2p_srcs = {"", "", "", ""},
	}
};

struct fft_stratus_access fft_cfg_p2p[] = {
	{
		/* <<--descriptor-->> */
		.batch_size = NUM_BATCHES,
		.do_bitrev = DO_BITREV,
		.log_len = LOG_LEN,
		.src_offset = 0,
		.dst_offset = 0,
		.esp.coherence = ACC_COH_NONE,
		.esp.p2p_store = 1,
		.esp.p2p_nsrcs = 0,
		.esp.p2p_srcs = {"", "", "", ""},
	},
	{
		/* <<--descriptor-->> */
		.batch_size = NUM_BATCHES,
		.do_bitrev = DO_BITREV,
		.log_len = LOG_LEN,
		.src_offset = 0,
		.dst_offset = 0,
		.esp.coherence = ACC_COH_NONE,
		.esp.p2p_store = 1,
		.esp.p2p_nsrcs = 1,
		.esp.p2p_srcs = {"fft_stratus.0", "", "", ""},
	},
	{
		/* <<--descriptor-->> */
		.batch_size = NUM_BATCHES,
		.do_bitrev = DO_BITREV,
		.log_len = LOG_LEN,
		.src_offset = 0,
		.dst_offset = 0,
		.esp.coherence = ACC_COH_NONE,
		.esp.p2p_store = 0,
		.esp.p2p_nsrcs = 1,
		.esp.p2p_srcs = {"fft_stratus.1", "", "", ""},
	}
};

esp_thread_info_t cfg_parallel[] = {
	{
		.run = true,
		.devname = "fft_stratus.0",
		.ioctl_req = FFT_STRATUS_IOC_ACCESS,
		.esp_desc = &(fft_cfg_coh[2].esp),
	},
	{
		.run = true,
		.devname = "fft_stratus.1",
		.ioctl_req = FFT_STRATUS_IOC_ACCESS,
		.esp_desc = &(fft_cfg_coh[1].esp),
	},
	{
		.run = true,
		.devname = "fft_stratus.2",
		.ioctl_req = FFT_STRATUS_IOC_ACCESS,
		.esp_desc = &(fft_cfg_coh[0].esp),
	}
};

esp_thread_info_t cfg_p2p[] = {
	{
		.run = true,
		.devname = "fft_stratus.0",
		.ioctl_req = FFT_STRATUS_IOC_ACCESS,
		.esp_desc = &(fft_cfg_p2p[0].esp),
	},
	{
		.run = true,
		.devname = "fft_stratus.1",
		.ioctl_req = FFT_STRATUS_IOC_ACCESS,
		.esp_desc = &(fft_cfg_p2p[1].esp),
	},
	{
		.run = true,
		.devname = "fft_stratus.2",
		.ioctl_req = FFT_STRATUS_IOC_ACCESS,
		.esp_desc = &(fft_cfg_p2p[2].esp),
	}

};

esp_thread_info_t cfg_nc[] = {
	{
		.run = true,
		.devname = "fft_stratus.0",
		.ioctl_req = FFT_STRATUS_IOC_ACCESS,
		.esp_desc = &(fft_cfg_coh[0].esp),
	}
};

esp_thread_info_t cfg_llc[] = {
	{
		.run = true,
		.devname = "fft_stratus.0",
		.ioctl_req = FFT_STRATUS_IOC_ACCESS,
		.esp_desc = &(fft_cfg_coh[1].esp),
	}
};

esp_thread_info_t cfg_fc[] = {
	{
		.run = true,
		.devname = "fft_stratus.0",
		.ioctl_req = FFT_STRATUS_IOC_ACCESS,
		.esp_desc = &(fft_cfg_coh[2].esp),
	}
};

#endif /* __MULTIFFT_STRATUS_CFG_H__ */
