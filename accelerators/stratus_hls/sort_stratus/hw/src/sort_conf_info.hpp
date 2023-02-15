// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __SORT_CONF_INFO_HPP__
#define __SORT_CONF_INFO_HPP__

#include <systemc.h>

//
// Configuration parameters for the accelerator.
//
class conf_info_t
{
public:
  uint32_t len; // Length of vectors to sort
  uint32_t batch; // Number of vectors to sort

  //
  // constructors
  //
  conf_info_t()
  : len(0)
  , batch(0)
  {}

  conf_info_t(
    uint32_t l,
    uint32_t b)
  : len(l)
  , batch(b)
  {}

  // equals operator
  inline bool operator==(const conf_info_t &rhs) const
  {
    return (rhs.len == len)
	    && (rhs.batch == batch);
  }

  // assignment operator
  inline conf_info_t& operator=(const conf_info_t& other)
  {
    len = other.len;
    batch = other.batch;

    return *this;
  }

  // VCD dumping function
  friend void sc_trace(sc_trace_file *tf, const conf_info_t &v, const std::string &NAME)
  {}

  // redirection operator
  friend ostream& operator << (ostream& os, conf_info_t const &conf_info)
  {
    os << "{ len = " << conf_info.len
       << ", batch = " << conf_info.batch
       << "}";
    return os;
  }
};

#endif // __SORT_CONF_INFO_HPP__
