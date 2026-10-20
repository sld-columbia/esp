// Copyright (c) 2011-2026 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef _GT_VORTEX_RTL_H_
#define _GT_VORTEX_RTL_H_

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

/*
 * Shared ioctl payload used by:
 * - user-space test apps/runtime (producer),
 * - kernel driver (consumer),
 * to program the GT_VORTEX wrapper registers before launch.
 */
struct gt_vortex_rtl_access {
	/* Generic ESP descriptor consumed by esp_run()/ESP driver framework. */
	struct esp_access esp;
	/* <<--regs-->> */
	/* Readback status register (optional in user-space; wrapper-owned). */
	unsigned VX_BUSY_INT;
	/* Base physical address of Vortex global memory window. */
	unsigned BASE_ADDR;
	/* Start pulse bit consumed by wrapper state machine. */
	unsigned START_VORTEX;
	/* Kernel entry address (low/high 32-bit split). */
	unsigned STARTUP_ADDR0;
	unsigned STARTUP_ADDR1;
	/* Kernel argument address (low/high 32-bit split). */
	unsigned STARTUP_ARG0;
	unsigned STARTUP_ARG1;
	/* Performance monitor class selector. */
	unsigned MPM_CLASS;
};

/* Single ioctl command that submits one launch descriptor. */
#define GT_VORTEX_RTL_IOC_ACCESS	_IOW ('S', 0, struct gt_vortex_rtl_access)

#endif /* _GT_VORTEX_RTL_H_ */
