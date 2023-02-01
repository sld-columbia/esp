// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef __riscv
#include <stdio.h>
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>
#include <math.h>
#include <fixed_point.h>

#define fx2float fixed32_to_float
#define float2fx float_to_fixed32
#define FX_IL 12

typedef int32_t token_t;

static unsigned DMA_WORD_PER_BEAT(unsigned _st)
{
        return (sizeof(void *) / _st);
}

#define SLD_CHOLESKY 0x062
#define DEV_NAME "sld,cholesky_stratus"

/* <<--params-->> */
const int32_t rows = 16;

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
#define CHUNK_SIZE BIT(CHUNK_SHIFT)
#define NCHUNK(_sz) ((_sz % CHUNK_SIZE == 0) ?		\
			(_sz / CHUNK_SIZE) :		\
			(_sz / CHUNK_SIZE) + 1)

/* User defined registers */
/* <<--regs-->> */
#define CHOLESKY_ROWS_REG 0x40

static int validate_buf(token_t *out, token_t *gold)
{
        int i;
        int j;
        unsigned errors = 0;
        const float ERR_TH = 0.2f;
        float out_fl, gold_fl;
        for (i = 0; i < 1; i++) {
            for (j = 0; j < rows * rows; j++) {
                out_fl = fx2float(out[j], FX_IL);
                gold_fl = fx2float(gold[j], FX_IL);
                if ((fabs(gold[j] - out[j]) / fabs(gold[j])) > ERR_TH) {
                    printf("ERR: GOLD = %f   and  OUT = %f and Element = %d\n", gold_fl, out_fl, j);
                    errors++; }
            }
        }

        return errors;
}

int main(int argc, char * argv[])
{
	int i;
	int n;
	int ndev;
	struct esp_device *espdevs;
	struct esp_device *dev;
	unsigned done;
    int coherence;
	unsigned **ptable;
	token_t *buf;
	token_t *gold;
	unsigned errors = 0;

	if (DMA_WORD_PER_BEAT(sizeof(token_t)) == 0) {
		in_words_adj = rows * rows;
		out_words_adj = rows * rows;
	} else {
		in_words_adj = round_up(rows * rows, DMA_WORD_PER_BEAT(sizeof(token_t)));
		out_words_adj = round_up(rows * rows, DMA_WORD_PER_BEAT(sizeof(token_t)));
	}
	in_len = in_words_adj * (1);
	out_len = out_words_adj * (1);
	in_size = in_len * sizeof(token_t);
	out_size = out_len * sizeof(token_t);
	out_offset  = in_len;
	mem_size = (out_offset * sizeof(token_t)) + out_size;


	// Search for the device
	printf("Scanning device tree... \n");

	ndev = probe(&espdevs, VENDOR_SLD, SLD_CHOLESKY, DEV_NAME);
	if (ndev == 0) {
		printf("cholesky not found\n");
		return 0;
	}

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

		// Allocate memory
		gold = aligned_malloc(out_size);
		buf = aligned_malloc(mem_size);
		printf("  memory buffer base-address = %p\n", buf);
		// Alocate and populate page table
		ptable = aligned_malloc(NCHUNK(mem_size) * sizeof(unsigned *));
		for (i = 0; i < NCHUNK(mem_size); i++)
			ptable[i] = (unsigned *) &buf[i * (CHUNK_SIZE / sizeof(token_t))];

        printf("  ptable = %p\n", ptable);
		printf("  nchunk = %lu\n", NCHUNK(mem_size));

        for (coherence = ACC_COH_NONE; coherence <= ACC_COH_FULL; coherence++) {
            printf("  Generate input...\n");

            //data generated in hw/datagen/
            #include "data.h"

            // Pass common configuration parameters
            iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
            iowrite32(dev, COHERENCE_REG, coherence);

#ifndef __sparc
            iowrite32(dev, PT_ADDRESS_REG, (unsigned long long) ptable);
#else
            iowrite32(dev, PT_ADDRESS_REG, (unsigned) ptable);
#endif
            iowrite32(dev, PT_NCHUNK_REG, NCHUNK(mem_size));
            iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);

            // Use the following if input and output data are not allocated at the default offsets
            iowrite32(dev, SRC_OFFSET_REG, 0x0);
            iowrite32(dev, DST_OFFSET_REG, 0x0);

            // Pass accelerator-specific configuration parameters
            /* <<--regs-config-->> */
            iowrite32(dev, CHOLESKY_ROWS_REG, rows);

            // Flush (customize coherence model here)
            printf("coh: %d\n", coherence);
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
            errors = validate_buf(&buf[out_offset], gold);
            if (errors){
                printf("  ... FAIL\n");
                printf(" ERRORS = %d \n",errors);}
            else
                printf("  ... PASS\n");
        }
		aligned_free(ptable);
		aligned_free(buf);
		aligned_free(gold);
	}

	return 0;
}
