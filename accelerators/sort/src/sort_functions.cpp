#include "sort.hpp"

/* TODO: handle exceptions and NaN */
inline bool lt_float(const unsigned &in0, const unsigned &in1)
{

	sc_uint<32> op0  = in0;
	sc_uint<32> op1  = in1;
	bool        s0   = op0[31] == 0 ? false : true;
	bool        s1   = op1[31] == 0 ? false : true;
	sc_uint<8>  exp0 = op0.range(30, 23);
	sc_uint<8>  exp1 = op1.range(30, 23);
	sc_uint<23> man0 = op0.range(22, 0);
	sc_uint<23> man1 = op1.range(22, 0);

	bool zero0 = false;
	bool zero1 = false;

	if (exp0 == 0 && man0 == 0)
		zero0 = true;

	if (exp1 == 0 && man1 == 0)
		zero1 = true;

	if (zero0 && zero1)
		return false;

	if (zero0)
		return !s1;

	if (zero1)
		return s0;

	if (s0 != s1)
		return s0;

	if (exp0 < exp1)
		return !s0;

	if (exp0 > exp1)
		return s0;

	if (man0 < man1)
		return !s0;

	if (man0 > man1)
		return s0;

	return false;
}
