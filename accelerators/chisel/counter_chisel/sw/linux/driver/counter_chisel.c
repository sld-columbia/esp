// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include <linux/of_device.h>
#include <linux/mm.h>

#include <asm/io.h>

#include <esp_accelerator.h>
#include <esp.h>

#include "counter_chisel.h"

#define DRV_NAME	"counter_chisel"

#define COUNTER_GITHASH_REG		0x40
#define COUNTER_TICKS_REG		0x44

struct counter_chisel_device {
	struct esp_device esp;
};

static struct esp_driver counter_driver;

static struct of_device_id counter_device_ids[] = {
	{
		.name = "SLD_COUNTER_CHISEL",
	},
	{
		.name = "eb_012",
	},
	{
		.compatible = "sld,counter_chisel",
	},
	{ },
};

static int counter_devs;

static inline struct counter_chisel_device *to_counter(struct esp_device *esp)
{
	return container_of(esp, struct counter_chisel_device, esp);
}

static void counter_prep_xfer(struct esp_device *esp, void *arg)
{
	struct counter_chisel_access *a = arg;

	iowrite32be(a->ticks, esp->iomem + COUNTER_TICKS_REG);
}

static bool counter_xfer_input_ok(struct esp_device *esp, void *arg)
{
	struct counter_chisel_access *a = arg;

	if (a->ticks >= (1<<16) || a->ticks < 1)
		return false;
	return true;
}

static int counter_probe(struct platform_device *pdev)
{
	struct counter_chisel_device *counter;
	struct esp_device *esp;
	int rc;

	counter = kzalloc(sizeof(*counter), GFP_KERNEL);
	if (counter == NULL)
		return -ENOMEM;
	esp = &counter->esp;
	esp->module = THIS_MODULE;
	esp->number = counter_devs;
	esp->driver = &counter_driver;
	rc = esp_device_register(esp, pdev);
	if (rc)
		goto err;

	counter_devs++;
	return 0;
 err:
	kfree(counter);
	return rc;
}

static int __exit counter_remove(struct platform_device *pdev)
{
	struct esp_device *esp = platform_get_drvdata(pdev);
	struct counter_chisel_device *counter = to_counter(esp);

	esp_device_unregister(esp);
	kfree(counter);
	return 0;
}

static struct esp_driver counter_driver = {
	.plat = {
		.probe		= counter_probe,
		.remove		= counter_remove,
		.driver		= {
			.name = DRV_NAME,
			.owner = THIS_MODULE,
			.of_match_table = counter_device_ids,
		},
	},
	.xfer_input_ok	= counter_xfer_input_ok,
	.prep_xfer	= counter_prep_xfer,
	.ioctl_cm	= COUNTER_CHISEL_IOC_ACCESS,
	.arg_size	= sizeof(struct counter_chisel_access),
};

static int __init counter_init(void)
{
	return esp_driver_register(&counter_driver);
}

static void __exit counter_exit(void)
{
	esp_driver_unregister(&counter_driver);
}

module_init(counter_init)
module_exit(counter_exit)

MODULE_DEVICE_TABLE(of, counter_device_ids);

MODULE_AUTHOR("Emilio G. Cota <cota@braap.org>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("counter_chisel driver");
