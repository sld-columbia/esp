// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include <linux/of_device.h>
#include <linux/mm.h>
#include <linux/log2.h>

#include <asm/io.h>

#include <esp_accelerator.h>
#include <esp.h>

#include "spmv_stratus.h"

#define DRV_NAME	"spmv_stratus"

#define SPMV_NROWS_REG		0x40
#define SPMV_NCOLS_REG		0x44
#define SPMV_MAX_NONZERO_REG	0x48
#define SPMV_MTX_LEN_REG	0x4C
#define SPMV_VALS_PLM_SIZE_REG	0x50
#define SPMV_VECT_FITS_PLM_REG	0x54

struct spmv_stratus_device {
	struct esp_device esp;
};

static struct esp_driver spmv_driver;

static struct of_device_id spmv_device_ids[] = {
	{
		.name = "SLD_SPMV_STRATUS",
	},
	{
		.name = "eb_00c",
	},
	{
		.compatible = "sld,spmv_stratus",
	},
	{ },
};

static int spmv_devs;

static inline struct spmv_stratus_device *to_spmv(struct esp_device *esp)
{
	return container_of(esp, struct spmv_stratus_device, esp);
}

static void spmv_prep_xfer(struct esp_device *esp, void *arg)
{
	struct spmv_stratus_access *a = arg;

	iowrite32be(a->nrows, esp->iomem + SPMV_NROWS_REG);
	iowrite32be(a->ncols, esp->iomem + SPMV_NCOLS_REG);
	iowrite32be(a->max_nonzero, esp->iomem + SPMV_MAX_NONZERO_REG);
	iowrite32be(a->mtx_len, esp->iomem + SPMV_MTX_LEN_REG);
	iowrite32be(a->vals_plm_size, esp->iomem + SPMV_VALS_PLM_SIZE_REG);
	iowrite32be(a->vect_fits_plm, esp->iomem + SPMV_VECT_FITS_PLM_REG);
}

static bool spmv_xfer_input_ok(struct esp_device *esp, void *arg)
{
	struct spmv_stratus_access *a = arg;
	long long unsigned mtx_max = ((long long unsigned) a->nrows) * ((long long unsigned) a->ncols);

	if (!is_power_of_2(a->nrows))
		return false;

	if (!is_power_of_2(a->ncols))
		return false;

	if (!is_power_of_2(a->max_nonzero))
		return false;

	if (a->max_nonzero > 32 || a->max_nonzero < 4)
		return false;

	if (a->mtx_len == 0 || ((long long unsigned) a->mtx_len) > mtx_max)
		return false;

	if (!is_power_of_2(a->vals_plm_size))
		return false;

	if (a->vals_plm_size < 16 || a->vals_plm_size > 1024)
		return false;

	if (a->vect_fits_plm && a->ncols > 8192)
		return false;

	return true;
}

static int spmv_probe(struct platform_device *pdev)
{
	struct spmv_stratus_device *spmv;
	struct esp_device *esp;
	int rc;

	spmv = kzalloc(sizeof(*spmv), GFP_KERNEL);
	if (spmv == NULL)
		return -ENOMEM;
	esp = &spmv->esp;
	esp->module = THIS_MODULE;
	esp->number = spmv_devs;
	esp->driver = &spmv_driver;
	rc = esp_device_register(esp, pdev);
	if (rc)
		goto err;

	spmv_devs++;
	return 0;
 err:
	kfree(spmv);
	return rc;
}

static int __exit spmv_remove(struct platform_device *pdev)
{
	struct esp_device *esp = platform_get_drvdata(pdev);
	struct spmv_stratus_device *spmv = to_spmv(esp);

	esp_device_unregister(esp);
	kfree(spmv);
	return 0;
}

static struct esp_driver spmv_driver = {
	.plat = {
		.probe		= spmv_probe,
		.remove		= spmv_remove,
		.driver		= {
			.name = DRV_NAME,
			.owner = THIS_MODULE,
			.of_match_table = spmv_device_ids,
		},
	},
	.xfer_input_ok	= spmv_xfer_input_ok,
	.prep_xfer	= spmv_prep_xfer,
	.ioctl_cm	= SPMV_STRATUS_IOC_ACCESS,
	.arg_size	= sizeof(struct spmv_stratus_access),
};

static int __init spmv_init(void)
{
	return esp_driver_register(&spmv_driver);
}

static void __exit spmv_exit(void)
{
	esp_driver_unregister(&spmv_driver);
}

module_init(spmv_init)
module_exit(spmv_exit)

MODULE_DEVICE_TABLE(of, spmv_device_ids);

MODULE_AUTHOR("Emilio G. Cota <cota@braap.org>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("spmv_stratus driver");
