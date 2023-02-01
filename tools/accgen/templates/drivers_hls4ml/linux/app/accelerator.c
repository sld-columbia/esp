// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include "libesp.h"
#include "cfg.h"

static unsigned in_words = /* <<--data_in_size-->> */;
static unsigned out_words = /* <<--data_out_size-->> */;
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

	// Validation expecting results of a classifier in the range [0, 1]
	// MODIFY the validation below if needed.
	int threshold = fl2fx(0.5);

	for (i = 0; i < nbursts; i++)
		for (j = 0; j < out_words; j++)
		        if ((gold[i * out_words_adj + j] < threshold &&
			     out[i * out_words_adj + j] >= threshold) ||
			    (gold[i * out_words_adj + j] > threshold &&
			     out[i * out_words_adj + j] <= threshold))
				errors++;

	return errors;
}


/* User-defined code */
static void init_buffer(token_t *in, token_t *gold)
{
	int i;
	int j;
	float val_float;
	FILE *fd = NULL;

	// Load input
	if((fd = fopen("data/tb_input_features.dat", "r")) == (FILE*) NULL)
	{
		printf("[ERROR] Could not open tb_input_features.dat\n");
		exit(1);
	}

	val_float = 0;
	fscanf(fd, "%f", &val_float);
	for (i = 0; i < nbursts; i++)
		for (j = 0; j < in_words; j++) {
			if (feof(fd)) {
				printf("Error: unexpected EOF data/tb_input_features.dat");
				fclose(fd);
				exit(EXIT_FAILURE);
			}
			in[i * in_words_adj + j] = (token_t) fl2fx(val_float);
			fscanf(fd, "%f", &val_float);
		}
	fclose(fd);

	// Load golden output
	if((fd = fopen("data/tb_output_predictions_fixed.dat", "r")) == (FILE*) NULL)
	{
		printf("[ERROR] Could not open tb_output_predictions_fixed.dat\n");
		exit(1);
	}

	val_float = 0;
	fscanf(fd, "%f", &val_float);
	for (i = 0; i < nbursts; i++)
		for (j = 0; j < out_words; j++) {
			if (feof(fd)) {
				printf("Error: unexpected EOF data/tb_output_predictions_fixed.dat");
				fclose(fd);
				exit(EXIT_FAILURE);
			}
			gold[i * out_words_adj + j] = (token_t) fl2fx(val_float);
			fscanf(fd, "%f", &val_float);
	}
	fclose(fd);
}


/* User-defined code */
static void init_parameters()
{
	if (DMA_WORD_PER_BEAT(sizeof(token_t)) == 0) {
		in_words_adj = in_words;
		out_words_adj = out_words;
	} else {
		in_words_adj = round_up(in_words, DMA_WORD_PER_BEAT(sizeof(token_t)));
		out_words_adj = round_up(out_words, DMA_WORD_PER_BEAT(sizeof(token_t)));
	}
	in_len = in_words_adj * (nbursts);
	out_len =  out_words_adj * (nbursts);
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
		printf("    + Test PASSED\n");
	else
		printf("    + Test FAILED\n");

	printf("\n====== %s ======\n\n", cfg_000[0].devname);

	return errors;
}
