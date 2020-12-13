#include <linux/of_device.h>
#include <linux/mm.h>

#include <asm/io.h>

#include <esp_accelerator.h>
#include <esp.h>

#include "AdderAccelerator.h"

#define DRV_NAME	"adderaccelerator"

/* <<--regs-->> */
#define ADDERACCELERATOR_WRITEADDR_REG 0x48
#define ADDERACCELERATOR_SIZE_REG 0x44
#define ADDERACCELERATOR_READADDR_REG 0x40

struct adderaccelerator_device {
	struct esp_device esp;
};

static struct esp_driver adderaccelerator_driver;

static struct of_device_id adderaccelerator_device_ids[] = {
	{
		.name = "SLD_ADDERACCELERATOR",
	},
	{
		.name = "eb_013",
	},
	{
		.compatible = "sld,adderaccelerator",
	},
	{ },
};

static int adderaccelerator_devs;

static inline struct adderaccelerator_device *to_adderaccelerator(struct esp_device *esp)
{
	return container_of(esp, struct adderaccelerator_device, esp);
}

static void adderaccelerator_prep_xfer(struct esp_device *esp, void *arg)
{
	struct adderaccelerator_access *a = arg;

	/* <<--regs-config-->> */
	iowrite32be(a->readAddr, esp->iomem + ADDERACCELERATOR_READADDR_REG);
	iowrite32be(a->size, esp->iomem + ADDERACCELERATOR_SIZE_REG);
	iowrite32be(a->writeAddr, esp->iomem + ADDERACCELERATOR_WRITEADDR_REG);

	iowrite32be(a->src_offset, esp->iomem + SRC_OFFSET_REG);
	iowrite32be(a->dst_offset, esp->iomem + DST_OFFSET_REG);

}

static bool adderaccelerator_xfer_input_ok(struct esp_device *esp, void *arg)
{
	/* struct adderaccelerator_device *adderaccelerator = to_adderaccelerator(esp); */
	/* struct adderaccelerator_access *a = arg; */

	return true;
}

static int adderaccelerator_probe(struct platform_device *pdev)
{
	struct adderaccelerator_device *adderaccelerator;
	struct esp_device *esp;
	int rc;

	adderaccelerator = kzalloc(sizeof(*adderaccelerator), GFP_KERNEL);
	if (adderaccelerator == NULL)
		return -ENOMEM;
	esp = &adderaccelerator->esp;
	esp->module = THIS_MODULE;
	esp->number = adderaccelerator_devs;
	esp->driver = &adderaccelerator_driver;
	rc = esp_device_register(esp, pdev);
	if (rc)
		goto err;

	adderaccelerator_devs++;
	return 0;
 err:
	kfree(adderaccelerator);
	return rc;
}

static int __exit adderaccelerator_remove(struct platform_device *pdev)
{
	struct esp_device *esp = platform_get_drvdata(pdev);
	struct adderaccelerator_device *adderaccelerator = to_adderaccelerator(esp);

	esp_device_unregister(esp);
	kfree(adderaccelerator);
	return 0;
}

static struct esp_driver adderaccelerator_driver = {
	.plat = {
		.probe		= adderaccelerator_probe,
		.remove		= adderaccelerator_remove,
		.driver		= {
			.name = DRV_NAME,
			.owner = THIS_MODULE,
			.of_match_table = adderaccelerator_device_ids,
		},
	},
	.xfer_input_ok	= adderaccelerator_xfer_input_ok,
	.prep_xfer	= adderaccelerator_prep_xfer,
	.ioctl_cm	= ADDERACCELERATOR_IOC_ACCESS,
	.arg_size	= sizeof(struct adderaccelerator_access),
};

static int __init adderaccelerator_init(void)
{
	return esp_driver_register(&adderaccelerator_driver);
}

static void __exit adderaccelerator_exit(void)
{
	esp_driver_unregister(&adderaccelerator_driver);
}

module_init(adderaccelerator_init)
module_exit(adderaccelerator_exit)

MODULE_DEVICE_TABLE(of, adderaccelerator_device_ids);

MODULE_AUTHOR("Emilio G. Cota <cota@braap.org>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("adderaccelerator driver");
