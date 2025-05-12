#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif
#include <esp_probe.h>

#define LEN_DEVNAME_MAX 32

//#define DECOUPLER_REG     0x030 // addr[:2] = 0b01100 = 12
#define DECOUPLER_REG     0x040 // addr[:2] = 0b10000 = 16
//#define PRC_INTERRUPT_REG 0x034 // addr[:2] = 0b01101 = 13
#define PRC_INTERRUPT_REG 0x104 // addr[:2] = 0b10001 = 17
typedef struct pbs_map {
    char name [LEN_DEVNAME_MAX];
    unsigned pbs_size;
    unsigned long long pbs_addr;
    unsigned pbs_tile_id;
}pbs_map;

int decouple_acc(struct esp_device *dev, unsigned val);
unsigned int reconfigure_FPGA(struct esp_device *dev, unsigned pbs_id);
