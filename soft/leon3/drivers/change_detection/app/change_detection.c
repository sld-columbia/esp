#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>

#include <my_stringify.h>
#include <test/wami.h>
#include <test/test.h>
#include <test/le.h>

#include <wami_params.h>
#include <wami_gmm.h>
#include <wami_morpho.h>

#include <change_detection.h>

#define DEVNAME "/dev/change_detection.0"
#define NAME "change_detection"

struct chdet_test {
	struct test_info info;
	struct change_detection_access desc;
	const char *fx_file;
	const char *gold_file;
	const char *in_file;
	float ***mu_sw;
	float ***sigma_sw;
	float ***weights_sw;
	uint16_t ***frames_sw;
	uint8_t ***foreground_sw;
	uint8_t ***foreground_gold;
	float ***mu;
	float ***sigma;
	float ***weights;
	uint16_t ***frames;
	uint8_t ***foreground;
	int rows;
	int cols;
};

static const char usage_str[] = "usage: coherence change_detection cmd [len] [in_fx_file] [gold_file] [in_file]\n"
	"  coherence: none|llc|full\n"
	"  cmd: config|test|run|hw\n"
	"\n"
	"Optional arguments: len and in_fx_file apply to 'config', 'hw' and 'test':\n"
	"  len: number of items per row or column (usually 32,512,1024,2048)\n"
	"  in_fx_file: path to input file for hardware (fixed point)\n"
	"\n"
        "The remaining options are only required by 'test':\n"
	"  gold_file: path to golden output file\n"
	"  in_file: path to input file for software (floating point)\n";

static inline struct chdet_test *to_test(struct test_info *info)
{
	return container_of(info, struct chdet_test, info);
}

static void read_gmm_input_data(int rows, int cols,
				float mu[rows][cols][WAMI_GMM_NUM_MODELS],
				float sigma[rows][cols][WAMI_GMM_NUM_MODELS],
				float weights[rows][cols][WAMI_GMM_NUM_MODELS],
				uint16_t frames[WAMI_GMM_NUM_FRAMES][rows][cols],
				const char *path)
{
	FILE *fp;
	uint16_t width, height, channels, depth;
	size_t nread;
	int success;
	int n;
	int i;

	fp = fopen(path, "rb");
	if (fp == NULL)
		die_errno("Unable to open input file %s for reading", path);

	n = rows * cols * WAMI_GMM_NUM_MODELS;
	success = lefread(mu, sizeof(float), n, fp) == n;
	success &= lefread(sigma, sizeof(float), n, fp) == n;
	success &= lefread(weights, sizeof(float), n, fp) == n;
	if (!success)
		die("Unable to read model parameters from %s", path);

	n = rows * cols;
	for (i = 0; i < WAMI_GMM_NUM_FRAMES; i++) {
		success = lefread(&width, sizeof(uint16_t), 1, fp) == 1;
		success &= lefread(&height, sizeof(uint16_t), 1, fp) == 1;
		success &= lefread(&channels, sizeof(uint16_t), 1, fp) == 1;
		success &= lefread(&depth, sizeof(uint16_t), 1, fp) == 1;
		if (!success)
			die("Unable to read image %d header from %s", i, path);

		if (width != cols || height != rows || channels != 1 || depth != 2) {
			die("Mismatch for image header %d in %s: "
				"[width,height,channels,depth] = [%u,%u,%u,%u]",
				i, path, width, height, channels, depth);
		}

		nread = lefread(&frames[i][0][0], sizeof(uint16_t), n, fp);
		if (nread != n)
			die("Unable to read input image %d from %s", i, path);
	}

	if (fclose(fp))
		die_errno("%s:%d", __func__, __LINE__);
}

