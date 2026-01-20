/* Copyright (c) 2011-2025 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
    #include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>
#include <fixed_point.h>

typedef int32_t token_t;

static unsigned DMA_WORD_PER_BEAT(unsigned _st) { return (sizeof(void *) / _st); }

#define SLD_CONV1D 0x099
#define DEV_NAME             "sld,conv1d_sysc_catapult"

/* <<--params-->> */
const int32_t kernel_size = 0;
const int32_t n_channels = 0;
const int32_t stride = 1;
const int32_t is_relu = 0;
const int32_t addrB = 0;
const int32_t addrO = 0;
const int32_t addrI = 0;
const int32_t addrW = 0;
const int32_t batch_size = 1;
const int32_t n_filters = 0;
const int32_t feature_map_len = 0;
const int32_t padding = 0;

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
#define CONV1D_KERNEL_SIZE_REG 0x6c
#define CONV1D_N_CHANNELS_REG 0x68
#define CONV1D_STRIDE_REG 0x64
#define CONV1D_IS_RELU_REG 0x60
#define CONV1D_ADDRB_REG 0x5c
#define CONV1D_ADDRO_REG 0x58
#define CONV1D_ADDRI_REG 0x54
#define CONV1D_ADDRW_REG 0x50
#define CONV1D_BATCH_SIZE_REG 0x4c
#define CONV1D_N_FILTERS_REG 0x48
#define CONV1D_FEATURE_MAP_LEN_REG 0x44
#define CONV1D_PADDING_REG 0x40

static int validate_buf(token_t *out, token_t *gold)
{
    int i;
    int j;
    unsigned errors = 0;

    for (i = 0; i < batch_size; i++)
        for (j = 0; j < batch_size * feature_map_len * n_filters; j++)
            if (gold[i * out_words_adj + j] != out[i * out_words_adj + j]) errors++;

    return errors;
}

static void init_buf(token_t *in, token_t *gold)
{
    int i;
    int j;

    for (i = 0; i < batch_size; i++)
        for (j = 0; j < batch_size * feature_map_len * n_channels; j++)
            in[i * in_words_adj + j] = (token_t)j;

    for (i = 0; i < batch_size; i++)
        for (j = 0; j < batch_size * feature_map_len * n_filters; j++)
            gold[i * out_words_adj + j] = (token_t)j;
}

int main(int argc, char *argv[])
{
    int i;
    int n;
    int ndev;
    struct esp_device *espdevs;
    struct esp_device *dev;
    unsigned done;
    unsigned **ptable;
    token_t *mem;
    token_t *gold;
    unsigned errors = 0;
    unsigned coherence;

    if (DMA_WORD_PER_BEAT(sizeof(token_t)) == 0) {
        in_words_adj  = batch_size * feature_map_len * n_channels;
        out_words_adj = batch_size * feature_map_len * n_filters;
    }
    else {
        in_words_adj  = round_up(batch_size * feature_map_len * n_channels, DMA_WORD_PER_BEAT(sizeof(token_t)));
        out_words_adj = round_up(batch_size * feature_map_len * n_filters, DMA_WORD_PER_BEAT(sizeof(token_t)));
    }
    in_len     = in_words_adj * (batch_size);
    out_len    = out_words_adj * (batch_size);
    in_size    = in_len * sizeof(token_t);
    out_size   = out_len * sizeof(token_t);
    out_offset = in_len;
    mem_size   = (out_offset * sizeof(token_t)) + out_size;

    // Search for the device
    printf("Scanning device tree... \n");

    ndev = probe(&espdevs, VENDOR_SLD, SLD_CONV1D, DEV_NAME);
    if (ndev == 0) {
        printf("conv1d not found\n");
        return 0;
    }

    for (n = 0; n < ndev; n++) {

        printf("**************** %s.%d ****************\n", DEV_NAME, n);

        dev = &espdevs[n];

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
        gold = aligned_malloc(out_size);
        mem  = aligned_malloc(mem_size);
        printf("  memory buffer base-address = %p\n", mem);

        // Alocate and populate page table
        ptable = aligned_malloc(NCHUNK(mem_size) * sizeof(unsigned *));
        for (i = 0; i < NCHUNK(mem_size); i++)
            ptable[i] = (unsigned *)&mem[i * (CHUNK_SIZE / sizeof(token_t))];

        printf("  ptable = %p\n", ptable);
        printf("  nchunk = %lu\n", NCHUNK(mem_size));

        for (coherence = ACC_COH_NONE; coherence <= ACC_COH_RECALL; coherence++) {
            printf("  --------------------\n");
            printf("  Generate input...\n");
            init_buf(mem, gold);

            // Pass common configuration parameters
            iowrite32(dev, COHERENCE_REG, coherence);

#ifndef __sparc
            iowrite32(dev, PT_ADDRESS_REG, (unsigned long long)ptable);
#else
            iowrite32(dev, PT_ADDRESS_REG, (unsigned)ptable);
#endif
            iowrite32(dev, PT_NCHUNK_REG, NCHUNK(mem_size));
            iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);

            // Use the following if input and output data are not allocated at the default offsets
            iowrite32(dev, SRC_OFFSET_REG, 0x0);
            iowrite32(dev, DST_OFFSET_REG, 0x0);

            // Pass accelerator-specific configuration parameters
            /* <<--regs-config-->> */
			iowrite32(dev, CONV1D_KERNEL_SIZE_REG, kernel_size);
			iowrite32(dev, CONV1D_N_CHANNELS_REG, n_channels);
			iowrite32(dev, CONV1D_STRIDE_REG, stride);
			iowrite32(dev, CONV1D_IS_RELU_REG, is_relu);
			iowrite32(dev, CONV1D_ADDRB_REG, addrB);
			iowrite32(dev, CONV1D_ADDRO_REG, addrO);
			iowrite32(dev, CONV1D_ADDRI_REG, addrI);
			iowrite32(dev, CONV1D_ADDRW_REG, addrW);
			iowrite32(dev, CONV1D_BATCH_SIZE_REG, batch_size);
			iowrite32(dev, CONV1D_N_FILTERS_REG, n_filters);
			iowrite32(dev, CONV1D_FEATURE_MAP_LEN_REG, feature_map_len);
			iowrite32(dev, CONV1D_PADDING_REG, padding);

            // Flush (customize coherence model here)
            esp_flush(coherence);

            // Start accelerators
            printf("  Start...\n");
            iowrite32(dev, CMD_REG, CMD_MASK_START);

            // Wait for completion
            done = 0;
            while (!done) {
                done = ioread32(dev, STATUS_REG);
                done &= STATUS_MASK_DONE;
            }
            iowrite32(dev, CMD_REG, 0x0);

            printf("  Done\n");
            printf("  validating...\n");

            /* Validation */
            errors = validate_buf(&mem[out_offset], gold);
            if (errors) printf("  ... FAIL\n");
            else
                printf("  ... PASS\n");
        }
        aligned_free(ptable);
        aligned_free(mem);
        aligned_free(gold);
    }

    return 0;
}
