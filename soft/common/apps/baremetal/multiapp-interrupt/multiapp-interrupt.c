/* Copyright (c) 2011-2026 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

/*
 * multiapp_interrupt
 *
 * Drives vecadd_rtl and mac_sysc_catapult CONCURRENTLY using PLIC interrupts
 * instead of polling STATUS_REG: both accelerators are configured and
 * started back to back before either is waited on, and a single shared
 * handle_trap() services whichever one completes first, then the other. A
 * single PLIC claim only ever reports one pending source at a time, so
 * handle_trap() drains it in a loop rather than assuming one claim/complete
 * pair per trap, in case both accelerators finish close enough together
 * that both are pending at once.
 */

#include <stdio.h>
#ifndef __riscv
    #include <stdlib.h>
#endif

#ifndef __riscv
#error "multiapp_interrupt uses RISC-V PLIC MMIO registers and CSRs; it is ariane-only."
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>
#include <fixed_point.h>

#define MCAUSE_INTERRUPT_BIT (1UL << 63)

#define PLIC_BASE           0x6c000000UL
#define PLIC_PRIORITY(src)  (PLIC_BASE + 4 * (src))
#define PLIC_ENABLE_CTX0    (PLIC_BASE + 0x2000)
#define PLIC_THRESH_CTX0    (PLIC_BASE + 0x200000)
#define PLIC_CLAIM_CTX0     (PLIC_BASE + 0x200004)  /* same address for claim (read) and complete (write) */

static void plic_setup(unsigned irq)
{
    *(volatile unsigned *)PLIC_PRIORITY(irq) = 2;            /* nonzero: priority 0 never fires */
    *(volatile unsigned *)PLIC_ENABLE_CTX0   |= (1 << irq);  /* enable this source for context 0 */
    *(volatile unsigned *)PLIC_THRESH_CTX0    = 0;           /* admit any nonzero priority */
}

/* -----------------------------------------------------------------------
 * Multi-device IRQ dispatch table, shared by both accelerators.
 * -----------------------------------------------------------------------
 */
#define NIRQDEV 2

struct irq_dev {
    struct esp_device *dev;
    volatile unsigned  fired;
};

static struct irq_dev irq_devs[NIRQDEV];
static unsigned        n_irq_devs = 0;

/* Configures dev's PLIC source and adds it to the dispatch table */
static unsigned irq_register(struct esp_device *dev)
{
    unsigned idx = n_irq_devs;
    plic_setup(dev->irq);
    irq_devs[idx].dev   = dev;
    irq_devs[idx].fired = 0;
    n_irq_devs++;
    return idx;
}

/*  A single PLIC claim reports only one pending source at a time, so this
 * drains the claim register in a loop rather than assuming one claim/
 * complete pair per trap: if vecadd_rtl and mac_sysc_catapult happen to
 * complete close enough together that both are pending when this runs, both
 * get serviced before returning. */
void *handle_trap(unsigned long mcause, void *mepc, void *sp)
{
    if (mcause == (MCAUSE_INTERRUPT_BIT | IRQ_M_EXT)) {
        unsigned id;
        while ((id = *(volatile unsigned *)PLIC_CLAIM_CTX0) != 0) {
            unsigned i;
            for (i = 0; i < n_irq_devs; i++) {
                if (irq_devs[i].dev->irq == id) {
                    irq_devs[i].fired = 1;
                    iowrite32(irq_devs[i].dev, CMD_REG, 0x0);
                    break;
                }
            }
            *(volatile unsigned *)PLIC_CLAIM_CTX0 = id;   /* complete: re-arms the source */
        }
    }
    return mepc;
}

#define CHUNK_SHIFT 20
#define CHUNK_SIZE  BIT(CHUNK_SHIFT)
#define NCHUNK(_sz) ((_sz % CHUNK_SIZE == 0) ? (_sz / CHUNK_SIZE) : (_sz / CHUNK_SIZE) + 1)

typedef int32_t vecadd_token_t;

#define VECADD_SLD_ID   0x0a0
#define VECADD_DEV_NAME "sld,vecadd_rtl"

