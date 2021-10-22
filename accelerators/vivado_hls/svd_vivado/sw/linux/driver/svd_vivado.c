#include <linux/of_device.h>
#include <linux/mm.h>

#include <asm/io.h>

#include <esp_accelerator.h>
#include <esp.h>

#include "svd_vivado.h"

#define DRV_NAME	"svd"

/* <<--regs-->> */
#define SVD_LOAD_STATE_REG 0x58
#define SVD_P2P_ITER_REG 0x54
#define SVD_P2P_IN_REG 0x50
#define SVD_P2P_OUT_REG 0x4C
#define SVD_Q_REG 0x48
#define SVD_P_REG 0x44
#define SVD_M_REG 0x40

struct svd_device {
	struct esp_device esp;
};

static struct esp_driver svd_driver;

static struct of_device_id svd_device_ids[] = {
	{
		.name = "SLD_SVD_VIVADO",
	},
	{
		.name = "eb_222",
	},
	{
		.compatible = "sld,svd_vivado",
	},
	{ },
};

static int svd_devs;

static inline struct svd_device *to_svd(struct esp_device *esp)
{
	return container_of(esp, struct svd_device, esp);
}

static void svd_prep_xfer(struct esp_device *esp, void *arg)
{
	struct svd_access *a = arg;

	/* <<--regs-config-->> */
	iowrite32be(a->load_state, esp->iomem + SVD_LOAD_STATE_REG);
	iowrite32be(a->p2p_iter, esp->iomem + SVD_P2P_ITER_REG);
	iowrite32be(a->p2p_in, esp->iomem + SVD_P2P_IN_REG);
	iowrite32be(a->p2p_out, esp->iomem + SVD_P2P_OUT_REG);
	iowrite32be(a->q, esp->iomem + SVD_Q_REG);
	iowrite32be(a->p, esp->iomem + SVD_P_REG);
	iowrite32be(a->m, esp->iomem + SVD_M_REG);
	iowrite32be(a->src_offset, esp->iomem + SRC_OFFSET_REG);
	iowrite32be(a->dst_offset, esp->iomem + DST_OFFSET_REG);

}

static bool svd_xfer_input_ok(struct esp_device *esp, void *arg)
{
	/* struct svd_device *svd = to_svd(esp); */
	/* struct svd_access *a = arg; */

	return true;
}

static int svd_probe(struct platform_device *pdev)
{
	struct svd_device *svd;
	struct esp_device *esp;
	int rc;

	svd = kzalloc(sizeof(*svd), GFP_KERNEL);
	if (svd == NULL)
		return -ENOMEM;
	esp = &svd->esp;
	esp->module = THIS_MODULE;
	esp->number = svd_devs;
	esp->driver = &svd_driver;
	rc = esp_device_register(esp, pdev);
	if (rc)
		goto err;

	svd_devs++;
	return 0;
 err:
	kfree(svd);
	return rc;
}

static int __exit svd_remove(struct platform_device *pdev)
{
	struct esp_device *esp = platform_get_drvdata(pdev);
	struct svd_device *svd = to_svd(esp);

	esp_device_unregister(esp);
	kfree(svd);
	return 0;
}

static struct esp_driver svd_driver = {
	.plat = {
		.probe		= svd_probe,
		.remove		= svd_remove,
		.driver		= {
			.name = DRV_NAME,
			.owner = THIS_MODULE,
			.of_match_table = svd_device_ids,
		},
	},
	.xfer_input_ok	= svd_xfer_input_ok,
	.prep_xfer	= svd_prep_xfer,
	.ioctl_cm	= SVD_IOC_ACCESS,
	.arg_size	= sizeof(struct svd_access),
};

static int __init svd_init(void)
{
	return esp_driver_register(&svd_driver);
}

static void __exit svd_exit(void)
{
	esp_driver_unregister(&svd_driver);
}

module_init(svd_init)
module_exit(svd_exit)

MODULE_DEVICE_TABLE(of, svd_device_ids);

MODULE_AUTHOR("Emilio G. Cota <cota@braap.org>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("svd_vivado driver");
