#ifndef __ESP_CFG_000_H__
#define __ESP_CFG_000_H__

#include "libesp.h"

#if (FFT_FX_WIDTH == 64)
typedef unsigned long long token_t;
typedef double native_t;
#define fx2float fixed64_to_double
#define float2fx double_to_fixed64
#define FX_IL 42
#elif (FFT_FX_WIDTH == 32)
typedef int token_t;
typedef float native_t;
#define fx2float fixed32_to_float
#define float2fx float_to_fixed32
#define FX_IL 12
#endif /* FFT_FX_WIDTH */

/* <<--params-def-->> */
#define LOG_LEN 10
#define LEN (1 << LOG_LEN)
#define DO_BITREV 1

/* <<--params-->> */
const int32_t do_bitrev = DO_BITREV;
const int32_t len = LEN;
const int32_t log_len = LOG_LEN;

#define NACC 1

esp_thread_info_t cfg_000[] = {
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

#endif /* __ESP_CFG_000_H__ */
