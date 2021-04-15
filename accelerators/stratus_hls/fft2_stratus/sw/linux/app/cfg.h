#ifndef __ESP_CFG_000_H__
#define __ESP_CFG_000_H__

#include "libesp.h"
#include "fft2_stratus.h"

#if (FFT2_FX_WIDTH == 64)
typedef unsigned long long token_t;
typedef double native_t;
#define fx2float fixed64_to_double
#define float2fx double_to_fixed64
#define FX_IL 42
#elif (FFT2_FX_WIDTH == 32)
typedef int token_t;
typedef float native_t;
#define fx2float fixed32_to_float
#define float2fx float_to_fixed32
#define FX_IL 14
#endif /* FFT2_FX_WIDTH */

/* <<--params-def-->> */
#define LOGN_SAMPLES 6
//#define NUM_FFTS     46
#define NUM_FFTS     1
//#define LOGN_SAMPLES 12
//#define NUM_FFTS     13
/*#define NUM_SAMPLES (NUM_FFTS * (1 << LOGN_SAMPLES))*/
#define DO_INVERSE   0
#define DO_SHIFT     1
#define SCALE_FACTOR 0

/* <<--params-->> */
const int32_t logn_samples = LOGN_SAMPLES;
/*const int32_t num_samples = NUM_SAMPLES;*/
const int32_t num_ffts = NUM_FFTS;
const int32_t do_inverse = DO_INVERSE;
const int32_t do_shift = DO_SHIFT;
const int32_t scale_factor = SCALE_FACTOR;

#define NACC 1

struct fft2_stratus_access fft2_cfg_000[] = {
	{
		/* <<--descriptor-->> */
		.logn_samples = LOGN_SAMPLES,
		.num_ffts = NUM_FFTS,
		.do_inverse = DO_INVERSE,
		.do_shift = DO_SHIFT,
		.scale_factor = SCALE_FACTOR,
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
		.devname = "fft2_stratus.0",
		.ioctl_req = FFT2_STRATUS_IOC_ACCESS,
		.esp_desc = &(fft2_cfg_000[0].esp),
	}
};

#endif /* __ESP_CFG_000_H__ */
