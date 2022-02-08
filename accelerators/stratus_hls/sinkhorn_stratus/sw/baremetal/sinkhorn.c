/* Copyright (c) 2011-2019 Columbia University, System Level Design Group */
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


#define SLD_SINKHORN 0x144
#define DEV_NAME "sld,sinkhorn_stratus"

/* <<--params-->> */
const int32_t maxiter = 150;
const float gamma_float = 1.6;
const int32_t q_cols = 177;
const int32_t m_rows = 3;
const int32_t p_rows = 229;
const int32_t p2p_in = 0;
const int32_t p2p_out = 0;
const int32_t p2p_iter = 1;
const int32_t store_state = 0;

static unsigned inX_words_adj;
static unsigned inY_words_adj;
static unsigned in_words_adj;
static unsigned out_words_adj;
static unsigned inX_len;
static unsigned inY_len;
static unsigned in_len;
static unsigned out_len;
static unsigned inX_size;
static unsigned inY_size;
static unsigned in_size;
static unsigned out_size;
static unsigned out_offset;
static unsigned mem_size;
static int32_t gamma_fixed;

/* Size of the contiguous chunks for scatter/gather */
#define CHUNK_SHIFT 20
#define CHUNK_SIZE BIT(CHUNK_SHIFT)
#define NCHUNK(_sz) ((_sz % CHUNK_SIZE == 0) ?		\
			(_sz / CHUNK_SIZE) :		\
			(_sz / CHUNK_SIZE) + 1)

/* User defined registers */
/* <<--regs-->> */
#define SINKHORN_STORE_STATE_REG 0x60
#define SINKHORN_P2P_ITER_REG 0x5C
#define SINKHORN_P2P_OUT_REG 0x58
#define SINKHORN_P2P_IN_REG 0x54
#define SINKHORN_MAXITER_REG 0x50
#define SINKHORN_GAMMA_REG 0x4c
#define SINKHORN_Q_COLS_REG 0x44
#define SINKHORN_M_ROWS_REG 0x48
#define SINKHORN_P_ROWS_REG 0x40


static int validate_buf(token_t *out, token_t *gold)
{
	int i;
	int j;
	float sum = 0;
	unsigned errors = 0;

	for (i = 0; i < 1; i++)
	{
		for (j = 0; j < p_rows * q_cols + 1; j++)
		{
			float val = fixed32_to_float(out[i * out_words_adj + j], 11);
			if (j < p_rows * q_cols) // P sum
			{
				//print_uart_int(out[i * out_words_adj + j]);print_uart("\n");
				sum += val;
			}
			else
			{
				float CP_val = fixed32_to_float(gold[i * out_words_adj + j],11);
				if (CP_val != val) // CP_sum
				{
					float CP_error = 100*(CP_val-val)/CP_val;
					printf("CP_sum is: %d\n", out[i * out_words_adj + j]);
					printf("Expected CP_sum is: %d\n", gold[i * out_words_adj + j]);
					if (CP_error > 3 || CP_error < -3)
					{
						printf("CP error is bigger than 3 percent\n");
						errors++;
					}
					else
						printf("CP error is smaller than 3 percent - Passed.\n");
				}
			}
		}

		if (sum != 1.0)
		{
			float P_error = 100*(1.0-sum)/1.0;
			int32_t sum_fixed = float_to_fixed32(sum, 11);
			int32_t sum_expected = float_to_fixed32(1.0, 11);
			printf("P sum is: %d\n", sum_fixed);
			printf("Expected P sum is: %d\n", sum_expected);
			if (P_error > 3)
			{
				printf("P error is bigger than 3 percent");
				errors++;
			}
		}
	}

	return errors;
}


static void init_buf (token_t *in, token_t * gold)
{
#include "input.h"

	int i;
	int j;
	int k;

	printf("Initializing buffer\n");

	//inX_len = round_up(p_rows * m_rows, DMA_WORD_PER_BEAT(sizeof(token_t)));
	//inY_len = round_up(q_cols * m_rows, DMA_WORD_PER_BEAT(sizeof(token_t)));

	for (i = 0; i < 1; i++)
	{
		for (j = 0; j < p_rows * m_rows; j++)
		{
			//print_uart_int(j); print_uart("\n");
			in[i * inX_words_adj + j] = (token_t) float_to_fixed32(inputX[j], 11);
		}

		//j = inX_len;

		printf("Finished loading X\n");

		for (k = 0; k < q_cols * m_rows; k++)
		{
			//print_uart_int(k); print_uart("\n");
			in[i * inY_words_adj + j + k] = float_to_fixed32(inputY[k], 11);
		}

		printf("Finished loading Y\n");
	}

	gold[p_rows * q_cols] = (token_t) float_to_fixed32(0.868033, 11);

	/* for (i = 0; i < 1; i++) */
	/* 	for (j = 0; j < /\*p_rows * q_cols + 1*\/5; j++) */
	/* 	{ */
	/* 		print_uart_int(j); print_uart("\n"); */
	/* 		gold[i * out_words_adj + j] = 0; */
	/* 		if (j == p_rows * q_cols) //CP_sum */
	/* 			gold[i * out_words_adj + j] = (token_t) float_to_fixed32(0.868033, 11); */
	/* 	} */

	printf("Finished initialization\n");
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
		inX_words_adj = p_rows * m_rows;
		inY_words_adj = q_cols * m_rows;
		in_words_adj = inX_words_adj + inY_words_adj;
		out_words_adj = p_rows * q_cols + 1;
	} else {
		inX_words_adj = round_up(p_rows * m_rows, DMA_WORD_PER_BEAT(sizeof(token_t)));
		inY_words_adj = round_up(q_cols * m_rows, DMA_WORD_PER_BEAT(sizeof(token_t)));
		in_words_adj = round_up((p_rows+q_cols) * m_rows, DMA_WORD_PER_BEAT(sizeof(token_t)));
		out_words_adj = round_up(p_rows * q_cols + 1, DMA_WORD_PER_BEAT(sizeof(token_t)));
	}
	inX_len = inX_words_adj * (1);
	inY_len = inY_words_adj * (1);
	in_len = in_words_adj * (1);
	out_len = out_words_adj * (1);
	inX_size = inX_len * sizeof(token_t);
	inY_size = inY_len * sizeof(token_t);
	in_size = in_len * sizeof(token_t);
	out_size = out_len * sizeof(token_t);
	out_offset  = in_len;
	mem_size = (out_offset * sizeof(token_t)) + out_size;

	gamma_fixed = float_to_fixed32(gamma_float, 11);

	// Search for the device
	printf("Scanning device tree... \n");

	ndev = probe(&espdevs, VENDOR_SLD, SLD_SINKHORN, DEV_NAME);
	if (ndev == 0) {
		printf("sinkhorn not found\n");
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
			printf("  --------------------\n");
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
			iowrite32(dev, SINKHORN_MAXITER_REG, maxiter);
			iowrite32(dev, SINKHORN_GAMMA_REG, gamma_fixed);
			iowrite32(dev, SINKHORN_Q_COLS_REG, q_cols);
			iowrite32(dev, SINKHORN_M_ROWS_REG, m_rows);
			iowrite32(dev, SINKHORN_P_ROWS_REG, p_rows);
			iowrite32(dev, SINKHORN_P2P_OUT_REG, p2p_out);
			iowrite32(dev, SINKHORN_P2P_IN_REG, p2p_in);
			iowrite32(dev, SINKHORN_P2P_ITER_REG, p2p_iter);
			iowrite32(dev, SINKHORN_STORE_STATE_REG, store_state);

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
