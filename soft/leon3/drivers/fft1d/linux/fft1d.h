#ifndef _FFT1D_H_
#define _FFT1D_H_

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

struct fft1d_access {
	struct esp_access esp;
	uint32_t log2;
};

#define FFT1D_IOC_ACCESS	_IOW ('F', 0, struct fft1d_access)

#endif /* _FFT1D_H_ */
