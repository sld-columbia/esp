/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#ifndef __SYNTH_P2P_MINIMAL_H__
#define __SYNTH_P2P_MINIMAL_H__

#ifdef __riscv
#define ACC_BASE_ADDR 0x60010000
#else
#define ACC_BASE_ADDR 0x80010000
#endif
#define ACC_OFFSET 0x100
// Set accelerator ID (ACC_TILE_ID) according to the position of the accelerator in the
// SoC. Acc IDs increment from left to right and from top to bottom.
#define ACC0_ID 0
#define ACC0_ADDR (ACC_BASE_ADDR + (ACC_OFFSET * ACC0_ID))

#define ACC1_ID 1
#define ACC1_ADDR (ACC_BASE_ADDR + (ACC_OFFSET * ACC1_ID))

#endif /* __FFT2_STRATUS_MINIMAL_H__ */
