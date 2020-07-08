// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __CHOLESKY_SMALL_CONF_INFO_HPP__
#define __CHOLESKY_SMALL_CONF_INFO_HPP__

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
        this->input_rows = 4;
        this->output_rows = 4;
    }

    conf_info_t(
        /* <<--ctor-args-->> */
        int32_t input_rows, 
        int32_t output_rows
        )
    {
        /* <<--ctor-custom-->> */
        this->input_rows = input_rows;
        this->output_rows = output_rows;
    }

    // equals operator
    inline bool operator==(const conf_info_t &rhs) const
    {
        /* <<--eq-->> */
        if (input_rows != rhs.input_rows) return false;
        if (output_rows != rhs.output_rows) return false;
        return true;
    }

    // assignment operator
    inline conf_info_t& operator=(const conf_info_t& other)
    {
        /* <<--assign-->> */
        input_rows = other.input_rows;
        output_rows = other.output_rows;
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
        os << "input_rows = " << conf_info.input_rows << ", ";
        os << "output_rows = " << conf_info.output_rows << "";
        os << "}";
        return os;
    }

        /* <<--params-->> */
        int32_t input_rows;
        int32_t output_rows;
};

#endif // __CHOLESKY_SMALL_CONF_INFO_HPP__
