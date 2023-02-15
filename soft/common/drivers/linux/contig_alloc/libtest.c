/*
 * Copyright (c) 2011-2023 Columbia University, System Level Design Group
 * SPDX-License-Identifier: Apache-2.0
 */

#include <assert.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include <contig.h>

static const char usage_str[] = "Usage:\n"
	"./contig_alloc-test n_bytes [n_bytes ...]\n"
	"  n_bytes is the amount of bytes for each allocation to be done.\n";
static unsigned long *sizes;
static contig_handle_t *handles;
static unsigned long n_allocs;

static void do_allocs(void)
{
	int i;

	handles = calloc(n_allocs, sizeof(*handles));
	if (handles == NULL) {
		perror(__func__);
		exit(1);
	}
	for (i = 0; i < n_allocs; i++) {
		if (contig_alloc(sizes[i], &handles[i]) == NULL) {
			perror(__func__);
			exit(1);
		}
		printf("allocation %i: handle %p\n", i, handles[i]);
	}
}

static void do_frees(void)
{
	int i;

	for (i = 0; i < n_allocs; i++)
		contig_free(handles[i]);
}

static void test_buf(int alloc_nr)
{
	contig_handle_t handle = handles[alloc_nr];
	unsigned long size = sizes[alloc_nr];
	unsigned long i;
	int mb = 0;

	printf("handle 0x%p, size %lu\n", (unsigned int *)handle, size);
	for (i = 0; i < size / sizeof(int); i++) {
		if (i && !((i * sizeof(int)) % (1024 * 1024))) {
			mb++;
			printf("  %d MB\n", mb);
		}
		contig_write32(0xdeadface, handle, i * sizeof(int));
	}

	for (i = 0; i < size / sizeof(int); i++) {
		assert(contig_read32(handle, i * sizeof(int)) == 0xdeadface);
	}
}

static void test_bufs(void)
{
	int i;

	for (i = 0; i < n_allocs; i++)
		test_buf(i);
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
	do_allocs();
	test_bufs();
	do_frees();
	return 0;
}
