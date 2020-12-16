#ifndef _FFT_H_
#define _FFT_H_

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

struct fft_access {
	struct esp_access esp;
	/* <<--regs-->> */
	unsigned log_len;
	unsigned do_bitrev;
	unsigned src_offset;
	unsigned dst_offset;

};

#define FFT_IOC_ACCESS	_IOW ('S', 0, struct fft_access)

#endif /* _FFT_H_ */
