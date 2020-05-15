#ifndef _OBFUSCATOR_H_
#define _OBFUSCATOR_H_

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

struct obfuscator_access {
	struct esp_access esp;
	/* <<--regs-->> */
	unsigned num_rows;
	unsigned num_cols;
	unsigned i_col_blur;
	unsigned i_row_blur;
    unsigned e_row_blur;
	unsigned e_col_blur;
    unsigned src_offset;
	unsigned dst_offset;
	unsigned ld_offset;
    unsigned st_offset;
};

#define OBFUSCATOR_IOC_ACCESS	_IOW ('S', 0, struct obfuscator_access)

#endif /* _OBFUSCATOR_H_ */
