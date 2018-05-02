#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>

#include <my_stringify.h>
#include <test/wami.h>
#include <test/test.h>

#include <wami_params.h>
#include <wami_debayer.h>

#include <debayer.h>

#define DEVNAME	"/dev/debayer.0"
#define NAME "debayer"

struct debayer_test {
	struct test_info info;
	struct debayer_access desc;
	const char *in_file;
	const char *gold_file;
	uint16_t **bayer;
	rgb_pixel **debayer_sw;
	rgb_pixel **debayer_hw;
	rgb_pixel **debayer_gold;
	int rows;
	int cols;
};

static const char usage_str[] = "usage: debayer coherence cmd [in_file] [gold_file]\n"
	"  coherence: none|llc|full\n"
	"  cmd: config|test|run|hw\n"
	"\n"
	"Optional arguments: in_file applies to 'config', 'hw' and 'test':\n"
	"  in_file: path to input file\n"
	"\n"
        "The remaining option is only required by 'test':\n"
	"  gold_file: path to golden output file\n";

static inline struct debayer_test *to_test(struct test_info *info)
{
	return container_of(info, struct debayer_test, info);
}

/*
 * An exact match is expected for the debayer kernel, so we check
 * each pixel individually.
 */
static int validation(int rows, int cols,
		rgb_pixel debayer[rows-2*PAD][cols-2*PAD],
		rgb_pixel gold[rows-2*PAD][cols-2*PAD])
{
	int r, c;
	int success = 1;

	for (r = 0; success && r < rows - 2*PAD; r++) {
		for (c = 0; c < cols - 2*PAD; c++) {
			if (debayer[r][c].r != gold[r][c].r) {
				fprintf(stderr, "Validation error: red pixel mismatch at row=%d, col=%d : "
					"test value = %u, golden value = %u\n\n", r, c,
					debayer[r][c].r, gold[r][c].r);
				success = 0;
			}

			if (debayer[r][c].g != gold[r][c].g) {
				fprintf(stderr, "Validation error: green pixel mismatch at row=%d, col=%d : "
					"test value = %u, golden value = %u\n\n", r, c,
					debayer[r][c].g, gold[r][c].g);
				success = 0;
			}

			if (debayer[r][c].b != gold[r][c].b) {
				fprintf(stderr, "Validation error: blue pixel mismatch at row=%d, col=%d : "
					"test value = %u, golden value = %u\n\n", r, c,
					debayer[r][c].b, gold[r][c].b);
				success = 0;
			}
		}
	}
	return !success;
}

static void debayer_alloc_buf(struct test_info *info)
{
	struct debayer_test *test = to_test(info);
	size_t debayer_pix = (test->rows - 2 * PAD) * (test->cols - 2 * PAD);
	size_t bayer_pix = test->rows * test->cols;

	test->bayer = malloc0_check(sizeof(uint16_t) * bayer_pix);
	test->debayer_hw = malloc0_check(sizeof(rgb_pixel) * debayer_pix);
	if (!strcmp(info->cmd, "test")) {
		test->debayer_sw = malloc0_check(sizeof(rgb_pixel) * debayer_pix);
		test->debayer_gold = malloc0_check(sizeof(rgb_pixel) * debayer_pix);
	}
}

static void debayer_alloc_contig(struct test_info *info)
{
	struct debayer_test *test = to_test(info);
	size_t debayer_pix = (test->rows - 2 * PAD) * (test->cols - 2 * PAD);
	size_t bayer_pix = test->rows * test->cols;
	size_t size;

	size = sizeof(uint16_t) * bayer_pix + sizeof(rgb_pixel) * debayer_pix;
	if (contig_alloc(size, &info->contig))
		die_errno(__func__);
}

static void debayer_init_bufs(struct test_info *info)
{
	struct debayer_test *test = to_test(info);
	size_t debayer_pix = (test->rows - 2 * PAD) * (test->cols - 2 * PAD);
	size_t bayer_pix = test->rows * test->cols;

	wami_read_image_file(test->bayer, sizeof(uint16_t), test->in_file, sizeof(uint16_t) * bayer_pix);
	if (!strcmp(info->cmd, "test")) {
		/*
		 * Note: we read u16's into rgb_pixel's, which is unnecessary.
		 * We do this for convenience, since the validation function
		 * takes rgb_pixel's and we're too lazy to change that.
		 */
		wami_read_image_file(test->debayer_gold, sizeof(uint16_t), test->gold_file, sizeof(rgb_pixel) * debayer_pix);
	}
	contig_copy_to(info->contig, 0, test->bayer, sizeof(uint16_t) * bayer_pix);
}

static void debayer_set_access(struct test_info *info)
{
	struct debayer_test *test = to_test(info);

	test->desc.rows = test->rows;
	test->desc.cols = test->cols;
}

static void debayer_comp(struct test_info *info)
{
	struct debayer_test *test = to_test(info);

	wami_debayer(test->rows, test->cols,
		(rgb_pixel (*)[test->cols - 2 * PAD])test->debayer_sw,
		(uint16_t (*)[test->cols])test->bayer);
}

static void debayer_to_float(struct test_info *info)
{
	struct debayer_test *test = to_test(info);
	size_t debayer_pix = (test->rows - 2 * PAD) * (test->cols - 2 * PAD);
	size_t bayer_pix = test->rows * test->cols;
	size_t offset = sizeof(uint16_t) * bayer_pix;
	size_t size = sizeof(rgb_pixel) * debayer_pix;

	contig_copy_from(test->debayer_hw, info->contig, offset, size);
}

static bool debayer_diff_ok(struct test_info *info)
{
	struct debayer_test *test = to_test(info);
	bool err = false;

	printf("Software validation: ");
	if (validation(test->rows, test->cols,
			(rgb_pixel (*)[])test->debayer_sw,
			(rgb_pixel (*)[])test->debayer_gold)) {
		fprintf(stderr, "debayer SW failed\n");
		err = true;
	} else {
		printf(" OK\n");
	}
	printf("Hardware validation: ");
	if (validation(test->rows, test->cols,
			(rgb_pixel (*)[])test->debayer_hw,
			(rgb_pixel (*)[])test->debayer_gold)) {
		fprintf(stderr, "debayer HW failed\n");
		err = true;
	} else {
		printf(" OK\n");
	}
	return err;
}

static struct debayer_test debayer_test = {
	.info = {
		.name		= NAME,
		.devname	= DEVNAME,
		.alloc_buf	= debayer_alloc_buf,
		.alloc_contig	= debayer_alloc_contig,
		.init_bufs	= debayer_init_bufs,
		.set_access	= debayer_set_access,
		.comp		= debayer_comp,
		.to_float	= debayer_to_float,
		.diff_ok	= debayer_diff_ok,
		.esp		= &debayer_test.desc.esp,
		.cm		= DEBAYER_IOC_ACCESS,
	},
};

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
	else if (!strcmp(argv[2], "hw") || !strcmp(argv[2], "config"))
		n_argc = 4;
	else
		n_argc = 5;
	if (argc < n_argc)
		usage();

	if (n_argc > 2) {
		wami_image_file_dimensions(argv[3], &debayer_test.rows, &debayer_test.cols);

		debayer_test.in_file = argv[3];
		if (n_argc == 5)
			debayer_test.gold_file = argv[4];
	}

	return test_main(&debayer_test.info, argv[1], argv[2]);
}
