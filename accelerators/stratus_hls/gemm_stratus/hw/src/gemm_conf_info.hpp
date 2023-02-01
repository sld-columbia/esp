// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __GEMM_CONF_INFO_HPP__
#define __GEMM_CONF_INFO_HPP__

#include <systemc.h>

//
// Configuration parameters for the accelerator.
//
class conf_info_t
{

public:

    //
    // variables
    //

    uint32_t ninputs;    // Number of inputs
    uint32_t d1;         // Size d1 of the matrix 1
    uint32_t d2;         // Size d2 of the matrix 1
    uint32_t d3;         // Size d2 of the matrix 2
    uint32_t ld_offset1; // Input offset (matrix 1)
    uint32_t ld_offset2; // Input offset (matrix 2)
    uint32_t st_offset;  // Output offset
    uint32_t do_relu; // Do ReLU stage
    uint32_t transpose; // True if matrix 2 is transposed

    //
    // constructors
    //

    conf_info_t()
            : ninputs(0)
	    , d1(0)
            , d2(0)
            , d3(0)
            , ld_offset1(0)
            , ld_offset2(0)
            , st_offset(0)
	    , do_relu(0)
	    , transpose(0)
	{}

    // equals operator
    inline bool operator==(const conf_info_t &rhs) const
	{
            return (rhs.ninputs == ninputs)
		&& (rhs.d1 == d1)
                && (rhs.d2 == d2)
                && (rhs.d3 == d3)
                && (rhs.ld_offset1 == ld_offset1)
                && (rhs.ld_offset2 == ld_offset2)
                && (rhs.st_offset == st_offset)
		&& (rhs.do_relu == do_relu)
		&& (rhs.transpose == transpose);
	}

    // assignment operator
    inline conf_info_t& operator=(const conf_info_t& other)
	{
            ninputs = other.ninputs;
            d1 = other.d1;
            d2 = other.d2;
            d3 = other.d3;
            ld_offset1 = other.ld_offset1;
            ld_offset2 = other.ld_offset2;
            st_offset = other.st_offset;
            do_relu = other.do_relu;
	    transpose = other.transpose;
            return *this;
	}

    // VCD dumping function
    friend void sc_trace(sc_trace_file *tf, const conf_info_t &v, const std::string &NAME)
	{
            // Note: not supported
	}

    // redirection operator
    friend ostream& operator << (ostream& os, conf_info_t const &conf_info)
	{
           // Note: not supported
	    os << "";
	    return os;
	}
};

#endif // __GEMM_CONF_INFO_HPP__
