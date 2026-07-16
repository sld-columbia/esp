/* Copyright (c) 2011-2024 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

/* Baremetal smoke test for the bambu peek+ding-dong 64-bit RTL accelerator:
 * out[i] = in[i]*in[i], 128 words (fixed). */

#include <stdio.h>
#ifndef __riscv
    #include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>
#include <fixed_point.h>

typedef int32_t token_t;

static unsigned DMA_WORD_PER_BEAT(unsigned _st) { return (sizeof(void *) / _st); }

#define SLD_PEEK_DD 0x078
#define DEV_NAME    "sld,peek_dd"

/* <<--params-->>  (the core is fixed at 128 words / 8 batches of 16) */
const int32_t len = 128;

static unsigned in_words_adj;
static unsigned out_words_adj;
static unsigned in_len;
static unsigned out_len;
static unsigned in_size;
static unsigned out_size;
static unsigned out_offset;
static unsigned mem_size;

#define CHUNK_SHIFT 20
#define CHUNK_SIZE  BIT(CHUNK_SHIFT)
#define NCHUNK(_sz) ((_sz % CHUNK_SIZE == 0) ? (_sz / CHUNK_SIZE) : (_sz / CHUNK_SIZE) + 1)

/* User defined registers (xml param order: len, base_in, base_out) */
/* <<--regs-->> */
#define PEEK_DD_LEN_REG      0x40
#define PEEK_DD_BASE_IN_REG  0x44
#define PEEK_DD_BASE_OUT_REG 0x48

static int validate_buf(token_t *out, token_t *gold)
{
    int j;
    unsigned errors = 0;

    for (j = 0; j < len; j++)
        if (gold[j] != out[j]) {
            errors++;
            if (errors < 8) printf("  [%d] got %d gold %d\n", j, out[j], gold[j]);
        }

    return errors;
}

static void init_buf(token_t *in, token_t *gold)
{
    int j;

    for (j = 0; j < len; j++)
        in[j] = (token_t)j;

    for (j = 0; j < len; j++)
        gold[j] = (token_t)(j * j);

    /* Sentinel-fill the OUTPUT region: any word the accelerator fails to write
     * then reads back as 0xDEAD (a defined value) instead of X -- so validate
     * completes and reports it, rather than deadlocking Ariane on an X operand. */
    for (j = 0; j < len; j++)
        in[out_offset + j] = (token_t)0xDEAD;
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
        in_words_adj  = len;
        out_words_adj = len;
    }
    else {
        in_words_adj  = round_up(len, DMA_WORD_PER_BEAT(sizeof(token_t)));
        out_words_adj = round_up(len, DMA_WORD_PER_BEAT(sizeof(token_t)));
    }
    in_len     = in_words_adj;
    out_len    = out_words_adj;
    in_size    = in_len * sizeof(token_t);
    out_size   = out_len * sizeof(token_t);
    out_offset = in_len;
    mem_size   = (out_offset * sizeof(token_t)) + out_size;

    printf("Scanning device tree... \n");

    ndev = probe(&espdevs, VENDOR_SLD, SLD_PEEK_DD, DEV_NAME);
    if (ndev == 0) {
        printf("peek_dd not found\n");
        return 0;
    }

    for (n = 0; n < ndev; n++) {

        printf("**************** %s.%d ****************\n", DEV_NAME, n);

        dev = &espdevs[n];

        if (ioread32(dev, PT_NCHUNK_MAX_REG) == 0) {
            printf("  -> scatter-gather DMA is disabled. Abort.\n");
            return 0;
        }
        if (ioread32(dev, PT_NCHUNK_MAX_REG) < NCHUNK(mem_size)) {
            printf("  -> Not enough TLB entries available. Abort.\n");
            return 0;
        }

        gold = aligned_malloc(out_size);
        mem  = aligned_malloc(mem_size);
        printf("  memory buffer base-address = %p\n", mem);

        ptable = aligned_malloc(NCHUNK(mem_size) * sizeof(unsigned *));
        for (i = 0; i < NCHUNK(mem_size); i++)
            ptable[i] = (unsigned *)&mem[i * (CHUNK_SIZE / sizeof(token_t))];

        printf("  ptable = %p\n", ptable);
        printf("  nchunk = %lu\n", NCHUNK(mem_size));

#ifndef __riscv
        for (coherence = ACC_COH_NONE; coherence <= ACC_COH_RECALL; coherence++) {
#else
        {
            coherence = ACC_COH_NONE;
#endif
            printf("  --------------------\n");
            printf("  Generate input...\n");
            init_buf(mem, gold);

            iowrite32(dev, MCAST_REG, 0);
            iowrite32(dev, COHERENCE_REG, coherence);

#ifndef __sparc
            iowrite32(dev, PT_ADDRESS_REG, (unsigned long long)ptable);
#else
            iowrite32(dev, PT_ADDRESS_REG, (unsigned)ptable);
#endif
            iowrite32(dev, PT_NCHUNK_REG, NCHUNK(mem_size));
            iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);

            iowrite32(dev, SRC_OFFSET_REG, 0x0);
            iowrite32(dev, DST_OFFSET_REG, 0x0);

            /* <<--regs-config-->> */
            iowrite32(dev, PEEK_DD_LEN_REG, len);
            iowrite32(dev, PEEK_DD_BASE_IN_REG, 0);
            iowrite32(dev, PEEK_DD_BASE_OUT_REG, out_offset / DMA_WORD_PER_BEAT(sizeof(token_t)));

            esp_flush(coherence);

            printf("  Start...\n");
            iowrite32(dev, CMD_REG, CMD_MASK_START);

            done = 0;
            while (!done) {
                done = ioread32(dev, STATUS_REG);
                done &= STATUS_MASK_DONE;
            }
            iowrite32(dev, CMD_REG, 0x0);

            printf("  Done\n");
            printf("  validating...\n");

            errors = validate_buf(&mem[out_offset], gold);
            if (errors) printf("  ... FAIL (%u errors)\n", errors);
            else
                printf("  ... PASS\n");
        }
        aligned_free(ptable);
        aligned_free(mem);
        aligned_free(gold);
    }

    return 0;
}
