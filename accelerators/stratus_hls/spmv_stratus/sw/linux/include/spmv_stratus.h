// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef _SPMV_STRATUS_H_
#define _SPMV_STRATUS_H_

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

struct spmv_stratus_access {
	struct esp_access esp;
	// Rows of input matrix. Rows of output vector.
	// Powers of 2
	unsigned int nrows;
	// Cols of input matrix. Cols of input vector.
	// Powers of 2
	unsigned int ncols;
	// Max of non-zero entries in a matrix row.
	// 4, 8, 16 or 32
	unsigned int max_nonzero;
	// Number of total nonzero matrix elements
	// Stored in .data input file
	unsigned int mtx_len;
	// PLM size to be used for values. All other sizes are derived
	// Max is 1024
	unsigned int vals_plm_size;
	// 'True' is the vector size fits the vector PLM and if it should be stored there
	// Set to false if ncols > 8192
	unsigned int vect_fits_plm;
};

#define SPMV_STRATUS_IOC_ACCESS	_IOW ('S', 0, struct spmv_stratus_access)

#endif /* _SPMV_STRATUS_H_ */
