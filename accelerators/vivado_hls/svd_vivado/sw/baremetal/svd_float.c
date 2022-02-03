/* Copyright (c) 2011-2019 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

/* This version of the svd accelerator is for if it was implemented with float datatype. The defulat svd accelerator works with fixed point datatype */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>

#include "input.h"

typedef float token_t;


static unsigned DMA_WORD_PER_BEAT(unsigned _st)
{
        return (sizeof(void *) / _st);
}


#define SLD_SVD 0x222
#define DEV_NAME "sld,svd_vivado"

/* <<--params-->> */
const int32_t p2p_out = 0;
const int32_t p2p_in = 0;
const int32_t p2p_iter = 1;
const int32_t load_state = 0;
const int32_t q = 177;
const int32_t p = 229;
const int32_t m = 3;

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
#define SVD_LOAD_STATE_REG 0x58
#define SVD_P2P_ITER_REG 0x54
#define SVD_P2P_IN_REG 0x50
#define SVD_P2P_OUT_REG 0x4C
#define SVD_Q_REG 0x48
#define SVD_P_REG 0x44
#define SVD_M_REG 0x40


static int validate_buf(token_t *out, token_t *gold)
{
	int i;
	int j;
	float MAE, MAE_sum, num;
	unsigned errors = 0;
	MAE_sum = 0;

	for (i = 0; i < 1; i++)
		for (j = 0; j < m*m+m*p; j++)
		{

			MAE = (out[i * out_words_adj + j] - gold[i * out_words_adj + j])
				/ gold[i * out_words_adj + j];

			/* uint32_t* tmp1 = (uint32_t*) &gold[i * out_words_adj + j]; */
			/* print_uart("gold = ");print_uart_int(*tmp1);print_uart(" "); */
			/* uint32_t* tmp2 = (uint32_t*) &out[i * out_words_adj + j]; */
			/* print_uart("out = ");print_uart_int(*tmp2);print_uart("\n"); */

			MAE_sum += MAE*MAE;

			if (MAE > 0.15 || MAE < -0.15)
			{
				errors++;
			}

		}

	num = m*m+p*m;
	if (MAE_sum / num > 0.01)
		errors++;

	printf("Sum of errors is %d \n", errors);

	return errors;
}


static void init_buf (token_t *in, token_t * gold)
{
	int i;
	int j;
	int k, x, y, t;

	printf("initialize buffer \n");

	for (i = 0; i < 1; i++)
	{
		for(j = 0; j < p*q; j++) //Q
		{
			//print_uart("saving Q[");print_uart_int(j);print_uart("]\n");
			in[i * in_words_adj + j] = (token_t) 1/(p * q);
		}

		printf("  Generated Q \n");

		for(x = 0; x < m*p; x++) //X
			in[i * in_words_adj + j + x] = inputX[x];

		printf("  Generated X \n");

		for(y = 0; y < m*q; y++) //Y
			in[i * in_words_adj + j + x + y] = inputY[y];

		printf("  Generated Y \n");

		for(t = 0; t < m*m; t++) //T
			in[i * in_words_adj + j + x + y + t] = inputT[t];

		printf("  Generated T \n");

		in[i * in_words_adj + j + x + y + t] = inputP;

		printf("  Generated P \n");

	}

	printf("  Generated all inputs \n");

	for(k = 0; k < m; k++)
		for(j = 0; j < p; j++)
			gold_out_sink[k][j] = 0.0;

	for(k = 0; k < m; k++)
		for(i = 0; i < p; i++)
			for(j = 0; j < m; j++)
				gold_out_sink[k][i] += inputX[i * m + j] * gold_out[k * m + j];

	printf("  Generated golden output for sinkhorn \n");

	for (i = 0; i < 1; i++)
	{
		for(j = 0; j < m*m; j++)
			gold[i * out_words_adj + j] = gold_out[j];

		for(k = 0; k < m*p; k++)
			gold[i * out_words_adj + j + k] = gold_out_sink[k / p][k % p];
	}

	printf("  Generated output \n");
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
		in_words_adj = p*q+m*p+m*q+m*m+1;
		out_words_adj = m*m+m*p;
	} else {
		in_words_adj = round_up(p*q+m*p+m*q+m*m+1, DMA_WORD_PER_BEAT(sizeof(token_t)));
		out_words_adj = round_up(m*m+m*p, DMA_WORD_PER_BEAT(sizeof(token_t)));
	}
	in_len = in_words_adj * (1);
	out_len = out_words_adj * (1);
	in_size = in_len * sizeof(token_t);
	out_size = out_len * sizeof(token_t);
	out_offset  = in_len;
	mem_size = (out_offset * sizeof(token_t)) + out_size;


	// Search for the device
	printf("Scanning device tree... \n");

	ndev = probe(&espdevs, VENDOR_SLD, SLD_SVD, DEV_NAME);
	if (ndev == 0) {
		printf("svd not found\n");
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
                for (coherence = ACC_COH_NONE; coherence <= ACC_COH_FULL; coherence++) {
#else
		{
			/* TODO: Restore full test once ESP caches are integrated */
			coherence = ACC_COH_NONE;
#endif

			printf("  Generate input...\n");

			init_buf(mem, gold);

			// Pass common configuration parameters

			iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
			iowrite32(dev, COHERENCE_REG, ACC_COH_NONE);

			iowrite32(dev, PT_ADDRESS_REG, (unsigned long) ptable);
			iowrite32(dev, PT_NCHUNK_REG, NCHUNK(mem_size));
			iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);

			// Use the following if input and output data are not allocated at the default offsets
			iowrite32(dev, SRC_OFFSET_REG, 0x0);
			iowrite32(dev, DST_OFFSET_REG, 0x0);

			// Pass accelerator-specific configuration parameters
			/* <<--regs-config-->> */
			iowrite32(dev, SVD_P2P_OUT_REG, p2p_out);
			iowrite32(dev, SVD_P2P_IN_REG, p2p_in);
			iowrite32(dev, SVD_P2P_ITER_REG, p2p_iter);
			iowrite32(dev, SVD_LOAD_STATE_REG, load_state);
			iowrite32(dev, SVD_Q_REG, q);
			iowrite32(dev, SVD_P_REG, p);
			iowrite32(dev, SVD_M_REG, m);

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
