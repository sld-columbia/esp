// Copyright (c) 2011-2021 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __CONF_INFO_HPP__
#define __CONF_INFO_HPP__

#include "esp_headers.hpp"

//
// Configuration parameters for the accelerator
//
struct conf_info_t {
    uint32_t in_bytes;
    uint32_t e_bytes;
    uint32_t n_bytes;
    uint32_t pubpriv;
    uint32_t padding;
    uint32_t encryption;
};

#endif // __CONF_INFO_HPP__
