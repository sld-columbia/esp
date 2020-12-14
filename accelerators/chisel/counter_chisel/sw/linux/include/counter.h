#ifndef _COUNTER_H_
#define _COUNTER_H_

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

struct counter_access {
	struct esp_access esp;
	unsigned int ticks;
};

#define COUNTER_IOC_ACCESS	_IOW ('S', 0, struct counter_access)

#endif /* _COUNTER_H_ */
