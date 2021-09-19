/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#ifndef __FFT2_H__
#define __FFT2_H__

#include "multi_acc.h"
#include "utils/fft2_utils.h"

#define SLD_FFT2 0x057
#define DEV_NAME_FFT2 "sld,fft2_stratus"

static int32_t logn_samples;
static int32_t num_ffts;
static int32_t do_inverse;
static int32_t do_shift;
static int32_t scale_factor;
static int32_t num_samples; // = (1 << logn_samples);

static int32_t len_fft2;
static unsigned in_len_fft2;
static unsigned out_len_fft2;
static unsigned in_size_fft2;
static unsigned out_size_fft2;
static unsigned out_offset_fft2;
static unsigned mem_size_fft2;

/* User defined registers */
#define FFT2_LOGN_SAMPLES_REG 0x40
#define FFT2_NUM_FFTS_REG 0x44
#define FFT2_DO_INVERSE_REG 0x48
#define FFT2_DO_SHIFT_REG 0x4c
#define FFT2_SCALE_FACTOR_REG 0x50

int validate_buf_fft2(token_t *out, float *gold);
void init_buf_fft2(token_t *in, float *gold);


#endif // __FFT2_H__
