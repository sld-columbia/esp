/*
 * Copyright (c) 2011-2023 Columbia University, System Level Design Group
 * SPDX-License-Identifier: Apache-2.0
 */

/**
 * Baremetal device driver for DUMMY
 *
 * Select Scatter-Gather in ESP configuration
 */

#include <stdio.h>
#include <stdlib.h>
#include <esp_accelerator.h>
#include <esp_probe.h>
#include "dummy_multicast_p2p.h"

typedef long long unsigned u64;
typedef unsigned u32;
typedef u64 token_t;

#define SLD_DUMMY   0x042
#define DEV_NAME "sld,dummy_stratus"
#define TRIALS 1

#define TOKENS_REG 0x40
#define BATCH_REG 0x44

// User defined registers
#define TOKENS 512
#define BATCH 256
#define mask 0x0LL

// Control the number of consumers
//#define NUM_MULTICAST 16
#define NUM_MULTICAST 16

// MCAST Select the source ID
//#define SOURCE_DEV_ID 7
//#define SOURCE_DEV_ID 7

/* Size of the contiguous chunks for scatter/gather */
#define CHUNK_SHIFT 20
#define CHUNK_SIZE BIT(CHUNK_SHIFT)


static int validate_dummy(token_t *mem)
{
    int i, j;
    int rtn = 0;
    for (j = 0; j < BATCH; j++)
        for (i = 0; i < TOKENS; i++)
            if (mem[i + j * TOKENS] != (mask | (token_t) (i + j * TOKENS))) {
//                printf("[%d, %d]: %llu\n", j, i, mem[i + j * TOKENS]);
                rtn++;
            }
    return rtn;
}

static void init_buf(token_t *mem)
{
    int i, j;
    for (j = 0; j < BATCH; j++)
        for (i = 0; i < TOKENS; i++)
            mem[i + j * TOKENS] = (mask | (token_t) (i + j * TOKENS));
}

void p2p_setup(struct esp_device* dev, int p2p_store, int mcast_ndests, int p2p_load, struct esp_device* p2p_src, int mcast_nsrcs){
    esp_p2p_reset(dev);
    if (p2p_store) {
        esp_p2p_enable_dst(dev);
        esp_p2p_set_mcast_ndests(dev, mcast_ndests);
        esp_p2p_set_mcast_nsrcs(dev, mcast_nsrcs);
    }
    if (p2p_load) {
        esp_p2p_enable_src(dev);
        esp_p2p_set_y(dev, 0, esp_get_y(p2p_src));
        esp_p2p_set_x(dev, 0, esp_get_x(p2p_src));
        esp_p2p_set_mcast_nsrcs(dev, mcast_nsrcs);
    }
}

static inline uint64_t get_counter()
{
    uint64_t counter;
    asm volatile (
	"li t0, 0;"
	"csrr t0, mcycle;"
	"mv %0, t0"
	: "=r" ( counter )
	:
	: "t0"
        );
    return counter;
} 

