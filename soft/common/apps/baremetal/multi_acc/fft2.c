/* Copyright (c) 2011-2019 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include "fft2.h"

const float ERR_TH = 0.05;

int validate_buf_fft2(token_t *out, float *gold)
{
	int j;
	unsigned errors = 0;

	for (j = 0; j < 2 * len_fft2; j++) {
		native_t val = fx2float(out[j], FX_IL);
		uint32_t ival = *((uint32_t*)&val);
#ifndef LARGE_WORKLOAD
		// printf("  GOLD[%u] = 0x%08x  :  OUT[%u] = 0x%08x\n", j, ((uint32_t*)gold)[j], j, ival);
#endif
		if ((fabs(gold[j] - val) / fabs(gold[j])) > ERR_TH)
			errors++;
	}

	//printf("  %u errors\n", errors);
	return errors;
}


void init_buf_fft2(token_t *in, float *gold)
{
	int j;
	const float LO = -10.0;
	const float HI = 10.0;

	/* srand((unsigned int) time(NULL)); */

	for (j = 0; j < 2 * len_fft2; j++) {
		float scaling_factor = (float) rand () / (float) RAND_MAX;
		gold[j] = LO + scaling_factor * (HI - LO);
		uint32_t ig = ((uint32_t*)gold)[j];
		/* printf("  IN[%u] = 0x%08x\n", j, ig); */
	}

	// convert input to fixed point
	for (j = 0; j < 2 * len_fft2; j++)
		in[j] = float2fx((native_t) gold[j], FX_IL);
}
