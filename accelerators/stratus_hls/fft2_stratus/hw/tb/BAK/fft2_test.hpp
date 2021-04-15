/*
 * Copyright (c) 2011-2019 Columbia University, System Level Design Group
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef TEST_FFT2_H
#define TEST_FFT2_H

#include <stdbool.h>
#include <limits.h>
#include <math.h>

void fft2_do_shift(float *A0, unsigned int offset, unsigned int num_samples, unsigned int bits);
unsigned int fft2_rev(unsigned int v);
void fft2_bit_reverse(float *w, unsigned int offset, unsigned int n, unsigned int bits);
int  fft2_comp(float *data, unsigned nffts, unsigned int n, unsigned int logn, int do_inverse, int do_shift);


#endif /* TEST_FFT2_H */
