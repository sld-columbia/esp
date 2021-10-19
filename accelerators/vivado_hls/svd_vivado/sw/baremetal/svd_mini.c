/* Copyright (c) 2011-2019 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#ifndef __riscv
#include <stdio.h>
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>
#include <fixed_point.h>

typedef int32_t token_t;
#define Q 5
#define P 5
#define M 3

float inputX[] = { -0.99729546, -0.48864438, -1.1597335 , -1.83951924, -0.50367543,
		   -0.67540379, -1.76116705, -0.56847006, -0.96412516, -1.54168092,
		   -0.5463881 , -1.02347615, -1.03408063, -0.43882483, -0.9527715 };

float inputY[] = { 6.72627056e-01,  3.69826234e-02, -9.02181788e-17,
		   1.15215940e+00,  1.19119133e-01, -1.56858856e-16,
		   1.26133188e+00,  1.41772359e-01, -1.72195174e-16,
		   1.03926143e+00, -1.38062725e-01, -1.31267156e-16,
		   6.69471981e-01, -3.40943350e-01, -7.40678875e-17};

float inputT[] = { 0.00166667, 0        , 0        ,
		    0        , 0.00166667, 0        ,
		    0        , 0        , 0.00166667 };

float inputP = 0.0625;

float gold_out[] = { -0.8082151413, -0.2470283508, -0.534570694,
		       -0.2470264435, 0.966252327, -0.07303285599,
		       -0.5345711708, -0.07302713394, 0.8419623375 };

float gold_out_sink[M][P];


static unsigned DMA_WORD_PER_BEAT(unsigned _st)
{
        return (sizeof(void *) / _st);
}


#define SLD_SVD 0x222
#define DEV_NAME "sld,svd"

/* <<--params-->> */
const int32_t q = 5;
const int32_t p = 5;
const int32_t m = 3;
const int32_t p2p_out = 0;

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
#define SVD_P2P_OUT_REG 0x4C
#define SVD_Q_REG 0x48
#define SVD_P_REG 0x44
#define SVD_M_REG 0x40


static int validate_buf(token_t *out, float *gold)
{
	int i;
	int j;
	float MAE, MAE_sum, num;
	unsigned errors = 0;
	MAE_sum = 0;

	for (i = 0; i < 1; i++)
		for (j = 0; j < m*m; j++)
		{

			float val = fixed32_to_float(out[i * out_words_adj + j], 11);
			float gold_val = gold[i * out_words_adj + j];

			//MAE = (out[i * out_words_adj + j] - gold[i * out_words_adj + j])
			//	/ gold[i * out_words_adj + j];

			MAE = (val - gold_val) / gold_val;

			uint32_t* tmp1 = (uint32_t*) &gold[i * out_words_adj + j];
			print_uart("gold = ");print_uart_int(*tmp1);print_uart(" ");
			uint32_t* tmp2 = (uint32_t*) &val;
			print_uart("out = ");print_uart_int(*tmp2);print_uart("\n");

			MAE_sum += MAE*MAE;

			if (MAE > 0.15 || MAE < -0.15)
			{
				print_uart("Error for j = ");print_uart_int(j);print_uart("\n");
				errors++;
				uint32_t* tmp3 = (uint32_t*) &gold[i * out_words_adj + j];
				print_uart("gold = ");print_uart_int(*tmp3);print_uart(" ");
				uint32_t* tmp4 = (uint32_t*) &val;
				print_uart("out = ");print_uart_int(*tmp4);print_uart("\n");

				//print_uart("out = ");print_uart_int(10000*out[i * out_words_adj + j]);
				//print_uart(" gold = ");print_uart_int(10000*gold[i * out_words_adj + j]);
				//print_uart(" MAE = ");print_uart_int(1000*MAE);print_uart("\n");
			}

		}

	num = m*m;
	if (MAE_sum / num > 0.01)
		errors++;

	print_uart("Sum of errors is ");print_uart_int(errors);print_uart("\n");

	return errors;
}


