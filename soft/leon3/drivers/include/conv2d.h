#ifndef _CONV2D_H_
#define _CONV2D_H_

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

struct conv2d_access {
	struct esp_access esp;
	/* <<--regs-->> */
	unsigned n_channels;
	unsigned n_filters;
	unsigned filter_height;
	unsigned dilation_h;
	unsigned stride_w;
	unsigned pad_w;
	unsigned feature_map_height;
	unsigned pad_h;
	unsigned stride_h;
	unsigned filter_width;
	unsigned dilation_w;
	unsigned feature_map_width;
	unsigned src_offset;
	unsigned dst_offset;
};

#define CONV2D_IOC_ACCESS	_IOW ('S', 0, struct conv2d_access)

#endif /* _CONV2D_H_ */