int main(int argc, char * argv[])
{
	int n, trial, errors = 0;
	int ndev;
        int num_multicast = NUM_MULTICAST;
for (int source_dev_id = 0; source_dev_id < num_multicast + 1; source_dev_id++) {
        //int source_dev_id = SOURCE_DEV_ID;
//	struct esp_device *devs = NULL;
	unsigned coherence;
        long long start, end;

//    printf("Scanning device tree...\n");
//	ndev = probe(&devs, VENDOR_SLD, SLD_DUMMY, DEV_NAME);
//	if (!ndev) {
//		printf("Error: %s device not found!\n", DEV_NAME);
//		exit(EXIT_FAILURE);
//	}

    struct esp_device devs[17];
    ndev = 17;
    for (int i = 0; i < ndev; i++) {
        devs[i].addr = 0x60010000 + i * 0x100;
    }


    int mcast_ndests = ndev - 1;
    int dummy_buf_size = TOKENS * BATCH * sizeof(token_t) * (num_multicast + 1);
    int nchunk = (dummy_buf_size % CHUNK_SIZE == 0) ?
			(dummy_buf_size / CHUNK_SIZE) :
			(dummy_buf_size / CHUNK_SIZE) + 1;

	unsigned **ptable = NULL;
	token_t *mem;
    int i;

    // Check if scatter-gather DMA is disabled
    if (ioread32(&devs[i], PT_NCHUNK_MAX_REG) == 0) {
//        printf("  -> scatter-gather DMA is disabled. Abort.\n");
        return 0;
    }

    if (ioread32(&devs[i], PT_NCHUNK_MAX_REG) < nchunk) {
//        printf("  -> Not enough TLB entries available. Abort.\n");
        return 0;
    }

    // Allocate memory (will be contigous anyway in baremetal)
    mem = aligned_malloc(dummy_buf_size);
//    printf("\n  memory buffer base-address = %p\n", mem);
    coherence = ACC_COH_NONE;

    // Initialize input: write floating point hex values (simpler to debug)
    init_buf(&mem[source_dev_id * BATCH * TOKENS]);

    //Alocate and populate page table
    ptable = aligned_malloc(nchunk * sizeof(unsigned *));
    for (i = 0; i < nchunk; i++)
        ptable[i] = (unsigned *) &mem[i * (CHUNK_SIZE / sizeof(token_t))];
//    printf("  ptable = %p\n", ptable);
//    printf("  nchunk = %lu\n\n", nchunk);

    for (int i = 0; i < num_multicast + 1; i++) {
        // Configure device
        iowrite32(&devs[i], SELECT_REG, ioread32(&devs[i], DEVID_REG));
        iowrite32(&devs[i], COHERENCE_REG, coherence);
        if (i == source_dev_id)
            p2p_setup(&devs[i], 1, num_multicast, 0, NULL, 1);
        else
            p2p_setup(&devs[i], 0, 0, 1, &devs[source_dev_id], 0);

        iowrite32(&devs[i], PT_ADDRESS_REG, (unsigned long) ptable);
        iowrite32(&devs[i], PT_NCHUNK_REG, nchunk);
        iowrite32(&devs[i], PT_SHIFT_REG, CHUNK_SHIFT);
        iowrite32(&devs[i], SRC_OFFSET_REG, source_dev_id * dummy_buf_size / (num_multicast + 1));
        iowrite32(&devs[i], DST_OFFSET_REG, i * dummy_buf_size / (num_multicast + 1));

        // Accelerator-specific registers
        iowrite32(&devs[i], TOKENS_REG, TOKENS);
        iowrite32(&devs[i], BATCH_REG, BATCH);
    }

    // Flush for non-coherent DMA
    esp_flush(coherence);

    // Start accelerator
//    printf("  Starting multicast to %d accelerators...\n", num_multicast);

    start = get_counter();

    for (int i = 0; i < num_multicast + 1; i++) {
        iowrite32(&devs[i], CMD_REG, CMD_MASK_START);
    }

//    printf(" Debug checkpoint 1\n");

    unsigned done = 0;

    while (!done) {
        done = STATUS_MASK_DONE;
//        printf("  Debug checkpoint 2\n");
        for (int i = 0; i < num_multicast + 1; i++){
            done &= (ioread32(&devs[i], STATUS_REG) & STATUS_MASK_DONE);
        }
//        printf("  Debug checkpoint 3\n");
    }

    end = get_counter();
//    printf("Total cycles = %lld\n", end - start);

    for (int i = 0; i < num_multicast + 1; i++) {
        iowrite32(&devs[i], CMD_REG, 0x0);
    }

//    printf("  Done\n");
//    printf("  Validating...\n\n");

    // Validation
    for (int i = 0; i < num_multicast + 1; i++) {
        int error_increment = 0;
        if (i != source_dev_id) {
            error_increment = validate_dummy(&mem[i * BATCH * TOKENS]);
        }
        // errors += validate_dummy(&mem[(i + 1) * BATCH * TOKENS]);
        errors += error_increment;
//        printf("Memory Block %d Iterated...\n", i);
//        if (!error_increment)
//            printf("Memory Block %d PASS\n", i);
//        else
//            printf("Memory Block %d FAIL\n", i);
    }
//    printf("Total Errors %d\n", errors);
    if (!errors)
		printf("Source %d, PASS\n", source_dev_id);
    else
		printf("Source %d, FAIL\n", source_dev_id);

    aligned_free(ptable);
    aligned_free(mem);

}
	return 0;
}