static void init_buf (token_t *in, float * gold)
{
	int i;
	int j;
	int k, x, y, t;

	print_uart("init_buf \n");

	for (i = 0; i < 1; i++)
	{
		for(j = 0; j < p*q; j++) //Q
		{
			//print_uart("saving Q[");print_uart_int(j);print_uart("]\n");
			float val = (float) 1/(p * q);
			in[i * in_words_adj + j] = (token_t) float_to_fixed32(val, 11);
			//in[i * in_words_adj + j] = (token_t) j;
		}

		print_uart("  Generated Q \n");

		for(x = 0; x < m*p; x++) //X
			in[i * in_words_adj + j + x] = (token_t) float_to_fixed32(inputX[x], 11);
			//in[i * in_words_adj + j + x] = (token_t) j+x;

		print_uart("  Generated X \n");

		for(y = 0; y < m*q; y++) //Y
			in[i * in_words_adj + j + x + y] = (token_t) float_to_fixed32(inputY[y], 11);
			//in[i * in_words_adj + j + x + y] = (token_t) j+x+y;

		print_uart("  Generated Y \n");

		for(t = 0; t < m*m; t++) //T
			in[i * in_words_adj + j + x + y + t] = (token_t) float_to_fixed32(inputT[t], 11);
			//in[i * in_words_adj + j + x + y + t] = (token_t) j+x+y+t;

		print_uart("  Generated T \n");

		in[i * in_words_adj + j + x + y + t] = (token_t) float_to_fixed32(inputP, 11);
		//in[i * in_words_adj + j + x + y + t] = (token_t) j+x+y+t;
		print_uart("  Generated P \n");

	}

	print_uart("  Generated all inputs \n");

	for(k = 0; k < m; k++)
		for(j = 0; j < p; j++)
			gold_out_sink[k][j] = 0.0;

	for(k = 0; k < m; k++)
		for(i = 0; i < p; i++)
			for(j = 0; j < m; j++)
				gold_out_sink[k][i] += inputX[i * m + j] * gold_out[k * m + j];

	print_uart("  Generated golden output for sinkhorn \n");

	for (i = 0; i < 1; i++)
	{
		for(j = 0; j < m*m; j++)
			gold[i * out_words_adj + j] = gold_out[j];

		for(k = 0; k < m*p; k++)
			gold[i * out_words_adj + j + k] = gold_out_sink[k / p][k % p];
	}

	print_uart("  Generated output \n");
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
#ifndef __riscv
	printf("Scanning device tree... \n");
#else
	print_uart("Scanning device tree... \n");
#endif

	ndev = probe(&espdevs, SLD_SVD, DEV_NAME);
	if (ndev == 0) {
#ifndef __riscv
		printf("svd not found\n");
#else
		print_uart("svd not found\n");
#endif
		return 0;
	}

	for (n = 0; n < ndev; n++) {

		dev = &espdevs[n];

		// Check DMA capabilities
		if (ioread32(dev, PT_NCHUNK_MAX_REG) == 0) {
#ifndef __riscv
			printf("  -> scatter-gather DMA is disabled. Abort.\n");
#else
			print_uart("  -> scatter-gather DMA is disabled. Abort.\n");
#endif
			return 0;
		}

		if (ioread32(dev, PT_NCHUNK_MAX_REG) < NCHUNK(mem_size)) {
#ifndef __riscv
			printf("  -> Not enough TLB entries available. Abort.\n");
#else
			print_uart("  -> Not enough TLB entries available. Abort.\n");
#endif
			return 0;
		}

		// Allocate memory
		gold = aligned_malloc(out_size);
		mem = aligned_malloc(mem_size);
#ifndef __riscv
		printf("  memory buffer base-address = %p\n", mem);
#else
		print_uart("  memory buffer base-address = "); print_uart_addr((uintptr_t) mem); print_uart("\n");
#endif
		// Alocate and populate page table
		ptable = aligned_malloc(NCHUNK(mem_size) * sizeof(unsigned *));
		for (i = 0; i < NCHUNK(mem_size); i++)
			ptable[i] = (unsigned *) &mem[i * (CHUNK_SIZE / sizeof(token_t))];
#ifndef __riscv
		printf("  ptable = %p\n", ptable);
		printf("  nchunk = %lu\n", NCHUNK(mem_size));
#else
		print_uart("  ptable = "); print_uart_addr((uintptr_t) ptable); print_uart("\n");
		print_uart("  nchunk = "); print_uart_int(NCHUNK(mem_size)); print_uart("\n");
#endif

#ifndef __riscv
		printf("  Generate input...\n");
#else
		print_uart("  Generate input...\n");
#endif
		init_buf(mem, gold);

		// Pass common configuration parameters

		iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
		iowrite32(dev, COHERENCE_REG, ACC_COH_NONE);

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
		iowrite32(dev, SVD_P2P_OUT_REG, p2p_out);
		iowrite32(dev, SVD_Q_REG, q);
		iowrite32(dev, SVD_P_REG, p);
		iowrite32(dev, SVD_M_REG, m);

		// Flush (customize coherence model here)
		esp_flush(ACC_COH_NONE);

		// Start accelerators
#ifndef __riscv
		printf("  Start...\n");
#else
		print_uart("  Start...\n");
#endif
		iowrite32(dev, CMD_REG, CMD_MASK_START);

		// Wait for completion
		done = 0;
		while (!done) {
			done = ioread32(dev, STATUS_REG);
			done &= STATUS_MASK_DONE;
		}
		iowrite32(dev, CMD_REG, 0x0);

#ifndef __riscv
		printf("  Done\n");
		printf("  validating...\n");
#else
		print_uart("  Done\n");
		print_uart("  validating...\n");
#endif

		/* Validation */
		errors = validate_buf(&mem[out_offset], gold);
#ifndef __riscv
		if (errors)
			printf("  ... FAIL\n");
		else
			printf("  ... PASS\n");
#else
		if (errors)
			print_uart("  ... FAIL\n");
		else
			print_uart("  ... PASS\n");
#endif

		aligned_free(ptable);
		aligned_free(mem);
		aligned_free(gold);
	}

	return 0;
}
