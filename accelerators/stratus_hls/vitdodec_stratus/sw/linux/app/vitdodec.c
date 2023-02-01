// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include "do_decoding.h"
#include "cfg.h"

static unsigned in_words_adj;
static unsigned out_words_adj;
static unsigned in_len;
static unsigned out_len;
static unsigned in_size;
static unsigned out_size;
static unsigned out_offset;
static unsigned size;


/* TEST-Specific Inputs */
static const unsigned char PARTAB[256] = {
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
         1, 0, 0, 1, 0, 1, 1, 0,
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
         0, 1, 1, 0, 1, 0, 0, 1,
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
         1, 0, 0, 1, 0, 1, 1, 0,
         0, 1, 1, 0, 1, 0, 0, 1,
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
         1, 0, 0, 1, 0, 1, 1, 0,
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
         0, 1, 1, 0, 1, 0, 0, 1,
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
         1, 0, 0, 1, 0, 1, 1, 0,
         0, 1, 1, 0, 1, 0, 0, 1,
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
         1, 0, 0, 1, 0, 1, 1, 0,
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
         0, 1, 1, 0, 1, 0, 0, 1,
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
}; 


#define ABS(x) ((x > 0) ? x : -x)

/* simple not quite random implementation of rand() when stdlib is not available */
static unsigned long int next = 42;
int irand(void)
{
	unsigned int rand_tmp;
	next = next * 1103515245 + 12345;
	rand_tmp = (unsigned int) (next / 65536) % 32768;
	return ((int) rand_tmp);

}


/* User-defined code */
static int validate_buffer(token_t *out, token_t *gold)
{
	int i;
	int j;
	unsigned errors = 0;

	for (i = 0; i < 1; i++)
		for (j = 0; j < 18585; j++)
			if (gold[i * out_words_adj + j] != out[i * out_words_adj + j])
				errors++;

	return errors;
}


/* User-defined code */
static void init_buffer(token_t *in, token_t * gold)
{
	int i;
	int j;
	int imi = 0;

	unsigned char depunct_ptn[6] = {1, 1, 0, 0, 0, 0}; /* PATTERN_1_2 Extended with zeros */

        int polys[2] = { 0x6d, 0x4f };
        for(int i=0; i < 32; i++) {
            in[imi]    = (polys[0] < 0) ^ PARTAB[(2*i) & ABS(polys[0])] ? 1 : 0;
            in[imi+32] = (polys[1] < 0) ^ PARTAB[(2*i) & ABS(polys[1])] ? 1 : 0;
            imi++;
        }
        if (imi != 32) { printf("ERROR : imi = %u and should be 32\n", imi); }
        imi += 32;

        /* printf("Set up brtab27\n"); */
        if (imi != 64) { printf("ERROR : imi = %u and should be 64\n", imi); }
        /* imi = 64; */
        for (int ti = 0; ti < 6; ti ++) {
            in[imi++] = depunct_ptn[ti];
        }
        /* printf("Set up depunct\n"); */
        in[imi++] = 0;
        in[imi++] = 0;

        for (int j = imi; j < in_size; j++) {
	    int bval = irand()  & 0x01;
            /* printf("Setting up in[%d] = %d\n", j, bval); */
            in[j] = bval;
        }

#if(1)
	{
		printf(" memory in   = ");
		int limi = 0;
		for (int li = 0; li < 32; li++) {
			printf("%u", in[limi++]);
			if ((li % 8) == 7) { printf(" "); }
		}
		printf("\n      brtb1    ");
		for (int li = 0; li < 32; li++) {
			printf("%u", in[limi++]);
			if ((li % 8) == 7) { printf(" "); }
		}
		printf("\n      depnc    ");
		for (int li = 0; li < 8; li++) {
			printf("%u", in[limi++]);
		}
		printf("\n      depdta   ");
		for (int li = 0; li < 32; li++) {
			printf("%u", in[limi++]);
			if ((li % 8) == 7) { printf(" "); }
		}
		printf("\n");
        }
#endif
	/* Pre-zero the output memeory */
	for (i = 0; i < 1; i++)
		for (j = 0; j < 18585; j++)
			gold[i * out_words_adj + j] = (token_t) 0;

	/* Compute the gold output in software! */
	printf("Computing Gold output\n");
	do_decoding(data_bits, cbps, ntraceback, (unsigned char *)in, (unsigned char*)gold);

	/* Re-set the input memory ? */

#if(1)
	{
		printf(" memory in   = ");
		int limi = 0;
		for (int li = 0; li < 32; li++) {
			printf("%u", in[limi++]);
			if ((li % 8) == 7) { printf(" "); }
		}
		printf("\n      brtb1    ");
		for (int li = 0; li < 32; li++) {
			printf("%u", in[limi++]);
			if ((li % 8) == 7) { printf(" "); }
		}
		printf("\n      depnc    ");
		for (int li = 0; li < 8; li++) {
			printf("%u", in[limi++]);
		}
		printf("\n      depdta   ");
		for (int li = 0; li < 32; li++) {
			printf("%u", in[limi++]);
			if ((li % 8) == 7) { printf(" "); }
		}
		printf("\n");
        }
#endif
}


/* User-defined code */
static void init_parameters()
{
	if (DMA_WORD_PER_BEAT(sizeof(token_t)) == 0) {
		in_words_adj = 24852;
		out_words_adj = 18585;
	} else {
		in_words_adj = round_up(24852, DMA_WORD_PER_BEAT(sizeof(token_t)));
		out_words_adj = round_up(18585, DMA_WORD_PER_BEAT(sizeof(token_t)));
	}
	in_len = in_words_adj * (1);
	out_len =  out_words_adj * (1);
	in_size = in_len * sizeof(token_t);
	out_size = out_len * sizeof(token_t);
	out_offset = in_len;
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
	printf("  .cbps = %d\n", cbps);
	printf("  .ntraceback = %d\n", ntraceback);
	printf("  .data_bits = %d\n", data_bits);
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
