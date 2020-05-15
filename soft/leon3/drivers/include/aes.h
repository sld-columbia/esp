#ifndef _AES_H_
#define _AES_H_

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

struct aes_access {
	struct esp_access esp;
	/* <<--regs-->> */
	unsigned encryption;
	unsigned num_blocks;
	unsigned src_offset;
	unsigned dst_offset;
};

#define AES_IOC_ACCESS	_IOW ('S', 0, struct aes_access)

#endif /* _AES_H_ */
