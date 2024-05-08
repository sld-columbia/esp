// Copyright (c) 2011-2021 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef _CRYPTO_CXX_CATAPULT_H_
#define _CRYPTO_CXX_CATAPULT_H_

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

struct crypto_cxx_catapult_access {
    struct esp_access esp;
    /* <<--regs-->> */
    unsigned crypto_algo;
    unsigned encryption;
    unsigned sha1_in_bytes;
    unsigned sha2_in_bytes;
    unsigned sha2_out_bytes;
    unsigned aes_oper_mode;
    unsigned aes_key_bytes;
    unsigned aes_input_bytes;
    unsigned aes_iv_bytes;
    unsigned aes_aad_bytes;
    unsigned aes_tag_bytes;
    unsigned src_offset;
    unsigned dst_offset;
};

#define CRYPTO_CXX_CATAPULT_IOC_ACCESS _IOW('S', 0, struct crypto_cxx_catapult_access)

#endif /* _CRYPTO_CXX_CATAPULT_H_ */
