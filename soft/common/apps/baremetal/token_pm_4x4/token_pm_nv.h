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

#define SLD_NIGHTVISION   0x13
#define NV_DEV_NAME "sld,nightvision_stratus"

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
#define NV_CHUNK_SHIFT 8
#define NV_CHUNK_SIZE BIT(NV_CHUNK_SHIFT)
#define NV_NCHUNK ((NIGHTVISION_BUF_SIZE % NV_CHUNK_SIZE == 0) ?		\
			(NIGHTVISION_BUF_SIZE / NV_CHUNK_SIZE) :		\
			(NIGHTVISION_BUF_SIZE / NV_CHUNK_SIZE) + 1)

// User defined registers
#define NIGHTVISION_NIMAGES_REG   0x40
#define NIGHTVISION_NROWS_REG     0x44
#define NIGHTVISION_NCOLS_REG     0x48
#define NIGHTVISION_DO_DWT_REG    0x4C

pixel gold[COLS * ROWS];

void setup_nv(struct esp_device *dev, pixel *mem, unsigned **ptable)
{
    int i;
    // Allocate memory (will be contigous anyway in baremetal)
    mem = aligned_malloc(NIGHTVISION_BUF_SIZE);
    //printf("  memory buffer base-address = %p\n", mem);

    ptable = aligned_malloc(NV_NCHUNK * sizeof(unsigned *));
    for (i = 0; i < NV_NCHUNK; i++)
        ptable[i] = (unsigned *) &mem[i * (NV_CHUNK_SIZE / sizeof(pixel))];
    //printf("  ptable = %p\n", ptable);
    //printf("  nchunk = %lu\n", NV_NCHUNK);

    // Initialize input (TODO)
    #include "nightvision_data_16x16.h"

    // Configure device
    iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
    iowrite32(dev, COHERENCE_REG, ACC_COH_RECALL);

    iowrite32(dev, PT_ADDRESS_REG, (uintptr_t) ptable);
    iowrite32(dev, PT_NCHUNK_REG, NV_NCHUNK);
    iowrite32(dev, PT_SHIFT_REG, NV_CHUNK_SHIFT);
    iowrite32(dev, SRC_OFFSET_REG, 0);
    iowrite32(dev, DST_OFFSET_REG, 0);

    // Accelerator-specific registers
    iowrite32(dev, NIGHTVISION_NIMAGES_REG, 1);
    iowrite32(dev, NIGHTVISION_NROWS_REG, ROWS);
    iowrite32(dev, NIGHTVISION_NCOLS_REG, COLS);
#if (ROWS == 32 && COLS == 32)
    iowrite32(dev, NIGHTVISION_DO_DWT_REG, 0);
#else
    iowrite32(dev, NIGHTVISION_DO_DWT_REG, 0);
#endif

}
