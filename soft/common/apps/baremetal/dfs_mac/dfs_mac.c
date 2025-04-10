/* Copyright (c) 2011-2023 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <monitors.h>

#include "soc_defs.h"
#include "soc_locs.h"

#include "dfs_mac.h"
#include "mac.h"

#define NUM_FREQUENCIES 1
//#define RUN_LOOP

#define SLD_ACC_TILE_1 0x98
#define DEV_NAME_MAC "sld,mac_vivado"

int main(int argc, char * argv[])
{
	  int i;
	  int k;
	  int n;
	  int ndev;
	  unsigned done;
	  unsigned high_time;
	  unsigned errors = 0;
	  unsigned coherence = ACC_COH_NONE;
	  struct esp_device *espdevs_tile_1;
	  struct esp_device *dev_tile_1;
	  unsigned **ptable_mac;
    token_t *mem_mac, *mem_gold_mac;

    printf("Hello from dfs_mac\n");

    // cycle monitor
    esp_monitor_args_t mon_args;
    const int CPU_TILE_IDX = 1;
    unsigned int cycles_start, cycles_end, cycles_diff;
    mon_args.read_mode = ESP_MON_READ_SINGLE;
    mon_args.tile_index = CPU_TILE_IDX;
    mon_args.mon_index = MON_DVFS_BASE_INDEX + 3;

    // MAC
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

    for(k = 0; k < NUM_FREQUENCIES; k++) {
        // half of the clock divider value
        //   output clock is high then low for (k+1) cycles of the PLL's reference
        //   divide by (k+1)+(k+1) = 2k+2
        //   fout = fin / (2k+2)
        high_time = k + 1;

        // MAC accelerator section
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
            /*printf("Checking DMA\n");
            if (ioread32(dev_tile_1, PT_NCHUNK_MAX_REG) == 0) {
                printf("  -> scatter-gather DMA is disabled. Abort.\n");
                return 0;
            }

            if (ioread32(dev_tile_1, PT_NCHUNK_MAX_REG) < NCHUNK(mem_size_mac)) {
                printf("  -> Not enough TLB entries available. Abort.\n");
                return 0;
            }*/

            // Allocate memory
            printf("Allocating memory\n");
            //mem_gold_mac = aligned_malloc(out_size_mac);
            //mem_mac = aligned_malloc(mem_size_mac);
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
                //init_buf_mac(mem_mac, mem_gold_mac);

                // Pass common configuration parameters

                //iowrite32(dev_tile_1, SELECT_REG, ioread32(dev_tile_1, DEVID_REG));
                printf("Writing basic configuration registers\n");
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
                printf("Done writing basic configuration registers\n");

                // MG configure clock frequency in bits [15:10]
                printf("Writing DCO\n");
                iowrite32(dev_tile_1, 3, (high_time & 0x3f) << 10);
                printf("Done writing DCO\n");

                // Pass accelerator-specific configuration parameters
                /* <<--regs-config-->> */
                printf("Writing specific configuration registers\n");
                iowrite32(dev_tile_1, MAC_MAC_N_REG, mac_n);
                iowrite32(dev_tile_1, MAC_MAC_VEC_REG, mac_vec);
                iowrite32(dev_tile_1, MAC_MAC_LEN_REG, mac_len);
                printf("Done writing configuration registers\n");

                // Flush (customize coherence model here)
                esp_flush(coherence);

                // Start accelerators
                printf("  Start...\n");
                cycles_start = esp_monitor(mon_args, NULL);
                iowrite32(dev_tile_1, CMD_REG, CMD_MASK_START);

                // Wait for completion
                done = 0;
                while (!done) {
                    done = ioread32(dev_tile_1, STATUS_REG);
                    done &= STATUS_MASK_DONE;
                }
                iowrite32(dev_tile_1, CMD_REG, 0x0);
                cycles_end = esp_monitor(mon_args, NULL);
                cycles_diff = sub_monitor_vals(cycles_start, cycles_end);

                printf("  Done\n");
                printf("  validating...\n");

                /* Validation */
                errors = validate_buf_mac(&mem_mac[out_offset_mac], mem_gold_mac);
                if (errors)
                    printf("  ... FAIL\n");
                else
                    printf("  ... PASS\n");
                printf("  ... latency of calculation was %u (%u - %u) core cycles\n", cycles_diff, cycles_end, cycles_start);
            }
            aligned_free(ptable_mac);
            aligned_free(mem_mac);
            aligned_free(mem_gold_mac);
        }

    }
    return 0;
}
