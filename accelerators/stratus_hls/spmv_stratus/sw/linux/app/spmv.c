// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include <math.h>

#include <my_stringify.h>
#include <test/test.h>
#include <test/time.h>
#include <fixed_point.h>
#include <spmv_stratus.h>

#define DEVNAME "/dev/spmv_stratus.0"
#define NAME "spmv_stratus"

static const char usage_str[] = "usage: spmv_stratus coherence cmd [plm_size] [fit_plm] [in_file] [-v]\n"
	"  coherence : none|llc-coh-dma|coh-dma|coh\n"
	"  cmd       : config|test|run|hw\n"
	"\n"
	"Optional arguments: these are required for 'config', 'test' and 'hw'\n"
	"  plm_size  : must be at most 1024 and a power of 2\n"
	"  fit_plm   : when not zero the dense vector is kept in the PLM if cols < 8K\n"
	"  in_file   : input matrix, input vector and configuration parameters\n"
	"\n"
	"Other optional arguments:\n"
	"  -v        : 'test' prints mismatched values in case of errors above threshold\n";

struct spmv_test {
	struct test_info info;
	struct spmv_stratus_access desc;

	unsigned int nrows;
	unsigned int ncols;
	unsigned int max_nonzero;
	unsigned int mtx_len;
	unsigned int vals_plm_size;
	unsigned int vect_fits_plm;

	const char *in_file;

	bool verbose;

	unsigned vals_addr;
	unsigned cols_addr;
	unsigned rows_addr;
	unsigned vect_addr;
	unsigned out_addr;

	unsigned vals_size;
	unsigned cols_size;
	unsigned rows_size;
	unsigned vect_size;
	unsigned out_size;

	float    *in_vals_buf;
	unsigned *in_cols_buf;
	unsigned *in_rows_buf;
	float    *in_vect_buf;
	float    *out_buf;

	int *in_vals_fx_buf;
	int *in_vect_fx_buf;
	int *out_fx_buf;

	float *gold_buf;
};

/*
 * Helper functions
 */
static inline struct spmv_test *to_spmv(struct test_info *info)
{
	return container_of(info, struct spmv_test, info);
}

static inline size_t spmv_in_size(struct spmv_test *test)
{
	return sizeof(int) * (test->vals_size + test->cols_size + test->rows_size + test->vect_size);
}

static inline size_t spmv_out_size(struct spmv_test *test)
{
	return sizeof(int) * test->out_size;
}

static inline size_t spmv_out_addr(struct spmv_test *test)
{
	return sizeof(int) * test->out_addr;
}

static inline size_t spmv_size(struct spmv_test *test)
{
	return spmv_in_size(test) + spmv_out_size(test);
}



/*
 * spmv_alloc_buf
 */

