// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include <linux/of_device.h>
#include <linux/mm.h>
#include <linux/log2.h>

#include <asm/io.h>

#include <esp_accelerator.h>
#include <esp.h>

#include "adder_vivado.h"

#define DRV_NAME	"adder_vivado"

#define ADDER_NBURSTS_REG 0x40

struct adder_vivado_device {
	struct esp_device esp;
};

static struct esp_driver adder_driver;

static struct of_device_id adder_device_ids[] = {
	{
		.name = "SLD_ADDER_VIVADO",
	},
	{
		.name = "eb_040",
	},
	{
		.compatible = "sld,adder_vivado",
	},
	{ },
};

static int adder_devs;

static inline struct adder_vivado_device *to_adder(struct esp_device *esp)
{
	return container_of(esp, struct adder_vivado_device, esp);
}

static void adder_prep_xfer(struct esp_device *esp, void *arg)
{
	struct adder_vivado_access *a = arg;

	iowrite32be(a->nbursts, esp->iomem + ADDER_NBURSTS_REG);
}

static bool adder_xfer_input_ok(struct esp_device *esp, void *arg)
{
	return true;
}

static int adder_probe(struct platform_device *pdev)
{
	struct adder_vivado_device *adder;
	struct esp_device *esp;
	int rc;

	adder = kzalloc(sizeof(*adder), GFP_KERNEL);
	if (adder == NULL)
		return -ENOMEM;
	esp = &adder->esp;
	esp->module = THIS_MODULE;
	esp->number = adder_devs;
	esp->driver = &adder_driver;
	rc = esp_device_register(esp, pdev);
	if (rc)
		goto err;

	adder_devs++;
	return 0;
 err:
	kfree(adder);
	return rc;
}

static int __exit adder_remove(struct platform_device *pdev)
{
	struct esp_device *esp = platform_get_drvdata(pdev);
	struct adder_vivado_device *adder = to_adder(esp);

	esp_device_unregister(esp);
	kfree(adder);
	return 0;
}

static struct esp_driver adder_driver = {
	.plat = {
		.probe		= adder_probe,
		.remove		= adder_remove,
		.driver		= {
			.name = DRV_NAME,
			.owner = THIS_MODULE,
			.of_match_table = adder_device_ids,
		},
	},
	.xfer_input_ok	= adder_xfer_input_ok,
	.prep_xfer	= adder_prep_xfer,
	.ioctl_cm	= ADDER_VIVADO_IOC_ACCESS,
	.arg_size	= sizeof(struct adder_vivado_access),
};

static int __init adder_init(void)
{
	return esp_driver_register(&adder_driver);
}

static void __exit adder_exit(void)
{
	esp_driver_unregister(&adder_driver);
}

module_init(adder_init)
module_exit(adder_exit)

MODULE_DEVICE_TABLE(of, adder_device_ids);

MODULE_AUTHOR("Emilio G. Cota <cota@braap.org>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("adder_vivado driver");
