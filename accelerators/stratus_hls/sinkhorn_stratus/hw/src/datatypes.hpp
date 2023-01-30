/* Copyright 2019 Columbia University SLD Group */

// Stratus fixed-point (HLS-r)
#include <cynw_fixed.h>

#ifndef __DATATYPES_HPP__
#define __DATATYPES_HPP__

// Define conversion functions between bit-vector and floating point types
// Note that the signature of these function is such that a conversion can
// be implemented for both floating point and fixed point data types.

#define FPDATA_WL 32
#define FPDATA_IL 11

#define FPDATA cynw_fixed<FPDATA_WL, FPDATA_IL>

typedef sc_dt::sc_uint<FPDATA_WL> FPDATA_WORD;
//typedef sc_dt::sc_uint<FPDATA_WL*2> FPDATA_WORD;

// cynw_interpret going to a bit vector
inline void cynw_interpret(const FPDATA& in, FPDATA_WORD& out)
{ out.range(FPDATA_WL-1,0) = in.range(FPDATA_WL-1,0); }

// cynw_interpret going to a bit vector
inline void cynw_interpret2(const FPDATA& in, FPDATA_WORD& out)
{ out.range(FPDATA_WL*2-1,FPDATA_WL) = in.range(FPDATA_WL-1,0); }

// cynw_interpret going to a 64-bit vector
inline void cynw_interpret64(const FPDATA& in1, const FPDATA& in2, FPDATA_WORD& out)
{ out.range(FPDATA_WL-1,0) = in2.range(FPDATA_WL-1,0);
    out.range(FPDATA_WL*2-1,FPDATA_WL) = in1.range(FPDATA_WL-1,0); }

// cynw_interpret going from a bit vector
inline void cynw_interpret(const FPDATA_WORD& in, FPDATA& out)
{ out.range(FPDATA_WL-1,0) = in.range(FPDATA_WL-1,0); }

// cynw_interpret going from a bit vector
inline void cynw_interpret2(const FPDATA_WORD& in, FPDATA& out)
{ out.range(FPDATA_WL-1,0) = in.range(FPDATA_WL*2-1,FPDATA_WL); }

// cynw_interpret going from a 64-bit vector
inline void cynw_interpret64(const FPDATA_WORD& in, FPDATA& out1, FPDATA& out2)
{ out2.range(FPDATA_WL-1,0) = in.range(FPDATA_WL-1,0);
    out1.range(FPDATA_WL-1,0) = in.range(FPDATA_WL*2-1,FPDATA_WL); }

// Conversion from bit-vector to fp
template<typename T, size_t FP_WL, size_t BV_L>
void bv2fp(sc_dt::sc_bv<BV_L> data_in, T &data_out)
{
	// Copy data
	for (unsigned i = 0; i < FP_WL; i++)
	{
		HLS_UNROLL_LOOP(ON, "bv2fp");
		data_out[i] = data_in[i].to_bool();
	}
}


// Conversion from fp to bit-vector
template<typename T, size_t FP_WL, size_t BV_L>
void fp2bv(T data_in, sc_dt::sc_bv<BV_L> &data_out)
{
	// Copy data
	for (unsigned i = 0; i < FP_WL; i++)
	{
		HLS_UNROLL_LOOP(ON, "fp2bv");
		data_out[i] = (bool)data_in[i];
	}
	// Extend sign
	for (unsigned i = FP_WL; i < BV_L; i++)
	{
		HLS_UNROLL_LOOP(ON, "fp2bv_s_ext");
		data_out[i] = (bool)data_in[FP_WL - 1];
	}
}


// Conversion from fixed-point to native floating point
inline void fp2native(const FPDATA& in, float& out)
{ out = in.to_double(); }

/* Memory alignment adjustment factor */
#define DMA_ADJ (FPDATA_WL / DATA_WIDTH)

#endif /* __DATATYPES_HPP__ */
