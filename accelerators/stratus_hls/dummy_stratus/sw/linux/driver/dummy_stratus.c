// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include <linux/of_device.h>
#include <linux/mm.h>

#include <asm/io.h>

#include <esp_accelerator.h>
#include <esp.h>

#include "dummy_stratus.h"

#define DRV_NAME	"dummy_stratus"

#define DUMMY_LEN_REG		0x40
#define DUMMY_BATCH_REG		0x44

struct dummy_stratus_device {
	struct esp_device esp;
};

static struct esp_driver dummy_driver;

static struct of_device_id dummy_device_ids[] = {
	{
		.name = "SLD_DUMMY_STRATUS",
	},
	{
		.name = "eb_042",
	},
	{
		.compatible = "sld,dummy_stratus",
	},
	{ },
};

static int dummy_devs;

static inline struct dummy_stratus_device *to_dummy(struct esp_device *esp)
{
	return container_of(esp, struct dummy_stratus_device, esp);
}

static void dummy_prep_xfer(struct esp_device *esp, void *arg)
{
	struct dummy_stratus_access *a = arg;

	iowrite32be(a->tokens, esp->iomem + DUMMY_LEN_REG);
	iowrite32be(a->batch, esp->iomem + DUMMY_BATCH_REG);
	iowrite32be(a->src_offset, esp->iomem + SRC_OFFSET_REG);
	iowrite32be(a->dst_offset, esp->iomem + DST_OFFSET_REG);

}

static bool dummy_xfer_input_ok(struct esp_device *esp, void *arg)
{
	/* struct dummy_stratus_device *dummy = to_dummy(esp); */
	/* struct dummy_stratus_access *a = arg; */

	return true;
}

static int dummy_probe(struct platform_device *pdev)
{
	struct dummy_stratus_device *dummy;
	struct esp_device *esp;
	int rc;

	dummy = kzalloc(sizeof(*dummy), GFP_KERNEL);
	if (dummy == NULL)
		return -ENOMEM;
	esp = &dummy->esp;
	esp->module = THIS_MODULE;
	esp->number = dummy_devs;
	esp->driver = &dummy_driver;
	rc = esp_device_register(esp, pdev);
	if (rc)
		goto err;

	dummy_devs++;
	return 0;
 err:
	kfree(dummy);
	return rc;
}

static int __exit dummy_remove(struct platform_device *pdev)
{
	struct esp_device *esp = platform_get_drvdata(pdev);
	struct dummy_stratus_device *dummy = to_dummy(esp);

	esp_device_unregister(esp);
	kfree(dummy);
	return 0;
}

static struct esp_driver dummy_driver = {
	.plat = {
		.probe		= dummy_probe,
		.remove		= dummy_remove,
		.driver		= {
			.name = DRV_NAME,
			.owner = THIS_MODULE,
			.of_match_table = dummy_device_ids,
		},
	},
	.xfer_input_ok	= dummy_xfer_input_ok,
	.prep_xfer	= dummy_prep_xfer,
	.ioctl_cm	= DUMMY_STRATUS_IOC_ACCESS,
	.arg_size	= sizeof(struct dummy_stratus_access),
};

static int __init dummy_init(void)
{
	return esp_driver_register(&dummy_driver);
}

static void __exit dummy_exit(void)
{
	esp_driver_unregister(&dummy_driver);
}

module_init(dummy_init)
module_exit(dummy_exit)

MODULE_DEVICE_TABLE(of, dummy_device_ids);

MODULE_AUTHOR("Emilio G. Cota <cota@braap.org>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("dummy_stratus driver");
