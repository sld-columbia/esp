// Copyright (c) 2011-2021 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef _SENSOR_DMA_STRATUS_H_
#define _SENSOR_DMA_STRATUS_H_

#ifdef __KERNEL__
#include <linux/ioctl.h>
#include <linux/types.h>
#else
#include <sys/ioctl.h>
#include <stdint.h>
#ifndef __user
#define __user
#endif
#endif /* __KERNEL__ */

#include <esp.h>
#include <esp_accelerator.h>

struct sensor_dma_stratus_access {
	struct esp_access esp;
	/* <<--regs-->> */
	unsigned rd_sp_offset;
	unsigned rd_wr_enable;
	unsigned wr_size;
	unsigned wr_sp_offset;
	unsigned rd_size;
	unsigned dst_offset;
	unsigned src_offset;
	unsigned src_offset;
	unsigned dst_offset;
};

#define SENSOR_DMA_STRATUS_IOC_ACCESS	_IOW ('S', 0, struct sensor_dma_stratus_access)

#endif /* _SENSOR_DMA_STRATUS_H_ */
