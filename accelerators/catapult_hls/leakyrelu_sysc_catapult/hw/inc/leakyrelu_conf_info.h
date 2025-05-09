// Copyright (c) 2011-2024 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __CONF_INFO_H__
#define __CONF_INFO_H__

#pragma once

#include <sstream>
#include <ac_int.h>
#include <ac_fixed.h>
#include "leakyrelu_specs.h"
#include "auto_gen_port_info.h"
#include "ac_enum.h"

//
// Configuration parameters for the accelerator.
//

struct conf_info_t
{

    /* <<--params-->> */
    int32_t batch;
    int32_t row;
    int32_t addrA;
    int32_t addrB;
    int32_t addrO;

    AUTO_GEN_FIELD_METHODS(conf_info_t, (\
            batch   \
        ,   row     \
        ,   addrA   \
        ,   addrB   \
        ,   addrO   \
    ))

};

template<typename T,int SIZE>
struct array_t
{
  
  T data[SIZE];

  AUTO_GEN_FIELD_METHODS(array_t, ( \
     data \
  ) )
};
#endif // __MAC_CONF_INFO_H__
