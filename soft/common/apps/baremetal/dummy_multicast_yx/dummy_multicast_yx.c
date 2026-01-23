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
#include "dummy_multicast_yx.h"

typedef long long unsigned u64;
typedef unsigned u32;
typedef u64 token_t;

#define SLD_DUMMY   0x042
#define DEV_NAME "sld,dummy_stratus"
#define TRIALS 1
#define TEST_P2P // comment to test multicast */


#define TOKENS_REG 0x40
#define BATCH_REG 0x44
#define SOURCE_REG 0x48
#define NDESTS_REG 0x4C
#define P2P_TARGET_REG 0x50

// User defined registers
#define TOKENS 64

#ifdef TEST_P2P
#define BATCH_PROD 12 // must be set to ndev -1
#define BATCH_CONS 1
#else
#define BATCH_PROD 1
#define BATCH_CONS 1
// batch_prod and cons must be equal in the mcast test
#endif

#define mask 0x0LL

/* Size of the contiguous chunks for scatter/gather */
#define CHUNK_SHIFT 20
#define CHUNK_SIZE BIT(CHUNK_SHIFT)



static int validate_dummy(token_t *mem, int dst)
{
    int i, j;
    int rtn = 0;
#ifndef TEST_P2P
    for (j = 0; j < BATCH_PROD; j++)
        for (i = 0; i < TOKENS; i++)
            if (mem[i + j * TOKENS] != (mask | (token_t) i)) {
                printf("[%d, %d]: %llu\n", j, i, mem[i + j * TOKENS]);
                rtn++;
            
            }
#else
        for (i = 0; i < TOKENS; i++)
            if (mem[i] != (mask | (token_t) i )) {
                printf("[%d, %d]: %llu\n", dst,  i , mem[i]);
                rtn++;
            }
#endif

    return rtn;
}

static void init_buf(token_t *mem)
{
    int i, j;
    for (j = 0; j < BATCH_PROD; j++)
        for (i = 0; i < TOKENS; i++)
            mem[i + j * TOKENS] = (mask | (token_t) i);
}



#define PRODUCER_ID 0
int main(int argc, char * argv[])
{
	int n, trial, errors = 0;
	int ndev;
	struct esp_device *devs;
	unsigned coherence;

    printf("Scanning device tree...\n");
	ndev = probe(&devs, VENDOR_SLD, SLD_DUMMY, DEV_NAME);
	if (!ndev) {
		printf("Error: %s device not found!\n", DEV_NAME);
		exit(EXIT_FAILURE);
	}

    int trans_ndests = ndev - 1;
    int in_buf_size = TOKENS * BATCH_PROD * sizeof(token_t);
    int out_buf_size = TOKENS * BATCH_CONS * sizeof(token_t);
    int dummy_buf_size = in_buf_size + out_buf_size * trans_ndests;
    int nchunk = (dummy_buf_size % CHUNK_SIZE == 0) ?
			(dummy_buf_size / CHUNK_SIZE) :
			(dummy_buf_size / CHUNK_SIZE) + 1;

	unsigned **ptable = NULL;
	token_t *mem;
    int i;

    // Check if scatter-gather DMA is disabled
    if (ioread32(&devs[i], PT_NCHUNK_MAX_REG) == 0) {
        printf("  -> scatter-gather DMA is disabled. Abort.\n");
        return 0;
    }

    if (ioread32(&devs[i], PT_NCHUNK_MAX_REG) < nchunk) {
        printf("  -> Not enough TLB entries available. Abort.\n");
        return 0;
    }

    // Allocate memory (will be contigous anyway in baremetal)
    mem = aligned_malloc(dummy_buf_size);
    printf("\n  memory buffer base-address = %p\n", mem);
    /* coherence = ACC_COH_RECALL; */
    coherence = ACC_COH_NONE;

    // Initialize input: write floating point hex values (simpler to debug)
    init_buf(mem);

    //Alocate and populate page table
    ptable = aligned_malloc(nchunk * sizeof(unsigned *));
    for (i = 0; i < nchunk; i++)
        ptable[i] = (unsigned *) &mem[i * (CHUNK_SIZE / sizeof(unsigned))];
    printf("  ptable = %p\n", ptable);
    printf("  nchunk = %lu\n\n", nchunk);

    int store_count = 0;
    for (int i = 0; i < trans_ndests + 1; i++) {
        int batch = (i == PRODUCER_ID) ? BATCH_PROD : BATCH_CONS;
        // Configure device
        iowrite32(&devs[i], COHERENCE_REG, coherence);

        iowrite32(&devs[i], PT_ADDRESS_REG, (unsigned long) ptable);
        iowrite32(&devs[i], PT_NCHUNK_REG, nchunk);
        iowrite32(&devs[i], PT_SHIFT_REG, CHUNK_SHIFT);
        iowrite32(&devs[i], SRC_OFFSET_REG, 0);
        iowrite32(&devs[i], DST_OFFSET_REG, in_buf_size + store_count * out_buf_size);
        esp_set_acc_yx_table(&devs[i], devs, ndev);

        // Accelerator-specific registers
        iowrite32(&devs[i], TOKENS_REG, TOKENS);
        iowrite32(&devs[i], BATCH_REG, batch);

        if (i == PRODUCER_ID) {
            iowrite32(&devs[i], SOURCE_REG, 0);
            #ifdef TEST_P2P
            iowrite32(&devs[i], NDESTS_REG, 1);
            iowrite32(&devs[i], P2P_TARGET_REG, PRODUCER_ID + 2);
            #else
            iowrite32(&devs[i], NDESTS_REG, trans_ndests);
            iowrite32(&devs[i], P2P_TARGET_REG, 0);
            #endif
        } else {
            iowrite32(&devs[i], SOURCE_REG, PRODUCER_ID + 1);
            iowrite32(&devs[i], P2P_TARGET_REG, 0);
            iowrite32(&devs[i], NDESTS_REG, 0);
            store_count++;
        }
    }

    // Flush for non-coherent DMA
    esp_flush(coherence);

    // Start accelerator
    printf("  Starting multicast to %d accelerators...\n", trans_ndests);

    // for (int i = 0; i < trans_ndests + 1; i++) {
    //     iowrite32(&devs[i], CMD_REG, CMD_MASK_START);
    // }

    for (int i = trans_ndests; i >= 0; i--) {
        iowrite32(&devs[i], CMD_REG, CMD_MASK_START);
    }


    unsigned done = 0;

    while (!done) {
        done = STATUS_MASK_DONE;
        for (int i = 0; i < trans_ndests + 1; i++){
            done &= (ioread32(&devs[i], STATUS_REG) & STATUS_MASK_DONE);
        }
    }

    for (int i = 0; i < trans_ndests + 1; i++) {
        iowrite32(&devs[i], CMD_REG, 0x0);
    }


    printf("  Done\n");
    printf("  Validating...\n\n");

    // Validation
    for (int i = 0; i < trans_ndests; i++) {
        #ifndef TEST_P2P
        errors += validate_dummy(&mem[(i + 1) * BATCH_PROD * TOKENS], i);
        #else
        errors += validate_dummy(&mem[(i + 1) * TOKENS], i);
        #endif
    }
    if (!errors)
		printf("PASS\n");
    else
		printf("FAIL\n");

    aligned_free(ptable);
    aligned_free(mem);

	return 0;
}
