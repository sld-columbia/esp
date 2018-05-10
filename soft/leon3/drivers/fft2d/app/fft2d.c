#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>

#include <my_stringify.h>
#include <test/test.h>
#include <test/fft.h>
#include "fft2d.h"

#define N_INT_BITS	20
#define PI 3.14159265358979323846
#define DEVNAME	"/dev/fft2d.0"
#define NAME "fft2d"

static const char usage_str[] = "usage: coherence cmd len_log [-v]\n"
	"  coherence: none|llc|full\n"
	"  cmd: config|test|run|hw\n"
	"  len_log: log2 of the number of elements of the FFT2D\n"
	"The remaining option is only optional for 'test':\n"
	"  -v: enable verbose output for output-to-gold comparison\n";

struct fft2d_test {
	struct test_info info;
	struct fft2d_access desc;
	float *a;
	float *t;
	size_t len_log;
	size_t len;
	size_t size;
	bool verbose;
};

static inline struct fft2d_test *to_test(struct test_info *info)
{
	return container_of(info, struct fft2d_test, info);
}

static void __fft2d(float *a, float *t, int len, int len_log, int sign)
{
	int i, j;

	/* 1D FFT on each row */
	for (i = 0; i < len; i++) {
		fft_comp(&a[2*i*len], len, len_log, sign, true);
	}

	/* 1D FFT on each column */
	for (i = 0; i < len; i++) {
		for (j = 0; j < len; j++) {
			t[2*j  ] = a[2*(len*j+i)  ];
			t[2*j+1] = a[2*(len*j+i)+1];
		}

		fft_comp(t, len, len_log, sign, true);

		for (j = 0; j < len; j++) {
			a[2*(len*j+i)  ] = t[2*j  ];
			a[2*(len*j+i)+1] = t[2*j+1];
		}
	}
}

static void fft2d_alloc_buf(struct test_info *info)
{
	struct fft2d_test *test = to_test(info);

	test->a = malloc0_check(test->size);
	if (!strcmp(info->cmd, "test")) {
		test->t = malloc0_check(2 * test->len * sizeof(float));
	}
}

static void fft2d_alloc_contig(struct test_info *info)
{
	struct fft2d_test *test = to_test(info);

	if (contig_alloc(test->size, &info->contig))
		die_errno(__func__);
}

static void fft2d_init_bufs(struct test_info *info)
{
	struct fft2d_test *test = to_test(info);
	int i;

	for (i = 0; i < 2 * test->len * test->len; i++)
		test->a[i] = (float) rand () / (float) RAND_MAX;
	contig_copy_to(info->contig, 0, test->a, test->size);
}

static void fft2d_to_sc_fixed(struct test_info *info)
{
	struct fft2d_test *test = to_test(info);

	fft_to_sc_fixed(info->contig, test->len * test->len, N_INT_BITS);
}

static void fft2d_set_access(struct test_info *info)
{
	struct fft2d_test *test = to_test(info);

	test->desc.log2 = test->len_log;
	test->desc.transpose = 1;
}

static void fft2d_comp(struct test_info *info)
{
	struct fft2d_test *test = to_test(info);

	__fft2d(test->a, test->t, test->len, test->len_log, -1);
}

static void fft2d_to_float(struct test_info *info)
{
	struct fft2d_test *test = to_test(info);

	fft_to_float(info->contig, test->len * test->len, N_INT_BITS);
}

static bool fft2d_diff_ok(struct test_info *info)
{
	struct fft2d_test *test = to_test(info);

	return fft_diff_ok(test->a, info->contig, test->len * test->len, test->verbose);
}

static struct fft2d_test fft2d_test = {
	.info = {
		.name		= NAME,
		.devname	= DEVNAME,
		.cm		= FFT2D_IOC_ACCESS,
		.alloc_buf	= fft2d_alloc_buf,
		.alloc_contig	= fft2d_alloc_contig,
		.init_bufs	= fft2d_init_bufs,
		.to_sc_fixed	= fft2d_to_sc_fixed,
		.set_access	= fft2d_set_access,
		.comp		= fft2d_comp,
		.to_float	= fft2d_to_float,
		.diff_ok	= fft2d_diff_ok,
		.esp		= &fft2d_test.desc.esp,
		.cm		= FFT2D_IOC_ACCESS,
	},
	.verbose = false,
};

static void NORETURN usage(void)
{
	fprintf(stderr, "%s", usage_str);
	exit(1);
}

int main(int argc, char *argv[])
{
	if (argc < 4)
		usage();

	sscanf(argv[3], "%zu", &fft2d_test.len_log);
	if (fft2d_test.len_log >= 12) {
		fprintf(stderr, "len_log out of range\n");
		exit(1);
	}
	fft2d_test.len = 1 << fft2d_test.len_log;
	fft2d_test.size = 2 * fft2d_test.len * fft2d_test.len * sizeof(float);

	if (argc == 5) {
		if (strcmp(argv[4], "-v"))
			usage();
		fft2d_test.verbose = true;
	}

	return test_main(&fft2d_test.info, argv[1], argv[2]);
}