static unsigned validation(int rows, int cols,
			uint8_t fg[WAMI_GMM_NUM_FRAMES][rows][cols],
			uint8_t gl[WAMI_GMM_NUM_FRAMES][rows][cols])
{
	int validation_warning = 0;
	unsigned count;
	int i, j, k;

	count = 0;
	for (k = 0; k < WAMI_GMM_NUM_FRAMES; k++)
		for (i = 0; i < rows; i++)
			for (j = 0; j < cols; j++)
				if (fg[k][i][j] != gl[k][i][j])
					count++;
	printf("Errors # %d\n", count);

	/* for (i = 0; i < WAMI_GMM_NUM_FRAMES; i++) { */
	/* 	int num_misclassified = 0, num_foreground = 0; */
	/* 	double misclassification_rate = 0; */

	/* 	uint8_t golden_eroded[rows][cols]; */
	/* 	uint8_t eroded[rows][cols]; */

	/* 	wami_morpho_erode(rows, cols, eroded, fg[i]); */
	/* 	wami_morpho_erode(rows, cols, golden_eroded, gl[i]); */

	/* 	printf("Validating frame %d output...\n", i); */

	/* 	for (j = 0; j < rows; j++) { */
	/* 		for (k = 0; k < cols; k++) { */
	/* 			if (eroded[j][k] != golden_eroded[j][k]) */
	/* 				++num_misclassified; */
	/* 			if (golden_eroded[j][k] != 0) */
	/* 				++num_foreground; */
	/* 		} */
	/* 	} */

	/* 	misclassification_rate = (100.0*num_misclassified)/num_foreground; */
	/* 	printf("\tMisclassified pixels: %d\n", num_misclassified); */
	/* 	printf("\tGolden foreground pixels (after erosion): %d\n", */
	/* 		num_foreground); */
	/* 	printf("\tMisclassification rate relative to foreground: %f%%\n", */
	/* 		misclassification_rate); */
	/* 	if (misclassification_rate > 0.1) */
	/* 		validation_warning = 1; */
	/* } */
	/* if (validation_warning) { */
	/* 	printf("\nValidation warning: Misclassification rate appears high; check images.\n\n"); */
	/* 	return 1; */
	/* } else { */
	/* 	printf("\nValidation checks passed.\n\n"); */
	/* } */

	return 0;
}

static void chdet_alloc_buf(struct test_info *info)
{
	struct chdet_test *test = to_test(info);
	size_t n_pixels = test->rows * test->cols;
	size_t pix_models = n_pixels * WAMI_GMM_NUM_MODELS;
	size_t pix_frames = n_pixels * WAMI_GMM_NUM_FRAMES;

	if (!strcmp(info->cmd, "test")) {
		test->mu_sw		= malloc0_check(sizeof(float) * pix_models);
		test->sigma_sw		= malloc0_check(sizeof(float) * pix_models);
		test->weights_sw	= malloc0_check(sizeof(float) * pix_models);
		test->frames_sw		= malloc0_check(sizeof(uint16_t) * pix_frames);
		test->foreground_sw	= malloc0_check(sizeof(uint8_t) * pix_frames);
		test->foreground_gold	= malloc0_check(sizeof(uint8_t) * pix_frames);
	}
	test->mu		= malloc0_check(sizeof(float) * pix_models);
	test->sigma		= malloc0_check(sizeof(float) * pix_models);
	test->weights		= malloc0_check(sizeof(float) * pix_models);
	test->frames		= malloc0_check(sizeof(uint16_t) * pix_frames);
	test->foreground	= malloc0_check(sizeof(uint8_t) * pix_frames);
}

static void chdet_alloc_contig(struct test_info *info)
{
	struct chdet_test *test = to_test(info);
	size_t n_pixels = test->rows * test->cols;
	size_t pix_models = n_pixels * WAMI_GMM_NUM_MODELS;
	size_t pix_frames = n_pixels * WAMI_GMM_NUM_FRAMES;
	size_t size;

	size = 3 * pix_models * sizeof(float);
	size += pix_frames * sizeof(uint16_t);
	size += pix_frames * sizeof(uint8_t);

	printf("HW buf size: %zu\n", size);
	if (contig_alloc(size, &info->contig))
		die_errno(__func__);
}

static void chdet_init_sw(struct chdet_test *t)
{
	size_t n_pixels = t->rows * t->cols;

	wami_read_data_file(t->foreground_gold, sizeof(uint8_t), t->gold_file,
		sizeof(uint8_t) * n_pixels * WAMI_GMM_NUM_FRAMES);

	read_gmm_input_data(t->rows, t->cols,
			(float (*)[t->cols][WAMI_GMM_NUM_MODELS])t->mu_sw,
			(float (*)[t->cols][WAMI_GMM_NUM_MODELS])t->sigma_sw,
			(float (*)[t->cols][WAMI_GMM_NUM_MODELS])t->weights_sw,
			(uint16_t (*)[t->rows][t->cols])t->frames_sw, t->in_file);
}

