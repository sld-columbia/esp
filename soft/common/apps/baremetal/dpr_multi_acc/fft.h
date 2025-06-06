/* Copyright (c) 2011-2023 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#ifndef __FFT_H__
#define __FFT_H__

#include "dpr_multi_acc.h"

#if (FFT_FX_WIDTH == 64)
typedef long long token_t;
typedef double native_t;
    #define fx2float fixed64_to_double
    #define float2fx double_to_fixed64
    #define FX_IL    42
#else // (FFT_FX_WIDTH == 32)
typedef int token_t;
typedef float native_t;
    #define fx2float fixed32_to_float
    #define float2fx float_to_fixed32
    #define FX_IL    12
#endif /* FFT_FX_WIDTH */

static const float ERR_TH = 0.05;

#define SLD_FFT      0x059
#define DEV_NAME_FFT "sld,fft_stratus"

/* <<--params-->> */
static const int32_t log_len_fft    = 9;
static const int32_t batch_size_fft = 32;
static int32_t len_fft;
static int32_t do_bitrev_fft = 1;

static unsigned in_words_adj_fft;
static unsigned out_words_adj_fft;
static unsigned in_len_fft;
static unsigned out_len_fft;
static unsigned in_size_fft;
static unsigned out_size_fft;
static unsigned out_offset_fft;
static unsigned mem_size_fft;

/* Size of the contiguous chunks for scatter/gather */
#define CHUNK_SHIFT_FFT 20
#define CHUNK_SIZE_FFT  BIT(CHUNK_SHIFT_FFT)
#define NCHUNK_FFT(_sz) ((_sz % CHUNK_SIZE_FFT == 0) ? (_sz / CHUNK_SIZE_FFT) : (_sz / CHUNK_SIZE_FFT) + 1)

/* User defined registers */
/* <<--regs-->> */
#define FFT_DO_PEAK_REG    0x4c
#define FFT_DO_BITREV_REG  0x48
#define FFT_LOG_LEN_REG    0x44
#define FFT_BATCH_SIZE_REG 0x40

int validate_buf_fft(token_t *out, float *gold);
void init_buf_fft(token_t *in, float *gold);

#endif // __FFT_H__

