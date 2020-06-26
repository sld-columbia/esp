#ifndef __ESP_CFG_000_H__
#define __ESP_CFG_000_H__

#include "libesp.h"

typedef int32_t token_t;

/* <<--params-def-->> */
#define N_CHANNELS 1
#define N_FILTERS 1
#define FILTER_HEIGHT 1
#define DILATION_H 1
#define STRIDE_W 1
#define PAD_W 1
#define FEATURE_MAP_HEIGHT 1
#define PAD_H 1
#define STRIDE_H 1
#define FILTER_WIDTH 1
#define DILATION_W 1
#define FEATURE_MAP_WIDTH 1

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
