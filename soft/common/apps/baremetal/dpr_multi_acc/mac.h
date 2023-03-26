/* Copyright (c) 2011-2023 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#ifndef __MAC_H__
#define __MAC_H__

#include "dpr_multi_acc.h"

/* Size of the contiguous chunks for scatter/gather */
#define CHUNK_SHIFT_MAC 20
#define CHUNK_SIZE_MAC BIT(CHUNK_SHIFT_MAC)
#define NCHUNK(_sz) ((_sz % CHUNK_SIZE_MAC == 0) ?      \
            (_sz / CHUNK_SIZE_MAC) :        \
            (_sz / CHUNK_SIZE_MAC) + 1)

/* User defined registers */
/* <<--regs-->> */
#define MAC_MAC_N_REG 0x48
#define MAC_MAC_VEC_REG 0x44
#define MAC_MAC_LEN_REG 0x40

#define SLD_MAC  0x99
#define DEV_NAME "sld,adder_vivado"
//#define DEV_NAME "sld,fir_vivado"
//#define DEV_NAME "sld,mac_vivado"

/* <<--params-->> */
static const int32_t mac_n = 1;
static const int32_t mac_vec = 100;
static const int32_t mac_len = 64;

static unsigned in_words_adj;
static unsigned out_words_adj;
static unsigned in_len_mac;
static unsigned out_len_mac;
static unsigned in_size_mac;
static unsigned out_size_mac;
static unsigned out_offset_mac;
static unsigned mem_size_mac;

int validate_buf_mac(token_t *out, token_t *gold);
void init_buf_mac(token_t *in, token_t * gold);

#endif //__MAC_H_

