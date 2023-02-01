/*
 * Copyright (c) 2011-2023 Columbia University, System Level Design Group
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef ESP_CACHE_H
#define ESP_CACHE_H

#define ESP_CACHE_REG_CMD	0x00
#define ESP_CACHE_REG_STATUS	0x04

#define ESP_CACHE_CMD_RESET_BIT	0
#define ESP_CACHE_CMD_FLUSH_BIT	1
#define ESP_CACHE_CMD_FLUSH_INST_BIT 2

#define ESP_CACHE_STATUS_DONE_MASK   0x1
#define ESP_CACHE_STATUS_CPUID_MASK  0xf0000000
#define ESP_CACHE_STATUS_CPUID_SHIFT 28

#ifdef __KERNEL__
#include <linux/types.h>
#else
#include <stdint.h>
#define ASI_LEON_DFLUSH 0x11
#define CACHELINE_SIZE 0x10
#endif /* __KERNEL__ */


#ifdef __KERNEL__

#include <linux/platform_device.h>
#include <linux/completion.h>
#include <linux/device.h>
#include <linux/module.h>
#include <linux/mutex.h>
#include <linux/list.h>
#include <linux/spinlock.h>
#include <linux/interrupt.h>
#include <linux/slab.h>
#include <linux/of_device.h>
#include <linux/of_platform.h>
#include <asm/io.h>
#include <asm/uaccess.h>

int esp_cache_flush(void);
int esp_private_cache_flush(void);
int esp_private_cache_flush_smp(void);

#ifdef __riscv
#undef ioread32be
#define ioread32be ioread32
#undef iowrite32be
#define iowrite32be iowrite32
#endif

#endif /* __KERNEL__ */

#endif /* ESP_CACHE_H */
