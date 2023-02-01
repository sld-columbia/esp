// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __CHOLESKY_CONF_INFO_HPP__
#define __CHOLESKY_CONF_INFO_HPP__

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
        this->rows = 8;
    }

    conf_info_t(
        /* <<--ctor-args-->> */
        int32_t rows
    )
    {
        /* <<--ctor-custom-->> */
        this->rows = rows;
    }

    // equals operator
    inline bool operator==(const conf_info_t &rhs) const
    {
        /* <<--eq-->> */
        if (rows != rhs.rows) return false;
        return true;
    }

    // assignment operator
    inline conf_info_t& operator=(const conf_info_t& other)
    {
        /* <<--assign-->> */
        rows = other.rows;
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
        os << "rows = " << conf_info.rows << ", ";
        os << "}";
        return os;
    }

        /* <<--params-->> */
        int32_t rows;
};

#endif // __CHOLESKY_CONF_INFO_HPP__
