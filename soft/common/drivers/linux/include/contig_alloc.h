/*
 * Copyright (c) 2011-2023 Columbia University, System Level Design Group
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef CONTIG_ALLOC_H
#define CONTIG_ALLOC_H

#ifdef __KERNEL__
#include <linux/compiler.h>
#include <linux/ioctl.h>
#else
#include <sys/ioctl.h>
#ifndef __user
#define __user
#endif
#endif

#define CONTIG_MAJOR 240
#define CONTIG_MINOR 0

/* enforce strict typecheck */
struct contig_khandle_struct {
	char unused;
};
typedef struct contig_khandle_struct *contig_khandle_t;

/**
 * enum contig_alloc_policy - chunks allocation policies across DDR controllers
 * @CONTIG_ALLOC_PREFERRED: use first available chunks starting from a
 *	user-specified DDR controller.
 * @CONTIG_ALLOC_LEAST_LOADED: allocate all chunks of each buffer on the DDR
 *	controller with more inactive chunks. DDR0 is chosen only when
 *	allocated_mem(DDR0) < allocated_mem(DDRx) - T for every controller,
 *	where x is not 0. This user-defined penalty accounts for the CPU
 *	sharing DDR0.
 * @CONTIG_ALLOC_BALANCED: allocate a cluster of N chunks for each memory
 *	controller.
 */
enum contig_alloc_policy {
	CONTIG_ALLOC_PREFERRED,
	CONTIG_ALLOC_LEAST_LOADED,
	CONTIG_ALLOC_BALANCED,
};

/**
 * struct contig_alloc_preferred
 * @first_ddr_node: first DDR controller chosen
 */
struct contig_alloc_preferred {
        int ddr_node;
};

/**
 * struct contig_alloc_least_loaded
 * @threshold: DDR0 penalty
 */
struct contig_alloc_least_loaded {
        unsigned int threshold;
};

/**
 * struct contig_alloc_balanced
 * @threshold: DDR0 penalty
 * @cluster_size: number of chunks in the clusters
 */
struct contig_alloc_balanced {
        unsigned int threshold;
        unsigned int cluster_size;
};

/**
 * struct contig_alloc_params - policy and parameters for contig_alloc
 * @policy: policy to be used for allocation
 * @pol: policy-specific struct
 */
struct contig_alloc_params {
        enum contig_alloc_policy policy;
        union {
                struct contig_alloc_preferred first;
                struct contig_alloc_least_loaded lloaded;
                struct contig_alloc_balanced balanced;
        } pol;
};

struct contig_alloc_req {
	contig_khandle_t khandle; /* filled in by the kernel */
	struct contig_alloc_params params;
	unsigned long size;
	unsigned long __user *arr;
	void __user *mm; /* user-space only */
	unsigned int n; /* filled in by the kernel */
	int most_allocated; /* filled in by the kernel */
	unsigned int n_max;
};

#define CONTIG_IOC_ALLOC	_IOWR('1', 0, struct contig_alloc_req)
#define CONTIG_IOC_FREE		_IOR ('1', 1, contig_khandle_t)
#define CONTIG_IOC_CHUNK_LOG	_IOW ('1', 2, unsigned long)

#ifdef __KERNEL__

#include <linux/list.h>

struct contig_desc {
	unsigned long *arr;
	dma_addr_t arr_dma_addr;
	unsigned int n;
	int most_allocated;
	struct list_head desc_node;
	struct list_head file_node;
	struct list_head alloc_list;
};

extern struct contig_desc *contig_alloc(const struct contig_alloc_params *params, unsigned long size);
extern void contig_free(struct contig_desc *desc);
extern struct contig_desc *contig_khandle_to_desc(contig_khandle_t khandle);

extern unsigned long contig_chunk_size_log;

#endif /* __KERNEL__ */

#endif /* CONTIG_ALLOC_H */
