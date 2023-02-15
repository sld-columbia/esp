// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include <linux/of_device.h>
#include <linux/mm.h>

#include <asm/io.h>

#include <esp_accelerator.h>
#include <esp.h>

#include "<acc_full_name>.h"

#define DRV_NAME	"<acc_full_name>"

/* <<--regs-->> */

struct <acc_full_name>_device {
	struct esp_device esp;
};

static struct esp_driver <accelerator_name>_driver;

static struct of_device_id <accelerator_name>_device_ids[] = {
	{
		.name = "SLD_<ACC_FULL_NAME>",
	},
	{
		.name = "eb_/* <<--id-->> */",
	},
	{
		.compatible = "sld,<acc_full_name>",
	},
	{ },
};

static int <accelerator_name>_devs;

static inline struct <acc_full_name>_device *to_<accelerator_name>(struct esp_device *esp)
{
	return container_of(esp, struct <acc_full_name>_device, esp);
}

static void <accelerator_name>_prep_xfer(struct esp_device *esp, void *arg)
{
	struct <acc_full_name>_access *a = arg;

	/* <<--regs-config-->> */
	iowrite32be(a->src_offset, esp->iomem + SRC_OFFSET_REG);
	iowrite32be(a->dst_offset, esp->iomem + DST_OFFSET_REG);

}

static bool <accelerator_name>_xfer_input_ok(struct esp_device *esp, void *arg)
{
	/* struct <acc_full_name>_device *<accelerator_name> = to_<accelerator_name>(esp); */
	/* struct <acc_full_name>_access *a = arg; */

	return true;
}

static int <accelerator_name>_probe(struct platform_device *pdev)
{
	struct <acc_full_name>_device *<accelerator_name>;
	struct esp_device *esp;
	int rc;

	<accelerator_name> = kzalloc(sizeof(*<accelerator_name>), GFP_KERNEL);
	if (<accelerator_name> == NULL)
		return -ENOMEM;
	esp = &<accelerator_name>->esp;
	esp->module = THIS_MODULE;
	esp->number = <accelerator_name>_devs;
	esp->driver = &<accelerator_name>_driver;
	rc = esp_device_register(esp, pdev);
	if (rc)
		goto err;

	<accelerator_name>_devs++;
	return 0;
 err:
	kfree(<accelerator_name>);
	return rc;
}

static int __exit <accelerator_name>_remove(struct platform_device *pdev)
{
	struct esp_device *esp = platform_get_drvdata(pdev);
	struct <acc_full_name>_device *<accelerator_name> = to_<accelerator_name>(esp);

	esp_device_unregister(esp);
	kfree(<accelerator_name>);
	return 0;
}

static struct esp_driver <accelerator_name>_driver = {
	.plat = {
		.probe		= <accelerator_name>_probe,
		.remove		= <accelerator_name>_remove,
		.driver		= {
			.name = DRV_NAME,
			.owner = THIS_MODULE,
			.of_match_table = <accelerator_name>_device_ids,
		},
	},
	.xfer_input_ok	= <accelerator_name>_xfer_input_ok,
	.prep_xfer	= <accelerator_name>_prep_xfer,
	.ioctl_cm	= <ACC_FULL_NAME>_IOC_ACCESS,
	.arg_size	= sizeof(struct <acc_full_name>_access),
};

static int __init <accelerator_name>_init(void)
{
	return esp_driver_register(&<accelerator_name>_driver);
}

static void __exit <accelerator_name>_exit(void)
{
	esp_driver_unregister(&<accelerator_name>_driver);
}

module_init(<accelerator_name>_init)
module_exit(<accelerator_name>_exit)

MODULE_DEVICE_TABLE(of, <accelerator_name>_device_ids);

MODULE_AUTHOR("Emilio G. Cota <cota@braap.org>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("<acc_full_name> driver");
