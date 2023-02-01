// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __DUMMY_CONF_INFO_HPP__
#define __DUMMY_CONF_INFO_HPP__

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
        : tokens(0)
        , batch(0)
    {}

    // equals operator
    inline bool operator==(const conf_info_t &rhs) const
    {
        return (tokens == rhs.tokens) && (batch == rhs.batch);
    }

    // assignment operator
    inline conf_info_t& operator=(const conf_info_t& other)
    {
        tokens = other.tokens;
        batch = other.batch;
        return *this;
    }

    // VCD dumping function
    friend void sc_trace(sc_trace_file *tf, const conf_info_t &v, const std::string &NAME)
    {}

    // redirection operator
    friend ostream& operator << (ostream& os, conf_info_t const &conf_info)
    {
        os << "{ tokens = " << conf_info.tokens
           << ", batch = "  << conf_info.batch
           << "}";
        return os;
    }

    uint32_t tokens;
    uint32_t batch;
};

#endif // __DUMMY_CONF_INFO_HPP__
