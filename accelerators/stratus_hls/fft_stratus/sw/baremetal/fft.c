/* Copyright (c) 2011-2025 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
    #include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>
#include <monitors.h>
#include "utils/fft_utils.h"

#if (FFT_FX_WIDTH == 64)
typedef long long token_t;
typedef double native_t;
    #define fx2float fixed64_to_double
    #define float2fx double_to_fixed64
    #define FX_IL    42
#else // (FFT_FX_WIDTH == 32)
typedef int token_t;
typedef float native_t;
    #define fx2float fixed32_to_float
    #define float2fx float_to_fixed32
    #define FX_IL    12
#endif /* FFT_FX_WIDTH */

const float ERR_TH = 0.05;

static unsigned DMA_WORD_PER_BEAT(unsigned _st) { return (sizeof(void *) / _st); }

#define SLD_FFT  0x059
#define DEV_NAME "sld,fft_stratus"

/* <<--params-->> */
const int32_t log_len    = 9;
const int32_t batch_size = 32;
int32_t len;
int32_t do_bitrev = 1;

static unsigned in_words_adj;
static unsigned out_words_adj;
static unsigned in_len;
static unsigned out_len;
static unsigned in_size;
static unsigned out_size;
static unsigned out_offset;
static unsigned mem_size;

/* Size of the contiguous chunks for scatter/gather */
#define CHUNK_SHIFT 20
#define CHUNK_SIZE  BIT(CHUNK_SHIFT)
#define NCHUNK(_sz) ((_sz % CHUNK_SIZE == 0) ? (_sz / CHUNK_SIZE) : (_sz / CHUNK_SIZE) + 1)

