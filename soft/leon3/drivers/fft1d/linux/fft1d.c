#include <linux/of_device.h>
#include <linux/mm.h>

#include <asm/io.h>

#include <esp_accelerator.h>
#include <esp.h>

#include "fft1d.h"

#define DRV_NAME	"fft1d"

/* user defined registers */
#define FFT_REG_LEN		0x40
#define FFT_REG_LOG_LEN		0x44
#define FFT_REG_MAX_LOG_LEN	0x48

struct fft_device {
	struct esp_device esp;
	size_t max_size; /* Maximum buffer size to be DMA'd to/from in bytes */
	unsigned max_log2;
};

static struct esp_driver fft_driver;

static struct of_device_id fft_device_ids[] = {
	{
		.name = "SLD_FFT",
	},
	{
		.name = "eb_010",
	},
	{ },
};

static int fft_devs;

static inline struct fft_device *to_fft(struct esp_device *esp)
{
	return container_of(esp, struct fft_device, esp);
}

static void fft_prep_xfer(struct esp_device *esp, void *arg)
{
	struct fft1d_access *access = arg;
	unsigned size = 1 << access->log2;

	iowrite32be(size, esp->iomem + FFT_REG_LEN);
	iowrite32be(access->log2, esp->iomem + FFT_REG_LOG_LEN);
}

static bool fft_xfer_input_ok(struct esp_device *esp, void *arg)
{
	struct fft_device *fft = to_fft(esp);
	struct fft1d_access *access = arg;

	if (access->log2 < 1 || access->log2 > fft->max_log2)
		return false;
	return true;
}

static int fft_probe(struct platform_device *pdev)
{
	struct fft_device *fft;
	struct esp_device *esp;
	size_t max_size;
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

	fft->max_log2 = ioread32be(esp->iomem + FFT_REG_MAX_LOG_LEN);
	max_size = (1 << fft->max_log2);
	max_size = max_size * 2 * sizeof(u32);
	fft->max_size = round_up(max_size, PAGE_SIZE);
	dev_info(esp->pdev, "fft1d max log2: %u\n", fft->max_log2);

	fft_devs++;
	return 0;
 err:
	kfree(fft);
	return rc;
}

static int __exit fft_remove(struct platform_device *pdev)
{
	struct esp_device *esp = platform_get_drvdata(pdev);
	struct fft_device *fft = to_fft(esp);

	esp_device_unregister(esp);
	kfree(fft);
	return 0;
}

static struct esp_driver fft_driver = {
	.plat = {
		.probe	= fft_probe,
		.remove	= fft_remove,
		.driver	= {
			.name = DRV_NAME,
			.owner = THIS_MODULE,
			.of_match_table = fft_device_ids,
		},
	},
	.xfer_input_ok	= fft_xfer_input_ok,
	.prep_xfer	= fft_prep_xfer,
	.ioctl_cm	= FFT1D_IOC_ACCESS,
	.arg_size	= sizeof(struct fft1d_access),
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
MODULE_DESCRIPTION("fft driver");
