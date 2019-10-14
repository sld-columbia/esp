#ifndef _COUNTERACCELERATOR_H_
#define _COUNTERACCELERATOR_H_

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

struct CounterAccelerator_access {
	struct esp_access esp;
	unsigned int ticks;
};

#define COUNTERACCELERATOR_IOC_ACCESS	_IOW ('S', 0, struct CounterAccelerator_access)

#endif /* _COUNTERACCELERATOR_H_ */
