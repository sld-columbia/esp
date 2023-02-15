// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __SYNTH_CONF_INFO_HPP__
#define __SYNTH_CONF_INFO_HPP__

#include <systemc.h>

//
// Configuration parameters for the accelerator.
//
class conf_info_t
{
public:

    uint32_t in_size; // size of input dataset
    uint32_t out_size; // size of output dataset
    uint32_t access_factor; // accessed portion of dataset
    uint32_t burst_len; // dma burst length
    uint32_t compute_bound_factor; // words transferred per cycle
    uint32_t reuse_factor; // # of times the dataset is accessed
    uint32_t in_place; // output stored in place of input
    uint32_t pattern;
    uint32_t irregular_seed;
    uint32_t ld_st_ratio;
    uint32_t stride_len;
    uint32_t offset;
    uint32_t wr_data;
    uint32_t rd_data;
    //
    // constructors
    //
    conf_info_t()
	: in_size(0)
	, out_size(0)
	, access_factor(0)
	, burst_len(0)
	, compute_bound_factor(0)
	, reuse_factor(0)
	, in_place(0)
	, pattern(0)
	, irregular_seed(0)
	, ld_st_ratio(0)
	, stride_len(0)
	, offset(0)
    , wr_data(0)
	, rd_data(0)
    {}

    conf_info_t(
	uint32_t in_size,
	uint32_t out_size,
	uint32_t access_factor,
	uint32_t burst_len,
	uint32_t compute_bound_factor,
	uint32_t reuse_factor,
	uint32_t in_place,
	uint32_t pattern,
	uint32_t irregular_seed,
	uint32_t ld_st_ratio,
	uint32_t stride_len,
	uint32_t offset,
    uint32_t wr_data,
	uint32_t rd_data)
    : in_size(in_size)
	, out_size(out_size)
	, access_factor(access_factor)
	, burst_len(burst_len)
	, compute_bound_factor(compute_bound_factor)
	, reuse_factor(reuse_factor)
	, in_place(in_place)
	, pattern(pattern)
	, irregular_seed(irregular_seed)
	, ld_st_ratio(ld_st_ratio)
	, stride_len(stride_len)
	, offset(offset)
	, wr_data(wr_data)
    , rd_data(rd_data)
    {}

    // equals operator
    inline bool operator==(const conf_info_t &rhs) const
	{
	    return (rhs.in_size == in_size)
		&& (rhs.out_size == out_size)
		&& (rhs.access_factor == access_factor)
		&& (rhs.burst_len == burst_len)
		&& (rhs.compute_bound_factor == compute_bound_factor)
		&& (rhs.reuse_factor == reuse_factor)
		&& (rhs.in_place == in_place)
		&& (rhs.pattern == pattern)
		&& (rhs.irregular_seed == irregular_seed)
		&& (rhs.ld_st_ratio == ld_st_ratio)
		&& (rhs.stride_len == stride_len)
		&& (rhs.offset == offset)
	    && (rhs.wr_data == wr_data)
	    && (rhs.rd_data == rd_data);
    }

    // assignment operator
    inline conf_info_t& operator=(const conf_info_t& other)
	{
	    in_size = other.in_size;
	    out_size = other.out_size;
	    access_factor = other.access_factor;
	    burst_len = other.burst_len;
	    compute_bound_factor = other.compute_bound_factor;
	    reuse_factor = other.reuse_factor;
	    in_place = other.in_place;
	    pattern = other.pattern;
	    irregular_seed = other.irregular_seed;
	    ld_st_ratio = other.ld_st_ratio;
	    stride_len = other.stride_len;
	    offset = other.offset;
        wr_data = other.wr_data;
	    rd_data = other.rd_data;
        return *this;
	}

    // VCD dumping function
    friend void sc_trace(sc_trace_file *tf, const conf_info_t &v, const std::string &NAME)
	{}

    // redirection operator
    friend ostream& operator << (ostream& os, conf_info_t const &conf_info)
	{
	    os << "{ in_size = " << conf_info.in_size
	       << ", out_size = " << conf_info.out_size
	       << ", access_factor = " << conf_info.access_factor
	       << ", burst_len = " << conf_info.burst_len
	       << ", compute_bound_factor = " << conf_info.compute_bound_factor
	       << ", reuse_factor = " << conf_info.reuse_factor
	       << ", in_place = " << conf_info.in_place
	       << ", pattern = " << conf_info.pattern
	       << ", irregular_seed = " << conf_info.irregular_seed
	       << ", ld_st_ratio = " << conf_info.ld_st_ratio
	       << ", stride_len = " << conf_info.stride_len
	       << ", offset = " << conf_info.offset
	       << ", wr_data = " << conf_info.wr_data
           << ", rd_data = " << conf_info.rd_data
           << "}";
	    return os;
	}
};

#endif // __SYNTH_CONF_INFO_HPP__
