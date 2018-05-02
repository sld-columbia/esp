#ifndef _DEBAYER_H_
#define _DEBAYER_H_

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

struct debayer_access {
	struct esp_access esp;
	unsigned int rows;
	unsigned int cols;
};

#define DEBAYER_IOC_ACCESS	_IOW ('D', 0, struct debayer_access)

#endif /* _DEBAYER_H_ */
