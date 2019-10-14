#ifndef _<ACCELERATOR_NAME>_H_
#define _<ACCELERATOR_NAME>_H_

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

struct <accelerator_name>_access {
	struct esp_access esp;
	/* <<--regs-->> */
	unsigned src_offset;
	unsigned dst_offset;
};

#define <ACCELERATOR_NAME>_IOC_ACCESS	_IOW ('S', 0, struct <accelerator_name>_access)

#endif /* _<ACCELERATOR_NAME>_H_ */
