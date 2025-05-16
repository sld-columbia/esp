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

#define NUM_SERVERS 1
#define NUM_FREQUENCIES 7

// profiling for a server
typedef struct {
  unsigned duration[NUM_FREQUENCIES]; // microseconds
  unsigned power[NUM_FREQUENCIES];    // milliwatts
  unsigned reconf_time;               // microseconds
  unsigned reconf_cycles;             // cycles
} server_profile_t;

// current configuration
typedef struct {
  struct esp_device *dev_tile;
  unsigned tile_id;
  unsigned div_sel_idx;
} server_runtime_t;

// selection values for the clock multiplexor
unsigned div_sel[NUM_FREQUENCIES] = { 0b001, 0b010, 0b011, 0b100, 0b101, 0b110, 0b111 };

// cycle monitor
unsigned int sched_cycles_start = 0, sched_cycles_new, sched_cycles_diff;
unsigned int total_cycles = 0, total_time = 0;
unsigned sched_power_start;
esp_monitor_args_t mon_args = {ESP_MON_READ_SINGLE, 0xffff, 1, 0, MON_DVFS_BASE_INDEX + 3, 0};

// power profiles under each frequency
server_profile_t profiles[NUM_SERVERS] = {
  {
    { 489, 440, 398, 363, 328, 299, 273 },
    { 22, 24, 25, 27, 29, 30, 32 },
    618738,
    12374756
  }
};

// runtime configuration
server_runtime_t servers[NUM_SERVERS];

// Find tile router address relative to tile device
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
    printf("Done writing register at tile %d with div_sel = %d, now reading\n", tile_id, div_sel);
    //int z = 1000000; while (z--);
    tile_id = ioread32(dev_tile_1, tile_id);
    printf("Read register and got %d\n", tile_id);
}

// initialize server state
void init_server(unsigned server_idx, struct esp_device *dev, unsigned tile_id, unsigned div_sel_idx) {
  servers[server_idx].dev_tile = dev;
  servers[server_idx].tile_id = tile_id;
  servers[server_idx].div_sel_idx = div_sel_idx;
}

// print out power consumption statistics
void log_power(unsigned power_new, int event_id) {
    // calculate duration since last log
    sched_cycles_new = esp_monitor(mon_args, NULL);

    // previous cycle count, new cycle count, previous power, new power, message
    printf("CSV:%d,%d,%d,%d,%d\n", sched_cycles_start, sched_cycles_new, sched_power_start, power_new, event_id);

    // save values for this period
    sched_power_start = power_new;
    sched_cycles_start = sched_cycles_new;
}

#define EVENT_IDLE 0
#define EVENT_DPR_START 1
#define EVENT_DFS_START 2
#define EVENT_WRK_START 3
#ifndef DO_DPR
unsigned int dpr_wait_cycles_start = 0, dpr_wait_cycles_new, dpr_wait_cycles_diff;;
#endif
void spawn_hw_thread(int server_idx, int pbs_id, int new_div_sel_idx) {
    server_runtime_t *server = &servers[server_idx];
    server_profile_t *profile = &profiles[server_idx];

    log_power(profile->power[server->div_sel_idx], EVENT_DPR_START);

    // load PBs
#ifdef DO_DPR
    reconfigure_FPGA(dev_tile_1, pbs_id);
#else
    // wait for profiled reconfiguration time
    dpr_wait_cycles_start = esp_monitor(mon_args, NULL);
    do {
      dpr_wait_cycles_new = esp_monitor(mon_args, NULL);
      dpr_wait_cycles_diff = sub_monitor_vals(dpr_wait_cycles_start, dpr_wait_cycles_new);
    } while (dpr_wait_cycles_diff < profile->reconf_cycles);
#endif

    log_power(profile->power[server->div_sel_idx], EVENT_DFS_START);

    // schedule new frequency based on budget
    write_and_read_div_sel(server->dev_tile, server->tile_id, div_sel[new_div_sel_idx], 1);
    server->div_sel_idx = new_div_sel_idx;

    log_power(profile->power[server->div_sel_idx], EVENT_WRK_START);
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
        init_server(0, dev_tile_1, 2, 3);

        //write_and_read_div_sel(dev_tile_1, DEV_TILE_ID_MAC, 0b100, 0);
        //write_and_read_div_sel(dev_tile_1, DEV_TILE_ID_MAC, div_sel[k], 1);
        spawn_hw_thread(0, 0, k);

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

        printf("  --------------------\n");
        printf("  Generate input...\n");
        iowrite32(dev_tile_1, CMD_REG, 0);
        //init_buf_mac(mem_mac, mem_gold_mac);
        printf("  Done generating input\n");

        // Pass common configuration parameters

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
        printf("Writing specific configuration registers\n");
        iowrite32(dev_tile_1, MAC_MAC_N_REG, mac_n);
        iowrite32(dev_tile_1, MAC_MAC_VEC_REG, mac_vec);
        iowrite32(dev_tile_1, MAC_MAC_LEN_REG, mac_len);
        printf("Done writing specific configuration registers\n");

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
