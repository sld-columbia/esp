#include <linux/of_device.h>
#include <linux/mm.h>

#include <asm/io.h>

#include <esp_accelerator.h>
#include <esp.h>

#include "conv2d_stratus.h"

#define DRV_NAME	"conv2d_stratus"

/* <<--regs-->> */
#define CONV2D_N_CHANNELS_REG 0x40
#define CONV2D_FEATURE_MAP_HEIGHT_REG 0x44
#define CONV2D_FEATURE_MAP_WIDTH_REG 0x48
#define CONV2D_N_FILTERS_REG 0x4c
#define CONV2D_FILTER_DIM_REG 0x50
#define CONV2D_IS_PADDED_REG 0x54
#define CONV2D_STRIDE_REG 0x58
#define CONV2D_DO_RELU_REG 0x5c
#define CONV2D_POOL_TYPE_REG 0x60
#define CONV2D_BATCH_SIZE_REG 0x64

struct conv2d_stratus_device {
	struct esp_device esp;
};

static struct esp_driver conv2d_driver;

static struct of_device_id conv2d_device_ids[] = {
	{
		.name = "SLD_CONV2D_STRATUS",
	},
	{
		.name = "eb_052",
	},
	{
		.compatible = "sld,conv2d_stratus",
	},
	{ },
};

static int conv2d_devs;

static inline struct conv2d_stratus_device *to_conv2d(struct esp_device *esp)
{
	return container_of(esp, struct conv2d_stratus_device, esp);
}

static void conv2d_prep_xfer(struct esp_device *esp, void *arg)
{
	struct conv2d_stratus_access *a = arg;

	/* <<--regs-config-->> */
	iowrite32be(a->n_channels, esp->iomem + CONV2D_N_CHANNELS_REG);
	iowrite32be(a->feature_map_height, esp->iomem + CONV2D_FEATURE_MAP_HEIGHT_REG);
	iowrite32be(a->feature_map_width, esp->iomem + CONV2D_FEATURE_MAP_WIDTH_REG);
	iowrite32be(a->n_filters, esp->iomem + CONV2D_N_FILTERS_REG);
	iowrite32be(a->filter_dim, esp->iomem + CONV2D_FILTER_DIM_REG);
	iowrite32be(a->is_padded, esp->iomem + CONV2D_IS_PADDED_REG);
	iowrite32be(a->stride, esp->iomem + CONV2D_STRIDE_REG);
	iowrite32be(a->do_relu, esp->iomem + CONV2D_DO_RELU_REG);
	iowrite32be(a->pool_type, esp->iomem + CONV2D_POOL_TYPE_REG);
	iowrite32be(a->batch_size, esp->iomem + CONV2D_BATCH_SIZE_REG);
	iowrite32be(a->src_offset, esp->iomem + SRC_OFFSET_REG);
	iowrite32be(a->dst_offset, esp->iomem + DST_OFFSET_REG);
}

static bool conv2d_xfer_input_ok(struct esp_device *esp, void *arg)
{
	/* struct conv2d_stratus_device *conv2d = to_conv2d(esp); */
	/* struct conv2d_stratus_access *a = arg; */

	return true;
}

static int conv2d_probe(struct platform_device *pdev)
{
	struct conv2d_stratus_device *conv2d;
	struct esp_device *esp;
	int rc;

	conv2d = kzalloc(sizeof(*conv2d), GFP_KERNEL);
	if (conv2d == NULL)
		return -ENOMEM;
	esp = &conv2d->esp;
	esp->module = THIS_MODULE;
	esp->number = conv2d_devs;
	esp->driver = &conv2d_driver;
	rc = esp_device_register(esp, pdev);
	if (rc)
		goto err;

	conv2d_devs++;
	return 0;
 err:
	kfree(conv2d);
	return rc;
}

static int __exit conv2d_remove(struct platform_device *pdev)
{
	struct esp_device *esp = platform_get_drvdata(pdev);
	struct conv2d_stratus_device *conv2d = to_conv2d(esp);

	esp_device_unregister(esp);
	kfree(conv2d);
	return 0;
}

static struct esp_driver conv2d_driver = {
	.plat = {
		.probe		= conv2d_probe,
		.remove		= conv2d_remove,
		.driver		= {
			.name = DRV_NAME,
			.owner = THIS_MODULE,
			.of_match_table = conv2d_device_ids,
		},
	},
	.xfer_input_ok	= conv2d_xfer_input_ok,
	.prep_xfer	= conv2d_prep_xfer,
	.ioctl_cm	= CONV2D_STRATUS_IOC_ACCESS,
	.arg_size	= sizeof(struct conv2d_stratus_access),
};

static int __init conv2d_init(void)
{
	return esp_driver_register(&conv2d_driver);
}

static void __exit conv2d_exit(void)
{
	esp_driver_unregister(&conv2d_driver);
}

module_init(conv2d_init)
module_exit(conv2d_exit)

MODULE_DEVICE_TABLE(of, conv2d_device_ids);

MODULE_AUTHOR("Emilio G. Cota <cota@braap.org>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("conv2d_stratus driver");
