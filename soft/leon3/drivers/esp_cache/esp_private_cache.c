#include <linux/platform_device.h>
#include <linux/dma-mapping.h>
#include <linux/interrupt.h>
#include <linux/pagemap.h>
#include <linux/fs.h>
#include <linux/mm.h>
#include <linux/ioctl.h>
#include <asm/uaccess.h>
#include <uapi/asm/asi.h>

#include <esp_cache.h>

#define DRV_NAME	"esp_private_cache"

static DEFINE_SPINLOCK(esp_private_cache_list_lock);
static LIST_HEAD(esp_private_cache_list);

struct esp_private_cache_device {
	struct device *pdev; /* platform device */
	struct module *module;
	struct mutex lock;
	struct completion completion;
	int irq;
	void __iomem *iomem; /* mmapped registers */
	struct list_head list;
};


static struct of_device_id esp_private_cache_device_ids[] = {
	{
		.name = "SLD_ESP_PRIVACE_CACHE",
	},
	{
		.name = "eb_020",
	},
	{ },
};


static void leon3_flush_dcache_all()
{
	__asm__ __volatile__("sta %%g0, [%%g0] %0\n\t" : :
			"i"(ASI_LEON_DFLUSH) : "memory");
}

static irqreturn_t esp_private_cache_irq(int irq, void *dev)
{
	struct esp_private_cache_device *esp_private_cache = dev_get_drvdata(dev);
	u32 status_reg;

	status_reg = ioread32be(esp_private_cache->iomem + ESP_CACHE_REG_STATUS);
	status_reg &= ESP_CACHE_STATUS_DONE_MASK;

	if (status_reg) {
		iowrite32be(0x0, esp_private_cache->iomem + ESP_CACHE_REG_CMD);
		complete_all(&esp_private_cache->completion);
		return IRQ_HANDLED;
	}

	return IRQ_NONE;
}

int esp_private_cache_flush(void)
{
	struct esp_private_cache_device *esp_private_cache = NULL;
	const int cmd = 1 << ESP_CACHE_CMD_FLUSH_BIT;
	int match = 0;
	int rc = 0;
	u32 status_reg;

	/* Disable preemption and get current CPU ID */
	int cpuid = get_cpu();

	/* Search for private L2 cache with matching CPU ID */
	list_for_each_entry(esp_private_cache, &esp_private_cache_list, list) {
		if (mutex_lock_interruptible(&esp_private_cache->lock))
			return -EINTR;

		status_reg    = ioread32be(esp_private_cache->iomem + ESP_CACHE_REG_STATUS);
		status_reg   &= ESP_CACHE_STATUS_CPUID_MASK;
		status_reg >>= ESP_CACHE_STATUS_CPUID_SHIFT;

		if (status_reg == cpuid) {

			INIT_COMPLETION(esp_private_cache->completion);

			/* Set flush due for L2 private cache */
			iowrite32be(cmd, esp_private_cache->iomem + ESP_CACHE_REG_CMD);

			/* Flush L1 cache: starts synchronized L2 flush as well */
			leon3_flush_dcache_all();

			/* Enable preemption */
			put_cpu();

			/* Wait for L2 flush to complete */
			rc = wait_for_completion_interruptible(&esp_private_cache->completion);
			if (rc < 0)
				rc = -EINTR;

			match = 1;
		}

		mutex_unlock(&esp_private_cache->lock);

		if (match)
			break;
	}

	if (!match)
		rc = -ENODEV;

	return rc;
}
EXPORT_SYMBOL_GPL(esp_private_cache_flush);


static int esp_private_cache_probe(struct platform_device *pdev)
{
	struct esp_private_cache_device *esp_private_cache;
	int rc;

	esp_private_cache = kzalloc(sizeof(*esp_private_cache), GFP_KERNEL);
	if (esp_private_cache == NULL)
		return -ENOMEM;

	esp_private_cache->pdev = &pdev->dev;

	esp_private_cache->module = THIS_MODULE;

	mutex_init(&esp_private_cache->lock);

	init_completion(&esp_private_cache->completion);

	esp_private_cache->irq = pdev->archdata.irqs[0];
	rc = request_irq(esp_private_cache->irq, esp_private_cache_irq, IRQF_SHARED, "esp_private_cache", esp_private_cache->pdev);
	if (rc) {
		dev_info(esp_private_cache->pdev, "cannot request IRQ number %d\n", esp_private_cache->irq);
		goto out_irq;
	}

	esp_private_cache->iomem = of_ioremap(&pdev->resource[0], 0, resource_size(&pdev->resource[0]), "esp_private_cache regs");
	if (esp_private_cache->iomem == NULL) {
		dev_info(esp_private_cache->pdev, "cannot map registers for I/O\n");
		goto out_iomem;
	}

	dev_info(esp_private_cache->pdev, "device registered.\n");

	platform_set_drvdata(pdev, esp_private_cache);

	spin_lock(&esp_private_cache_list_lock);
	list_add(&esp_private_cache->list, &esp_private_cache_list);
	spin_unlock(&esp_private_cache_list_lock);

	return 0;

 out_iomem:
	free_irq(esp_private_cache->irq, esp_private_cache->pdev);
 out_irq:
	kfree(esp_private_cache);
	return rc;
}

static int __exit esp_private_cache_remove(struct platform_device *pdev)
{
	struct esp_private_cache_device *esp_private_cache = platform_get_drvdata(pdev);

	spin_lock(&esp_private_cache_list_lock);
	list_del(&esp_private_cache->list);
	spin_unlock(&esp_private_cache_list_lock);

	dev_info(esp_private_cache->pdev, "device unregistered.\n");

	free_irq(esp_private_cache->irq, esp_private_cache->pdev);
	iounmap(esp_private_cache->iomem);
	kfree(esp_private_cache);

	return 0;
}

static struct platform_driver esp_private_cache_driver = {
	.probe		= esp_private_cache_probe,
	.remove		= esp_private_cache_remove,
	.driver		= {
		.name = DRV_NAME,
		.owner = THIS_MODULE,
		.of_match_table = esp_private_cache_device_ids,
	},
};

static int __init esp_private_cache_init(void)
{
	int rc = platform_driver_register(&esp_private_cache_driver);
	return rc;
}

static void __exit esp_private_cache_exit(void)
{
	platform_driver_unregister(&esp_private_cache_driver);
}

module_init(esp_private_cache_init)
module_exit(esp_private_cache_exit)

MODULE_DEVICE_TABLE(of, esp_private_cache_device_ids);

MODULE_AUTHOR("Paolo Mantovani <paolo@cs.columbia.edu>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("esp_private_cache driver");
