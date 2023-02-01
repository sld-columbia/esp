/*
 * Copyright (c) 2011-2023 Columbia University, System Level Design Group
 * SPDX-License-Identifier: Apache-2.0
 */

/*
 * fixed_point.h
 * Helpers to convert to/from floating and fixed point.
 *
 * The functions directly manipulate floating point type bits to
 * directly compute 1 / 2^n_int_bits.
 */
#ifndef FIXED_POINT_H
#define FIXED_POINT_H

static inline int float_to_fixed32(float value, int n_int_bits);
static inline unsigned float_to_ufixed32(float value, int n_int_bits);
static inline long long double_to_fixed64(double value, int n_int_bits);
static inline unsigned long long double_to_ufixed64(double value, int n_int_bits);

static inline float fixed32_to_float(int value, int n_int_bits);
static inline float ufixed32_to_float(unsigned value, int n_int_bits);
static inline double fixed64_to_double(long long value, int n_int_bits);
static inline double ufixed64_to_double(unsigned long long value, int n_int_bits);

/**
 * fixed_to_float - convert a fixed point value to floating point
 * @value: pointer to the value to be converted
 * @n_int_bits: number of integer bits, including sign bit
 *
 * Note: this assumes the fixed point value is 32 bits long
 */
static inline void fixed_to_float(void *value, int n_int_bits)
{
	int *valuep = (int*)value;
	*(float*)value = fixed32_to_float(*valuep, n_int_bits);
}

/**
 * float_to_fixed - convert a floating point value to fixed point
 * @value: pointer to the value to be converted
 * @n_int_bits: number of integer bits, including sign bit
 *
 * Note: this assumes the fixed point value is 32 bits long
 */
static inline void float_to_fixed(void *value, int n_int_bits)
{
	float *valuep = (float*)value;
	*(int*)value = float_to_fixed32(*valuep, n_int_bits);
}

static inline int float_to_fixed32(float value, int n_int_bits)
{
	unsigned shift_int = 0x3f800000 + 0x800000 * (32 - n_int_bits);
	float *shift = (float *) &shift_int;

	return (int)(value * (*shift));
}

static inline unsigned float_to_ufixed32(float value, int n_int_bits)
{
	unsigned shift_int = 0x3f800000 + 0x800000 * (32 - n_int_bits);
	float *shift = (float *) (&shift_int);

	return (unsigned)(value * (*shift));
}

static inline long long double_to_fixed64(double value, int n_int_bits)
{
	unsigned long long shift_ll = 0x3ff0000000000000LL + 0x0010000000000000LL * (64 - n_int_bits);
	double *shift = (double *) (&shift_ll);

	return (long long)(value * (*shift));
}

static inline unsigned long long double_to_ufixed64(double value, int n_int_bits)
{
	unsigned long long shift_ll = 0x3ff0000000000000LL + 0x0010000000000000LL * (64 - n_int_bits);
	double *shift = (double *) (&shift_ll);

	return (unsigned long long)(value * (*shift));
}

static inline float fixed32_to_float(int value, int n_int_bits)
{
	unsigned shift_int = 0x3f800000 - 0x800000 * (32 - n_int_bits);
	float *shift = (float *) (&shift_int);

	return (*shift) * (float)value;
}

static inline float ufixed32_to_float(unsigned value, int n_int_bits)
{
	unsigned shift_int = 0x3f800000 - 0x800000 * (32 - n_int_bits);
	float *shift = (float *) (&shift_int);

	return (*shift) * (float)value;
}

static inline double fixed64_to_double(long long value, int n_int_bits)
{
	unsigned long long shift_ll = 0x3ff0000000000000LL - 0x0010000000000000LL * (64 - n_int_bits);
	double *shift = (double *) (&shift_ll);

	return (*shift) * (double)value;
}

static inline double ufixed64_to_double(unsigned long long value, int n_int_bits)
{
	unsigned long long shift_ll = 0x3ff0000000000000LL - 0x0010000000000000LL * (64 - n_int_bits);
	double *shift = (double *) (&shift_ll);

	return (*shift) * (double)value;
}

#endif /* FIXED_POINT_H */
