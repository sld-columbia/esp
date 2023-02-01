// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef _NIGHTVISION_STRATUS_H_
#define _NIGHTVISION_STRATUS_H_

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

#define MAX_NIMAGES 10000
#define MAX_ROWS    2048
#define MAX_COLS    2048

struct nightvision_stratus_access {
    struct esp_access esp;
    // Number of images to be processed
    unsigned int nimages;
    // Rows of input matrix. Rows of output vector.
    unsigned int rows;
    // Cols of input matrix. Cols of input vector.
    unsigned int cols;
    // Enable/disable di DWT stage.
    unsigned int do_dwt;
    // Input offset (bytes) used for P2P setup
    unsigned src_offset;
    // Output offset (bytes) used for P2P setup
    unsigned dst_offset;
};

#define NIGHTVISION_STRATUS_IOC_ACCESS _IOW('S', 0, struct nightvision_stratus_access)

#endif /* _NIGHTVISION_STRATUS_H_ */
