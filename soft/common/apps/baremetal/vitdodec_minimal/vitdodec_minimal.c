/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>

#include "vitdodec_minimal.h"

typedef int8_t token_t;

static unsigned DMA_WORD_PER_BEAT(unsigned _st)
{
        return (sizeof(void *) / _st);
}


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

static int validate_buf(token_t *out, token_t *gold)
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

static void init_buf (token_t *in, token_t * gold)
{
    int i;
	int j;
	int imi = 0;

    #include "vitdodec_minimal_vals.h"
}


int main(int argc, char * argv[])
{
	int i;
	int n;
	int ndev;
	struct esp_device dev;
	unsigned done;
	unsigned **ptable = NULL;
	token_t *mem;
	token_t *gold;
	unsigned errors = 0;
    int coherence = ACC_COH_RECALL;
	uint64_t cycles_start = 0, cycles_end = 0;

	if (DMA_WORD_PER_BEAT(sizeof(token_t)) == 0) {
		in_words_adj = 24852;
		out_words_adj = 18585;
	} else {
		in_words_adj = round_up(24852, DMA_WORD_PER_BEAT(sizeof(token_t)));
		out_words_adj = round_up(18585, DMA_WORD_PER_BEAT(sizeof(token_t)));
	}
	in_len = in_words_adj * (1);
	out_len = out_words_adj * (1);
	in_size = in_len * sizeof(token_t);
	out_size = out_len * sizeof(token_t);
	out_offset  = in_len;
	mem_size = (out_offset * sizeof(token_t)) + out_size;

    dev.addr = ACC_ADDR;

    // Allocate memory
    gold = aligned_malloc(out_size);
    mem = aligned_malloc(mem_size);

    //printf("  memory buffer base-address = %p\n", mem);
    // Alocate and populate page table
    ptable = aligned_malloc(NCHUNK(mem_size) * sizeof(unsigned *));
    for (i = 0; i < NCHUNK(mem_size); i++)
        ptable[i] = (unsigned *) &mem[i * (CHUNK_SIZE / sizeof(token_t))];
    //printf("  ptable = %p\n", ptable);
    //printf("  nchunk = %lu\n", NCHUNK(mem_size));

    //printf("  Generate input...\n");
    init_buf(mem, gold);

    // Pass common configuration parameters

    iowrite32(&dev, SELECT_REG, ioread32(&dev, DEVID_REG));
    iowrite32(&dev, COHERENCE_REG, coherence);

    iowrite32(&dev, PT_ADDRESS_REG, (unsigned long) ptable);

    iowrite32(&dev, PT_NCHUNK_REG, NCHUNK(mem_size));
    iowrite32(&dev, PT_SHIFT_REG, CHUNK_SHIFT);

    // Use the following if input and output data are not allocated at the default offsets
    iowrite32(&dev, SRC_OFFSET_REG, 0x0);
    iowrite32(&dev, DST_OFFSET_REG, 0x0);

    // Pass accelerator-specific configuration parameters
    /* <<--regs-config-->> */
    iowrite32(&dev, VITDODEC_CBPS_REG, cbps);
    iowrite32(&dev, VITDODEC_NTRACEBACK_REG, ntraceback);
    iowrite32(&dev, VITDODEC_DATA_BITS_REG, data_bits);

    // Flush (customize coherence model here)
    if (coherence != ACC_COH_RECALL)
        esp_flush(coherence,1);

    // Start accelerators
    //printf("  Start...\n");
	cycles_start = get_counter();

    iowrite32(&dev, CMD_REG, CMD_MASK_START);
	

    // Wait for completion
    done = 0;
    while (!done) {
        done = ioread32(&dev, STATUS_REG);
        done &= STATUS_MASK_DONE;
    }
	cycles_end = get_counter();

    iowrite32(&dev, CMD_REG, 0x0);

    //printf("  Done\n");
    //printf("  validating...\n");

    /* Validation */
    errors = validate_buf(&mem[out_offset], gold);
    if (errors)
        printf("  ... FAIL\n");
    else
        printf("  ... PASS\n");
	printf("  Execution cycles: %llu\n", cycles_end - cycles_start);

    aligned_free(ptable);
    aligned_free(mem);
    aligned_free(gold);

	return 0;
}
