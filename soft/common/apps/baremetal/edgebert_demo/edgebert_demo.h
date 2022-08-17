/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#ifndef __EDGEBERT_DEMO_H__
#define __EDGEBERT_DEMO_H__

#define ACC_BASE_ADDR 0x60400000
#define ACC_OFFSET 0x100000
// Set accelerator ID (ACC_TILE_ID) according to the position of the accelerator in the
// SoC. Acc IDs increment from left to right and from top to bottom.
#define ACC_ID 0
#define ACC_ADDR (ACC_BASE_ADDR + (ACC_OFFSET * ACC_ID))

#define CSR_BASE_ADDR 0x60090180
#define CSR_TILE_OFFSET 0x200
#define TILE_ID 2
#define CSR_REG_OFFSET 4
#define CSR_TILE_ADDR (CSR_BASE_ADDR + CSR_TILE_OFFSET * TILE_ID)


#endif /* __EDGEBERT_DEMO_H__ */
