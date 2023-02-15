/*
 * Copyright (c) 2011-2023 Columbia University, System Level Design Group
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef TEST_TEST_H
#define TEST_TEST_H

#include <stdbool.h>
#include <stdlib.h>

#include <contig.h>
#include <esp.h>
#include <esp_accelerator.h>

#ifndef offsetof
#define offsetof(TYPE, MEMBER) ((size_t) &((TYPE *)0)->MEMBER)
#endif

#ifndef container_of
#define container_of(ptr, type, member) ({				\
			const typeof(((type *)0)->member) * __mptr = (ptr); \
			(type *)((char *)__mptr - offsetof(type, member)); })
#endif

#ifndef ARRAY_SIZE
#define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
#endif

#ifndef NORETURN
#define NORETURN __attribute__((noreturn))
#endif

struct test_info {
	const char *name;
	const char *devname;
	const char *cmd;
	void (*alloc_buf)(struct test_info *);
	void (*alloc_contig)(struct test_info *);
	void (*init_bufs)(struct test_info *);
	void (*to_sc_fixed)(struct test_info *); /* can be NULL */
	void (*set_access)(struct test_info *); /* can be NULL */
	void (*comp)(struct test_info *); /* can be NULL */
	void (*to_float)(struct test_info *); /* can be NULL */
	bool  (*diff_ok)(struct test_info *);
	struct esp_access *esp;
	contig_handle_t contig;
	int cm;
	int fd; /* filled in by the library */
};

int test_main(struct test_info *info, const char * coh, const char *cmd);
void NORETURN die(const char *fmt, ...);
void NORETURN die_errno(const char *fmt, ...);

static inline void *malloc0_check(size_t size)
{
	void *buf;

	buf = calloc(1, size);
	if (buf == NULL)
		die_errno("%s: cannot allocate %zu bytes", __func__, size);
	return buf;
}

#endif /* TEST_TEST_H */
