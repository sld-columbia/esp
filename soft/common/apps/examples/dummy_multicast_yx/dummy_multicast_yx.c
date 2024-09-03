// Copyright (c) 2011-2024 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include "libesp.h"
#include "dummy_multicast_yx_cfg.h"

/*static unsigned in_words_adj;
static unsigned out_words_adj;
static unsigned in_len;
static unsigned out_len;
static unsigned in_size;
static unsigned out_size;
static unsigned out_offset;
static unsigned size;
*/

/* User-defined code */
static int validate_buffer(token_t *mem)
{
    int i, j;
    int rtn = 0;
    for (j = 0; j < BATCH; j++)
        for (i = 0; i < TOKENS; i++)
            if (mem[i + j * TOKENS] != (mask | (token_t) i)) {
                printf("[%d, %d]: %lu\n", j, i, mem[i + j * TOKENS]);
                rtn++;
            }
    return rtn;
}


/* User-defined code */
static void init_buffer(token_t *mem)
{
    int i, j;
    for (j = 0; j < BATCH; j++)
        for (i = 0; i < TOKENS; i++)
            mem[i + j * TOKENS] = (mask | (token_t) i);
}


/* User-defined code */
/*static void init_parameters()
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
*/

int main(int argc, char **argv)
{
	int errors = 0;
    int dummy_buf_size = TOKENS * BATCH * sizeof(token_t) * NACC;

//	init_parameters();

    token_t *mem = (token_t *) esp_alloc(dummy_buf_size);

	init_buffer(mem);

	printf("\n====== Multicast P2P ======\n\n");
	printf("  .batch = %d\n", BATCH);
	printf("  .tokens = %d\n", TOKENS);

    for (int i = 0; i < NACC; i++) {
    	cfg_p2p[i].hw_buf = mem;
    }

	esp_run(cfg_p2p, NACC);

	printf("\n	** DONE **\n");

    for (int i = 0; i < NACC - 1; i++) {
    	errors += validate_buffer(&mem[(i+1) * BATCH * TOKENS]);
    }

    if (errors)
		printf("  + TEST FAIL: exceeding error count threshold\n");
    else
		printf("  + TEST PASS: not exceeding error count threshold\n");

	printf("\n============\n\n");
	return errors;
}
