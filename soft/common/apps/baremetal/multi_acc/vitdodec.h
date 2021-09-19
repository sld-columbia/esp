/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#ifndef __VITDODEC_H__
#define __VITDODEC_H__

#include "multi_acc.h"
#include "do_decoding.h"

typedef int8_t token_vit_t;

#define SLD_VITDODEC 0x030
#define DEV_NAME_VIT "sld,vitdodec_stratus"

/* <<--params-->> */
int32_t cbps;
int32_t ntraceback;
#ifndef LARGE_WORKLOAD
int32_t data_bits;
#else
int32_t data_bits;
#endif
static unsigned in_len_vit;
static unsigned out_len_vit;
static unsigned in_size_vit;
static unsigned out_size_vit;
static unsigned out_offset_vit;
static unsigned mem_size_vit;

/* User defined registers */
#define VITDODEC_CBPS_REG 0x48
#define VITDODEC_NTRACEBACK_REG 0x44
#define VITDODEC_DATA_BITS_REG 0x40

#define ABS(x) ((x > 0) ? x : -x)

/* simple not quite random implementation of rand() when stdlib is not available */
static unsigned long int next = 42;

/* TEST-Specific Inputs */
static const unsigned char PARTAB[256] = {
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
         1, 0, 0, 1, 0, 1, 1, 0,
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
         0, 1, 1, 0, 1, 0, 0, 1,
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
         1, 0, 0, 1, 0, 1, 1, 0,
         0, 1, 1, 0, 1, 0, 0, 1,
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
         1, 0, 0, 1, 0, 1, 1, 0,
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
         0, 1, 1, 0, 1, 0, 0, 1,
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
         1, 0, 0, 1, 0, 1, 1, 0,
         0, 1, 1, 0, 1, 0, 0, 1,
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
         1, 0, 0, 1, 0, 1, 1, 0,
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
         0, 1, 1, 0, 1, 0, 0, 1,
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
}; 

int validate_buf_vitdodec(token_vit_t *out, token_vit_t *gold);
int irand(void);
void init_buf_vitdodec(token_vit_t *in, token_vit_t * gold);



#endif // __VITDODEC_H__
