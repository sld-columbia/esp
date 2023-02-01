// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include <linux/of_device.h>
#include <linux/mm.h>

#include <asm/io.h>

#include <esp_accelerator.h>
#include <esp.h>

#include "sort_stratus.h"

#define DRV_NAME	"sort_stratus"

#define SORT_LEN_REG		0x40
#define SORT_BATCH_REG		0x44
#define SORT_LEN_MIN_REG	0x48
#define SORT_LEN_MAX_REG	0x4c
#define SORT_BATCH_MAX_REG	0x50

struct sort_stratus_device {
	struct esp_device esp;
	size_t max_size; /* Maximum buffer size to be DMA'd to/from in bytes */
	unsigned min_len;
	unsigned max_len;
	unsigned max_batch;
};

static struct esp_driver sort_driver;

static struct of_device_id sort_device_ids[] = {
	{
		.name = "SLD_SORT_STRATUS",
	},
	{
		.name = "eb_00b",
	},
	{
		.compatible = "sld,sort_stratus",
	},
	{ },
};

static int sort_devs;

static inline struct sort_stratus_device *to_sort(struct esp_device *esp)
{
	return container_of(esp, struct sort_stratus_device, esp);
}

static void sort_prep_xfer(struct esp_device *esp, void *arg)
{
	struct sort_stratus_access *a = arg;

	iowrite32be(a->size, esp->iomem + SORT_LEN_REG);
	iowrite32be(a->batch, esp->iomem + SORT_BATCH_REG);
}

static bool sort_xfer_input_ok(struct esp_device *esp, void *arg)
{
	struct sort_stratus_device *sort = to_sort(esp);
	struct sort_stratus_access *a = arg;
	unsigned size_mask = 0x0000001f;

	if (a->size & size_mask ||
		a->size > sort->max_len ||
		a->size < sort->min_len ||
		a->batch > sort->max_batch ||
		a->batch < 1)
		return false;
	return true;
}

static int sort_probe(struct platform_device *pdev)
{
	struct sort_stratus_device *sort;
	struct esp_device *esp;
	size_t max_size;
	int rc;

	sort = kzalloc(sizeof(*sort), GFP_KERNEL);
	if (sort == NULL)
		return -ENOMEM;
	esp = &sort->esp;
	esp->module = THIS_MODULE;
	esp->number = sort_devs;
	esp->driver = &sort_driver;
	rc = esp_device_register(esp, pdev);
	if (rc)
		goto err;
	sort->max_len = ioread32be(esp->iomem + SORT_LEN_MAX_REG);
	sort->min_len = ioread32be(esp->iomem + SORT_LEN_MIN_REG);
	sort->max_batch = ioread32be(esp->iomem + SORT_BATCH_MAX_REG);
	max_size = sort->max_len * sort->max_batch * sizeof(u32);
	sort->max_size = round_up(max_size, PAGE_SIZE);

	sort_devs++;
	return 0;
 err:
	kfree(sort);
	return rc;
}

static int __exit sort_remove(struct platform_device *pdev)
{
	struct esp_device *esp = platform_get_drvdata(pdev);
	struct sort_stratus_device *sort = to_sort(esp);

	esp_device_unregister(esp);
	kfree(sort);
	return 0;
}

static struct esp_driver sort_driver = {
	.plat = {
		.probe		= sort_probe,
		.remove		= sort_remove,
		.driver		= {
			.name = DRV_NAME,
			.owner = THIS_MODULE,
			.of_match_table = sort_device_ids,
		},
	},
	.xfer_input_ok	= sort_xfer_input_ok,
	.prep_xfer	= sort_prep_xfer,
	.ioctl_cm	= SORT_STRATUS_IOC_ACCESS,
	.arg_size	= sizeof(struct sort_stratus_access),
};

static int __init sort_init(void)
{
	return esp_driver_register(&sort_driver);
}

static void __exit sort_exit(void)
{
	esp_driver_unregister(&sort_driver);
}

module_init(sort_init)
module_exit(sort_exit)

MODULE_DEVICE_TABLE(of, sort_device_ids);

MODULE_AUTHOR("Emilio G. Cota <cota@braap.org>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("sort_stratus driver");
