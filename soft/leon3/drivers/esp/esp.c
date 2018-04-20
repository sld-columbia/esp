#include <linux/platform_device.h>
#include <linux/dma-mapping.h>
#include <linux/interrupt.h>
#include <linux/pagemap.h>
#include <linux/fs.h>
#include <linux/mm.h>
#include <linux/ioctl.h>

#include <asm/uaccess.h>
#include <asm/cacheflush.h>

#include <esp.h>

#define PFX "esp: "
#define ESP_MAX_DEVICES	64

static irqreturn_t esp_irq(int irq, void *dev)
{
	struct esp_device *esp = dev_get_drvdata(dev);
	u32 status, error, done;

	status = ioread32be(esp->iomem + STATUS_REG);
	error = status & STATUS_MASK_ERR;
	done = status & STATUS_MASK_DONE;

	/* printk(KERN_INFO "IRQ: %08x\n", status); */

	if (error) {
		iowrite32be(0, esp->iomem + CMD_REG);
		esp->err = -1;
		complete_all(&esp->completion);
		return IRQ_HANDLED;
	}
	if (done) {
		iowrite32be(0, esp->iomem + CMD_REG);
		complete_all(&esp->completion);
		return IRQ_HANDLED;
	}
	return IRQ_NONE;
}

#define ASI_LEON_DFLUSH         0x11
/*
 * Note: we know the leon3 has write-through caches, so this may not seem like
 * it's needed. However, I cannot find a way to flush the write buffers, so I'm
 * hoping flushing the cache does flush the write buffers too.
 *
 * The leon3 code flushes the entire cache even if we just want to flush a
 * single line, so we call the flush function below only once.
 */
static int esp_flush(struct esp_device *esp)
{
	int rc = 0;

	if (esp->coherence < ACC_COH_FULL)
		flush_page_for_dma(0);

	if (esp->coherence < ACC_COH_LLC)
		rc = esp_cache_flush();

	return rc;
}

static int esp_open(struct inode *inode, struct file *file)
{
	struct esp_device *esp;

	esp = container_of(inode->i_cdev, struct esp_device, cdev);
	file->private_data = esp;
	if (!try_module_get(esp->module))
		return -ENODEV;
	return 0;
}

static int esp_release(struct inode *inode, struct file *file)
{
	struct esp_device *esp;

	esp = file->private_data;
	module_put(esp->module);
	return 0;
}

static void esp_transfer(struct esp_device *esp, const struct contig_desc *contig)
{
	esp->err = 0;
	INIT_COMPLETION(esp->completion);

	iowrite32be(contig->arr_dma_addr, esp->iomem + PT_ADDRESS_REG);
	iowrite32be(contig_chunk_size_log, esp->iomem + PT_SHIFT_REG);
	iowrite32be(contig->n, esp->iomem + PT_NCHUNK_REG);
	iowrite32be(0x0, esp->iomem + SRC_OFFSET_REG);
	iowrite32be(0x0, esp->iomem + DST_OFFSET_REG);
}

static void esp_run(struct esp_device *esp)
{
	iowrite32be(0x1, esp->iomem + CMD_REG);
}

static int esp_wait(struct esp_device *esp)
{
	int wait;

	wait = wait_for_completion_interruptible(&esp->completion);
	if (wait < 0)
		return -EINTR;
	if (esp->err) {
		pr_info(PFX "Error occured\n");
		return -1;
	}

	return 0;
}

static bool esp_xfer_input_ok(struct esp_device *esp, const struct contig_desc *contig)
{
	unsigned nchunk_max = ioread32be(esp->iomem + PT_NCHUNK_MAX_REG);

	if (!contig->n || contig->n > nchunk_max)
		return false;
	return true;
}

static int esp_access_ioctl(struct esp_device *esp, void __user *argp)
{
	struct contig_desc *contig;
	struct esp_access *access;
	void *arg;
	int rc = 0;

	arg = kmalloc(esp->driver->arg_size, GFP_KERNEL);
	if (arg == NULL)
		return -ENOMEM;

	if (copy_from_user(arg, argp, esp->driver->arg_size)) {
		rc = -EFAULT;
		goto out;
	}

	access = arg;
	contig = contig_khandle_to_desc(access->contig);
	if (contig == NULL) {
		rc = -EFAULT;
		goto out;
	}

	if (!esp_xfer_input_ok(esp, contig)) {
		rc = -EINVAL;
		goto out;
	}
	if (esp->driver->xfer_input_ok && !esp->driver->xfer_input_ok(esp, arg)) {
		rc = -EINVAL;
		goto out;
	}

	if (esp_flush(esp)) {
		rc = -EINTR;
		goto out;
	}

	if (mutex_lock_interruptible(&esp->lock)) {
		rc = -EINTR;
		goto out;
	}

	esp_transfer(esp, contig);
	if (esp->driver->prep_xfer)
		esp->driver->prep_xfer(esp, arg);
	if (access->run)
		esp_run(esp);
	rc = esp_wait(esp);

	mutex_unlock(&esp->lock);

 out:
	kfree(arg);
	return rc;
}

static int esp_run_ioctl(struct esp_device *esp)
{
	esp_run(esp);
	return 0;
}

static long esp_do_ioctl(struct file *file, unsigned int cm, void __user *arg)
{
	struct esp_device *esp = file->private_data;

	switch (cm) {
	case ESP_IOC_RUN:
		return esp_run_ioctl(esp);
	default:
		if (cm == esp->driver->ioctl_cm)
			return esp_access_ioctl(esp, arg);
		return -ENOTTY;
	}
}

