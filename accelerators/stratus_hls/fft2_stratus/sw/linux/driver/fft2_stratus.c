#include <linux/of_device.h>
#include <linux/mm.h>

#include <asm/io.h>

#include <esp_accelerator.h>
#include <esp.h>

#include "fft2_stratus.h"

#define DRV_NAME	"fft2_stratus"

/* <<--regs-->> */
#define FFT2_LOGN_SAMPLES_REG 0x40
#define FFT2_NUM_FFTS_REG 0x44
#define FFT2_DO_INVERSE_REG 0x48
#define FFT2_DO_SHIFT_REG 0x4c
#define FFT2_SCALE_FACTOR_REG 0x50

struct fft2_stratus_device {
	struct esp_device esp;
};

static struct esp_driver fft2_driver;

static struct of_device_id fft2_device_ids[] = {
	{
		.name = "SLD_FFT2_STRATUS",
	},
	{
		.name = "eb_057",
	},
	{
		.compatible = "sld,fft2_stratus",
	},
	{ },
};

static int fft2_devs;

static inline struct fft2_stratus_device *to_fft2(struct esp_device *esp)
{
	return container_of(esp, struct fft2_stratus_device, esp);
}

static void fft2_prep_xfer(struct esp_device *esp, void *arg)
{
	struct fft2_stratus_access *a = arg;

	/* <<--regs-config-->> */
	iowrite32be(a->scale_factor, esp->iomem + FFT2_SCALE_FACTOR_REG);
	iowrite32be(a->do_inverse, esp->iomem + FFT2_DO_INVERSE_REG);
	iowrite32be(a->logn_samples, esp->iomem + FFT2_LOGN_SAMPLES_REG);
	iowrite32be(a->do_shift, esp->iomem + FFT2_DO_SHIFT_REG);
	iowrite32be(a->num_ffts, esp->iomem + FFT2_NUM_FFTS_REG);
	iowrite32be(a->src_offset, esp->iomem + SRC_OFFSET_REG);
	iowrite32be(a->dst_offset, esp->iomem + DST_OFFSET_REG);

}

static bool fft2_xfer_input_ok(struct esp_device *esp, void *arg)
{
	/* struct fft2_stratus_device *fft2 = to_fft2(esp); */
	/* struct fft2_stratus_access *a = arg; */

	return true;
}

static int fft2_probe(struct platform_device *pdev)
{
	struct fft2_stratus_device *fft2;
	struct esp_device *esp;
	int rc;

	fft2 = kzalloc(sizeof(*fft2), GFP_KERNEL);
	if (fft2 == NULL)
		return -ENOMEM;
	esp = &fft2->esp;
	esp->module = THIS_MODULE;
	esp->number = fft2_devs;
	esp->driver = &fft2_driver;
	rc = esp_device_register(esp, pdev);
	if (rc)
		goto err;

	fft2_devs++;
	return 0;
 err:
	kfree(fft2);
	return rc;
}

static int __exit fft2_remove(struct platform_device *pdev)
{
	struct esp_device *esp = platform_get_drvdata(pdev);
	struct fft2_stratus_device *fft2 = to_fft2(esp);

	esp_device_unregister(esp);
	kfree(fft2);
	return 0;
}

static struct esp_driver fft2_driver = {
	.plat = {
		.probe		= fft2_probe,
		.remove		= fft2_remove,
		.driver		= {
			.name = DRV_NAME,
			.owner = THIS_MODULE,
			.of_match_table = fft2_device_ids,
		},
	},
	.xfer_input_ok	= fft2_xfer_input_ok,
	.prep_xfer	= fft2_prep_xfer,
	.ioctl_cm	= FFT2_STRATUS_IOC_ACCESS,
	.arg_size	= sizeof(struct fft2_stratus_access),
};

static int __init fft2_init(void)
{
	return esp_driver_register(&fft2_driver);
}

static void __exit fft2_exit(void)
{
	esp_driver_unregister(&fft2_driver);
}

module_init(fft2_init)
module_exit(fft2_exit)

MODULE_DEVICE_TABLE(of, fft2_device_ids);

MODULE_AUTHOR("Emilio G. Cota <cota@braap.org>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("fft2_stratus driver");
