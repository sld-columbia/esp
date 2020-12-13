#include <linux/of_device.h>
#include <linux/mm.h>

#include <asm/io.h>

#include <esp_accelerator.h>
#include <esp.h>

#include "FFTAccelerator.h"

#define DRV_NAME	"fftaccelerator"

/* <<--regs-->> */
#define FFTACCELERATOR_STRIDE_REG 0x50
#define FFTACCELERATOR_COUNT_REG 0x4C
#define FFTACCELERATOR_STARTADDR_REG 0x48

struct fftaccelerator_device {
	struct esp_device esp;
};

static struct esp_driver fftaccelerator_driver;

static struct of_device_id fftaccelerator_device_ids[] = {
	{
		.name = "SLD_FFTACCELERATOR",
	},
	{
		.name = "eb_013",
	},
	{
		.compatible = "sld,fftaccelerator",
	},
	{ },
};

static int fftaccelerator_devs;

static inline struct fftaccelerator_device *to_fftaccelerator(struct esp_device *esp)
{
	return container_of(esp, struct fftaccelerator_device, esp);
}

static void fftaccelerator_prep_xfer(struct esp_device *esp, void *arg)
{
	struct fftaccelerator_access *a = arg;

	/* <<--regs-config-->> */
	iowrite32be(a->stride, esp->iomem + FFTACCELERATOR_STRIDE_REG);
	iowrite32be(1, esp->iomem + FFTACCELERATOR_COUNT_REG);
	iowrite32be(0, esp->iomem + FFTACCELERATOR_STARTADDR_REG);
	iowrite32be(a->src_offset, esp->iomem + SRC_OFFSET_REG);
	iowrite32be(a->dst_offset, esp->iomem + DST_OFFSET_REG);

}

static bool fftaccelerator_xfer_input_ok(struct esp_device *esp, void *arg)
{
	/* struct fftaccelerator_device *fftaccelerator = to_fftaccelerator(esp); */
	/* struct fftaccelerator_access *a = arg; */

	return true;
}

static int fftaccelerator_probe(struct platform_device *pdev)
{
	struct fftaccelerator_device *fftaccelerator;
	struct esp_device *esp;
	int rc;

	fftaccelerator = kzalloc(sizeof(*fftaccelerator), GFP_KERNEL);
	if (fftaccelerator == NULL)
		return -ENOMEM;
	esp = &fftaccelerator->esp;
	esp->module = THIS_MODULE;
	esp->number = fftaccelerator_devs;
	esp->driver = &fftaccelerator_driver;
	rc = esp_device_register(esp, pdev);
	if (rc)
		goto err;

	fftaccelerator_devs++;
	return 0;
 err:
	kfree(fftaccelerator);
	return rc;
}

static int __exit fftaccelerator_remove(struct platform_device *pdev)
{
	struct esp_device *esp = platform_get_drvdata(pdev);
	struct fftaccelerator_device *fftaccelerator = to_fftaccelerator(esp);

	esp_device_unregister(esp);
	kfree(fftaccelerator);
	return 0;
}

static struct esp_driver fftaccelerator_driver = {
	.plat = {
		.probe		= fftaccelerator_probe,
		.remove		= fftaccelerator_remove,
		.driver		= {
			.name = DRV_NAME,
			.owner = THIS_MODULE,
			.of_match_table = fftaccelerator_device_ids,
		},
	},
	.xfer_input_ok	= fftaccelerator_xfer_input_ok,
	.prep_xfer	= fftaccelerator_prep_xfer,
	.ioctl_cm	= FFTACCELERATOR_IOC_ACCESS,
	.arg_size	= sizeof(struct fftaccelerator_access),
};

static int __init fftaccelerator_init(void)
{
	return esp_driver_register(&fftaccelerator_driver);
}

static void __exit fftaccelerator_exit(void)
{
	esp_driver_unregister(&fftaccelerator_driver);
}

module_init(fftaccelerator_init)
module_exit(fftaccelerator_exit)

MODULE_DEVICE_TABLE(of, fftaccelerator_device_ids);

MODULE_AUTHOR("Emilio G. Cota <cota@braap.org>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("fftaccelerator driver");
