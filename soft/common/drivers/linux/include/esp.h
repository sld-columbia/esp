/*
 * Copyright (c) 2011-2023 Columbia University, System Level Design Group
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef ESP_H
#define ESP_H

#include <contig_alloc.h>
#include <esp_accelerator.h>
#include <esp_cache.h>
#ifdef __KERNEL__
#include <linux/ioctl.h>
#include <linux/types.h>
#else
#include <sys/ioctl.h>
#include <stdint.h>
#endif /* __KERNEL__ */

/* embed this struct at the beginning of the access struct */
struct esp_access {
	contig_khandle_t contig;
	uint8_t run;
	uint8_t p2p_store;
	uint8_t p2p_nsrcs;
	char p2p_srcs[4][64];
	enum accelerator_coherence coherence;
        unsigned int footprint;
        enum contig_alloc_policy alloc_policy;
        unsigned int ddr_node;
	unsigned int in_place;
	unsigned int reuse_factor;
};

#define ESP_IOC_RUN _IO('E', 0)
#define ESP_IOC_FLUSH _IO('E', 1)

#ifdef __KERNEL__

#include <linux/platform_device.h>
#include <linux/completion.h>
#include <linux/device.h>
#include <linux/module.h>
#include <linux/mutex.h>
#include <linux/cdev.h>
#include <linux/list.h>

// TO DO do not hard-code this values
#define N_MEM 8
#define PRIVATE_CACHE_SIZE 16384
#define LLC_SIZE 524288
#define LLC_SIZE_SPLIT 262144 


struct esp_device;

struct esp_driver {
	struct class *class;
	dev_t devno;
	/* the below are filled in by drivers */
	struct platform_driver plat;
	bool (*xfer_input_ok)(struct esp_device *esp, void *arg);
	void (*prep_xfer)(struct esp_device *esp, void *arg);
	unsigned int ioctl_cm;
	size_t arg_size;
};

struct esp_device {
	struct list_head list;
	struct cdev cdev;
	struct device *pdev; /* parent device */
	struct device *dev; /* associated device */
	struct mutex lock;
	struct completion completion;
	void __iomem *iomem; /* mmapped registers */
	int irq;
	int err;
	/* the below are filled in by drivers */
	struct esp_driver *driver;
	struct module *module;
	int number;
	enum accelerator_coherence coherence;
        unsigned int footprint;
        enum contig_alloc_policy alloc_policy;
        unsigned int ddr_node;
	unsigned int in_place;
	unsigned int reuse_factor;
};

struct esp_status {
	struct mutex lock;
	unsigned int active_acc_cnt;
	unsigned int active_acc_cnt_full; 
	unsigned int active_footprint;
	unsigned int active_footprint_split[N_MEM]; // 2 mem ctrl
};

int esp_driver_register(struct esp_driver *driver);
void esp_driver_unregister(struct esp_driver *driver);
int esp_device_register(struct esp_device *esp, struct platform_device *pdev);
void esp_device_unregister(struct esp_device *device);

#endif /* __KERNEL__ */

#endif /* ESP_H */
