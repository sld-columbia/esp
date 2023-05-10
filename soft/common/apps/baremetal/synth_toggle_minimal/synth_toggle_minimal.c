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
#include "synth_toggle_minimal.h"

#define SLD_SYNTH   0x014
#define DEV_NAME "sld,synth_stratus"
#define TRIALS 1

#define PATTERN_STREAMING 0
#define PATTERN_STRIDED 1
#define PATTERN_IRREGULAR 2

#define SYNTH_OFFSET_REG 0x40
#define SYNTH_PATTERN_REG 0x44
#define SYNTH_IN_SIZE_REG 0x48
#define SYNTH_ACCESS_FACTOR_REG 0x4c
#define SYNTH_BURST_LEN_REG 0x50
#define SYNTH_COMPUTE_BOUND_FACTOR_REG 0x54
#define SYNTH_IRREGULAR_SEED_REG 0x58
#define SYNTH_REUSE_FACTOR_REG 0x5c
#define SYNTH_LD_ST_RATIO_REG 0x60
#define SYNTH_STRIDE_LEN_REG 0x64
#define SYNTH_OUT_SIZE_REG 0x68
#define SYNTH_IN_PLACE_REG 0x6c
#define SYNTH_WR_DATA_REG 0x70
#define SYNTH_RD_DATA_REG 0x74

//COMMON PARAMETERS
#define IN_SIZE 16
#define IN_SIZE1 32
#define LD_ST_RATIO 1
#define ACCESS_FACTOR 0
#define OUT_SIZE ((IN_SIZE / LD_ST_RATIO) >> ACCESS_FACTOR)
#define OUT_SIZE1 ((IN_SIZE1 / LD_ST_RATIO) >> ACCESS_FACTOR)
#define SYNTH_BUF_SIZE ((IN_SIZE + OUT_SIZE) * sizeof(unsigned))
#define IN_PLACE 0
#define BURST_LEN 16
#define REUSE_FACTOR 1
#define STRIDE_LEN 1
#define COMPUTE_BOUND_FACTOR 1
#define IRREGULAR_SEED 0
#define OFFSET 0

//Different for each Acc
#define IN0_DATA 0x11111111
#define OUT0_DATA 0x22222222
#define IN1_DATA 0x22222222
#define OUT1_DATA 0x33333333

/* Size of the contiguous chunks for scatter/gather */
#define CHUNK_SHIFT 20
#define CHUNK_SIZE BIT(CHUNK_SHIFT)
#define NCHUNK ((SYNTH_BUF_SIZE % CHUNK_SIZE == 0) ?		\
			(SYNTH_BUF_SIZE / CHUNK_SIZE) :		\
			(SYNTH_BUF_SIZE / CHUNK_SIZE) + 1)

// User defined registers

void dma_idx_setup(struct esp_device* dev, int p2p_store, int p2p_load, struct esp_device* p2p_src, int idx){
    esp_dma_mode_reset(dev, idx);
    if (p2p_store)
        esp_dma_mode_enable_dst(dev, idx);
    if (p2p_load) {
        esp_dma_mode_enable_src(dev, idx);
        esp_dma_mode_set_y(dev, idx, 0, esp_get_y(p2p_src));
        esp_dma_mode_set_x(dev, idx, 0, esp_get_x(p2p_src));
    }
}


