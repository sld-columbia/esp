#ifndef _GEMM_H_
#define _GEMM_H_

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

struct gemm_access {
	struct esp_access esp;
	/* <<--regs-->> */
	unsigned do_relu;
	unsigned transpose;
	unsigned ninputs;
	unsigned d3;
	unsigned d2;
	unsigned d1;
	unsigned st_offset;
	unsigned ld_offset1;
	unsigned ld_offset2;
	unsigned src_offset;
	unsigned dst_offset;
};

#define GEMM_IOC_ACCESS	_IOW ('S', 0, struct gemm_access)

#endif /* _GEMM_H_ */
