// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include <math.h>
#include <stdio.h>

#define __round_mask(x, y) ((y)-1)
#define round_up(x, y) ((((x)-1) | __round_mask(x, y))+1)


typedef int32_t token_t;
typedef float native_t;


void init_parameters(int32_t batch_size_x, int32_t num_batch_x,
		     int32_t batch_size_k, int32_t num_batch_k,
		     unsigned *in_words_adj, unsigned *out_words_adj,
		     unsigned *in_len, unsigned *out_len,
		     unsigned *in_size, unsigned *out_size, 
		     unsigned *out_offset,
		     unsigned *mem_size, unsigned dma_word_per_beat)
{
    if (dma_word_per_beat == 0) {
      *in_words_adj = 3*batch_size_x * num_batch_x+5*batch_size_k * num_batch_k;
      *out_words_adj = 2*batch_size_x * num_batch_x;
    } else {
      *in_words_adj = round_up(3*batch_size_x * num_batch_x+5*batch_size_k * num_batch_k, dma_word_per_beat);
      *out_words_adj = round_up(2*batch_size_x * num_batch_x, dma_word_per_beat);
    }


    *in_len = (*in_words_adj) * (1);
    *out_len =  (*out_words_adj) * (1);
    *in_size = (*in_len) * sizeof(token_t);
    *out_size = (*out_len) * sizeof(token_t);
    *out_offset = *in_len;
    *mem_size = ((*out_offset) * sizeof(token_t)) + (*out_size);
}






int diff(native_t *gold, native_t *out, int len, float diff_thresh)
{
    float diff;
    int errors = 0;

    for (int i = 0; i < len; i++) {

        if(!gold[i] && !out[i]) {
	   diff = 0;
	} else if(!gold[i]) {// gold = 0, can't do division 
	   diff = fabs((gold[i] - out[i])/out[i]);
	} else { // gold != 0
	   diff = fabs((gold[i] - out[i])/gold[i]);
	   //	   printf("i = %d, out = %f, gold = %f\n", i, out[i], gold[i]);
	}

	if (diff > diff_thresh)
	    errors++;
    }

    return errors;
}


int validate_buffer(native_t *out, native_t *gold, unsigned out_len)
{

    uint32_t errors = 0;
    float error_rate;

    float diff_thresh = 0.05; 
    float error_rate_thresh = 0.01;

    errors = diff(gold, out, out_len, diff_thresh);

    error_rate = (float) errors/out_len;

    if (error_rate > error_rate_thresh)
      return 1;
    else 
      return 0;

}




