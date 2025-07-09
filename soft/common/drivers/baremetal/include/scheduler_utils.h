
#include "soc_defs.h"
//#include "soc_locs.h"

#ifndef __SCHEDULER_UTILS_H__
#define __SCHEDULER_UTILS_H__

#ifdef __riscv
    #ifndef APB_BASE_ADDR
        #define APB_BASE_ADDR 0x60000000
    #endif
#endif

// selection values for the clock selector
#define N_FREQS 7
unsigned div_sel[N_FREQS] = { 0b001, 0b010, 0b011, 0b100, 0b101, 0b110, 0b111 };

// Operating point for an accelerator
typedef struct acc_operating_point {
    unsigned viable;
} acc_operating_point_t;

// Set of operating points
typedef struct acc_profile {
    unsigned tile_id;
    acc_operating_point_t op[N_FREQS];
} acc_profile_t;

// DFS register mapping and encoding
#define DCO_REG 0b1001100 // addr[6:2] = 19
int encode_dco_ctrl(int freq_sel, int div_sel, int fc_sel, int cc_sel, int clk_sel, int en) {
    return ((      en & 0b000001) <<  0) |
           (( clk_sel & 0b000001) <<  1) |
           ((  cc_sel & 0b111111) <<  2) |
           ((  fc_sel & 0b111111) <<  8) |
           (( div_sel & 0b000111) << 14) |
           ((freq_sel & 0b000011) << 17);
}

// Get base address of router
/*int get_router_addr(struct esp_device *dev, struct esp_device *router)
{
    unsigned i;
    unsigned tile_id = 0xFF;
    unsigned dev_addr;
    unsigned dev_addr_trunc;
    unsigned dev_start_addr = 0x10000;

    const unsigned addr_incr = 0x100;
    const unsigned monitor_base = 0x90180;

    dev_addr = (unsigned) dev->addr;
    dev_addr_trunc = (dev_addr << 12) >> 12;

#ifdef SCHEDULER_VERBOSE
    printf("[SCHEDULER]: device address -- 0x%0x, truncated addr -- 0x%0x \n", dev_addr, dev_addr_trunc);
#endif

    //Obtain tile id
    USE_SOC_LOCS();
    for (i = 0; i < SOC_NACC; i++) {
        if(dev_start_addr == dev_addr_trunc) {
            tile_id = acc_locs[i].row * SOC_COLS + acc_locs[i].col;
            break;
        }
         else
            dev_start_addr += addr_incr;
    }

    if(tile_id == 0XFF) {
        printf("[PRC DRIVER]: Error: cannot find tile id\n");
        return -1;
    }

    // compute apb address for tile decoupler
    (*router).addr = APB_BASE_ADDR + (monitor_base + tile_id * 0x200);
#ifdef SCHEDULER_VERBOSE
    printf("[SCHEDULER]: tile_id -- 0x%0x, decoupler addr is -- 0x%0llx \n", tile_id, (*router).addr);
#endif
    return 0;
}*/

// Write to frequency control register
void write_div_sel(struct esp_device *router_dev, int div_sel, int en) {
    iowrite32(router_dev, DCO_REG, encode_dco_ctrl(0, div_sel, 0, 0, 0, en));
}

#endif // __SCHEDULER_UTILS_H__
