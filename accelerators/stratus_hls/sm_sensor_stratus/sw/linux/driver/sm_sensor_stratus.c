// Copyright (c) 2011-2022 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include <linux/of_device.h>
#include <linux/mm.h>

#include <asm/io.h>

#include <esp_accelerator.h>
#include <esp.h>

#include "sm_sensor_stratus.h"

#define DRV_NAME	"sm_sensor_stratus"

/* <<--regs-->> */
#define SM_SENSOR_SIZE_REG 0x40

struct sm_sensor_stratus_device {
	struct esp_device esp;
};

static struct esp_driver sm_sensor_driver;

static struct of_device_id sm_sensor_device_ids[] = {
	{
		.name = "SLD_SM_SENSOR_STRATUS",
	},
	{
		.name = "eb_050",
	},
	{
		.compatible = "sld,sm_sensor_stratus",
	},
	{ },
};

static int sm_sensor_devs;

static inline struct sm_sensor_stratus_device *to_sm_sensor(struct esp_device *esp)
{
	return container_of(esp, struct sm_sensor_stratus_device, esp);
}

static void sm_sensor_prep_xfer(struct esp_device *esp, void *arg)
{
	struct sm_sensor_stratus_access *a = arg;

	/* <<--regs-config-->> */
	iowrite32be(a->size, esp->iomem + SM_SENSOR_SIZE_REG);
	iowrite32be(a->src_offset, esp->iomem + SRC_OFFSET_REG);
	iowrite32be(a->dst_offset, esp->iomem + DST_OFFSET_REG);

}

static bool sm_sensor_xfer_input_ok(struct esp_device *esp, void *arg)
{
	/* struct sm_sensor_stratus_device *sm_sensor = to_sm_sensor(esp); */
	/* struct sm_sensor_stratus_access *a = arg; */

	return true;
}

static int sm_sensor_probe(struct platform_device *pdev)
{
	struct sm_sensor_stratus_device *sm_sensor;
	struct esp_device *esp;
	int rc;

	sm_sensor = kzalloc(sizeof(*sm_sensor), GFP_KERNEL);
	if (sm_sensor == NULL)
		return -ENOMEM;
	esp = &sm_sensor->esp;
	esp->module = THIS_MODULE;
	esp->number = sm_sensor_devs;
	esp->driver = &sm_sensor_driver;
	rc = esp_device_register(esp, pdev);
	if (rc)
		goto err;

	sm_sensor_devs++;
	return 0;
 err:
	kfree(sm_sensor);
	return rc;
}

static int __exit sm_sensor_remove(struct platform_device *pdev)
{
	struct esp_device *esp = platform_get_drvdata(pdev);
	struct sm_sensor_stratus_device *sm_sensor = to_sm_sensor(esp);

	esp_device_unregister(esp);
	kfree(sm_sensor);
	return 0;
}

static struct esp_driver sm_sensor_driver = {
	.plat = {
		.probe		= sm_sensor_probe,
		.remove		= sm_sensor_remove,
		.driver		= {
			.name = DRV_NAME,
			.owner = THIS_MODULE,
			.of_match_table = sm_sensor_device_ids,
		},
	},
	.xfer_input_ok	= sm_sensor_xfer_input_ok,
	.prep_xfer	= sm_sensor_prep_xfer,
	.ioctl_cm	= SM_SENSOR_STRATUS_IOC_ACCESS,
	.arg_size	= sizeof(struct sm_sensor_stratus_access),
};

static int __init sm_sensor_init(void)
{
	return esp_driver_register(&sm_sensor_driver);
}

static void __exit sm_sensor_exit(void)
{
	esp_driver_unregister(&sm_sensor_driver);
}

module_init(sm_sensor_init)
module_exit(sm_sensor_exit)

MODULE_DEVICE_TABLE(of, sm_sensor_device_ids);

MODULE_AUTHOR("Emilio G. Cota <cota@braap.org>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("sm_sensor_stratus driver");
