/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#include <stdlib.h>

#include <fixed_point.h>
#include <math.h>

#include <esp_accelerator.h>
#include <esp_probe.h>

typedef uint32_t token_t;

static unsigned DMA_WORD_PER_BEAT(unsigned _st)
{
    return (sizeof(void *) / _st);
}


#define SLD_SHA1_CXX 0x054
#define DEV_NAME "sld,sha1_cxx_catapult"

/* <<--params-->> */
//const int32_t in_bytes = 0;

static unsigned in_words;
static unsigned out_words;
static unsigned in_size;
static unsigned out_size;
static unsigned mem_size;

const unsigned sha1_in_size = 1600;
const unsigned sha1_out_size = 5;

/* Size of the contiguous chunks for scatter/gather */
#define CHUNK_SHIFT 20
#define CHUNK_SIZE BIT(CHUNK_SHIFT)
#define NCHUNK(_sz) ((_sz % CHUNK_SIZE == 0) ?        \
        (_sz / CHUNK_SIZE) :        \
        (_sz / CHUNK_SIZE) + 1)

         /* User defined registers */
         /* <<--regs-->> */
#define SHA1_CXX_IN_BYTES_REG 0x40

static unsigned raw_in_bytes[10] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
static unsigned raw_words[10] = {0, 1, 1, 1, 1, 2, 2, 2, 2, 3};


static unsigned raw_inputs[10][1600] = {
    {0x00000000},
    {0x36000000},
    {0x195a0000},
    {0xdf4bd200},
    {0x549e959e},
    {0xf7fb1be2, 0x05000000},
    {0xc0e5abea, 0xea630000},
    {0x63bfc1ed, 0x7f78ab00},
    {0x7e3d7b3e, 0xada98866},
    {0x9e61e55d, 0x9ed37b1c, 0x20000000}};

static unsigned raw_outputs[10][5] = {
    {0xda39a3ee, 0x5e6b4b0d, 0x3255bfef, 0x95601890, 0xafd80709},
    {0xc1dfd96e, 0xea8cc2b6, 0x2785275b, 0xca38ac26, 0x1256e278},
    {0x0a1c2d55, 0x5bbe431a, 0xd6288af5, 0xa54f93e0, 0x449c9232},
    {0xbf36ed5d, 0x74727dfd, 0x5d7854ec, 0x6b1d4946, 0x8d8ee8aa},
    {0xb78bae6d, 0x14338ffc, 0xcfd5d5b5, 0x674a275f, 0x6ef9c717},
    {0x60b7d5bb, 0x560a1acf, 0x6fa45721, 0xbd0abb41, 0x9a841a89},
    {0xa6d33845, 0x9780c083, 0x63090fd8, 0xfc7d28dc, 0x80e8e01f},
    {0x860328d8, 0x0509500c, 0x1783169e, 0xbf0ba0c4, 0xb94da5e5},
    {0x24a2c34b, 0x97630527, 0x7ce58c2f, 0x42d50920, 0x31572520},
    {0x411ccee1, 0xf6e3677d, 0xf1269841, 0x1eb09d3f, 0xf580af97}};

static int validate_buf(token_t *out, token_t *gold)
{
    int j;
    unsigned errors = 0;

    printf("  gold output data @%p\n", gold);
    printf("       output data @%p\n", out);

    for (j = 0; j < sha1_out_size; j++)
    {
        token_t gold_data = gold[j];
        token_t out_data = out[j];

        if (out_data != gold_data)
        {
            errors++;
        }
        //printf("[%u][%u] %d (%d)\n", i, j, (int)out_data, (int)gold_data);
    }

    printf("  total errors %u\n", errors);

    return errors;
}

static void init_buf (unsigned t, token_t *inputs, token_t * gold_outputs)
{
    int j;

    printf("  input data @%p\n", inputs);

    printf("  in_bytes %u\n", t);
    printf("  raw_words %u\n", raw_words[t]);

    for (j = 0; j < raw_words[t]; j++)
    {
        inputs[j] = raw_inputs[t][j];
        printf("  raw_inputs[%u][%u] %x\n", t, j, raw_inputs[t][j]);
    }

    printf("  gold output data @%p\n", gold_outputs);

    for (j = 0; j < sha1_out_size; j++) {
        gold_outputs[j] = raw_outputs[t][j];
        printf("  raw_outputs[%u][%u] %x\n", t, j, raw_outputs[t][j]);
    }
}


int main(int argc, char * argv[])
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

    in_words = 64; //sha1_in_size;
    out_words = 16; //sha1_out_size;

    in_size = in_words * sizeof(token_t);
    out_size = out_words * sizeof(token_t);
    mem_size = in_size + out_size;

    // Search for the device
    printf("Scanning device tree... \n");

    ndev = probe(&espdevs, VENDOR_SLD, SLD_SHA1_CXX, DEV_NAME);

    printf("Found %d devices: %s\n", ndev, DEV_NAME);

    if (ndev == 0) {
        printf("sha1_cxx not found\n");
        return 0;
    }

    // Allocate memory
    gold = aligned_malloc(out_size);
    mem = aligned_malloc(mem_size);
    printf("  memory buffer base-address = %p\n", mem);
    printf("  memory buffer size = %p\n", mem_size);
    printf("  golden buffer base-address = %p\n", gold);
    printf("  golden buffer size = %p\n", out_size);

    // Alocate and populate page table
    ptable = aligned_malloc(NCHUNK(mem_size) * sizeof(unsigned *));
    for (i = 0; i < NCHUNK(mem_size); i++)
        ptable[i] = (unsigned *) &mem[i * (CHUNK_SIZE / sizeof(token_t))];
    printf("  ptable = %p\n", ptable);
    printf("  nchunk = %lu\n", NCHUNK(mem_size));

    printf("  Generate input...\n");

    for (unsigned t = 4; t < 5; t++) {
        int32_t in_bytes = t;

        init_buf(t, mem, gold);

        printf("  ... input ready!\n");

        // Pass common configuration parameters
        for (n = 0; n < ndev; n++) {

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

            // Pass common configuration parameters
            iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
            iowrite32(dev, COHERENCE_REG, ACC_COH_NONE);
            iowrite32(dev, PT_ADDRESS_REG, (unsigned long) ptable);
            iowrite32(dev, PT_NCHUNK_REG, NCHUNK(mem_size));
            iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);

            // Use the following if input and output data are not allocated at the default offsets
            //iowrite32(dev, SRC_OFFSET_REG, 0x0);
            //iowrite32(dev, DST_OFFSET_REG, 0x0);

            // Pass accelerator-specific configuration parameters
            /* <<--regs-config-->> */
            iowrite32(dev, SHA1_CXX_IN_BYTES_REG, in_bytes);

            // Flush (customize coherence model here)
            esp_flush(ACC_COH_NONE);

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
            errors = validate_buf(mem + in_size, gold);
            if (errors)
                printf("  ... FAIL\n");
            else
                printf("  ... PASS\n");

            aligned_free(ptable);
            aligned_free(mem);
            aligned_free(gold);
        }
    }

    printf("DONE\n");

    return 0;
}
