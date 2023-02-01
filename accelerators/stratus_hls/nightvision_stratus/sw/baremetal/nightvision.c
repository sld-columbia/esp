// Copyright (c) 2011-2023 Columbia University, System Level Design Group
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

#define SLD_NIGHTVISION 0x13
#define DEV_NAME        "sld,nightvision_stratus"

// Statically define the size of the input image for this test
// Prepare in this path the corresponding data_ROWSxCOLS.h

//#define IMG_SIZE 1024       // 32x32
#define IMG_SIZE 1200 // 30x40
//#define IMG_SIZE 19200      // 120x160
//#define IMG_SIZE 307200     // 480x640

#if IMG_SIZE == 1024
    #define ROWS 32
    #define COLS 32
typedef char pixel;
#elif IMG_SIZE == 1200
    #define ROWS 30
    #define COLS 40
typedef short pixel;
#elif IMG_SIZE == 19200
    #define ROWS 120
    #define COLS 160
typedef short pixel;
#else
    #define ROWS 480
    #define COLS 640
typedef short pixel;
#endif

#define NIGHTVISION_BUF_SIZE (ROWS * COLS * 2 * sizeof(pixel))

/* Size of the contiguous chunks for scatter/gather */
#define CHUNK_SHIFT 10
#define CHUNK_SIZE  BIT(CHUNK_SHIFT)
#define NCHUNK                                                                      \
    ((NIGHTVISION_BUF_SIZE % CHUNK_SIZE == 0) ? (NIGHTVISION_BUF_SIZE / CHUNK_SIZE) \
                                              : (NIGHTVISION_BUF_SIZE / CHUNK_SIZE) + 1)

// User defined registers
#define NIGHTVISION_NIMAGES_REG 0x40
#define NIGHTVISION_NROWS_REG   0x44
#define NIGHTVISION_NCOLS_REG   0x48
#define NIGHTVISION_DO_DWT_REG  0x4C

int main(int argc, char *argv[])
{
    int                n;
    int                ndev;
    struct esp_device *espdevs = NULL;
    unsigned           coherence;

    ndev = probe(&espdevs, VENDOR_SLD, SLD_NIGHTVISION, DEV_NAME);
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
            int                done;
            int                i, j;
            unsigned **        ptable = NULL;
            pixel *            mem;
            pixel              gold[COLS * ROWS];
            unsigned           errors         = 0;
            int                scatter_gather = 1;

            printf("******************** %s.%d ********************\n", DEV_NAME, n);
            printf("*** CHUNK_SIZE: %d\n", CHUNK_SIZE);
            printf("*** NCHUNK: %d\n", NCHUNK);
            printf("*** NIGHTVISION_BUF_SIZE: %d\n", NIGHTVISION_BUF_SIZE);
            printf("*** IMG_SIZE: %d\n", IMG_SIZE);

            // Check access ok (TODO)

            // Check if scatter-gather DMA is disabled
            if (ioread32(dev, PT_NCHUNK_MAX_REG) == 0) {
                printf("  -> scatter-gather DMA is disabled; revert to contiguous buffer.\n");
                scatter_gather = 0;
            } else {
                printf("  -> scatter-gather DMA is enabled.\n");
                scatter_gather = 1;
            }

            if (scatter_gather) {
                if (ioread32(dev, PT_NCHUNK_MAX_REG) < NCHUNK) {
                    printf("  Trying to allocate %lu chunks on %d TLB available entries\n", NCHUNK,
                           ioread32(dev, PT_NCHUNK_MAX_REG));
                    break;
                }
            }

            // Allocate memory (will be contigous anyway in baremetal)
            mem = aligned_malloc(NIGHTVISION_BUF_SIZE);
            printf("  memory buffer base-address = %p\n", mem);

            if (scatter_gather) {
                // Alocate and populate page table
                ptable = aligned_malloc(NCHUNK * sizeof(unsigned *));
                for (i = 0; i < NCHUNK; i++)
                    ptable[i] = (unsigned *)&mem[i * (CHUNK_SIZE / sizeof(pixel))];
                printf("  ptable = %p\n", ptable);
                printf("  nchunk = %lu\n", NCHUNK);
            }

            // Initialize input (TODO)
#if IMG_SIZE == 1024
    #include "data_32x32.h"
#elif IMG_SIZE == 1200
    #include "data_30x40.h"
#elif IMG_SIZE == 19200
    #include "data_120x160.h"
#else
    #include "data_480x640.h"
#endif
            // Configure device
            iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
            iowrite32(dev, COHERENCE_REG, coherence);

            if (scatter_gather) {
                iowrite32(dev, PT_ADDRESS_REG, (uintptr_t)ptable);
                iowrite32(dev, PT_NCHUNK_REG, NCHUNK);
                iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);
                iowrite32(dev, SRC_OFFSET_REG, 0);
                iowrite32(dev, DST_OFFSET_REG, 0);
            } else {
                iowrite32(dev, SRC_OFFSET_REG, (uintptr_t)mem);
                iowrite32(dev, DST_OFFSET_REG, (uintptr_t)mem);
            }

            // Accelerator-specific registers
            iowrite32(dev, NIGHTVISION_NIMAGES_REG, 1);
            iowrite32(dev, NIGHTVISION_NROWS_REG, ROWS);
            iowrite32(dev, NIGHTVISION_NCOLS_REG, COLS);
#if (ROWS == 32 && COLS == 32)
            iowrite32(dev, NIGHTVISION_DO_DWT_REG, 0);
#else
            iowrite32(dev, NIGHTVISION_DO_DWT_REG, 1);
#endif

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

            for (i = 0; i < ROWS; i++) {
                for (j = 0; j < COLS; j++) {
                    if (mem[i * COLS + j] != gold[i * COLS + j]) {
                        // printf(" %d,%d: %d != %d\n", i, j,
                        // mem[i * COLS + j], gold[i * COLS + j]);
                        errors++;
                    }
                }
            }

            if (errors) {
                printf("  ... FAIL: %d mismatches\n", errors);
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
