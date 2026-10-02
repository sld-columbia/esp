// Copyright (c) 2011-2026 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include <linux/of_device.h>
#include <linux/mm.h>

#include <asm/io.h>

#include <esp_accelerator.h>
#include <esp.h>

#include "gt_vortex_rtl.h"

#define DRV_NAME	"gt_vortex_rtl"

/*
 * This driver is intentionally small: ESP's framework handles queueing,
 * synchronization, and blocking completion behavior. This driver only maps
 * ioctl descriptor fields to GT_VORTEX wrapper registers.
 */

/* <<--regs-->> */
#define GT_VORTEX_BASE_ADDR_REG 0x50
#define GT_VORTEX_START_VORTEX_REG 0x54
#define GT_VORTEX_VX_BUSY_INT_REG 0x58
#define GT_VORTEX_STARTUP_ADDR0 0x60
#define GT_VORTEX_STARTUP_ADDR1 0x64
#define GT_VORTEX_STARTUP_ARG0 0x68
#define GT_VORTEX_STARTUP_ARG1 0x6C
#define GT_VORTEX_MPM_CLASS 0x70

struct gt_vortex_rtl_device {
	struct esp_device esp;
};

static struct esp_driver gt_vortex_driver;

static struct of_device_id gt_vortex_device_ids[] = {
	{
		.name = "SLD_GT_VORTEX_RTL",
	},
	{
		.name = "eb_108",
	},
	{
		.compatible = "GATech,gt_vortex",
	},
	{ },
};

static int gt_vortex_devs;

static inline struct gt_vortex_rtl_device *to_gt_vortex(struct esp_device *esp)
{
	return container_of(esp, struct gt_vortex_rtl_device, esp);
}

static void gt_vortex_prep_xfer(struct esp_device *esp, void *arg)
{
	struct gt_vortex_rtl_access *a = arg;

	/* <<--regs-config-->> */
	/* Program wrapper-visible registers from the user descriptor. */
	iowrite32be(0, esp->iomem + GT_VORTEX_START_VORTEX_REG);
	iowrite32be(a->BASE_ADDR, esp->iomem + GT_VORTEX_BASE_ADDR_REG);
	iowrite32be(a->STARTUP_ADDR0, esp->iomem + GT_VORTEX_STARTUP_ADDR0);
	iowrite32be(a->STARTUP_ADDR1, esp->iomem + GT_VORTEX_STARTUP_ADDR1);
	iowrite32be(a->STARTUP_ARG0, esp->iomem + GT_VORTEX_STARTUP_ARG0);
	iowrite32be(a->STARTUP_ARG1, esp->iomem + GT_VORTEX_STARTUP_ARG1);
	iowrite32be(a->MPM_CLASS, esp->iomem + GT_VORTEX_MPM_CLASS);
	/*
	 * Drain posted MMIO writes so the wrapper snapshots a coherent set of
	 * launch registers before it observes the start pulse.
	 */
	ioread32be(esp->iomem + GT_VORTEX_MPM_CLASS);
	mb();
	iowrite32be(a->START_VORTEX ? 1 : 0,
		    esp->iomem + GT_VORTEX_START_VORTEX_REG);
	ioread32be(esp->iomem + GT_VORTEX_START_VORTEX_REG);
}

static bool gt_vortex_xfer_input_ok(struct esp_device *esp, void *arg)
{
	/* No extra pre-checks today; descriptor validation is minimal. */
	return true;
}

static int gt_vortex_probe(struct platform_device *pdev)
{
	struct gt_vortex_rtl_device *gt_vortex;
	struct esp_device *esp;
	int rc;

	gt_vortex = kzalloc(sizeof(*gt_vortex), GFP_KERNEL);
	if (gt_vortex == NULL)
		return -ENOMEM;
	esp = &gt_vortex->esp;
	/* Mark as third-party so ESP uses third-party accelerator flow. */
	esp->module = THIS_MODULE;
	esp->number = gt_vortex_devs;
	esp->driver = &gt_vortex_driver;
	esp->third_party = 1;
	rc = esp_device_register(esp, pdev);
	if (rc)
		goto err;

	gt_vortex_devs++;
	return 0;
 err:
	kfree(gt_vortex);
	return rc;
}

static int __exit gt_vortex_remove(struct platform_device *pdev)
{
	struct esp_device *esp = platform_get_drvdata(pdev);
	struct gt_vortex_rtl_device *gt_vortex = to_gt_vortex(esp);

	esp_device_unregister(esp);
	kfree(gt_vortex);
	return 0;
}

static struct esp_driver gt_vortex_driver = {
	.plat = {
		.probe		= gt_vortex_probe,
		.remove		= gt_vortex_remove,
		.driver		= {
			.name = DRV_NAME,
			.owner = THIS_MODULE,
			.of_match_table = gt_vortex_device_ids,
		},
	},
	.xfer_input_ok	= gt_vortex_xfer_input_ok,
	.prep_xfer	= gt_vortex_prep_xfer,
	/* ioctl command and payload size expected from user-space. */
	.ioctl_cm	= GT_VORTEX_RTL_IOC_ACCESS,
	.arg_size	= sizeof(struct gt_vortex_rtl_access),
};

static int __init gt_vortex_init(void)
{
	return esp_driver_register(&gt_vortex_driver);
}

static void __exit gt_vortex_exit(void)
{
	esp_driver_unregister(&gt_vortex_driver);
}

module_init(gt_vortex_init)
module_exit(gt_vortex_exit)

MODULE_DEVICE_TABLE(of, gt_vortex_device_ids);

MODULE_AUTHOR("GA Tech");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("gt_vortex_rtl driver");
