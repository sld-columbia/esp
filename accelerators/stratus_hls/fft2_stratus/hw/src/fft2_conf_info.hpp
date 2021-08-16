// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __FFT2_CONF_INFO_HPP__
#define __FFT2_CONF_INFO_HPP__

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
        this->logn_samples = 6;
        this->num_ffts = 1;
        this->do_inverse = 0;
        this->do_shift = 0;
        this->scale_factor = 1;
    }

    conf_info_t(
        /* <<--ctor-args-->> */
        int32_t logn_samples,
        int32_t num_ffts,
        int32_t do_inverse,
        int32_t do_shift,
        int32_t scale_factor
        )
    {
        /* <<--ctor-custom-->> */
        this->logn_samples = logn_samples;
        this->num_ffts   = num_ffts;
        this->do_inverse = do_inverse;
        this->do_shift   = do_shift;
        this->scale_factor = scale_factor;
    }

    // equals operator
    inline bool operator==(const conf_info_t &rhs) const
    {
        /* <<--eq-->> */
        if (logn_samples != rhs.logn_samples) return false;
        if (num_ffts != rhs.num_ffts) return false;
        if (do_inverse != rhs.do_inverse) return false;
        if (do_shift != rhs.do_shift) return false;
        if (scale_factor != rhs.scale_factor) return false;
        return true;
    }

    // assignment operator
    inline conf_info_t& operator=(const conf_info_t& other)
    {
        /* <<--assign-->> */
        logn_samples = other.logn_samples;
        num_ffts = other.num_ffts;
        do_inverse = other.do_inverse;
        do_shift = other.do_shift;
        scale_factor = other.scale_factor;
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
        os << "logn_samples = " << conf_info.logn_samples << ", ";
        os << "num_ffts = " << conf_info.num_ffts << ", ";
        os << "do_inverse = " << conf_info.do_inverse << ", ";
        os << "do_shift = " << conf_info.do_shift << ", ";
        os << "scale_factor = " << conf_info.scale_factor << "";
        os << "}";
        return os;
    }

    /* <<--params-->> */
    int32_t logn_samples;
    int32_t num_ffts;
    int32_t do_inverse;
    int32_t do_shift;
    int32_t scale_factor;
};

#endif // __FFT2_CONF_INFO_HPP__
