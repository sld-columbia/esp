// Copyright (c) 2011-2021 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __SENSOR_DMA_CONF_INFO_HPP__
#define __SENSOR_DMA_CONF_INFO_HPP__

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
        this->rd_sp_offset = 1;
        this->rd_wr_enable = 0;
        this->wr_size = 1;
        this->wr_sp_offset = 1;
        this->rd_size = 1;
        this->dst_offset = 1;
        this->src_offset = 1;
    }

    conf_info_t(
        /* <<--ctor-args-->> */
        int32_t rd_sp_offset, 
        int32_t rd_wr_enable, 
        int32_t wr_size, 
        int32_t wr_sp_offset, 
        int32_t rd_size, 
        int32_t dst_offset, 
        int32_t src_offset
        )
    {
        /* <<--ctor-custom-->> */
        this->rd_sp_offset = rd_sp_offset;
        this->rd_wr_enable = rd_wr_enable;
        this->wr_size = wr_size;
        this->wr_sp_offset = wr_sp_offset;
        this->rd_size = rd_size;
        this->dst_offset = dst_offset;
        this->src_offset = src_offset;
    }

    // equals operator
    inline bool operator==(const conf_info_t &rhs) const
    {
        /* <<--eq-->> */
        if (rd_sp_offset != rhs.rd_sp_offset) return false;
        if (rd_wr_enable != rhs.rd_wr_enable) return false;
        if (wr_size != rhs.wr_size) return false;
        if (wr_sp_offset != rhs.wr_sp_offset) return false;
        if (rd_size != rhs.rd_size) return false;
        if (dst_offset != rhs.dst_offset) return false;
        if (src_offset != rhs.src_offset) return false;
        return true;
    }

    // assignment operator
    inline conf_info_t& operator=(const conf_info_t& other)
    {
        /* <<--assign-->> */
        rd_sp_offset = other.rd_sp_offset;
        rd_wr_enable = other.rd_wr_enable;
        wr_size = other.wr_size;
        wr_sp_offset = other.wr_sp_offset;
        rd_size = other.rd_size;
        dst_offset = other.dst_offset;
        src_offset = other.src_offset;
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
        os << "rd_sp_offset = " << conf_info.rd_sp_offset << ", ";
        os << "rd_wr_enable = " << conf_info.rd_wr_enable << ", ";
        os << "wr_size = " << conf_info.wr_size << ", ";
        os << "wr_sp_offset = " << conf_info.wr_sp_offset << ", ";
        os << "rd_size = " << conf_info.rd_size << ", ";
        os << "dst_offset = " << conf_info.dst_offset << ", ";
        os << "src_offset = " << conf_info.src_offset << "";
        os << "}";
        return os;
    }

        /* <<--params-->> */
        int32_t rd_sp_offset;
        int32_t rd_wr_enable;
        int32_t wr_size;
        int32_t wr_sp_offset;
        int32_t rd_size;
        int32_t dst_offset;
        int32_t src_offset;
};

#endif // __SENSOR_DMA_CONF_INFO_HPP__
