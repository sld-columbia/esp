/*
 * Copyright (c) 2011-2023 Columbia University, System Level Design Group
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef FFT_UTILS_H
#define FFT_UTILS_H

#include <stdbool.h>
#include <limits.h>
#include <math.h>

#include <fixed_point.h>

unsigned int fft_rev(unsigned int v);
void fft_bit_reverse(float *w, unsigned int n, unsigned int bits);
int fft_comp(float *data, unsigned int n, unsigned int logn, int sign, bool rev);

#ifndef __linux__
double sin(double x);
#ifdef __riscv
float rand(void);
#define RAND_MAX 32768.0
#endif
#endif

#endif /* FFT_UTILS_H */
