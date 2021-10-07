/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#ifndef __HU_AUDIODEC_MINIMAL_H__
#define __HU_AUDIODEC_MINIMAL_H__

#define ACC_BASE_ADDR 0x60010000
#define ACC_OFFSET 0x100
// Set accelerator ID (ACC_TILE_ID) according to the position of the accelerator in the
// SoC. Acc IDs increment from left to right and from top to bottom.
#define ACC_ID 0
#define ACC_ADDR (ACC_BASE_ADDR + (ACC_OFFSET * ACC_ID))

#endif /* __HU_AUDIODEC_MINIMAL_H__ */
