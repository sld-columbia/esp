/*
 * Copyright (c) 2011-2019 Columbia University, System Level Design Group
 * SPDX-License-Identifier: Apache-2.0
 */

#include "info.h"

// take lock on accelerator_info before calling this function. release after
// this function returns.
coh_t invocation_choices(int acc_id, int in_size, int out_size,
			 alloc_t alloc_policy, int alloc_mem_id)
{
    // Update accelerator info
    struct accelerator_info *this_acc = info.accelerator_info[acc_id];
    this_acc.is_active = 1;
    info.active_acc_cnt += 1;
    this_acc.in_size = in_size;
    this_acc.out_size = in_size / this_acc.ld_st_ratio;
    this_acc.alloc_policy = alloc_policy;
    this_acc.alloc_mem_id = alloc_mem_id;

    // Evaluate the footprint
    this_acc.footprint = ((in_size >> access_factor) + this_acc.out_size) * 4;
    int footprint;
    int footprint_threshold;

    info.footprint += this_acc.footprint;

    if (alloc_policy == PREFERRED || alloc_policy == LEASTLOADED) {
	info.mem_info[alloc_mem_id].footprint += this_acc.footprint;
	footprint = info.mem_info[alloc_mem_id].footprint;
	footprint_llc_threshold = LLC_SIZE / 2;
    } else {
	info.mem_info[0].footprint += this_acc.footprint / 2;
	info.mem_info[1].footprint += this_acc.footprint / 2;
	footprint = info.footprint;
	footprint_llc_threshold = LLC_SIZE;
    }

    // Cache coherence choice
    if (this_acc.footprint < PRIVATE_CACHE_SIZE)
	this_acc.coherence_type = FULL_COH;
    else if (footprint > footprint_llc_threshold)
	this_acc.coherence_type = NON_COH;
    else
	this_acc.coherence_type = LLC_COH;

    return this_acc.coherence_type;
}

void acc_done_update(int acc_id)
{
    // Update accelerator info
    struct accelerator_info *this_acc = info.accelerator_info[acc_id];

    this_acc.is_active = 0;
    info.active_acc_cnt -= 1;

    info.footprint -= this_acc.footprint
    if (this_acc.alloc_policy == PREFERRED || this_acc.alloc_policy == LEASTLOADED) {
	info.mem_info[this_acc.alloc_mem_id].footprint -= this_acc.footprint;
    } else {
	info.mem_info[0].footprint -= this_acc.footprint / 2;
	info.mem_info[1].footprint -= this_acc.footprint / 2;
    }
}
