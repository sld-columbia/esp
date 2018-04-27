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


/*
 * Note: we know the leon3 has write-through caches, so this may not seem like
 * it's needed. However, I cannot find a way to flush the write buffers, so I'm
 * hoping flushing the cache does flush the write buffers too.
 *
 * The leon3 code flushes the entire cache even if we just want to flush a
 * single line, so we call the flush function below only once.
 */
static void leon3_flush_dcache_all(void)
{
	__asm__ __volatile__("sta %%g0, [%%g0] %0\n\t" : :
			"i"(ASI_LEON_DFLUSH) : "memory");
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

		/* pr_info("cpuid is %d, cache id is %d\n", cpuid, status_reg); */

		if (status_reg == cpuid) {

			/* Set flush due for L2 private cache */
			iowrite32be(cmd, esp_private_cache->iomem + ESP_CACHE_REG_CMD);

			/* Wait for L2 flush to be set (may loose synch flush with L1 otherwise) */
			do {
				status_reg = ioread32be(esp_private_cache->iomem + ESP_CACHE_REG_CMD);
			} while (status_reg != cmd);

			/* pr_info("L2 flush ready...\n"); */

			match = 1;

			/* Flush L1 cache: starts synchronized L2 flush as well */
			leon3_flush_dcache_all();

			/* pr_info("L1/L2 flush issued...\n"); */

			/* Wait for flush completion */
			do {
				status_reg = ioread32be(esp_private_cache->iomem + ESP_CACHE_REG_STATUS);
				status_reg &= ESP_CACHE_STATUS_DONE_MASK;
			} while (!status_reg);


			/* pr_info("L1/L2 flush done...\n"); */

			/* Clear command register */
			iowrite32be(0x0, esp_private_cache->iomem + ESP_CACHE_REG_CMD);
		}

		mutex_unlock(&esp_private_cache->lock);

		if (match)
			break;
	}

	/* Enable preemption */
	put_cpu();

	if (!match)
		rc = -ENODEV;

	return rc;
}
EXPORT_SYMBOL_GPL(esp_private_cache_flush);


static int esp_private_cache_probe(struct platform_device *pdev)
{
	struct esp_private_cache_device *esp_private_cache;
	int rc = 0;

	esp_private_cache = kzalloc(sizeof(*esp_private_cache), GFP_KERNEL);
	if (esp_private_cache == NULL)
		return -ENOMEM;

	esp_private_cache->pdev = &pdev->dev;

	esp_private_cache->module = THIS_MODULE;

	mutex_init(&esp_private_cache->lock);

	esp_private_cache->iomem = of_ioremap(&pdev->resource[0], 0, resource_size(&pdev->resource[0]), "esp_private_cache regs");
	if (esp_private_cache->iomem == NULL) {
		dev_info(esp_private_cache->pdev, "cannot map registers for I/O\n");
		rc = -ENODEV;
		goto out_iomem;
	}

	dev_info(esp_private_cache->pdev, "device registered.\n");

	platform_set_drvdata(pdev, esp_private_cache);

	spin_lock(&esp_private_cache_list_lock);
	list_add(&esp_private_cache->list, &esp_private_cache_list);
	spin_unlock(&esp_private_cache_list_lock);

	return 0;

 out_iomem:
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
