// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include <linux/log2.h>
#include <linux/mm.h>
#include <linux/of_device.h>

#include <asm/io.h>

#include <esp.h>
#include <esp_accelerator.h>

#include "nightvision_stratus.h"

#define DRV_NAME "nightvision_stratus"

#define NIGHTVISION_NIMAGES_REG 0x40
#define NIGHTVISION_ROWS_REG    0x44
#define NIGHTVISION_COLS_REG    0x48
#define NIGHTVISION_DO_DWT_REG  0x4C

struct nightvision_stratus_device {
    struct esp_device esp;
};

static struct esp_driver nightvision_driver;

static struct of_device_id nightvision_device_ids[] = {
    {
        .name = "SLD_NIGHTVISION_STRATUS",
    },
    {
        .name = "eb_011",
    },
    {
        .compatible = "sld,nightvision_stratus",
    },
    {},
};

static int nightvision_devs;

static inline struct nightvision_stratus_device *to_nightvision(struct esp_device *esp)
{
    return container_of(esp, struct nightvision_stratus_device, esp);
}

static void nightvision_prep_xfer(struct esp_device *esp, void *arg)
{
    struct nightvision_stratus_access *a = arg;

    iowrite32be(a->nimages, esp->iomem + NIGHTVISION_NIMAGES_REG);
    iowrite32be(a->rows, esp->iomem + NIGHTVISION_ROWS_REG);
    iowrite32be(a->cols, esp->iomem + NIGHTVISION_COLS_REG);
    iowrite32be(a->do_dwt, esp->iomem + NIGHTVISION_DO_DWT_REG);
    iowrite32be(a->src_offset, esp->iomem + SRC_OFFSET_REG);
    iowrite32be(a->dst_offset, esp->iomem + DST_OFFSET_REG);
}

static bool nightvision_xfer_input_ok(struct esp_device *esp, void *arg)
{
    struct nightvision_stratus_access *a = arg;

    if (a->nimages > MAX_NIMAGES)
        return false;

    if (a->rows > MAX_ROWS)
        return false;

    if (a->cols > MAX_COLS)
        return false;

    if (a->do_dwt != 0 && a->do_dwt != 1)
        return false;

    return true;
}

static int nightvision_probe(struct platform_device *pdev)
{
    struct nightvision_stratus_device *nightvision;
    struct esp_device *                esp;
    int                                rc;

    nightvision = kzalloc(sizeof(*nightvision), GFP_KERNEL);
    if (nightvision == NULL)
        return -ENOMEM;
    esp         = &nightvision->esp;
    esp->module = THIS_MODULE;
    esp->number = nightvision_devs;
    esp->driver = &nightvision_driver;
    rc          = esp_device_register(esp, pdev);
    if (rc)
        goto err;

    nightvision_devs++;
    return 0;
err:
    kfree(nightvision);
    return rc;
}

static int __exit nightvision_remove(struct platform_device *pdev)
{
    struct esp_device *                esp         = platform_get_drvdata(pdev);
    struct nightvision_stratus_device *nightvision = to_nightvision(esp);

    esp_device_unregister(esp);
    kfree(nightvision);
    return 0;
}

static struct esp_driver nightvision_driver = {
    .plat =
        {
            .probe  = nightvision_probe,
            .remove = nightvision_remove,
            .driver =
                {
                    .name           = DRV_NAME,
                    .owner          = THIS_MODULE,
                    .of_match_table = nightvision_device_ids,
                },
        },
    .xfer_input_ok = nightvision_xfer_input_ok,
    .prep_xfer     = nightvision_prep_xfer,
    .ioctl_cm      = NIGHTVISION_STRATUS_IOC_ACCESS,
    .arg_size      = sizeof(struct nightvision_stratus_access),
};

static int __init nightvision_init(void) { return esp_driver_register(&nightvision_driver); }

static void __exit nightvision_exit(void) { esp_driver_unregister(&nightvision_driver); }

module_init(nightvision_init) module_exit(nightvision_exit)

    MODULE_DEVICE_TABLE(of, nightvision_device_ids);

MODULE_AUTHOR("Emilio G. Cota <cota@braap.org>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("nightvision_stratus driver");
