// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __SPMV_CONF_INFO_HPP__
#define __SPMV_CONF_INFO_HPP__

#include <systemc.h>

//
// Configuration parameters for the accelerator.
//
class conf_info_t
{
public:
    // Rows of input matrix. Rows of output vector.
    uint32_t nrows; // Powers of 2
    // Cols of input matrix. Cols of input vector.
    uint32_t ncols; // Powers of 2
    // Max of non-zero entries in a matrix row.
    uint32_t max_nonzero; // 4, 8, 16 or 32
    // Number of total nonzero matrix elements
    uint32_t mtx_len; // Stored in .data input file
    // PLM size to be used for values. All other sizes are derived
    uint32_t vals_plm_size; // Max is 1024
    // 'True' is the vector size fits the vector PLM and if it should be stored there
    uint32_t vect_fits_plm; // Set to false if ncols < 8192

    //
    // constructors
    //
    conf_info_t()
	: nrows(0)
	, ncols(0)
	, max_nonzero(0)
	, mtx_len(0)
	, vals_plm_size(0)
	, vect_fits_plm(0)
	{}

    conf_info_t(
	uint32_t r,
	uint32_t c,
	uint32_t max,
	uint32_t mtx_len,
	uint32_t vals_plm_size,
	bool     vect_fits_plm)
	: nrows(r)
	, ncols(c)
	, max_nonzero(max)
	, mtx_len(mtx_len)
	, vals_plm_size(vals_plm_size)
	, vect_fits_plm(vect_fits_plm)
	{}

    // equals operator
    inline bool operator==(const conf_info_t &rhs) const
	{
	    return (rhs.nrows == nrows)
		&& (rhs.ncols == ncols)
		&& (rhs.max_nonzero == max_nonzero)
		&& (rhs.mtx_len == mtx_len)
		&& (rhs.vals_plm_size == vals_plm_size)
		&& (rhs.vect_fits_plm == vect_fits_plm);
	}

    // assignment operator
    inline conf_info_t& operator=(const conf_info_t& other)
	{
	    nrows = other.nrows;
	    ncols = other.ncols;
	    max_nonzero = other.max_nonzero;
	    mtx_len = other.mtx_len;
	    vals_plm_size = other.vals_plm_size;
	    vect_fits_plm = other.vect_fits_plm;
	    return *this;
	}

    // VCD dumping function
    friend void sc_trace(sc_trace_file *tf, const conf_info_t &v, const std::string &NAME)
	{}

    // redirection operator
    friend ostream& operator << (ostream& os, conf_info_t const &conf_info)
	{
	    os << "{ nrows = " << conf_info.nrows
	       << ", ncols = " << conf_info.ncols
	       << ", mtx_len = " << conf_info.mtx_len
	       << ", vals_plm_size = " << conf_info.vals_plm_size
	       << ", vect_fits_plm = " << conf_info.vect_fits_plm
	       << "}";
	    return os;
	}
};

#endif // __SPMV_CONF_INFO_HPP__
