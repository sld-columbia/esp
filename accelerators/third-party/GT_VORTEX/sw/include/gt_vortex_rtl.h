// Copyright (c) 2011-2022 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef _GT_VORTEX_RTL_H_
#define _GT_VORTEX_RTL_H_

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

struct gt_vortex_rtl_access {
	struct esp_access esp;
	/* <<--regs-->> */
	unsigned VX_BUSY_INT;
	unsigned BASE_ADDR;
	unsigned START_VORTEX;
	unsigned src_offset;
	unsigned dst_offset;
};

#define GT_VORTEX_RTL_IOC_ACCESS	_IOW ('S', 0, struct gt_vortex_rtl_access)

#endif /* _GT_VORTEX_RTL_H_ */
