// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef _FFT_CHISEL_H_
#define _FFT_CHISEL_H_

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

struct fft_chisel_access {
	struct esp_access esp;
	/* <<--regs-->> */
	unsigned stride;
	unsigned src_offset;
	unsigned dst_offset;
};

#define FFT_CHISEL_IOC_ACCESS	_IOW ('S', 0, struct fft_chisel_access)

#endif /* _FFT_CHISEL_H_ */
