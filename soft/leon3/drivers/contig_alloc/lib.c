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

int contig_alloc(unsigned long size, contig_handle_t *handle)
{
	struct contig_alloc_req *req;
	unsigned long flags = PROT_READ | PROT_WRITE;
	int i;

	if (unlikely(contig_init()))
		return -1;
	req = calloc(1, sizeof(*req));
	if (unlikely(req == NULL))
		return -1;
	req->n_max = DIV_ROUND_UP(size, chunk_size);

	req->arr = calloc(req->n_max, sizeof(*req->arr));
	if (unlikely(req->arr == NULL))
		goto err_arr;

	req->mm = calloc(req->n_max, sizeof(*req->mm));
	if (unlikely(req->mm == NULL))
		goto err_mm;

	req->size = size;

	/* Default policy is get chunks in order */
	req->params.policy = CONTIG_ALLOC_PREFERRED;
	req->params.pol.first.ddr_node = 0;

	if (ioctl(fd, CONTIG_IOC_ALLOC, req) < 0)
		goto err_ioctl;

	for (i = 0; i < req->n; i++) {
		req->mm[i] = mmap(NULL, chunk_size, flags, MAP_SHARED, fd, req->arr[i]);
		if (req->mm[i] == MAP_FAILED) {
			goto err_mmap;
		}
	}

	*handle = (contig_handle_t)req;
	return 0;

 err_mmap:
	while (--i >= 0) {
		if (munmap(req->mm[i], chunk_size))
			fprintf(stderr, PFX "munmap failed for %p\n", req->mm[i]);
	}
 err_ioctl:
	free(req->mm);
 err_mm:
	free(req->arr);
 err_arr:
	free(req);
	return -1;
}

int contig_alloc_policy(struct contig_alloc_params params, unsigned long size, contig_handle_t *handle)
{
	struct contig_alloc_req *req;
	unsigned long flags = PROT_READ | PROT_WRITE;
	int i;

	if (unlikely(contig_init()))
		return -1;
	req = calloc(1, sizeof(*req));
	if (unlikely(req == NULL))
		return -1;
	req->n_max = DIV_ROUND_UP(size, chunk_size);

	req->arr = calloc(req->n_max, sizeof(*req->arr));
	if (unlikely(req->arr == NULL))
		goto err_arr;

	req->mm = calloc(req->n_max, sizeof(*req->mm));
	if (unlikely(req->mm == NULL))
		goto err_mm;

	req->size = size;

	req->params = params;

	if (ioctl(fd, CONTIG_IOC_ALLOC, req) < 0)
		goto err_ioctl;

	for (i = 0; i < req->n; i++) {
		req->mm[i] = mmap(NULL, chunk_size, flags, MAP_SHARED, fd, req->arr[i]);
		if (req->mm[i] == MAP_FAILED) {
			goto err_mmap;
		}
	}

	*handle = (contig_handle_t)req;
	return 0;

 err_mmap:
	while (--i >= 0) {
		if (munmap(req->mm[i], chunk_size))
			fprintf(stderr, PFX "munmap failed for %p\n", req->mm[i]);
	}
 err_ioctl:
	free(req->mm);
 err_mm:
	free(req->arr);
 err_arr:
	free(req);
	return -1;
}

void contig_free(contig_handle_t handle)
{
	struct contig_alloc_req *req = (struct contig_alloc_req *)handle;
	int i;

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
	for (i = 0; i < req->n; i++) {
		if (munmap(req->mm[i], chunk_size))
			fprintf(stderr, PFX "munmap failed for %p\n", req->mm[i]);
	}
	free(req->arr);
	free(req->mm);
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
	unsigned long copied;
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

	copied = 0;
	curr = req->mm[chunk_nr(offset)];
	curr += offset & ~chunk_mask;
	fr = vaddr;
	/* Note: we cannot assume any aligment for req->mm[i] */
	while (copied < size) {
		unsigned long remainder;
		unsigned long sz;

		remainder = chunk_size - ((offset + copied) & ~chunk_mask);
		/* copy the remainder of the chunk, or less if end is here */
		sz = min(size - copied, remainder);

		if (to_contig)
			memcpy(curr, fr, sz);
		else
			memcpy(fr, curr, sz);
		copied += sz;
		fr += sz;
		curr = req->mm[chunk_nr(offset + copied)];
	}
}

void contig_copy_to(contig_handle_t handle, unsigned long offset, void *from, unsigned long size)
{
	contig_copy(handle, offset, from, size, true);
}

void contig_copy_from(void *to, contig_handle_t handle, unsigned long offset, unsigned long size)
{
	contig_copy(handle, offset, to, size, false);
}

void contig_memcpy(contig_handle_t to, unsigned long to_off, contig_handle_t fr, unsigned long fr_off, unsigned long size)
{
	struct contig_alloc_req *to_req = (struct contig_alloc_req *)to;
	struct contig_alloc_req *fr_req = (struct contig_alloc_req *)fr;
	unsigned long copied;
	uint8_t *to_curr;
	uint8_t *fr_curr;

	assert(to_req);
	assert(fr_req);
	if (unlikely(contig_init())) {
		fprintf(stderr, PFX "error: %s: cannot init contig\n", __func__);
		abort();
	}
	if (to_off + size > to_req->n * chunk_size) {
		fprintf(stderr, PFX "error: %s: destination out of bounds (offset 0x%lx + size %ld)\n",
			__func__, to_off, size);
		abort();
	}
	if (fr_off + size > fr_req->n * chunk_size) {
		fprintf(stderr, PFX "error: %s: origin out of bounds (offset 0x%lx + size %ld)\n",
			__func__, fr_off, size);
		abort();
	}

	copied = 0;
	while (copied < size) {
		unsigned long to_part = (to_off + copied) & ~chunk_mask;
		unsigned long fr_part = (fr_off + copied) & ~chunk_mask;
		unsigned long to_remainder;
		unsigned long fr_remainder;
		unsigned long sz;

		to_curr = to_req->mm[chunk_nr(to_off + copied)] + to_part;
		fr_curr = fr_req->mm[chunk_nr(fr_off + copied)] + fr_part;

		to_remainder = min(size - copied, chunk_size - to_part);
		fr_remainder = min(size - copied, chunk_size - fr_part);
		sz = min(to_remainder, fr_remainder);

		memcpy(to_curr, fr_curr, sz);
		copied += sz;
	}
}
