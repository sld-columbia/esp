// Copyright (c) 2011-2021 Columbia University, System Level Design Group
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
        this->do_peak = 0;
        this->do_bitrev = 1;
        this->log_len = 3;
    }

    conf_info_t(
        /* <<--ctor-args-->> */
        int32_t do_peak,
        int32_t do_bitrev,
        int32_t log_len
        )
    {
        /* <<--ctor-custom-->> */
        this->do_peak = do_peak;
        this->do_bitrev = do_bitrev;
        this->log_len = log_len;
    }

    // equals operator
    inline bool operator==(const conf_info_t &rhs) const
    {
        /* <<--eq-->> */
        if (do_peak != rhs.do_peak) return false;
        if (do_bitrev != rhs.do_bitrev) return false;
        if (log_len != rhs.log_len) return false;
        return true;
    }

    // assignment operator
    inline conf_info_t& operator=(const conf_info_t& other)
    {
        /* <<--assign-->> */
        do_peak = other.do_peak;
        do_bitrev = other.do_bitrev;
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
        os << "do_peak = " << conf_info.do_peak << ", ";
        os << "do_bitrev = " << conf_info.do_bitrev << ", ";
        os << "log_len = " << conf_info.log_len << "";
        os << "}";
        return os;
    }

        /* <<--params-->> */
        int32_t do_peak;
        int32_t do_bitrev;
        int32_t log_len;
};

#endif // __FFT_CONF_INFO_HPP__
