#ifndef ESP_H
#define ESP_H

#include <contig_alloc.h>
#include <esp_accelerator.h>
#include <esp_cache.h>
#ifdef __KERNEL__
#include <linux/ioctl.h>
#include <linux/types.h>
#else
#include <sys/ioctl.h>
#include <stdint.h>
#endif /* __KERNEL__ */

/* embed this struct at the beginning of the access struct */
struct esp_access {
	contig_khandle_t contig;
	uint8_t run;
};

#define ESP_IOC_RUN _IO('E', 0)

#ifdef __KERNEL__

#include <linux/platform_device.h>
#include <linux/completion.h>
#include <linux/device.h>
#include <linux/module.h>
#include <linux/mutex.h>
#include <linux/cdev.h>

struct esp_device;

struct esp_driver {
	struct class *class;
	dev_t devno;
	/* the below are filled in by drivers */
	struct platform_driver plat;
	bool (*xfer_input_ok)(struct esp_device *esp, void *arg);
	void (*prep_xfer)(struct esp_device *esp, void *arg);
	unsigned int ioctl_cm;
	size_t arg_size;
};

struct esp_device {
	struct cdev cdev;
	struct device *pdev; /* parent device */
	struct device *dev; /* associated device */
	struct mutex lock;
	struct completion completion;
	void __iomem *iomem; /* mmapped registers */
	int irq;
	int err;
	/* the below are filled in by drivers */
	struct esp_driver *driver;
	struct module *module;
	int number;
	enum accelerator_coherence coherence;
};

int esp_driver_register(struct esp_driver *driver);
void esp_driver_unregister(struct esp_driver *driver);
int esp_device_register(struct esp_device *esp, struct platform_device *pdev);
void esp_device_unregister(struct esp_device *device);

#endif /* __KERNEL__ */

#endif /* ESP_H */
