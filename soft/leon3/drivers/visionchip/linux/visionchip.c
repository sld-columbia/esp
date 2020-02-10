#include <linux/of_device.h>
#include <linux/mm.h>
#include <linux/log2.h>

#include <asm/io.h>

#include <esp_accelerator.h>
#include <esp.h>

#include "visionchip.h"

#define DRV_NAME	"visionchip"

#define VISIONCHIP_NIMAGES_REG	0x40
#define VISIONCHIP_ROWS_REG	0x44
#define VISIONCHIP_COLS_REG	0x48
#define VISIONCHIP_DO_DWT_REG	0x4C

struct visionchip_device {
	struct esp_device esp;
};

static struct esp_driver visionchip_driver;

static struct of_device_id visionchip_device_ids[] = {
	{
		.name = "SLD_VISIONCHIP",
	},
	{
		.name = "eb_011",
	},
	{
		.compatible = "sld,visionchip",
	},
	{ },
};

static int visionchip_devs;

static inline struct visionchip_device *to_visionchip(struct esp_device *esp)
{
	return container_of(esp, struct visionchip_device, esp);
}

static void visionchip_prep_xfer(struct esp_device *esp, void *arg)
{
	struct visionchip_access *a = arg;

	iowrite32be(a->nimages, esp->iomem + VISIONCHIP_NIMAGES_REG);
	iowrite32be(a->rows, esp->iomem + VISIONCHIP_ROWS_REG);
	iowrite32be(a->cols, esp->iomem + VISIONCHIP_COLS_REG);
	iowrite32be(a->do_dwt, esp->iomem + VISIONCHIP_DO_DWT_REG);
	iowrite32be(a->src_offset, esp->iomem + SRC_OFFSET_REG);
	iowrite32be(a->dst_offset, esp->iomem + DST_OFFSET_REG);
}

static bool visionchip_xfer_input_ok(struct esp_device *esp, void *arg)
{
	struct visionchip_access *a = arg;

        if (a->nimages > MAX_NIMAGES)
	        return false;

        if (a->rows > MAX_ROWS)
		return false;

        if (a->cols > MAX_COLS)
	        return false;

        if (a->do_dwt != 0 && a->do_dwt != 1)
	        return false;

	return true;
}

static int visionchip_probe(struct platform_device *pdev)
{
	struct visionchip_device *visionchip;
	struct esp_device *esp;
	int rc;

	visionchip = kzalloc(sizeof(*visionchip), GFP_KERNEL);
	if (visionchip == NULL)
		return -ENOMEM;
	esp = &visionchip->esp;
	esp->module = THIS_MODULE;
	esp->number = visionchip_devs;
	esp->driver = &visionchip_driver;
	rc = esp_device_register(esp, pdev);
	if (rc)
		goto err;

	visionchip_devs++;
	return 0;
 err:
	kfree(visionchip);
	return rc;
}

static int __exit visionchip_remove(struct platform_device *pdev)
{
	struct esp_device *esp = platform_get_drvdata(pdev);
	struct visionchip_device *visionchip = to_visionchip(esp);

	esp_device_unregister(esp);
	kfree(visionchip);
	return 0;
}

static struct esp_driver visionchip_driver = {
	.plat = {
		.probe		= visionchip_probe,
		.remove		= visionchip_remove,
		.driver		= {
			.name = DRV_NAME,
			.owner = THIS_MODULE,
			.of_match_table = visionchip_device_ids,
		},
	},
	.xfer_input_ok	= visionchip_xfer_input_ok,
	.prep_xfer	= visionchip_prep_xfer,
	.ioctl_cm	= VISIONCHIP_IOC_ACCESS,
	.arg_size	= sizeof(struct visionchip_access),
};

static int __init visionchip_init(void)
{
	return esp_driver_register(&visionchip_driver);
}

static void __exit visionchip_exit(void)
{
	esp_driver_unregister(&visionchip_driver);
}

module_init(visionchip_init)
module_exit(visionchip_exit)

MODULE_DEVICE_TABLE(of, visionchip_device_ids);

MODULE_AUTHOR("Emilio G. Cota <cota@braap.org>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("visionchip driver");
