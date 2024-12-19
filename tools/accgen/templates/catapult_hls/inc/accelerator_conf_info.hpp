// Copyright (c) 2011-2024 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __CONF_INFO_HPP__
#define __CONF_INFO_HPP__

#pragma once

#include <sstream>
#include <ac_int.h>
#include <ac_fixed.h>
#include "<accelerator_name>_specs.hpp"
#include "auto_gen_port_info.h"

//
// Configuration parameters for the accelerator.
//

struct conf_info_t {

    /* <<--params-->> */

    AUTO_GEN_FIELD_METHODS(conf_info_t,
                           (/* <<--params1-->> */
                            ))
};

#endif // __MAC_CONF_INFO_HPP__
