/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>
//#include "utils/vitdodec_utils.h"

//#include "vitdodec_minimal.h"

typedef int8_t vit_token_t;

//static unsigned DMA_WORD_PER_BEAT(unsigned _st)
//{
//return (sizeof(void *) / _st);
//}


#define SLD_VITDODEC 0x030
#define DEV_NAME "sld,vitdodec_stratus"

/* <<--params-->> */
const int32_t cbps = 48;
const int32_t ntraceback = 5;
const int32_t data_bits = 288;

static unsigned in_words_adj;
static unsigned out_words_adj;
static unsigned in_len;
static unsigned out_len;
static unsigned in_size;
static unsigned out_size;
static unsigned out_offset;
static unsigned mem_size;

/* Size of the contiguous chunks for scatter/gather */
#define CHUNK_SHIFT 20
#define CHUNK_SIZE BIT(CHUNK_SHIFT)
#define NCHUNK(_sz) ((_sz % CHUNK_SIZE == 0) ?		\
			(_sz / CHUNK_SIZE) :		\
			(_sz / CHUNK_SIZE) + 1)

/* User defined registers */
/* <<--regs-->> */
#define VITDODEC_CBPS_REG 0x48
#define VITDODEC_NTRACEBACK_REG 0x44
#define VITDODEC_DATA_BITS_REG 0x40

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

static int validate_buf(vit_token_t *out, vit_token_t *gold)
{
	int i;
	int j;
	unsigned errors = 0;
    int k;
	for (i = 0; i < 1; i++)
		for (j = 0; j < 288; j++) {
            k = i * out_words_adj + j;
			if (gold[k] != out[k]) {
				printf("%d - exp: %d, got: %d\n", k, gold[k], out[k]);
                errors++;
            }
        }
	return errors;
}


#define ABS(x) ((x > 0) ? x : -x)

static void init_buf (vit_token_t *in, vit_token_t * gold)
{
    int i;
	int j;
	int imi = 0;

    #include "vitdodec_minimal_vals.h"
}


