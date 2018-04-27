#include "esp_cache.h"

#define DRV_NAME	"esp_cache"

static DEFINE_SPINLOCK(esp_cache_list_lock);
static LIST_HEAD(esp_cache_list);

struct esp_cache_device {
	struct device *pdev; /* platform device */
	struct module *module;
	struct mutex lock;
	void __iomem *iomem; /* mmapped registers */
	struct list_head list;
};


static struct of_device_id esp_cache_device_ids[] = {
	{
		.name = "SLD_ESP_CACHE",
	},
	{
		.name = "eb_021",
	},
	{ },
};


static void esp_cache_do_flush(struct esp_cache_device *esp_cache)
{
	int cmd = 1 << ESP_CACHE_CMD_FLUSH_BIT;
	u32 satus_reg;


	iowrite32be(cmd, esp_cache->iomem + ESP_CACHE_REG_CMD);

	/* Wait for completion */
	do {
		satus_reg = ioread32be(esp_cache->iomem + ESP_CACHE_REG_STATUS);
		satus_reg &= ESP_CACHE_STATUS_DONE_MASK;
	} while (!satus_reg);

	/* Clear command register */
	iowrite32be(0x0, esp_cache->iomem + ESP_CACHE_REG_CMD);
}

int esp_cache_flush()
{
	struct esp_cache_device *esp_cache = NULL;
	list_for_each_entry(esp_cache, &esp_cache_list, list) {
		if (mutex_lock_interruptible(&esp_cache->lock))
			return -EINTR;
		esp_cache_do_flush(esp_cache);
		mutex_unlock(&esp_cache->lock);
	}
	return 0;
}
EXPORT_SYMBOL_GPL(esp_cache_flush);


static int esp_cache_probe(struct platform_device *pdev)
{
	struct esp_cache_device *esp_cache;
	int rc = 0;

	esp_cache = kzalloc(sizeof(*esp_cache), GFP_KERNEL);
	if (esp_cache == NULL)
		return -ENOMEM;

	esp_cache->pdev = &pdev->dev;

	esp_cache->module = THIS_MODULE;

	mutex_init(&esp_cache->lock);

	esp_cache->iomem = of_ioremap(&pdev->resource[0], 0, resource_size(&pdev->resource[0]), "esp_cache regs");
	if (esp_cache->iomem == NULL) {
		dev_info(esp_cache->pdev, "cannot map registers for I/O\n");
		rc = -ENODEV;
		goto out_iomem;
	}

	dev_info(esp_cache->pdev, "device registered.\n");

	platform_set_drvdata(pdev, esp_cache);

	spin_lock(&esp_cache_list_lock);
	list_add(&esp_cache->list, &esp_cache_list);
	spin_unlock(&esp_cache_list_lock);

	return 0;

 out_iomem:
	kfree(esp_cache);
	return rc;
}

static int __exit esp_cache_remove(struct platform_device *pdev)
{
	struct esp_cache_device *esp_cache = platform_get_drvdata(pdev);

	spin_lock(&esp_cache_list_lock);
	list_del(&esp_cache->list);
	spin_unlock(&esp_cache_list_lock);

	dev_info(esp_cache->pdev, "device unregistered.\n");

	iounmap(esp_cache->iomem);
	kfree(esp_cache);

	return 0;
}

static struct platform_driver esp_cache_driver = {
	.probe		= esp_cache_probe,
	.remove		= esp_cache_remove,
	.driver		= {
		.name = DRV_NAME,
		.owner = THIS_MODULE,
		.of_match_table = esp_cache_device_ids,
	},
};

static int __init esp_cache_init(void)
{
	int rc = platform_driver_register(&esp_cache_driver);
	return rc;
}

static void __exit esp_cache_exit(void)
{
	platform_driver_unregister(&esp_cache_driver);
}

module_init(esp_cache_init)
module_exit(esp_cache_exit)

MODULE_DEVICE_TABLE(of, esp_cache_device_ids);

MODULE_AUTHOR("Paolo Mantovani <paolo@cs.columbia.edu>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("esp_cache driver");
