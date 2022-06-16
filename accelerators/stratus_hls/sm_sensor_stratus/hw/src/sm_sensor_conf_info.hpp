// Copyright (c) 2011-2022 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __SM_SENSOR_CONF_INFO_HPP__
#define __SM_SENSOR_CONF_INFO_HPP__

#include <systemc.h>

//
// Configuration parameters for the accelerator.
//
class conf_info_t
{
public:

    //
    // constructors
    //
    conf_info_t()
    {
        /* <<--ctor-->> */
        this->size = 1;
    }

    conf_info_t(
        /* <<--ctor-args-->> */
        int32_t size
        )
    {
        /* <<--ctor-custom-->> */
        this->size = size;
    }

    // equals operator
    inline bool operator==(const conf_info_t &rhs) const
    {
        /* <<--eq-->> */
        if (size != rhs.size) return false;
        return true;
    }

    // assignment operator
    inline conf_info_t& operator=(const conf_info_t& other)
    {
        /* <<--assign-->> */
        size = other.size;
        return *this;
    }

    // VCD dumping function
    friend void sc_trace(sc_trace_file *tf, const conf_info_t &v, const std::string &NAME)
    {}

    // redirection operator
    friend ostream& operator << (ostream& os, conf_info_t const &conf_info)
    {
        os << "{";
        /* <<--print-->> */
        os << "size = " << conf_info.size << "";
        os << "}";
        return os;
    }

        /* <<--params-->> */
        int32_t size;
};

#endif // __SM_SENSOR_CONF_INFO_HPP__
