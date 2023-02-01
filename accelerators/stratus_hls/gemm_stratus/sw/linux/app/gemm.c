// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "libesp.h"
#include "cfg.h"

static void validate_buffer(token_t *acc_buf, native_t *sw_buf, unsigned len)
{
    int i;
    native_t val;
    unsigned errors = 0;

    printf("\nPrint output\n");

    for (i = 0; i < len; i++) {

#ifdef __FIXED
	val = fx2float(acc_buf[i], FX_IL);
#else
	val = acc_buf[i];
#endif
	if (sw_buf[i] != val) {
	    errors++;
	    if (errors <= MAX_PRINTED_ERRORS)
		printf("index %d : output %d : expected %d <-- ERROR\n", i, (int) val, (int) sw_buf[i]);
	}
    }

    if (!errors)
	printf("\n  ** Test PASSED! **\n");
    else
	printf("\n  ** Test FAILED! **\n");
}


/* User-defined code */
static void init_buffer(token_t *acc_buf, native_t *sw_buf, unsigned in_len)
{
    int i;

    printf("  Initialize inputs\n");

    for (i = 0; i < in_len; i++) {
	native_t val = i % 17 - 8;
#ifdef __FIXED
        acc_buf[i] = float2fx(val, FX_IL);
#else
        acc_buf[i] = val;
#endif
	sw_buf[i] = val;
    }
}


/* User-defined code */
static void init_parameters(int test, int32_t do_relu, int32_t transpose, int32_t ninputs,
			    int32_t d3, int32_t d2, int32_t d1,
			    unsigned *in_len, unsigned *in1_len, unsigned *out_len,
			    unsigned *in_size, unsigned *out_size, unsigned *size)
{
    int32_t ld_offset1, ld_offset2, st_offset;
    unsigned in2_len;
    
    *in1_len = round_up(ninputs * d1 * d2, DMA_WORD_PER_BEAT(sizeof(token_t)));
    in2_len = round_up(ninputs * d2 * d3, DMA_WORD_PER_BEAT(sizeof(token_t)));
    *in_len = *in1_len + in2_len;
    *out_len = round_up(ninputs * d1 * d3, DMA_WORD_PER_BEAT(sizeof(token_t)));
    *in_size = *in_len * sizeof(token_t);
    *out_size = *out_len * sizeof(token_t);
    *size = *in_size + *out_size;

    ld_offset1 = 0;
    ld_offset2 = *in1_len;
    st_offset = *in_len;

    gemm_cfg_000[0].do_relu = do_relu;
    gemm_cfg_000[0].transpose = transpose;
    gemm_cfg_000[0].ninputs = ninputs;
    gemm_cfg_000[0].d1 = d1;
    gemm_cfg_000[0].d2 = d2;
    gemm_cfg_000[0].d3 = d3;
    gemm_cfg_000[0].ld_offset1 = ld_offset1;
    gemm_cfg_000[0].ld_offset2 = ld_offset2;
    gemm_cfg_000[0].st_offset = st_offset;

    // print test info
    printf("  Prepare test %d parameters\n", test);
    printf("    .do_relu = %d\n", do_relu);
    printf("    .transpose = %d\n", transpose);
    printf("    .ninputs = %d\n", ninputs);
    printf("    .d3 = %d\n", d3);
    printf("    .d2 = %d\n", d2);
    printf("    .d1 = %d\n", d1);
    printf("    .st_offset = %d\n", st_offset);
    printf("    .ld_offset1 = %d\n", ld_offset1);
    printf("    .ld_offset2 = %d\n", ld_offset2);
}

static void sw_run(int32_t do_relu, int32_t transpose, int32_t ninputs,
		   int32_t d3, int32_t d2, int32_t d1,
		   native_t *in1, native_t *in2, native_t *out)
{
    int i, j, k, l;
    struct timespec th_start, th_end;
    native_t *in1_l, *in2_l, *out_l;

    gettime(&th_start);

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

    gettime(&th_end);

    unsigned long long hw_ns = ts_subtract(&th_start, &th_end);
    printf("    Software execution time: %llu ns\n", hw_ns);
}

