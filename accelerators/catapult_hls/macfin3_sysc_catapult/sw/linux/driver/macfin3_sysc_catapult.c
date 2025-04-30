// Copyright (c) 2011-2025 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include <linux/of_device.h>
#include <linux/mm.h>

#include <asm/io.h>

#include <esp_accelerator.h>
#include <esp.h>

#include "macfin3_sysc_catapult.h"

#define DRV_NAME "macfin3_sysc_catapult"

/* <<--regs-->> */
#define MACFIN_MAC_N_REG 0x48
#define MACFIN_MAC_VEC_REG 0x44
#define MACFIN_MAC_LEN_REG 0x40

struct macfin3_sysc_catapult_device {
    struct esp_device esp;
};

static struct esp_driver macfin3_driver;

static struct of_device_id macfin3_device_ids[] = {
    {
        .name = "SLD_MACFIN_SYSC_CATAPULT",
    },
    {
        .name = "eb_04a",
    },
    {
        .compatible = "sld,macfin3_sysc_catapult",
    },
    {},
};

static int macfin3_devs;

static inline struct macfin3_sysc_catapult_device *to_macfin3(struct esp_device *esp)
{
    return container_of(esp, struct macfin3_sysc_catapult_device, esp);
}

static void macfin3_prep_xfer(struct esp_device *esp, void *arg)
{
    struct macfin3_sysc_catapult_access *a = arg;

    /* <<--regs-config-->> */
	iowrite32be(a->mac_n, esp->iomem + MACFIN_MAC_N_REG);
	iowrite32be(a->mac_vec, esp->iomem + MACFIN_MAC_VEC_REG);
	iowrite32be(a->mac_len, esp->iomem + MACFIN_MAC_LEN_REG);
    iowrite32be(a->src_offset, esp->iomem + SRC_OFFSET_REG);
    iowrite32be(a->dst_offset, esp->iomem + DST_OFFSET_REG);
}

static bool macfin3_xfer_input_ok(struct esp_device *esp, void *arg)
{
    /* struct macfin3_sysc_catapult_device *macfin3 = to_macfin3(esp); */
    /* struct macfin3_sysc_catapult_access *a = arg; */

    return true;
}

static int macfin3_probe(struct platform_device *pdev)
{
    struct macfin3_sysc_catapult_device *macfin3;
    struct esp_device *esp;
    int rc;

    macfin3 = kzalloc(sizeof(*macfin3), GFP_KERNEL);
    if (macfin3 == NULL) return -ENOMEM;
    esp         = &macfin3->esp;
    esp->module = THIS_MODULE;
    esp->number = macfin3_devs;
    esp->driver = &macfin3_driver;
    rc          = esp_device_register(esp, pdev);
    if (rc) goto err;

    macfin3_devs++;
    return 0;
err:
    kfree(macfin3);
    return rc;
}

static int __exit macfin3_remove(struct platform_device *pdev)
{
    struct esp_device *esp                        = platform_get_drvdata(pdev);
    struct macfin3_sysc_catapult_device *macfin3 = to_macfin3(esp);

    esp_device_unregister(esp);
    kfree(macfin3);
    return 0;
}

static struct esp_driver macfin3_driver = {
    .plat =
        {
            .probe  = macfin3_probe,
            .remove = macfin3_remove,
            .driver =
                {
                    .name           = DRV_NAME,
                    .owner          = THIS_MODULE,
                    .of_match_table = macfin3_device_ids,
                },
        },
    .xfer_input_ok = macfin3_xfer_input_ok,
    .prep_xfer     = macfin3_prep_xfer,
    .ioctl_cm      = MACFIN_SYSC_CATAPULT_IOC_ACCESS,
    .arg_size      = sizeof(struct macfin3_sysc_catapult_access),
};

static int __init macfin3_init(void)
{
    return esp_driver_register(&macfin3_driver);
}

static void __exit macfin3_exit(void) { esp_driver_unregister(&macfin3_driver); }

module_init(macfin3_init) module_exit(macfin3_exit)

    MODULE_DEVICE_TABLE(of, macfin3_device_ids);

MODULE_AUTHOR("Emilio G. Cota <cota@braap.org>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("macfin3_sysc_catapult driver");
