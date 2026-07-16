// Copyright (c) 2011-2026 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef _SQR_BAMBU_H_
#define _SQR_BAMBU_H_

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

struct sqr_bambu_access {
    struct esp_access esp;
    /* <<--regs-->> */
    unsigned size;
    unsigned src_offset;
    unsigned dst_offset;
};

#define SQR_BAMBU_IOC_ACCESS _IOW('S', 0, struct sqr_bambu_access)

#endif /* _SQR_BAMBU_H_ */
