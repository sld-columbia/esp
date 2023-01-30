#ifndef _SINKHORN_STRATUS_H_
#define _SINKHORN_STRATUS_H_

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

struct sinkhorn_access {
	struct esp_access esp;
	/* <<--regs-->> */
	unsigned maxiter;
	unsigned gamma;
	unsigned q_cols;
	unsigned m_rows;
	unsigned p_rows;
	unsigned p2p_out;
	unsigned p2p_in;
	unsigned p2p_iter;
	unsigned store_state;
	unsigned src_offset;
	unsigned dst_offset;
};

#define SINKHORN_IOC_ACCESS	_IOW ('S', 0, struct sinkhorn_access)

#endif /* _SINKHORN_STRATUS_H_ */
