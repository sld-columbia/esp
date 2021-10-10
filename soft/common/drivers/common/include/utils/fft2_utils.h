/*
 * Copyright (c) 2011-2019 Columbia University, System Level Design Group
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef FFT2_UTILS_H
#define FFT2_UTILS_H

#include <stdbool.h>
#include <limits.h>
#include <math.h>

#include <fixed_point.h>

void fft2_do_shift(float *A0, unsigned int offset, unsigned int num_samples, unsigned int bits);
unsigned int fft2_rev(unsigned int v);
void fft2_bit_reverse(float *w, unsigned int offset, unsigned int n, unsigned int bits);
int  fft2_comp(float *data, unsigned nffts, unsigned int n, unsigned int logn, int do_inverse, int do_shift);

#ifndef __linux__
double sin(double x);
#ifdef __riscv
float rand(void);
#define RAND_MAX 32768.0
#endif
#endif

#endif /* FFT2_UTILS_H */
