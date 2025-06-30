
#include "soc_defs.h"

#ifndef __SCHEDULER_UTILS_H__
#define __SCHEDULER_UTILS_H__

// selection values for the clock selector
#define N_FREQS 7
static unsigned div_sel[N_FREQS] = { 0b001, 0b010, 0b011, 0b100, 0b101, 0b110, 0b111 };

// Operating point for an accelerator
typedef struct acc_operating_point {
    unsigned viable;
} acc_operating_point_t;

// Set of operating points
typedef struct acc_profile {
    unsigned tile_id;
    acc_operating_point_t op[N_FREQS];
} acc_profile_t;

// DFS invocation
#define DCO_REG 0b1001100 // addr[6:2] = 19

#endif // __SCHEDULER_UTILS_H__
