/*
 * Copyright (c) 2011-2019 Columbia University, System Level Design Group
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef _INFO_H_
#define _INFO_H_

#define N_ACC 12
#define N_MEM 2

#define PRIVATE_CACHE_SIZE 65536
#define LLC_SIZE 2097152 

typedef enum coherence_type {NON_COH, LLC_COH, FULL_COH} coh_t;
typedef enum allocation_type {PREFERRED, LEASTLOADED, BALANCED} alloc_t;

struct accelerator_info
{
    // static parameters
    int id;
    int tile_x_coord;
    int tile_y_coord;

    int pattern;
    int access_factor;
    int burst_len;
    int compute_bound_factor;
    int ld_st_ratio;
    int stride_len;
    int in_place;

    // dynamic parameters
    bool is_active;
    coh_t coherence_type;
    int offset;
    int in_size;
    int out_size;
    int irregular_seed;
    coh_t alloc_policy;
    bool alloc_mem_id;
    int footprint;

};

struct mem_ctrl_info
{
    // static parameters
    int id;
    int tile_x_coord;
    int tile_y_coord;

    // dynamic parameters
    int footprint;
};

struct info {
    struct accelerator_info acc_info[N_ACC];
    struct mem_ctrl_info mem_info[N_MEM];
    int active_acc_cnt;
    int footprint;
};

struct info accs_info;

#endif /* _INFO_H_ */
