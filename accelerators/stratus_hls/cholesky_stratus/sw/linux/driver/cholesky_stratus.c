// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include <linux/of_device.h>
#include <linux/mm.h>

#include <asm/io.h>

#include <esp_accelerator.h>
#include <esp.h>

#include "cholesky_stratus.h"

#define DRV_NAME	"cholesky_stratus"

/* <<--regs-->> */
#define CHOLESKY_ROWS_REG 0x40

struct cholesky_stratus_device {
	struct esp_device esp;
};

static struct esp_driver cholesky_driver;

static struct of_device_id cholesky_device_ids[] = {
	{
		.name = "SLD_CHOLESKY_STRATUS",
	},
	{
		.name = "eb_062",
	},
	{
		.compatible = "sld,cholesky_stratus",
	},
	{ },
};

static int cholesky_devs;

static inline struct cholesky_stratus_device *to_cholesky(struct esp_device *esp)
{
	return container_of(esp, struct cholesky_stratus_device, esp);
}

static void cholesky_prep_xfer(struct esp_device *esp, void *arg)
{
	struct cholesky_stratus_access *a = arg;

	/* <<--regs-config-->> */
	iowrite32be(a->rows, esp->iomem + CHOLESKY_ROWS_REG);
	iowrite32be(a->src_offset, esp->iomem + SRC_OFFSET_REG);
	iowrite32be(a->dst_offset, esp->iomem + DST_OFFSET_REG);

}

static bool cholesky_xfer_input_ok(struct esp_device *esp, void *arg)
{
	struct cholesky_stratus_device *cholesky = to_cholesky(esp);
	struct cholesky_stratus_access *a = arg;

    if (a->rows > 2048)
        return false;

    return true;
}

static int cholesky_probe(struct platform_device *pdev)
{
	struct cholesky_stratus_device *cholesky;
	struct esp_device *esp;
	int rc;

	cholesky = kzalloc(sizeof(*cholesky), GFP_KERNEL);
	if (cholesky == NULL)
		return -ENOMEM;
	esp = &cholesky->esp;
	esp->module = THIS_MODULE;
	esp->number = cholesky_devs;
	esp->driver = &cholesky_driver;
	rc = esp_device_register(esp, pdev);
	if (rc)
		goto err;

	cholesky_devs++;
	return 0;
 err:
	kfree(cholesky);
	return rc;
}

static int __exit cholesky_remove(struct platform_device *pdev)
{
	struct esp_device *esp = platform_get_drvdata(pdev);
	struct cholesky_stratus_device *cholesky = to_cholesky(esp);

	esp_device_unregister(esp);
	kfree(cholesky);
	return 0;
}

static struct esp_driver cholesky_driver = {
	.plat = {
		.probe		= cholesky_probe,
		.remove		= cholesky_remove,
		.driver		= {
			.name = DRV_NAME,
			.owner = THIS_MODULE,
			.of_match_table = cholesky_device_ids,
		},
	},
	.xfer_input_ok	= cholesky_xfer_input_ok,
	.prep_xfer	= cholesky_prep_xfer,
	.ioctl_cm	= CHOLESKY_STRATUS_IOC_ACCESS,
	.arg_size	= sizeof(struct cholesky_stratus_access),
};

static int __init cholesky_init(void)
{
	return esp_driver_register(&cholesky_driver);
}

static void __exit cholesky_exit(void)
{
	esp_driver_unregister(&cholesky_driver);
}

module_init(cholesky_init)
module_exit(cholesky_exit)

MODULE_DEVICE_TABLE(of, cholesky_device_ids);

MODULE_AUTHOR("Emilio G. Cota <cota@braap.org>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("cholesky_stratus driver");
