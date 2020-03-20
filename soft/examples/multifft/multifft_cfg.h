#ifndef __MULTIFFT_CFG_H__
#define __MULTIFFT_CFG_H__

#include "libesp.h"

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

/* <<--params-->> */
const int32_t len = LEN;
const int32_t log_len = LOG_LEN;

#define NACC 3

esp_thread_info_t cfg_parallel[] = {
	{
		.run = true,
		.devname = "fft.0",
		.type = fft,
		/* <<--descriptor-->> */
		.desc.fft_desc.do_bitrev = DO_BITREV,
		.desc.fft_desc.log_len = LOG_LEN,
		.desc.fft_desc.src_offset = 0,
		.desc.fft_desc.dst_offset = 0,
		.desc.fft_desc.esp.coherence = ACC_COH_FULL,
		.desc.fft_desc.esp.p2p_store = 0,
		.desc.fft_desc.esp.p2p_nsrcs = 0,
		.desc.fft_desc.esp.p2p_srcs = {"", "", "", ""},
	},
	{
		.run = true,
		.devname = "fft.1",
		.type = fft,
		/* <<--descriptor-->> */
		.desc.fft_desc.do_bitrev = DO_BITREV,
		.desc.fft_desc.log_len = LOG_LEN,
		.desc.fft_desc.src_offset = 0,
		.desc.fft_desc.dst_offset = 0,
		.desc.fft_desc.esp.coherence = ACC_COH_LLC,
		.desc.fft_desc.esp.p2p_store = 0,
		.desc.fft_desc.esp.p2p_nsrcs = 0,
		.desc.fft_desc.esp.p2p_srcs = {"", "", "", ""},
	},
	{
		.run = true,
		.devname = "fft.2",
		.type = fft,
		/* <<--descriptor-->> */
		.desc.fft_desc.do_bitrev = DO_BITREV,
		.desc.fft_desc.log_len = LOG_LEN,
		.desc.fft_desc.src_offset = 0,
		.desc.fft_desc.dst_offset = 0,
		.desc.fft_desc.esp.coherence = ACC_COH_NONE,
		.desc.fft_desc.esp.p2p_store = 0,
		.desc.fft_desc.esp.p2p_nsrcs = 0,
		.desc.fft_desc.esp.p2p_srcs = {"", "", "", ""},
	}

};

esp_thread_info_t cfg_p2p[] = {
	{
		.run = true,
		.devname = "fft.0",
		.type = fft,
		/* <<--descriptor-->> */
		.desc.fft_desc.do_bitrev = DO_BITREV,
		.desc.fft_desc.log_len = LOG_LEN,
		.desc.fft_desc.src_offset = 0,
		.desc.fft_desc.dst_offset = 0,
		.desc.fft_desc.esp.coherence = ACC_COH_NONE,
		.desc.fft_desc.esp.p2p_store = 1,
		.desc.fft_desc.esp.p2p_nsrcs = 0,
		.desc.fft_desc.esp.p2p_srcs = {"", "", "", ""},
	},
	{
		.run = true,
		.devname = "fft.1",
		.type = fft,
		/* <<--descriptor-->> */
		.desc.fft_desc.do_bitrev = DO_BITREV,
		.desc.fft_desc.log_len = LOG_LEN,
		.desc.fft_desc.src_offset = 0,
		.desc.fft_desc.dst_offset = 0,
		.desc.fft_desc.esp.coherence = ACC_COH_NONE,
		.desc.fft_desc.esp.p2p_store = 1,
		.desc.fft_desc.esp.p2p_nsrcs = 1,
		.desc.fft_desc.esp.p2p_srcs = {"fft.0", "", "", ""},
	},
	{
		.run = true,
		.devname = "fft.2",
		.type = fft,
		/* <<--descriptor-->> */
		.desc.fft_desc.do_bitrev = DO_BITREV,
		.desc.fft_desc.log_len = LOG_LEN,
		.desc.fft_desc.src_offset = 0,
		.desc.fft_desc.dst_offset = 0,
		.desc.fft_desc.esp.coherence = ACC_COH_NONE,
		.desc.fft_desc.esp.p2p_store = 0,
		.desc.fft_desc.esp.p2p_nsrcs = 1,
		.desc.fft_desc.esp.p2p_srcs = {"fft.1", "", "", ""},
	}

};

esp_thread_info_t cfg_nc[] = {
	{
		.run = true,
		.devname = "fft.0",
		.type = fft,
		/* <<--descriptor-->> */
		.desc.fft_desc.do_bitrev = DO_BITREV,
		.desc.fft_desc.log_len = LOG_LEN,
		.desc.fft_desc.src_offset = 0,
		.desc.fft_desc.dst_offset = 0,
		.desc.fft_desc.esp.coherence = ACC_COH_NONE,
		.desc.fft_desc.esp.p2p_store = 0,
		.desc.fft_desc.esp.p2p_nsrcs = 0,
		.desc.fft_desc.esp.p2p_srcs = {"", "", "", ""},
	}
};

esp_thread_info_t cfg_llc[] = {
	{
		.run = true,
		.devname = "fft.0",
		.type = fft,
		/* <<--descriptor-->> */
		.desc.fft_desc.do_bitrev = DO_BITREV,
		.desc.fft_desc.log_len = LOG_LEN,
		.desc.fft_desc.src_offset = 0,
		.desc.fft_desc.dst_offset = 0,
		.desc.fft_desc.esp.coherence = ACC_COH_LLC,
		.desc.fft_desc.esp.p2p_store = 0,
		.desc.fft_desc.esp.p2p_nsrcs = 0,
		.desc.fft_desc.esp.p2p_srcs = {"", "", "", ""},
	}
};

esp_thread_info_t cfg_fc[] = {
	{
		.run = true,
		.devname = "fft.0",
		.type = fft,
		/* <<--descriptor-->> */
		.desc.fft_desc.do_bitrev = DO_BITREV,
		.desc.fft_desc.log_len = LOG_LEN,
		.desc.fft_desc.src_offset = 0,
		.desc.fft_desc.dst_offset = 0,
		.desc.fft_desc.esp.coherence = ACC_COH_FULL,
		.desc.fft_desc.esp.p2p_store = 0,
		.desc.fft_desc.esp.p2p_nsrcs = 0,
		.desc.fft_desc.esp.p2p_srcs = {"", "", "", ""},
	}
};

#endif /* __MULTIFFT_CFG_H__ */
