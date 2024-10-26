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
#define NUM_MULTICAST_0 1
#define NUM_MULTICAST_1 14

// MCAST number of iterations = 8 * 9 (num_dest + 1)*(num_dest + 1)
#define IT 30

/* Size of the contiguous chunks for scatter/gather */
#define CHUNK_SHIFT 20
#define CHUNK_SIZE BIT(CHUNK_SHIFT)

#define MCAST_PACKET 1

static int validate_dummy_0(token_t *mem)
{
    int i, j;
    int rtn = 0;
    for (j = 0; j < BATCH; j++)
        for (i = 0; i < TOKENS; i++) {
//            if (i ==0 && j == 0) {
//                printf("%llu\n", mem[0]);
//            }
            if (mem[i + j * TOKENS] != (mask | (token_t) ((2 * BATCH * TOKENS) + (i + j * TOKENS)))) {
                // printf("[%d, %d]: %llu\n", j, i, mem[i + j * TOKENS]);
                rtn++;
            }
        }
    return rtn;
}

static int validate_dummy_1(token_t *mem)
{
    int i, j;
    int rtn = 0;
    for (j = 0; j < BATCH; j++)
        for (i = 0; i < TOKENS; i++) {
//            if (i ==0 && j == 0) {
//                printf("%llu\n", mem[0]);
//            }
            if (mem[i + j * TOKENS] != (mask | (token_t) ((BATCH * TOKENS) + (i + j * TOKENS)))) {
                // printf("[%d, %d]: %llu\n", j, i, mem[i + j * TOKENS]);
                rtn++;
            }
        }
    return rtn;
}

static void init_buf_0(token_t *mem)
{
    int i, j;
    for (j = 0; j < BATCH; j++)
        for (i = 0; i < TOKENS; i++)
            mem[i + j * TOKENS] = (mask | (token_t) ((2 * BATCH * TOKENS) + (i + j * TOKENS)));
}

static void init_buf_1(token_t *mem)
{
    int i, j;
    for (j = 0; j < BATCH; j++)
        for (i = 0; i < TOKENS; i++)
            mem[i + j * TOKENS] = (mask | (token_t) ((BATCH * TOKENS) + (i + j * TOKENS)));
}

static void clear_buf(token_t *mem)
{
    int i, j;
    for (j = 0; j < BATCH; j++)
        for (i = 0; i < TOKENS; i++)
            mem[i + j * TOKENS] = (mask | (token_t) (99999));
}

