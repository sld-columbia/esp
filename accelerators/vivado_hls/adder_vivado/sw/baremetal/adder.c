// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
/**
 * Baremetal device driver for VivadoHLS accelerators
 *
 * Select Scatter-Gather in ESP configuration
 */

#include <stdio.h>
#include <stdlib.h>
#include <esp_accelerator.h>
#include <esp_probe.h>
#include <fixed_point.h>

/////////////////////////////////
// TODO include accelerators configuration header
//      instead of copying its content here
// #include "espacc_config.h"
// In/out arrays
#define SIZE_IN_CHUNK_DATA 64
#define SIZE_OUT_CHUNK_DATA 32
/////////////////////////////////

/////////////////////////////////
// TODO read HLS config directly from the accelerator registers
//      instead of setting it here
#ifndef __riscv
#define DMA_SIZE  32
#else
#define DMA_SIZE  64
#endif

#define DATA_BITWIDTH 32
typedef int32_t word_t;
// typedef float word_t; // use this if the accelerator is floating point
/////////////////////////////////

// Specify accelerator type
#define SLD_ADDER   0x40
#define DEV_NAME "sld,adder_vivado"

// Sizes
#define NINVOKE 4
#define NBURSTS 4
#define IN_SIZE_DATA (SIZE_IN_CHUNK_DATA * NBURSTS)
#define OUT_SIZE_DATA (SIZE_OUT_CHUNK_DATA * NBURSTS)
#define IN_SIZE (IN_SIZE_DATA * sizeof(word_t))
#define OUT_SIZE (OUT_SIZE_DATA * sizeof(word_t))
#define SIZE_DATA (IN_SIZE_DATA + OUT_SIZE_DATA)
#define SIZE (IN_SIZE + OUT_SIZE)

/* Size of the contiguous chunks for scatter/gather */
#define CHUNK_SHIFT 9
#define CHUNK_SIZE BIT(CHUNK_SHIFT)
#define NCHUNK ((SIZE % CHUNK_SIZE == 0) ?		\
		(SIZE / CHUNK_SIZE) :			\
		(SIZE / CHUNK_SIZE) + 1)

// User defined registers
#define NBURSTS_REG   0x40

//#define VERBOSE

int main(int argc, char * argv[])
{
    int n, k;
    int ndev;
    struct esp_device *espdevs = NULL;
    unsigned coherence;

    printf("STARTING!\n");

    ndev = probe(&espdevs, VENDOR_SLD, SLD_ADDER, DEV_NAME);
    if (!ndev) {
	    printf("Error: device not found!");
	    printf(DEV_NAME);
	    exit(EXIT_FAILURE);
    }

    for (n = 0; n < ndev; n++) {

	for (k = 0; k < NINVOKE; ++k) {

	    coherence = ACC_COH_NONE;

	    struct esp_device *dev = &espdevs[n];
	    int done;
	    int i;
	    unsigned **ptable = NULL;
	    word_t *mem;
	    unsigned errors = 0;
	    int scatter_gather = 1;

	    printf("\n********************************\n");
	    printf("Process input # ");
	    printf("%u\n", (unsigned) k);

	    // Check access ok (TODO)

	    // Check if scatter-gather DMA is disabled
	    if (ioread32(dev, PT_NCHUNK_MAX_REG) == 0) {
		    printf("  -> scatter-gather DMA is disabled; revert to contiguous buffer.\n");
		    scatter_gather = 0;
	    } else {
		    printf("  -> scatter-gather DMA is enabled.\n");
	    }

	    if (scatter_gather) {
		if (ioread32(dev, PT_NCHUNK_MAX_REG) < NCHUNK) {
		    printf("  Trying to allocate # chunks on # TLB available entries: \n");
		    printf("%u\t%u\n", (unsigned) NCHUNK, (unsigned) ioread32(dev, PT_NCHUNK_MAX_REG));
		    break;
		}
	    }

	    // Allocate memory (will be contiguos anyway in baremetal)
	    mem = aligned_malloc(SIZE);
	    printf("  memory buffer base-address = %lu\n", (unsigned long) mem);

	    if (scatter_gather) {
		// Allocate and populate page table
		ptable = aligned_malloc(NCHUNK * sizeof(unsigned *));
		for (i = 0; i < NCHUNK; i++)
		    ptable[i] = (unsigned *)
			&mem[i * (CHUNK_SIZE / sizeof(unsigned))];

		printf("  ptable = %p\n", ptable);
		printf("  nchunk = %lu\n", NCHUNK);
	    }

	    // Initialize input and output
	    for (i = 0; i < IN_SIZE_DATA; ++i)
		mem[i] = i;
	    for (; i < SIZE_DATA; ++i)
		mem[i] = 63;

	    // Allocate memory for gold output
	    word_t *mem_gold;
	    mem_gold = aligned_malloc(OUT_SIZE);
	    printf("  memory buffer base-address = %lu\n", (unsigned long) mem_gold);

	    // Populate memory for gold output
	    for (i = 0; i < OUT_SIZE_DATA; ++i) {
		mem_gold[i] = mem[i*2] + mem[i*2+1];
	    }

	    // Configure device
	    iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
	    iowrite32(dev, COHERENCE_REG, coherence);

	    if (scatter_gather) {
		iowrite32(dev, PT_ADDRESS_REG, (unsigned long) ptable);
		iowrite32(dev, PT_NCHUNK_REG, NCHUNK);
		iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);
		iowrite32(dev, SRC_OFFSET_REG, 0);
		iowrite32(dev, DST_OFFSET_REG, 0);
	    } else {
		iowrite32(dev, SRC_OFFSET_REG, (unsigned long) mem);
		iowrite32(dev, DST_OFFSET_REG, (unsigned long) mem);
	    }

	    // Accelerator-specific registers
	    iowrite32(dev, NBURSTS_REG, 4);

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

	    errors = 0;
	    for (i = 0; i < OUT_SIZE_DATA; i++) {
		if (mem[i + IN_SIZE_DATA] != mem_gold[i]) {
		    errors++;
		    printf("ERROR: i mem mem_gold\n");
		    printf("%d\n%lu\n%lu\n", i, mem[i + IN_SIZE_DATA], mem_gold[i]);
		} else {
#ifdef VERBOSE
		    printf("ERROR: i mem mem_gold\n");
		    printf("%u\n%u\n%u\n", (uint32_t) i, (uint32_t) mem[i + IN_SIZE_DATA],
			   (uint32_t) mem_gold[i]);
#endif
		}
	    }

	    if (!errors) {
		printf("\n  Test PASSED!\n");
	    } else {
		printf("\n  Test FAILED. Number of errors: %d\n", errors);
	    }
	}
    }

    return 0;
}
