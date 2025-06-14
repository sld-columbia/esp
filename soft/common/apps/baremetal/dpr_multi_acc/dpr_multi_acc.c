/* Copyright (c) 2011-2023 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <monitors.h>

#include "pbs_list.h"
#include "prc_utils.h"

#include "dpr_multi_acc.h"
#include "utils/fft_utils.h"
#include "mac.h"
#include "fft.h"

#define NUM_ACC_INVOC_ITER 1
#define RUN_LOOP
#define DO_DPR

//#undef PBS_IDX_FFT_STRATUS_2
#undef PBS_IDX_MAC_SYSC_CATAPULT_2

#define CURRENT_DEV SLD_FFT
#define CURRENT_DEV_NAME DEV_NAME_FFT

/* Scheduling */
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
unsigned int sched_cycles_start = 0, sched_cycles_new = 0, sched_cycles_diff = 0;
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
int get_dco_reg_addr(struct esp_device *dev, int tile_id) {
  return (0x60090000
        + 0x200 * tile_id)  // router base address
        + 0b111001100       // address of DCO register in NoC CSR file (addr[6:2] = 19)
        - dev->addr; // relative to device for call to iowrite32
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
void write_and_read_div_sel(struct esp_device *dev, int tile_id, int div_sel, int en) {
    tile_id = get_dco_reg_addr(dev, tile_id);
    iowrite32(dev, tile_id, encode_dco_ctrl(0, div_sel, 0, 0, 0, en));
    printf("Done writing register with div_sel = %d, en = %d, now reading\n", div_sel, en);
    tile_id = ioread32(dev, tile_id);
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
    printf("CSV:%u,%u,%u,%u,%u\n", sched_cycles_start, sched_cycles_new, sched_power_start, power_new, event_id);

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
void spawn_hw_thread(struct esp_device *dev, int server_idx, int pbs_id, int new_div_sel_idx) {
    server_runtime_t *server = &servers[server_idx];
    server_profile_t *profile = &profiles[server_idx];

    log_power(profile->power[server->div_sel_idx], EVENT_DPR_START);

    // load PBs
#ifdef DO_DPR
    reconfigure_FPGA(dev, pbs_id);
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
	int i, k;
	int n;
	int ndev;
	unsigned done;
	unsigned errors = 0;
    const unsigned ERROR_COUNT_TH = 1;
	unsigned coherence = ACC_COH_NONE;
	struct esp_device *espdevs_tile_1;
	struct esp_device *dev_tile_1;
	unsigned **ptable_mac, **ptable_fft;
    token_t *mem_mac, *mem_gold_mac;
    token_t *mem_fft;
    float *mem_gold_fft;

    printf("Hello from dpr_multi_acc\n");

    // MAC
    if (DMA_WORD_PER_BEAT(sizeof(token_t)) == 0) {
        in_words_adj_mac = mac_len * mac_vec;
        out_words_adj_mac = mac_vec;
    } else {
        in_words_adj_mac = round_up(mac_len * mac_vec, DMA_WORD_PER_BEAT(sizeof(token_t)));
        out_words_adj_mac = round_up(mac_vec, DMA_WORD_PER_BEAT(sizeof(token_t)));
    }
    in_len_mac = in_words_adj_mac * (mac_n);
    out_len_mac = out_words_adj_mac * (mac_n);
    in_size_mac = in_len_mac * sizeof(token_t);
    out_size_mac = out_len_mac * sizeof(token_t);
    out_offset_mac  = in_len_mac;
    mem_size_mac = (out_offset_mac * sizeof(token_t)) + out_size_mac;

    // FFT
    len_fft = 1 << log_len_fft;
    if (DMA_WORD_PER_BEAT(sizeof(token_t)) == 0) {
        in_words_adj_fft  = 2 * len_fft * batch_size_fft;
        out_words_adj_fft = 2 * len_fft * batch_size_fft;
    }
    else {
        in_words_adj_fft  = round_up(2 * len_fft * batch_size_fft, DMA_WORD_PER_BEAT(sizeof(token_t)));
        out_words_adj_fft = round_up(2 * len_fft * batch_size_fft, DMA_WORD_PER_BEAT(sizeof(token_t)));
    }
    in_len_fft     = in_words_adj_fft;
    out_len_fft    = out_words_adj_fft;
    in_size_fft    = in_len_fft * sizeof(token_t);
    out_size_fft   = out_len_fft * sizeof(token_t);
    out_offset_fft = 0;
    mem_size_fft   = (out_offset_fft * sizeof(token_t)) + out_size_fft;


#ifdef RUN_LOOP
    for(k = 0; k < NUM_ACC_INVOC_ITER; k++) {
#endif

    // Find tile
    printf("  Probing... device\n");
    ndev = probe(&espdevs_tile_1, VENDOR_SLD, CURRENT_DEV, CURRENT_DEV_NAME);
    if (ndev == 0) {
        printf("Reconfigurable tile not found, defaulting to tile @ 0x60010000\n");
        dev_tile_1->addr = 0x60010000;
    }
    else {
        dev_tile_1 = &espdevs_tile_1[0];
    }

    // test decoupling
    decouple_acc(dev_tile_1, 1);
    decouple_acc(dev_tile_1, 0);

#ifdef PBS_IDX_ADDER_VIVADO_2
    // Adder functionality
    printf("  ****  Loading Adder accelerator onto FPGA  **** \n");
#ifdef DO_DPR
    reconfigure_FPGA(dev_tile_1, PBS_IDX_ADDER_VIVADO_2);
#endif

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
    //iowrite32(dev_tile_1, SELECT_REG, ioread32(dev_tile_1, DEVID_REG));
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

#else
    printf("PBS_IDX_ADDER_VIVADO_2 not defined\n");
#endif // PBS_IDX_ADDER_VIVADO_2

#ifdef PBS_IDX_MAC_SYSC_CATAPULT_2
    //reconfigure the accelerator tile :- load the mac accelerator
    printf("   **** Loading MAC accelerator onto FPGA ****\n");

    decouple_acc(dev_tile_1, 1);
    decouple_acc(dev_tile_1, 0);

#ifdef DO_DPR
    reconfigure_FPGA(dev_tile_1, PBS_IDX_MAC_SYSC_CATAPULT_2);
#endif

	// Probing
	printf("  Probing... MAC\n");

    // Search for the device
    printf("Scanning device tree... \n");

    ndev = probe(&espdevs_tile_1, VENDOR_SLD, CURRENT_DEV, CURRENT_DEV_NAME);
    if (ndev == 0) {
        printf("Reconfigurable tile not found, defaulting to tile @ 0x60010000\n");
        dev_tile_1->addr = 0x60010000;
    }
    else {
        dev_tile_1 = &espdevs_tile_1[0];
    }

    for (n = 0; n < ndev; n++) {

        printf("**************** %s.%d ****************\n", DEV_NAME_MAC, n);

        dev_tile_1 = &espdevs_tile_1[n];

        // Check DMA capabilities
        if (ioread32(dev_tile_1, PT_NCHUNK_MAX_REG) == 0) {
            printf("  -> scatter-gather DMA is disabled. Abort.\n");
            return 0;
        }

        if (ioread32(dev_tile_1, PT_NCHUNK_MAX_REG) < NCHUNK_MAC(mem_size_mac)) {
            printf("  -> Not enough TLB entries available. Abort.\n");
            return 0;
        }

        // Allocate memory
        mem_gold_mac = aligned_malloc(out_size_mac);
        mem_mac = aligned_malloc(mem_size_mac);
        printf("  memory buffer base-address = %p\n", mem_mac);

        // Alocate and populate page table
        ptable_mac = aligned_malloc(NCHUNK_MAC(mem_size_mac) * sizeof(unsigned *));
        for (i = 0; i < NCHUNK_MAC(mem_size_mac); i++)
            ptable_mac[i] = (unsigned *) &mem_mac[i * (CHUNK_SIZE_MAC / sizeof(token_t))];

        printf("  ptable = %p\n", ptable_mac);
        printf("  nchunk = %lu\n", NCHUNK_MAC(mem_size_mac));

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
            //iowrite32(dev_tile_1, SELECT_REG, ioread32(dev_tile_1, DEVID_REG));
            iowrite32(dev_tile_1, COHERENCE_REG, coherence);

#ifndef __sparc
            iowrite32(dev_tile_1, PT_ADDRESS_REG, (unsigned long long) ptable_mac);
#else
            iowrite32(dev_tile_1, PT_ADDRESS_REG, (unsigned) ptable_mac);
#endif
            iowrite32(dev_tile_1, PT_NCHUNK_REG, NCHUNK_MAC(mem_size_mac));
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
#else

    printf("PBS_IDX_MAC_SYSC_CATAPULT_2 not defined\n");

#endif // PBS_IDX_MAC_SYSC_CATAPULT_2

#ifdef PBS_IDX_FFT_STRATUS_2
    // reconfigure the accelerator tile :- load the FFT accelerator
    printf("   **** Loading FFT accelerator onto FPGA ****\n");

    decouple_acc(dev_tile_1, 1);
    decouple_acc(dev_tile_1, 0);

#ifdef DO_DPR
    reconfigure_FPGA(dev_tile_1, PBS_IDX_FFT_STRATUS_2);
#endif

	// Probing
	printf("  Probing... FFT\n");

    // Search for the device
    printf("Scanning device tree... \n");

    ndev = probe(&espdevs_tile_1, VENDOR_SLD, CURRENT_DEV, CURRENT_DEV_NAME);
    if (ndev == 0) {
        printf("Reconfigurable tile not found, defaulting to tile @ 0x60010000\n");
        dev_tile_1->addr = 0x60010000;
    }
    else {
        dev_tile_1 = &espdevs_tile_1[0];
    }

    for (n = 0; n < ndev; n++) {
        printf("**************** %s.%d ****************\n", DEV_NAME_FFT, n);

        // Check DMA capabilities
        if (ioread32(dev_tile_1, PT_NCHUNK_MAX_REG) == 0) {
            printf("  -> scatter-gather DMA is disabled. Abort.\n");
            return 0;
        }

        if (ioread32(dev_tile_1, PT_NCHUNK_MAX_REG) < NCHUNK_FFT(mem_size_fft)) {
            printf("  -> Not enough TLB entries available. Abort.\n");
            return 0;
        }

        // Allocate memory
        mem_gold_fft = aligned_malloc(out_len_fft * sizeof(float));
        mem_fft      = aligned_malloc(mem_size_fft);
        printf("  memory buffer base-address = %p\n", mem_fft);

        // Allocate and populate page table
        ptable_fft = aligned_malloc(NCHUNK_FFT(mem_size_fft) * sizeof(unsigned *));
        for (i = 0; i < NCHUNK_FFT(mem_size_fft); i++)
            ptable_fft[i] = (unsigned *)&mem_fft[i * (CHUNK_SIZE_FFT / sizeof(token_t))];

        printf("  ptable = %p\n", ptable_fft);
        printf("  nchunk = %lu\n", NCHUNK_FFT(mem_size_fft));

#ifndef __riscv
        for (coherence = ACC_COH_NONE; coherence <= ACC_COH_NONE; coherence++) {
#else
        {
            /* TODO: Restore full test once ESP caches are integrated */
            coherence = ACC_COH_NONE;
#endif
            printf("  --------------------\n");
            printf("  Generate input...\n");
            init_buf_fft(mem_fft, mem_gold_fft);

            // Pass common configuration parameters

            iowrite32(dev_tile_1, COHERENCE_REG, coherence);

            iowrite32(dev_tile_1, PT_ADDRESS_REG, (unsigned long)ptable_fft);

            iowrite32(dev_tile_1, PT_NCHUNK_REG, NCHUNK_FFT(mem_size_fft));
            iowrite32(dev_tile_1, PT_SHIFT_REG, CHUNK_SHIFT_FFT);

            // Use the following if input and output data are not allocated at the default offsets
            iowrite32(dev_tile_1, SRC_OFFSET_REG, 0x0);
            iowrite32(dev_tile_1, DST_OFFSET_REG, 0x0);

            // Pass accelerator-specific configuration parameters
            /* <<--regs-config-->> */
            iowrite32(dev_tile_1, FFT_DO_PEAK_REG, 0);
            iowrite32(dev_tile_1, FFT_DO_BITREV_REG, do_bitrev_fft);
            iowrite32(dev_tile_1, FFT_LOG_LEN_REG, log_len_fft);
            iowrite32(dev_tile_1, FFT_BATCH_SIZE_REG, batch_size_fft);

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
            errors = validate_buf_fft(&mem_fft[out_offset_fft], mem_gold_fft);
            if (errors > (ERROR_COUNT_TH * len_fft / 100)) printf("  ... FAIL\n");
            else
                printf("  ... PASS\n");
        }

        aligned_free(ptable_fft);
        aligned_free(mem_fft);
        aligned_free(mem_gold_fft);
    }

#else

    printf("PBS_IDX_FFT_STRATUS_2 not defined\n");

#endif // PBS_IDX_FFT_STRATUS_2

#ifdef RUN_LOOP
}
#endif
    return 0;
}
