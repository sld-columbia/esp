// Copyright (c) 2011-2024 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef _LEAKYRELU_SYSC_CATAPULT_H_
#define _LEAKYRELU_SYSC_CATAPULT_H_

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

struct leakyrelu_sysc_catapult_access {
	struct esp_access esp;
	/* <<--regs-->> */
	unsigned batch;
	unsigned row;
	unsigned addrA;
	unsigned addrB;
	unsigned addrO;
	unsigned src_offset;
	unsigned dst_offset;
};

#define LEAKYRELU_SYSC_CATAPULT_IOC_ACCESS	_IOW ('S', 0, struct leakyrelu_sysc_catapult_access)

#endif /* _LEAKYRELU_SYSC_CATAPULT_H_ */
