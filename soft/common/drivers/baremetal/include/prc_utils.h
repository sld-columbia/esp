#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif
#include <esp_probe.h>

#define LEN_DEVNAME_MAX 32

#define DECOUPLER_REG  0x30
#define PRC_INTERRUPT_REG 0x34
typedef struct pbs_map {
    char name [LEN_DEVNAME_MAX];    
    unsigned pbs_size;
    unsigned long long pbs_addr;
    unsigned pbs_tile_id;
}pbs_map;

int decouple_acc(struct esp_device *dev, unsigned val);
unsigned int reconfigure_FPGA(struct esp_device *dev, unsigned pbs_id);
