#ifndef _VITBFLY2_H_
#define _VITBFLY2_H_

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

struct vitbfly2_access {
	struct esp_access esp;
};

#define VITBFLY2_IOC_ACCESS	_IOW ('S', 0, struct vitbfly2_access)

#endif /* _VITBFLY2_H_ */