static long esp_ioctl(struct file *file, unsigned int cm, unsigned long arg)
{
	return esp_do_ioctl(file, cm, (void __user *)arg);
}


static const struct file_operations esp_fops = {
	.owner		= THIS_MODULE,
	.open		= esp_open,
	.release	= esp_release,
	.unlocked_ioctl	= esp_ioctl,
};

static int esp_create_cdev(struct esp_device *esp, int ndev)
{
	dev_t devno = MKDEV(MAJOR(esp->driver->devno), ndev);
	const char *name = esp->driver->plat.driver.name;
	int rc;

	cdev_init(&esp->cdev, &esp_fops);
	esp->cdev.owner = esp->module;
	rc = cdev_add(&esp->cdev, devno, 1);
	if (rc) {
		dev_err(esp->pdev, "Error %d adding cdev %d\n", rc, ndev);
		goto out;
	}

	esp->dev = device_create(esp->driver->class, esp->pdev, devno, NULL, "%s.%i", name, ndev);
	if (IS_ERR(esp->dev)) {
		rc = PTR_ERR(esp->dev);
		dev_err(esp->pdev, "Error %d creating device %d\n", rc, ndev);
		esp->dev = NULL;
		goto device_create_failed;
	}

	dev_set_drvdata(esp->dev, esp);
	return 0;

device_create_failed:
	cdev_del(&esp->cdev);
out:
	return rc;
}

static void esp_destroy_cdev(struct esp_device *esp, int ndev)
{
	dev_t devno = MKDEV(MAJOR(esp->driver->devno), ndev);

	device_destroy(esp->driver->class, devno);
	cdev_del(&esp->cdev);
}

int esp_device_register(struct esp_device *esp, struct platform_device *pdev)
{
	int rc;

	esp->pdev = &pdev->dev;
	mutex_init(&esp->lock);
	init_completion(&esp->completion);

	rc = esp_create_cdev(esp, esp->number);
	if (rc)
		goto out;

	esp->irq = pdev->archdata.irqs[0];
	rc = request_irq(esp->irq, esp_irq, IRQF_SHARED, "esp", esp->pdev);
	if (rc) {
		dev_info(esp->pdev, "cannot request IRQ number %d\n", esp->irq);
		goto out_irq;
	}

	esp->iomem = of_ioremap(&pdev->resource[0], 0, resource_size(&pdev->resource[0]), "esp regs");
	if (esp->iomem == NULL) {
		dev_info(esp->pdev, "cannot map registers for I/O\n");
		goto out_iomem;
	}

	/* reset device and wait for it to complete */
	iowrite32be(0x0, esp->iomem + CMD_REG);
	while (ioread32be(esp->iomem + CMD_REG))
		cpu_relax();

	/* get type of coherence selected for the device */
	esp->coherence = ioread32be(esp->iomem + COHERENCE_REG);

	dev_info(esp->pdev, "device registered.\n");
	platform_set_drvdata(pdev, esp);
	return 0;

out_iomem:
	free_irq(esp->irq, esp->pdev);
out_irq:
	esp_destroy_cdev(esp, esp->number);
out:
	kfree(esp);
	return rc;
}
EXPORT_SYMBOL_GPL(esp_device_register);

void esp_device_unregister(struct esp_device *esp)
{
	free_irq(esp->irq, esp->pdev);
	esp_destroy_cdev(esp, esp->number);
	iounmap(esp->iomem);
	dev_info(esp->pdev, "device unregistered.\n");
}
EXPORT_SYMBOL_GPL(esp_device_unregister);

static int esp_sysfs_device_create(struct esp_driver *drv)
{
	const char *name = drv->plat.driver.name;
	int rc;

	drv->class = class_create(drv->plat.driver.owner, name);
	if (IS_ERR(drv->class)) {
		pr_err(PFX "Failed to create esp class\n");
		rc = PTR_ERR(drv->class);
		goto out;
	}

	rc = alloc_chrdev_region(&drv->devno, 0, ESP_MAX_DEVICES, name);
	if (rc) {
		pr_err(PFX "Failed to allocate chrdev region\n");
		goto alloc_chrdev_region_failed;
	}

	return 0;

alloc_chrdev_region_failed:
	class_destroy(drv->class);
out:
	return rc;
}

static void esp_sysfs_device_remove(struct esp_driver *drv)
{
	dev_t devno = MKDEV(MAJOR(drv->devno), 0);

	class_destroy(drv->class);
	unregister_chrdev_region(devno, ESP_MAX_DEVICES);
}

int esp_driver_register(struct esp_driver *driver)
{
	struct platform_driver *plat = &driver->plat;
	int rc;

	rc = esp_sysfs_device_create(driver);
	if (rc)
		return rc;
	rc = platform_driver_register(plat);
	if (rc)
		goto err;
	return 0;
err:
	esp_sysfs_device_remove(driver);
	return rc;
}
EXPORT_SYMBOL_GPL(esp_driver_register);

void esp_driver_unregister(struct esp_driver *driver)
{
	platform_driver_unregister(&driver->plat);
	esp_sysfs_device_remove(driver);
}
EXPORT_SYMBOL_GPL(esp_driver_unregister);

static int __init esp_init(void)
{
	return 0;
}

static void __exit esp_exit(void)
{ }

module_init(esp_init)
module_exit(esp_exit)

MODULE_AUTHOR("Emilio G. Cota <cota@braap.org>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("esp driver");