int main(int argc, char **argv)
{
    int test, n_tests, start_test = 1;

    unsigned in_len;
    unsigned in1_len;
    unsigned out_len;
    unsigned in_size;
    unsigned out_size;
    unsigned size;

    token_t *acc_buf;
    native_t *sw_buf;

    int32_t do_relu  [MAX_TESTS] = {   0,  0,  0,    0,   0,  0,   0,   0,   0,    0,
				       0,  0,  0,    0,   0,  0,   0,   0,   0,    0,
				       0,  0,  0,    0,   0,  0,   0,   0,   0,    0};

    int32_t transpose[MAX_TESTS] = {   1,  1,  0,    1,   1,  0,   1,   1,   0,    1,
				       1,  1,  0,    0,   1,  1,   1,   1,   1,    1,
				       0,  0,  0,    0,   1,  0,   0,   1,   1,    1};

    int32_t ninputs  [MAX_TESTS] = {   2, 32,  4,    1,   8,  1,   1, 128,   1,    1,
				       1,  2,  1,    1,   1,  1,   4,   8,   2,    2,
				       2,  2,  2,    1, 128,  1,   4,   2,   2,    2};

    int32_t d3       [MAX_TESTS] = {   8,  8,  8,   32,  32, 32, 128, 128, 128,    1,
				       1, 20,  2,    2,  64, 64,  11,  18,  18,   21,
				      11, 18, 18,   21, 128,  8,   8,   8,   8,   21};

    int32_t d2       [MAX_TESTS] = {   8,  8,  8,   32,  32, 32, 128, 128, 128, 2048,
				    2048, 16, 64, 2048,   1,  2,  246,  25,  14,   14,
				      26, 25, 14,   14, 128,  8,   8,   8,   8,   14};

    int32_t d1       [MAX_TESTS] = {   8,  8,  8,   32,  32, 32, 128, 128, 128,    1,
				       8,  1, 10,    1,  64, 64,  21,  22,  31,   22,
				       21,22, 31,   22, 128,  8,   8,   8,   8,   11};

    printf("\n====== %s ======\n\n", cfg_000[0].devname);

    // command line arguments
    if (argc < 3) {
	n_tests = 1;
    } else if (argc == 3) {
	n_tests = strtol(argv[1], NULL, 10);
	if (n_tests > MAX_TESTS) {
	    printf("Wrong input arguments!");
	    return 1;
	}
	start_test = strtol(argv[2], NULL, 10);
	if (start_test > MAX_TESTS) {
	    printf("Wrong input arguments!");
	    return 1;
	}

    } else {
	printf("Wrong input arguments!");
	return 1;
    }
    printf("  Executing %d tests\n", n_tests);

    // allocations
    printf("  Allocations\n");

    acc_buf = (token_t *) esp_alloc(MAX_SIZE);
    cfg_000[0].hw_buf = acc_buf;

    sw_buf = malloc(MAX_SIZE);

    for (test = start_test - 1; test < n_tests + start_test - 1; ++test) {

	printf("\n\n-------------------\n");
	printf("TEST #%d\n", test + 1);

	// calculate test parameters
	init_parameters(test,
			do_relu[test], transpose[test], ninputs[test], d3[test], d2[test], d1[test],
			&in_len, &in1_len, &out_len, &in_size, &out_size, &size);

	// initialize input data
	init_buffer(acc_buf, sw_buf, in_len);

	// hardware execution
	printf("  Start accelerator execution\n");
	esp_run(cfg_000, NACC);
	printf("  Completed accelerator execution\n");

	// software execution
	printf("  Start software execution\n");
	sw_run(do_relu[test], transpose[test], ninputs[test], d3[test], d2[test], d1[test],
	       sw_buf, &sw_buf[in1_len], &sw_buf[in_len]);
	printf("  Completed software execution\n");

	// validation
	// errors = print_input(buf, gold);
	validate_buffer(&acc_buf[in_len], &sw_buf[in_len], out_len);
    }

    // free
    esp_free(acc_buf);
    free(sw_buf);

    printf("\n====== %s ======\n\n", cfg_000[0].devname);

    return 0;
}
