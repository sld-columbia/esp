/* Copyright (c) 2011-2023 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include "adder.h"

void init_buff_adder(token_t *in, token_t *gold)
{   
    int i;

    // Initialize input and output
    for (i = 0; i < IN_SIZE_DATA_ADDER; ++i)
        in[i] = i;
    for (; i < SIZE_DATA_ADDER; ++i)
        in[i] = 63;
    
    // Populate memory for gold output
    for (i = 0; i < OUT_SIZE_DATA_ADDER; ++i) {
        gold[i] = in[i*2] + in[i*2+1];
    }
}

int validate_adder(token_t *in, token_t *gold) 
{
    int i;
    int errors = 0;

    for (i = 0; i < OUT_SIZE_DATA_ADDER; i++) {
    if (in[i + IN_SIZE_DATA_ADDER] != gold[i]) {
        errors++;
        printf("ERROR: i mem mem_gold\n");
        printf("%d\n%lu\n%lu\n", i, in[i + IN_SIZE_DATA_ADDER], gold[i]);
    } else {
#ifdef VERBOSE
        printf("ERROR: i mem mem_gold\n");
        printf("%u\n%u\n%u\n", (uint32_t) i, (uint32_t) in[i + IN_SIZE_DATA_ADDER],
           (uint32_t) gold[i]);
#endif
    }
    }

    return errors;
}
