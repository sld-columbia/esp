/* Copyright 2017 Columbia University, SLD Group */

#ifndef __SPMV_CONF_INFO_HPP__
#define __SPMV_CONF_INFO_HPP__

#include <systemc.h>

//
// Configuration parameters for the accelerator.
//
class conf_info_t
{
public:
    uint32_t nrows; // Rows of input matrix. Rows of output vector.
    uint32_t ncols; // Cols of input matrix. Cols of input vector.
    uint32_t max_nonzero; // Max of non-zero entries in a matrix row.
    uint32_t mtx_len;

    //
    // constructors
    //
    conf_info_t()
	: nrows(0)
	, ncols(0)
	, max_nonzero(0)
	, mtx_len(0)
	{}

    conf_info_t(
	uint32_t r,
	uint32_t c,
	uint32_t max,
	uint32_t mtx_len)
	: nrows(r)
	, ncols(c)
	, max_nonzero(max)
	, mtx_len(mtx_len)
	{}

    // equals operator
    inline bool operator==(const conf_info_t &rhs) const
	{
	    return (rhs.nrows == nrows)
		&& (rhs.ncols == ncols)
		&& (rhs.max_nonzero == max_nonzero)
		&& (rhs.mtx_len == mtx_len);
	}

    // assignment operator
    inline conf_info_t& operator=(const conf_info_t& other)
	{
	    nrows = other.nrows;
	    ncols = other.ncols;
	    max_nonzero = other.max_nonzero;
	    mtx_len = other.mtx_len;
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
	       << "}";
	    return os;
	}
};

#endif // __SPMV_CONF_INFO_HPP__
