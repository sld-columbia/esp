#ifndef _FFT2_STRATUS_H_
#define _FFT2_STRATUS_H_

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

struct fft2_stratus_access {
	struct esp_access esp;
	/* <<--regs-->> */
	unsigned scale_factor;
	unsigned do_inverse;
	unsigned logn_samples;
	unsigned do_shift;
	unsigned num_ffts;
	unsigned src_offset;
	unsigned dst_offset;
};

#define FFT2_STRATUS_IOC_ACCESS	_IOW ('S', 0, struct fft2_stratus_access)

#endif /* _FFT2_STRATUS_H_ */
