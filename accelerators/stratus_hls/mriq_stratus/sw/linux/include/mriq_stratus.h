// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef _MRIQ_STRATUS_H_
#define _MRIQ_STRATUS_H_

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

struct mriq_stratus_access {
	struct esp_access esp;
	/* <<--regs-->> */
	unsigned num_batch_k;
	unsigned batch_size_k;
	unsigned num_batch_x;
	unsigned batch_size_x;
	unsigned src_offset;
	unsigned dst_offset;
};

#define MRIQ_STRATUS_IOC_ACCESS	_IOW ('S', 0, struct mriq_stratus_access)

#endif /* _MRIQ_STRATUS_H_ */
