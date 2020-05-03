#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include "espacc.h"

int main(int argc, char **argv) {

    printf("****start*****\n");

    unsigned k = 0;
    int num_blocks = 4;

    int size_in = (num_blocks + 1) * WORDS_IN_CHUNK;
    int size_out = (num_blocks + 0) * WORDS_IN_CHUNK;

    dma_word_t *in  = (dma_word_t*) malloc(size_in * sizeof(dma_word_t));
    dma_word_t *tmp = (dma_word_t*) malloc(size_in * sizeof(dma_word_t));
    dma_word_t *out = (dma_word_t*) malloc(size_out * sizeof(dma_word_t));

    dma_info_t *load  = (dma_info_t*) malloc((num_blocks + 1) * sizeof(dma_info_t));
    dma_info_t *store = (dma_info_t*) malloc((num_blocks + 0) * sizeof(dma_info_t));

    // Init key + data

    for (unsigned i = 0; i < size_in; i++)
    {
	    for (unsigned j = 0; j < VALUES_PER_WORD; j++)
        {
	        in[i].word[j] = (ap_uint<8>) k++;
	    }
    }

    // Initialize output data

    for (unsigned i = 0; i < size_out; i++)
    {
	    for (unsigned j = 0; j < VALUES_PER_WORD; j++)
        {
	        out[i].word[j] = (ap_uint<8>) 33;
	    }
    }

    // Encrypt the data with AES

    dma_word_t *ptr = tmp + WORDS_IN_CHUNK;
    top(ptr, in, 0, num_blocks, load, store);

    /* for (unsigned i = 0; i < size_in; i++) */
		/* for (unsigned j = 0; j < VALUES_PER_WORD; j++) */
            /* std::cout << "tmp[" << i << "][" << j << "] = " << tmp[i].word[j] << std::endl; */

    // Use same key for decryption

    for (unsigned i = 0; i < WORDS_IN_CHUNK; i++)
    {
	    for (unsigned j = 0; j < VALUES_PER_WORD; j++)
        {
	        tmp[i].word[j] = in[i].word[j];
	    }
    }

    /* for (unsigned i = 0; i < size_in; i++) */
		/* for (unsigned j = 0; j < VALUES_PER_WORD; j++) */
            /* std::cout << "tmp[" << i << "][" << j << "] = " << tmp[i].word[j] << std::endl; */

    // Decrypt the data with AES

    top(out, tmp, 1, num_blocks, load, store);

    // Decrypted data = encrypted data?

    int errors = 0;

    for (unsigned i = 0; i < size_out; i++)
    {
	    for (unsigned j = 0; j < VALUES_PER_WORD; j++)
        {
            if (out[i].word[j] != in[i + WORDS_IN_CHUNK].word[j])
                errors++;
	    }
    }

    if (errors)
	    std::cout << "Test FAILED with " << errors << " errors." << std::endl;
    else
	    std::cout << "Test PASSED." << std::endl;

    // Free memory

    free(in);
    free(tmp);
    free(out);

    free(load);
    free(store);

    return 0;
}
