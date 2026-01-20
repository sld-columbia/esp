// Copyright (c) 2011-2025 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include <linux/of_device.h>
#include <linux/mm.h>

#include <asm/io.h>

#include <esp_accelerator.h>
#include <esp.h>

#include "conv1d_sysc_catapult.h"

#define DRV_NAME "conv1d_sysc_catapult"

/* <<--regs-->> */
#define CONV1D_KERNEL_SIZE_REG 0x6c
#define CONV1D_N_CHANNELS_REG 0x68
#define CONV1D_STRIDE_REG 0x64
#define CONV1D_IS_RELU_REG 0x60
#define CONV1D_ADDRB_REG 0x5c
#define CONV1D_ADDRO_REG 0x58
#define CONV1D_ADDRI_REG 0x54
#define CONV1D_ADDRW_REG 0x50
#define CONV1D_BATCH_SIZE_REG 0x4c
#define CONV1D_N_FILTERS_REG 0x48
#define CONV1D_FEATURE_MAP_LEN_REG 0x44
#define CONV1D_PADDING_REG 0x40

struct conv1d_sysc_catapult_device {
    struct esp_device esp;
};

static struct esp_driver conv1d_driver;

static struct of_device_id conv1d_device_ids[] = {
    {
        .name = "SLD_CONV1D_SYSC_CATAPULT",
    },
    {
        .name = "eb_099",
    },
    {
        .compatible = "sld,conv1d_sysc_catapult",
    },
    {},
};

static int conv1d_devs;

static inline struct conv1d_sysc_catapult_device *to_conv1d(struct esp_device *esp)
{
    return container_of(esp, struct conv1d_sysc_catapult_device, esp);
}

static void conv1d_prep_xfer(struct esp_device *esp, void *arg)
{
    struct conv1d_sysc_catapult_access *a = arg;

    /* <<--regs-config-->> */
	iowrite32be(a->kernel_size, esp->iomem + CONV1D_KERNEL_SIZE_REG);
	iowrite32be(a->n_channels, esp->iomem + CONV1D_N_CHANNELS_REG);
	iowrite32be(a->stride, esp->iomem + CONV1D_STRIDE_REG);
	iowrite32be(a->is_relu, esp->iomem + CONV1D_IS_RELU_REG);
	iowrite32be(a->addrB, esp->iomem + CONV1D_ADDRB_REG);
	iowrite32be(a->addrO, esp->iomem + CONV1D_ADDRO_REG);
	iowrite32be(a->addrI, esp->iomem + CONV1D_ADDRI_REG);
	iowrite32be(a->addrW, esp->iomem + CONV1D_ADDRW_REG);
	iowrite32be(a->batch_size, esp->iomem + CONV1D_BATCH_SIZE_REG);
	iowrite32be(a->n_filters, esp->iomem + CONV1D_N_FILTERS_REG);
	iowrite32be(a->feature_map_len, esp->iomem + CONV1D_FEATURE_MAP_LEN_REG);
	iowrite32be(a->padding, esp->iomem + CONV1D_PADDING_REG);
    iowrite32be(a->src_offset, esp->iomem + SRC_OFFSET_REG);
    iowrite32be(a->dst_offset, esp->iomem + DST_OFFSET_REG);
}

static bool conv1d_xfer_input_ok(struct esp_device *esp, void *arg)
{
    /* struct conv1d_sysc_catapult_device *conv1d = to_conv1d(esp); */
    /* struct conv1d_sysc_catapult_access *a = arg; */

    return true;
}

static int conv1d_probe(struct platform_device *pdev)
{
    struct conv1d_sysc_catapult_device *conv1d;
    struct esp_device *esp;
    int rc;

    conv1d = kzalloc(sizeof(*conv1d), GFP_KERNEL);
    if (conv1d == NULL) return -ENOMEM;
    esp         = &conv1d->esp;
    esp->module = THIS_MODULE;
    esp->number = conv1d_devs;
    esp->driver = &conv1d_driver;
    rc          = esp_device_register(esp, pdev);
    if (rc) goto err;

    conv1d_devs++;
    return 0;
err:
    kfree(conv1d);
    return rc;
}

static int __exit conv1d_remove(struct platform_device *pdev)
{
    struct esp_device *esp                        = platform_get_drvdata(pdev);
    struct conv1d_sysc_catapult_device *conv1d = to_conv1d(esp);

    esp_device_unregister(esp);
    kfree(conv1d);
    return 0;
}

static struct esp_driver conv1d_driver = {
    .plat =
        {
            .probe  = conv1d_probe,
            .remove = conv1d_remove,
            .driver =
                {
                    .name           = DRV_NAME,
                    .owner          = THIS_MODULE,
                    .of_match_table = conv1d_device_ids,
                },
        },
    .xfer_input_ok = conv1d_xfer_input_ok,
    .prep_xfer     = conv1d_prep_xfer,
    .ioctl_cm      = CONV1D_SYSC_CATAPULT_IOC_ACCESS,
    .arg_size      = sizeof(struct conv1d_sysc_catapult_access),
};

static int __init conv1d_init(void)
{
    return esp_driver_register(&conv1d_driver);
}

static void __exit conv1d_exit(void) { esp_driver_unregister(&conv1d_driver); }

module_init(conv1d_init) module_exit(conv1d_exit)

    MODULE_DEVICE_TABLE(of, conv1d_device_ids);

MODULE_AUTHOR("Emilio G. Cota <cota@braap.org>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("conv1d_sysc_catapult driver");
