// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __AD03_CONF_INFO_HPP__
#define __AD03_CONF_INFO_HPP__

#include "esp_headers.hpp"

#define F_MODE 0
#define W_MODE 1
#define I_MODE 2

//
// Configuration parameters for the accelerator
//
struct conf_info_t {
    uint32_t mode;
    uint32_t batch;
};

#endif // __AD03_CONF_INFO_HPP__
