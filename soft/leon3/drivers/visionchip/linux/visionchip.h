#ifndef _VISIONCHIP_H_
#define _VISIONCHIP_H_

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

#define MAX_NIMAGES 50
#define MAX_ROWS 480
#define MAX_COLS 640

struct visionchip_access {
	struct esp_access esp;
	// Number of images to be processed
	unsigned int nimages;
	// Rows of input matrix. Rows of output vector.
	unsigned int rows;
	// Cols of input matrix. Cols of input vector.
	unsigned int cols;
};

#define VISIONCHIP_IOC_ACCESS	_IOW ('S', 0, struct visionchip_access)

#endif /* _VISIONCHIP_H_ */
