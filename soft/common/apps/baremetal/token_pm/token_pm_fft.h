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
typedef int token_t;
typedef float native_t;
#define fx2float fixed32_to_float
#define float2fx float_to_fixed32
#define FX_IL 12

const float ERR_TH = 0.05;

static unsigned DMA_WORD_PER_BEAT(unsigned _st)
{
        return (sizeof(void *) / _st);
}

#define SLD_FFT 0x059
#define DEV_NAME "sld,fft_stratus"

/* <<--params-->> */
const int32_t log_len = 12;
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

static int fft_validate_buf(token_t *out, float *gold)
{
	int j;
	unsigned errors = 0;

	for (j = 0; j < 2 * len; j++) {
		native_t val = fx2float(out[j], FX_IL);
		if ((fabs(gold[j] - val) / fabs(gold[j])) > ERR_TH)
			errors++;
	}

	//printf("  %u errors\n", errors);
	return errors;
}


static void fft_init_buf(token_t *in, float *gold)
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

static void fft_init_params()
{
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
    out_offset  = 0;
    mem_size = (out_offset * sizeof(token_t)) + out_size;
}

/* static void fft_probe(struct esp_device **espdevs_fft) */
/* { */
/*     // Search for the device */
/*     printf("Scanning device tree... \n"); */

/*     ndev = probe(espdevs_fft, VENDOR_SLD, SLD_FFT, DEV_NAME); */
/*     if (ndev == 0) { */
/* 	printf("fft not found\n"); */
/* 	return 0; */
/*     } */
/* } */
