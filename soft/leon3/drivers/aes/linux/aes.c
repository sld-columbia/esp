#include <linux/of_device.h>
#include <linux/mm.h>

#include <asm/io.h>

#include <esp_accelerator.h>
#include <esp.h>

#include "aes.h"

#define DRV_NAME	"aes"

/* <<--regs-->> */
#define AES_NUM_BLOCKS_REG 0x40
#define AES_ENCRYPTION_REG 0x44

struct aes_device {
	struct esp_device esp;
};

static struct esp_driver aes_driver;

static struct of_device_id aes_device_ids[] = {
	{
		.name = "SLD_AES",
	},
	{
		.name = "eb_04a",
	},
	{
		.compatible = "sld,aes",
	},
	{ },
};

static int aes_devs;

static inline struct aes_device *to_aes(struct esp_device *esp)
{
	return container_of(esp, struct aes_device, esp);
}

static void aes_prep_xfer(struct esp_device *esp, void *arg)
{
	struct aes_access *a = arg;

	/* <<--regs-config-->> */
	iowrite32be(a->encryption, esp->iomem + AES_ENCRYPTION_REG);
	iowrite32be(a->num_blocks, esp->iomem + AES_NUM_BLOCKS_REG);
	iowrite32be(a->src_offset, esp->iomem + SRC_OFFSET_REG);
	iowrite32be(a->dst_offset, esp->iomem + DST_OFFSET_REG);

}

static bool aes_xfer_input_ok(struct esp_device *esp, void *arg)
{
	/* struct aes_device *aes = to_aes(esp); */
	/* struct aes_access *a = arg; */

	return true;
}

static int aes_probe(struct platform_device *pdev)
{
	struct aes_device *aes;
	struct esp_device *esp;
	int rc;

	aes = kzalloc(sizeof(*aes), GFP_KERNEL);
	if (aes == NULL)
		return -ENOMEM;
	esp = &aes->esp;
	esp->module = THIS_MODULE;
	esp->number = aes_devs;
	esp->driver = &aes_driver;
	rc = esp_device_register(esp, pdev);
	if (rc)
		goto err;

	aes_devs++;
	return 0;
 err:
	kfree(aes);
	return rc;
}

static int __exit aes_remove(struct platform_device *pdev)
{
	struct esp_device *esp = platform_get_drvdata(pdev);
	struct aes_device *aes = to_aes(esp);

	esp_device_unregister(esp);
	kfree(aes);
	return 0;
}

static struct esp_driver aes_driver = {
	.plat = {
		.probe		= aes_probe,
		.remove		= aes_remove,
		.driver		= {
			.name = DRV_NAME,
			.owner = THIS_MODULE,
			.of_match_table = aes_device_ids,
		},
	},
	.xfer_input_ok	= aes_xfer_input_ok,
	.prep_xfer	= aes_prep_xfer,
	.ioctl_cm	= AES_IOC_ACCESS,
	.arg_size	= sizeof(struct aes_access),
};

static int __init aes_init(void)
{
	return esp_driver_register(&aes_driver);
}

static void __exit aes_exit(void)
{
	esp_driver_unregister(&aes_driver);
}

module_init(aes_init)
module_exit(aes_exit)

MODULE_DEVICE_TABLE(of, aes_device_ids);

MODULE_AUTHOR("Emilio G. Cota <cota@braap.org>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("aes driver");
