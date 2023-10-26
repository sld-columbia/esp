/*
 * Copyright (c) 2011-2023 Columbia University, System Level Design Group
 * SPDX-License-Identifier: Apache-2.0
 */

/**
 * Baremetal device driver for SYNTH
 *
 * Select Scatter-Gather in ESP configuration
 */

#include <stdio.h>
#include <stdlib.h>
#include <esp_accelerator.h>
#include <esp_probe.h>
#include "dummy_p2p_minimal.h"

typedef long long unsigned u64;
typedef unsigned u32;
typedef u64 token_t;

#define SLD_SYNTH   0x042
#define DEV_NAME "sld,dummy_stratus"
#define TRIALS 1

#define TOKENS_REG 0x40
#define BATCH_REG 0x44

//COMMON PARAMETERS
#define TOKENS 64
#define BATCH 1
#define mask 0x0LL

//8 bytes per word, both input and output
#define DUMMY_BUF_SIZE (TOKENS * BATCH * sizeof(token_t) * 2)

/* Size of the contiguous chunks for scatter/gather */
#define CHUNK_SHIFT 20
#define CHUNK_SIZE BIT(CHUNK_SHIFT)
#define NCHUNK ((DUMMY_BUF_SIZE % CHUNK_SIZE == 0) ?		\
			(DUMMY_BUF_SIZE / CHUNK_SIZE) :		\
			(DUMMY_BUF_SIZE / CHUNK_SIZE) + 1)

// User defined registers


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

static void init_buf(token_t *mem)
{
    int i, j;
    for (j = 0; j < BATCH; j++) 
        for (i = 0; i < TOKENS; i++)
            mem[i + j * TOKENS] = (mask | (token_t) i);
}

void p2p_setup(struct esp_device* dev, int p2p_store, int p2p_load, struct esp_device* p2p_src){
    esp_p2p_reset(dev);
    if (p2p_store)
        esp_p2p_enable_dst(dev);
    if (p2p_load) {
        esp_p2p_enable_src(dev);
        esp_p2p_set_y(dev, 0, esp_get_y(p2p_src));
        esp_p2p_set_x(dev, 0, esp_get_x(p2p_src));
    }
}


int main(int argc, char * argv[])
{
	int n, trial, errors;
	int ndev;
	struct esp_device *espdevs = NULL;
	unsigned coherence;
    struct esp_device dev0, dev1;
    dev0.addr = ACC0_ADDR;
    dev1.addr = ACC1_ADDR;

	/*ndev = probe(&espdevs, VENDOR_SLD, SLD_SYNTH, DEV_NAME);
	if (!ndev) {
		printf("Error: %s device not found!\n", DEV_NAME);
		exit(EXIT_FAILURE);
	}*/

	for (trial = 0; trial < TRIALS; trial++) {
		{
			coherence = ACC_COH_NONE;
			unsigned **ptable = NULL;
			token_t *mem;
			int scatter_gather = 1;
            int i;

            // Check if scatter-gather DMA is disabled
            if (ioread32(&dev0, PT_NCHUNK_MAX_REG) == 0) {
                //printf("  -> scatter-gather DMA is disabled; revert to contiguous buffer.\n");
                scatter_gather = 0;
            } else {
                //printf("  -> scatter-gather DMA is enabled.\n");
            }

            if (scatter_gather)
                if (ioread32(&dev0, PT_NCHUNK_MAX_REG) < NCHUNK) {
                    //printf("  Trying to allocate %lu chunks on %d TLB available entries\n",
                     //   NCHUNK, ioread32(dev, PT_NCHUNK_MAX_REG));
                    break;
                }

            // Allocate memory (will be contigous anyway in baremetal)
            mem = aligned_malloc(DUMMY_BUF_SIZE);
            printf("  memory buffer base-address = %p\n", mem);

            init_buf(mem);

            if (scatter_gather) {
                //Alocate and populate page table
                ptable = aligned_malloc(NCHUNK * sizeof(unsigned *));
                for (i = 0; i < NCHUNK; i++)
                    ptable[i] = (unsigned *) &mem[i * (CHUNK_SIZE / sizeof(unsigned))];
                printf("  ptable = %p\n", ptable);
                printf("  nchunk = %lu\n", NCHUNK);
            }

            // Initialize input: write floating point hex values (simpler to debug)

            // Configure device
            iowrite32(&dev0, SELECT_REG, ioread32(&dev0, DEVID_REG));
            iowrite32(&dev0, COHERENCE_REG, coherence);
            p2p_setup(&dev0, 1, 0, NULL);

            if (scatter_gather) {
                iowrite32(&dev0, PT_ADDRESS_REG, (unsigned long) ptable);
                iowrite32(&dev0, PT_NCHUNK_REG, NCHUNK);
                iowrite32(&dev0, PT_SHIFT_REG, CHUNK_SHIFT);
                iowrite32(&dev0, SRC_OFFSET_REG, 0);
                iowrite32(&dev0, DST_OFFSET_REG, DUMMY_BUF_SIZE / 2);
            } else {
                iowrite32(&dev0, SRC_OFFSET_REG, (unsigned long) mem);
                iowrite32(&dev0, DST_OFFSET_REG, (unsigned long) DUMMY_BUF_SIZE / 2);
            }

            // Accelerator-specific registers
            iowrite32(&dev0, TOKENS_REG, TOKENS);
            iowrite32(&dev0, BATCH_REG, BATCH);

            // Configure device
            iowrite32(&dev1, SELECT_REG, ioread32(&dev1, DEVID_REG));
            iowrite32(&dev1, COHERENCE_REG, coherence);
            p2p_setup(&dev1, 0, 1, &dev0);

            if (scatter_gather) {
                iowrite32(&dev1, PT_ADDRESS_REG, (unsigned long) ptable);
                iowrite32(&dev1, PT_NCHUNK_REG, NCHUNK);
                iowrite32(&dev1, PT_SHIFT_REG, CHUNK_SHIFT);
                iowrite32(&dev1, SRC_OFFSET_REG, 0);
                iowrite32(&dev1, DST_OFFSET_REG, DUMMY_BUF_SIZE / 2);
            } else {
                iowrite32(&dev1, SRC_OFFSET_REG, (unsigned long) mem);
                iowrite32(&dev1, DST_OFFSET_REG, (unsigned long) DUMMY_BUF_SIZE / 2);
            }

            // Accelerator-specific registers
            iowrite32(&dev1, TOKENS_REG, TOKENS);
            iowrite32(&dev1, BATCH_REG, BATCH);

            // Flush for non-coherent DMA
            //esp_flush(coherence);

            // Start accelerator
            printf("  Start..\n");
            iowrite32(&dev0, CMD_REG, CMD_MASK_START);
            iowrite32(&dev1, CMD_REG, CMD_MASK_START);

            unsigned done = 0;

            while (!done) {
                done = ioread32(&dev0, STATUS_REG);
                done &= STATUS_MASK_DONE;
            }

            iowrite32(&dev0, CMD_REG, 0x0);
            printf("  Acc0 done...\n");

            done = 0;
            while (!done) {
                done = ioread32(&dev1, STATUS_REG);
                done &= STATUS_MASK_DONE;
            }

            iowrite32(&dev1, CMD_REG, 0x0);
            printf("  Validating...\n");

            errors = validate_dummy(&mem[BATCH * TOKENS]);

            printf(" %d errors \n", errors);

            printf("  Done\n");


            // Validation

            if (scatter_gather)
                aligned_free(ptable);
            aligned_free(mem);
			printf("**************************************************\n\n");
		}
	}
	return 0;
}
