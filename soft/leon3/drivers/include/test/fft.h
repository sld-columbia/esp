#ifndef TEST_FFT_H
#define TEST_FFT_H

#include <stdbool.h>
#include <limits.h>
#include <math.h>

#include <fixed_point.h>
#include <contig.h>

static inline void fft_to_float(contig_handle_t contig, int n, int n_int_bits)
{
	int i;

	for (i = 0; i < n * 2; i++) {
		unsigned int val;

		val = contig_read32(contig, sizeof(val) * i);
		fixed_to_float(&val, n_int_bits);
		contig_write32(val, contig, sizeof(val) * i);
	}
}

static inline void fft_to_sc_fixed(contig_handle_t contig, int n, int n_int_bits)
{
	int i;

	for (i = 0; i < n * 2; i++) {
		unsigned int val;

		val = contig_read32(contig, sizeof(val) * i);
		float_to_fixed(&val, n_int_bits);
		contig_write32(val, contig, sizeof(val) * i);
	}
}

bool fft_diff_ok(const float *sw_fft, contig_handle_t contig, int n, bool verbose);
unsigned int fft_rev(unsigned int v);
float *fft_bit_reverse(float *w, unsigned int n, unsigned int bits);
int fft_comp(float *data, unsigned int n, unsigned int logn, int sign, bool rev);

#endif /* TEST_FFT_H */
