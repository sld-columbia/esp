/* Copyright (c) 2011-2024 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>
#include <fixed_point.h>

typedef int32_t token_t;

static unsigned DMA_WORD_PER_BEAT(unsigned _st)
{
        return (sizeof(void *) / _st);
}


#define SLD_LEAKYRELU 0x777
#define DEV_NAME "sld,mac_sysc_catapult"

/* <<--params-->> */
const int32_t mac_n = 1;
const int32_t mac_vec = 8;
const int32_t mac_len = 16;

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
#define LEAKY_ADDRO_REG 0x50
#define LEAKY_ADDRB_REG 0x4c
#define LEAKY_ADDRA_REG 0x48
#define LEAKY_ROW_REG 0x44
#define LEAKY_BATCH_REG 0x40

static int validate_buffer(token_t *out, token_t *gold)
{
	int i;
	int j;
	unsigned errors = 0;

	for (i=0; i<batch; i++){
		for (j=0; j<row; j++){
			for (k=0; k<vec_len; k++){
				if (gold[(row*vec_len)*i + vec_len*j + k] != out[(row*vec_len)*i + vec_len*j + k])
				errors++;
			}
		}
	}
	return errors;
}

static void init_buffer(token_t *in token_t * gold)
{

	int i;
	int j;
	int k;
	for (i=0; i<batch; i++){
		for (j=0; j<row; j++){
			for (k=0; k<vec_len; k++){
				float data = ((i * 8 + j - k) % 32) + 0.25;
				token_t data_fxd = float_to_fixed32(data, 16);
				in[(row*vec_len)*i + vec_len*j + k] = data_fxd;
			}
		}
	}
	for (i=0; i<batch; i++){
		for (j=0; j<row; j++){
			for (k=0; k<vec_len; k++){
				float data = ((i * 8 + j + k) % 32) + 0.15;
				token_t data_fxd = float_to_fixed32(data, 16);
				in[in_a_len + (row*vec_len)*i + vec_len*j + k] = data_fxd;
			}
		}
	}

	float out_gold;
	for (i=0; i<batch; i++){
		for (j=0; j<row; j++){
			for (k=0; k<vec_len; k++){
				float data_a = fixed32_to_float(in[(row*vec_len)*i + vec_len*j + k], 16);
				float data_b = fixed32_to_float(in[in_a_len + (row*vec_len)*i + vec_len*j + k], 16);
				
				out_gold = data1*data2;

				if (out_gold < 0){
					out_gold *= 0.5;
				}
				gold[(row*vec_len)*i + vec_len*j + k]= float_to_fixed32(out_gold, 16);
			}
		}
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
	unsigned coherence;

	if (DMA_WORD_PER_BEAT(sizeof(token_t)) == 0) {
		in_a_len        = batch*(row*VEC_LEN);
		in_b_len        = batch*(row*VEC_LEN);
		out_len         = batch*(row*VEC_LEN);
	} else {
		in_a_len        = round_up(batch*(row*VEC_LEN), DMA_WORD_PER_BEAT(sizeof(token_t)));
		in_b_len        = round_up(batch*(row*VEC_LEN), DMA_WORD_PER_BEAT(sizeof(token_t)));
		out_len         = round_up(batch*(row*VEC_LEN), DMA_WORD_PER_BEAT(sizeof(token_t)));
	}

	in_a_size = in_a_len * sizeof(token_t);
	in_b_size = in_b_len * sizeof(token_t);
	out_size = out_len * sizeof(token_t);
	in_a_offset	= 0;
	in_b_offset	= in_a_len;
	out_offset = in_a_len + in_b_len;
	mem_size = (out_offset * sizeof(token_t)) + out_size;


	// Search for the device
	printf("Scanning device tree... \n");

	ndev = probe(&espdevs, VENDOR_SLD, SLD_LEAKYRELU, DEV_NAME);
	if (ndev == 0) {
		printf("device not found\n");
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
		mem = aligned_malloc(mem_size);
		printf("  memory buffer base-address = %p\n", mem);

		// Alocate and populate page table
		ptable = aligned_malloc(NCHUNK(mem_size) * sizeof(unsigned *));
		for (i = 0; i < NCHUNK(mem_size); i++)
			ptable[i] = (unsigned *) &mem[i * (CHUNK_SIZE / sizeof(token_t))];

		printf("  ptable = %p\n", ptable);
		printf("  nchunk = %lu\n", NCHUNK(mem_size));

#ifndef __riscv
		for (coherence = ACC_COH_NONE; coherence <= ACC_COH_RECALL; coherence++) {
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
			iowrite32(dev, LEAKY_BATCH_REG, batch);
			iowrite32(dev, LEAKY_ROW_REG, row);
			iowrite32(dev, LEAKY_ADDRA_REG, addrA);
			iowrite32(dev, LEAKY_ADDRB_REG, addrB);
			iowrite32(dev, LEAKY_ADDRO_REG, addrO);

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
