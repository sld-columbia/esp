// Copyright (c) 2011-2021 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __CONF_INFO_HPP__
#define __CONF_INFO_HPP__

#include "esp_headers.hpp"

//
// Configuration parameters for the accelerator
//
struct conf_info_t {
    uint32 in_bytes;
    uint32 e_bytes;
    uint32 n_bytes;
    uint32 pubpriv;
    uint32 padding;
    uint32 encryption;
};

#endif // __CONF_INFO_HPP__
