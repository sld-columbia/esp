#ifndef _CHANGE_DETECTION_H_
#define _CHANGE_DETECTION_H_

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

struct change_detection_access {
	struct esp_access esp;
	unsigned int rows;
	unsigned int cols;
};

#define CHANGE_DETECTION_IOC_ACCESS	_IOW ('C', 0, struct change_detection_access)

#endif /* _CHANGE_DETECTION_H_ */
