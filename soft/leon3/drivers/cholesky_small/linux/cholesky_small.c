#include <linux/of_device.h>
#include <linux/mm.h>

#include <asm/io.h>

#include <esp_accelerator.h>
#include <esp.h>

#include "cholesky_small.h"

#define DRV_NAME	"cholesky_small"

/* <<--regs-->> */
#define CHOLESKY_SMALL_INPUT_ROWS_REG 0x44
#define CHOLESKY_SMALL_OUTPUT_ROWS_REG 0x40

struct cholesky_small_device {
	struct esp_device esp;
};

static struct esp_driver cholesky_small_driver;

static struct of_device_id cholesky_small_device_ids[] = {
	{
		.name = "SLD_CHOLESKY_SMALL",
	},
	{
		.name = "eb_056",
	},
	{
		.compatible = "sld,cholesky_small",
	},
	{ },
};

static int cholesky_small_devs;

static inline struct cholesky_small_device *to_cholesky_small(struct esp_device *esp)
{
	return container_of(esp, struct cholesky_small_device, esp);
}

static void cholesky_small_prep_xfer(struct esp_device *esp, void *arg)
{
	struct cholesky_small_access *a = arg;

	/* <<--regs-config-->> */
	iowrite32be(a->input_rows, esp->iomem + CHOLESKY_SMALL_INPUT_ROWS_REG);
	iowrite32be(a->output_rows, esp->iomem + CHOLESKY_SMALL_OUTPUT_ROWS_REG);
	iowrite32be(a->src_offset, esp->iomem + SRC_OFFSET_REG);
	iowrite32be(a->dst_offset, esp->iomem + DST_OFFSET_REG);

}

static bool cholesky_small_xfer_input_ok(struct esp_device *esp, void *arg)
{
	/* struct cholesky_small_device *cholesky_small = to_cholesky_small(esp); */
	/* struct cholesky_small_access *a = arg; */

	return true;
}

static int cholesky_small_probe(struct platform_device *pdev)
{
	struct cholesky_small_device *cholesky_small;
	struct esp_device *esp;
	int rc;

	cholesky_small = kzalloc(sizeof(*cholesky_small), GFP_KERNEL);
	if (cholesky_small == NULL)
		return -ENOMEM;
	esp = &cholesky_small->esp;
	esp->module = THIS_MODULE;
	esp->number = cholesky_small_devs;
	esp->driver = &cholesky_small_driver;
	rc = esp_device_register(esp, pdev);
	if (rc)
		goto err;

	cholesky_small_devs++;
	return 0;
 err:
	kfree(cholesky_small);
	return rc;
}

static int __exit cholesky_small_remove(struct platform_device *pdev)
{
	struct esp_device *esp = platform_get_drvdata(pdev);
	struct cholesky_small_device *cholesky_small = to_cholesky_small(esp);

	esp_device_unregister(esp);
	kfree(cholesky_small);
	return 0;
}

static struct esp_driver cholesky_small_driver = {
	.plat = {
		.probe		= cholesky_small_probe,
		.remove		= cholesky_small_remove,
		.driver		= {
			.name = DRV_NAME,
			.owner = THIS_MODULE,
			.of_match_table = cholesky_small_device_ids,
		},
	},
	.xfer_input_ok	= cholesky_small_xfer_input_ok,
	.prep_xfer	= cholesky_small_prep_xfer,
	.ioctl_cm	= CHOLESKY_SMALL_IOC_ACCESS,
	.arg_size	= sizeof(struct cholesky_small_access),
};

static int __init cholesky_small_init(void)
{
	return esp_driver_register(&cholesky_small_driver);
}

static void __exit cholesky_small_exit(void)
{
	esp_driver_unregister(&cholesky_small_driver);
}

module_init(cholesky_small_init)
module_exit(cholesky_small_exit)

MODULE_DEVICE_TABLE(of, cholesky_small_device_ids);

MODULE_AUTHOR("Emilio G. Cota <cota@braap.org>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("cholesky_small driver");
