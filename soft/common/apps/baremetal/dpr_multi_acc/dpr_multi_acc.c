/* Copyright (c) 2011-2023 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <monitors.h>

#include "prc_utils.h"
#include "dpr_multi_acc.h"
#include "mac.h"
#include "adder.h"

#define NUM_ACC_INVOC_ITER 5
//#define RUN_LOOP

#define SLD_ACC_TILE_1 0x98
#define DEV_NAME_ADDER "sld,adder_vivado"
#define DEV_NAME_MAC "sld,mac_vivado"

int main(int argc, char * argv[])
{
	int i; 
	int n;
	int ndev;
	unsigned done;
	unsigned errors = 0;
	unsigned coherence = ACC_COH_NONE;
	struct esp_device *espdevs_tile_1;
	struct esp_device *dev_tile_1;
	unsigned **ptable_adder, **ptable_mac;
	token_t *mem_adder, *mem_gold_adder;
    token_t *mem_mac, *mem_gold_mac;

    //MAC
    if (DMA_WORD_PER_BEAT(sizeof(token_t)) == 0) {
        in_words_adj = mac_len * mac_vec;
        out_words_adj = mac_vec;
    } else {
        in_words_adj = round_up(mac_len * mac_vec, DMA_WORD_PER_BEAT(sizeof(token_t)));
        out_words_adj = round_up(mac_vec, DMA_WORD_PER_BEAT(sizeof(token_t)));
    }
    in_len_mac = in_words_adj * (mac_n);
    out_len_mac = out_words_adj * (mac_n);
    in_size_mac = in_len_mac * sizeof(token_t);
    out_size_mac = out_len_mac * sizeof(token_t);
    out_offset_mac  = in_len_mac;
    mem_size_mac = (out_offset_mac * sizeof(token_t)) + out_size_mac;

#ifdef RUN_LOOP    
    for(k = 0; k < NUM_ACC_INVOC_ITER; k++) {	
#endif    
    //Adder acceleraotr section
	// Probing ADDER
	printf("  Probing... ADDER\n");
	
	// adder
	printf(" Initialize Adder app...\n");
	ndev = probe(&espdevs_tile_1, VENDOR_SLD, SLD_ACC_TILE_1, DEV_NAME_ADDER);
	if (ndev == 0) {
		printf("adder not found\n");
		return 0;
	}

	dev_tile_1 = &espdevs_tile_1[0];
    
    printf("  ****  Loading Adder accelerator onto FPGA  **** \n");
    reconfigure_FPGA(dev_tile_1, 0);	
    // Check DMA capabilities
	if (ioread32(dev_tile_1, PT_NCHUNK_MAX_REG) == 0) {
	    printf("  -> scatter-gather DMA is disabled. Abort.\n");
	    return 0;
	}
	if (ioread32(dev_tile_1, PT_NCHUNK_MAX_REG) < NCHUNK_ADDER) {
	    printf("  -> Not enough TLB entries available. Abort.\n");
	    return 0;
	}

	// Allocation
	printf("  Allocation...\n");

    // Allocate memory (will be contiguos anyway in baremetal)
    mem_adder = aligned_malloc(SIZE_ADDER);
    printf("  memory buffer base-address = %lu\n", (unsigned long) mem_adder);

    // Allocate memory for gold output
    mem_gold_adder = aligned_malloc(OUT_SIZE_ADDER);
    printf("  memory buffer base-address = %lu\n", (unsigned long) mem_gold_adder);

    
    // Allocate and populate page table
    ptable_adder = aligned_malloc(NCHUNK_ADDER * sizeof(unsigned *));
    for (i = 0; i < NCHUNK_ADDER; i++)
        ptable_adder[i] = (unsigned *)
        &mem_adder[i * (CHUNK_SIZE_ADDER / sizeof(unsigned))];

    printf("  ptable = %p\n", ptable_adder);
    printf("  nchunk = %lu\n", NCHUNK_ADDER);
    
    //initialize Adder memory
    init_buff_adder(mem_adder, mem_gold_adder);
    
    // Configure Adder accelerator
    iowrite32(dev_tile_1, SELECT_REG, ioread32(dev_tile_1, DEVID_REG));
    iowrite32(dev_tile_1, COHERENCE_REG, coherence);
    iowrite32(dev_tile_1, PT_ADDRESS_REG, (unsigned long) ptable_adder);
    iowrite32(dev_tile_1, PT_NCHUNK_REG, NCHUNK_ADDER);
    iowrite32(dev_tile_1, PT_SHIFT_REG, CHUNK_SHIFT_ADDER);
    iowrite32(dev_tile_1, SRC_OFFSET_REG, 0);
    iowrite32(dev_tile_1, DST_OFFSET_REG, 0);

    // Configure Adder registers
    iowrite32(dev_tile_1, NBURSTS_REG, 4);

    // Flush for non-coherent DMA
    esp_flush(coherence);

    // Start Adder accelerator
    printf("  Start..\n");
    iowrite32(dev_tile_1, CMD_REG, CMD_MASK_START);

    done = 0;

    while (!done) {
    done = ioread32(dev_tile_1, STATUS_REG);
    done &= STATUS_MASK_DONE;
    }

    iowrite32(dev_tile_1, CMD_REG, 0x0);
    printf("  Done\n");

    /* Validation */
    printf("  validating...\n");

    errors = 0;
    errors = validate_adder(mem_adder, mem_gold_adder);

    if (!errors) {
    printf("\n  Test PASSED!\n");
    } else {
    printf("\n  Test FAILED. Number of errors: %d\n", errors);
    }


    //reconfigure the accelerator tile :- load the mac accelerator
    printf("   **** Loading MAC accelerator onto FPGA ****\n");
    reconfigure_FPGA(dev_tile_1, 1);


    //MAC acceleraotr section
	// Probing
	printf("  Probing... MAC\n");

    // Search for the device
    printf("Scanning device tree... \n");

    ndev = probe(&espdevs_tile_1, VENDOR_SLD, SLD_ACC_TILE_1, DEV_NAME_MAC);
    if (ndev == 0) {
        printf("mac not found\n");
        return 0;
    }
   
    for (n = 0; n < ndev; n++) {

        printf("**************** %s.%d ****************\n", DEV_NAME, n);

        dev_tile_1 = &espdevs_tile_1[n];

        // Check DMA capabilities
        if (ioread32(dev_tile_1, PT_NCHUNK_MAX_REG) == 0) {
            printf("  -> scatter-gather DMA is disabled. Abort.\n");
            return 0;
        }

        if (ioread32(dev_tile_1, PT_NCHUNK_MAX_REG) < NCHUNK(mem_size_mac)) {
            printf("  -> Not enough TLB entries available. Abort.\n");
            return 0;
        }

        // Allocate memory
        mem_gold_mac = aligned_malloc(out_size_mac);
        mem_mac = aligned_malloc(mem_size_mac);
        printf("  memory buffer base-address = %p\n", mem_mac);

        // Alocate and populate page table
        ptable_mac = aligned_malloc(NCHUNK(mem_size_mac) * sizeof(unsigned *));
        for (i = 0; i < NCHUNK(mem_size_mac); i++)
            ptable_mac[i] = (unsigned *) &mem_mac[i * (CHUNK_SIZE_MAC / sizeof(token_t))];

        printf("  ptable = %p\n", ptable_mac);
        printf("  nchunk = %lu\n", NCHUNK(mem_size_mac));

#ifndef __riscv
        for (coherence = ACC_COH_NONE; coherence <= ACC_COH_RECALL; coherence++) {
#else
        {
            /* TODO: Restore full test once ESP caches are integrated */
            coherence = ACC_COH_NONE;
#endif
            printf("  --------------------\n");
            printf("  Generate input...\n");
            init_buf_mac(mem_mac, mem_gold_mac);

            // Pass common configuration parameters

            iowrite32(dev_tile_1, SELECT_REG, ioread32(dev_tile_1, DEVID_REG));
            iowrite32(dev_tile_1, COHERENCE_REG, coherence);

#ifndef __sparc
            iowrite32(dev_tile_1, PT_ADDRESS_REG, (unsigned long long) ptable_mac);
#else
            iowrite32(dev_tile_1, PT_ADDRESS_REG, (unsigned) ptable_mac);
#endif
            iowrite32(dev_tile_1, PT_NCHUNK_REG, NCHUNK(mem_size_mac));
            iowrite32(dev_tile_1, PT_SHIFT_REG, CHUNK_SHIFT_MAC);

            // Use the following if input and output data are not allocated at the default offsets
            iowrite32(dev_tile_1, SRC_OFFSET_REG, 0x0);
            iowrite32(dev_tile_1, DST_OFFSET_REG, 0x0);
           
            // Pass accelerator-specific configuration parameters
            /* <<--regs-config-->> */
            iowrite32(dev_tile_1, MAC_MAC_N_REG, mac_n);
            iowrite32(dev_tile_1, MAC_MAC_VEC_REG, mac_vec);
            iowrite32(dev_tile_1, MAC_MAC_LEN_REG, mac_len);

            // Flush (customize coherence model here)
            esp_flush(coherence);

            // Start accelerators
            printf("  Start...\n");
            iowrite32(dev_tile_1, CMD_REG, CMD_MASK_START);

            // Wait for completion
            done = 0;
            while (!done) {
                done = ioread32(dev_tile_1, STATUS_REG);
                done &= STATUS_MASK_DONE;
            }
            iowrite32(dev_tile_1, CMD_REG, 0x0);

            printf("  Done\n");
            printf("  validating...\n");

            /* Validation */
            errors = validate_buf_mac(&mem_mac[out_offset_mac], mem_gold_mac);
            if (errors)
                printf("  ... FAIL\n");
            else
                printf("  ... PASS\n");
        }
        aligned_free(ptable_mac);
        aligned_free(mem_mac);
        aligned_free(mem_gold_mac);
    }
    
    //reconfigure_FPGA(dev_tile_1, 0);
#ifdef RUN_LOOP    
}
#endif
    return 0;
}
