/*
 * Copyright (c) 2011-2023 Columbia University, System Level Design Group
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef CONTIG_H
#define CONTIG_H

#include <inttypes.h>

/* bring in contig_khandle_t */
#include <contig_alloc.h>

/* enforce strict typecheck */
struct contig_handle_struct {
	char unused;
};
typedef struct contig_handle_struct *contig_handle_t;

/**
 * contig_alloc and contig_alloc_polcy - allocate a contiguous buffer
 * @params: allocation policy and parameters
 * @size: size of the buffer to be allocated
 * @handle: pointer where to store the handle of the resulting contig buffer
 *
 * Allocates a contiguous buffer and returns its handle via @handle.
 * Note that all accesses to the buffer must happen via the contig helpers;
 * the handle has no meaning other than uniquely identifying the buffer.
 *
 * Returns 0 on success or -1 on error, setting errno.
 */
void *contig_alloc(unsigned long size, contig_handle_t *handle);
void *contig_alloc_policy(struct contig_alloc_params params, unsigned long size, contig_handle_t *handle);

/**
 * contig_free - free a contiguous buffer
 * @handle: handle of the buffer to be freed
 */
void contig_free(contig_handle_t handle);

/**
 * contig_to_khandle - obtain a kernel handle from a handle
 * @handle: contig buffer handle to obtain the kernel handle from
 *
 * The handle used in the rest of the functions is only valid for the
 * same user-space process. In order to pass a contiguous buffer to
 * kernel-space, this function needs to be called to obtain a converted
 * handle that is valid in kernel space.
 */
contig_khandle_t contig_to_khandle(contig_handle_t handle);


/**
 * contig_to_most_allocated - get on which ddr node most chunks have
 * been allocated
 * @handle: contig buffer handle to obtain the kernel handle from
 *
 * This function is relevant for policies PREFERRED and LEAST_LOADED
 * while for BALANCED, the difference across ddr nodes is not relevant
 *
 */
int contig_to_most_allocated(contig_handle_t handle);

/**
 * contig_copy_to - copy data to a contig buffer
 * @handle: handle of the buffer to copy to
 * @offset: byte offset within the contig buffer
 * @from: pointer to regular memory to copy from
 * @size: size of the transfer
 */
void contig_copy_to(contig_handle_t handle, unsigned long offset, void *from, unsigned long size);

/**
 * contig_copy_from - copy data from a contig buffer
 * @to: pointer to regular memory to copy to
 * @handle: handle of the buffer to copy from
 * @offset: byte offset within the contig buffer
 * @size: size of the transfer
 */
void contig_copy_from(void *to, contig_handle_t handle, unsigned long offset, unsigned long size);

#define DEF_CONTIG_READ(funcname_, type_)				\
	static inline type_						\
	funcname_(contig_handle_t handle, unsigned long offs)		\
	{								\
		type_ ret;						\
									\
		contig_copy_from(&ret, handle, offs, sizeof(ret));	\
		return ret;						\
	}

/**
 * contig_read32 - read a uint32_t from a contig buffer
 * @handle: handle of the buffer to read from
 * @offs: byte offset within the contig buffer
 *
 * Returns the value read from the contig buffer.
 */
DEF_CONTIG_READ(contig_read32, uint32_t)
DEF_CONTIG_READ(contig_read16, uint16_t)
DEF_CONTIG_READ(contig_read8,  uint8_t)
DEF_CONTIG_READ(contig_read64, uint64_t)

#define DEF_CONTIG_WRITE(funcname_, type_)				\
	static inline void						\
	funcname_(type_ val, contig_handle_t handle, unsigned long offs)\
	{								\
		contig_copy_to(handle, offs, &val, sizeof(val));	\
	}

/**
 * contig_write32 - write a uint32_t to a contig buffer
 * @val: value to be written
 * @handle: handle of the buffer to write to
 * @offs: byte offset within the contig buffer
 */
DEF_CONTIG_WRITE(contig_write32, uint32_t)
DEF_CONTIG_WRITE(contig_write16, uint16_t)
DEF_CONTIG_WRITE(contig_write8,  uint8_t)
DEF_CONTIG_WRITE(contig_write64, uint64_t)

#endif /* CONTIG_H */
