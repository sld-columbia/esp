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

#define N_TILES 7
//#define N_TILE_CSRS 6 (0-1-2-3-4-5)
//#define N_NOC_CSRS 9 (12-13-14-15-16-17-18-19-31)
//#define N_PM_CFG_CSRS 9 (20-28)
//#define N_PM_STATUS_CSRS 2 (29-30)
#define N_CSRS_READ 25
#define N_CSRS_WRITE 23
#define TILE_ID_CSR 1 
#define TILE_ID_NOC_CSR 16

int main(int argc, char * argv[])
{
    int tid, rid;
    unsigned offset, val, csr_val;
    struct esp_device dev;

    int csr_ids[N_CSRS_READ] = { 0,  1,  2,  3,  4,  12, 13, 14,
			   15, 16, 17, 18, 19, 31, 20, 21, 22,
			    23, 24, 25, 26, 27, 28, 29, 30}; // excluding soft reset

    unsigned csr_def_val[N_CSRS_READ] = {1, 777, 0, 0, 0, 0x2af13ff4, 0xb3a7a217,
				    0x4d25366e, 490, 777, 3, 0x70095, 0x70095,
					 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 , 0};
    
    for (tid = 0; tid < N_TILES; ++tid) {
	dev.addr = CSR_TILE_BASE_ADDR + tid * CSR_TILE_OFFSET;
	for (rid = 0; rid < N_CSRS_READ; ++rid) {
	    offset = csr_ids[rid] * 4;
	    csr_val = ioread32(&dev, offset);
	    if ((csr_val != csr_def_val[rid]) && ~((csr_ids[rid] == 1 || csr_ids[rid] == 16) && csr_val == tid))
		printf("tid %u - rid %u - exp %u - val %u <-- error", tid, csr_ids[rid], csr_def_val[rid], csr_val);
	}
    }

    // Write
    // iowrite32(&dev, offset * 4, val);

    return 0;
}
