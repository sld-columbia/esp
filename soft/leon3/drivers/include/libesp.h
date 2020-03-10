/*
 * Copyright (c) 2011-2019 Columbia University, System Level Design Group
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef __ESPLIB_H__
#define __ESPLIB_H__
#include <assert.h>
#include <fcntl.h>
#include <math.h>
#include <pthread.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "my_stringify.h"
#include "fixed_point.h"
#include "contig.h"
#include "esp.h"
#include "test/time.h"
#include "test/test.h"

#include <esp.h>
#include <esp_accelerator.h>

// <<--esp-include-->>
#include "vitdodec.h"
#include "FFTAccelerator.h"
#include "AdderAccelerator.h"
#include "fft.h"
#include "adder.h"
#include "CounterAccelerator.h"
#include "dummy.h"
#include "sort.h"
#include "spmv.h"
#include "synth.h"
#include "visionchip.h"
#include "vitbfly2.h"

unsigned DMA_WORD_PER_BEAT(unsigned _st);

enum esp_accelerator_type {
	// <<--esp-enum-->>
	vitdodec,
	fftaccelerator,
	adderaccelerator,
	fft,
	adder,
	CounterAccelerator,
	dummy,
	sort,
	spmv,
	synth,
	visionchip,
	vitbfly2,
};

union esp_accelerator_descriptor {
	// <<--esp-descriptor-->>
	struct vitdodec_access vitdodec_desc;
	struct fftaccelerator_access fftaccelerator_desc;
	struct adderaccelerator_access adderaccelerator_desc;
	struct fft_access fft_desc;
	struct adder_access adder_desc;
	struct CounterAccelerator_access CounterAccelerator_desc;
	struct dummy_access dummy_desc;
	struct sort_access sort_desc;
	struct spmv_access spmv_desc;
	struct synth_access synth_desc;
	struct visionchip_access visionchip_desc;
	struct vitbfly2_access vitbfly2_desc;
};

struct esp_accelerator_thread_info {
	bool run;
	char *devname;
	enum esp_accelerator_type type;
    void *hw_buf;
    /* Partially Filled-in by ESPLIB */
	union esp_accelerator_descriptor desc;
	/* Filled-in by ESPLIB */
	int fd;
	unsigned long long hw_ns;
};

typedef struct esp_accelerator_thread_info esp_thread_info_t;

typedef struct buf2handle_node {
    void *buf;
    contig_handle_t *handle;
    enum contig_alloc_policy policy;
    struct buf2handle_node *next;
} buf2handle_node;

struct thread_args {
    esp_thread_info_t* info; 
    unsigned nacc; 
};

void *esp_alloc_policy(struct contig_alloc_params params, size_t size);
void *esp_alloc(size_t size);
void esp_run_parallel(esp_thread_info_t* cfg[], unsigned nthreads, unsigned* nacc);
void esp_run(esp_thread_info_t cfg[], unsigned nacc);
void esp_free(void *buf);

#endif /* __ESPLIB_H__ */
