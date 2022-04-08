/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>
#include <fixed_point.h>

#include "nvdla_minimal.h"

typedef unsigned long long int token_t;
typedef unsigned long long int native_t;

static unsigned DMA_WORD_PER_BEAT(unsigned _st)
{
    return (sizeof(void *) / _st);
}

#define MAX_PRINTED_ERRORS 10


#define NV_NVDLA  0x100
#define DEV_NAME "nvidia,nv_small"

static unsigned i_base;
static unsigned w_base;
static unsigned b_base;
static unsigned o_base;
static unsigned mem_size;
static unsigned out_len;
static unsigned out_size;
static unsigned out_offset;

static int validate_buf(token_t *out, native_t *gold)
{
    int j;
    native_t val;
    unsigned errors = 0;

    for (j = 0; j < out_len; j++) {
	val = out[j];

	if (gold[j] != val) {
	    errors++;
	    if (errors <= MAX_PRINTED_ERRORS) {
		printf("%d : %llu : %llu\n", j, val, gold[j]);
	    }
	}
    }

    return errors;
}

static void init_buf (token_t *in, native_t * gold)
{
#include "input.h"
#include "gold.h"
}

int main(int argc, char * argv[])
{
    int i;
    int n;
    int ndev;
    struct esp_device *espdevs;
    struct esp_device dev, coh_dev, plic_dev;
    unsigned done;
    token_t *mem;
    native_t *gold;
    unsigned errors = 0;
    unsigned coherence;
    unsigned error_id;
    unsigned read_val;
	long time0, time1, time2, time3;

    i_base = 0x200;
    w_base  = 0x000;
    b_base  = 0x280;
    o_base  = 0x400;
    mem_size = 0x500;

    out_len = 12;
    out_size = 12 * sizeof(native_t);
    out_offset = o_base / sizeof(native_t);

    dev.addr = ACC_ADDR;

    // Allocation of the accelerator data array (mem) and of the expected output array (gold)
    mem = aligned_malloc(mem_size);
    gold = aligned_malloc(out_size);
    printf("  memory buffer base-address = %p\n", mem);

    init_buf(mem, gold);

    // Flush (customize coherence model here)
    coherence = ACC_COH_RECALL;
    coh_dev.addr = CSR_TILE_ADDR;
    iowrite32(&coh_dev, CSR_REG_OFFSET*4, coherence);
//    if (coherence != ACC_COH_RECALL)
//	esp_flush(coherence, 1);

    // Write the accelerator configuration registers


    //read_val = ioread32(dev, 28676);
    //if (read_val != 1 && read_val != 65536)
    //    printf("error %u\n", error_id);
    //error_id++;


for (int i = 0; i < 3; i++) {

        error_id = 0;

        //read_val = ioread32(dev, 28676);
        //if (read_val != 1 && read_val != 65536)
        //    printf("error %u\n", error_id);
        //error_id++;

        printf("  start NVDLA\n");
        time0=get_counter();
        setup_nvdla(mem, i_base, o_base, b_base, w_base);
        time1=get_counter();
        plic_dev.addr = PLIC_ADDR;
        while(ioread32(&plic_dev, PLIC_IP_OFFSET) != 0x40);
        time2 = get_counter();

        printf("Time load: %llu\n", time1 - time0);
        printf("Time run: %llu\n", time2 - time1);

        read_val = ioread32(&dev, 4100);
        if (read_val != 0)
        printf("error %u\n", error_id);
        error_id++;

        read_val = ioread32(&dev, 4108);
        if (read_val != 1376257  && read_val != 2752514)
        printf("error %u\n", error_id);
        error_id++;
        *((unsigned int*) (NVDLA_BASE_ADDR + 4108)) = read_val;

        read_val = ioread32(&dev, 4100);
        if (read_val != 0)
        printf("error %u\n", error_id);
        error_id++;

        read_val = ioread32(&dev, 4108);
        if (read_val != 0)
        printf("error %u\n", error_id);
        error_id++;

        iowrite32(&plic_dev, PLIC_INTACK_OFFSET, NVDLA_IRQ + 1);
        iowrite32(&plic_dev, 0x2000, 0x40);
        iowrite32(&plic_dev, 0x18, 0x2);
        ioread32(&plic_dev, PLIC_INTACK_OFFSET);

        /* Validation */
        errors = validate_buf(&mem[out_offset], gold);

        if (errors)
        printf("  ... FAIL\n");
        else
        printf("  ... PASS\n");
        for (int j = 0; j < out_len; j++)
            mem[out_offset+j] = 0;
    }

    aligned_free(mem);
    aligned_free(gold);

    return 0;
}
