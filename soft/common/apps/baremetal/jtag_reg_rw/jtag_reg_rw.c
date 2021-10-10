/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

/* Basic test for reading and writing any tile CSR.
 *
 * How to customize the test to read or write&read a specific CSR:
 * - test_type: set to test CSRs or accelerator registers, and either read-only
     or write&read.
     - 0 = CSR read only
     - 1 = CSR write&read
     - 2 = acc reg read only
     - 3 = acc reg write&read
 * - TILE_ID: ID of the tile containing the target CSR (range 0 to N_TILES-1)
 * - CSR_REG_OFFSET: can only write to in range 96 to 106, and 116 to 124
 * - ACC_ID: ID of the accelerator containing the target register (range 0 to N_ACC-1)
 * - ACC_REG_OFFSET: range 0 to 31

 *   to. Tiles are numbered starting from 0 from left to right and from
 *   top to bottom.
 * - Set CSR_REG_OFFSET to the CSR register ID (range 0 to 127). Beware that
 *   not all registers are readable, and that you may be overwriting important
 *   configuration parameters. Make sure you consult the tile CSRs source code
 *   in `rtl/sockets/crs`.
 * - Ser CSR_VAL to the expected value in the read-only mode, and to the value 
 *   to be written in the write&read mode.
 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>
#include "jtag_reg_rw.h"


// CSR offset
#define CSR_BASE_ADDR 0x60090180
#define CSR_TILE_OFFSET 0x200
#define TILE_ID 0
// example 1: 1 for read-only (value: TILE_ID), 1 for write&read (any value, e.g. 3)
// example 2: 8 for read-only (value: 0x2af13ff4), 8 for write&read (any value, 0x2bf13ff4)
#define CSR_REG_OFFSET 8
#define CSR_TILE_ADDR (CSR_BASE_ADDR + CSR_TILE_OFFSET * TILE_ID)

// CSR value
#define CSR_VAL 0x2bf13ff4

// Accelerator registers offset
#define ACCREG_BASE_ADDR 0x60010000
#define ACCREG_TILE_OFFSET 0x100
#define ACC_ID 0
// example:  7 for read-only (value: data_size in xml of accelerator, e.g. 4 for FFT2)
//          16 for write&read (any value, e.g. 12345678)
#define ACCREG_REG_OFFSET 7
#define ACCREG_TILE_ADDR (ACCREG_BASE_ADDR + ACCREG_TILE_OFFSET * ACC_ID)

// Accelerator register value
#define ACCREG_VAL 4

// Test type
const int test_type = 1; // 0 = CSR read only, 1 = CSR write&read
                         // 2 = acc reg read only, 3 = acc reg write&read

int main(int argc, char * argv[])
{
    int i;
    unsigned offset, val, csr_val;
    struct esp_device dev;

    // Set test configuration either for CSR or for accelerator registers
    if (test_type <= 1) {
	dev.addr = CSR_TILE_ADDR;
	offset = CSR_REG_OFFSET;
	val = CSR_VAL;
    } else {
	dev.addr = ACCREG_TILE_ADDR;
	offset = ACCREG_REG_OFFSET;
	val = ACCREG_VAL;
    }

    // Write
    if (test_type == 1 || test_type == 3) {
	iowrite32(&dev, offset * 4, val);
    }

    // Read
    csr_val = ioread32(&dev, offset * 4); 
    if (csr_val != val)
	printf("[ERROR] Expected : %u, read : %u.\n", val, csr_val);
    else
	printf("Test PASSED!\n");

    return 0;
}
