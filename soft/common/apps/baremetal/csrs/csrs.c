/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>
#include "csrs.h"


// CSR offset
#define CSR_TILE_BASE_ADDR 0x60090180
#define CSR_NOC_BASE_ADDR 0x600901c0
#define CSR_TILE_OFFSET 0x200

#define N_TILES 4

int main(int argc, char * argv[])
{
    int tid;
    unsigned offset, val, csr_val;
    struct esp_device dev;

    for (tid = 0; tid < N_TILES; ++tid) {
	// read tile CSRs
	dev.addr = CSR_TILE_BASE_ADDR + tid * CSR_TILE_OFFSET;
	offset = 1;
	csr_val = ioread32(&dev, offset * 4);
	printf("val %u\n", csr_val);

	// read tile CSRs
	dev.addr = CSR_TILE_BASE_ADDR + tid * CSR_TILE_OFFSET;
	offset = 8;
	csr_val = ioread32(&dev, offset * 4);
	printf("val %u\n", csr_val);

	// NoC CSRs
	dev.addr = CSR_NOC_BASE_ADDR + tid * CSR_TILE_OFFSET;;
	offset = 0;
	csr_val = ioread32(&dev, offset * 4);
	printf("val %u\n", csr_val);

	// NoC CSRs
	dev.addr = CSR_NOC_BASE_ADDR + tid * CSR_TILE_OFFSET;;
	offset = 3;
	csr_val = ioread32(&dev, offset * 4);
	printf("val %u\n", csr_val);
    }

    /* // Write */
    /* iowrite32(&dev, offset * 4, val); */

    /* // Read */
    /* csr_val = ioread32(&dev, offset * 4);  */
    /* if (csr_val != val) */
    /* 	printf("[ERROR] Expected : %u, read : %u.\n", val, csr_val); */
    /* else */
    /* 	printf("Test PASSED!\n"); */

    return 0;
}
