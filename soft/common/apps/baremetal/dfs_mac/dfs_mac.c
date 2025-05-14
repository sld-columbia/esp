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

#define SLD_ACC_TILE_1 0x98
#define DEV_NAME_MAC "sld,mac_vivado"
#define DEV_TILE_ID_MAC 2

//unsigned div_sel[7] = { 0b100, 0b101, 0b011, 0b110, 0b010, 0b111, 0b001 };
unsigned div_sel[7] = { 0b100, 0b100, 0b100, 0b100, 0b100, 0b101, 0b100 };

//#define MG_DEBUG

// Find tile 2 router address relative to tile 2 device
int get_dco_reg_addr(struct esp_device *dev_tile_1, int tile_id) {
  return (0x60090000
        + 0x200 * tile_id)  // router base address
        + 0b111001100       // address of DCO register in NoC CSR file (addr[6:2] = 19)
        - dev_tile_1->addr; // relative to device for call to iowrite32
}

// Encode new DCO configuration value
int encode_dco_ctrl(int freq_sel, int div_sel, int fc_sel, int cc_sel, int clk_sel, int en) {
    return ((      en & 0b000001) <<  0) |
           (( clk_sel & 0b000001) <<  1) |
           ((  cc_sel & 0b111111) <<  2) |
           ((  fc_sel & 0b111111) <<  8) |
           (( div_sel & 0b000111) << 14) |
           ((freq_sel & 0b000011) << 17);
}

// Configure new frequency
void write_and_read_div_sel(struct esp_device *dev_tile_1, int tile_id, int div_sel, int en) {
    tile_id = get_dco_reg_addr(dev_tile_1, tile_id);
    iowrite32(dev_tile_1, tile_id, encode_dco_ctrl(0, div_sel, 0, 0, 0, en));
    printf("Done writing register with div_sel = %d, en = %d, now reading\n", div_sel, en);
    int z = 1000000; while (z--);
    tile_id = ioread32(dev_tile_1, tile_id);
    printf("Read register and got %d\n", tile_id);
}

