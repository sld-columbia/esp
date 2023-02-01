// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include <linux/of_device.h>
#include <linux/mm.h>

#include <asm/io.h>

#include <esp_accelerator.h>
#include <esp.h>

#include "fft_chisel.h"

#define DRV_NAME	"fft_chisel"

/* <<--regs-->> */
#define FFT_STRIDE_REG 0x50
#define FFT_COUNT_REG 0x4C
#define FFT_STARTADDR_REG 0x48

struct fft_chisel_device {
	struct esp_device esp;
};

static struct esp_driver fft_driver;

static struct of_device_id fft_device_ids[] = {
	{
		.name = "SLD_FFT_CHISEL",
	},
	{
		.name = "eb_013",
	},
	{
		.compatible = "sld,fft_chisel",
	},
	{ },
};

static int fft_devs;

static inline struct fft_chisel_device *to_fft(struct esp_device *esp)
{
	return container_of(esp, struct fft_chisel_device, esp);
}

static void fft_prep_xfer(struct esp_device *esp, void *arg)
{
	struct fft_chisel_access *a = arg;

	/* <<--regs-config-->> */
	iowrite32be(a->stride, esp->iomem + FFT_STRIDE_REG);
	iowrite32be(1, esp->iomem + FFT_COUNT_REG);
	iowrite32be(0, esp->iomem + FFT_STARTADDR_REG);
	iowrite32be(a->src_offset, esp->iomem + SRC_OFFSET_REG);
	iowrite32be(a->dst_offset, esp->iomem + DST_OFFSET_REG);

}

static bool fft_xfer_input_ok(struct esp_device *esp, void *arg)
{
	/* struct fft_chisel_device *fft = to_fft(esp); */
	/* struct fft_chisel_access *a = arg; */

	return true;
}

static int fft_probe(struct platform_device *pdev)
{
	struct fft_chisel_device *fft;
	struct esp_device *esp;
	int rc;

	fft = kzalloc(sizeof(*fft), GFP_KERNEL);
	if (fft == NULL)
		return -ENOMEM;
	esp = &fft->esp;
	esp->module = THIS_MODULE;
	esp->number = fft_devs;
	esp->driver = &fft_driver;
	rc = esp_device_register(esp, pdev);
	if (rc)
		goto err;

	fft_devs++;
	return 0;
 err:
	kfree(fft);
	return rc;
}

static int __exit fft_remove(struct platform_device *pdev)
{
	struct esp_device *esp = platform_get_drvdata(pdev);
	struct fft_chisel_device *fft = to_fft(esp);

	esp_device_unregister(esp);
	kfree(fft);
	return 0;
}

static struct esp_driver fft_driver = {
	.plat = {
		.probe		= fft_probe,
		.remove		= fft_remove,
		.driver		= {
			.name = DRV_NAME,
			.owner = THIS_MODULE,
			.of_match_table = fft_device_ids,
		},
	},
	.xfer_input_ok	= fft_xfer_input_ok,
	.prep_xfer	= fft_prep_xfer,
	.ioctl_cm	= FFT_CHISEL_IOC_ACCESS,
	.arg_size	= sizeof(struct fft_chisel_access),
};

static int __init fft_init(void)
{
	return esp_driver_register(&fft_driver);
}

static void __exit fft_exit(void)
{
	esp_driver_unregister(&fft_driver);
}

module_init(fft_init)
module_exit(fft_exit)

MODULE_DEVICE_TABLE(of, fft_device_ids);

MODULE_AUTHOR("Emilio G. Cota <cota@braap.org>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("fft_chisel driver");
