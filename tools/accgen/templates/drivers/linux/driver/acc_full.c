// Copyright (c) 2011-2025 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include <linux/of_device.h>
#include <linux/mm.h>

#include <asm/io.h>

#include <esp_accelerator.h>
#include <esp.h>

#include "acc_full_name.h"

#define DRV_NAME "acc_full_name"

/* <<--regs-->> */

struct acc_full_name_device {
    struct esp_device esp;
};

static struct esp_driver accelerator_name_driver;

static struct of_device_id accelerator_name_device_ids[] = {
    {
        .name = "SLD_ACC_FULL_NAME",
    },
    {
        .name = "eb_/* <<--id-->> */",
    },
    {
        .compatible = "sld,acc_full_name",
    },
    {},
};

static int accelerator_name_devs;

static inline struct acc_full_name_device *to_accelerator_name(struct esp_device *esp)
{
    return container_of(esp, struct acc_full_name_device, esp);
}

static void accelerator_name_prep_xfer(struct esp_device *esp, void *arg)
{
    struct acc_full_name_access *a = arg;

    /* <<--regs-config-->> */
    iowrite32be(a->src_offset, esp->iomem + SRC_OFFSET_REG);
    iowrite32be(a->dst_offset, esp->iomem + DST_OFFSET_REG);
}

static bool accelerator_name_xfer_input_ok(struct esp_device *esp, void *arg)
{
    /* struct acc_full_name_device *accelerator_name = to_accelerator_name(esp); */
    /* struct acc_full_name_access *a = arg; */

    return true;
}

static int accelerator_name_probe(struct platform_device *pdev)
{
    struct acc_full_name_device *accelerator_name;
    struct esp_device *esp;
    int rc;

    accelerator_name = kzalloc(sizeof(*accelerator_name), GFP_KERNEL);
    if (accelerator_name == NULL) return -ENOMEM;
    esp         = &accelerator_name->esp;
    esp->module = THIS_MODULE;
    esp->number = accelerator_name_devs;
    esp->driver = &accelerator_name_driver;
    rc          = esp_device_register(esp, pdev);
    if (rc) goto err;

    accelerator_name_devs++;
    return 0;
err:
    kfree(accelerator_name);
    return rc;
}

static int __exit accelerator_name_remove(struct platform_device *pdev)
{
    struct esp_device *esp                        = platform_get_drvdata(pdev);
    struct acc_full_name_device *accelerator_name = to_accelerator_name(esp);

    esp_device_unregister(esp);
    kfree(accelerator_name);
    return 0;
}

static struct esp_driver accelerator_name_driver = {
    .plat =
        {
            .probe  = accelerator_name_probe,
            .remove = accelerator_name_remove,
            .driver =
                {
                    .name           = DRV_NAME,
                    .owner          = THIS_MODULE,
                    .of_match_table = accelerator_name_device_ids,
                },
        },
    .xfer_input_ok = accelerator_name_xfer_input_ok,
    .prep_xfer     = accelerator_name_prep_xfer,
    .ioctl_cm      = ACC_FULL_NAME_IOC_ACCESS,
    .arg_size      = sizeof(struct acc_full_name_access),
};

static int __init accelerator_name_init(void)
{
    return esp_driver_register(&accelerator_name_driver);
}

static void __exit accelerator_name_exit(void) { esp_driver_unregister(&accelerator_name_driver); }

module_init(accelerator_name_init) module_exit(accelerator_name_exit)

    MODULE_DEVICE_TABLE(of, accelerator_name_device_ids);

MODULE_AUTHOR("Emilio G. Cota <cota@braap.org>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("acc_full_name driver");
