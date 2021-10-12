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
#define CPU0_TILE 1

#define MONITOR_BASE_ADDR 0x60090000
#define MONITOR_TILE_SIZE 0x200
unsigned int read_monitor(int tile_no, int mon_no)
{
    unsigned int offset = (MONITOR_TILE_SIZE / sizeof(unsigned int)) * tile_no;
    unsigned int *addr = ((unsigned int *) MONITOR_BASE_ADDR) + offset + mon_no + 1;
    return *addr;
}

void write_burst_reg(int tile_no, int val)
{
    unsigned int offset = (MONITOR_TILE_SIZE / sizeof(unsigned int)) * tile_no;
    unsigned int *addr = ((unsigned int *) MONITOR_BASE_ADDR) + offset;
    *addr = val;
}

int main(int argc, char * argv[])
{
    int tid, rid;
    unsigned offset, val, csr_val;
    struct esp_device dev;

    int csr_ids[N_CSRS_READ] = { 0,  1,  2,  3,  4,  12, 13, 14,
			   15, 16, 17, 18, 19, 31, 20, 21, 22,
			    23, 24, 25, 26, 27, 28, 29, 30}; // excluding soft reset

    int csr_write_ids[N_CSRS_WRITE] = {0, 2, 3, 4,
                                       12, 13, 14, 15, 17, 18, 19, 31,
                                       20, 21, 22, 23, 24, 25, 26, 27, 28};

    unsigned csr_def_val[N_CSRS_READ] = {1, 777, 0, 0, 0, 0x2af13ff4, 0xb3a7a217,
				    0x4e25366e, 490, 777, 3, 0x70095, 0x70095,
					 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 , 0};

    unsigned csr_write_val[N_CSRS_WRITE] = {0x1, 0x1d, 0x876, 0x3,
                             0x28e01ff4, 0xb1832017, 0x4601122e, 495, 4, 0x7c081, 0x7c081, 0x1ff,
					         0x1111, 0x2222, 0x3333, 0x4444, 0x5555, 0x6666, 0x7777, 0x8888, 0x9999};

    int data[11];
    for (tid = 0; tid < N_TILES; ++tid) {
        dev.addr = CSR_TILE_BASE_ADDR + tid * CSR_TILE_OFFSET;
        for (rid = 0; rid < N_CSRS_READ; ++rid) {
            offset = csr_ids[rid] * 4;
            csr_val = ioread32(&dev, offset);
            if ((csr_val != csr_def_val[rid]) && !((csr_ids[rid] == 1 || csr_ids[rid] == 16) && csr_val == (unsigned) tid) && !(tid == CPU0_TILE && csr_ids[rid] >= 12))
                printf("read tid %u - rid %u - exp %u - val %u <-- error\n", tid, csr_ids[rid], csr_def_val[rid], csr_val);
        }

        for (rid = 0; rid < N_CSRS_WRITE; ++rid) {
            offset = csr_write_ids[rid] * 4;
            iowrite32(&dev, offset, csr_write_val[rid]);
            csr_val = ioread32(&dev, offset);
            if (csr_val != csr_write_val[rid] && !(tid == CPU0_TILE && csr_write_ids[rid] >= 12))
                printf("write tid %u - rid %u - exp %u - val %u <-- error\n", tid, csr_write_ids[rid], csr_write_val[rid], csr_val);
        }

        write_burst_reg(tid, 1);
        data[0] = read_monitor(tid, 0);
        data[1] = read_monitor(tid, 1);
        data[2] = read_monitor(tid, 4);
        data[3] = read_monitor(tid, 12);
        data[4] = read_monitor(tid, 21);
        data[5] = read_monitor(tid, 22);
        data[6] = read_monitor(tid, 24);
        data[7] = read_monitor(tid, 32);
        data[8] = read_monitor(tid, 41);
        data[9] = read_monitor(tid, 52);
        data[10] = read_monitor(tid, 57);
        printf("tid %d: %u %u %u %u %u %u %u %u %u %u %u\n", tid, data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7], data[8], data[9], data[10]);
        write_burst_reg(tid, 0);
        data[0] = read_monitor(tid, 0);
        data[1] = read_monitor(tid, 1);
        data[2] = read_monitor(tid, 4);
        data[3] = read_monitor(tid, 12);
        data[4] = read_monitor(tid, 21);
        data[5] = read_monitor(tid, 22);
        data[6] = read_monitor(tid, 24);
        data[7] = read_monitor(tid, 32);
        data[8] = read_monitor(tid, 41);
        data[9] = read_monitor(tid, 52);
        data[10] = read_monitor(tid, 57);
        printf("tid %d: %u %u %u %u %u %u %u %u %u %u %u\n", tid, data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7], data[8], data[9], data[10]);
    }
    // Write
    // iowrite32(&dev, offset * 4, val);

    return 0;
}
