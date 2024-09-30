/* Copyright (c) 2011-2023 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>

typedef int32_t token_t;

const int ERR_TH = 0.05;

static unsigned DMA_WORD_PER_BEAT(unsigned _st)
{
        return (sizeof(void *) / _st);
}


#define SLD_ADDER 0x013
#define DEV_NAME "sld,adder_chisel"

/* <<--params-->> */
const int32_t readAddr = 0;
const int32_t writeAddr = 0;
const int32_t size = 1024;

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
#define ADDER_WRITEADDR_REG 0x48
#define ADDER_SIZE_REG 0x44
#define ADDER_READADDR_REG 0x40


static int validate_buf(token_t *out, int *gold)
{
	unsigned errors = 0;

	return errors;
}


static void init_buf(token_t *in, int *gold)
{
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
	int *gold;
	unsigned errors = 0;

	if (DMA_WORD_PER_BEAT(sizeof(token_t)) == 0) {
		in_words_adj = 2 * size;
		out_words_adj = 2 * size;
	} else {
		in_words_adj = round_up(2 * size, DMA_WORD_PER_BEAT(sizeof(token_t)));
		out_words_adj = round_up(2 * size, DMA_WORD_PER_BEAT(sizeof(token_t)));
	}
	in_len = in_words_adj;
	out_len = out_words_adj;
	in_size = in_len * sizeof(token_t);
	out_size = out_len * sizeof(token_t);
	out_offset  = 0;
	mem_size = (out_offset * sizeof(token_t)) + out_size;


	// Search for the device
	printf("Scanning device tree... \n");

	ndev = probe(&espdevs, VENDOR_SLD, SLD_ADDER, DEV_NAME);
	if (ndev == 0) {
		printf("adder not found\n");
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
		gold = aligned_malloc(out_len * sizeof(int));
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
		iowrite32(dev, ADDER_READADDR_REG, 0);
		iowrite32(dev, ADDER_SIZE_REG, size);
		iowrite32(dev, ADDER_WRITEADDR_REG, 0);

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
			printf("  ... FAIL:\n");
		else
			printf("  ... PASS:\n");

		aligned_free(ptable);
		aligned_free(mem);
		aligned_free(gold);
	}

	return 0;
}