#define VECADD_VECTOR_SIZE_REG 0x40
#define VECADD_CHUNK_SIZE_REG  0x44

#define VECADD_POISON ((vecadd_token_t)0xDEADBEEF)

#define VECADD_N      1024
#define VECADD_CHUNK  256
#define VECADD_MEM_LEN (3 * (VECADD_N + 1))

static unsigned vecadd_m_of(unsigned n) { return n + (n & 1U); }

static vecadd_token_t vecadd_gen_a(unsigned i) { return (vecadd_token_t)(i * 3 + 1); }

static vecadd_token_t vecadd_gen_b(unsigned i) { return (vecadd_token_t)(0x1000 - (int)i * 7); }

static void vecadd_init_buf(vecadd_token_t *mem, unsigned n)
{
    unsigned i, m = vecadd_m_of(n);

    for (i = 0; i < n; i++) {
        mem[i]         = vecadd_gen_a(i);
        mem[m + i]     = vecadd_gen_b(i);
        mem[2 * m + i] = VECADD_POISON;
    }
}

static unsigned vecadd_validate_buf(vecadd_token_t *mem, unsigned n)
{
    unsigned i, m = vecadd_m_of(n);
    unsigned errors    = 0;
    unsigned reported  = 0;
    unsigned corrupted = 0;

    for (i = 0; i < n; i++) {
        vecadd_token_t gold = vecadd_gen_a(i) + vecadd_gen_b(i);

        if (mem[2 * m + i] != gold) {
            errors++;
            if (reported < 8) {
                printf("    vecadd_rtl C[%u] = 0x%08x, expected 0x%08x\n", i,
                       (unsigned)mem[2 * m + i], (unsigned)gold);
                reported++;
            }
        }
    }

/*
    for (i = 0; i < n; i++)
        if (mem[i] != vecadd_gen_a(i) || mem[m + i] != vecadd_gen_b(i)) corrupted++;

    if (corrupted) {
        printf("    vecadd_rtl: %u input elements were overwritten\n", corrupted);
        errors += corrupted;
    }
*/
    return errors;
}

/* =========================================================================
 * mac_sysc_catapult side, following mac.c directly: same test parameters
 * and buffer-sizing formulas, renamed with a mac_ prefix.
 * ========================================================================= */
typedef int32_t mac_token_t;

static unsigned mac_dma_word_per_beat(unsigned _st) { return (sizeof(void *) / _st); }

#define MAC_SLD_ID   0x04a
#define MAC_DEV_NAME "sld,mac_sysc_catapult"

const int32_t mac_n   = 1;
const int32_t mac_vec = 8;
const int32_t mac_len = 16;

static unsigned mac_in_words_adj;
static unsigned mac_out_words_adj;
static unsigned mac_in_len;
static unsigned mac_out_len;
static unsigned mac_in_size;
static unsigned mac_out_size;
static unsigned mac_out_offset;
static unsigned mac_mem_size;

#define MAC_MAC_N_REG   0x48
#define MAC_MAC_VEC_REG 0x44
#define MAC_MAC_LEN_REG 0x40

static unsigned mac_validate_buf(mac_token_t *out, mac_token_t *gold)
{
    int i, j;
    unsigned errors = 0;

    for (i = 0; i < mac_n; i++)
        for (j = 0; j < mac_vec; j++)
            if (gold[i * mac_out_words_adj + j] != out[i * mac_out_words_adj + j]) errors++;

    return errors;
}

static void mac_init_buf(mac_token_t *in, mac_token_t *gold)
{
    int i, j, k = 0;
    float out_gold;

    for (i = 0; i < mac_n; i++) {
        for (j = 0; j < mac_len * mac_vec; j++) {
            float data                   = ((i * 8 + j + k) % 32) + 0.25;
            mac_token_t data_fxd         = float_to_fixed32(data, 16);
            in[i * mac_in_words_adj + j] = data_fxd;
        }
        k++;
    }

    for (i = 0; i < mac_n; i++)
        for (j = 0; j < mac_vec; j++) {
            out_gold = 0;
            for (k = 0; k < mac_len; k += 2) {
                float data1 = fixed32_to_float(in[i * mac_in_words_adj + j * mac_len + k], 16);
                float data2 = fixed32_to_float(in[i * mac_in_words_adj + j * mac_len + k + 1], 16);
                out_gold += data1 * data2;
            }
            gold[i * mac_out_words_adj + j] = float_to_fixed32(out_gold, 16);
        }
}

