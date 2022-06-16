// Copyright (c) 2011-2021 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include <linux/of_device.h>
#include <linux/mm.h>

#include <asm/io.h>

#include <esp_accelerator.h>
#include <esp.h>

#include "sensor_dma_stratus.h"

#define DRV_NAME	"sensor_dma_stratus"

/* <<--regs-->> */
#define SENSOR_DMA_RD_SP_OFFSET_REG 0x58
#define SENSOR_DMA_RD_WR_ENABLE_REG 0x54
#define SENSOR_DMA_WR_SIZE_REG 0x50
#define SENSOR_DMA_WR_SP_OFFSET_REG 0x4c
#define SENSOR_DMA_RD_SIZE_REG 0x48
#define SENSOR_DMA_DST_OFFSET_REG 0x44
#define SENSOR_DMA_SRC_OFFSET_REG 0x40

struct sensor_dma_stratus_device {
	struct esp_device esp;
};

static struct esp_driver sensor_dma_driver;

static struct of_device_id sensor_dma_device_ids[] = {
	{
		.name = "SLD_SENSOR_DMA_STRATUS",
	},
	{
		.name = "eb_050",
	},
	{
		.compatible = "sld,sensor_dma_stratus",
	},
	{ },
};

static int sensor_dma_devs;

static inline struct sensor_dma_stratus_device *to_sensor_dma(struct esp_device *esp)
{
	return container_of(esp, struct sensor_dma_stratus_device, esp);
}

static void sensor_dma_prep_xfer(struct esp_device *esp, void *arg)
{
	struct sensor_dma_stratus_access *a = arg;

	/* <<--regs-config-->> */
	iowrite32be(a->rd_sp_offset, esp->iomem + SENSOR_DMA_RD_SP_OFFSET_REG);
	iowrite32be(a->rd_wr_enable, esp->iomem + SENSOR_DMA_RD_WR_ENABLE_REG);
	iowrite32be(a->wr_size, esp->iomem + SENSOR_DMA_WR_SIZE_REG);
	iowrite32be(a->wr_sp_offset, esp->iomem + SENSOR_DMA_WR_SP_OFFSET_REG);
	iowrite32be(a->rd_size, esp->iomem + SENSOR_DMA_RD_SIZE_REG);
	iowrite32be(a->dst_offset, esp->iomem + SENSOR_DMA_DST_OFFSET_REG);
	iowrite32be(a->src_offset, esp->iomem + SENSOR_DMA_SRC_OFFSET_REG);
	iowrite32be(a->src_offset, esp->iomem + SRC_OFFSET_REG);
	iowrite32be(a->dst_offset, esp->iomem + DST_OFFSET_REG);

}

static bool sensor_dma_xfer_input_ok(struct esp_device *esp, void *arg)
{
	/* struct sensor_dma_stratus_device *sensor_dma = to_sensor_dma(esp); */
	/* struct sensor_dma_stratus_access *a = arg; */

	return true;
}

static int sensor_dma_probe(struct platform_device *pdev)
{
	struct sensor_dma_stratus_device *sensor_dma;
	struct esp_device *esp;
	int rc;

	sensor_dma = kzalloc(sizeof(*sensor_dma), GFP_KERNEL);
	if (sensor_dma == NULL)
		return -ENOMEM;
	esp = &sensor_dma->esp;
	esp->module = THIS_MODULE;
	esp->number = sensor_dma_devs;
	esp->driver = &sensor_dma_driver;
	rc = esp_device_register(esp, pdev);
	if (rc)
		goto err;

	sensor_dma_devs++;
	return 0;
 err:
	kfree(sensor_dma);
	return rc;
}

static int __exit sensor_dma_remove(struct platform_device *pdev)
{
	struct esp_device *esp = platform_get_drvdata(pdev);
	struct sensor_dma_stratus_device *sensor_dma = to_sensor_dma(esp);

	esp_device_unregister(esp);
	kfree(sensor_dma);
	return 0;
}

static struct esp_driver sensor_dma_driver = {
	.plat = {
		.probe		= sensor_dma_probe,
		.remove		= sensor_dma_remove,
		.driver		= {
			.name = DRV_NAME,
			.owner = THIS_MODULE,
			.of_match_table = sensor_dma_device_ids,
		},
	},
	.xfer_input_ok	= sensor_dma_xfer_input_ok,
	.prep_xfer	= sensor_dma_prep_xfer,
	.ioctl_cm	= SENSOR_DMA_STRATUS_IOC_ACCESS,
	.arg_size	= sizeof(struct sensor_dma_stratus_access),
};

static int __init sensor_dma_init(void)
{
	return esp_driver_register(&sensor_dma_driver);
}

static void __exit sensor_dma_exit(void)
{
	esp_driver_unregister(&sensor_dma_driver);
}

module_init(sensor_dma_init)
module_exit(sensor_dma_exit)

MODULE_DEVICE_TABLE(of, sensor_dma_device_ids);

MODULE_AUTHOR("Emilio G. Cota <cota@braap.org>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("sensor_dma_stratus driver");
