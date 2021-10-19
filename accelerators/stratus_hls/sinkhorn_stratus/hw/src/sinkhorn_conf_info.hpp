// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __SINKHORN_CONF_INFO_HPP__
#define __SINKHORN_CONF_INFO_HPP__

#include <systemc.h>
#include "datatypes.hpp"

//
// Configuration parameters for the accelerator.
//
class conf_info_t
{
public:

    uint32_t p_rows;
    uint32_t q_cols;
    uint32_t m_rows;
    FPDATA_WORD gamma;
    uint32_t maxiter;
    uint32_t p2p_in;
    uint32_t p2p_out;
    uint32_t p2p_iter;
    uint32_t store_state;

    //
    // constructors
    //
    conf_info_t()
        : p_rows(0), q_cols(0), m_rows(0), gamma(0), maxiter(0), p2p_in(0), p2p_out(0), p2p_iter(0), store_state(0)
    {}

    conf_info_t(uint32_t p, uint32_t q, uint32_t m, FPDATA_WORD gamma, uint32_t iter,
                uint32_t p2p_in, uint32_t p2p_out, uint32_t p2p_iter, uint32_t store_state)
        : p_rows(p), q_cols(q), m_rows(m), gamma(gamma), maxiter(iter),
          p2p_in(p2p_in), p2p_out(p2p_out), p2p_iter(p2p_iter), store_state(store_state)
    {}

    // equals operator
    inline bool operator==(const conf_info_t &rhs) const
    {
        return (p_rows == rhs.p_rows) &&
            (q_cols == rhs.q_cols) &&
            (m_rows == rhs.m_rows) &&
            (gamma == rhs.gamma) &&
            (maxiter == rhs.maxiter) &&
            (p2p_in == rhs.p2p_in) &&
            (p2p_out == rhs.p2p_out) &&
            (p2p_iter == rhs.p2p_iter) &&
            (store_state == rhs.store_state);
    }

    // assignment operator
    inline conf_info_t& operator=(const conf_info_t& other)
    {
        p_rows = other.p_rows;
        q_cols = other.q_cols;
        m_rows = other.m_rows;
        gamma = other.gamma;
        maxiter = other.maxiter;
        p2p_in = other.p2p_in;
        p2p_out = other.p2p_out;
        p2p_iter = other.p2p_iter;
        store_state = other.store_state;
        return *this;
    }

    // VCD dumping function
    friend void sc_trace(sc_trace_file *tf, const conf_info_t &v, const std::string &NAME)
    {}

    // redirection operator
    friend ostream& operator << (ostream& os, conf_info_t const &conf_info)
    {
        os << "{ p_rows = " << conf_info.p_rows
           << ", q_cols = "  << conf_info.q_cols
           << ", m_rows = "  << conf_info.m_rows
           << ", gamma = "  << conf_info.gamma
           << ", maxiter = "  << conf_info.maxiter
           << ", p2p_in = "  << conf_info.p2p_in
           << ", p2p_out = "  << conf_info.p2p_out
           << ", p2p_iter = "  << conf_info.p2p_iter
           << ", store_state = "  << conf_info.store_state
           << "}";
        return os;
    }

};

#endif // __SINKHORN_CONF_INFO_HPP__
