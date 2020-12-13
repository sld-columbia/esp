/*
 * Copyright (c) 2011-2019 Columbia University, System Level Design Group
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef TEST_FFT_H
#define TEST_FFT_H

#include <stdbool.h>
#include <limits.h>
#include <math.h>

#include <fixed_point.h>

unsigned int fft_rev(unsigned int v);
void fft_bit_reverse(float *w, unsigned int n, unsigned int bits);
int fft_comp(float *data, unsigned int n, unsigned int logn, int sign, bool rev);

#ifndef __linux__
#ifdef __riscv
double sin(double x);
float rand(void);
#define RAND_MAX 32768.0
#endif
#endif

#endif /* TEST_FFT_H */