int main(int argc, char *argv[])
{
    unsigned       i;
    const unsigned coherence      = ACC_COH_NONE;
    unsigned       overall_errors = 0;

    int                vecadd_ndev;
    struct esp_device *vecadd_espdevs, *vecadd_dev;
    unsigned          **vecadd_ptable;
    vecadd_token_t     *vecadd_mem;
    unsigned            vecadd_mem_size = VECADD_MEM_LEN * sizeof(vecadd_token_t);
    unsigned            vecadd_idx, vecadd_errors = 0;

    int                mac_ndev;
    struct esp_device *mac_espdevs, *mac_dev;
    unsigned          **mac_ptable;
    mac_token_t        *mac_mem, *mac_gold;
    unsigned            mac_idx, mac_errors = 0;

    {
        unsigned z;
        n_irq_devs = 0;
        for (z = 0; z < NIRQDEV; z++) {
            irq_devs[z].dev   = 0;
            irq_devs[z].fired = 0;
        }
    }

    if (mac_dma_word_per_beat(sizeof(mac_token_t)) == 0) {
        mac_in_words_adj  = mac_len * mac_vec;
        mac_out_words_adj = mac_vec;
    }
    else {
        mac_in_words_adj  = round_up(mac_len * mac_vec, mac_dma_word_per_beat(sizeof(mac_token_t)));
        mac_out_words_adj = round_up(mac_vec, mac_dma_word_per_beat(sizeof(mac_token_t)));
    }
    mac_in_len     = mac_in_words_adj * mac_n;
    mac_out_len    = mac_out_words_adj * mac_n;
    mac_in_size    = mac_in_len * sizeof(mac_token_t);
    mac_out_size   = mac_out_len * sizeof(mac_token_t);
    mac_out_offset = mac_in_len;
    mac_mem_size   = (mac_out_offset * sizeof(mac_token_t)) + mac_out_size;

    printf("Scanning device tree...\n");

    vecadd_ndev = probe(&vecadd_espdevs, VENDOR_SLD, VECADD_SLD_ID, VECADD_DEV_NAME);
    if (vecadd_ndev == 0) {
        printf("vecadd_rtl not found\n");
        return 1;
    }
    vecadd_dev = &vecadd_espdevs[0];

    if (ioread32(vecadd_dev, PT_NCHUNK_MAX_REG) == 0 ||
        ioread32(vecadd_dev, PT_NCHUNK_MAX_REG) < NCHUNK(vecadd_mem_size)) {
        printf("vecadd_rtl: scatter-gather DMA unavailable or too small. Abort.\n");
        return 1;
    }

    vecadd_mem    = aligned_malloc(vecadd_mem_size);
    vecadd_ptable = aligned_malloc(NCHUNK(vecadd_mem_size) * sizeof(unsigned *));
    for (i = 0; i < NCHUNK(vecadd_mem_size); i++)
        vecadd_ptable[i] = (unsigned *)&vecadd_mem[i * (CHUNK_SIZE / sizeof(vecadd_token_t))];
    vecadd_init_buf(vecadd_mem, VECADD_N);

    mac_ndev = probe(&mac_espdevs, VENDOR_SLD, MAC_SLD_ID, MAC_DEV_NAME);
    if (mac_ndev == 0) {
        printf("mac_sysc_catapult not found\n");
        return 1;
    }
    mac_dev = &mac_espdevs[0];

    if (ioread32(mac_dev, PT_NCHUNK_MAX_REG) == 0 ||
        ioread32(mac_dev, PT_NCHUNK_MAX_REG) < NCHUNK(mac_mem_size)) {
        printf("mac_sysc_catapult: scatter-gather DMA unavailable or too small. Abort.\n");
        return 1;
    }

    mac_gold   = aligned_malloc(mac_out_size);
    mac_mem    = aligned_malloc(mac_mem_size);
    mac_ptable = aligned_malloc(NCHUNK(mac_mem_size) * sizeof(unsigned *));
    for (i = 0; i < NCHUNK(mac_mem_size); i++)
        mac_ptable[i] = (unsigned *)&mac_mem[i * (CHUNK_SIZE / sizeof(mac_token_t))];
    mac_init_buf(mac_mem, mac_gold);

    /* Configure both accelerators' registers first. */
    iowrite32(vecadd_dev, COHERENCE_REG, coherence);
    iowrite32(vecadd_dev, PT_ADDRESS_REG, (unsigned long)vecadd_ptable);
    iowrite32(vecadd_dev, PT_NCHUNK_REG, NCHUNK(vecadd_mem_size));
    iowrite32(vecadd_dev, PT_SHIFT_REG, CHUNK_SHIFT);
    iowrite32(vecadd_dev, SRC_OFFSET_REG, 0x0);
    iowrite32(vecadd_dev, DST_OFFSET_REG, 0x0);
    iowrite32(vecadd_dev, VECADD_VECTOR_SIZE_REG, VECADD_N);
    iowrite32(vecadd_dev, VECADD_CHUNK_SIZE_REG, VECADD_CHUNK);
    esp_flush(coherence);

    iowrite32(mac_dev, COHERENCE_REG, coherence);
    iowrite32(mac_dev, PT_ADDRESS_REG, (unsigned long)mac_ptable);
    iowrite32(mac_dev, PT_NCHUNK_REG, NCHUNK(mac_mem_size));
    iowrite32(mac_dev, PT_SHIFT_REG, CHUNK_SHIFT);
    iowrite32(mac_dev, SRC_OFFSET_REG, 0x0);
    iowrite32(mac_dev, DST_OFFSET_REG, 0x0);
    iowrite32(mac_dev, MAC_MAC_N_REG, mac_n);
    iowrite32(mac_dev, MAC_MAC_VEC_REG, mac_vec);
    iowrite32(mac_dev, MAC_MAC_LEN_REG, mac_len);
    esp_flush(coherence);

    /* Register both with the PLIC, then enable interrupts once, before
     * either accelerator is started, so a completion that arrives right
     * away can never be missed on either device. */
    vecadd_idx = irq_register(vecadd_dev);
    mac_idx    = irq_register(mac_dev);
    set_csr(mie, MIP_MEIP);
    set_csr(mstatus, MSTATUS_MIE);

    /* Start both back to back. */
    printf("Starting vecadd_rtl mac_sysc_catapult...\n");
    iowrite32(vecadd_dev, CMD_REG, CMD_MASK_START);
    iowrite32(mac_dev, CMD_REG, CMD_MASK_START);

    /* Validate whichever accelerator's interrupt fires first, then go back
     * to waiting for the other, rather than waiting for both to finish
     * before validating either. */
    {
        unsigned vec_done = 0, mac_done = 0;

        while (!vec_done || !mac_done) {
            if (!vec_done && irq_devs[vecadd_idx].fired) {
                vecadd_errors = vecadd_validate_buf(vecadd_mem, VECADD_N);
                printf("  vecadd_rtl         ... %s\n", vecadd_errors ? "FAIL" : "PASS");
                overall_errors += vecadd_errors;
                vec_done = 1;
                continue;
            }
            if (!mac_done && irq_devs[mac_idx].fired) {
                mac_errors = mac_validate_buf(&mac_mem[mac_out_offset], mac_gold);
                printf("  mac_sysc_catapult  ... %s\n", mac_errors ? "FAIL" : "PASS");
                overall_errors += mac_errors;
                mac_done = 1;
                continue;
            }
            asm volatile("wfi");
        }
    }

    aligned_free(vecadd_ptable);
    aligned_free(vecadd_mem);
    aligned_free(mac_ptable);
    aligned_free(mac_mem);
    aligned_free(mac_gold);

    printf("========================================\n");
    if (!overall_errors)
        printf(" multiapp_interrupt: PASS\n");
    else
        printf(" multiapp_interrupt: FAIL\n");
    printf("========================================\n");

    return 0;
}
