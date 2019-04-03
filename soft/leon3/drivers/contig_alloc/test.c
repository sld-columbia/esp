/*
 * Copyright (c) 2011-2019 Columbia University, System Level Design Group
 * SPDX-License-Identifier: MIT
 */

#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <assert.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>

#include <contig_alloc.h>

#define CONTIG_ALLOC_DEV	"/dev/contig_alloc"

static const char usage_str[] = "Usage:\n"
	"./contig_alloc-test n_chunks [n_chunks ...]\n"
	"  n_chunks is the amount of chunks for each allocation to be done.\n";
static unsigned long chunk_size;
static unsigned long *sizes;
static struct contig_alloc_req *reqs;
static unsigned long n_allocs;
static int fd;

static void get_chunk_size(void)
{
	unsigned long log;

	if (ioctl(fd, CONTIG_IOC_CHUNK_LOG, &log) < 0) {
		perror(__func__);
		exit(1);
	}
	chunk_size = 1 << log;
}

static void do_mmap(struct contig_alloc_req *req)
{
	unsigned long flags = PROT_READ | PROT_WRITE;
	int i;

	req->mm = calloc(req->n, sizeof(*req->mm));
	if (req->mm == NULL) {
		perror(__func__);
		exit(1);
	}
	for (i = 0; i < req->n; i++) {
		req->mm[i] = mmap(NULL, chunk_size, flags, MAP_SHARED, fd, req->arr[i]);
		if (req->mm[i] == MAP_FAILED) {
			perror(__func__);
			exit(-1);
		}
	}
}

static void do_allocs(void)
{
	int i;

	reqs = calloc(n_allocs, sizeof(*reqs));
	if (reqs == NULL) {
		perror(__func__);
		exit(1);
	}
	for (i = 0; i < n_allocs; i++) {
		struct contig_alloc_req *req = &reqs[i];

		req->n_max = sizes[i] / chunk_size + 1;
		req->arr = calloc(req->n_max, sizeof(*req->arr));
		if (req->arr == NULL) {
			perror(__func__);
			exit(1);
		}
		req->size = sizes[i];

		if (ioctl(fd, CONTIG_IOC_ALLOC, req) < 0) {
			perror(__func__);
			exit(1);
		}
		printf("allocation %i: khandle %p n_chunks: %d size %ld bytes\n",
			i, req->khandle, req->n, req->size);
		do_mmap(req);
	}
}

static void do_frees(void)
{
	int i, j;

	for (i = 0; i < n_allocs; i++) {
		if (ioctl(fd, CONTIG_IOC_FREE, &reqs[i].khandle)) {
			perror(__func__);
			exit(1);
		}
		for (j = 0; j < reqs[i].n; j++) {
			if (munmap(reqs[i].mm[j], chunk_size)) {
				perror(__func__);
				exit(1);
			}
		}
	}
}

static void write_buf(int alloc_nr)
{
	struct contig_alloc_req *req = &reqs[alloc_nr];
	unsigned int *p;

	/* write first int of the first chunk */
	p = req->mm[0];
	*p = 0xdeadbee0;
	*(p + 1) = 0xdeadbee1;

	/* write last int of the last chunk */
	p = req->mm[req->n - 1];
	*(p + chunk_size / sizeof(*p) - 1) = 0xdeaddea0;
	*(p + chunk_size / sizeof(*p) - 2) = 0xdeaddea1;

	/* read them */
	p = req->mm[0];
	assert(*p == 0xdeadbee0);
	assert(*(p + 1) == 0xdeadbee1);
	p = req->mm[req->n - 1];
	assert(*(p + chunk_size / sizeof(*p) - 1) == 0xdeaddea0);
	assert(*(p + chunk_size / sizeof(*p) - 2) == 0xdeaddea1);
}

static void write_bufs(void)
{
	int i;

	for (i = 0; i < n_allocs; i++) {
		write_buf(i);
	}
}

int main(int argc, char *argv[])
{
	int i;

	argc--;
	argv++;
	if (argc == 0) {
		fprintf(stderr, "%s\n", usage_str);
		exit(1);
	}
	for (i = 0; i < argc; i++) {
		sizes = realloc(sizes, sizeof(*sizes) * (n_allocs + 1));
		if (sizes == NULL) {
			perror(NULL);
			exit(1);
		}
		sizes[i] = strtoul(argv[i], NULL, 0);
		n_allocs++;
	}
	fd = open(CONTIG_ALLOC_DEV, O_RDWR);
	if (fd < 0) {
		perror(CONTIG_ALLOC_DEV);
		exit(1);
	}
	get_chunk_size();
	do_allocs();
	write_bufs();
	do_frees();
	if (close(fd) < 0) {
		perror(CONTIG_ALLOC_DEV ": close");
		exit(1);
	}
	return 0;
}
