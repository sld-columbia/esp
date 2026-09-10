/* Copyright (c) 2011-2026 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

/*
 * Bare-metal test for vecadd_rtl, the RTL vector-add accelerator.
 *
 * C[i] = A[i] + B[i] over N 32-bit integers.
 *
 * The test sweeps several vector sizes rather than one. 
*/

#include <stdio.h>
#ifndef __riscv
    #include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>

typedef uint32_t token_t;

#define SLD_VECADD 0x0a0
#define DEV_NAME   "sld,vecadd_rtl"

#define VECADD_VECTOR_SIZE_REG 0x40
#define VECADD_CHUNK_SIZE_REG  0x44

#define VECADD_PLM_DEPTH 512

#define CHUNK_SHIFT 20
#define CHUNK_SIZE  BIT(CHUNK_SHIFT)
#define NCHUNK(_sz) ((_sz % CHUNK_SIZE == 0) ? (_sz / CHUNK_SIZE) : (_sz / CHUNK_SIZE) + 1)

#define POISON 0xDEADBEEF

#define POLL_LIMIT 200000000

struct test_cfg {
    unsigned    n;     /* elements per vector */
    unsigned    chunk; /* chunk_size register value; 0 selects the PLM depth */
    unsigned    eff;   /* chunk size the hardware is expected to settle on */
    const char *name;
};

static const struct test_cfg tests[] = {
    {1024, 256, 256, "aligned"},
    {1000, 256, 256, "with tail"},
    { 512, 512, 512, "exactly one chunk"},
    {1024,   0, VECADD_PLM_DEPTH, "chunk_size 0 clamps"},
    {1024, VECADD_PLM_DEPTH * 4, VECADD_PLM_DEPTH, "oversized chunk clamps"},
};

#define NTESTS  (sizeof(tests) / sizeof(tests[0]))
#define N_MAX   1024
#define MEM_LEN (3 * N_MAX)

static token_t gen_a(unsigned i) { return (token_t)(i * 3 + 1); }

static token_t gen_b(unsigned i) { return (token_t)(0x1000 - (int)i * 7); }

static void init_buf(token_t *mem, unsigned n)
{
    unsigned i;

    for (i = 0; i < n; i++) {
        mem[i]         = gen_a(i);
        mem[n + i]     = gen_b(i);
        mem[2 * n + i] = (token_t)POISON;
    }
}

static unsigned validate_buf(token_t *mem, unsigned n)
{
    unsigned i;
    unsigned errors    = 0;
    unsigned reported  = 0;
    unsigned corrupted = 0;

    for (i = 0; i < n; i++) {
        token_t gold = gen_a(i) + gen_b(i);

        if (mem[2 * n + i] != gold) {
            errors++;
            if (reported < 8) {
                printf("    C[%u] = 0x%08x, expected 0x%08x\n", i, (unsigned)mem[2 * n + i],
                       (unsigned)gold);
                reported++;
            }
        }
    }

    /* The accelerator must only ever write the C region. */
    for (i = 0; i < n; i++)
        if (mem[i] != gen_a(i) || mem[n + i] != gen_b(i)) corrupted++;

    if (corrupted) {
        printf("    %u input elements were overwritten\n", corrupted);
        errors += corrupted;
    }

    return errors;
}

int main(int argc, char *argv[])
{
    unsigned               i;
    int                    n;
    int                    ndev;
    unsigned               t;
    struct esp_device     *espdevs;
    struct esp_device     *dev;
    unsigned               done;
    unsigned               poll;
    unsigned             **ptable;
    token_t               *mem;
    unsigned               coherence;
    unsigned               errors      = 0;
    unsigned               tot_errors  = 0;
    unsigned               mem_size    = MEM_LEN * sizeof(token_t);

    printf("Scanning device tree... \n");


    ndev = probe(&espdevs, VENDOR_SLD, SLD_VECADD, DEV_NAME);
    if (ndev == 0) {
        printf("vecadd not found\n");
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

        mem = aligned_malloc(mem_size);
        printf("  memory buffer base-address = %p\n", mem);

        ptable = aligned_malloc(NCHUNK(mem_size) * sizeof(unsigned *));
        for (i = 0; i < NCHUNK(mem_size); i++)
            ptable[i] = (unsigned *)&mem[i * (CHUNK_SIZE / sizeof(token_t))];

        printf("  ptable = %p\n", ptable);
        printf("  nchunk = %lu\n", (unsigned long)NCHUNK(mem_size));

        for (coherence = ACC_COH_NONE; coherence <= ACC_COH_RECALL; coherence++) {

            printf("  --------------------\n");
            printf("  coherence model %u\n", coherence);

            for (t = 0; t < NTESTS; t++) {

                unsigned vn    = tests[t].n;
                unsigned chunk = tests[t].chunk;

                printf("   %-24s N=%u chunk=%u (effective %u)\n", tests[t].name, vn, chunk,
                       tests[t].eff);

                init_buf(mem, vn);

                iowrite32(dev, COHERENCE_REG, coherence);

                iowrite32(dev, PT_ADDRESS_REG, (unsigned long)ptable);
                iowrite32(dev, PT_NCHUNK_REG, NCHUNK(mem_size));
                iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);

                iowrite32(dev, SRC_OFFSET_REG, 0x0);
                iowrite32(dev, DST_OFFSET_REG, 0x0);

                /* Accelerator-specific configuration */
                iowrite32(dev, VECADD_VECTOR_SIZE_REG, vn);
                iowrite32(dev, VECADD_CHUNK_SIZE_REG, chunk);

                esp_flush(coherence);

                iowrite32(dev, CMD_REG, CMD_MASK_START);

                done = 0;
                poll = 0;
                while (!done) {
                    done = ioread32(dev, STATUS_REG);
                    done &= STATUS_MASK_DONE;
                    if (++poll > POLL_LIMIT) {
                        printf("    ... HANG (no done after %u polls)\n", POLL_LIMIT);
                        break;
                    }
                }
                iowrite32(dev, CMD_REG, 0x0);

                if (!done) {
                    tot_errors++;
                    continue;
                }

                errors = validate_buf(mem, vn);
                tot_errors += errors;

                if (errors)
                    printf("    ... FAIL (%u errors)\n", errors);
                else
                    printf("    ... PASS\n");
            }
        }

        aligned_free(ptable);
        aligned_free(mem);
    }

    printf("========================================\n");
    if (tot_errors == 0)
        printf(" vecadd: PASS\n");
    else
        printf(" vecadd: FAIL, %u errors\n", tot_errors);
    printf("========================================\n");

    return 0;
}
