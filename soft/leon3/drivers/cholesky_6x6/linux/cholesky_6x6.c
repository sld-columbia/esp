#include <linux/of_device.h>
#include <linux/mm.h>

#include <asm/io.h>

#include <esp_accelerator.h>
#include <esp.h>

#include "cholesky_6x6.h"

#define DRV_NAME	"cholesky_6x6"

/* <<--regs-->> */
#define CHOLESKY_6X6_INPUT_ROWS_REG 0x44
#define CHOLESKY_6X6_OUTPUT_ROWS_REG 0x40

struct cholesky_6x6_device {
	struct esp_device esp;
};

static struct esp_driver cholesky_6x6_driver;

static struct of_device_id cholesky_6x6_device_ids[] = {
	{
		.name = "SLD_CHOLESKY_6X6",
	},
	{
		.name = "eb_059",
	},
	{
		.compatible = "sld,cholesky_6x6",
	},
	{ },
};

static int cholesky_6x6_devs;

static inline struct cholesky_6x6_device *to_cholesky_6x6(struct esp_device *esp)
{
	return container_of(esp, struct cholesky_6x6_device, esp);
}

static void cholesky_6x6_prep_xfer(struct esp_device *esp, void *arg)
{
	struct cholesky_6x6_access *a = arg;

	/* <<--regs-config-->> */
	iowrite32be(a->input_rows, esp->iomem + CHOLESKY_6X6_INPUT_ROWS_REG);
	iowrite32be(a->output_rows, esp->iomem + CHOLESKY_6X6_OUTPUT_ROWS_REG);
	iowrite32be(a->src_offset, esp->iomem + SRC_OFFSET_REG);
	iowrite32be(a->dst_offset, esp->iomem + DST_OFFSET_REG);

}

static bool cholesky_6x6_xfer_input_ok(struct esp_device *esp, void *arg)
{
	/* struct cholesky_6x6_device *cholesky_6x6 = to_cholesky_6x6(esp); */
	/* struct cholesky_6x6_access *a = arg; */

	return true;
}

static int cholesky_6x6_probe(struct platform_device *pdev)
{
	struct cholesky_6x6_device *cholesky_6x6;
	struct esp_device *esp;
	int rc;

	cholesky_6x6 = kzalloc(sizeof(*cholesky_6x6), GFP_KERNEL);
	if (cholesky_6x6 == NULL)
		return -ENOMEM;
	esp = &cholesky_6x6->esp;
	esp->module = THIS_MODULE;
	esp->number = cholesky_6x6_devs;
	esp->driver = &cholesky_6x6_driver;
	rc = esp_device_register(esp, pdev);
	if (rc)
		goto err;

	cholesky_6x6_devs++;
	return 0;
 err:
	kfree(cholesky_6x6);
	return rc;
}

static int __exit cholesky_6x6_remove(struct platform_device *pdev)
{
	struct esp_device *esp = platform_get_drvdata(pdev);
	struct cholesky_6x6_device *cholesky_6x6 = to_cholesky_6x6(esp);

	esp_device_unregister(esp);
	kfree(cholesky_6x6);
	return 0;
}

static struct esp_driver cholesky_6x6_driver = {
	.plat = {
		.probe		= cholesky_6x6_probe,
		.remove		= cholesky_6x6_remove,
		.driver		= {
			.name = DRV_NAME,
			.owner = THIS_MODULE,
			.of_match_table = cholesky_6x6_device_ids,
		},
	},
	.xfer_input_ok	= cholesky_6x6_xfer_input_ok,
	.prep_xfer	= cholesky_6x6_prep_xfer,
	.ioctl_cm	= CHOLESKY_6X6_IOC_ACCESS,
	.arg_size	= sizeof(struct cholesky_6x6_access),
};

static int __init cholesky_6x6_init(void)
{
	return esp_driver_register(&cholesky_6x6_driver);
}

static void __exit cholesky_6x6_exit(void)
{
	esp_driver_unregister(&cholesky_6x6_driver);
}

module_init(cholesky_6x6_init)
module_exit(cholesky_6x6_exit)

MODULE_DEVICE_TABLE(of, cholesky_6x6_device_ids);

MODULE_AUTHOR("Emilio G. Cota <cota@braap.org>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("cholesky_6x6 driver");
