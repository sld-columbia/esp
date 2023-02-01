// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include <linux/of_device.h>
#include <linux/mm.h>

#include <asm/io.h>

#include <esp_accelerator.h>
#include <esp.h>

#include "synth_stratus.h"

#define DRV_NAME	"synth_stratus"

#define SYNTH_OFFSET_REG		0x40
#define SYNTH_PATTERN_REG		0x44
#define SYNTH_IN_SIZE_REG		0x48
#define SYNTH_ACCESS_FACTOR_REG		0x4c
#define SYNTH_BURST_LEN_REG		0x50
#define SYNTH_COMPUTE_BOUND_factor_REG	0x54
#define SYNTH_IRREGULAR_SEED_REG	0x58
#define SYNTH_REUSE_FACTOR_REG		0x5c
#define SYNTH_LD_ST_ratio_REG		0x60
#define SYNTH_STRIDE_LEN_REG		0x64
#define SYNTH_OUT_SIZE_REG		0x68
#define SYNTH_IN_PLACE_REG		0x6c
#define SYNTH_WR_DATA_REG       0x70
#define SYNTH_RD_DATA_REG       0x74
struct synth_stratus_device {
	struct esp_device esp;
};

static struct esp_driver synth_driver;

static struct of_device_id synth_device_ids[] = {
	{
		.name = "SLD_SYNTH_STRATUS",
	},
	{
		.name = "eb_014",
	},
	{
		.compatible = "sld,synth_stratus",
	},
	{ },
};

static int synth_devs; // TODO this is never initialized

static inline struct synth_stratus_device *to_synth(struct esp_device *esp)
{
	return container_of(esp, struct synth_stratus_device, esp);
}

static void synth_prep_xfer(struct esp_device *esp, void *arg)
{
	struct synth_stratus_access *a = arg;

	iowrite32be(a->offset, esp->iomem + SYNTH_OFFSET_REG);
	iowrite32be(a->pattern, esp->iomem + SYNTH_PATTERN_REG);
	iowrite32be(a->in_size, esp->iomem + SYNTH_IN_SIZE_REG);
	iowrite32be(a->access_factor, esp->iomem + SYNTH_ACCESS_FACTOR_REG);
	iowrite32be(a->burst_len, esp->iomem + SYNTH_BURST_LEN_REG);
	iowrite32be(a->compute_bound_factor, esp->iomem + SYNTH_COMPUTE_BOUND_factor_REG);
	iowrite32be(a->irregular_seed, esp->iomem + SYNTH_IRREGULAR_SEED_REG);
	iowrite32be(a->reuse_factor, esp->iomem + SYNTH_REUSE_FACTOR_REG);
	iowrite32be(a->ld_st_ratio, esp->iomem + SYNTH_LD_ST_ratio_REG);
	iowrite32be(a->stride_len, esp->iomem + SYNTH_STRIDE_LEN_REG);
	iowrite32be(a->out_size, esp->iomem + SYNTH_OUT_SIZE_REG);
	iowrite32be(a->in_place, esp->iomem + SYNTH_IN_PLACE_REG);
    iowrite32be(a->wr_data, esp->iomem + SYNTH_WR_DATA_REG);
    iowrite32be(a->rd_data, esp->iomem + SYNTH_RD_DATA_REG);
}

static bool synth_xfer_input_ok(struct esp_device *esp, void *arg)
{
	return true;
}

static int synth_probe(struct platform_device *pdev)
{
	struct synth_stratus_device *synth;
	struct esp_device *esp;
	int rc;

	synth = kzalloc(sizeof(*synth), GFP_KERNEL);
	if (synth == NULL)
		return -ENOMEM;
	esp = &synth->esp;
	esp->module = THIS_MODULE;
	esp->number = synth_devs;
	esp->driver = &synth_driver;
	rc = esp_device_register(esp, pdev);
	if (rc)
		goto err;

	synth_devs++;
	return 0;
 err:
	kfree(synth);
	return rc;
}

static int __exit synth_remove(struct platform_device *pdev)
{
	struct esp_device *esp = platform_get_drvdata(pdev);
	struct synth_stratus_device *synth = to_synth(esp);

	esp_device_unregister(esp);
	kfree(synth);
	return 0;
}

static struct esp_driver synth_driver = {
	.plat = {
		.probe		= synth_probe,
		.remove		= synth_remove,
		.driver		= {
			.name = DRV_NAME,
			.owner = THIS_MODULE,
			.of_match_table = synth_device_ids,
		},
	},
	.xfer_input_ok	= synth_xfer_input_ok,
	.prep_xfer	= synth_prep_xfer,
	.ioctl_cm	= SYNTH_STRATUS_IOC_ACCESS,
	.arg_size	= sizeof(struct synth_stratus_access),
};

static int __init synth_init(void)
{
	return esp_driver_register(&synth_driver);
}

static void __exit synth_exit(void)
{
	esp_driver_unregister(&synth_driver);
}

module_init(synth_init)
module_exit(synth_exit)

MODULE_DEVICE_TABLE(of, synth_device_ids);

MODULE_AUTHOR("Emilio G. Cota <cota@braap.org>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("synth_stratus driver");
