#include <linux/of_device.h>
#include <linux/mm.h>

#include <asm/io.h>

#include <esp_accelerator.h>
#include <esp.h>

#include "debayer.h"

#define DRV_NAME	"debayer"

#define DEBAYER_ROWS_REG 0x40
#define DEBAYER_COLS_REG 0x44
#define DEBAYER_ROWS_MAX_REG 0x48

#define DEBAYER_INPUT_SIZE(__row, __col) ((__row) * (__col) * 2)
#define DEBAYER_OUTPUT_SIZE(__row, __col) (((__row) -4) * ((__col) - 4) * 6)
#define DEBAYER_BUF_SIZE(__row, __col)		\
	(DEBAYER_INPUT_SIZE(__row, __col) + DEBAYER_OUTPUT_SIZE(__row, __col))

struct debayer_device {
	struct esp_device esp;
	size_t max_size;
	unsigned rows_max;
};

static struct esp_driver debayer_driver;

static struct of_device_id debayer_device_ids[] = {
	{
		.name = "SLD_DEBAYER",
	},
	{
		.name = "eb_00d",
	},
	{ },
};

static int debayer_devs;

static inline struct debayer_device *to_debayer(struct esp_device *esp)
{
	return container_of(esp, struct debayer_device, esp);
}

static void debayer_prep_xfer(struct esp_device *esp, void *arg)
{
	struct debayer_access *a = arg;
	unsigned int dest = DEBAYER_INPUT_SIZE(a->rows, a->cols);

	iowrite32be(dest, esp->iomem + DST_OFFSET_REG);
	iowrite32be(a->rows, esp->iomem + DEBAYER_ROWS_REG);
	iowrite32be(a->cols, esp->iomem + DEBAYER_COLS_REG);
}

static bool debayer_xfer_input_ok(struct esp_device *esp, void *arg)
{
	struct debayer_device *debayer = to_debayer(esp);
	struct debayer_access *a = arg;

	if (a->rows  < 8 || a->rows > debayer->rows_max ||
		a->cols < 8 || a->cols > debayer->rows_max)
		return false;
	return true;
}

static int debayer_probe(struct platform_device *pdev)
{
	struct debayer_device *debayer;
	struct esp_device *esp;
	int rc;

	debayer = kzalloc(sizeof(*debayer), GFP_KERNEL);
	if (debayer == NULL)
		return -ENOMEM;
	esp = &debayer->esp;
	esp->module = THIS_MODULE;
	esp->number = debayer_devs;
	esp->driver = &debayer_driver;
	rc = esp_device_register(esp, pdev);
	if (rc)
		goto err;

	debayer->rows_max = ioread32be(esp->iomem + DEBAYER_ROWS_MAX_REG);
	debayer->max_size = round_up(DEBAYER_BUF_SIZE(debayer->rows_max, debayer->rows_max), PAGE_SIZE);
	debayer_devs++;
	return 0;

 err:
	kfree(debayer);
	return rc;
}

static int __exit debayer_remove(struct platform_device *pdev)
{
	struct esp_device *esp = platform_get_drvdata(pdev);
	struct debayer_device *debayer = to_debayer(esp);

	esp_device_unregister(esp);
	kfree(debayer);
	return 0;
}

static struct esp_driver debayer_driver = {
	.plat = {
		.probe		= debayer_probe,
		.remove		= debayer_remove,
		.driver		= {
			.name = DRV_NAME,
			.owner = THIS_MODULE,
			.of_match_table = debayer_device_ids,
		},
	},
	.xfer_input_ok	= debayer_xfer_input_ok,
	.prep_xfer	= debayer_prep_xfer,
	.ioctl_cm	= DEBAYER_IOC_ACCESS,
	.arg_size	= sizeof(struct debayer_access),
};

static int __init debayer_init(void)
{
	return esp_driver_register(&debayer_driver);
}

static void __exit debayer_exit(void)
{
	esp_driver_unregister(&debayer_driver);
}

module_init(debayer_init)
module_exit(debayer_exit)

MODULE_DEVICE_TABLE(of, debayer_device_ids);

MODULE_AUTHOR("Emilio G. Cota <cota@braap.org>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("debayer driver");

