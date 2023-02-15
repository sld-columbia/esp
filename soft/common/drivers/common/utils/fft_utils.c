// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include <stdint.h>
#include <math.h>

#include <utils/fft_utils.h>

#ifndef __linux__
/* RISC-V baremetal does not have sin implementation */
/* source stackoverflow: https://stackoverflow.com/a/2284929 */
double sin(double x)
{
	int i = 1;
	double cur = x;
	double acc = 1;
	double fact= 1;
	double pow = x;
	while (fabs(acc) > .00000001 &&   i < 100){
		fact *= ((2*i)*(2*i+1));
		pow *= -1 * x*x;
		acc =  pow / fact;
		cur += acc;
		i++;
	}
	return cur;

}
#ifdef __riscv
/* simple not quite random implementation of rand() when stdlib is not available */
static unsigned long int next = 42;
float rand(void)
{
	unsigned int rand_tmp;
	next = next * 1103515245 + 12345;
	rand_tmp = (unsigned int) (next / 65536) % 32768;
	return ((float) rand_tmp);

}
#endif
#endif

/*
 * This determines the maximum admissible relative error between the accelerated
 * FFT and the software one.
 *
 * Note that in simulation, this code is compiled into something different
 * than what is run natively to model the accelerator, so a discrepancy
 * between the simulated and accelerated FFT (which in this case would be
 * native) is totally normal.
 *
 * With a hardware accelerator, a discrepancy is again expected, since
 * the floating point precision of the hardware accelerator is different
 * from that of the host CPU.
 */
#define MAX_REL_ERR 0.05

unsigned int fft_rev(unsigned int v)
{
	unsigned int r = v;
	int s = sizeof(v) * CHAR_BIT - 1;

	for (v >>= 1; v; v >>= 1) {
		r <<= 1;
		r |= v & 1;
		s--;
	}
	r <<= s;
	return r;
}

void fft_bit_reverse(float *w, unsigned int n, unsigned int bits)
{
	unsigned int i, s, shift;

	s = sizeof(i) * CHAR_BIT - 1;
	shift = s - bits + 1;

	for (i = 0; i < n; i++) {
		unsigned int r;
		float t_real, t_imag;

		r = fft_rev(i);
		r >>= shift;

		if (i < r) {
			t_real = w[2 * i];
			t_imag = w[2 * i + 1];
			w[2 * i] = w[2 * r];
			w[2 * i + 1] = w[2 * r + 1];
			w[2 * r] = t_real;
			w[2 * r + 1] = t_imag;
		}
	}
}

int fft_comp(float *data, unsigned int n, unsigned int logn, int sign, bool rev)
{
	unsigned int transform_length;
	unsigned int a, b, i, j, bit;
	float theta, t_real, t_imag, w_real, w_imag, s, t, s2, z_real, z_imag;

	if (rev)
		fft_bit_reverse(data, n, logn);

	transform_length = 1;

	/* calculation */
	for (bit = 0; bit < logn; bit++) {
		w_real = 1.0;
		w_imag = 0.0;

		theta = 1.0 * sign * M_PI / (float) transform_length;

		s = sin(theta);
		t = sin(0.5 * theta);
		s2 = 2.0 * t * t;

		for (a = 0; a < transform_length; a++) {
			for (b = 0; b < n; b += 2 * transform_length) {
				i = b + a;
				j = b + a + transform_length;

				z_real = data[2 * j];
				z_imag = data[2 * j + 1];

				t_real = w_real * z_real - w_imag * z_imag;
				t_imag = w_real * z_imag + w_imag * z_real;

				/* write the result */
				data[2*j]	= data[2*i] - t_real;
				data[2*j + 1]	= data[2*i + 1] - t_imag;
				data[2*i]	+= t_real;
				data[2*i + 1]	+= t_imag;
			}

			/* adjust w */
			t_real = w_real - (s * w_imag + s2 * w_real);
			t_imag = w_imag + (s * w_real - s2 * w_imag);
			w_real = t_real;
			w_imag = t_imag;

		}
		transform_length *= 2;
	}

	return 0;
}
