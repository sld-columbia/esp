// Copyright (c) 2011-2024 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef _MAC_SYSC_CATAPULT_H_
#define _MAC_SYSC_CATAPULT_H_

#ifdef __KERNEL__
    #include <linux/ioctl.h>
    #include <linux/types.h>
#else
    #include <stdint.h>
    #include <sys/ioctl.h>
    #ifndef __user
        #define __user
    #endif
#endif /* __KERNEL__ */

#include <esp.h>
#include <esp_accelerator.h>

struct mac_sysc_catapult_access {
    struct esp_access esp;
    /* <<--regs-->> */
    unsigned mac_n;
    unsigned mac_vec;
    unsigned mac_len;
    unsigned src_offset;
    unsigned dst_offset;
};

#define MAC_SYSC_CATAPULT_IOC_ACCESS _IOW('S', 0, struct mac_sysc_catapult_access)

#endif /* _MAC_SYSC_CATAPULT_H_ */
