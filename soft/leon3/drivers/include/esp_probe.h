/*
 * Copyright (c) 2011-2019 Columbia University, System Level Design Group
 * SPDX-License-Identifier: Apache-2.0
 */

#include <esp_cache.h>
#include <esp_accelerator.h>

#ifdef __riscv
#include <encoding.h>
#include <fdt.h>
#include <uart.h>
#endif

#ifndef __ESP_PROBE_H__
#define __ESP_PROBE_H__

#define VENDOR_SLD 0xEB
#ifdef __sparc
#define APB_BASE_ADDR 0x80000000
#define APB_PLUGNPLAY (APB_BASE_ADDR + 0xff000)
#elif __riscv
#define DTB_ADDRESS 0x10400
#else
#error Unsupported ISA
#endif

/*
 * The number of accelerators depends on how many I/O devices can be addressed.
 * This can be changed by updating the constant NAPBS as explained above, as well
 * as the corresponding constant in
 * <esp>/rtl/include/sld/noc/nocpackage.vhd
 * The following indices  are reserved:
 * 0 - BOOT ROM memory controller
 * 1 - UART
 * 2 - Interrupt controller
 * 3 - Timer
 * 4 - Reserved
 * 5-8 - DVFS controller
 * 9-12 - Processors' private cache controller (must change with NCPU_MAX)
 * 13 - SVGA controller
 * 14 - Ethernet MAC controller
 * 15 - Ethernet SGMII PHY controller
 * 16-19 - LLC cache controller (must change with NMEM_MAX)
 * 20-(NAPBS-1) - Accelerators
 */
#define NAPBSLV 32
#define NACC_MAX 12


#define SLD_L2_CACHE 0x020
#define SLD_LLC_CACHE 0x021

#define DEVNAME_MAX_LEN 32

struct esp_device {
	unsigned vendor;
	unsigned id;
	unsigned number;
	unsigned irq;
	long long unsigned addr;
	unsigned compat;
	char name[DEVNAME_MAX_LEN];
};

extern const char *const coherence_label[5];

int get_pid();
void *aligned_malloc(int size);
void aligned_free(void *ptr);
int probe(struct esp_device **espdevs, unsigned devid, const char *name);
unsigned ioread32(struct esp_device *dev, unsigned offset);
void iowrite32(struct esp_device *dev, unsigned offset, unsigned payload);
void esp_flush(int coherence);
void esp_p2p_init(struct esp_device *dev, struct esp_device **srcs, unsigned nsrcs);

#define esp_get_y(_dev) (YX_MASK_YX & (ioread32(_dev, YX_REG) >> YX_SHIFT_Y))
#define esp_get_x(_dev) (YX_MASK_YX & (ioread32(_dev, YX_REG) >> YX_SHIFT_X))
#define esp_p2p_reset(_dev) iowrite32(_dev, P2P_REG, 0)
#define esp_p2p_enable_dst(_dev) iowrite32(_dev, P2P_REG, ioread32(_dev, P2P_REG) | P2P_MASK_DST_IS_P2P)
#define esp_p2p_enable_src(_dev) iowrite32(_dev, P2P_REG, ioread32(_dev, P2P_REG) | P2P_MASK_SRC_IS_P2P)
#define esp_p2p_set_nsrcs(_dev, _n) iowrite32(_dev, P2P_REG, ioread32(_dev, P2P_REG) | (P2P_MASK_NSRCS & (_n - 1)))
#define esp_p2p_set_y(_dev, _n, _y) iowrite32(_dev, P2P_REG, ioread32(_dev, P2P_REG) | ((P2P_MASK_SRCS_YX & _y) << P2P_SHIFT_SRCS_Y(_n)))
#define esp_p2p_set_x(_dev, _n, _x) iowrite32(_dev, P2P_REG, ioread32(_dev, P2P_REG) | ((P2P_MASK_SRCS_YX & _x) << P2P_SHIFT_SRCS_X(_n)))

#endif /* __ESP_PROBE_H__ */
