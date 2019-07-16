// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __<ACCELERATOR_NAME>_CONF_INFO_HPP__
#define __<ACCELERATOR_NAME>_CONF_INFO_HPP__

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
		{}

	// equals operator
	inline bool operator==(const conf_info_t &rhs) const
		{
		}

	// assignment operator
	inline conf_info_t& operator=(const conf_info_t& other)
		{

			return *this;
		}

	// VCD dumping function
	friend void sc_trace(sc_trace_file *tf, const conf_info_t &v, const std::string &NAME)
		{}

	// redirection operator
	friend ostream& operator << (ostream& os, conf_info_t const &conf_info)
		{
			os << "";
			return os;
		}
};

#endif // __<ACCELERATOR_NAME>_CONF_INFO_HPP__
