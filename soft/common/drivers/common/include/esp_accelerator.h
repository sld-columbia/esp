/*
 * Copyright (c) 2011-2024 Columbia University, System Level Design Group
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef __ESP_ACCELERATOR_H__
#define __ESP_ACCELERATOR_H__

#define BIT(nr)			(1UL << (nr))

#ifndef __KERNEL__
#define __round_mask(x, y) ((y)-1)
#define round_up(x, y) ((((x)-1) | __round_mask(x, y))+1)
#endif


/***
 * ESP accelerator common definitions and registers offset
 ***/

/* bank(0): CMD (reset if cleared) */
#define CMD_REG 0x00
#define CMD_MASK_START BIT(0)

/* bank(1): STATUS (idle when cleared) - Read only */
#define STATUS_REG 0x04
#define STATUS_MASK_RUN  BIT(0)
#define STATUS_MASK_DONE BIT(1)
#define STATUS_MASK_ERR  BIT(2)

/* bank(2)        : RESERVED - Read only */
#define DEVID_REG 0x08

/* bank(3)        : PT_ADDRESS (page table bus address) */
#define PT_ADDRESS_REG 0x0c

/* bank(4)        : PT_NCHUNK (number of physical contiguous buffers in memory) */
#define PT_NCHUNK_REG 0x10

/* bank(5)        : PT_SHIFT (log2(cunk size)) */
#define PT_SHIFT_REG 0x14

/* bank(6)        : PT_NCHUNK_MAX (maximum number of chunks supported) - Read only */
#define PT_NCHUNK_MAX_REG 0x18

/* bank(7)        : PT_ADDRESS_EXTENDED (page table bus address MSBs) */
#define PT_ADDRESS_EXTENDED_REG 0x1c

/* bank(8)        : Type of coherence (None, LLC, Full) - Read only */
#define COHERENCE_REG 0x20
enum accelerator_coherence {ACC_COH_NONE = 0, ACC_COH_LLC, ACC_COH_RECALL, ACC_COH_FULL, ACC_COH_AUTO};

/* bank(9)       : Point-to-point configuration */
#define P2P_REG 0x24
#define P2P_MASK_NSRCS 0x3
#define P2P_MASK_SRC_IS_P2P BIT(2)
#define P2P_MASK_DST_IS_P2P BIT(3)
#define P2P_MASK_SRCS_YX 0x7
#define P2P_BIT_SRCS_YX 4
#define YX_WIDTH 4
#define P2P_SHIFT_SRCS_Y(_n) (P2P_BIT_SRCS_YX + YX_WIDTH + _n * 2 * YX_WIDTH)
#define P2P_SHIFT_SRCS_X(_n) (P2P_BIT_SRCS_YX + _n * 2 * YX_WIDTH)

/* bank(10)       : SRC_OFFSET (offset in bytes from beginning of physical buffer) */
#define SRC_OFFSET_REG 0x28

/* bank(11)       : DST_OFFSET (offset in bytes from beginning of physical buffer) */
#define DST_OFFSET_REG 0x2C

/* bank(12)       : RESERVED */
#define SPANDEX_REG 0x30

/* bank(13)       : Point-to-point configuration */
#define MCAST_REG 0x34
#define MCAST_MASK_NDESTS 0xF
#define MCAST_SHIFT_NDESTS 0
#define MCAST_MASK_PACKET 0x1
#define MCAST_SHIFT_PACKET 4
#define MCAST_MASK_PACKET_SIZE 0xF
#define MCAST_SHIFT_PACKET_SIZE 5

/* bank(16 to 95) : USR (user defined) */

/* YX_REGs contain a mapping from an accelerator number to a physical tile coordinate */
/* bank(96)       : YX_REG - LSBs reserved for local tile's coordinates */
#define YX_REG 0x180
#define YX_SHIFT_X 0
#define YX_SHIFT_Y 4
#define YX_MASK_YX 0xF
#define YX_WIDTH 4

/* bank(97)       : YX_REG_2 */
#define YX_REG_2 0x184

/* bank(98)       : YX_REG_3 */
#define YX_REG_3 0x188

/* bank(99)       : YX_REG_2 */
#define YX_REG_4 0x18C

/* bank(100)      : YX_REG_3 */
#define YX_REG_5 0x190

/* bank(101)      : YX_REG_2 */
#define YX_REG_6 0x194

/* bank(102)      : YX_REG_3 */
#define YX_REG_7 0x198

/* bank(103)      : YX_REG_2 */
#define YX_REG_8 0x19C

/* bank(104)      : YX_REG_3 */
#define YX_REG_9 0x1A0

// Re-enable the following 3 registers if adding an SRAM expanding the register bank
// /* bank(29)       : EXP_ADDR (bits 29:0 address an SRAM expanding the register bank) */
// #define EXP_ADDR_REG 0x74
// #define EXT_MASK_R BIT(30)
// #define EXT_MASK_W BIT(31)
// /* bank(30)       : EXP_DI (data to be written to the expansion SRAM) */
// #define EXP_DI_REG 0x78
// /* bank(31)       : EXP_DO (data read from the exansion SRAM) */
// #define EXP_DO_REG 0x7c

#endif /* __ESP_ACCELERATOR_H__ */
