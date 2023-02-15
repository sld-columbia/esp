// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include "../inc/espacc_config.h"
#include "../inc/espacc.h"

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

int main(int argc, char **argv) {

    printf("****start*****\n");

    int nbursts = 4;
    int size_in = nbursts * SIZE_IN_CHUNK;
    int size_out = nbursts * SIZE_OUT_CHUNK;

    dma_word_t *in=(dma_word_t*) malloc(size_in * sizeof(dma_word_t));
    word_t *inbuff= (word_t*) malloc(size_in * VALUES_PER_WORD * sizeof(word_t));
    dma_word_t *out= (dma_word_t*) malloc(size_out * sizeof(dma_word_t));
    word_t *outbuff_gold= (word_t*) malloc(size_out * VALUES_PER_WORD * sizeof(word_t));
    dma_info_t load;
    dma_info_t store;

    if (in == NULL || out == NULL)
    {
    	printf("null operator...FAIL");
    	exit(1);
    }

    // Prepare input data
    unsigned k = 0;
    for(unsigned i = 0; i < size_in; i++) {
	for(unsigned j = 0; j < VALUES_PER_WORD; j++) {
	    in[i].word[j] = (word_t) k++;
	}
    }

    // Initialize output data
    for(unsigned i = 0; i < size_out; i++) {
	for(unsigned j = 0; j < VALUES_PER_WORD; j++) {
	    out[i].word[j] = 33;
	}
    }

    // Call the TOP function
    top(out, in, nbursts, load, store);

    // Validate

    for(unsigned i = 0; i < size_in; i++) {
	for(unsigned j = 0; j < VALUES_PER_WORD; j++) {
	    inbuff[i * VALUES_PER_WORD + j] = in[i].word[j];
	}
    }

    for (unsigned i = 0; i < nbursts; i++)
	compute(&inbuff[SIZE_IN_CHUNK_DATA * i], &outbuff_gold[SIZE_OUT_CHUNK_DATA * i]);

    int errors = 0;
    for(unsigned i = 0; i < size_out; i++) {
	for(unsigned j = 0; j < VALUES_PER_WORD; j++) {
	    if (out[i].word[j] != outbuff_gold[i * VALUES_PER_WORD + j]) {
		errors++;
		std::cout << "ERROR: " << i*VALUES_PER_WORD+j << " : " << out[i].word[j]
			  << " : " << outbuff_gold[i * VALUES_PER_WORD + j] << std::endl;
	    }
	}
    }

    if (errors)
	std::cout << "Test FAILED with " << errors << " errors." << std::endl;
    else
	std::cout << "Test PASSED." << std::endl;

    // Free memory

    free(in);
    free(inbuff);
    free(out);
    free(outbuff_gold);

    return 0;
}
