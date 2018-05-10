#include <linux/of_device.h>
#include <linux/mm.h>

#include <asm/io.h>

#include <esp_accelerator.h>
#include <esp.h>

#include "fft2d.h"

#define DRV_NAME	"fft2d"

/* user defined registers */
#define FFT2D_REG_SIZE	    0x40
#define FFT2D_REG_LOG2 	    0x44
//#define FFT2D_REG_MAX_LOG2  0x48
#define FFT2D_REG_BATCH     0x48
#define FFT2D_REG_TRANSPOSE 0x4C

struct fft2d_device {
	struct esp_device esp;
	size_t max_size; /* Maximum buffer size to be DMA'd to/from in bytes */
	unsigned max_log2;
};

static struct esp_driver fft2d_driver;

static struct of_device_id fft2d_device_ids[] = {
	{
		.name = "SLD_FFT2D",
	},
	{
		.name = "eb_011",
	},
	{ },
};

static int fft2d_devs;

static inline struct fft2d_device *to_fft2d(struct esp_device *esp)
{
	return container_of(esp, struct fft2d_device, esp);
}

static void fft2d_prep_xfer(struct esp_device *esp, void *arg)
{
	struct fft2d_access *access = arg;
	unsigned size = 1 << access->log2;

	esp->coherence = access->esp.coherence;
	iowrite32be(size, esp->iomem + FFT2D_REG_SIZE);
	iowrite32be(access->log2, esp->iomem + FFT2D_REG_LOG2);
	iowrite32be(size, esp->iomem + FFT2D_REG_BATCH);
	iowrite32be(access->transpose, esp->iomem + FFT2D_REG_TRANSPOSE);
}

static bool fft2d_xfer_input_ok(struct esp_device *esp, void *arg)
{
	struct fft2d_device *fft2d = to_fft2d(esp);
	struct fft2d_access *access = arg;

	if (access->log2 < 1 || access->log2 > fft2d->max_log2)
		return false;
	return true;
}

static int fft2d_probe(struct platform_device *pdev)
{
	struct fft2d_device *fft2d;
	struct esp_device *esp;
	size_t max_size;
	int rc;

	fft2d = kzalloc(sizeof(*fft2d), GFP_KERNEL);
	if (fft2d == NULL)
		return -ENOMEM;
	esp = &fft2d->esp;
	esp->module = THIS_MODULE;
	esp->number = fft2d_devs;
	esp->driver = &fft2d_driver;
	rc = esp_device_register(esp, pdev);
	if (rc)
		goto err;

	fft2d->max_log2 = 12;//ioread32be(esp->iomem + FFT2D_REG_MAX_LOG2);
	if (fft2d->max_log2 > 12) {
		dev_info(esp->pdev, "max log2 will be 11 instead of %d\n", fft2d->max_log2);
		fft2d->max_log2 = 11;
	}
	max_size = 1 << fft2d->max_log2;
	max_size *= max_size;
	max_size = max_size * 2 * sizeof(u32) * 2;
	fft2d->max_size = round_up(max_size, PAGE_SIZE);
	dev_info(esp->pdev, "max buf size: %zu\n", fft2d->max_size);

	fft2d_devs++;
	return 0;
 err:
	kfree(fft2d);
	return rc;
}

static int __exit fft2d_remove(struct platform_device *pdev)
{
	struct esp_device *esp = platform_get_drvdata(pdev);
	struct fft2d_device *fft2d = to_fft2d(esp);

	esp_device_unregister(esp);
	kfree(fft2d);
	return 0;
}

static struct esp_driver fft2d_driver = {
	.plat	= {
		.probe	= fft2d_probe,
		.remove	= fft2d_remove,
		.driver	= {
			.name = DRV_NAME,
			.owner = THIS_MODULE,
			.of_match_table = fft2d_device_ids,
		},
	},
	.xfer_input_ok	= fft2d_xfer_input_ok,
	.prep_xfer	= fft2d_prep_xfer,
	.ioctl_cm	= FFT2D_IOC_ACCESS,
	.arg_size	= sizeof(struct fft2d_access),
};

static int __init fft2d_init(void)
{
	return esp_driver_register(&fft2d_driver);
}

static void __exit fft2d_exit(void)
{
	esp_driver_unregister(&fft2d_driver);
}

module_init(fft2d_init)
module_exit(fft2d_exit)

MODULE_DEVICE_TABLE(of, fft2d_device_ids);

MODULE_AUTHOR("Emilio G. Cota <cota@braap.org>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("fft2d driver");
