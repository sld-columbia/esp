// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef _ADDER_CHISEL_H_
#define _ADDER_CHISEL_H_

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

struct adder_chisel_access {
	struct esp_access esp;
	/* <<--regs-->> */
	unsigned size;
	unsigned readAddr;
	unsigned writeAddr;
	unsigned src_offset;
	unsigned dst_offset;
};

#define ADDER_CHISEL_IOC_ACCESS	_IOW ('S', 0, struct adder_chisel_access)

#endif /* _ADDER_CHISEL_H_ */
