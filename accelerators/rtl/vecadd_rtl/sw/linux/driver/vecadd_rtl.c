// Copyright (c) 2011-2025 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include <linux/of_device.h>
#include <linux/mm.h>

#include <asm/io.h>

#include <esp_accelerator.h>
#include <esp.h>

#include "vecadd_rtl.h"

#define DRV_NAME "vecadd_rtl"

/* <<--regs-->> */
#define VECADD_VECTOR_SIZE_REG 0x40
#define VECADD_CHUNK_SIZE_REG  0x44

struct vecadd_rtl_device {
    struct esp_device esp;
};

static struct esp_driver vecadd_driver;

static struct of_device_id vecadd_device_ids[] = {
    {
        .name = "SLD_VECADD",
    },
    {
        .name = "eb_0a0",
    },
    {
        .compatible = "sld,vecadd_rtl",
    },
    {},
};

static int vecadd_devs;

static inline struct vecadd_rtl_device *to_vecadd(struct esp_device *esp)
{
    return container_of(esp, struct vecadd_rtl_device, esp);
}

static void vecadd_prep_xfer(struct esp_device *esp, void *arg)
{
    struct vecadd_rtl_access *a = arg;

    /* <<--regs-config-->> */
    iowrite32be(a->vector_size, esp->iomem + VECADD_VECTOR_SIZE_REG);
    iowrite32be(a->chunk_size, esp->iomem + VECADD_CHUNK_SIZE_REG);
    iowrite32be(a->src_offset, esp->iomem + SRC_OFFSET_REG);
    iowrite32be(a->dst_offset, esp->iomem + DST_OFFSET_REG);
}

static bool vecadd_xfer_input_ok(struct esp_device *esp, void *arg)
{
    /* struct vecadd_rtl_device *vecadd = to_vecadd(esp); */
    /* struct vecadd_rtl_access *a = arg; */

    return true;
}

static int vecadd_probe(struct platform_device *pdev)
{
    struct vecadd_rtl_device *vecadd;
    struct esp_device *esp;
    int rc;

    vecadd = kzalloc(sizeof(*vecadd), GFP_KERNEL);
    if (vecadd == NULL) return -ENOMEM;
    esp         = &vecadd->esp;
    esp->module = THIS_MODULE;
    esp->number = vecadd_devs;
    esp->driver = &vecadd_driver;
    rc          = esp_device_register(esp, pdev);
    if (rc) goto err;

    vecadd_devs++;
    return 0;
err:
    kfree(vecadd);
    return rc;
}

static int __exit vecadd_remove(struct platform_device *pdev)
{
    struct esp_device *esp             = platform_get_drvdata(pdev);
    struct vecadd_rtl_device *vecadd   = to_vecadd(esp);

    esp_device_unregister(esp);
    kfree(vecadd);
    return 0;
}

static struct esp_driver vecadd_driver = {
    .plat =
        {
            .probe  = vecadd_probe,
            .remove = vecadd_remove,
            .driver =
                {
                    .name           = DRV_NAME,
                    .owner          = THIS_MODULE,
                    .of_match_table = vecadd_device_ids,
                },
        },
    .xfer_input_ok = vecadd_xfer_input_ok,
    .prep_xfer     = vecadd_prep_xfer,
    .ioctl_cm      = VECADD_RTL_IOC_ACCESS,
    .arg_size      = sizeof(struct vecadd_rtl_access),
};

static int __init vecadd_init(void) { return esp_driver_register(&vecadd_driver); }

static void __exit vecadd_exit(void) { esp_driver_unregister(&vecadd_driver); }

module_init(vecadd_init) module_exit(vecadd_exit)

    MODULE_DEVICE_TABLE(of, vecadd_device_ids);

MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("vecadd_rtl driver");
