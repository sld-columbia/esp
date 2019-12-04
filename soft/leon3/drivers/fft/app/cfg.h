#ifndef __ESP_CFG_000_H__
#define __ESP_CFG_000_H__

#include "libesp.h"

typedef int64_t token_t;

/* <<--params-def-->> */
#define LEN 1024
#define LOG_LEN 10

/* <<--params-->> */
const int32_t len = LEN;
const int32_t log_len = LOG_LEN;

#define NACC 1

esp_thread_info_t cfg_000[] = {
	{
		.run = true,
		.devname = "fft.0",
		.type = fft,
		/* <<--descriptor-->> */
		.desc.fft_desc.len = LEN,
		.desc.fft_desc.log_len = LOG_LEN,
		.desc.fft_desc.src_offset = 0,
		.desc.fft_desc.dst_offset = 0,
		.desc.fft_desc.esp.coherence = ACC_COH_NONE,
		.desc.fft_desc.esp.p2p_store = 0,
		.desc.fft_desc.esp.p2p_nsrcs = 0,
		.desc.fft_desc.esp.p2p_srcs = {"", "", "", ""},
	}
};

#endif /* __ESP_CFG_000_H__ */
