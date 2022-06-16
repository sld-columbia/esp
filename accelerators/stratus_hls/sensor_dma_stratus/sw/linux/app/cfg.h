// Copyright (c) 2011-2021 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef __ESP_CFG_000_H__
#define __ESP_CFG_000_H__

#include "libesp.h"
#include "sensor_dma_stratus.h"

typedef int64_t token_t;

/* <<--params-def-->> */
#define RD_SP_OFFSET 1
#define RD_WR_ENABLE 0
#define WR_SIZE 1
#define WR_SP_OFFSET 1
#define RD_SIZE 1
#define DST_OFFSET 1
#define SRC_OFFSET 1

/* <<--params-->> */
const int32_t rd_sp_offset = RD_SP_OFFSET;
const int32_t rd_wr_enable = RD_WR_ENABLE;
const int32_t wr_size = WR_SIZE;
const int32_t wr_sp_offset = WR_SP_OFFSET;
const int32_t rd_size = RD_SIZE;
const int32_t dst_offset = DST_OFFSET;
const int32_t src_offset = SRC_OFFSET;

#define NACC 1

struct sensor_dma_stratus_access sensor_dma_cfg_000[] = {
	{
		/* <<--descriptor-->> */
		.rd_sp_offset = RD_SP_OFFSET,
		.rd_wr_enable = RD_WR_ENABLE,
		.wr_size = WR_SIZE,
		.wr_sp_offset = WR_SP_OFFSET,
		.rd_size = RD_SIZE,
		.dst_offset = DST_OFFSET,
		.src_offset = SRC_OFFSET,
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
		.devname = "sensor_dma_stratus.0",
		.ioctl_req = SENSOR_DMA_STRATUS_IOC_ACCESS,
		.esp_desc = &(sensor_dma_cfg_000[0].esp),
	}
};

#endif /* __ESP_CFG_000_H__ */
