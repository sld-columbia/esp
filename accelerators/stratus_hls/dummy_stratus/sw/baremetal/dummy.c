// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
/**
 * Baremetal device driver for DUMMY
 *
 * (point-to-point communication test)
 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>

typedef long long unsigned u64;
typedef unsigned u32;

typedef u64 token_t;
#define mask 0xFEED0BAC00000000LL

#define SLD_DUMMY   0x42
#define DEV_NAME "sld,dummy_stratus"

#define TOKENS 64
#define BATCH 4

static unsigned out_offset;
static unsigned size;

/* Size of the contiguous chunks for scatter/gather */
#define CHUNK_SHIFT 20
#define CHUNK_SIZE BIT(CHUNK_SHIFT)
#define NCHUNK ((size % CHUNK_SIZE == 0) ?			\
			(size / CHUNK_SIZE) :		\
			(size / CHUNK_SIZE) + 1)

// User defined registers
#define TOKENS_REG	0x40
#define BATCH_REG	0x44


static int validate_dummy(token_t *mem)
{
	int i, j;
	int rtn = 0;
	for (j = 0; j < BATCH; j++)
		for (i = 0; i < TOKENS; i++)
			if (mem[i + j * TOKENS] != (mask | (token_t) i)) {
				printf("[%d, %d]: %llu\n", j, i, mem[i + j * TOKENS]);
				rtn++;
			}
	return rtn;
}

static void init_buf (token_t *mem)
{
	int i, j;
	for (j = 0; j < BATCH; j++)
		for (i = 0; i < TOKENS; i++)
			mem[i + j * TOKENS] = (mask | (token_t) i);

	for (i = 0; i < BATCH * TOKENS; i++)
		mem[i + BATCH * TOKENS] = 0xFFFFFFFFFFFFFFFFLL;
}


int main(int argc, char * argv[])
{
	int i;
	int n;
	int ndev;
	struct esp_device *espdevs;
	struct esp_device *dev;
	struct esp_device *srcs[4];
	unsigned all_done;
	unsigned **ptable = NULL;
	token_t *mem;
	unsigned errors = 0;

	out_offset = BATCH * TOKENS * sizeof(u64);
	size = 2 * out_offset;

	printf("Scanning device tree... \n");

	ndev = probe(&espdevs, VENDOR_SLD, SLD_DUMMY, DEV_NAME);
	if (ndev < 1) {
		printf("This test requires a dummy device!\n");
		return 0;
	}

	// Check DMA capabilities
	dev = &espdevs[0];

	if (ioread32(dev, PT_NCHUNK_MAX_REG) == 0) {
		printf("  -> scatter-gather DMA is disabled. Abort.\n");
		return 0;
	}

	if (ioread32(dev, PT_NCHUNK_MAX_REG) < NCHUNK) {
		printf("  -> Not enough TLB entries available. Abort.\n");
		return 0;
	}

	// Allocate memory
	mem = aligned_malloc(size);
	printf("  memory buffer base-address = %p\n", mem);

	//Alocate and populate page table
	ptable = aligned_malloc(NCHUNK * sizeof(unsigned *));
	for (i = 0; i < NCHUNK; i++)
		ptable[i] = (unsigned *) &mem[i * (CHUNK_SIZE / sizeof(token_t))];
	printf("  ptable = %p\n", ptable);
	printf("  nchunk = %lu\n", NCHUNK);

	printf("  Generate random input...\n");
	init_buf(mem);

	iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
	iowrite32(dev, COHERENCE_REG, ACC_COH_NONE);
	iowrite32(dev, PT_ADDRESS_REG, (unsigned long) ptable);
	iowrite32(dev, PT_NCHUNK_REG, NCHUNK);
	iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);
	iowrite32(dev, TOKENS_REG, TOKENS);
	iowrite32(dev, BATCH_REG, BATCH);
	iowrite32(dev, SRC_OFFSET_REG, 0x0);
	iowrite32(dev, DST_OFFSET_REG, out_offset);

	// Flush for non-coherent DMA
	esp_flush(ACC_COH_NONE);

	// Start accelerators
	printf("  Start...\n");
	iowrite32(dev, CMD_REG, CMD_MASK_START);

	// Wait for completion
	all_done = 0;
	while (!all_done) {
		all_done = ioread32(dev, STATUS_REG);
		all_done &= STATUS_MASK_DONE;
	}

	iowrite32(dev, CMD_REG, 0x0);

	printf("  Done\n");

	/* Validation */
	printf("  validating...\n");
	errors = validate_dummy(&mem[BATCH * TOKENS]);

	if (errors)
		printf("  ... FAIL\n");
	else
		printf("  ... PASS\n");

	aligned_free(ptable);
	aligned_free(mem);

	return 0;
}

