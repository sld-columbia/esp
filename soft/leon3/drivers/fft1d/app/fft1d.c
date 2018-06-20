#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>

#include <my_stringify.h>
#include <test/test.h>
#include <test/fft.h>
#include <fft1d.h>

#define N_INT_BITS	16
#define PI 3.14159265358979323846
#define DEVNAME	"/dev/fft1d.0"
#define NAME "fft1d"

static const char usage_str[] = "usage: fft1d coherence cmd len_log [-v]\n"
	"  coherence: none|llc|recall|full\n"
	"  cmd: config|test|run|hw\n"
	"  len_log: log2 of the number of elements of the FFT\n"
	"The remaining option is only optional for 'test':\n"
	"  -v: enable verbose output for output-to-gold comparison\n";

struct fft1d_test {
	struct test_info info;
	struct fft1d_access desc;
	float *a;
	size_t len_log;
	size_t len;
	size_t size;
	bool verbose;
};

static inline struct fft1d_test *to_test(struct test_info *info)
{
	return container_of(info, struct fft1d_test, info);
}

static void fft1d_alloc_buf(struct test_info *info)
{
	struct fft1d_test *test = to_test(info);

	test->a = malloc0_check(test->size);
}

static void fft1d_alloc_contig(struct test_info *info)
{
	struct fft1d_test *test = to_test(info);

	if (contig_alloc(test->size, &info->contig))
		die_errno(__func__);
}

static void fft1d_init_bufs(struct test_info *info)
{
	struct fft1d_test *test = to_test(info);
	int i;

	for (i = 0; i < 2 * test->len; i++)
		test->a[i] = (float) rand () / (float) RAND_MAX;
	/* the hardware does not do this so we have to do it here */
	fft_bit_reverse(test->a, test->len, test->len_log);

	contig_copy_to(info->contig, 0, test->a, test->size);
}

static void fft1d_to_sc_fixed(struct test_info *info)
{
	struct fft1d_test *test = to_test(info);

	fft_to_sc_fixed(info->contig, test->len, N_INT_BITS);
}

static void fft1d_set_access(struct test_info *info)
{
	struct fft1d_test *test = to_test(info);

	test->desc.log2 = test->len_log;
}

static void fft1d_comp(struct test_info *info)
{
	struct fft1d_test *test = to_test(info);

	fft_comp(test->a, test->len, test->len_log, -1, false);
}

static void fft1d_to_float(struct test_info *info)
{
	struct fft1d_test *test = to_test(info);

	fft_to_float(info->contig, test->len, N_INT_BITS);
}

static bool fft1d_diff_ok(struct test_info *info)
{
	struct fft1d_test *test = to_test(info);

	return fft_diff_ok(test->a, info->contig, test->len, test->verbose);
}

static struct fft1d_test fft1d_test = {
	.info = {
		.name		= NAME,
		.devname	= DEVNAME,
		.cm		= FFT1D_IOC_ACCESS,
		.alloc_buf	= fft1d_alloc_buf,
		.alloc_contig	= fft1d_alloc_contig,
		.init_bufs	= fft1d_init_bufs,
		.to_sc_fixed	= fft1d_to_sc_fixed,
		.set_access	= fft1d_set_access,
		.comp		= fft1d_comp,
		.to_float	= fft1d_to_float,
		.diff_ok	= fft1d_diff_ok,
		.esp		= &fft1d_test.desc.esp,
		.cm		= FFT1D_IOC_ACCESS,
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

	sscanf(argv[3], "%zu", &fft1d_test.len_log);
	if (fft1d_test.len_log >= 16) {
		fprintf(stderr, "len_log out of range\n");
		exit(1);
	}
	fft1d_test.len = 1 << fft1d_test.len_log;
	fft1d_test.size = fft1d_test.len * sizeof(float) * 2;

	if (argc == 5) {
		if (strcmp(argv[4], "-v"))
			usage();
		fft1d_test.verbose = true;
	}

	return test_main(&fft1d_test.info, argv[1], argv[2]);
}
