/*
 * Copyright (c) 2011-2019 Columbia University, System Level Design Group
 * SPDX-License-Identifier: Apache-2.0
 */

/**
 * Baremetal device driver for SYNTH
 *
 * Select Scatter-Gather in ESP configuration
 */

#ifndef __riscv
#include <stdio.h>
#endif
#include <stdlib.h>
#include <esp_accelerator.h>
#include <esp_probe.h>

#define SLD_SYNTH   0x014
#define DEV_NAME "sld,synth"

// Accelerator-specific buffe size
#define SYNTH_BUF_SIZE (1024 * sizeof(unsigned))

/* Size of the contiguous chunks for scatter/gather */
#define CHUNK_SHIFT 7
#define CHUNK_SIZE BIT(CHUNK_SHIFT)
#define NCHUNK ((SYNTH_BUF_SIZE % CHUNK_SIZE == 0) ?			\
			(SYNTH_BUF_SIZE / CHUNK_SIZE) :			\
			(SYNTH_BUF_SIZE / CHUNK_SIZE) + 1)

// User defined registers



int main(int argc, char * argv[])
{
	int n;
	int ndev;
	struct esp_device *espdevs = NULL;
	unsigned coherence;

	ndev = probe(&espdevs, SLD_SYNTH, DEV_NAME);
	if (!ndev) {
#ifndef __riscv
		printf("Error: %s device not found!\n", DEV_NAME);
#else
		print_uart("Error: "); print_uart(DEV_NAME); print_uart(" device not found!\n");
#endif
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
			unsigned done;
			int i;
			unsigned **ptable;
			unsigned *mem;
			int scatter_gather = 1;
#ifndef __riscv
			printf("******************** %s.%d ********************\n", DEV_NAME, n);
#else
			print_uart("******************** "); print_uart(DEV_NAME); print_uart(".");
			print_uart_int(n); print_uart(" ********************\n");
#endif
			// Check if scatter-gather DMA is disabled
			if (ioread32(dev, PT_NCHUNK_MAX_REG) == 0) {
#ifndef __riscv
				printf("  -> scatter-gather DMA is disabled; revert to contiguous buffer.\n");
#else
				print_uart("  -> scatter-gather DMA is disabled; revert to contiguous buffer.\n");
#endif
				scatter_gather = 0;
			} else {
#ifndef __riscv
				printf("  -> scatter-gather DMA is enabled.\n");
#else
				print_uart("  -> scatter-gather DMA is enabled.\n");
#endif
			}

			if (scatter_gather)
				if (ioread32(dev, PT_NCHUNK_MAX_REG) < NCHUNK) {
#ifndef __riscv
					printf("  Trying to allocate %lu chunks on %d TLB available entries\n",
						NCHUNK, ioread32(dev, PT_NCHUNK_MAX_REG));
#else
					print_uart("  Trying to allocate more chunks than available TLB entries\n");
#endif
					break;
				}

			// Allocate memory (will be contigous anyway in baremetal)
			mem = aligned_malloc(SYNTH_BUF_SIZE);
#ifndef __riscv
			printf("  memory buffer base-address = %p\n", mem);
#else
			print_uart("  memory buffer base-address = 0x"); print_uart_int((unsigned long) mem); print_uart("\n");
#endif

			if (scatter_gather) {
				//Alocate and populate page table
				ptable = aligned_malloc(NCHUNK * sizeof(unsigned *));
				for (i = 0; i < NCHUNK; i++)
					ptable[i] = (unsigned *) &mem[i * (CHUNK_SIZE / sizeof(unsigned))];
#ifndef __riscv
				printf("  ptable = %p\n", ptable);
				printf("  nchunk = %lu\n", NCHUNK);
#else
				print_uart("  ptable = 0x"); print_uart_int((unsigned long) ptable); print_uart("\n");
				print_uart("  nchunk = 0x"); print_uart_int(NCHUNK); print_uart("\n");
#endif
			}

			// Initialize input: write floating point hex values (simpler to debug)

			// Configure device
			iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
			iowrite32(dev, COHERENCE_REG, coherence);

			if (scatter_gather) {
				iowrite32(dev, PT_ADDRESS_REG, (unsigned long) ptable);
				iowrite32(dev, PT_NCHUNK_REG, NCHUNK);
				iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);
				iowrite32(dev, SRC_OFFSET_REG, 0);
				iowrite32(dev, DST_OFFSET_REG, 0); // Sort runs in place
			} else {
				iowrite32(dev, SRC_OFFSET_REG, (unsigned long) mem);
				iowrite32(dev, DST_OFFSET_REG, (unsigned long) mem); // Sort runs in place
			}

			// Accelerator-specific registers

			// Flush for non-coherent DMA
			esp_flush(coherence);

			// Start accelerator
#ifndef __riscv
			printf("  Start..\n");
#else
			print_uart("  Start..\n");
#endif
			iowrite32(dev, CMD_REG, CMD_MASK_START);

			done = 0;
			while (!done) {
				done = ioread32(dev, STATUS_REG);
				done &= STATUS_MASK_DONE;
			}
			iowrite32(dev, CMD_REG, 0x0);
#ifndef __riscv
			printf("  Done\n");
#else
			print_uart("  Done\n");
#endif

			// Validation

			if (scatter_gather)
				aligned_free(ptable);
			aligned_free(mem);

#ifndef __riscv
			printf("**************************************************\n\n");
#else
			print_uart("**************************************************\n\n");
#endif
		}
	}
	return 0;
}