static void spmv_alloc_buf(struct test_info *info)
{
	struct spmv_test *test = to_spmv(info);

	FILE *fp;
	char str_tmp[4];
	int i;

	fp = fopen(test->in_file, "r");
	if (!fp)
		die_errno("%s: cannot open file %s", __func__, test->in_file);

	// Read configuration
	fscanf(fp, "%u %u %u %u\n", &test->nrows, &test->ncols, &test->max_nonzero, &test->mtx_len);

	printf("config: %u %u %u %u\n", test->nrows, test->ncols, test->max_nonzero, test->mtx_len);

	// Set data structure offsets (4B words)
	test->vals_addr = 0;
	test->vals_size = test->mtx_len;

	test->cols_addr = test->mtx_len;
	test->cols_size = test->mtx_len;

	test->rows_addr = 2 * test->mtx_len;
	test->rows_size = test->nrows;

	test->vect_addr = test->nrows + 2 * test->mtx_len;
	test->vect_size = test->ncols;

	test->out_addr  = test->nrows + 2 * test->mtx_len + test->ncols;
	test->out_size  = test->nrows;

	// Allocate input buffers
	test->in_vals_buf = malloc0_check(sizeof(float) * test->vals_size);
	test->in_cols_buf = malloc0_check(sizeof(unsigned) * test->cols_size);
	test->in_rows_buf = malloc0_check(sizeof(unsigned) * test->rows_size);
	test->in_vect_buf = malloc0_check(sizeof(float) * test->vect_size);
	test->out_buf     = malloc0_check(sizeof(float) * test->out_size);

	test->in_vals_fx_buf = malloc0_check(sizeof(int) * test->vals_size);
	test->in_vect_fx_buf = malloc0_check(sizeof(int) * test->vect_size);
	test->out_fx_buf     = malloc0_check(sizeof(int) * test->out_size);

	// Read input data
	// Vals
	fscanf(fp, "%s\n", str_tmp); // Read separator line: %%
	for (i = 0; i < test->vals_size; i++) {
		float val;
		fscanf(fp, "%f\n", &val);
		test->in_vals_buf[i] = val;
	}
	// Cols
	fscanf(fp, "%s\n", str_tmp); // Read separator line: %%
	for (i = 0; i < test->cols_size; i++) {
		uint32_t col;
		fscanf(fp, "%u\n", &col);
		test->in_cols_buf[i] = col;
	}
	// Rows
	fscanf(fp, "%s\n", str_tmp); // Read separator line: %%
	fscanf(fp, "%s\n", str_tmp); // Read 0
	for (i = 0; i < test->rows_size; i++) {
		uint32_t row;
		fscanf(fp, "%u\n", &row);
		test->in_rows_buf[i] = row;
	}
	// Vect
	fscanf(fp, "%s\n", str_tmp); // Read separator line: %%
	for (i = 0; i < test->vect_size; i++) {
		float vect;
		fscanf(fp, "%f\n", &vect);
		test->in_vect_buf[i] = vect;  // FPDATA -> sc_bv and store it
	}

	fclose(fp);

	// Gold
	if (!strcmp(info->cmd, "test")) {
		test->gold_buf = malloc0_check(sizeof(float) * test->out_size);
	}
}



/*
 * spmv_alloc_contig
 */

static void spmv_alloc_contig(struct test_info *info)
{
	struct spmv_test *test = to_spmv(info);
	size_t size = spmv_size(test);

	printf("HW buf size: %zu\n", size);
	if (contig_alloc(size, &info->contig) == NULL)
		die_errno(__func__);
}


/*
 * spmv_init_bufs
 */

static void spmv_init_bufs(struct test_info *info)
{
	struct spmv_test *test = to_spmv(info);
	int i;

	// Convert to fixed point
	printf("Converting input data to fixed point...\n");
	for (i = 0; i < test->vals_size; i++)
		test->in_vals_fx_buf[i] = float_to_fixed32(test->in_vals_buf[i], 16);

	for (i = 0; i < test->vect_size; i++)
		test->in_vect_fx_buf[i] = float_to_fixed32(test->in_vect_buf[i], 16);

	// Memory layout

	//  ===========================  ^
	//  |  vals (input)  (float)  |  | mtx_len
	//  ===========================  -
	//  |  cols (input)  (uint)   |  | mtx_len
	//  ===========================  -
	//  |  rows (input)  (uint)   |  | nrows
	//  ===========================  -
	//  |  vect (input)  (float)  |  | ncols
	//  ===========================  -
	//  |  cols (output) (float)  |  | nrows
	//  ===========================  v

	contig_copy_to(info->contig, sizeof(int) * test->vals_addr, test->in_vals_fx_buf, sizeof(int) * test->vals_size);
	contig_copy_to(info->contig, sizeof(int) * test->cols_addr, test->in_cols_buf, sizeof(int) * test->cols_size);
	contig_copy_to(info->contig, sizeof(int) * test->rows_addr, test->in_rows_buf, sizeof(int) * test->rows_size);
	contig_copy_to(info->contig, sizeof(int) * test->vect_addr, test->in_vect_fx_buf, sizeof(int) * test->vect_size);
}

/*
 * smpv_set_access
 */

