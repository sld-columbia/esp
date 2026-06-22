// Copyright (c) 2011-2025 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __CONF_INFO_HPP__
#define __CONF_INFO_HPP__

#pragma once

#include <sstream>
#include <ac_int.h>
#include <ac_fixed.h>
#include "mac_specs.hpp"
#include "auto_gen_port_info.h"

//
// Configuration parameters for the accelerator.
//

struct conf_info_t {

    /* <<--params-->> */
    int32_t mac_n;
    int32_t mac_vec;
    int32_t mac_len;

    AUTO_GEN_FIELD_METHODS(conf_info_t, (mac_n, mac_vec, mac_len))
};

#endif // __MAC_CONF_INFO_HPP__
