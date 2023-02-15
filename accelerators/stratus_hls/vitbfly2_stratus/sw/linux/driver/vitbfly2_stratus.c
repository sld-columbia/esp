// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include <linux/of_device.h>
#include <linux/mm.h>
#include <linux/log2.h>

#include <asm/io.h>

#include <esp_accelerator.h>
#include <esp.h>

#include "vitbfly2_stratus.h"

#define DRV_NAME	"vitbfly2_stratus"

struct vitbfly2_stratus_device {
	struct esp_device esp;
};

static struct esp_driver vitbfly2_driver;

static struct of_device_id vitbfly2_device_ids[] = {
	{
		.name = "SLD_VITBFLY2_STRATUS",
	},
	{
		.name = "eb_016",
	},
	{
		.compatible = "sld,vitbfly2_stratus",
	},
	{ },
};

static int vitbfly2_devs;

static inline struct vitbfly2_stratus_device *to_vitbfly2(struct esp_device *esp)
{
	return container_of(esp, struct vitbfly2_stratus_device, esp);
}

static void vitbfly2_prep_xfer(struct esp_device *esp, void *arg)
{
}

static bool vitbfly2_xfer_input_ok(struct esp_device *esp, void *arg)
{
	return true;
}

static int vitbfly2_probe(struct platform_device *pdev)
{
	struct vitbfly2_stratus_device *vitbfly2;
	struct esp_device *esp;
	int rc;

	vitbfly2 = kzalloc(sizeof(*vitbfly2), GFP_KERNEL);
	if (vitbfly2 == NULL)
		return -ENOMEM;
	esp = &vitbfly2->esp;
	esp->module = THIS_MODULE;
	esp->number = vitbfly2_devs;
	esp->driver = &vitbfly2_driver;
	rc = esp_device_register(esp, pdev);
	if (rc)
		goto err;

	vitbfly2_devs++;
	return 0;
 err:
	kfree(vitbfly2);
	return rc;
}

static int __exit vitbfly2_remove(struct platform_device *pdev)
{
	struct esp_device *esp = platform_get_drvdata(pdev);
	struct vitbfly2_stratus_device *vitbfly2 = to_vitbfly2(esp);

	esp_device_unregister(esp);
	kfree(vitbfly2);
	return 0;
}

static struct esp_driver vitbfly2_driver = {
	.plat = {
		.probe		= vitbfly2_probe,
		.remove		= vitbfly2_remove,
		.driver		= {
			.name = DRV_NAME,
			.owner = THIS_MODULE,
			.of_match_table = vitbfly2_device_ids,
		},
	},
	.xfer_input_ok	= vitbfly2_xfer_input_ok,
	.prep_xfer	= vitbfly2_prep_xfer,
	.ioctl_cm	= VITBFLY2_STRATUS_IOC_ACCESS,
	.arg_size	= sizeof(struct vitbfly2_stratus_access),
};

static int __init vitbfly2_init(void)
{
	return esp_driver_register(&vitbfly2_driver);
}

static void __exit vitbfly2_exit(void)
{
	esp_driver_unregister(&vitbfly2_driver);
}

module_init(vitbfly2_init)
module_exit(vitbfly2_exit)

MODULE_DEVICE_TABLE(of, vitbfly2_device_ids);

MODULE_AUTHOR("Emilio G. Cota <cota@braap.org>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("vitbfly2_stratus driver");
