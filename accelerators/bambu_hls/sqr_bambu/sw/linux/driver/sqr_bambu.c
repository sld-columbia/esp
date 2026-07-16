// Copyright (c) 2011-2026 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include <linux/of_device.h>
#include <linux/mm.h>

#include <asm/io.h>

#include <esp_accelerator.h>
#include <esp.h>

#include "sqr_bambu.h"

#define DRV_NAME "sqr_bambu"

/* <<--regs-->> */
#define SQR_SIZE_REG 0x40

struct sqr_bambu_device {
    struct esp_device esp;
};

static struct esp_driver sqr_driver;

static struct of_device_id sqr_device_ids[] = {
    {
        .name = "SLD_SQR_BAMBU",
    },
    {
        .name = "eb_07a",
    },
    {
        .compatible = "sld,sqr_bambu",
    },
    {},
};

static int sqr_devs;

static inline struct sqr_bambu_device *to_sqr(struct esp_device *esp)
{
    return container_of(esp, struct sqr_bambu_device, esp);
}

static void sqr_prep_xfer(struct esp_device *esp, void *arg)
{
    struct sqr_bambu_access *a = arg;

    /* <<--regs-config-->> */
    iowrite32be(a->size, esp->iomem + SQR_SIZE_REG);
    iowrite32be(a->src_offset, esp->iomem + SRC_OFFSET_REG);
    iowrite32be(a->dst_offset, esp->iomem + DST_OFFSET_REG);
}

static bool sqr_xfer_input_ok(struct esp_device *esp, void *arg)
{
    /* struct sqr_bambu_device *sqr = to_sqr(esp); */
    /* struct sqr_bambu_access *a = arg; */

    return true;
}

static int sqr_probe(struct platform_device *pdev)
{
    struct sqr_bambu_device *sqr;
    struct esp_device *esp;
    int rc;

    sqr = kzalloc(sizeof(*sqr), GFP_KERNEL);
    if (sqr == NULL) return -ENOMEM;
    esp         = &sqr->esp;
    esp->module = THIS_MODULE;
    esp->number = sqr_devs;
    esp->driver = &sqr_driver;
    rc          = esp_device_register(esp, pdev);
    if (rc) goto err;

    sqr_devs++;
    return 0;
err:
    kfree(sqr);
    return rc;
}

static int __exit sqr_remove(struct platform_device *pdev)
{
    struct esp_device *esp       = platform_get_drvdata(pdev);
    struct sqr_bambu_device *sqr = to_sqr(esp);

    esp_device_unregister(esp);
    kfree(sqr);
    return 0;
}

static struct esp_driver sqr_driver = {
    .plat =
        {
            .probe  = sqr_probe,
            .remove = sqr_remove,
            .driver =
                {
                    .name           = DRV_NAME,
                    .owner          = THIS_MODULE,
                    .of_match_table = sqr_device_ids,
                },
        },
    .xfer_input_ok = sqr_xfer_input_ok,
    .prep_xfer     = sqr_prep_xfer,
    .ioctl_cm      = SQR_BAMBU_IOC_ACCESS,
    .arg_size      = sizeof(struct sqr_bambu_access),
};

static int __init sqr_init(void) { return esp_driver_register(&sqr_driver); }

static void __exit sqr_exit(void) { esp_driver_unregister(&sqr_driver); }

module_init(sqr_init) module_exit(sqr_exit)

    MODULE_DEVICE_TABLE(of, sqr_device_ids);

MODULE_AUTHOR("Emilio G. Cota <cota@braap.org>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("sqr_bambu driver");
