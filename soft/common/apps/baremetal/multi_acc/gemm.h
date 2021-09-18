/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#ifndef __GEMM_H__
#define __GEMM_H__

#include "multi_acc.h"

#define SLD_GEMM 0x051
#define DEV_NAME_GEMM "sld,gemm_stratus"

int32_t do_relu_gemm;
int32_t transpose;
int32_t ninputs;
int32_t d3;
int32_t d2;
int32_t d1;
int32_t st_offset;
int32_t ld_offset1;
int32_t ld_offset2;

static unsigned in_len_gemm, in1_len_gemm;
static unsigned out_len_gemm;
static unsigned in_size_gemm;
static unsigned out_size_gemm;
static unsigned out_offset_gemm;
static unsigned mem_size_gemm;

/* User defined registers */
#define GEMM_TRANSPOSE_REG 0x60
#define GEMM_DO_RELU_REG 0x5c
#define GEMM_ST_OFFSET_REG 0x58
#define GEMM_LD_OFFSET2_REG 0x54
#define GEMM_LD_OFFSET1_REG 0x50
#define GEMM_D3_REG 0x4c
#define GEMM_D2_REG 0x48
#define GEMM_D1_REG 0x44
#define GEMM_NINPUTS_REG 0x40

void sw_run_gemm(int32_t do_relu, int32_t transpose, int32_t ninputs,
		 int32_t d3, int32_t d2, int32_t d1,
		 native_t *in1, native_t *in2, native_t *out);
int validate_buf_gemm(token_t *out, native_t *gold);
void init_buf_gemm (token_t *in, native_t *sw_buf);


#endif // __GEMM_H__
