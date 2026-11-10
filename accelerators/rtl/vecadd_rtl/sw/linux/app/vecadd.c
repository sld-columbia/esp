// Copyright (c) 2011-2025 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include "libesp.h"
#include "cfg.h"

#define POISON 0xDEADBEEF

static unsigned size;

/* Deterministic inputs, recomputed at validation time rather than read back
 * from memory, so that an accelerator which corrupts its own inputs cannot
 * corrupt the golden values too. Matches the baremetal test. */
static token_t gen_a(unsigned i) { return (token_t)(i * 3 + 1); }

static token_t gen_b(unsigned i) { return (token_t)(0x1000 - (int)i * 7); }

/* User-defined code */
static unsigned validate_buffer(token_t *mem)
{
    unsigned i;
    unsigned errors    = 0;
    unsigned corrupted = 0;

    for (i = 0; i < vector_size; i++) {
        token_t gold = gen_a(i) + gen_b(i);

        if (mem[2 * vector_size + i] != gold) errors++;
    }

    /* The accelerator must only ever write the C region. */
    for (i = 0; i < vector_size; i++)
        if (mem[i] != gen_a(i) || mem[vector_size + i] != gen_b(i)) corrupted++;

    if (corrupted) {
        printf("    %u input elements were overwritten\n", corrupted);
        errors += corrupted;
    }

    return errors;
}

/* User-defined code */
static void init_buffer(token_t *mem)
{
    unsigned i;

    for (i = 0; i < vector_size; i++) {
        mem[i]                   = gen_a(i);
        mem[vector_size + i]     = gen_b(i);
        mem[2 * vector_size + i] = (token_t)POISON;
    }
}

/* User-defined code */
static void init_parameters()
{
    size = 3 * vector_size * sizeof(token_t);
}

int main(int argc, char **argv)
{
    unsigned errors;

    token_t *buf;

    init_parameters();

    buf               = (token_t *)esp_alloc(size);
    cfg_000[0].hw_buf = buf;

    init_buffer(buf);

    printf("\n====== %s ======\n\n", cfg_000[0].devname);
    /* <<--print-params-->> */
    printf("  .vector_size = %d\n", vector_size);
    printf("  .chunk_size = %d\n", chunk_size);
    printf("\n  ** START **\n");

    esp_run(cfg_000, NACC);

    printf("\n  ** DONE **\n");

    errors = validate_buffer(buf);

    esp_free(buf);

    if (!errors) printf("+ Test PASSED\n");
    else
        printf("+ Test FAILED (%u errors)\n", errors);

    printf("\n====== %s ======\n\n", cfg_000[0].devname);

    return errors;
}