int main(int argc, char * argv[])
{
	  int i;
	  int k;
	  int n;
	  int ndev;
	  unsigned done;
	  unsigned errors = 0;
	  unsigned coherence = ACC_COH_NONE;
	  struct esp_device *espdevs_tile_1;
	  struct esp_device *dev_tile_1;
	  unsigned **ptable_mac;
    token_t *mem_mac, *mem_gold_mac;

    printf("Hello from dfs_mac\n");
    #ifdef MG_DEBUG
    printf("MG_DEBUG defined\n");
    #else
    printf("MG_DEBUG not defined\n");
    #endif

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

    for(k = 0; k < 7; k++) {
        // MAC accelerator section
        printf("  Probing... MAC\n");

        // Search for the device
        printf("Scanning device tree... \n");

        ndev = probe(&espdevs_tile_1, VENDOR_SLD, SLD_ACC_TILE_1, DEV_NAME_MAC);
        printf("Found %d devs\n", ndev);
        if (ndev == 0) {
            printf("mac not found\n");
            return 0;
        }

        printf("**************** %s.%d ****************\n", DEV_NAME, n);

        dev_tile_1 = &espdevs_tile_1[0];

        //write_and_read_div_sel(dev_tile_1, DEV_TILE_ID_MAC, 0b100, 0);
        write_and_read_div_sel(dev_tile_1, DEV_TILE_ID_MAC, div_sel[k], 1);

        /*#ifdef MG_DEBUG
        int z = 0;

        for (z = 0; z < 1000000; z++);
        printf("z is %d\n", z);
        write_and_read_div_sel(dev_tile_1, DEV_TILE_ID_MAC, 0b101, 1);

        for (z = 0; z < 1000000; z++);
        printf("z is %d\n", z);
        write_and_read_div_sel(dev_tile_1, DEV_TILE_ID_MAC, 0b100, 0);
        return 0;
        printf("Writing specific configuration registers\n");
        iowrite32(dev_tile_1, MAC_MAC_N_REG, mac_n);
        iowrite32(dev_tile_1, MAC_MAC_VEC_REG, mac_vec);
        iowrite32(dev_tile_1, MAC_MAC_LEN_REG, mac_len);
        printf("Done writing configuration registers\n");
        printf("Read status 0: %d\n", ioread32(dev_tile_1, STATUS_REG));
        #endif*/

        // Check DMA capabilities
        printf("Checking DMA\n");
        /*if (ioread32(dev_tile_1, PT_NCHUNK_MAX_REG) == 0) {
            printf("  -> scatter-gather DMA is disabled. Abort.\n");
            return 0;
        }

        if (ioread32(dev_tile_1, PT_NCHUNK_MAX_REG) < NCHUNK(mem_size_mac)) {
            printf("  -> Not enough TLB entries available. Abort.\n");
            return 0;
        }*/

        // Allocate memory
        printf("Allocating memory\n");
        mem_gold_mac = aligned_malloc(out_size_mac);
        mem_mac = aligned_malloc(mem_size_mac);
        printf("  memory buffer base-address = %p\n", mem_mac);

        // Alocate and populate page table
        ptable_mac = aligned_malloc(NCHUNK(mem_size_mac) * sizeof(unsigned *));
        for (i = 0; i < NCHUNK(mem_size_mac); i++)
            ptable_mac[i] = (unsigned *) &mem_mac[i * (CHUNK_SIZE_MAC / sizeof(token_t))];

        printf("  ptable = %p\n", ptable_mac);
        printf("  nchunk = %lu\n", NCHUNK(mem_size_mac));

        /*#ifdef MG_DEBUG
        iowrite32(dev_tile_1, PT_ADDRESS_REG, (unsigned) ptable_mac);
        iowrite32(dev_tile_1, PT_NCHUNK_REG, NCHUNK(mem_size_mac));
        iowrite32(dev_tile_1, PT_SHIFT_REG, CHUNK_SHIFT_MAC);

        printf("Writing start command\n");
        //iowrite32(dev_tile_1, CMD_REG, CMD_MASK_START);
        printf("Done writing start\n");
        printf("Read status 1: %d\n", ioread32(dev_tile_1, STATUS_REG));
        //iowrite32(dev_tile_1, CMD_REG, 0x0);
        printf("Done writing end\n");

        write_and_read_div_sel(dev_tile_1, DEV_TILE_ID_MAC, 0b110, 1);

        return 0;
        #endif*/

        // Configure clock frequency
        //printf("Writing DCO\n");
        //write_and_read_div_sel(dev_tile_1, DEV_TILE_ID_MAC, k, 1);
        //write_and_read_div_sel(dev_tile_1, DEV_TILE_ID_MAC, 0b100, 0);

        printf("  --------------------\n");
        printf("  Generate input...\n");
        iowrite32(dev_tile_1, CMD_REG, 0);
        init_buf_mac(mem_mac, mem_gold_mac);
        printf("  Done generating input\n");

        // Pass common configuration parameters

        //iowrite32(dev_tile_1, SELECT_REG, ioread32(dev_tile_1, DEVID_REG));
        printf("Writing basic configuration registers\n");
        iowrite32(dev_tile_1, COHERENCE_REG, ACC_COH_NONE);

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

        // Pass accelerator-specific configuration parameters
        iowrite32(dev_tile_1, MAC_MAC_N_REG, mac_n);
        iowrite32(dev_tile_1, MAC_MAC_VEC_REG, mac_vec);
        iowrite32(dev_tile_1, MAC_MAC_LEN_REG, mac_len);

        // Flush (customize coherence model here)
        esp_flush(coherence);

        // Start accelerators
        printf("  Start...\n");
        cycles_start = esp_monitor(mon_args, NULL);

        //for (int z = 0; z < 100; z++) {
        iowrite32(dev_tile_1, CMD_REG, CMD_MASK_START);

        // Wait for completion
        done = 0;
        int iterations;
        for (iterations = 0; iterations < 1000000 && !done; iterations++) {
            while (!done) {
                done = ioread32(dev_tile_1, STATUS_REG);
                done &= STATUS_MASK_DONE;
            }
        }
        iowrite32(dev_tile_1, CMD_REG, 0x0);
        if (iterations == 1000000) {
            printf("Warning: timed out at 1000000 iterations\n");
        }

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
        printf("  ... Division selection = %u, latency was %u (%u - %u)\n", div_sel[k], cycles_diff, cycles_end, cycles_start);

        write_and_read_div_sel(dev_tile_1, DEV_TILE_ID_MAC, 0b100, 0);

        aligned_free(ptable_mac);
        aligned_free(mem_mac);
        aligned_free(mem_gold_mac);

        printf("Completed iteration %d\n", i);
    }
    printf("Thanks for coming!\n");
    return 0;
}
