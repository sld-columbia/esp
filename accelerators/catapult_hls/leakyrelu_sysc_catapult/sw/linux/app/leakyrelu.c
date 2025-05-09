// Copyright (c) 2011-2024 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include "libesp.h"
#include "cfg.h"

static unsigned batch;
static unsigned row;
static unsigned vec_len;
static unsigned in_a_len;
static unsigned in_b_len;
static unsigned out_len;
static unsigned in_a_size;
static unsigned in_b_size;
static unsigned out_size;
static unsigned in_a_offset;
static unsigned in_b_offset;
static unsigned out_offset;

/* User-defined code */
static int validate_buffer(token_t *out, token_t *gold)
{
	int i;
	int j;
	unsigned errors = 0;

	for (i=0; i<batch; i++){
		for (j=0; j<row; j++){
			for (k=0; k<vec_len; k++){
				if (gold[(row*vec_len)*i + vec_len*j + k] != out[(row*vec_len)*i + vec_len*j + k])
				errors++;
			}
		}
	}
	return errors;
}


/* User-defined code */
static void init_buffer(token_t *in token_t * gold)
{

	int i;
	int j;
	int k;
	for (i=0; i<batch; i++){
		for (j=0; j<row; j++){
			for (k=0; k<vec_len; k++){
				float data = ((i * 8 + j - k) % 32) + 0.25;
				token_t data_fxd = float_to_fixed32(data, 16);
				in[(row*vec_len)*i + vec_len*j + k] = data_fxd;
			}
		}
	}
	for (i=0; i<batch; i++){
		for (j=0; j<row; j++){
			for (k=0; k<vec_len; k++){
				float data = ((i * 8 + j + k) % 32) + 0.15;
				token_t data_fxd = float_to_fixed32(data, 16);
				in[in_a_len + (row*vec_len)*i + vec_len*j + k] = data_fxd;
			}
		}
	}

	float out_gold;
	for (i=0; i<batch; i++){
		for (j=0; j<row; j++){
			for (k=0; k<vec_len; k++){
				float data_a = fixed32_to_float(in[(row*vec_len)*i + vec_len*j + k], 16);
				float data_b = fixed32_to_float(in[in_a_len + (row*vec_len)*i + vec_len*j + k], 16);
				
				out_gold = data1*data2;

				if (out_gold < 0){
					out_gold *= 0.5;
				}
				gold[(row*vec_len)*i + vec_len*j + k]= float_to_fixed32(out_gold, 16);
			}
		}
	}
}


/* User-defined code */
static void init_parameters()
{
	if (DMA_WORD_PER_BEAT(sizeof(token_t)) == 0) {
		in_a_len        = batch*(row*VEC_LEN);
		in_b_len        = batch*(row*VEC_LEN);
		out_len         = batch*(row*VEC_LEN);
	} else {
		in_a_len        = round_up(batch*(row*VEC_LEN), DMA_WORD_PER_BEAT(sizeof(token_t)));
		in_b_len        = round_up(batch*(row*VEC_LEN), DMA_WORD_PER_BEAT(sizeof(token_t)));
		out_len         = round_up(batch*(row*VEC_LEN), DMA_WORD_PER_BEAT(sizeof(token_t)));
	}

	in_a_size = in_a_len * sizeof(token_t);
	in_b_size = in_b_len * sizeof(token_t);
	out_size = out_len * sizeof(token_t);
	in_a_offset	= 0;
	in_b_offset	= in_a_len;
	out_offset = in_a_len + in_b_len;
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
	printf("  .mac_n = %d\n", mac_n);
	printf("  .mac_vec = %d\n", mac_vec);
	printf("  .mac_len = %d\n", mac_len);
	printf("  .batch = %d\n", batch);
	printf("  .row = %d\n", row);
	printf("  .addrA = %d\n", in_a_offset);
	printf("  .addrB = %d\n", in_b_offset);
	printf("  .addrO = %d\n", out_offset);
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
