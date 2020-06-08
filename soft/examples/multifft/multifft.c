#include "libesp.h"
#include "multifft_cfg.h"
#include "test/fft_test.h"

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
static int validate_buffer(token_t *out, float *gold, bool parallel)
{
	int j;
	unsigned errors = 0;
	int total;

	if (parallel)
		total = 2 * len * NACC;
	else
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
static void init_buffer(token_t *in, float *gold, bool parallel, bool p2p)
{
	int k, j, p, ktotal, iters;
	const float LO = -1.0;
	const float HI = 1.0;

	if (parallel && p2p) {
		printf("  Error: parallel and p2p can't are mutually exclusive\n");
		exit(EXIT_FAILURE);
	}

	srand((unsigned int) time(NULL));

	/* Execute NACC times FFT on NACC independent memory regions */
	if (parallel)
		ktotal = NACC;
	else
		ktotal = 1;

	/* Repeat FFT for NACC times on the same memory region */
	if (p2p)
		iters = NACC;
	else
		iters = 1;

	for (k = 0; k < ktotal; k++) {
		for (j = 0; j < 2 * len; j++) {
			float scaling_factor = (float) rand () / (float) RAND_MAX;
			gold[k * in_words_adj + j] = LO + scaling_factor * (HI - LO);
		}

		// convert input to fixed point
		for (j = 0; j < 2 * len; j++)
			in[k * in_words_adj + j] = float2fx((native_t) gold[k * in_words_adj + j], FX_IL);

		for (p = 0; p < iters; p++) {
			// Compute golden output
			fft_comp(&gold[k * in_words_adj], len, log_len,  -1,  DO_BITREV);
		}
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

	float *gold;
	token_t *buf;

        const int ERROR_COUNT_TH = 0.001;

	int k;

	init_parameters();

    buf = (token_t *) esp_alloc(NACC * size);
	gold = malloc(NACC * out_len * sizeof(float));
	init_buffer(buf, gold, false, false);

    printf("\n====== Non coherent DMA ======\n\n");
	printf("  .len = %d\n", len);
	printf("  .log_len = %d\n", log_len);

	printf("  ** Press ENTER to START ** ");
	scanf("%c", &key);

	cfg_nc[0].hw_buf = buf;;
    esp_run(cfg_nc, 1);

	printf("\n  ** DONE **\n");

	errors = validate_buffer(&buf[out_offset], gold, false);

        if ((errors / len) > ERROR_COUNT_TH)
		printf("  + TEST FAIL: exceeding error count threshold\n");
        else
		printf("  + TEST PASS: not exceeding error count threshold\n");

	printf("\n============\n\n");


	/* LLC-Coherent test */
	init_buffer(buf, gold, false, false);

	printf("\n====== LLC-coherent DMA ======\n\n");
	printf("  .len = %d\n", len);
	printf("  .log_len = %d\n", log_len);

	printf("  ** Press ENTER to START ** ");
	scanf("%c", &key);
	
    cfg_llc[0].hw_buf = buf;
	esp_run(cfg_llc, 1);

	printf("\n  ** DONE **\n");

	errors = validate_buffer(&buf[out_offset], gold, false);

        if ((errors / len) > ERROR_COUNT_TH)
		printf("  + TEST FAIL: exceeding error count threshold\n");
        else
		printf("  + TEST PASS: not exceeding error count threshold\n");

	printf("\n============\n\n");


	/* Fully-Coherent test */
	init_buffer(buf, gold, false, false);

	printf("\n====== Fully-coherent DMA ======\n\n");
	printf("  .len = %d\n", len);
	printf("  .log_len = %d\n", log_len);

	printf("  ** Press ENTER to START ** ");
	scanf("%c", &key);

    cfg_fc[0].hw_buf = buf;
	esp_run(cfg_fc, 1);

	printf("\n  ** DONE **\n");

	errors = validate_buffer(&buf[out_offset], gold, false);

        if ((errors / len) > ERROR_COUNT_TH)
		printf("  + TEST FAIL: exceeding error count threshold\n");
        else
		printf("  + TEST PASS: not exceeding error count threshold\n");

	printf("\n============\n\n");


	/* Parallel test */
	for (k = 0; k < NACC; k++) {
		cfg_parallel[k].desc.fft_desc.src_offset = size * k;
		cfg_parallel[k].desc.fft_desc.dst_offset = size * k;
	}

	init_buffer(buf, gold, true, false);

	printf("\n====== Concurrent execution ======\n\n");
	printf("  fft.0 -> fully coherent\n");
	printf("  fft.1 -> LLC-coherent DMA\n");
	printf("  fft.2 -> non-coherent DMA\n");
	printf("  .len = %d\n", len);
	printf("  .log_len = %d\n", log_len);

	printf("  ** Press ENTER to START ** ");
	scanf("%c", &key);

    for (k = 0; k < NACC; k++)
	    cfg_parallel[k].hw_buf = buf;

    esp_run(cfg_parallel, NACC);

	printf("\n  ** DONE **\n");

	errors = validate_buffer(&buf[out_offset], gold, true);

        if ((errors / (len * NACC)) > ERROR_COUNT_TH)
		printf("  + TEST FAIL: exceeding error count threshold\n");
        else
		printf("  + TEST PASS: not exceeding error count threshold\n");

	printf("\n============\n\n");


	/* P2P test */
	init_buffer(buf, gold, false, true);

	printf("\n====== Point-to-point Test ======\n\n");
	printf("  fft.0 (NC DMA) -> fft.1 -> fft.2 (NC DMA)\n");
	printf("  .len = %d\n", len);
	printf("  .log_len = %d\n", log_len);

	printf("  ** Press ENTER to START ** ");
	scanf("%c", &key);

    for (k = 0; k < NACC; k++)
        cfg_p2p[k].hw_buf = buf;
	esp_run(cfg_p2p, NACC);

	printf("\n  ** DONE **\n");

	errors = validate_buffer(&buf[out_offset], gold, false);

        if ((errors / len) > ERROR_COUNT_TH)
		printf("  + TEST FAIL: exceeding error count threshold\n");
        else
		printf("  + TEST PASS: not exceeding error count threshold\n");

	printf("\n============\n\n");

	free(gold);
	esp_free(buf);

	return errors;
}
