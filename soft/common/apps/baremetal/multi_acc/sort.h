/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#ifndef __SORT_H__
#define __SORT_H__

#include "multi_acc.h"

#define SLD_SORT   0x0B
#define DEV_NAME_SORT "sld,sort_stratus"

#ifndef LARGE_WORKLOAD
#define SORT_LEN 64
#define SORT_BATCH 2
#else
#define SORT_LEN 512
#define SORT_BATCH 512
#endif

#define SORT_BUF_SIZE (SORT_LEN * SORT_BATCH * sizeof(unsigned))

/* User defined registers */
#define SORT_LEN_REG		0x40
#define SORT_BATCH_REG		0x44
#define SORT_LEN_MIN_REG	0x48
#define SORT_LEN_MAX_REG	0x4c
#define SORT_BATCH_MAX_REG	0x50

static void insertion_sort(float *value, int len);
static int partition(float * array, int low, int high);
int quicksort_inner(float *array, int low, int high);
int quicksort(float *array, int len);
int validate_sorted(float *array, int len);
void init_buf_sort (float *buf, unsigned sort_size, unsigned sort_batch);



#endif // __SORT_H__
