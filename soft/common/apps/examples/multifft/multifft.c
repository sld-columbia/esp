// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include "libesp.h"
#include "multifft_cfg.h"
#include "utils/fft_utils.h"

static unsigned in_words_adj;
static unsigned out_words_adj;
static unsigned in_len;
static unsigned out_len;
static unsigned in_size;
static unsigned out_size;
static unsigned out_offset;
static unsigned size;

const float ERR_TH = 0.05;

/* User-defined code */
static int validate_buffer(token_t *out, float *gold)
{
	int j;
	unsigned errors = 0;
	int total;

	total = 2 * len;

	for (j = 0; j < total; j++) {
		native_t val = fx2float(out[j], FX_IL);
		if ((fabs(gold[j] - val) / fabs(gold[j])) > ERR_TH)
			errors++;
	}

	printf("  + Relative error > %.02f for %d output values out of %d\n", ERR_TH, errors, total);

	return errors;
}


/* User-defined code */
static void init_buffer(token_t *in, float *gold, bool p2p)
{
	int j, p, iters;
	const float LO = -1.0;
	const float HI = 1.0;

	srand((unsigned int) time(NULL));

	/* Repeat FFT for NACC times on the same memory region */
	if (p2p)
		iters = NACC;
	else
		iters = 1;

	for (j = 0; j < 2 * len; j++) {
		float scaling_factor = (float) rand () / (float) RAND_MAX;
		gold[j] = LO + scaling_factor * (HI - LO);
	}

	// convert input to fixed point
	for (j = 0; j < 2 * len; j++)
		in[j] = float2fx((native_t) gold[j], FX_IL);

	for (p = 0; p < iters; p++) {
		// Compute golden output
		fft_comp(gold, len, log_len,  -1, DO_BITREV);
	}
}


/* User-defined code */
static void init_parameters()
{
	if (DMA_WORD_PER_BEAT(sizeof(token_t)) == 0) {
		in_words_adj = 2 * len;
		out_words_adj = 2 * len;
	} else {
		in_words_adj = round_up(2 * len, DMA_WORD_PER_BEAT(sizeof(token_t)));
		out_words_adj = round_up(2 * len, DMA_WORD_PER_BEAT(sizeof(token_t)));
	}
	in_len = in_words_adj;
	out_len =  out_words_adj;
	in_size = in_len * sizeof(token_t);
	out_size = out_len * sizeof(token_t);
	out_offset = 0;
	size = (out_offset * sizeof(token_t)) + out_size;
}


int main(int argc, char **argv)
{
	int errors;
	char key;

	float *gold[3];
	token_t *buf[3];

	const float ERROR_COUNT_TH = 0.01;

	int k;

	init_parameters();

	for (k = 0; k < NACC; k++) {
		buf[k] = (token_t *) esp_alloc(NACC * size);
		gold[k] = malloc(NACC * out_len * sizeof(float));
	}

	init_buffer(buf[0], gold[0], false);

	printf("\n====== Non coherent DMA ======\n\n");
	printf("  .len = %d\n", len);
	printf("  .log_len = %d\n", log_len);

	printf("  ** Press ENTER to START ** ");
	scanf("%c", &key);

	cfg_nc[0].hw_buf = buf[0];
	esp_run(cfg_nc, 1);

	printf("\n	** DONE **\n");

	errors = validate_buffer(&buf[0][out_offset], gold[0]);

		if (((float) errors / (float) len) > ERROR_COUNT_TH)
		printf("  + TEST FAIL: exceeding error count threshold\n");
		else
		printf("  + TEST PASS: not exceeding error count threshold\n");

	printf("\n============\n\n");


	/* LLC-Coherent test */
	init_buffer(buf[0], gold[0], false);

	printf("\n====== LLC-coherent DMA ======\n\n");
	printf("  .len = %d\n", len);
	printf("  .log_len = %d\n", log_len);

	printf("  ** Press ENTER to START ** ");
	scanf("%c", &key);

	cfg_llc[0].hw_buf = buf[0];
	esp_run(cfg_llc, 1);

	printf("\n	** DONE **\n");

	errors = validate_buffer(&buf[0][out_offset], gold[0]);

		if (((float) errors / (float) len) > ERROR_COUNT_TH)
		printf("  + TEST FAIL: exceeding error count threshold\n");
		else
		printf("  + TEST PASS: not exceeding error count threshold\n");

	printf("\n============\n\n");


	/* Fully-Coherent test */
	init_buffer(buf[0], gold[0], false);

	printf("\n====== Fully-coherent DMA ======\n\n");
	printf("  .len = %d\n", len);
	printf("  .log_len = %d\n", log_len);

	printf("  ** Press ENTER to START ** ");
	scanf("%c", &key);

	cfg_fc[0].hw_buf = buf[0];
	esp_run(cfg_fc, 1);

	printf("\n	** DONE **\n");

	errors = validate_buffer(&buf[0][out_offset], gold[0]);

		if (((float) errors / (float) len) > ERROR_COUNT_TH)
		printf("  + TEST FAIL: exceeding error count threshold\n");
		else
		printf("  + TEST PASS: not exceeding error count threshold\n");

	printf("\n============\n\n");


	/* Parallel test */
	for (k = 0; k < NACC; k++) {
		init_buffer(buf[k], gold[k], false);
	}

	printf("\n====== Concurrent execution ======\n\n");
	printf("  fft.0 -> fully coherent\n");
	printf("  fft.1 -> LLC-coherent DMA\n");
	printf("  fft.2 -> non-coherent DMA\n");
	printf("  .len = %d\n", len);
	printf("  .log_len = %d\n", log_len);

	printf("  ** Press ENTER to START ** ");
	scanf("%c", &key);

	for (k = 0; k < NACC; k++)
		cfg_parallel[k].hw_buf = buf[k];

	esp_run(cfg_parallel, NACC);

	printf("\n	** DONE **\n");

	for (k = 0; k < NACC; k++) {
		errors = validate_buffer(&buf[k][out_offset], gold[k]);

		if (((float) errors / (float) (len * NACC)) > ERROR_COUNT_TH)
		printf("  + TEST FAIL fft.%d: exceeding error count threshold\n", k);
		else
		printf("  + TEST PASS fft.%d: not exceeding error count threshold\n", k);
	}

	printf("\n============\n\n");


	/* P2P test */
	init_buffer(buf[0], gold[0], true);

	printf("\n====== Point-to-point Test ======\n\n");
	printf("  fft.0 (NC DMA) -> fft.1 -> fft.2 (NC DMA)\n");
	printf("  .len = %d\n", len);
	printf("  .log_len = %d\n", log_len);

	printf("  ** Press ENTER to START ** ");
	scanf("%c", &key);

	for (k = 0; k < NACC; k++)
		cfg_p2p[k].hw_buf = buf[0];

	esp_run(cfg_p2p, NACC);

	printf("\n	** DONE **\n");

	errors = validate_buffer(&buf[0][out_offset], gold[0]);

		if (((float) errors / (float) (len * NACC)) > ERROR_COUNT_TH)
		printf("  + TEST FAIL: exceeding error count threshold\n");
		else
		printf("  + TEST PASS: not exceeding error count threshold\n");

	printf("\n============\n\n");

	for (k = 0; k < NACC; k++) {
		free(gold[k]);
		esp_free(buf[k]);
	}

	return errors;
}
