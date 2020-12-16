#ifndef _SORT_H_
#define _SORT_H_

#ifdef __KERNEL__
#include <linux/ioctl.h>
#include <linux/types.h>
#else
#include <sys/ioctl.h>
#include <stdint.h>
#ifndef __user
#define __user
#endif
#endif /* __KERNEL__ */

#include <esp.h>
#include <esp_accelerator.h>

struct sort_access {
	struct esp_access esp;
	unsigned int size;
	unsigned int batch;
};

#define SORT_IOC_ACCESS	_IOW ('S', 0, struct sort_access)

#endif /* _SORT_H_ */
