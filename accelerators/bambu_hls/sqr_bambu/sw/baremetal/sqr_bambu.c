/* Copyright (c) 2011-2024 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

/* Baremetal smoke test for the Bambu dataflow square 64-bit RTL accelerator:
 * out[i] = in[i]*in[i], repeated invocations with distinct batch contents. */

#include <stdio.h>
#ifndef __riscv
    #include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>
#include <fixed_point.h>

typedef uint32_t token_t;

/* Hardware DMA width is independent of the CPU pointer width. */
static unsigned DMA_WORD_PER_BEAT(unsigned _st) { return (8 / _st); }

#define SLD_SQR_BAMBU 0x07a
#define DEV_NAME    "sld,sqr_bambu"

/* Odd batch count exercises bank state across repeated invocations. */
const int32_t len = 272;
#define POLL_LIMIT 10000000U

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
#define SQR_BAMBU_LEN_REG      0x40
#define SQR_BAMBU_BASE_IN_REG  0x44
#define SQR_BAMBU_BASE_OUT_REG 0x48

static int validate_buf(token_t *out, token_t *gold)
{
    int j;
    unsigned errors = 0;

    for (j = 0; j < len; j++)
        if (gold[j] != out[j]) {
            errors++;
            if (errors < 8) printf("  [%d] got %x gold %x\n", j, out[j], gold[j]);
        }

    return errors;
}

static void init_buf(token_t *in, token_t *gold)
{
    int j;

    for (j = 0; j < len; j++)
        in[j] = (0x9e3779b9U * (j + 1)) ^ 0x10203041U;

    for (j = 0; j < len; j++)
        gold[j] = in[j] * in[j];

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
    unsigned total_errors = 0;
    unsigned poll;
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

    ndev = probe(&espdevs, VENDOR_SLD, SLD_SQR_BAMBU, DEV_NAME);
    if (ndev == 0) {
        printf("sqr_bambu not found\n");
        return 1;
    }

    for (n = 0; n < ndev; n++) {

        printf("**************** %s.%d ****************\n", DEV_NAME, n);

        dev = &espdevs[n];

        if (ioread32(dev, PT_NCHUNK_MAX_REG) == 0) {
            printf("  -> scatter-gather DMA is disabled. Abort.\n");
            return 1;
        }
        if (ioread32(dev, PT_NCHUNK_MAX_REG) < NCHUNK(mem_size)) {
            printf("  -> Not enough TLB entries available. Abort.\n");
            return 1;
        }

        gold = aligned_malloc(out_size);
        mem  = aligned_malloc(mem_size);
        if (!gold || !mem) {
            printf("sqr_bambu FAIL: allocation\n");
            return 1;
        }
        printf("  memory buffer base-address = %p\n", mem);

        ptable = aligned_malloc(NCHUNK(mem_size) * sizeof(unsigned *));
        if (!ptable) {
            printf("sqr_bambu FAIL: page-table allocation\n");
            return 1;
        }
        for (i = 0; i < NCHUNK(mem_size); i++)
            ptable[i] = (unsigned *)&mem[i * (CHUNK_SIZE / sizeof(token_t))];

        printf("  ptable = %p\n", ptable);
        printf("  nchunk = %lu\n", NCHUNK(mem_size));

#ifndef __riscv
        for (coherence = ACC_COH_NONE; coherence <= ACC_COH_RECALL; coherence++) {
#else
        for (unsigned run = 0; run < 3; ++run) {
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
            iowrite32(dev, SQR_BAMBU_LEN_REG, len);
            iowrite32(dev, SQR_BAMBU_BASE_IN_REG, 0);
            iowrite32(dev, SQR_BAMBU_BASE_OUT_REG, out_offset / DMA_WORD_PER_BEAT(sizeof(token_t)));

            esp_flush(coherence);

            printf("  Start...\n");
            iowrite32(dev, CMD_REG, CMD_MASK_START);

            done = 0;
            for (poll = 0; !done && poll < POLL_LIMIT; ++poll) {
                done = ioread32(dev, STATUS_REG);
                done &= STATUS_MASK_DONE;
            }
            if (!done) {
                printf("sqr_bambu FAIL: completion timeout\n");
                /* Retain memory: a timed-out DMA may still be active. */
                return 1;
            }
            iowrite32(dev, CMD_REG, 0x0);

            printf("  Done\n");
            printf("  validating...\n");

            errors = validate_buf(&mem[out_offset], gold);
            total_errors += errors;
            if (errors) printf("  ... FAIL (%u errors)\n", errors);
            else
                printf("  ... PASS\n");
        }
        aligned_free(ptable);
        aligned_free(mem);
        aligned_free(gold);
    }

    printf("sqr_bambu %s total_errors=%u\n", total_errors ? "FAIL" : "PASS", total_errors);
    return total_errors ? 1 : 0;
}
