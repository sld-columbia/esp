/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include "vitdodec.h"

int validate_buf_vitdodec(token_vit_t *out, token_vit_t *gold)
{
	int i;
	int j;
	unsigned errors = 0;

	for (i = 0; i < 1; i++)
		for (j = 0; j < 18585; j++)
			if (gold[i * out_len_vit + j] != out[i * out_len_vit + j])
				errors++;

	return errors;
}


int irand(void)
{
	unsigned int rand_tmp;
	next = next * 1103515245 + 12345;
	rand_tmp = (unsigned int) (next / 65536) % 32768;
	return ((int) rand_tmp);

}

void init_buf_vitdodec(token_vit_t *in, token_vit_t * gold)
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
        //if (imi != 32) { printf("ERROR : imi = %u and should be 32\n", imi); }
        imi += 32;

        /* printf("Set up brtab27\n"); */
        //if (imi != 64) { printf("ERROR : imi = %u and should be 64\n", imi); }
        /* imi = 64; */
        for (int ti = 0; ti < 6; ti ++) {
            in[imi++] = depunct_ptn[ti];
        }
        /* printf("Set up depunct\n"); */
        in[imi++] = 0;
        in[imi++] = 0;

        for (int j = imi; j < in_size_vit; j++) {
	    int bval = irand()  & 0x01;
            /* printf("Setting up in[%d] = %d\n", j, bval); */
            in[j] = bval;
        }

	/* Pre-zero the output memeory */
	for (i = 0; i < 1; i++)
		for (j = 0; j < 18585; j++)
			gold[i * out_len_vit + j] = (token_vit_t) 0;


}
