// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __NMF_FPDATA_HPP__
#define __NMF_FPDATA_HPP__

#include <cstdio>
#include <cstdlib>
#include <cstddef>
#include <systemc.h>

// Stratus fixed point

#include "cynw_fixed.h"

// Data types

// x,y,z, kx,ky,kz,phiR,phiI, cosArg, sinArg, phiMag

// WL 24, IL 5.
//const unsigned int FPDATA_S_WL = 24;
//const unsigned int FPDATA_S_IL = 5;
//
const unsigned int FPDATA_S_WL = 32;
const unsigned int FPDATA_S_IL = 12;
////
//

const unsigned int FPDATA_S_PL = (FPDATA_S_WL - FPDATA_S_IL);

typedef cynw_fixed<FPDATA_S_WL, FPDATA_S_IL, SC_RND> FPDATA_S;

typedef sc_dt::sc_int<FPDATA_S_WL> FPDATA_S_WORD;

// WL 24, IL 11
// Qracc, Qiacc, expArg, 
//const unsigned int FPDATA_L_WL = 24;
//const unsigned int FPDATA_L_IL = 11;
//
const unsigned int FPDATA_L_WL = 32;
const unsigned int FPDATA_L_IL = 12;
////

const unsigned int FPDATA_L_PL = (FPDATA_L_WL - FPDATA_L_IL);

typedef cynw_fixed<FPDATA_L_WL, FPDATA_L_IL, SC_RND> FPDATA_L;

typedef sc_dt::sc_int<FPDATA_L_WL> FPDATA_L_WORD;



// Helper functions


// from fft:

template<typename T, size_t N>
void bv2fp( sc_dt::sc_bv<N> data_in, T &data_out)
{
  {
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "bv2fp2");

    for (unsigned i = 0; i < N; i++)
      {
	HLS_UNROLL_LOOP(ON, "bv2fp-loop");

	data_out[i] = data_in[i].to_bool();
      }
  }
}




template<typename T, size_t N>
T bv2fp(sc_dt::sc_bv<N> data_in)
{
  T data_out;

  {
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "bv2fp1");

    for (unsigned i = 0; i < N; i++)
      {
	HLS_UNROLL_LOOP(ON, "bv2fp-loop");

	data_out[i] = data_in[i].to_bool();
      }
  }

  return data_out;
}





// from fft


template<typename T, size_t N>
void fp2bv( T data_in, sc_dt::sc_bv<N> &data_out)
{
  {
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "fp2bv2");

    for (unsigned i = 0; i < N; i++)
      {
	HLS_UNROLL_LOOP(ON, "fp2bv-loop");

	data_out[i] = (bool) data_in[i];
      }
  }
}

// Helper functions

// T <---> sc_dt::sc_int<N>

template<typename T, size_t N>
T int2fp(sc_dt::sc_int<N> data_in)
{
  T data_out;

  {
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "int2fp1");

    for (unsigned i = 0; i < N; i++)
      {
	HLS_UNROLL_LOOP(ON, "int2fp-loop");

	data_out[i] = data_in[i].to_bool();
      }
  }

  return data_out;
}

template<typename T, size_t N>
void int2fp(T &data_out, sc_dt::sc_int<N> data_in)
{
  {
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "int2fp2");

    for (unsigned i = 0; i < N; i++)
      {
	HLS_UNROLL_LOOP(ON, "int2fp-loop");

	data_out[i] = data_in[i].to_bool();
      }
  }
}

template<typename T, size_t N>
sc_dt::sc_int<N> fp2int(T data_in)
{
  sc_dt::sc_int<N> data_out;

  {
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "fp2int1");

    for (unsigned i = 0; i < N; i++)
      {
	HLS_UNROLL_LOOP(ON, "fp2int-loop");

	data_out[i] = (bool) data_in[i];
      }
  }

  return data_out;
}

template<typename T, size_t N>
void fp2int(sc_dt::sc_int<N> &data_out, T data_in)
{
  {
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "fp2int2");

    for (unsigned i = 0; i < N; i++)
      {
	HLS_UNROLL_LOOP(ON, "fp2int-loop");

	data_out[i] = (bool) data_in[i];
      }
  }
}



#endif // __NMF_FPDATA_HPP__
