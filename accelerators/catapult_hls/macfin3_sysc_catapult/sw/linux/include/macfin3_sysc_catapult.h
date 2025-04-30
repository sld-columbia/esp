// Copyright (c) 2011-2025 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef _MACFIN_SYSC_CATAPULT_H_
#define _MACFIN_SYSC_CATAPULT_H_

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

struct macfin3_sysc_catapult_access {
    struct esp_access esp;
    /* <<--regs-->> */
	unsigned mac_n;
	unsigned mac_vec;
	unsigned mac_len;
    unsigned src_offset;
    unsigned dst_offset;
};

#define MACFIN_SYSC_CATAPULT_IOC_ACCESS _IOW('S', 0, struct macfin3_sysc_catapult_access)

#endif /* _MACFIN_SYSC_CATAPULT_H_ */
