// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __CONV2D_CONF_INFO_HPP__
#define __CONV2D_CONF_INFO_HPP__

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
        this->n_channels = 1;
        this->n_filters = 1;
        this->filter_height = 1;
        this->dilation_h = 1;
        this->stride_w = 1;
        this->pad_w = 1;
        this->feature_map_height = 1;
        this->pad_h = 1;
        this->stride_h = 1;
        this->filter_width = 1;
        this->dilation_w = 1;
        this->feature_map_width = 1;
    }

    conf_info_t(
        /* <<--ctor-args-->> */
        int32_t n_channels, 
        int32_t n_filters, 
        int32_t filter_height, 
        int32_t dilation_h, 
        int32_t stride_w, 
        int32_t pad_w, 
        int32_t feature_map_height, 
        int32_t pad_h, 
        int32_t stride_h, 
        int32_t filter_width, 
        int32_t dilation_w, 
        int32_t feature_map_width
        )
    {
        /* <<--ctor-custom-->> */
        this->n_channels = n_channels;
        this->n_filters = n_filters;
        this->filter_height = filter_height;
        this->dilation_h = dilation_h;
        this->stride_w = stride_w;
        this->pad_w = pad_w;
        this->feature_map_height = feature_map_height;
        this->pad_h = pad_h;
        this->stride_h = stride_h;
        this->filter_width = filter_width;
        this->dilation_w = dilation_w;
        this->feature_map_width = feature_map_width;
    }

    // equals operator
    inline bool operator==(const conf_info_t &rhs) const
    {
        /* <<--eq-->> */
        if (n_channels != rhs.n_channels) return false;
        if (n_filters != rhs.n_filters) return false;
        if (filter_height != rhs.filter_height) return false;
        if (dilation_h != rhs.dilation_h) return false;
        if (stride_w != rhs.stride_w) return false;
        if (pad_w != rhs.pad_w) return false;
        if (feature_map_height != rhs.feature_map_height) return false;
        if (pad_h != rhs.pad_h) return false;
        if (stride_h != rhs.stride_h) return false;
        if (filter_width != rhs.filter_width) return false;
        if (dilation_w != rhs.dilation_w) return false;
        if (feature_map_width != rhs.feature_map_width) return false;
        return true;
    }

    // assignment operator
    inline conf_info_t& operator=(const conf_info_t& other)
    {
        /* <<--assign-->> */
        n_channels = other.n_channels;
        n_filters = other.n_filters;
        filter_height = other.filter_height;
        dilation_h = other.dilation_h;
        stride_w = other.stride_w;
        pad_w = other.pad_w;
        feature_map_height = other.feature_map_height;
        pad_h = other.pad_h;
        stride_h = other.stride_h;
        filter_width = other.filter_width;
        dilation_w = other.dilation_w;
        feature_map_width = other.feature_map_width;
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
        os << "n_channels = " << conf_info.n_channels << ", ";
        os << "n_filters = " << conf_info.n_filters << ", ";
        os << "filter_height = " << conf_info.filter_height << ", ";
        os << "dilation_h = " << conf_info.dilation_h << ", ";
        os << "stride_w = " << conf_info.stride_w << ", ";
        os << "pad_w = " << conf_info.pad_w << ", ";
        os << "feature_map_height = " << conf_info.feature_map_height << ", ";
        os << "pad_h = " << conf_info.pad_h << ", ";
        os << "stride_h = " << conf_info.stride_h << ", ";
        os << "filter_width = " << conf_info.filter_width << ", ";
        os << "dilation_w = " << conf_info.dilation_w << ", ";
        os << "feature_map_width = " << conf_info.feature_map_width << "";
        os << "}";
        return os;
    }

        /* <<--params-->> */
        int32_t n_channels;
        int32_t n_filters;
        int32_t filter_height;
        int32_t dilation_h;
        int32_t stride_w;
        int32_t pad_w;
        int32_t feature_map_height;
        int32_t pad_h;
        int32_t stride_h;
        int32_t filter_width;
        int32_t dilation_w;
        int32_t feature_map_width;
};

#endif // __CONV2D_CONF_INFO_HPP__
