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
	enum accelerator_coherence coherence;
        unsigned int footprint;
        enum contig_alloc_policy alloc_policy;
        unsigned int ddr_node;
};

#define ESP_IOC_RUN _IO('E', 0)
#define ESP_IOC_FLUSH _IO('E', 1)

#ifdef __KERNEL__

#include <linux/platform_device.h>
#include <linux/completion.h>
#include <linux/device.h>
#include <linux/module.h>
#include <linux/mutex.h>
#include <linux/cdev.h>

#define N_MEM 2
#define PRIVATE_CACHE_SIZE 16384
#define LLC_SIZE 524288
#define LLC_SIZE_SPLIT 262144 

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
        unsigned int footprint;
        enum contig_alloc_policy alloc_policy;
        unsigned int ddr_node;
};

struct esp_status {
    struct mutex lock;
    unsigned int active_acc_cnt;
    unsigned int active_footprint;
    unsigned int active_footprint_split[N_MEM]; // 2 mem ctrl
};

int esp_driver_register(struct esp_driver *driver);
void esp_driver_unregister(struct esp_driver *driver);
int esp_device_register(struct esp_device *esp, struct platform_device *pdev);
void esp_device_unregister(struct esp_device *device);
void esp_status_init(void);

#endif /* __KERNEL__ */

#endif /* ESP_H */
