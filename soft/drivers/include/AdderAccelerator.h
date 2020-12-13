#ifndef _ADDERACCELERATOR_H_
#define _ADDERACCELERATOR_H_

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

struct adderaccelerator_access {
	struct esp_access esp;
	/* <<--regs-->> */
	unsigned size;
	unsigned readAddr;
	unsigned writeAddr;
	unsigned src_offset;
	unsigned dst_offset;
};

#define ADDERACCELERATOR_IOC_ACCESS	_IOW ('S', 0, struct adderaccelerator_access)

#endif /* _ADDERACCELERATOR_H_ */
