// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __CONF_INFO_HPP__
#define __CONF_INFO_HPP__

#pragma once

#include <sstream>
#include <ac_int.h>
#include <ac_fixed.h>
#include "<accelerator_name>_specs.hpp"

//
// Configuration parameters for the accelerator.
//

struct conf_info_t
{

    /* <<--params-->> */

    static const unsigned int width = 32*/* <<--nparam-->> */;
    template <unsigned int Size> void Marshall(Marshaller <Size> &m) {
        /* <<--marsh-->> */
    }

    //
    // constructors
    //
    conf_info_t()
    {
        /* <<--ctor-->> */
    }

    conf_info_t(
        /* <<--ctor-args-->> */
        )
    {
        /* <<--ctor-custom-->> */
    }

    // VCD dumping function
   inline friend void sc_trace(sc_trace_file *tf, const conf_info_t &v, const std::string &NAME)
    {
        /* <<--sctrc-->> */

        // sc_trace(tf,v.mac_n,  NAME + ".mac_n");
        // sc_trace(tf,v.mac_length,  NAME + ".mac_length");
        // sc_trace(tf,v.mac_vec,  NAME + ".mac_vec");
    }

    // redirection operator
    friend ostream& operator << (ostream& os, conf_info_t const &conf_info)
    {
        os << "{";
        /* <<--print-->> */
        // os << "mac_n = " << conf_info.mac_n << ", ";
        // os << "mac_length = " << conf_info.mac_length << ", ";
        // os << "mac_vec = " << conf_info.mac_vec << ", ";
        os << "}";
        return os;
    }

};

#endif // __MAC_CONF_INFO_HPP__
