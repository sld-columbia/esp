/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#ifndef __GEMM_STRATUS_MINIMAL_H__
#define __GEMM_STRATUS_MINIMAL_H__

#define ACC_BASE_ADDR 0x60010000
#define ACC_OFFSET 0x100
// Set accelerator ID (ACC_TILE_ID) according to the position of the accelerator in the
// SoC. Acc IDs increment from left to right and from top to bottom.
#define ACC_ID 0
#define ACC_ADDR (ACC_BASE_ADDR + (ACC_OFFSET * ACC_ID))

#endif /* __GEMM_STRATUS_MINIMAL_H__ */

static inline uint64_t get_counter()
{
    uint64_t counter;
    asm volatile (
	"li t0, 0;"
	"csrr t0, mcycle;"
	"mv %0, t0"
	: "=r" ( counter )
	:
	: "t0"
        );
    return counter;
} 