void p2p_setup(struct esp_device* dev, int p2p_store, int mcast_ndests, int p2p_load, struct esp_device* p2p_src, int mcast_packet){
    esp_p2p_reset(dev);
    if (p2p_store) {
        esp_p2p_enable_dst(dev);
        esp_p2p_set_mcast_ndests(dev, mcast_ndests);
        esp_p2p_set_mcast_packet(dev, mcast_packet);
    }
    if (p2p_load) {
        esp_p2p_enable_src(dev);
        esp_p2p_set_y(dev, 0, esp_get_y(p2p_src));
        esp_p2p_set_x(dev, 0, esp_get_x(p2p_src));
        esp_p2p_set_mcast_packet(dev, mcast_packet);
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
        int num_multicast_0 = NUM_MULTICAST_0;
        int num_multicast_1 = NUM_MULTICAST_1;
//	struct esp_device *devs = NULL;
	unsigned coherence;
        long long start, end;

    struct esp_device devs[17];
    ndev = 17;
    for (int i = 0; i < ndev; i++) {
        devs[i].addr = 0x60010000 + i * 0x100;
    }
        //printf("Scanning device tree...\n");
//	ndev = probe(&devs, VENDOR_SLD, SLD_DUMMY, DEV_NAME);
//	if (!ndev) {
//		printf("Error: %s device not found!\n", DEV_NAME);
//		exit(EXIT_FAILURE);
//	}

    //int mcast_ndests = ndev - 1;
    int dummy_buf_size = TOKENS * BATCH * sizeof(token_t) * (num_multicast_0 + num_multicast_1 + 1 + 1);
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
    //printf("\n  memory buffer base-address = %p\n", mem);
//    coherence = ACC_COH_RECALL;
    coherence = ACC_COH_NONE;

    //Alocate and populate page table
    ptable = aligned_malloc(nchunk * sizeof(unsigned *));
    for (i = 0; i < nchunk; i++)
        ptable[i] = (unsigned *) &mem[i * (CHUNK_SIZE / sizeof(token_t))];
    //printf("  ptable = %p\n", ptable);
    //printf("  nchunk = %lu\n\n", nchunk);

for (int it_0 = 0; it_0 < NUM_MULTICAST_0 + 1; it_0++) {
    for (int it_1 = 0; it_1 < NUM_MULTICAST_1 + 1; it_1++) {

    // Indexes
    int dev_id_0[NUM_MULTICAST_0 + 1] = {1, 13};
    int dev_id_1[NUM_MULTICAST_1 + 1] = {0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 14, 15, 16};
    int dev_id[NUM_MULTICAST_0 + NUM_MULTICAST_1 + 1 + 1] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16};

    // Swap indexes
    int int_tmp_0, int_tmp_1;
    int_tmp_0 = dev_id_0[it_0];
    dev_id_0[it_0] = dev_id_0[0]; 
    dev_id_0[0] = int_tmp_0;
   
    int_tmp_1 = dev_id_1[it_1];
    dev_id_1[it_1] = dev_id_1[0]; 
    dev_id_1[0] = int_tmp_1;

    dev_id[int_tmp_0] = dev_id[1];
    dev_id[1] = int_tmp_0;
    dev_id[int_tmp_1] = dev_id[0];
    dev_id[0] = int_tmp_1;

    // Initialize input: write floating point hex values (simpler to debug)
    init_buf_0(&mem[(dev_id_0[0]) * BATCH * TOKENS]);
    init_buf_1(&mem[(dev_id_1[0]) * BATCH * TOKENS]);


    for (int i = 0; i < num_multicast_0 + 1; i++) {
        // Configure device
        iowrite32(&devs[dev_id_0[i]], SELECT_REG, ioread32(&devs[dev_id_0[i]], DEVID_REG));
        iowrite32(&devs[dev_id_0[i]], COHERENCE_REG, coherence);
        if (i == 0)
            p2p_setup(&devs[dev_id_0[i]], 1, num_multicast_0, 0, NULL, MCAST_PACKET);
        else
            p2p_setup(&devs[dev_id_0[i]], 0, 0, 1, &devs[dev_id_0[0]], 0);

        iowrite32(&devs[dev_id_0[i]], PT_ADDRESS_REG, (unsigned long) ptable);
        iowrite32(&devs[dev_id_0[i]], PT_NCHUNK_REG, nchunk);
        iowrite32(&devs[dev_id_0[i]], PT_SHIFT_REG, CHUNK_SHIFT);
        iowrite32(&devs[dev_id_0[i]], SRC_OFFSET_REG, dev_id_0[0] * dummy_buf_size / (num_multicast_0 + num_multicast_1 + 1 + 1));
        iowrite32(&devs[dev_id_0[i]], DST_OFFSET_REG, dev_id_0[i] * dummy_buf_size / (num_multicast_0 + num_multicast_1 + 1 + 1));

        // Accelerator-specific registers
        iowrite32(&devs[dev_id_0[i]], TOKENS_REG, TOKENS);
        iowrite32(&devs[dev_id_0[i]], BATCH_REG, BATCH);
    }
    for (int i = 0; i < num_multicast_1 + 1; i++) {
        // Configure device
        iowrite32(&devs[dev_id_1[i]], SELECT_REG, ioread32(&devs[dev_id_1[i]], DEVID_REG));
        iowrite32(&devs[dev_id_1[i]], COHERENCE_REG, coherence);
        if (i == 0)
            p2p_setup(&devs[dev_id_1[i]], 1, num_multicast_1, 0, NULL, MCAST_PACKET);
        else
            p2p_setup(&devs[dev_id_1[i]], 0, 0, 1, &devs[dev_id_1[0]], 0);

        iowrite32(&devs[dev_id_1[i]], PT_ADDRESS_REG, (unsigned long) ptable);
        iowrite32(&devs[dev_id_1[i]], PT_NCHUNK_REG, nchunk);
        iowrite32(&devs[dev_id_1[i]], PT_SHIFT_REG, CHUNK_SHIFT);
        iowrite32(&devs[dev_id_1[i]], SRC_OFFSET_REG, dev_id_1[0] * dummy_buf_size / (num_multicast_0 + num_multicast_1 + 1 + 1));
        iowrite32(&devs[dev_id_1[i]], DST_OFFSET_REG, dev_id_1[i] * dummy_buf_size / (num_multicast_0 + num_multicast_1 + 1 + 1));

        // Accelerator-specific registers
        iowrite32(&devs[dev_id_1[i]], TOKENS_REG, TOKENS);
        iowrite32(&devs[dev_id_1[i]], BATCH_REG, BATCH);
    }

    // Flush for non-coherent DMA
    esp_flush(coherence);

    // Start accelerator
//    printf("  Starting multicast to %d accelerators...\n", num_multicast_0 + num_multicast_1);

    start = get_counter();

    for (int i = 0; i < num_multicast_0 + num_multicast_1 + 1 + 1; i++) {
        iowrite32(&devs[dev_id[i]], CMD_REG, CMD_MASK_START);
    }
    
//    printf(" Debug checkpoint 1\n");

    unsigned done = 0;

    while (!done) {
        done = STATUS_MASK_DONE;
//        printf("  Debug checkpoint 2\n");
        for (int i = 0; i < num_multicast_0 + num_multicast_1 + 1 + 1; i++){
            done &= (ioread32(&devs[i], STATUS_REG) & STATUS_MASK_DONE);
        }
//        printf("  Debug checkpoint 3\n");
    }

    end = get_counter();
//    printf("Total cycles = %lld\n", end - start);

    for (int i = 0; i < num_multicast_0 + num_multicast_1 + 1 + 1; i++) {
        iowrite32(&devs[i], CMD_REG, 0x0);
    }

//    printf("  Done\n");
//    printf("  Validating...\n\n");

    // Validation
    for (int i = 0; i < num_multicast_0; i++) {
        int error_increment = validate_dummy_0(&mem[(dev_id_0[i + 1]) * BATCH * TOKENS]);
        // errors += validate_dummy(&mem[(i + 1) * BATCH * TOKENS]);
        errors += error_increment;
//        printf("Memory Block %d Iterated...\n", i + 1);
//        if (!error_increment)
//            printf("Memory Block %d PASS\n", dev_id_0[i + 1]);
//        else
//            printf("Memory Block %d FAIL\n", dev_id_0[i + 1]);
    }
    for (int i = 0; i < num_multicast_1; i++) {
        int error_increment = validate_dummy_1(&mem[(dev_id_1[i + 1]) * BATCH * TOKENS]);
        // errors += validate_dummy(&mem[(i + 1) * BATCH * TOKENS]);
        errors += error_increment;
//        if (!error_increment)
//            printf("Memory Block %d PASS\n", dev_id_1[i + 1]);
//        else
//            printf("Memory Block %d FAIL\n", dev_id_1[i + 1]);
    }

    //printf("Total Errors %d for it_0 = %d, it_1 = %d\n", errors, it_0, it_1);
    if (!errors)
        printf("PASS for it_0 = %d, it_1 = %d\n", it_0, it_1);
    else
        printf("FAIL for it_0 = %d, it_1 = %d, Total Errors = %d\n", it_0, it_1, errors);
    
    errors = 0;

    for (int k = 0; k < 17; k++) {
       clear_buf(&mem[dev_id[k] * BATCH * TOKENS]);
    }
}//it1 for loop
}//it0 for loop
    aligned_free(ptable);
    aligned_free(mem);
	return 0;
}
