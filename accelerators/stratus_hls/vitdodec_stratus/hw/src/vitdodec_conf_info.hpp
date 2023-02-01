// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __VITDODEC_CONF_INFO_HPP__
#define __VITDODEC_CONF_INFO_HPP__

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
        this->cbps = 48;
        this->ntraceback = 5;
        this->data_bits = 288;
    }

    conf_info_t(
        /* <<--ctor-args-->> */
        int32_t cbps, 
        int32_t ntraceback, 
        int32_t data_bits
        )
    {
        /* <<--ctor-custom-->> */
        this->cbps = cbps;
        this->ntraceback = ntraceback;
        this->data_bits = data_bits;
    }

    // equals operator
    inline bool operator==(const conf_info_t &rhs) const
    {
        /* <<--eq-->> */
        if (cbps != rhs.cbps) return false;
        if (ntraceback != rhs.ntraceback) return false;
        if (data_bits != rhs.data_bits) return false;
        return true;
    }

    // assignment operator
    inline conf_info_t& operator=(const conf_info_t& other)
    {
        /* <<--assign-->> */
        cbps = other.cbps;
        ntraceback = other.ntraceback;
        data_bits = other.data_bits;
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
        os << "cbps = " << conf_info.cbps << ", ";
        os << "ntraceback = " << conf_info.ntraceback << ", ";
        os << "data_bits = " << conf_info.data_bits << "";
        os << "}";
        return os;
    }

        /* <<--params-->> */
        int32_t cbps;
        int32_t ntraceback;
        int32_t data_bits;
};

#endif // __VITDODEC_CONF_INFO_HPP__