/* User defined registers */
/* <<--regs-->> */
#define FFT_DO_PEAK_REG    0x4c
#define FFT_DO_BITREV_REG  0x48
#define FFT_LOG_LEN_REG    0x44
#define FFT_BATCH_SIZE_REG 0x40

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
void spawn_hw_thread(int server_idx, int pbs_id, int new_div_sel_idx) {
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

static int validate_buf(token_t *out, float *gold)
{
    int j;
    unsigned errors = 0;

    for (j = 0; j < 2 * len * batch_size; j++) {
        native_t val = fx2float(out[j], FX_IL);
        if ((fabs(gold[j] - val) / fabs(gold[j])) > ERR_TH) { errors++; }
    }

    printf("  %u errors\n", errors);
    return errors;
}

static void init_buf(token_t *in, float *gold)
{
    int j;
    const float LO = -10.0;
    const float HI = 10.0;

    /* srand((unsigned int) time(NULL)); */

    for (j = 0; j < 2 * len * batch_size; j++) {
        float scaling_factor = (float)rand() / (float)RAND_MAX;
        gold[j]              = LO + scaling_factor * (HI - LO);
    }

    // preprocess with bitreverse (fast in software anyway)
    if (!do_bitrev) fft_bit_reverse(gold, len, log_len);

    // convert input to fixed point
    for (j = 0; j < 2 * len * batch_size; j++)
        in[j] = float2fx((native_t)gold[j], FX_IL);

    // Compute golden output
    for (j = 0; j < batch_size; j++)
        fft_comp(&gold[j * 2 * len], len, log_len, -1, do_bitrev);
}

int main(int argc, char *argv[])
{
    int i;
    int n;
    int ndev;
    struct esp_device *espdevs;
    struct esp_device *dev;
    unsigned done;
    unsigned **ptable = NULL;
    token_t *mem;
    float *gold;
    unsigned errors = 0;
    unsigned coherence;
    const unsigned ERROR_COUNT_TH = 1;
    unsigned int reads = 0;

    unsigned int cycles_start, cycles_end, cycles_diff;

    printf("Magic R\n");

    len = 1 << log_len;

    if (DMA_WORD_PER_BEAT(sizeof(token_t)) == 0) {
        in_words_adj  = 2 * len * batch_size;
        out_words_adj = 2 * len * batch_size;
    }
    else {
        in_words_adj  = round_up(2 * len * batch_size, DMA_WORD_PER_BEAT(sizeof(token_t)));
        out_words_adj = round_up(2 * len * batch_size, DMA_WORD_PER_BEAT(sizeof(token_t)));
    }
    in_len     = in_words_adj;
    out_len    = out_words_adj;
    in_size    = in_len * sizeof(token_t);
    out_size   = out_len * sizeof(token_t);
    out_offset = 0;
    mem_size   = (out_offset * sizeof(token_t)) + out_size;

    // Search for the device
    printf("Scanning device tree... \n");

    ndev = probe(&espdevs, VENDOR_SLD, SLD_FFT, DEV_NAME);
    if (ndev == 0) {
        printf("fft not found\n");
        return 0;
    }
    dev = &espdevs[0];
    init_server(0, dev, 2, 3);

    for (n = 0; n < NUM_FREQUENCIES; n++) {

        printf("**************** %s.%d ****************\n", DEV_NAME, n);
        spawn_hw_thread(0, 0, n);

        // Check DMA capabilities
        if (ioread32(dev, PT_NCHUNK_MAX_REG) == 0) {
            printf("  -> scatter-gather DMA is disabled. Abort.\n");
            return 0;
        }

        if (ioread32(dev, PT_NCHUNK_MAX_REG) < NCHUNK(mem_size)) {
            printf("  -> Not enough TLB entries available. Abort.\n");
            return 0;
        }

        // Allocate memory
        gold = aligned_malloc(out_len * sizeof(float));
        mem  = aligned_malloc(mem_size);
        printf("  memory buffer base-address = %p\n", mem);

        // Allocate and populate page table
        ptable = aligned_malloc(NCHUNK(mem_size) * sizeof(unsigned *));
        for (i = 0; i < NCHUNK(mem_size); i++)
            ptable[i] = (unsigned *)&mem[i * (CHUNK_SIZE / sizeof(token_t))];

        printf("  ptable = %p\n", ptable);
        printf("  nchunk = %lu\n", NCHUNK(mem_size));

        for (coherence = ACC_COH_NONE; coherence <= ACC_COH_NONE; coherence++) {
            printf("  --------------------\n");
            printf("  Generate input...\n");
            init_buf(mem, gold);

            // Pass common configuration parameters

            iowrite32(dev, COHERENCE_REG, coherence);

            iowrite32(dev, PT_ADDRESS_REG, (unsigned long)ptable);

            iowrite32(dev, PT_NCHUNK_REG, NCHUNK(mem_size));
            iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);

            // Use the following if input and output data are not allocated at the default offsets
            iowrite32(dev, SRC_OFFSET_REG, 0x0);
            iowrite32(dev, DST_OFFSET_REG, 0x0);

            // Pass accelerator-specific configuration parameters
            /* <<--regs-config-->> */
            iowrite32(dev, FFT_DO_PEAK_REG, 0);
            iowrite32(dev, FFT_DO_BITREV_REG, do_bitrev);
            iowrite32(dev, FFT_LOG_LEN_REG, log_len);
            iowrite32(dev, FFT_BATCH_SIZE_REG, batch_size);

            // Flush (customize coherence model here)
            esp_flush(coherence);

            // Start accelerators
            printf("  Start...\n");
            cycles_start = esp_monitor(mon_args, NULL);
            iowrite32(dev, CMD_REG, CMD_MASK_START);

            // Wait for completion
            done = 0;
            reads = 0;
            while (!done) {
                done = ioread32(dev, STATUS_REG);
                done &= STATUS_MASK_DONE;
                reads++;
            }
            iowrite32(dev, CMD_REG, 0x0);

            cycles_end = esp_monitor(mon_args, NULL);
            cycles_diff = sub_monitor_vals(cycles_start, cycles_end);

            printf("  Done\n");
            printf("  validating...\n");

            /* Validation */
            errors = validate_buf(&mem[out_offset], gold);
            if (errors > (ERROR_COUNT_TH * len / 100)) printf("  ... FAIL\n");
            else
                printf("  ... PASS\n");

            printf("  ... Division selection = %u, latency was %u (%u - %u)\n", div_sel[n], cycles_diff, cycles_end, cycles_start);
            printf("  ... %u reads\n", reads);
        }

        aligned_free(ptable);
        aligned_free(mem);
        aligned_free(gold);
    }

    log_power(0, EVENT_IDLE);

    write_and_read_div_sel(dev, 2, 0b100, 0);
    printf("Thanks for coming\n");

    return 0;
}