int main(int argc, char * argv[])
{
	int n, trial;
	int ndev;
	struct esp_device *espdevs = NULL;
	unsigned coherence;
    struct esp_device dev0, dev1;
    dev0.addr = ACC0_ADDR;
    dev1.addr = ACC1_ADDR;


	for (trial = 0; trial < TRIALS; trial++) {
		{
			coherence = ACC_COH_NONE;
			unsigned **ptable = NULL;
			unsigned *mem;
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
            mem = aligned_malloc(SYNTH_BUF_SIZE);
            for (i = 0; i < IN_SIZE1; i++){
                mem[i] = IN0_DATA;
            }
            printf("  memory buffer base-address = %p\n", mem);

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
            /*setup just 2 entries for now*/
            dma_idx_setup(&dev0, 0, 0, NULL, 0);
            dma_idx_setup(&dev0, 1, 0, NULL, 1);

            if (scatter_gather) {
                iowrite32(&dev0, PT_ADDRESS_REG, (unsigned long) ptable);
                iowrite32(&dev0, PT_NCHUNK_REG, NCHUNK);
                iowrite32(&dev0, PT_SHIFT_REG, CHUNK_SHIFT);
                iowrite32(&dev0, SRC_OFFSET_REG, 0);
                iowrite32(&dev0, DST_OFFSET_REG, 0); // Sort runs in place
            } else {
                iowrite32(&dev0, SRC_OFFSET_REG, (unsigned long) mem);
                iowrite32(&dev0, DST_OFFSET_REG, (unsigned long) mem); // Sort runs in place
            }

            // Accelerator-specific registers
            iowrite32(&dev0, SYNTH_OFFSET_REG, OFFSET);
            iowrite32(&dev0, SYNTH_PATTERN_REG, PATTERN_STREAMING);
            iowrite32(&dev0, SYNTH_IN_SIZE_REG, IN_SIZE);
            iowrite32(&dev0, SYNTH_ACCESS_FACTOR_REG, ACCESS_FACTOR);
            iowrite32(&dev0, SYNTH_BURST_LEN_REG, BURST_LEN);
            iowrite32(&dev0, SYNTH_COMPUTE_BOUND_FACTOR_REG, COMPUTE_BOUND_FACTOR);
            iowrite32(&dev0, SYNTH_IRREGULAR_SEED_REG, IRREGULAR_SEED);
            iowrite32(&dev0, SYNTH_REUSE_FACTOR_REG, REUSE_FACTOR);
            iowrite32(&dev0, SYNTH_LD_ST_RATIO_REG, LD_ST_RATIO);
            iowrite32(&dev0, SYNTH_STRIDE_LEN_REG, STRIDE_LEN);
            iowrite32(&dev0, SYNTH_OUT_SIZE_REG, OUT_SIZE);
            iowrite32(&dev0, SYNTH_IN_PLACE_REG, IN_PLACE);
            iowrite32(&dev0, SYNTH_WR_DATA_REG, OUT0_DATA);
            iowrite32(&dev0, SYNTH_RD_DATA_REG, IN0_DATA);

            // Configure device
            iowrite32(&dev1, SELECT_REG, ioread32(&dev1, DEVID_REG));
            iowrite32(&dev1, COHERENCE_REG, coherence);
            dma_idx_setup(&dev1, 0, 0, NULL, 0);
            dma_idx_setup(&dev1, 0, 1, &dev0, 1);

            if (scatter_gather) {
                iowrite32(&dev1, PT_ADDRESS_REG, (unsigned long) ptable);
                iowrite32(&dev1, PT_NCHUNK_REG, NCHUNK);
                iowrite32(&dev1, PT_SHIFT_REG, CHUNK_SHIFT);
                iowrite32(&dev1, SRC_OFFSET_REG, 0);
                iowrite32(&dev1, DST_OFFSET_REG, 0); // Sort runs in place
            } else {
                iowrite32(&dev1, SRC_OFFSET_REG, (unsigned long) mem);
                iowrite32(&dev1, DST_OFFSET_REG, (unsigned long) mem); // Sort runs in place
            }

            // Accelerator-specific registers
            iowrite32(&dev1, SYNTH_OFFSET_REG, OFFSET);
            iowrite32(&dev1, SYNTH_PATTERN_REG, PATTERN_IRREGULAR);
            iowrite32(&dev1, SYNTH_IN_SIZE_REG, IN_SIZE);
            iowrite32(&dev1, SYNTH_ACCESS_FACTOR_REG, ACCESS_FACTOR);
            iowrite32(&dev1, SYNTH_BURST_LEN_REG, BURST_LEN);
            iowrite32(&dev1, SYNTH_COMPUTE_BOUND_FACTOR_REG, COMPUTE_BOUND_FACTOR);
            iowrite32(&dev1, SYNTH_IRREGULAR_SEED_REG, IRREGULAR_SEED);
            iowrite32(&dev1, SYNTH_REUSE_FACTOR_REG, REUSE_FACTOR);
            iowrite32(&dev1, SYNTH_LD_ST_RATIO_REG, LD_ST_RATIO);
            iowrite32(&dev1, SYNTH_STRIDE_LEN_REG, STRIDE_LEN);
            iowrite32(&dev1, SYNTH_OUT_SIZE_REG, OUT_SIZE);
            iowrite32(&dev1, SYNTH_IN_PLACE_REG, IN_PLACE);
            iowrite32(&dev1, SYNTH_WR_DATA_REG, OUT1_DATA); //dont care - not validating in this application
            iowrite32(&dev1, SYNTH_RD_DATA_REG, IN1_DATA); //dont care
// Flush for non-coherent DMA
            esp_flush(coherence);

            // Start accelerator
            printf("  Start..\n");
            iowrite32(&dev0, CMD_REG, CMD_MASK_START);
            iowrite32(&dev1, CMD_REG, CMD_MASK_START);
            unsigned dmareg= ioread32(&dev0, DMA_IDX_REG + 4);
            printf("Dev0 DMA reg1 value is: %x \n",dmareg );
            unsigned done = 0;

            while (!done) {
                done = ioread32(&dev0, STATUS_REG);
                done &= STATUS_MASK_DONE;
            }

            iowrite32(&dev0, CMD_REG, 0x0);
            printf("  Acc0 done...\n");
            printf("*************************************** \n \n");
            done = 0;
            while (!done) {
                done = ioread32(&dev1, STATUS_REG);
                done &= STATUS_MASK_DONE;
            }

            iowrite32(&dev1, CMD_REG, 0x0);
            // printf("  Validating...\n");


            // uint32_t start = IN_PLACE ? 0 : IN_SIZE*2;

            // for (i = start; i < start + OUT_SIZE*2; i++){
            //         printf("%x data \n", mem[i]);
            // }

            printf(" Acc1 Done\n");


            // Validation

            if (scatter_gather)
                aligned_free(ptable);
            aligned_free(mem);
			printf("**************************************************\n\n");
		}
	}
	return 0;
}
