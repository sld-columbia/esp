// Copyright (c) 2011-2025 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef __ESP_CFG_000_H__
#define __ESP_CFG_000_H__

#include "libesp.h"
#include "crypto_cxx_catapult.h"

typedef uint32_t token_t;
typedef uint32_t native_t;

/* <<--params-def-->> */

/* <<--params-->> */

#define NACC 1

struct crypto_cxx_catapult_access crypto_cfg_000[] = {{
    /* <<--descriptor-->> */
    .crypto_algo     = 0,
    .encryption      = 0,
    .sha1_in_bytes   = 0,
    .sha2_in_bytes   = 0,
    .sha2_out_bytes  = 0,
    .aes_oper_mode   = 0,
    .aes_key_bytes   = 0,
    .aes_input_bytes = 0,
    .aes_iv_bytes    = 0,
    .aes_aad_bytes   = 0,
    .aes_tag_bytes   = 0,
    .src_offset      = 0,
    .dst_offset      = 0,
    .src_offset      = 0,
    .dst_offset      = 0,
    .esp.coherence   = ACC_COH_RECALL,
    .esp.p2p_store   = 0,
    .esp.p2p_nsrcs   = 0,
    .esp.p2p_srcs    = {"", "", "", ""},
}};

esp_thread_info_t cfg_000[] = {{
    .run       = true,
    .devname   = "crypto_cxx_catapult.0",
    .ioctl_req = CRYPTO_CXX_CATAPULT_IOC_ACCESS,
    .esp_desc  = &(crypto_cfg_000[0].esp),
}};

#endif /* __ESP_CFG_000_H__ */
