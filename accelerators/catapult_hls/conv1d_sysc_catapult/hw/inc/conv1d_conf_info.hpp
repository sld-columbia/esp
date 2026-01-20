// Copyright (c) 2011-2025 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __CONF_INFO_HPP__
#define __CONF_INFO_HPP__

#pragma once

#include <sstream>
#include <ac_int.h>
#include <ac_fixed.h>
#include "conv1d_specs.hpp"
#include "auto_gen_port_info.h"

//
// Configuration parameters for the accelerator.
//

struct conf_info_t {

    /* <<--params-->> */
        int32_t kernel_size;
        int32_t n_channels;
        int32_t stride;
        int32_t is_relu;
        // addr* are DATA_WIDTH word offsets into DMA memory.
        int32_t addrB;
        int32_t addrO;
        int32_t addrI;
        int32_t addrW;
        int32_t batch_size;
        int32_t n_filters;
        int32_t feature_map_len;
        int32_t padding;

    AUTO_GEN_FIELD_METHODS(conf_info_t,
                           (/* <<--params1-->> */
          kernel_size ,  \ 
          n_channels ,  \ 
          stride ,  \ 
          is_relu ,  \ 
          addrB ,  \ 
          addrO ,  \ 
          addrI ,  \ 
          addrW ,  \ 
          batch_size ,  \ 
          n_filters ,  \ 
          feature_map_len ,  \ 
          padding  \ 
                            ))
};

#endif // __MAC_CONF_INFO_HPP__
