#ifndef _FFT2D_H_
#define _FFT2D_H_

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

struct fft2d_access {
	struct esp_access esp;
	unsigned log2;
	unsigned transpose;
};

#define FFT2D_IOC_ACCESS	_IOW ('2', 0, struct fft2d_access)

#endif /* _FFT2D_H_ */
