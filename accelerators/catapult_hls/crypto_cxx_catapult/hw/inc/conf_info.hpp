// Copyright (c) 2011-2021 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __CONF_INFO_HPP__
#define __CONF_INFO_HPP__

#include "esp_headers.hpp"

//
// Configuration parameters for the accelerator
//
struct conf_info_t {
    // rsa
    // aes
    // sha2
    uint32_t sha2_in_bytes;
    uint32_t sha2_out_bytes;
    // sha1
    uint32_t sha1_in_bytes;
    // global
    uint32_t crypto_algo;
};

#endif // __CONF_INFO_HPP__
