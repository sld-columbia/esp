/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>
#include "utils/fft_utils.h"

// FFT_FX_WIDTH == 32
typedef int fft_token_t;
typedef float fft_native_tt;
#define fx2float fixed32_to_float
#define float2fx float_to_fixed32
#define FX_IL 12

const float ERR_TH = 0.05;

static unsigned DMA_WORD_PER_BEAT(unsigned _st)
{
        return (sizeof(void *) / _st);
}

#define SLD_FFT 0x059
#define FFT_DEV_NAME "sld,fft_stratus"

/* <<--params-->> */
const int32_t log_len = 12;
int32_t len;
int32_t do_bitrev = 1;

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

static int fft_validate_buf(fft_token_t *out, fft_token_t *gold)
{
	int j;
	unsigned errors = 0;

	for (j = 0; j < 2 * len; j++) {
		fft_native_tt val = fx2float(out[j], FX_IL);
		if ((fabs(gold[j] - val) / fabs(gold[j])) > ERR_TH)
			errors++;
	}

	//printf("  %u errors\n", errors);
	return errors;
}


static void fft_init_buf(fft_token_t *in, fft_token_t *gold)
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
		fft_bit_reverse((float *)gold, len, log_len);

	printf("  Done bit reverse ...\n");
	// convert input to fixed point
	for (j = 0; j < 2 * len; j++)
		in[j] = float2fx((fft_native_tt) gold[j], FX_IL);

	printf("  Done type convert ...\n");

	// Compute golden output
	fft_comp((float *) gold, len, log_len, -1, do_bitrev);
	printf("  Done compare ...\n");
}

static unsigned fft_init_params()
{
    len = 1 << log_len;

    if (DMA_WORD_PER_BEAT(sizeof(fft_token_t)) == 0) {
	in_words_adj = 2 * len;
	out_words_adj = 2 * len;
    } else {
	in_words_adj = round_up(2 * len, DMA_WORD_PER_BEAT(sizeof(fft_token_t)));
	out_words_adj = round_up(2 * len, DMA_WORD_PER_BEAT(sizeof(fft_token_t)));
    }
    in_len = in_words_adj;
    out_len = out_words_adj;
    in_size = in_len * sizeof(fft_token_t);
    out_size = out_len * sizeof(fft_token_t);
    out_offset  = 0;
    mem_size = (out_offset * sizeof(fft_token_t)) + out_size;
    return mem_size;
}

static void fft_probe(struct esp_device **espdevs_fft)
{
    int ndev;

    // Search for the device
    printf("Probing for FFT accs, scanning device tree... \n");

    ndev = probe(espdevs_fft, VENDOR_SLD, SLD_FFT, FFT_DEV_NAME);
    if (ndev == 0)
	printf("fft not found\n");
    else
	printf("Found %d FFT instances\n",ndev);
}


void setup_fft(struct esp_device *dev, fft_token_t *gold_fft, fft_token_t *mem_fft, unsigned **ptable)
{
	int i; 
	//// Check DMA capabilities
	//if (ioread32(dev, PT_NCHUNK_MAX_REG) == 0) 	{
	//	printf("  -> scatter-gather DMA is disabled. Abort.\n");
	//	return;
	//}

	//if (ioread32(dev, PT_NCHUNK_MAX_REG) < NCHUNK(mem_size)) {
	//	printf("  -> Not enough TLB entries available. Abort.\n");
	//	return;
	//}

	// Allocate memory
	gold_fft = aligned_malloc(out_len * sizeof(float));
	mem_fft = aligned_malloc(mem_size);

	// Allocate and populate page table
	ptable = aligned_malloc(NCHUNK(mem_size) * sizeof(unsigned *));

	for (i = 0; i < NCHUNK(mem_size); i++)
		ptable[i] = (unsigned *) &mem_fft[i * (CHUNK_SIZE / sizeof(fft_token_t))];

	// Pass accelerator-specific configuration parameters
	/* <<--regs-config-->> */
	iowrite32(dev, FFT_DO_PEAK_REG, 0);
	iowrite32(dev, FFT_DO_BITREV_REG, do_bitrev);
	iowrite32(dev, FFT_LOG_LEN_REG, log_len);
	#ifdef DEBUG
		printf("  memory buffer base-address = %p\n", mem_fft);
		printf("  ptable = %p\n", ptable);
		printf("  nchunk = %lu\n", NCHUNK(mem_size));
		printf("  --------------------\n");
	#endif
	//fft_init_buf(mem_fft, gold_fft);
	// Pass common configuration parameters
	iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
	iowrite32(dev, COHERENCE_REG, ACC_COH_NONE);

	iowrite32(dev, PT_ADDRESS_REG, (unsigned long) ptable);

	iowrite32(dev, PT_NCHUNK_REG, NCHUNK(mem_size));
	iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);

	// Use the following if input and output data are not allocated at the default offsets
	iowrite32(dev, SRC_OFFSET_REG, 0x0);
	iowrite32(dev, DST_OFFSET_REG, 0x0);
	
}
