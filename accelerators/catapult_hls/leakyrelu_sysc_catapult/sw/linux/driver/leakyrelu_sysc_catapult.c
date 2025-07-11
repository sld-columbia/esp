// Copyright (c) 2011-2024 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include <linux/of_device.h>
#include <linux/mm.h>

#include <asm/io.h>

#include <esp_accelerator.h>
#include <esp.h>

#include "leakyrelu_sysc_catapult.h"

#define DRV_NAME	"leakyrelu_sysc_catapult"

/* <<--regs-->> */
#define LEAKY_ADDRO_REG 0x50
#define LEAKY_ADDRB_REG 0x4c
#define LEAKY_ADDRA_REG 0x48
#define LEAKY_ROW_REG 0x44
#define LEAKY_BATCH_REG 0x40

struct leakyrelu_sysc_catapult_device {
	struct esp_device esp;
};

static struct esp_driver leakyrelu_driver;

static struct of_device_id leakyrelu_device_ids[] = {
	{
		.name = "SLD_LEAKYRELU_SYSC_CATAPULT",
	},
	{
		.name = "eb_777",
	},
	{
		.compatible = "sld,leakyrelu_sysc_catapult",
	},
	{ },
};

static int leakyrelu_devs;

static inline struct leakyrelu_sysc_catapult_device *to_mac(struct esp_device *esp)
{
	return container_of(esp, struct leakyrelu_sysc_catapult_device, esp);
}

static void leakyrelu_prep_xfer(struct esp_device *esp, void *arg)
{
	struct leakyrelu_sysc_catapult_access *a = arg;

	/* <<--regs-config-->> */
	iowrite32be(a->batch, esp->iomem + LEAKY_BATCH_REG);
	iowrite32be(a->row, esp->iomem + LEAKY_ROW_REG);
	iowrite32be(a->addrA, esp->iomem + LEAKY_ADDRA_REG);
	iowrite32be(a->addrB, esp->iomem + LEAKY_ADDRB_REG);
	iowrite32be(a->addrO, esp->iomem + LEAKY_ADDRO_REG);
	iowrite32be(a->src_offset, esp->iomem + SRC_OFFSET_REG);
	iowrite32be(a->dst_offset, esp->iomem + DST_OFFSET_REG);

}

static bool leakyrelu_xfer_input_ok(struct esp_device *esp, void *arg)
{
	/* struct leakyrelu_sysc_catapult_device *mac = to_mac(esp); */
	/* struct leakyrelu_sysc_catapult_access *a = arg; */

	return true;
}

static int leakyrelu_probe(struct platform_device *pdev)
{
	struct leakyrelu_sysc_catapult_device *mac;
	struct esp_device *esp;
	int rc;

	mac = kzalloc(sizeof(*mac), GFP_KERNEL);
	if (mac == NULL)
		return -ENOMEM;
	esp = &mac->esp;
	esp->module = THIS_MODULE;
	esp->number = leakyrelu_devs;
	esp->driver = &leakyrelu_driver;
	rc = esp_device_register(esp, pdev);
	if (rc)
		goto err;

	leakyrelu_devs++;
	return 0;
 err:
	kfree(mac);
	return rc;
}

static int __exit leakyrelu_remove(struct platform_device *pdev)
{
	struct esp_device *esp = platform_get_drvdata(pdev);
	struct leakyrelu_sysc_catapult_device *mac = to_mac(esp);

	esp_device_unregister(esp);
	kfree(mac);
	return 0;
}

static struct esp_driver leakyrelu_driver = {
	.plat = {
		.probe		= leakyrelu_probe,
		.remove		= leakyrelu_remove,
		.driver		= {
			.name = DRV_NAME,
			.owner = THIS_MODULE,
			.of_match_table = leakyrelu_device_ids,
		},
	},
	.xfer_input_ok	= leakyrelu_xfer_input_ok,
	.prep_xfer	= leakyrelu_prep_xfer,
	.ioctl_cm	= leakyrelu_SYSC_CATAPULT_IOC_ACCESS,
	.arg_size	= sizeof(struct leakyrelu_sysc_catapult_access),
};

static int __init leakyrelu_init(void)
{
	return esp_driver_register(&leakyrelu_driver);
}

static void __exit leakyrelu_exit(void)
{
	esp_driver_unregister(&leakyrelu_driver);
}

module_init(leakyrelu_init)
module_exit(leakyrelu_exit)

MODULE_DEVICE_TABLE(of, leakyrelu_device_ids);

MODULE_AUTHOR("Emilio G. Cota <cota@braap.org>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("leakyrelu_sysc_catapult driver");
