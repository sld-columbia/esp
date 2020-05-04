#include <linux/of_device.h>
#include <linux/mm.h>

#include <asm/io.h>

#include <esp_accelerator.h>
#include <esp.h>

#include "obfuscator.h"

#define DRV_NAME	"obfuscator"

/* <<--regs-->> */
#define OBFUSCATOR_NUM_ROWS_REG   0x40
#define OBFUSCATOR_NUM_COLS_REG   0x44
#define OBFUSCATOR_I_ROW_BLUR_REG 0x48
#define OBFUSCATOR_I_COL_BLUR_REG 0x4c
#define OBFUSCATOR_E_ROW_BLUR_REG 0x50
#define OBFUSCATOR_E_COL_BLUR_REG 0x54
#define OBFUSCATOR_LD_OFFSET_REG  0x58
#define OBFUSCATOR_ST_OFFSET_REG  0x5c

struct obfuscator_device {
	struct esp_device esp;
};

static struct esp_driver obfuscator_driver;

static struct of_device_id obfuscator_device_ids[] = {
	{
		.name = "SLD_OBFUSCATOR",
	},
	{
		.name = "eb_04a",
	},
	{
		.compatible = "sld,obfuscator",
	},
	{ },
};

static int obfuscator_devs;

static inline struct obfuscator_device *to_obfuscator(struct esp_device *esp)
{
	return container_of(esp, struct obfuscator_device, esp);
}

static void obfuscator_prep_xfer(struct esp_device *esp, void *arg)
{
	struct obfuscator_access *a = arg;

	/* <<--regs-config-->> */
	iowrite32be(a->num_rows,   esp->iomem + OBFUSCATOR_NUM_ROWS_REG);
	iowrite32be(a->num_cols,   esp->iomem + OBFUSCATOR_NUM_COLS_REG);
	iowrite32be(a->i_row_blur, esp->iomem + OBFUSCATOR_I_ROW_BLUR_REG);
	iowrite32be(a->i_col_blur, esp->iomem + OBFUSCATOR_I_COL_BLUR_REG);
    iowrite32be(a->e_row_blur, esp->iomem + OBFUSCATOR_E_ROW_BLUR_REG);
	iowrite32be(a->e_col_blur, esp->iomem + OBFUSCATOR_E_COL_BLUR_REG);
	iowrite32be(a->ld_offset,  esp->iomem + OBFUSCATOR_LD_OFFSET_REG);
	iowrite32be(a->st_offset,  esp->iomem + OBFUSCATOR_ST_OFFSET_REG);
    iowrite32be(a->src_offset, esp->iomem + SRC_OFFSET_REG);
	iowrite32be(a->dst_offset, esp->iomem + DST_OFFSET_REG);
}

static bool obfuscator_xfer_input_ok(struct esp_device *esp, void *arg)
{
	/* struct obfuscator_device *obfuscator = to_obfuscator(esp); */
	/* struct obfuscator_access *a = arg; */

	return true;
}

static int obfuscator_probe(struct platform_device *pdev)
{
	struct obfuscator_device *obfuscator;
	struct esp_device *esp;
	int rc;

	obfuscator = kzalloc(sizeof(*obfuscator), GFP_KERNEL);
	if (obfuscator == NULL)
		return -ENOMEM;
	esp = &obfuscator->esp;
	esp->module = THIS_MODULE;
	esp->number = obfuscator_devs;
	esp->driver = &obfuscator_driver;
	rc = esp_device_register(esp, pdev);
	if (rc)
		goto err;

	obfuscator_devs++;
	return 0;
 err:
	kfree(obfuscator);
	return rc;
}

static int __exit obfuscator_remove(struct platform_device *pdev)
{
	struct esp_device *esp = platform_get_drvdata(pdev);
	struct obfuscator_device *obfuscator = to_obfuscator(esp);

	esp_device_unregister(esp);
	kfree(obfuscator);
	return 0;
}

static struct esp_driver obfuscator_driver = {
	.plat = {
		.probe		= obfuscator_probe,
		.remove		= obfuscator_remove,
		.driver		= {
			.name = DRV_NAME,
			.owner = THIS_MODULE,
			.of_match_table = obfuscator_device_ids,
		},
	},
	.xfer_input_ok	= obfuscator_xfer_input_ok,
	.prep_xfer	= obfuscator_prep_xfer,
	.ioctl_cm	= OBFUSCATOR_IOC_ACCESS,
	.arg_size	= sizeof(struct obfuscator_access),
};

static int __init obfuscator_init(void)
{
	return esp_driver_register(&obfuscator_driver);
}

static void __exit obfuscator_exit(void)
{
	esp_driver_unregister(&obfuscator_driver);
}

module_init(obfuscator_init)
module_exit(obfuscator_exit)

MODULE_DEVICE_TABLE(of, obfuscator_device_ids);

MODULE_AUTHOR("Emilio G. Cota <cota@braap.org>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("obfuscator driver");
