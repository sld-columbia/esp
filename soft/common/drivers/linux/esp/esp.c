/*
 * Copyright (c) 2011-2023 Columbia University, System Level Design Group
 * SPDX-License-Identifier: Apache-2.0
 */

/*
 * esp.c
 * Accelerator-independent Linux module to manage an ESP accelerator.
 * The module requires these flags when it is installed:
 * - line_bytes
 * - l2_sets
 * - l2_ways
 * - llc_sets
 * - llc_ways
 * - llc_banks
 */

#include <linux/platform_device.h>
#include <linux/of_device.h>
#include <linux/of_platform.h>
#include <linux/of_irq.h>
#include <linux/dma-mapping.h>
#include <linux/interrupt.h>
#include <linux/pagemap.h>
#include <linux/fs.h>
#include <linux/mm.h>
#include <linux/ioctl.h>
#include <linux/string.h>

#include <asm/uaccess.h>

#include <esp.h>

#define PFX "esp: "
#define ESP_MAX_DEVICES	64

static DEFINE_SPINLOCK(esp_devices_lock);
static LIST_HEAD(esp_devices);

/* These are overwritten whith insmod flags */
static unsigned long cache_line_bytes = 16;
module_param_named(line_bytes, cache_line_bytes, ulong, S_IRUGO);
static unsigned long cache_l2_sets = 512;
module_param_named(l2_sets, cache_l2_sets, ulong, S_IRUGO);
static unsigned long cache_l2_ways = 4;
module_param_named(l2_ways, cache_l2_ways, ulong, S_IRUGO);
static unsigned long cache_llc_sets = 1024;
module_param_named(llc_sets, cache_llc_sets, ulong, S_IRUGO);
static unsigned long cache_llc_ways = 16;
module_param_named(llc_ways, cache_llc_ways, ulong, S_IRUGO);
static unsigned long cache_llc_banks = 1;
module_param_named(llc_banks, cache_llc_banks, ulong, S_IRUGO);
static unsigned long rtl_cache = 1;
module_param(rtl_cache, ulong, S_IRUGO);

/* These are overwritten when the module initializes based on input flags */
static size_t cache_l2_size = 32768;
static size_t cache_llc_bank_size = 262144;
static size_t cache_llc_size = 262144;

struct esp_status esp_status;

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

