#ifndef __ESP_CFG_000_H__
#define __ESP_CFG_000_H__

#include "libesp.h"

/* User defined */

// Define data type (decomment the one needed)
// #define __UINT
// #define __INT
#define __FIXED
// #define __FLOAT

// Define bit width (decomment the one needed)
#ifndef __riscv
#define BITWIDTH 32
// #define BITWIDTH 64
#else
#define BITWIDTH 32
// #define BITWIDTH 64
#endif

/* End of user defined */

#ifdef __UINT
#if (BITWIDTH == 32)
typedef unsigned token_t;
#elif (BITWIDTH == 64)
typedef long long unsigned token_t;
#endif
#endif

#ifdef __INT
#if (BITWIDTH == 32)
typedef int token_t;
#elif (BITWIDTH == 64)
typedef long long token_t;
#endif
#endif

#ifdef __FIXED
#if (BITWIDTH == 32)
typedef int token_t;
#define fx2float fixed32_to_float
#define float2fx float_to_fixed32
#define FX_IL 16
#elif (BITWIDTH == 64)
typedef long long token_t;
#define fx2float fixed64_to_double
#define float2fx double_to_fixed64
#define FX_IL 32
#endif
#endif

#ifdef __FLOAT
#if (BITWIDTH == 32)
typedef float token_t;
#elif (BITWIDTH == 64)
typedef double token_t;
#endif
#endif

#if (BITWIDTH == 32)
typedef float native_t;
#elif (BITWIDTH == 64)
typedef double native_t;
#endif

#define MAX_PRINTED_ERRORS 10


/* <<--params-def-->> */
#define N_CHANNELS 2
#define N_FILTERS 2
#define FILTER_HEIGHT 3
#define DILATION_H 1
#define STRIDE_W 1
#define PAD_W 1
#define FEATURE_MAP_HEIGHT 6
#define PAD_H 1
#define STRIDE_H 1
#define FILTER_WIDTH 3
#define DILATION_W 1
#define FEATURE_MAP_WIDTH 6

/* <<--params-->> */
const int32_t n_channels = N_CHANNELS;
const int32_t n_filters = N_FILTERS;
const int32_t filter_height = FILTER_HEIGHT;
const int32_t dilation_h = DILATION_H;
const int32_t stride_w = STRIDE_W;
const int32_t pad_w = PAD_W;
const int32_t feature_map_height = FEATURE_MAP_HEIGHT;
const int32_t pad_h = PAD_H;
const int32_t stride_h = STRIDE_H;
const int32_t filter_width = FILTER_WIDTH;
const int32_t dilation_w = DILATION_W;
const int32_t feature_map_width = FEATURE_MAP_WIDTH;

#define NACC 1

esp_thread_info_t cfg_000[] = {
	{
		.run = true,
		.devname = "conv2d.0",
		.type = conv2d,
		/* <<--descriptor-->> */
		.desc.conv2d_desc.n_channels = N_CHANNELS,
		.desc.conv2d_desc.n_filters = N_FILTERS,
		.desc.conv2d_desc.filter_height = FILTER_HEIGHT,
		.desc.conv2d_desc.dilation_h = DILATION_H,
		.desc.conv2d_desc.stride_w = STRIDE_W,
		.desc.conv2d_desc.pad_w = PAD_W,
		.desc.conv2d_desc.feature_map_height = FEATURE_MAP_HEIGHT,
		.desc.conv2d_desc.pad_h = PAD_H,
		.desc.conv2d_desc.stride_h = STRIDE_H,
		.desc.conv2d_desc.filter_width = FILTER_WIDTH,
		.desc.conv2d_desc.dilation_w = DILATION_W,
		.desc.conv2d_desc.feature_map_width = FEATURE_MAP_WIDTH,
		.desc.conv2d_desc.src_offset = 0,
		.desc.conv2d_desc.dst_offset = 0,
		.desc.conv2d_desc.esp.coherence = ACC_COH_NONE,
		.desc.conv2d_desc.esp.p2p_store = 0,
		.desc.conv2d_desc.esp.p2p_nsrcs = 0,
		.desc.conv2d_desc.esp.p2p_srcs = {"", "", "", ""},
	}
};

#endif /* __ESP_CFG_000_H__ */