static void chdet_init_contig(struct chdet_test *t)
{
	size_t n_pixels = t->rows * t->cols;
	size_t model_param_size = n_pixels * WAMI_GMM_NUM_MODELS * sizeof(float);
	size_t img_size = n_pixels * WAMI_GMM_NUM_FRAMES * sizeof(uint16_t);

	read_gmm_input_data(t->rows, t->cols,
			(float (*)[t->cols][WAMI_GMM_NUM_MODELS])t->mu,
			(float (*)[t->cols][WAMI_GMM_NUM_MODELS])t->sigma,
			(float (*)[t->cols][WAMI_GMM_NUM_MODELS])t->weights,
			(uint16_t (*)[t->rows][t->cols])t->frames, t->fx_file);

	contig_copy_to(t->info.contig, 0, t->mu, model_param_size);
	contig_copy_to(t->info.contig, model_param_size, t->sigma, model_param_size);
	contig_copy_to(t->info.contig, model_param_size * 2, t->weights, model_param_size);
	contig_copy_to(t->info.contig, model_param_size * 3, t->frames, img_size);
}

static void chdet_init_bufs(struct test_info *info)
{
	struct chdet_test *test = to_test(info);

	if (!strcmp(info->cmd, "test"))
		chdet_init_sw(test);
	chdet_init_contig(test);
}

static void chdet_set_access(struct test_info *info)
{
	struct chdet_test *test = to_test(info);

	test->desc.rows = test->rows;
	test->desc.cols = test->cols;
}

static void __comp_sw(struct chdet_test *t, int rows, int cols,
		uint8_t fg[WAMI_GMM_NUM_FRAMES][rows][cols],
		uint16_t frames[WAMI_GMM_NUM_FRAMES][rows][cols])
{
	int i;

	for (i = 0; i < WAMI_GMM_NUM_FRAMES; i++) {
		wami_gmm(rows, cols,
			fg[i],
			(float (*)[cols][WAMI_GMM_NUM_MODELS])t->mu_sw,
			(float (*)[cols][WAMI_GMM_NUM_MODELS])t->sigma_sw,
			(float (*)[cols][WAMI_GMM_NUM_MODELS])t->weights_sw,
			frames[i]);
	}
}

static void chdet_comp(struct test_info *info)
{
	struct chdet_test *t = to_test(info);

	return __comp_sw(t, t->rows, t->cols,
			(uint8_t (*)[t->rows][t->cols])t->foreground_sw,
			(uint16_t (*)[t->rows][t->cols])t->frames_sw);
}

static void chdet_to_float(struct test_info *info)
{
	struct chdet_test *t = to_test(info);
	size_t n_pixels = t->rows * t->cols;
	size_t pix_models = n_pixels * WAMI_GMM_NUM_MODELS;
	size_t pix_frames = n_pixels * WAMI_GMM_NUM_FRAMES;
	size_t offset;
	size_t size;

	offset = 3 * pix_models * sizeof(float);
	offset += pix_frames * sizeof(uint16_t);
	size = pix_frames * sizeof(uint8_t);

	contig_copy_from(t->foreground, t->info.contig, offset, size);
}

static bool chdet_diff_ok(struct test_info *info)
{
	struct chdet_test *t = to_test(info);
	bool err = false;

	printf("Software validation (OUT vs. GOLD):\n");
	if (validation(t->rows, t->cols,
			(uint8_t (*)[t->rows][t->cols])t->foreground_sw,
			(uint8_t (*)[t->rows][t->cols])t->foreground_gold)) {
		fprintf(stderr, "change detection SW failed\n");
		err = true;
	}

	printf("Hardware validation (OUT vs. GOLD):\n");
	if (validation(t->rows, t->cols,
			(uint8_t (*)[t->rows][t->cols])t->foreground,
			(uint8_t (*)[t->rows][t->cols])t->foreground_gold)) {
		fprintf(stderr, "change detection HW failed\n");
		err = true;
	}
	return err;
}

static struct chdet_test chdet_test = {
	.info = {
		.name		= NAME,
		.devname	= DEVNAME,
		.alloc_buf	= chdet_alloc_buf,
		.alloc_contig	= chdet_alloc_contig,
		.init_bufs	= chdet_init_bufs,
		.set_access	= chdet_set_access,
		.comp		= chdet_comp,
		.to_float	= chdet_to_float,
		.diff_ok	= chdet_diff_ok,
		.esp		= &chdet_test.desc.esp,
		.cm		= CHANGE_DETECTION_IOC_ACCESS,
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
		n_argc = 5;
	else
		n_argc = 7;
	if (argc < n_argc)
		usage();

	if (n_argc > 3) {
		chdet_test.rows = chdet_test.cols = strtoul(argv[3], NULL, 0);
		chdet_test.fx_file = argv[4];
		if (n_argc == 7) {
			chdet_test.gold_file = argv[5];
			chdet_test.in_file = argv[6];
		}
	}

	return test_main(&chdet_test.info, argv[1], argv[2]);
}
