// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include "libesp.h"
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
static int validate_buffer(token_t *out, token_t *gold)
{
	int i;
	int j;
	unsigned errors = 0;

	for (i = 0; i < /* <<--number of transfers-->> */; i++)
		for (j = 0; j < /* <<--data_out_size-->> */; j++)
			if (gold[i * out_words_adj + j] != out[i * out_words_adj + j])
				errors++;

	return errors;
}


/* User-defined code */
static void init_buffer(token_t *in, token_t * gold)
{
	int i;
	int j;

	for (i = 0; i < /* <<--number of transfers-->> */; i++)
		for (j = 0; j < /* <<--data_in_size-->> */; j++)
			in[i * in_words_adj + j] = (token_t) j;

	for (i = 0; i < /* <<--number of transfers-->> */; i++)
		for (j = 0; j < /* <<--data_out_size-->> */; j++)
			gold[i * out_words_adj + j] = (token_t) j;
}


/* User-defined code */
static void init_parameters()
{
	if (DMA_WORD_PER_BEAT(sizeof(token_t)) == 0) {
		in_words_adj = /* <<--data_in_size-->> */;
		out_words_adj = /* <<--data_out_size-->> */;
	} else {
		in_words_adj = round_up(/* <<--data_in_size-->> */, DMA_WORD_PER_BEAT(sizeof(token_t)));
		out_words_adj = round_up(/* <<--data_out_size-->> */, DMA_WORD_PER_BEAT(sizeof(token_t)));
	}
	in_len = in_words_adj * (/* <<--number of transfers-->> */);
	out_len =  out_words_adj * (/* <<--number of transfers-->> */);
	in_size = in_len * sizeof(token_t);
	out_size = out_len * sizeof(token_t);
	out_offset = /* <<--store-offset-->> */;
	size = (out_offset * sizeof(token_t)) + out_size;
}


int main(int argc, char **argv)
{
	int errors;

	token_t *gold;
	token_t *buf;

	init_parameters();

	buf = (token_t *) esp_alloc(size);
	cfg_000[0].hw_buf = buf;
    
	gold = malloc(out_size);

	init_buffer(buf, gold);

	printf("\n====== %s ======\n\n", cfg_000[0].devname);
	/* <<--print-params-->> */
	printf("\n  ** START **\n");

	esp_run(cfg_000, NACC);

	printf("\n  ** DONE **\n");

	errors = validate_buffer(&buf[out_offset], gold);

	free(gold);
	esp_free(buf);

	if (!errors)
		printf("+ Test PASSED\n");
	else
		printf("+ Test FAILED\n");

	printf("\n====== %s ======\n\n", cfg_000[0].devname);

	return errors;
}
