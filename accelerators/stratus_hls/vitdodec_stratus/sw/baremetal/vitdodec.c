/* Copyright (c) 2011-2023 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>

#include "do_decoding.h"

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

	for (i = 0; i < 1; i++)
		for (j = 0; j < 18585; j++)
			if (gold[i * out_words_adj + j] != out[i * out_words_adj + j])
				errors++;

	return errors;
}


#define ABS(x) ((x > 0) ? x : -x)

/* simple not quite random implementation of rand() when stdlib is not available */
static unsigned long int next = 42;
int irand(void)
{
	unsigned int rand_tmp;
	next = next * 1103515245 + 12345;
	rand_tmp = (unsigned int) (next / 65536) % 32768;
	return ((int) rand_tmp);

}

static void init_buf (token_t *in, token_t * gold)
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

        for (int j = imi; j < in_size; j++) {
	    int bval = irand()  & 0x01;
            /* printf("Setting up in[%d] = %d\n", j, bval); */
            in[j] = bval;
        }

#if(0)
	{
		printf(" memory in   = ");
		int limi = 0;
		for (int li = 0; li < 32; li++) {
			printf("%u", in[limi++]);
			if ((li % 8) == 7) { printf(" "); }
		}
		printf("\n      brtb1    ");
		for (int li = 0; li < 32; li++) {
			printf("%u", in[limi++]);
			if ((li % 8) == 7) { printf(" "); }
		}
		printf("\n      depnc    ");
		for (int li = 0; li < 8; li++) {
			printf("%u", in[limi++]);
		}
		printf("\n      depdta   ");
		for (int li = 0; li < 32; li++) {
			printf("%u", in[limi++]);
			if ((li % 8) == 7) { printf(" "); }
		}
		printf("\n");
        }
#endif
	/* Pre-zero the output memeory */
	for (i = 0; i < 1; i++)
		for (j = 0; j < 18585; j++)
			gold[i * out_words_adj + j] = (token_t) 0;

	/* Compute the gold output in software! */
	printf("Computing Gold output\n");
	do_decoding(data_bits, cbps, ntraceback, (unsigned char *)in, (unsigned char*)gold);

	/* Re-set the input memory ? */

#if(0)
	{
		printf(" memory in   = ");
		int limi = 0;
		for (int li = 0; li < 32; li++) {
			printf("%u", in[limi++]);
			if ((li % 8) == 7) { printf(" "); }
		}
		printf("\n      brtb1    ");
		for (int li = 0; li < 32; li++) {
			printf("%u", in[limi++]);
			if ((li % 8) == 7) { printf(" "); }
		}
		printf("\n      depnc    ");
		for (int li = 0; li < 8; li++) {
			printf("%u", in[limi++]);
		}
		printf("\n      depdta   ");
		for (int li = 0; li < 32; li++) {
			printf("%u", in[limi++]);
			if ((li % 8) == 7) { printf(" "); }
		}
		printf("\n");
        }
#endif
}


int main(int argc, char * argv[])
{
	int i;
	int n;
	int ndev;
	struct esp_device *espdevs;
	struct esp_device *dev;
	unsigned done;
	unsigned **ptable = NULL;
	token_t *mem;
	token_t *gold;
	unsigned errors = 0;

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


	// Search for the device
	printf("Scanning device tree... \n");

	ndev = probe(&espdevs, VENDOR_SLD, SLD_VITDODEC, DEV_NAME);
	if (ndev == 0) {
		printf("vitdodec not found\n");
		return 0;
	}

	for (n = 0; n < ndev; n++) {

		dev = &espdevs[n];

		// Check DMA capabilities
		if (ioread32(dev, PT_NCHUNK_MAX_REG) == 0) {
			printf("  -> scatter-gather DMA is disabled. Abort.\n");
			return 0;
		}

		if (ioread32(dev, PT_NCHUNK_MAX_REG) < NCHUNK(mem_size)) {
			printf("  -> Not enough TLB entries available. Abort.\n");
			return 0;
		}

		// Allocate memory
		gold = aligned_malloc(out_size);
		mem = aligned_malloc(mem_size);
		printf("  memory buffer base-address = %p\n", mem);
		// Alocate and populate page table
		ptable = aligned_malloc(NCHUNK(mem_size) * sizeof(unsigned *));
		for (i = 0; i < NCHUNK(mem_size); i++)
			ptable[i] = (unsigned *) &mem[i * (CHUNK_SIZE / sizeof(token_t))];
		printf("  ptable = %p\n", ptable);
		printf("  nchunk = %lu\n", NCHUNK(mem_size));

		printf("  Generate input...\n");
		init_buf(mem, gold);

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

		// Flush (customize coherence model here)
		esp_flush(ACC_COH_NONE);

		// Start accelerators
		printf("  Start...\n");
		iowrite32(dev, CMD_REG, CMD_MASK_START);

		// Wait for completion
		done = 0;
		while (!done) {
			done = ioread32(dev, STATUS_REG);
			done &= STATUS_MASK_DONE;
		}
		iowrite32(dev, CMD_REG, 0x0);

		printf("  Done\n");
		printf("  validating...\n");

		/* Validation */
		errors = validate_buf(&mem[out_offset], gold);
		if (errors)
			printf("  ... FAIL\n");
		else
			printf("  ... PASS\n");

		aligned_free(ptable);
		aligned_free(mem);
		aligned_free(gold);
	}

	return 0;
}
