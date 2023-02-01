/* Copyright (c) 2011-2023 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>
#include <fixed_point.h>

#include "../../common/utils.h"

//typedef int32_t token_t; defined in utils.h file5

static unsigned DMA_WORD_PER_BEAT(unsigned _st)
{
  return (sizeof(void *) / _st);
}


#define fx2float fixed32_to_float
#define float2fx float_to_fixed32
#define FX_IL 12


#define SLD_MRIQ 0x079
#define DEV_NAME "sld,mriq_stratus"

/* <<--params-->> */

const int32_t num_batch_k = 1;
const int32_t batch_size_k = 16;
const int32_t num_batch_x = 1;
const int32_t batch_size_x = 4;

static unsigned in_words_adj;
static unsigned out_words_adj;
static unsigned in_size;
static unsigned out_size;
static unsigned in_len;
static unsigned out_len;
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

#define MRIQ_NUM_BATCH_K_REG 0x4c
#define MRIQ_BATCH_SIZE_K_REG 0x48
#define MRIQ_NUM_BATCH_X_REG 0x44
#define MRIQ_BATCH_SIZE_X_REG 0x40


static int validate_buf(token_t *out, float *gold)
{
    float *out_fp;
    int ret;
    out_fp = aligned_malloc(out_len * sizeof(float));

    for (int i = 0; i < out_len; i++) {
      out_fp[i] = fx2float(out[i], FX_IL);
    }

    ret = validate_buffer(out_fp, gold, out_len);

    aligned_free(out_fp);
    return ret;
}



static void init_buf (token_t *in, float * gold)
{
#include "../../hw/data/test_32_x4_k16_bm.h"
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
	float *gold;
	unsigned errors = 0;
	unsigned coherence;

	// init corresponding parameters
	init_parameters(batch_size_x, num_batch_x, 
			batch_size_k, num_batch_k,
			&in_words_adj, &out_words_adj,
			&in_len, &out_len,
			&in_size, &out_size,
			&out_offset,
			&mem_size,
			DMA_WORD_PER_BEAT(sizeof(token_t)));


	// Search for the device
	printf("Scanning device tree... \n");

	ndev = probe(&espdevs, VENDOR_SLD, SLD_MRIQ, DEV_NAME);
	if (ndev == 0) {
		printf("mriq not found\n");
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
		gold = aligned_malloc(out_len * sizeof(float));

		mem = aligned_malloc(mem_size);

		printf("  memory buffer base-address = %p\n", mem);

		// Alocate and populate page table
		ptable = aligned_malloc(NCHUNK(mem_size) * sizeof(unsigned *));
		for (i = 0; i < NCHUNK(mem_size); i++)
			ptable[i] = (unsigned *) &mem[i * (CHUNK_SIZE / sizeof(token_t))];

		printf("  ptable = %p\n", ptable);
		printf("  nchunk = %lu\n", NCHUNK(mem_size));

#ifndef __riscv // for leon3, skip ACC_COH_FULL
		for (coherence = ACC_COH_NONE; coherence < ACC_COH_FULL; coherence++) {
#else
		{
			/* TODO: Restore full test once ESP caches are integrated */
			coherence = ACC_COH_NONE;
#endif
			printf("  --------------------\n");
			printf("  Generate input...\n");

			init_buf(mem, gold);

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

		iowrite32(dev, MRIQ_NUM_BATCH_K_REG, num_batch_k);
		iowrite32(dev, MRIQ_BATCH_SIZE_K_REG, batch_size_k);
		iowrite32(dev, MRIQ_NUM_BATCH_X_REG, num_batch_x);
		iowrite32(dev, MRIQ_BATCH_SIZE_X_REG, batch_size_x);

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

			if (errors)
				printf("  ... FAIL\n");
			else
				printf("  ... PASS\n");
		}
		aligned_free(ptable);
		aligned_free(mem);
		aligned_free(gold);
	}

	return 0;
}
