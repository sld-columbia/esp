// Copyright (c) 2011-2025 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef _CONV1D_SYSC_CATAPULT_H_
#define _CONV1D_SYSC_CATAPULT_H_

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

struct conv1d_sysc_catapult_access {
    struct esp_access esp;
    /* <<--regs-->> */
	unsigned kernel_size;
	unsigned n_channels;
	unsigned stride;
	unsigned is_relu;
	unsigned addrB;
	unsigned addrO;
	unsigned addrI;
	unsigned addrW;
	unsigned batch_size;
	unsigned n_filters;
	unsigned feature_map_len;
	unsigned padding;
    unsigned src_offset;
    unsigned dst_offset;
};

#define CONV1D_SYSC_CATAPULT_IOC_ACCESS _IOW('S', 0, struct conv1d_sysc_catapult_access)

#endif /* _CONV1D_SYSC_CATAPULT_H_ */
