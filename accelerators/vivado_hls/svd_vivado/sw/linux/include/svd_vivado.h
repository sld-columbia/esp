#ifndef _SVD_VIVADO_H_
#define _SVD_VIVADO_H_

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

struct svd_access {
	struct esp_access esp;
	/* <<--regs-->> */
	unsigned q;
	unsigned p;
	unsigned m;
	unsigned p2p_out;
	unsigned p2p_in;
	unsigned p2p_iter;
	unsigned load_state;
	unsigned src_offset;
	unsigned dst_offset;
};

#define SVD_IOC_ACCESS	_IOW ('S', 0, struct svd_access)

#endif /* _SVD_VIVADO_H_ */
