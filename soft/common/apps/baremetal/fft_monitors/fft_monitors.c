/* Copyright (c) 2011-2023 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>
#include "utils/fft_utils.h"
#include "monitors.h"

#if (FFT_FX_WIDTH == 64)
typedef long long token_t;
typedef double native_t;
#define fx2float fixed64_to_double
#define float2fx double_to_fixed64
#define FX_IL 42
#else // (FFT_FX_WIDTH == 32)
typedef int token_t;
typedef float native_t;
#define fx2float fixed32_to_float
#define float2fx float_to_fixed32
#define FX_IL 12
#endif /* FFT_FX_WIDTH */

const float ERR_TH = 0.05;

static unsigned DMA_WORD_PER_BEAT(unsigned _st)
{
		return (sizeof(void *) / _st);
}


#define SLD_FFT 0x059
#define DEV_NAME "sld,fft_stratus"

/* <<--params-->> */
const int32_t log_len = 3;
int32_t len;
int32_t do_bitrev = 1;

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
#define FFT_DO_PEAK_REG 0x48
#define FFT_DO_BITREV_REG 0x44
#define FFT_LOG_LEN_REG 0x40


static int validate_buf(token_t *out, float *gold)
{
	int j;
	unsigned errors = 0;

	for (j = 0; j < 2 * len; j++) {
		native_t val = fx2float(out[j], FX_IL);
		if ((fabs(gold[j] - val) / fabs(gold[j])) > ERR_TH)
			errors++;
	}

	//printf("	%u errors\n", errors);
	return errors;
}


static void init_buf(token_t *in, float *gold)
{
	int j;
	const float LO = -10.0;
	const float HI = 10.0;

	/* srand((unsigned int) time(NULL)); */

	for (j = 0; j < 2 * len; j++) {
		float scaling_factor = (float) rand () / (float) RAND_MAX;
		gold[j] = LO + scaling_factor * (HI - LO);
	}

	// preprocess with bitreverse (fast in software anyway)
	if (!do_bitrev)
		fft_bit_reverse(gold, len, log_len);

	// convert input to fixed point
	for (j = 0; j < 2 * len; j++)
		in[j] = float2fx((native_t) gold[j], FX_IL);


	// Compute golden output
	fft_comp(gold, len, log_len, -1, do_bitrev);
}


int main(int argc, char * argv[])
{
	int i;
	int n;
	int ndev;
	struct esp_device *espdevs;
	struct esp_device *dev;
	unsigned done;
	unsigned **ptable = NULL;
	token_t *mem;
	float *gold;
	unsigned errors = 0;
	unsigned coherence;
		const int ERROR_COUNT_TH = 0.001;

	len = 1 << log_len;

	if (DMA_WORD_PER_BEAT(sizeof(token_t)) == 0) {
		in_words_adj = 2 * len;
		out_words_adj = 2 * len;
	} else {
		in_words_adj = round_up(2 * len, DMA_WORD_PER_BEAT(sizeof(token_t)));
		out_words_adj = round_up(2 * len, DMA_WORD_PER_BEAT(sizeof(token_t)));
	}
	in_len = in_words_adj;
	out_len = out_words_adj;
	in_size = in_len * sizeof(token_t);
	out_size = out_len * sizeof(token_t);
	out_offset	= 0;
	mem_size = (out_offset * sizeof(token_t)) + out_size;


	// Search for the device
	printf("Scanning device tree... \n");

	ndev = probe(&espdevs, VENDOR_SLD, SLD_FFT, DEV_NAME);
	if (ndev == 0) {
		printf("fft not found\n");
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

		// Allocate and populate page table
		ptable = aligned_malloc(NCHUNK(mem_size) * sizeof(unsigned *));
		for (i = 0; i < NCHUNK(mem_size); i++)
			ptable[i] = (unsigned *) &mem[i * (CHUNK_SIZE / sizeof(token_t))];

		printf("  ptable = %p\n", ptable);
		printf("  nchunk = %lu\n", NCHUNK(mem_size));

#ifndef __riscv
		for (coherence = ACC_COH_NONE; coherence <= ACC_COH_FULL; coherence++) {
#else
			{
			coherence = ACC_COH_NONE;
#endif
			printf("  --------------------\n");
			printf("  Generate input...\n");
			init_buf(mem, gold);

			// Pass common configuration parameters

			iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
			iowrite32(dev, COHERENCE_REG, coherence);

			iowrite32(dev, PT_ADDRESS_REG, (unsigned long) ptable);

			iowrite32(dev, PT_NCHUNK_REG, NCHUNK(mem_size));
			iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);

			// Use the following if input and output data are not allocated at the default offsets
			iowrite32(dev, SRC_OFFSET_REG, 0x0);
			iowrite32(dev, DST_OFFSET_REG, 0x0);

			// Pass accelerator-specific configuration parameters
			/* <<--regs-config-->> */
			iowrite32(dev, FFT_DO_PEAK_REG, 0);
			iowrite32(dev, FFT_DO_BITREV_REG, do_bitrev);
			iowrite32(dev, FFT_LOG_LEN_REG, log_len);

			esp_monitor_args_t mon_args;
			mon_args.read_mode = ESP_MON_READ_ALL;

			//declare monitor structures and capture start values
			esp_monitor_vals_t vals_start, vals_end, vals_diff;
			esp_monitor(mon_args, &vals_start);

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

			//capture end values and compute difference
			esp_monitor(mon_args, &vals_end);
			vals_diff = esp_monitor_diff(vals_start, vals_end);

			printf("  Done\n");
			printf("  validating...\n");

			/* Validation */
			errors = validate_buf(&mem[out_offset], gold);
			if ((errors / len) > ERROR_COUNT_TH)
				printf("  ... FAIL\n");
			else
				printf("  ... PASS\n");

			//dump monitor statistics
			esp_monitor_print(mon_args, vals_diff);
		}
		aligned_free(ptable);
		aligned_free(mem);
		aligned_free(gold);
	}

	return 0;
}
