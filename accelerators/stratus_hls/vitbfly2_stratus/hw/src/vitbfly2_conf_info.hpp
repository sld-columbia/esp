// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __VITBFLY2_CONF_INFO_HPP__
#define __VITBFLY2_CONF_INFO_HPP__

#include <systemc.h>

//
// Configuration parameters for the accelerator.
//
class conf_info_t
{
public:

    uint32_t unused;

    //
    // constructors
    //
    conf_info_t()
        : unused(0)
    {}

    conf_info_t(uint32_t u)
        : unused(u)
    {}

    // equals operator
    inline bool operator==(const conf_info_t &rhs) const
    {
        return (rhs.unused == unused);
    }

    // assignment operator
    inline conf_info_t& operator=(const conf_info_t& other)
    {
        unused = other.unused;
        return *this;
    }

    // VCD dumping function
    friend void sc_trace(sc_trace_file *tf, const conf_info_t &v, const std::string &NAME)
    {}

    // redirection operator
    friend ostream& operator << (ostream& os, conf_info_t const &conf_info)
    {
        os << "{ unused = " << conf_info.unused
           << "}";
        return os;
    }
};

#endif // __VITBFLY2_CONF_INFO_HPP__
