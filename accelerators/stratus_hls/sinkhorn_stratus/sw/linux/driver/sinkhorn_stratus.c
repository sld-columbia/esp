#include <linux/of_device.h>
#include <linux/mm.h>

#include <asm/io.h>

#include <esp_accelerator.h>
#include <esp.h>

#include "sinkhorn_stratus.h"

#define DRV_NAME	"sinkhorn"

/* <<--regs-->> */
#define SINKHORN_STORE_STATE_REG 0x60
#define SINKHORN_P2P_ITER_REG 0x5C
#define SINKHORN_P2P_OUT_REG 0x58
#define SINKHORN_P2P_IN_REG 0x54
#define SINKHORN_MAXITER_REG 0x50
#define SINKHORN_GAMMA_REG 0x4c
#define SINKHORN_Q_COLS_REG 0x44
#define SINKHORN_M_ROWS_REG 0x48
#define SINKHORN_P_ROWS_REG 0x40

struct sinkhorn_device {
	struct esp_device esp;
};

static struct esp_driver sinkhorn_driver;

static struct of_device_id sinkhorn_device_ids[] = {
	{
		.name = "SLD_SINKHORN_STRATUS",
	},
	{
		.name = "eb_144",
	},
	{
		.compatible = "sld,sinkhorn_stratus",
	},
	{ },
};

static int sinkhorn_devs;

static inline struct sinkhorn_device *to_sinkhorn(struct esp_device *esp)
{
	return container_of(esp, struct sinkhorn_device, esp);
}

static void sinkhorn_prep_xfer(struct esp_device *esp, void *arg)
{
	struct sinkhorn_access *a = arg;

	/* <<--regs-config-->> */
	iowrite32be(a->store_state, esp->iomem + SINKHORN_STORE_STATE_REG);
	iowrite32be(a->p2p_iter, esp->iomem + SINKHORN_P2P_ITER_REG);
	iowrite32be(a->p2p_in, esp->iomem + SINKHORN_P2P_IN_REG);
	iowrite32be(a->p2p_out, esp->iomem + SINKHORN_P2P_OUT_REG);
	iowrite32be(a->maxiter, esp->iomem + SINKHORN_MAXITER_REG);
	iowrite32be(a->gamma, esp->iomem + SINKHORN_GAMMA_REG);
	iowrite32be(a->q_cols, esp->iomem + SINKHORN_Q_COLS_REG);
	iowrite32be(a->m_rows, esp->iomem + SINKHORN_M_ROWS_REG);
	iowrite32be(a->p_rows, esp->iomem + SINKHORN_P_ROWS_REG);
	iowrite32be(a->src_offset, esp->iomem + SRC_OFFSET_REG);
	iowrite32be(a->dst_offset, esp->iomem + DST_OFFSET_REG);

}

static bool sinkhorn_xfer_input_ok(struct esp_device *esp, void *arg)
{
	/* struct sinkhorn_device *sinkhorn = to_sinkhorn(esp); */
	/* struct sinkhorn_access *a = arg; */

	return true;
}

static int sinkhorn_probe(struct platform_device *pdev)
{
	struct sinkhorn_device *sinkhorn;
	struct esp_device *esp;
	int rc;

	sinkhorn = kzalloc(sizeof(*sinkhorn), GFP_KERNEL);
	if (sinkhorn == NULL)
		return -ENOMEM;
	esp = &sinkhorn->esp;
	esp->module = THIS_MODULE;
	esp->number = sinkhorn_devs;
	esp->driver = &sinkhorn_driver;
	rc = esp_device_register(esp, pdev);
	if (rc)
		goto err;

	sinkhorn_devs++;
	return 0;
 err:
	kfree(sinkhorn);
	return rc;
}

static int __exit sinkhorn_remove(struct platform_device *pdev)
{
	struct esp_device *esp = platform_get_drvdata(pdev);
	struct sinkhorn_device *sinkhorn = to_sinkhorn(esp);

	esp_device_unregister(esp);
	kfree(sinkhorn);
	return 0;
}

static struct esp_driver sinkhorn_driver = {
	.plat = {
		.probe		= sinkhorn_probe,
		.remove		= sinkhorn_remove,
		.driver		= {
			.name = DRV_NAME,
			.owner = THIS_MODULE,
			.of_match_table = sinkhorn_device_ids,
		},
	},
	.xfer_input_ok	= sinkhorn_xfer_input_ok,
	.prep_xfer	= sinkhorn_prep_xfer,
	.ioctl_cm	= SINKHORN_IOC_ACCESS,
	.arg_size	= sizeof(struct sinkhorn_access),
};

static int __init sinkhorn_init(void)
{
	return esp_driver_register(&sinkhorn_driver);
}

static void __exit sinkhorn_exit(void)
{
	esp_driver_unregister(&sinkhorn_driver);
}

module_init(sinkhorn_init)
module_exit(sinkhorn_exit)

MODULE_DEVICE_TABLE(of, sinkhorn_device_ids);

MODULE_AUTHOR("Emilio G. Cota <cota@braap.org>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("sinkhorn_stratus driver");