static int esp_flush(struct esp_device *esp)
{
	int rc = 0;
	if (esp->coherence < ACC_COH_RECALL)
		rc |= esp_private_cache_flush();

	if (esp->coherence < ACC_COH_LLC)
		rc |= esp_cache_flush();

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

void esp_status_init(void) {

	int i;

	cache_l2_size = cache_l2_sets * cache_l2_ways * cache_line_bytes;
	
    if (rtl_cache) {
        cache_llc_size = cache_llc_sets * cache_llc_ways * cache_line_bytes;
        cache_llc_bank_size = cache_llc_sets * cache_llc_ways * cache_line_bytes / cache_llc_banks;
    } else {
        cache_llc_size = cache_llc_sets * cache_llc_ways * cache_line_bytes * cache_llc_banks;
        cache_llc_bank_size = cache_llc_sets * cache_llc_ways * cache_line_bytes;
    }

	mutex_init(&esp_status.lock);
	esp_status.active_acc_cnt = 0;
	esp_status.active_footprint = 0;
	for (i = 0; i < cache_llc_banks; i++)
		esp_status.active_footprint_split[i] = 0;
}

static void esp_runtime_config(struct esp_device *esp)
{
	unsigned int footprint, footprint_llc_threshold;
	// Update number of active accelerators
	esp_status.active_acc_cnt += 1;

	if (esp->coherence == ACC_COH_FULL) {

		esp_status.active_acc_cnt_full++;

		return;
	}

    if  (esp->coherence == ACC_COH_AUTO){

        // Evaluate footprint
        if (esp->alloc_policy == CONTIG_ALLOC_PREFERRED ||
            esp->alloc_policy == CONTIG_ALLOC_LEAST_LOADED) {

            footprint = esp_status.active_footprint_split[esp->ddr_node]
                + esp->footprint;
            footprint_llc_threshold = cache_llc_bank_size;

        } else { // CONTIG_ALLOC_BALANCED

            footprint = esp_status.active_footprint + esp->footprint;;
            footprint_llc_threshold = cache_llc_size;
        }

        // Cache coherence choice
        if (esp->footprint < cache_l2_size) {
            if (esp->reuse_factor > 1){
                esp->coherence =  ACC_COH_FULL;
                esp_status.active_acc_cnt_full++;
            } else {
                esp->coherence = ACC_COH_RECALL;
            }
        } else if (esp->footprint < cache_llc_bank_size) {
            esp->coherence = ACC_COH_RECALL;

        } else {
            esp->coherence = ACC_COH_NONE;
        }
    }

	// Update footprint
	if (esp->coherence != ACC_COH_NONE) {

		esp_status.active_footprint += esp->footprint;

		if (esp->alloc_policy == CONTIG_ALLOC_PREFERRED ||
			esp->alloc_policy == CONTIG_ALLOC_LEAST_LOADED) {

			esp_status.active_footprint_split[esp->ddr_node] +=
				esp->footprint;

		} else { // CONTIG_ALLOC_BALANCED

			int i;
			for (i = 0; i < cache_llc_banks; i++) {
				esp_status.active_footprint_split[i] +=
					(esp->footprint / cache_llc_banks);
			}
		}
	}

	return;
}

static void esp_transfer(struct esp_device *esp, const struct contig_desc *contig)
{
	esp->err = 0;
	reinit_completion(&esp->completion);

	iowrite32be(contig->arr_dma_addr, esp->iomem + PT_ADDRESS_REG);
	iowrite32be(contig_chunk_size_log, esp->iomem + PT_SHIFT_REG);
	iowrite32be(contig->n, esp->iomem + PT_NCHUNK_REG);
	iowrite32be(esp->coherence, esp->iomem + COHERENCE_REG);
	iowrite32be(0x0, esp->iomem + SRC_OFFSET_REG);
	iowrite32be(0x0, esp->iomem + DST_OFFSET_REG);
}

static void esp_run(struct esp_device *esp)
{
	iowrite32be(0x1, esp->iomem + CMD_REG);
}

static int esp_wait(struct esp_device *esp)
{
	/* Interrupt */
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

static void esp_update_status(struct esp_device *esp)
{
	if (esp->coherence == ACC_COH_FULL)
		esp_status.active_acc_cnt_full--;

	// Update number of active accelerators
	esp_status.active_acc_cnt -= 1;

	// Update footprints
	if (esp->coherence != ACC_COH_NONE) {

		esp_status.active_footprint -= esp->footprint;

		if (esp->alloc_policy == CONTIG_ALLOC_PREFERRED ||
			esp->alloc_policy == CONTIG_ALLOC_LEAST_LOADED) {

			esp_status.active_footprint_split[esp->ddr_node] -= esp->footprint;

		} else {

			int i;
			for (i = 0; i < cache_llc_banks; i++) {
				esp_status.active_footprint_split[i] -= (esp->footprint / cache_llc_banks);
			}
		}
	}
}

static bool esp_xfer_input_ok(struct esp_device *esp, const struct contig_desc *contig)
{
	unsigned nchunk_max = ioread32be(esp->iomem + PT_NCHUNK_MAX_REG);

	/* No check needed if memory is not accessed (PT_NCHUNK_MAX == 0) */
	if (!nchunk_max)
		return true;

	if (!contig->n || contig->n > nchunk_max)
		return false;
	return true;
}

#define esp_get_y(_dev) (YX_MASK_YX & (ioread32be(_dev->iomem + YX_REG) >> YX_SHIFT_Y))
#define esp_get_x(_dev) (YX_MASK_YX & (ioread32be(_dev->iomem + YX_REG) >> YX_SHIFT_X))
#define esp_p2p_reset(_dev) iowrite32be(0, _dev->iomem + P2P_REG)
#define esp_p2p_enable_dst(_dev) iowrite32be(ioread32be(_dev->iomem + P2P_REG) | P2P_MASK_DST_IS_P2P, _dev->iomem + P2P_REG)
#define esp_p2p_enable_src(_dev) iowrite32be(ioread32be(_dev->iomem + P2P_REG) | P2P_MASK_SRC_IS_P2P, _dev->iomem + P2P_REG)
#define esp_p2p_set_nsrcs(_dev, _n) iowrite32be(ioread32be(_dev->iomem + P2P_REG) | (P2P_MASK_NSRCS & (_n - 1)), _dev->iomem + P2P_REG)
#define esp_p2p_set_y(_dev, _n, _y) iowrite32be(ioread32be(_dev->iomem + P2P_REG) | ((P2P_MASK_SRCS_YX & _y) << P2P_SHIFT_SRCS_Y(_n)), _dev->iomem + P2P_REG)
#define esp_p2p_set_x(_dev, _n, _x) iowrite32be(ioread32be(_dev->iomem + P2P_REG) | ((P2P_MASK_SRCS_YX & _x) << P2P_SHIFT_SRCS_X(_n)), _dev->iomem + P2P_REG)

static long esp_p2p_set_src(struct esp_device *esp, char *src_name, int src_index)
{
	struct list_head *ele;
	struct esp_device *dev;

	dev_dbg(esp->pdev, "searching P2P source %s\n", src_name);
	spin_lock(&esp_devices_lock);
	list_for_each(ele, &esp_devices) {
		dev = list_entry(ele, struct esp_device, list);
		if (!strncmp(src_name, dev->dev->kobj.name, strlen(dev->dev->kobj.name))) {
			unsigned y = esp_get_y(dev);
			unsigned x = esp_get_x(dev);
			esp_p2p_set_y(esp, src_index, y);
			esp_p2p_set_x(esp, src_index, x);
			spin_unlock(&esp_devices_lock);
			dev_dbg(esp->pdev, "P2P source %s on tile %d,%d\n", dev->dev->kobj.name, y, x);
			return true;
		}
	}
	spin_unlock(&esp_devices_lock);

	dev_info(esp->pdev, "ESP device %s not found\n", src_name);
	return false;
}

static long esp_p2p_init(struct esp_device *esp, struct esp_access *access)
{
	int i = 0;

	esp_p2p_reset(esp);

	for (i = 0; i < access->p2p_nsrcs; i++)
		if (!esp_p2p_set_src(esp, access->p2p_srcs[i], i))
			return -ENODEV;

	if (access->p2p_store) {
		dev_dbg(esp->pdev, "P2P store enabled\n");
		esp_p2p_enable_dst(esp);
	}

	if (access->p2p_nsrcs != 0) {
		esp_p2p_enable_src(esp);
		esp_p2p_set_nsrcs(esp, access->p2p_nsrcs);
	}

	return 0;
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

	if (access->p2p_nsrcs > 4) {
		rc = -EINVAL;
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

	if (mutex_lock_interruptible(&esp->lock)) {
		rc = -EINTR;
		goto out;
	}

	rc = esp_p2p_init(esp, access);
	if (rc)
		goto out;

	esp->coherence = access->coherence;
	esp->footprint = access->footprint;
        esp->alloc_policy = access->alloc_policy;
        esp->ddr_node = access->ddr_node;
	esp->in_place = access->in_place;
	esp->reuse_factor = access->reuse_factor;

    if (mutex_lock_interruptible(&esp_status.lock)) {
        rc = -EINTR;
        goto out;
    }

    esp_runtime_config(esp);

    mutex_unlock(&esp_status.lock);

	rc = esp_flush(esp);
	if (rc)
		goto out;

	esp_transfer(esp, contig);

	if (esp->driver->prep_xfer)
		esp->driver->prep_xfer(esp, arg);

	if (access->run) {
		esp_run(esp);
		rc = esp_wait(esp);
	}

    if (mutex_lock_interruptible(&esp_status.lock)) {
        rc = -EINTR;
        goto out;
    }

    esp_update_status(esp);

    mutex_unlock(&esp_status.lock);

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

static long esp_flush_ioctl(struct esp_device *esp, void __user *argp)
{
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
	esp->coherence = access->coherence;
	rc = esp_flush(esp);
out:
	kfree(arg);
	return rc;
}

static long esp_do_ioctl(struct file *file, unsigned int cm, void __user *arg)
{
	struct esp_device *esp = file->private_data;

	switch (cm) {
	case ESP_IOC_RUN:
		return esp_run_ioctl(esp);
	case ESP_IOC_FLUSH:
		return esp_flush_ioctl(esp, arg);
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
	struct resource *res;
	int rc;

	esp->pdev = &pdev->dev;
	mutex_init(&esp->lock);
	init_completion(&esp->completion);

	rc = esp_create_cdev(esp, esp->number);
	if (rc)
		goto out;

#ifndef __sparc
	esp->irq = of_irq_get(pdev->dev.of_node, 0);
#else
	esp->irq = pdev->archdata.irqs[0];
#endif
	rc = request_irq(esp->irq, esp_irq, IRQF_SHARED, "esp", esp->pdev);
	if (rc) {
		dev_info(esp->pdev, "cannot request IRQ number %d\n", esp->irq);
		goto out_irq;
	}

	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
	esp->iomem = devm_ioremap_resource(&pdev->dev, res);
	if (esp->iomem == NULL) {
		dev_info(esp->pdev, "cannot map registers for I/O\n");
		goto out_iomem;
	}

	/* reset device and wait for it to complete */
	iowrite32be(0x0, esp->iomem + CMD_REG);
	while (ioread32be(esp->iomem + CMD_REG)){
        cpu_relax();
    }

	/* set type of coherence to no coherence by default */
	esp->coherence = ACC_COH_NONE;

	dev_info(esp->pdev, "l2_size: %zu, llc_size %zu, llc_banks: %lu.\n",
		cache_l2_size, cache_llc_size, cache_llc_banks);

	/* Add device to ESP devices list */
	spin_lock(&esp_devices_lock);
	list_add(&esp->list, &esp_devices);
	spin_unlock(&esp_devices_lock);

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
	list_del(&esp->list);
	free_irq(esp->irq, esp->pdev);
	esp_destroy_cdev(esp, esp->number);
	devm_iounmap(esp->pdev, esp->iomem);
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
        esp_status_init();
	return 0;
}

static void __exit esp_exit(void)
{ }

module_init(esp_init)
	module_exit(esp_exit)

	MODULE_AUTHOR("Emilio G. Cota <cota@braap.org>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("esp driver");
