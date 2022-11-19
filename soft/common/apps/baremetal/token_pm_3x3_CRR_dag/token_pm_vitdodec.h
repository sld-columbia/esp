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

typedef int8_t viterbi_token_t;

//static unsigned DMA_WORD_PER_BEAT(unsigned _st)
//{
//return (sizeof(void *) / _st);
//}


#define SLD_VITDODEC 0x030
#define VIT_DEV_NAME "sld,vitdodec_stratus"

/* <<--params-->> */
const int32_t cbps = 48;
const int32_t ntraceback = 5;
const int32_t data_bits = 288;

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

static int viterbi_validate_buf(viterbi_token_t *out, viterbi_token_t *gold)
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

static void init_buf (viterbi_token_t *in, viterbi_token_t * gold)
{
    int i;
	int j;
	int imi = 0;

    #include "vitdodec_minimal_vals.h"
}


static void viterbi_probe(struct esp_device **espdevs_viterbi)
{
    int ndev;

    // Search for the device
    printf("Probing for Viterbi accs, scanning device tree... \n");

    ndev = probe(espdevs_viterbi, VENDOR_SLD, SLD_VITDODEC, VIT_DEV_NAME);
    if (ndev == 0)
	printf("Viterbi not found\n");
    else
	printf("Found %d Viterbi instances\n",ndev);
}

static unsigned viterbi_init_params()
{
	if (DMA_WORD_PER_BEAT(sizeof(viterbi_token_t)) == 0) {
		in_words_adj = 24852;
		out_words_adj = 18585;
	} else {
		in_words_adj = round_up(24852, DMA_WORD_PER_BEAT(sizeof(viterbi_token_t)));
		out_words_adj = round_up(18585, DMA_WORD_PER_BEAT(sizeof(viterbi_token_t)));
	}
	in_len = in_words_adj * (1);
	out_len = out_words_adj * (1);
	in_size = in_len * sizeof(viterbi_token_t);
	out_size = out_len * sizeof(viterbi_token_t);
	out_offset  = in_len;
	mem_size = (out_offset * sizeof(viterbi_token_t)) + out_size;
	return mem_size;
}

void setup_viterbi(struct esp_device *dev, viterbi_token_t *gold_viterbi, viterbi_token_t *mem_viterbi, unsigned **ptable)
{
    int i;
    // Allocate memory
    gold_viterbi = aligned_malloc(out_size);
    mem_viterbi = aligned_malloc(mem_size);

    //printf("  memory buffer base-address = %p\n", mem_viterbi);
    // Alocate and populate page table
    ptable = aligned_malloc(NCHUNK(mem_size) * sizeof(unsigned *));
    for (i = 0; i < NCHUNK(mem_size); i++)
        ptable[i] = (unsigned *) &mem_viterbi[i * (CHUNK_SIZE / sizeof(viterbi_token_t))];
    
    #ifdef DEBUG
	    printf("  memory buffer base-address = %p\n", mem_viterbi);
	    printf("  ptable = %p\n", ptable);
	    printf("  nchunk = %lu\n", NCHUNK(mem_size));
    #endif

    //printf("  Generate input...\n");
    init_buf(mem_viterbi, gold_viterbi);

    // Pass common configuration parameters

    iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
    iowrite32(dev, COHERENCE_REG, ACC_COH_NONE);

    iowrite32(dev, PT_ADDRESS_REG, (unsigned long) ptable);

    iowrite32(dev, PT_NCHUNK_REG, NCHUNK(mem_size));
    iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);

    // Use the following if input and output data are not allocated at the default offsets
    iowrite32(dev, SRC_OFFSET_REG, 0x0);
    iowrite32(dev, DST_OFFSET_REG, 0x0);

    // Pass accelerator-specific configuration parameters
    /* <<--regs-config-->> */
    iowrite32(dev, VITDODEC_CBPS_REG, cbps);
    iowrite32(dev, VITDODEC_NTRACEBACK_REG, ntraceback);
    iowrite32(dev, VITDODEC_DATA_BITS_REG, data_bits);
}
