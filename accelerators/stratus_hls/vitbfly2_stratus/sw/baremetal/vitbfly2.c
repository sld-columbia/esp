// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
/**
 * Baremetal device driver for VITBFLY2
 *
 * Select Scatter-Gather in ESP configuration
 */


#include <stdio.h>
#include <stdlib.h>

#include <esp_accelerator.h>
#include <esp_probe.h>

#define SLD_VITBFLY2   0x16
#define DEV_NAME "sld,vitbfly2_stratus"

#define COLS 40
#define ROWS 30

#define VITBFLY2_BUF_SIZE (ROWS * COLS * sizeof(unsigned))

/* Size of the contiguous chunks for scatter/gather */
#define CHUNK_SHIFT 20
#define CHUNK_SIZE BIT(CHUNK_SHIFT)
#define NCHUNK ((VITBFLY2_BUF_SIZE % CHUNK_SIZE == 0) ?		\
			(VITBFLY2_BUF_SIZE / CHUNK_SIZE) :		\
			(VITBFLY2_BUF_SIZE / CHUNK_SIZE) + 1)

// User defined registers
#define VITBFLY2_NIMAGES_REG   0x40
#define VITBFLY2_NROWS_REG     0x44
#define VITBFLY2_NCOLS_REG     0x48


int main(int argc, char * argv[])
{
	int n;
	int ndev;
	struct esp_device *espdevs = NULL;
	unsigned coherence;

	// TODO This app is just a placeholder. Exit!
	printf("There is no bare-metal app for the 'vitbfly2' accelerator.\n");
	printf("This bare-metal app is a placeholder.\n");
	printf("Exiting...\n");
	return 0;

	ndev = probe(&espdevs, VENDOR_SLD, SLD_VITBFLY2, DEV_NAME);
	if (ndev <= 0) {
		printf("Error: %s device not found!\n", DEV_NAME);
		exit(EXIT_FAILURE);
	}

	for (n = 0; n < ndev; n++) {
#ifndef __riscv
		for (coherence = ACC_COH_NONE; coherence <= ACC_COH_FULL; coherence++) {
#else
		{
			/* TODO: Restore full test once ESP caches are integrated */
			coherence = ACC_COH_NONE;
#endif
			struct esp_device *dev = &espdevs[n];
			int done;
			int i, j;
			unsigned **ptable = NULL;
			short *mem;
			short gold[COLS * ROWS];
			unsigned errors = 0;
			int scatter_gather = 1;

			printf("******************** %s.%d ********************\n", DEV_NAME, n);

			// Check access ok (TODO)

			// Check if scatter-gather DMA is disabled
			if (ioread32(dev, PT_NCHUNK_MAX_REG) == 0) {
				printf("  -> scatter-gather DMA is disabled; revert to contiguous buffer.\n");
				scatter_gather = 0;
			} else {
				printf("  -> scatter-gather DMA is enabled.\n");
			}

			if (scatter_gather)
				if (ioread32(dev, PT_NCHUNK_MAX_REG) < NCHUNK) {
					printf("  Trying to allocate %lu chunks on %d TLB available entries\n",
						NCHUNK, ioread32(dev, PT_NCHUNK_MAX_REG));
					break;
				}

			// Allocate memory (will be contigous anyway in baremetal)
			mem = aligned_malloc(VITBFLY2_BUF_SIZE);
			printf("  memory buffer base-address = %p\n", mem);

			if (scatter_gather) {
				//Alocate and populate page table
				ptable = aligned_malloc(NCHUNK * sizeof(unsigned *));
				for (i = 0; i < NCHUNK; i++)
					ptable[i] = (unsigned *) &mem[i * (CHUNK_SIZE / sizeof(unsigned short))];

				printf("  ptable = %p\n", ptable);
				printf("  nchunk = %lu\n", NCHUNK);
			}

			// Initialize input (TODO)
			#include "data.h"

			// Configure device
			iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
			iowrite32(dev, COHERENCE_REG, coherence);

			if (scatter_gather) {
				iowrite32(dev, PT_ADDRESS_REG, (uintptr_t) ptable);
				iowrite32(dev, PT_NCHUNK_REG, NCHUNK);
				iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);
				iowrite32(dev, SRC_OFFSET_REG, 0);
				iowrite32(dev, DST_OFFSET_REG, 0);
			} else {
				iowrite32(dev, SRC_OFFSET_REG, (uintptr_t) mem);
				iowrite32(dev, DST_OFFSET_REG, (uintptr_t) mem);
			}

			// Accelerator-specific registers
			iowrite32(dev, VITBFLY2_NIMAGES_REG, 1);
			iowrite32(dev, VITBFLY2_NROWS_REG, ROWS);
			iowrite32(dev, VITBFLY2_NCOLS_REG, COLS);

			// Flush for non-coherent DMA
			esp_flush(coherence);

			// Start accelerator
			printf("  Start..\n");

			iowrite32(dev, CMD_REG, CMD_MASK_START);

			done = 0;
			while (!done) {
				done = ioread32(dev, STATUS_REG);
				done &= STATUS_MASK_DONE;
			}
			iowrite32(dev, CMD_REG, 0x0);
			printf("  Done\n");

			/* Validation */
			printf("  validating...\n");

			for (i = 0; i < ROWS; i++)
				for (j = 0; j < COLS; j++)
					if (mem[i * COLS + j] != gold[i * COLS + j]) {
						printf(" %d,%d: %d != %d\n", i, j, mem[i * COLS + j], gold[i * COLS + j]);
						errors++;
					}


			if (errors) {
				printf("  ... FAIL\n");
			} else {
				printf("  ... PASS\n");
			}

			if (scatter_gather)
				aligned_free(ptable);
			aligned_free(mem);

			printf("**************************************************\n\n");
		}
	}
	return 0;
}

