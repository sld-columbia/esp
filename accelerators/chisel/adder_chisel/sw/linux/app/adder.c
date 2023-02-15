// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include "cfg.h"

static unsigned in_words_adj;
static unsigned out_words_adj;
static unsigned in_len;
static unsigned out_len;
static unsigned in_size;
static unsigned out_size;
static unsigned out_offset;
static unsigned size;


/* User-defined code */
static int validate_buffer(token_t *out, int *gold)
{
	unsigned errors = 0;

	return errors;
}


/* User-defined code */
static void init_buffer(token_t *in, int *gold)
{
}


/* User-defined code */
static void init_parameters()
{
	if (DMA_WORD_PER_BEAT(sizeof(token_t)) == 0) {
		in_words_adj = 2 * SIZE;
		out_words_adj = 2 * SIZE;
	} else {
		in_words_adj = round_up(2 * SIZE, DMA_WORD_PER_BEAT(sizeof(token_t)));
		out_words_adj = round_up(2 * SIZE, DMA_WORD_PER_BEAT(sizeof(token_t)));
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

	int *gold;
	token_t *buf;

	init_parameters();

	buf = (token_t *) esp_alloc(size);
	cfg_000[0].hw_buf = buf;
	gold = malloc(out_len * sizeof(int));

	init_buffer(buf, gold);

	printf("\n====== %s ======\n\n", cfg_000[0].devname);
	/* <<--print-params-->> */
	printf("  .readAddr = %d\n", readAddr);
	printf("  .size = %d\n", SIZE);
	printf("  .writeAddr = %d\n", writeAddr);
	printf("\n  ** START **\n");

	esp_run(cfg_000, NACC);

	printf("\n  ** DONE **\n");

	errors = validate_buffer(&buf[out_offset], gold);

	free(gold);
	esp_free(buf);

        if (errors)
		printf("  + TEST FAIL\n");
        else
		printf("  + TEST PASS\n");

	printf("\n====== %s ======\n\n", cfg_000[0].devname);

	return errors;
}
