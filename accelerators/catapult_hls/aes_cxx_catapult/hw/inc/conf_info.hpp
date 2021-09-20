// Copyright (c) 2011-2021 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __CONF_INFO_HPP__
#define __CONF_INFO_HPP__

#include "esp_headers.hpp"

//
// Configuration parameters for the accelerator
//
struct conf_info_t {
    uint32_t tag_bytes;
    uint32_t aad_bytes;
    uint32_t iv_bytes;
    uint32_t in_bytes;
    uint32_t key_bytes;
    uint32_t encryption;
    uint32_t oper_mode;
};

#endif // __CONF_INFO_HPP__
