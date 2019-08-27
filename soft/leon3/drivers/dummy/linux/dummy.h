#ifndef _DUMMY_H_
#define _DUMMY_H_

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

struct dummy_access {
	struct esp_access esp;
	unsigned tokens;
	unsigned batch;
	unsigned src_offset;
	unsigned dst_offset;
};

#define DUMMY_IOC_ACCESS	_IOW ('S', 0, struct dummy_access)

#endif /* _DUMMY_H_ */
