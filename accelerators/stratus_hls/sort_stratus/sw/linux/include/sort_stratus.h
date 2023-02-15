// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef _SORT_STRATUS_H_
#define _SORT_STRATUS_H_

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

struct sort_stratus_access {
	struct esp_access esp;
	unsigned int size;
	unsigned int batch;
};

#define SORT_STRATUS_IOC_ACCESS	_IOW ('S', 0, struct sort_stratus_access)

#endif /* _SORT_STRATUS_H_ */
