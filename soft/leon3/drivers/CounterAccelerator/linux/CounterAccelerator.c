#include <linux/of_device.h>
#include <linux/mm.h>

#include <asm/io.h>

#include <esp_accelerator.h>
#include <esp.h>

#include "CounterAccelerator.h"

#define DRV_NAME	"CounterAccelerator"

#define COUNTERACCELERATOR_GITHASH_REG		0x40
#define COUNTERACCELERATOR_TICKS_REG		0x44

struct CounterAccelerator_device {
	struct esp_device esp;
};

static struct esp_driver CounterAccelerator_driver;

static struct of_device_id CounterAccelerator_device_ids[] = {
	{
		.name = "SLD_COUNTERACCELERATOR",
	},
	{
		.name = "eb_012",
	},
	{
		.compatible = "sld,CounterAccelerator",
	},
	{ },
};

static int CounterAccelerator_devs;

static inline struct CounterAccelerator_device *to_CounterAccelerator(struct esp_device *esp)
{
	return container_of(esp, struct CounterAccelerator_device, esp);
}

static void CounterAccelerator_prep_xfer(struct esp_device *esp, void *arg)
{
	struct CounterAccelerator_access *a = arg;

	iowrite32be(a->ticks, esp->iomem + COUNTERACCELERATOR_TICKS_REG);
}

static bool CounterAccelerator_xfer_input_ok(struct esp_device *esp, void *arg)
{
	struct CounterAccelerator_access *a = arg;

	if (a->ticks >= (1<<16) || a->ticks < 1)
		return false;
	return true;
}

static int CounterAccelerator_probe(struct platform_device *pdev)
{
	struct CounterAccelerator_device *CounterAccelerator;
	struct esp_device *esp;
	int rc;

	CounterAccelerator = kzalloc(sizeof(*CounterAccelerator), GFP_KERNEL);
	if (CounterAccelerator == NULL)
		return -ENOMEM;
	esp = &CounterAccelerator->esp;
	esp->module = THIS_MODULE;
	esp->number = CounterAccelerator_devs;
	esp->driver = &CounterAccelerator_driver;
	rc = esp_device_register(esp, pdev);
	if (rc)
		goto err;

	CounterAccelerator_devs++;
	return 0;
 err:
	kfree(CounterAccelerator);
	return rc;
}

static int __exit CounterAccelerator_remove(struct platform_device *pdev)
{
	struct esp_device *esp = platform_get_drvdata(pdev);
	struct CounterAccelerator_device *CounterAccelerator = to_CounterAccelerator(esp);

	esp_device_unregister(esp);
	kfree(CounterAccelerator);
	return 0;
}

static struct esp_driver CounterAccelerator_driver = {
	.plat = {
		.probe		= CounterAccelerator_probe,
		.remove		= CounterAccelerator_remove,
		.driver		= {
			.name = DRV_NAME,
			.owner = THIS_MODULE,
			.of_match_table = CounterAccelerator_device_ids,
		},
	},
	.xfer_input_ok	= CounterAccelerator_xfer_input_ok,
	.prep_xfer	= CounterAccelerator_prep_xfer,
	.ioctl_cm	= COUNTERACCELERATOR_IOC_ACCESS,
	.arg_size	= sizeof(struct CounterAccelerator_access),
};

static int __init CounterAccelerator_init(void)
{
	return esp_driver_register(&CounterAccelerator_driver);
}

static void __exit CounterAccelerator_exit(void)
{
	esp_driver_unregister(&CounterAccelerator_driver);
}

module_init(CounterAccelerator_init)
module_exit(CounterAccelerator_exit)

MODULE_DEVICE_TABLE(of, CounterAccelerator_device_ids);

MODULE_AUTHOR("Emilio G. Cota <cota@braap.org>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("CounterAccelerator driver");
