/*
 * Copyright (c) 2011-2023 Columbia University, System Level Design Group
 * SPDX-License-Identifier: Apache-2.0
 */

#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <stdbool.h>
#include <assert.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>

#include <pthread.h>

#include <contig_alloc.h>
#include <contig.h>

#define CONTIG_ALLOC_DEV	"/dev/contig_alloc"
#define PFX			"libcontig: "

#define likely(cond)		__builtin_expect(!!(cond), 1)
#define unlikely(cond)		__builtin_expect(!!(cond), 0)

#define atomic_read(ptr)	(*(__typeof__(*ptr) volatile*) (ptr))
#define atomic_set(ptr, i)	((*(__typeof__(*ptr) volatile*) (ptr)) = (i))

#define DIV_ROUND_UP(n,d)	(((n) + (d) - 1) / (d))

#define min(x, y) ({					\
			typeof(x) _min1 = (x);		\
			typeof(y) _min2 = (y);		\
			(void) (&_min1 == &_min2);	\
			_min1 < _min2 ? _min1 : _min2;	\
		})

static int fd;
static unsigned long chunk_log;
static unsigned long chunk_size;
static unsigned long chunk_mask;
static pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;

static int contig_init(void)
{
	int local_fd;
	int rc = -1;

	if (likely(atomic_read(&fd)))
		return 0;

	local_fd = open(CONTIG_ALLOC_DEV, O_RDWR);
	if (local_fd < 0)
		return -1;

	pthread_mutex_lock(&lock);

	/* only assign fd to local_fd if nobody else has done it yet */
	if (atomic_read(&fd)) {
		if (close(local_fd) < 0)
			goto unlock;
	} else {
		atomic_set(&fd, local_fd);
	}

	if (ioctl(fd, CONTIG_IOC_CHUNK_LOG, &chunk_log) < 0)
		goto unlock;
	chunk_size = 1 << chunk_log;
	chunk_mask = ~(chunk_size - 1);
	rc = 0;
 unlock:
	pthread_mutex_unlock(&lock);
	return rc;
}

void *contig_alloc(unsigned long size, contig_handle_t *handle)
{
	struct contig_alloc_req *req;
	unsigned long flags = PROT_READ | PROT_WRITE;

	if (unlikely(contig_init()))
		return NULL;
	req = calloc(1, sizeof(*req));
	if (unlikely(req == NULL))
		return NULL;
	req->n_max = DIV_ROUND_UP(size, chunk_size);

	req->arr = calloc(req->n_max, sizeof(*req->arr));
	if (unlikely(req->arr == NULL))
		goto err_arr;

	req->size = size;

	/* Default policy is get chunks in order */
	req->params.policy = CONTIG_ALLOC_PREFERRED;
	req->params.pol.first.ddr_node = 0;

	if (ioctl(fd, CONTIG_IOC_ALLOC, req) < 0)
		goto err_ioctl;

	req->mm = mmap(NULL, req->n * chunk_size, flags, MAP_SHARED, fd, req->arr[0]);
	if (req->mm == MAP_FAILED) {
		goto err_mmap;
	}

	*handle = (contig_handle_t)req;
	return req->mm;

 err_mmap:
	if (munmap(req->mm, chunk_size))
		fprintf(stderr, PFX "munmap failed for %p\n", req->mm);
 err_ioctl:
	free(req->arr);
 err_arr:
	free(req);
	return NULL;
}

void *contig_alloc_policy(struct contig_alloc_params params, unsigned long size, contig_handle_t *handle)
{
	struct contig_alloc_req *req;
	unsigned long flags = PROT_READ | PROT_WRITE;

	if (unlikely(contig_init()))
		return NULL;
	req = calloc(1, sizeof(*req));
	if (unlikely(req == NULL))
		return NULL;
	req->n_max = DIV_ROUND_UP(size, chunk_size);

	req->arr = calloc(req->n_max, sizeof(*req->arr));
	if (unlikely(req->arr == NULL))
		goto err_arr;

	req->size = size;

	req->params = params;

	if (ioctl(fd, CONTIG_IOC_ALLOC, req) < 0)
		goto err_ioctl;

	req->mm = mmap(NULL, req->n * chunk_size, flags, MAP_SHARED, fd, req->arr[0]);
	if (req->mm == MAP_FAILED) {
		goto err_mmap;
	}

	*handle = (contig_handle_t)req;
	return req->mm;

 err_mmap:
	if (munmap(req->mm, chunk_size))
		fprintf(stderr, PFX "munmap failed for %p\n", req->mm);
 err_ioctl:
	free(req->arr);
 err_arr:
	free(req);
	return NULL;
}

void contig_free(contig_handle_t handle)
{
	struct contig_alloc_req *req = (struct contig_alloc_req *)handle;

	assert(req);
	if (unlikely(contig_init())) {
		fprintf(stderr, PFX "error: %s: cannot init contig\n", __func__);
		abort();
	}
	if (ioctl(fd, CONTIG_IOC_FREE, &req->khandle)) {
		fprintf(stderr, PFX "error: %s: cannot free handle %p\n", __func__, handle);
		perror(NULL);
		abort();
	}
	if (munmap(req->mm, chunk_size))
		fprintf(stderr, PFX "munmap failed for %p\n", req->mm);
	free(req->arr);
	free(req);
}

contig_khandle_t contig_to_khandle(contig_handle_t handle)
{
	struct contig_alloc_req *req = (struct contig_alloc_req *)handle;

	assert(req);
	return req->khandle;
}

int contig_to_most_allocated(contig_handle_t handle)
{
	struct contig_alloc_req *req = (struct contig_alloc_req *)handle;

	assert(req);
	return req->most_allocated;
}

static inline unsigned long chunk_nr(unsigned long offset)
{
	return (offset & chunk_mask) >> chunk_log;
}

static void contig_copy(contig_handle_t handle, unsigned long offset, void *vaddr, unsigned long size, bool to_contig)
{
	struct contig_alloc_req *req = (struct contig_alloc_req *)handle;
	uint8_t *curr;
	uint8_t *fr;

	assert(req);
	if (unlikely(contig_init())) {
		fprintf(stderr, PFX "error: %s: cannot init contig\n", __func__);
		abort();
	}

	if (offset + size > req->n * chunk_size) {
		fprintf(stderr, PFX "error: %s: out of bounds (offset 0x%lx + size %ld)\n",
			__func__, offset, size);
		abort();
	}

	curr = req->mm;
	curr += offset;
	fr = vaddr;

	if (to_contig)
		memcpy(curr, fr, size);
	else
		memcpy(fr, curr, size);
}

void contig_copy_to(contig_handle_t handle, unsigned long offset, void *from, unsigned long size)
{
	contig_copy(handle, offset, from, size, true);
}

void contig_copy_from(void *to, contig_handle_t handle, unsigned long offset, unsigned long size)
{
	contig_copy(handle, offset, to, size, false);
}
