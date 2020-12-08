#ifndef __ESP_CFG_000_H__
#define __ESP_CFG_000_H__

#include "libesp.h"
#include "fft.h"

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

struct fft_access fft_cfg_000[] = {
	{
		/* <<--descriptor-->> */
		.do_bitrev = DO_BITREV,
		.log_len = LOG_LEN,
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
		.devname = "fft.0",
		.ioctl_req = FFT_IOC_ACCESS,
		.esp_desc = &(fft_cfg_000[0].esp),
	}
};

#endif /* __ESP_CFG_000_H__ */
