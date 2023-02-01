// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef _<ACC_FULL_NAME>_H_
#define _<ACC_FULL_NAME>_H_

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

struct <acc_full_name>_access {
	struct esp_access esp;
	/* <<--regs-->> */
	unsigned src_offset;
	unsigned dst_offset;
};

#define <ACC_FULL_NAME>_IOC_ACCESS	_IOW ('S', 0, struct <acc_full_name>_access)

#endif /* _<ACC_FULL_NAME>_H_ */
