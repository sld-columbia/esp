// Copyright (c) 2011-2022 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include "libesp.h"
#include "cfg.h"
#include <esp_accelerator.h>
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

	unsigned errors = 0;
	/*iint i;
	int j;

	for (i = 0; i < 1; i++)
		for (j = 0; j < 3 * START_VORTEX; j++)
			if (gold[i * out_words_adj + j] != out[i * out_words_adj + j])
				errors++;
	*/
        if(*out != *gold)
        {  
           errors+=1;
        }
	
        printf("out = %ld, gold = %ld \n", *out, *gold); 
	return errors;
}


/* User-defined code */
static void init_buffer(token_t *in, token_t * gold)
{
	int i;
	int j;

	for (i = 0; i < 1; i++)
		for (j = 0; j < 3 * START_VORTEX; j++)
			in[i * in_words_adj + j] = (token_t) j;

	for (i = 0; i < 1; i++)
		for (j = 0; j < 3 * START_VORTEX; j++)
			gold[i * out_words_adj + j] = (token_t) j;
}

static void init_buf(token_t *in)
{
  #include "input.h"
}


int fibonacci(int n)
{
        if (n <= 1)
          return n;
        return fibonacci(n - 1) + fibonacci(n - 2);
}

/**
// User-defined code
static void init_parameters()
{
	if (DMA_WORD_PER_BEAT(sizeof(token_t)) == 0) {
		in_words_adj = 3 * START_VORTEX;
		out_words_adj = 3 * START_VORTEX;
	} else {
		in_words_adj = round_up(3 * START_VORTEX, DMA_WORD_PER_BEAT(sizeof(token_t)));
		out_words_adj = round_up(3 * START_VORTEX, DMA_WORD_PER_BEAT(sizeof(token_t)));
	}
	in_len = in_words_adj * (1);
	out_len =  out_words_adj * (1);
	in_size = in_len * sizeof(token_t);
	out_size = out_len * sizeof(token_t);
	out_offset = 0;
	size = (out_offset * sizeof(token_t)) + out_size;
}
**/

int main(int argc, char **argv)
{
	int errors;

	token_t *gold;
	token_t *acc_out; 
	token_t *buf;
        token_t *mem; 

        //init_parameters();

	// esp_alloc(out_size);
        unsigned int _fibonacci_bin_len_in_words = 7780/4;
        
	size_t mem_size = _fibonacci_bin_len_in_words * sizeof(token_t);	
	mem = esp_alloc(mem_size); 
	init_buf(mem); 
	intptr_t mem_top = (intptr_t)mem;
	int input_val = 9;
	// init_buffer(buf, gold);
        // printf("  memory buffer base-address = %lx\n", (intptr_t)(mem));        

	buf = (token_t *) (mem_top+0x7fff0); // 0xa0200000
	*buf = input_val; 
	cfg_000[0].hw_buf = mem;
        printf("cfg set to buf\n");
        //gt_vortex_cfg_000.BASE_ADDR = mem_top;	
	acc_out = (token_t *) (mem_top+0x7fff4); 
	printf("print acc_out set\n");
        gold = esp_alloc(sizeof(token_t));
        *gold = fibonacci(input_val); 
	printf("\n====== %s ======\n\n", cfg_000[0].devname);
        // cfg_000[0].BASE_ADDR = mem_top; 
	// cfg_000[0].START_VORTEX = 1; 	
	/* <<--print-params-->> */
	printf("  .VX_BUSY_INT = %d\n", VX_BUSY_INT);
	printf("  .BASE_ADDR = %d\n", BASE_ADDR);
	printf("  .START_VORTEX = %d\n", START_VORTEX);
	printf("\n  ** START **\n");

	esp_run(cfg_000, NACC);

	printf("\n  ** DONE **\n");

	errors = validate_buffer(acc_out, gold);

	//free(gold);
	//esp_free(buf);

	if (!errors)
		printf("+ Test PASSED\n");
	else
		printf("+ Test FAILED\n");

	printf("\n====== %s ======\n\n", cfg_000[0].devname);

	return errors;
}
