/*
 * Copyright (c) 2011-2024 Columbia University, System Level Design Group
 * SPDX-License-Identifier: Apache-2.0
 */

#include <esp_accelerator.h>
#include <esp_cache.h>

#ifdef __riscv
    #include <encoding.h>
    #include <fdt.h>
    #include <uart.h>
#endif

#include "esplink.h"

#ifndef __ESP_PROBE_H__
    #define __ESP_PROBE_H__

    #ifdef __sparc
        #define APB_BASE_ADDR 0x80000000
        #define APB_PLUGNPLAY (APB_BASE_ADDR + 0xff000)
    #elif __riscv
        #define DTB_ADDRESS RODATA_START_ADDR
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
     * 84-(NAPBS-1) - Accelerators
     */
    #define NAPBSLV  128
    #define NACC_MAX 44

    #define VENDOR_SLD 0xEB

    #define SLD_L2_CACHE  0x020
    #define SLD_LLC_CACHE 0x021

    #define VENDOR_UIUC 0xEE

    #define UIUC_SPANDEX_L2  0x020
    #define UIUC_SPANDEX_LLC 0x021

    #ifdef USE_SPANDEX
        #define VENDOR_CACHE      VENDOR_UIUC
        #define DEVID_L2_CACHE    UIUC_SPANDEX_L2
        #define DEVID_LLC_CACHE   UIUC_SPANDEX_LLC
        #define DEVNAME_L2_CACHE  "uiuc,spandex_l2"
        #define DEVNAME_LLC_CACHE "uiuc,spandex_llc"
    #else
        #define VENDOR_CACHE      VENDOR_SLD
        #define DEVID_L2_CACHE    SLD_L2_CACHE
        #define DEVID_LLC_CACHE   SLD_LLC_CACHE
        #define DEVNAME_L2_CACHE  "sld,l2_cache"
        #define DEVNAME_LLC_CACHE "sld,llc_cache"
    #endif

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
int probe(struct esp_device **espdevs, unsigned vendor, unsigned devid, const char *name);
unsigned ioread32(struct esp_device *dev, unsigned offset);
void iowrite32(struct esp_device *dev, unsigned offset, unsigned payload);
void esp_flush(int coherence);
void esp_p2p_init(struct esp_device *dev, struct esp_device **srcs, unsigned nsrcs);

    #define esp_get_y(_dev)     (YX_MASK_YX & (ioread32(_dev, YX_REG) >> YX_SHIFT_Y))
    #define esp_get_x(_dev)     (YX_MASK_YX & (ioread32(_dev, YX_REG) >> YX_SHIFT_X))
    #define esp_p2p_reset(_dev) iowrite32(_dev, P2P_REG, 0)
    #define esp_p2p_enable_dst(_dev) \
        iowrite32(_dev, P2P_REG, ioread32(_dev, P2P_REG) | P2P_MASK_DST_IS_P2P)
    #define esp_p2p_enable_src(_dev) \
        iowrite32(_dev, P2P_REG, ioread32(_dev, P2P_REG) | P2P_MASK_SRC_IS_P2P)
    #define esp_p2p_set_nsrcs(_dev, _n) \
        iowrite32(_dev, P2P_REG, ioread32(_dev, P2P_REG) | (P2P_MASK_NSRCS & (_n - 1)))
    #define esp_p2p_set_y(_dev, _n, _y) \
        iowrite32(_dev, P2P_REG,        \
                  ioread32(_dev, P2P_REG) | ((P2P_MASK_SRCS_YX & _y) << P2P_SHIFT_SRCS_Y(_n)))
    #define esp_p2p_set_x(_dev, _n, _x) \
        iowrite32(_dev, P2P_REG,        \
                  ioread32(_dev, P2P_REG) | ((P2P_MASK_SRCS_YX & _x) << P2P_SHIFT_SRCS_X(_n)))

#endif /* __ESP_PROBE_H__ */