static void spmv_set_access(struct test_info *info)
{
	struct spmv_test *test = to_spmv(info);

	test->desc.nrows = test->nrows;
	test->desc.ncols = test->ncols;
	test->desc.max_nonzero = test->max_nonzero;
	test->desc.mtx_len = test->mtx_len;
	test->desc.vals_plm_size = test->vals_plm_size;
	test->desc.vect_fits_plm = test->vect_fits_plm;
}


/*
 * smpv_diff_ok
 */

#define MAX_REL_ERROR 0.003
#define MAX_ABS_ERROR 0.05

int check_error_threshold(float out, float gold)
{
    float error;

    if (gold != 0)
        error = fabs((gold - out) / gold);
    else if (out != 0)
        error = fabs((out - gold) / out);
    else
	error = 0;

    if (fabs(gold) >= 1) {
	return (error > MAX_REL_ERROR);
    } else {
	return (fabs(gold - out) > MAX_ABS_ERROR);
    }
}

static int check_gold(float *gold, float *out, int nrows, bool verbose)
{
	int i;
	int rtn = 0;

	for (i = 0; i < nrows; i++)
		if (check_error_threshold(out[i], gold[i])) {
			if (verbose)
				printf("out[%d]: result=%.15g; gold=%.15g\n", i, out[i], gold[i]);
			rtn++;
		}

	return rtn;
}

static bool spmv_diff_ok(struct test_info *info)
{
	struct spmv_test *t = to_spmv(info);
	int total_err = 0;
	int i;

	contig_copy_from(t->out_fx_buf, info->contig, spmv_out_addr(t), spmv_out_size(t));

	for (i = 0; i < t->out_size; i++) {
		t->out_buf[i] = fixed32_to_float(t->out_fx_buf[i], 16);
	}

	total_err = check_gold(t->gold_buf, t->out_buf, t->nrows, t->verbose);
	if (total_err)
		printf("%d mismatches in total\n", total_err);
	return !total_err;
}

void spmv_comp(struct test_info *info)
{
	struct spmv_test *t = to_spmv(info);
	long i, j;
	double sum, Si;

	for(i = 0; i < t->nrows; i++) {
		int tmp_begin;
		int tmp_end;
		sum = 0; Si = 0;

		if (i == 0)
			tmp_begin = 0;
		else
			tmp_begin= t->in_rows_buf[i - 1];

		tmp_end = t->in_rows_buf[i];

		for (j = tmp_begin; j < tmp_end; j++) {
			Si = t->in_vals_buf[j] * t->in_vect_buf[t->in_cols_buf[j]];
			sum = sum + Si;
		}

		t->gold_buf[i] = sum;
	}


}


/*
 * Test operations assignment
 */
static struct spmv_test spmv_test = {
	.info = {
		.name		= NAME,
		.devname	= DEVNAME,
		.alloc_buf	= spmv_alloc_buf,
		.alloc_contig	= spmv_alloc_contig,
		.init_bufs	= spmv_init_bufs,
		.set_access	= spmv_set_access,
		.diff_ok	= spmv_diff_ok,
		.comp           = spmv_comp,
		.esp		= &spmv_test.desc.esp,
		.cm		= SPMV_STRATUS_IOC_ACCESS,
	},
};

/*
 * main
 */
static void NORETURN usage(void)
{
	fprintf(stderr, "%s", usage_str);
	exit(1);
}

int main(int argc, char *argv[])
{
	int n_argc;

	if (argc < 3)
		usage();

	if (!strcmp(argv[2], "run"))
		n_argc = 3;
	else if (!strcmp(argv[2], "test"))
		n_argc = 6;
	else
		n_argc = 5;

	if (argc < n_argc)
		usage();

	spmv_test.verbose = false;
	if (n_argc > 3) {
		spmv_test.vals_plm_size = strtoul(argv[3], NULL, 0);
		spmv_test.vect_fits_plm = strtoul(argv[4], NULL, 0);
		spmv_test.in_file = argv[5];
		if (argc == 7) {
			if (strcmp(argv[6], "-v"))
				usage();
			spmv_test.verbose = true;
		}
	}

	return test_main(&spmv_test.info, argv[1], argv[2]);
}
