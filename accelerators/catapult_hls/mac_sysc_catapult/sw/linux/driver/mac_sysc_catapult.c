// Copyright (c) 2011-2024 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include <linux/mm.h>
#include <linux/of_device.h>

#include <asm/io.h>

#include <esp.h>
#include <esp_accelerator.h>

#include "mac_sysc_catapult.h"

#define DRV_NAME "mac_sysc_catapult"

/* <<--regs-->> */
#define MAC_MAC_N_REG   0x48
#define MAC_MAC_VEC_REG 0x44
#define MAC_MAC_LEN_REG 0x40

struct mac_sysc_catapult_device {
    struct esp_device esp;
};

static struct esp_driver mac_driver;

static struct of_device_id mac_device_ids[] = {
    {
        .name = "SLD_MAC_SYSC_CATAPULT",
    },
    {
        .name = "eb_04a",
    },
    {
        .compatible = "sld,mac_sysc_catapult",
    },
    {},
};

static int mac_devs;

static inline struct mac_sysc_catapult_device *to_mac(struct esp_device *esp)
{
    return container_of(esp, struct mac_sysc_catapult_device, esp);
}

static void mac_prep_xfer(struct esp_device *esp, void *arg)
{
    struct mac_sysc_catapult_access *a = arg;

    /* <<--regs-config-->> */
    iowrite32be(a->mac_n, esp->iomem + MAC_MAC_N_REG);
    iowrite32be(a->mac_vec, esp->iomem + MAC_MAC_VEC_REG);
    iowrite32be(a->mac_len, esp->iomem + MAC_MAC_LEN_REG);
    iowrite32be(a->src_offset, esp->iomem + SRC_OFFSET_REG);
    iowrite32be(a->dst_offset, esp->iomem + DST_OFFSET_REG);
}

static bool mac_xfer_input_ok(struct esp_device *esp, void *arg)
{
    /* struct mac_sysc_catapult_device *mac = to_mac(esp); */
    /* struct mac_sysc_catapult_access *a = arg; */

    return true;
}

static int mac_probe(struct platform_device *pdev)
{
    struct mac_sysc_catapult_device *mac;
    struct esp_device *esp;
    int rc;

    mac = kzalloc(sizeof(*mac), GFP_KERNEL);
    if (mac == NULL) return -ENOMEM;
    esp         = &mac->esp;
    esp->module = THIS_MODULE;
    esp->number = mac_devs;
    esp->driver = &mac_driver;
    rc          = esp_device_register(esp, pdev);
    if (rc) goto err;

    mac_devs++;
    return 0;
err:
    kfree(mac);
    return rc;
}

static int __exit mac_remove(struct platform_device *pdev)
{
    struct esp_device *esp               = platform_get_drvdata(pdev);
    struct mac_sysc_catapult_device *mac = to_mac(esp);

    esp_device_unregister(esp);
    kfree(mac);
    return 0;
}

static struct esp_driver mac_driver = {
    .plat =
        {
            .probe  = mac_probe,
            .remove = mac_remove,
            .driver =
                {
                    .name           = DRV_NAME,
                    .owner          = THIS_MODULE,
                    .of_match_table = mac_device_ids,
                },
        },
    .xfer_input_ok = mac_xfer_input_ok,
    .prep_xfer     = mac_prep_xfer,
    .ioctl_cm      = MAC_SYSC_CATAPULT_IOC_ACCESS,
    .arg_size      = sizeof(struct mac_sysc_catapult_access),
};

static int __init mac_init(void) { return esp_driver_register(&mac_driver); }

static void __exit mac_exit(void) { esp_driver_unregister(&mac_driver); }

module_init(mac_init) module_exit(mac_exit)

    MODULE_DEVICE_TABLE(of, mac_device_ids);

MODULE_AUTHOR("Emilio G. Cota <cota@braap.org>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("mac_sysc_catapult driver");
