/* Copyright (c) 2011-2023 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#ifndef __ADDER_H__
#define __ADDER_H__

#include "dpr_multi_acc.h"

#define SIZE_IN_CHUNK_DATA_ADDER 64
#define SIZE_OUT_CHUNK_DATA_ADDER 32

// Sizes
#define NINVOKE 4
#define NBURSTS 4
#define IN_SIZE_DATA_ADDER (SIZE_IN_CHUNK_DATA_ADDER * NBURSTS)
#define OUT_SIZE_DATA_ADDER (SIZE_OUT_CHUNK_DATA_ADDER * NBURSTS)
#define IN_SIZE_ADDER (IN_SIZE_DATA_ADDER * sizeof(token_t))
#define OUT_SIZE_ADDER (OUT_SIZE_DATA_ADDER * sizeof(token_t))
#define SIZE_DATA_ADDER (IN_SIZE_DATA_ADDER + OUT_SIZE_DATA_ADDER)
#define SIZE_ADDER (IN_SIZE_ADDER + OUT_SIZE_ADDER)

/* Size of the contiguous chunks for scatter/gather */
#define CHUNK_SHIFT_ADDER 9
#define CHUNK_SIZE_ADDER BIT(CHUNK_SHIFT_ADDER)
#define NCHUNK_ADDER ((SIZE_ADDER % CHUNK_SIZE_ADDER == 0) ?      \
        (SIZE_ADDER / CHUNK_SIZE_ADDER) :           \
        (SIZE_ADDER / CHUNK_SIZE_ADDER) + 1)

// User defined registers
#define NBURSTS_REG   0x40

void init_buff_adder(token_t *in, token_t *out);
int validate_adder(token_t *in, token_t *gold);
#endif // __ADDER_H__
