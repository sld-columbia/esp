/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include "multi_acc.h"
#include "gemm.h"

void sw_run_gemm(int32_t do_relu, int32_t transpose, int32_t ninputs,
			int32_t d3, int32_t d2, int32_t d1,
			native_t *in1, native_t *in2, native_t *out)
{
    int i, j, k, l;
    struct timespec th_start, th_end;
    native_t *in1_l, *in2_l, *out_l;

    for (l = 0; l < ninputs; ++l)
    {
	in1_l = &in1[l * d1 * d2];
	in2_l = &in2[l * d2 * d3];
	out_l = &out[l * d1 * d3];

	for (i = 0; i < d1; ++i)
	{
	    for (j = 0; j < d3; ++j)
	    {
		native_t accumulator = 0.0;

		for (k = 0; k < d2; ++k)
		{
		    int mtx_in1_i = i * d2 + k;
		    int mtx_in2_i = transpose ? (j * d2 + k) : (k * d3 + j);

		    accumulator += in1_l[mtx_in1_i] * in2_l[mtx_in2_i];
		}

		out_l[i * d3 + j] = accumulator;
	    }
	}
    }
}

int validate_buf_gemm(token_t *out, native_t *gold)
{
	int j;
	native_t val;
	unsigned errors = 0;

        for (j = 0; j < out_len_gemm; j++) {
#ifdef __FIXED
	    val = fx2float(out[j], FX_IL);
#else
            val = out[j];
#endif

            if (gold[j] != val) {
                errors++;
                if (errors <= MAX_PRINTED_ERRORS) {
		    printf("%d : %d : %d\n", j, (int) val, (int) gold[j]);
		}
            }
	}

	return errors;
}


void init_buf_gemm (token_t *in, native_t *sw_buf)
{
    int i;

//#include "input.h"

#ifdef __FIXED
    for (i = 0; i < ninputs * (d1*d2 + d2*d3); i++) {
	sw_buf[i] = i % 14;
        in[i] = float2fx(i % 14, FX_IL);
    }
#endif

//#include "gold.h"
}
