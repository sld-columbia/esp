// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __FFT_CONF_INFO_HPP__
#define __FFT_CONF_INFO_HPP__

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
        this->len = 8;
        this->log_len = 3;
    }

    conf_info_t(
        /* <<--ctor-args-->> */
        int32_t len, 
        int32_t log_len
        )
    {
        /* <<--ctor-custom-->> */
        this->len = len;
        this->log_len = log_len;
    }

    // equals operator
    inline bool operator==(const conf_info_t &rhs) const
    {
        /* <<--eq-->> */
        if (len != rhs.len) return false;
        if (log_len != rhs.log_len) return false;
        return true;
    }

    // assignment operator
    inline conf_info_t& operator=(const conf_info_t& other)
    {
        /* <<--assign-->> */
        len = other.len;
        log_len = other.log_len;
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
        os << "len = " << conf_info.len << ", ";
        os << "log_len = " << conf_info.log_len << "";
        os << "}";
        return os;
    }

        /* <<--params-->> */
        int32_t len;
        int32_t log_len;
};

#endif // __FFT_CONF_INFO_HPP__
