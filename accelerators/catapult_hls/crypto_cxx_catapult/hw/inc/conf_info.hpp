// Copyright (c) 2011-2021 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __CONF_INFO_HPP__
#define __CONF_INFO_HPP__

#include "esp_headers.hpp"

//
// Configuration parameters for the accelerator
//
struct conf_info_t {
    // aes
    uint32 aes_tag_bytes;
    uint32 aes_aad_bytes;
    uint32 aes_iv_bytes;
    uint32 aes_in_bytes;
    uint32 aes_key_bytes;
    // uint32 aes_encryption;
    uint32 aes_oper_mode;
    // sha2
    uint32 sha2_out_bytes;
    uint32 sha2_in_bytes;
    // sha1
    uint32 sha1_in_bytes;
    // global
    uint32 encryption;
    uint32 crypto_algo;
};

#endif // __CONF_INFO_HPP__
