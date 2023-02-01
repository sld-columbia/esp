// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef _COUNTER_CHISEL_H_
#define _COUNTER_CHISEL_H_

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

struct counter_chisel_access {
	struct esp_access esp;
	unsigned int ticks;
};

#define COUNTER_CHISEL_IOC_ACCESS	_IOW ('S', 0, struct counter_chisel_access)

#endif /* _COUNTER_CHISEL_H_ */
