// Copyright (c) 2011-2025 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __CONF_INFO_HPP__
#define __CONF_INFO_HPP__

#pragma once

#include <sstream>
#include <ac_int.h>
#include <ac_fixed.h>
#include "macfin2_specs.hpp"
#include "macfin2_data_types.hpp"
#include "auto_gen_port_info.h"

//
// Configuration parameters for the accelerator.
//
// struct wr_data {

//     /* <<--params-->> */
//         int32_t addr;
//         FPDATA_WORD data;

//     AUTO_GEN_FIELD_METHODS(wr_data,
//                            (/* <<--params1-->> */
//           addr ,  \ 
//           data  \ 
//                             ))
// }


// struct read_data {

//     nvhls::nv_scvector<FPDATA_WORD, 2> op;
//     // FPDATA_WORD op[2];

//     AUTO_GEN_FIELD_METHODS(read_data,
//                            (/* <<--params1-->> */
//           op  \ 
//                             ))
// }


struct read_data {

    // nvhls::nv_scvector<FPDATA_WORD, 2> data;
    FPDATA_WORD data[2];

    AUTO_GEN_FIELD_METHODS(read_data,
                           (data  \
                               ))
};

struct conf_info_t {

    /* <<--params-->> */
        int32_t mac_n;
        int32_t mac_vec;
        int32_t mac_len;

    AUTO_GEN_FIELD_METHODS(conf_info_t,
                           (/* <<--params1-->> */
          mac_n ,  \ 
          mac_vec ,  \ 
          mac_len  \ 
                            ))
};

#endif // __MAC_CONF_INFO_HPP__
