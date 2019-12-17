#ifndef __ESP_CFG_000_H__
#define __ESP_CFG_000_H__

#include "libesp.h"

typedef int32_t token_t;

/* <<--params-def-->> */
#define LOG_LEN 5
#define LEN (1 << LOG_LEN)

/* <<--params-->> */
const int32_t len = LEN;
const int32_t log_len = LOG_LEN;

#define NACC 1

esp_thread_info_t cfg_000[] = {
	{
		.run = true,
		.devname = "fftaccelerator.0",
		.type = fftaccelerator,
		/* <<--descriptor-->> */
		.desc.fftaccelerator_desc.stride = LEN,
		.desc.fftaccelerator_desc.src_offset = 0,
		.desc.fftaccelerator_desc.dst_offset = 0,
		.desc.fftaccelerator_desc.esp.coherence = ACC_COH_NONE,
		.desc.fftaccelerator_desc.esp.p2p_store = 0,
		.desc.fftaccelerator_desc.esp.p2p_nsrcs = 0,
		.desc.fftaccelerator_desc.esp.p2p_srcs = {"", "", "", ""},
	}
};

#endif /* __ESP_CFG_000_H__ */
