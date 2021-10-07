// Copyright (c) 2011-2021 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
/**
 * Baremetal device driver for NIGHTVISION
 *
 * Select Scatter-Gather in ESP configuration
 */

#include <stdio.h>
#include <stdlib.h>

#include <esp_accelerator.h>
#include <esp_probe.h>
#include "nightvision_minimal.h"

#define SLD_NIGHTVISION   0x13
#define DEV_NAME "sld,nightvision_stratus"

// Statically define the size of the input image for this test
// Prepare in this path the corresponding data_ROWSxCOLS.h
#define IS_SMALL

#ifndef IS_SMALL
#define COLS 8
#define ROWS 8
// Define data type of the pixel
typedef short pixel;
#else
#define COLS 16
#define ROWS 16
// Define data type of the pixel
typedef char pixel;
#endif

#define NIGHTVISION_BUF_SIZE (ROWS * COLS * 2 * sizeof(pixel))

/* Size of the contiguous chunks for scatter/gather */
#define CHUNK_SHIFT 8
#define CHUNK_SIZE BIT(CHUNK_SHIFT)
#define NCHUNK ((NIGHTVISION_BUF_SIZE % CHUNK_SIZE == 0) ?		\
			(NIGHTVISION_BUF_SIZE / CHUNK_SIZE) :		\
			(NIGHTVISION_BUF_SIZE / CHUNK_SIZE) + 1)

// User defined registers
#define NIGHTVISION_NIMAGES_REG   0x40
#define NIGHTVISION_NROWS_REG     0x44
#define NIGHTVISION_NCOLS_REG     0x48
#define NIGHTVISION_DO_DWT_REG    0x4C


int main(int argc, char * argv[])
{
	int n;
	int ndev;
	unsigned coherence;

    /* TODO: Restore full test once ESP caches are integrated */
    coherence = ACC_COH_RECALL;
    struct esp_device dev;
    int done;
    int i, j;
    unsigned **ptable = NULL;
    pixel *mem;
    pixel gold[COLS * ROWS];
    unsigned errors = 0;
    int scatter_gather = 1;

    dev.addr = ACC_ADDR;

    // Allocate memory (will be contigous anyway in baremetal)
    mem = aligned_malloc(NIGHTVISION_BUF_SIZE);
    //printf("  memory buffer base-address = %p\n", mem);

    ptable = aligned_malloc(NCHUNK * sizeof(unsigned *));
    for (i = 0; i < NCHUNK; i++)
        ptable[i] = (unsigned *) &mem[i * (CHUNK_SIZE / sizeof(pixel))];
    //printf("  ptable = %p\n", ptable);
    //printf("  nchunk = %lu\n", NCHUNK);

    // Initialize input (TODO)
    #include "data_16x16.h"

    // Configure device
    iowrite32(&dev, SELECT_REG, ioread32(&dev, DEVID_REG));
    iowrite32(&dev, COHERENCE_REG, coherence);

    iowrite32(&dev, PT_ADDRESS_REG, (uintptr_t) ptable);
    iowrite32(&dev, PT_NCHUNK_REG, NCHUNK);
    iowrite32(&dev, PT_SHIFT_REG, CHUNK_SHIFT);
    iowrite32(&dev, SRC_OFFSET_REG, 0);
    iowrite32(&dev, DST_OFFSET_REG, 0);

    // Accelerator-specific registers
    iowrite32(&dev, NIGHTVISION_NIMAGES_REG, 1);
    iowrite32(&dev, NIGHTVISION_NROWS_REG, ROWS);
    iowrite32(&dev, NIGHTVISION_NCOLS_REG, COLS);
#if (ROWS == 32 && COLS == 32)
    iowrite32(&dev, NIGHTVISION_DO_DWT_REG, 0);
#else
    iowrite32(&dev, NIGHTVISION_DO_DWT_REG, 0);
#endif

    // Flush for non-coherent DMA
    if (coherence != ACC_COH_RECALL)
        esp_flush(coherence);

    // Start accelerator
    //printf("  Start..\n");

    iowrite32(&dev, CMD_REG, CMD_MASK_START);

    done = 0;
    while (!done) {
        done = ioread32(&dev, STATUS_REG);
        done &= STATUS_MASK_DONE;
    }
    iowrite32(&dev, CMD_REG, 0x0);
    //printf("  Done\n");

    /* Validation */
    //printf("  validating...\n");

    for (i = 0; i < ROWS; i++)
        for (j = 0; j < COLS; j++) {
            //printf("gold[%d] = %d;\n", i * COLS + j, mem[i * COLS + j]);
            if (mem[i * COLS + j] != gold[i * COLS + j]) {
                //printf(" %d,%d: %d != %d\n", i, j,
                //       mem[i * COLS + j], gold[i * COLS + j]);
                errors++;
            }
       }

    if (errors) {
        printf("  ... FAIL\n");
    } else {
        printf("  ... PASS\n");
    }

    aligned_free(ptable);
    aligned_free(mem);

	return 0;
}
