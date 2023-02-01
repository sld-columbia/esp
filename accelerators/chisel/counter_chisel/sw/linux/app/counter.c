// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>

#include <my_stringify.h>
#include <test/test.h>
#include <test/time.h>
#include <counter_chisel.h>

#define DEVNAME "/dev/counter_chisel.0"
#define NAME "counter_chisel"

static const char usage_str[] = "usage: counter_chisel <ticks>\n"
	"  ticks: counter initialization\n"
	"\n";

struct counter_test {
	struct test_info info;
	struct counter_chisel_access desc;
	unsigned int ticks;
};

static inline struct counter_test *to_counter(struct test_info *info)
{
	return container_of(info, struct counter_test, info);
}

static inline size_t counter_size()
{
	return 4096;
}

static void counter_alloc_buf(struct test_info *info)
{
}

static void counter_alloc_contig(struct test_info *info)
{
	if (contig_alloc(counter_size(), &info->contig) == NULL)
		die_errno(__func__);

}

static void counter_init_bufs(struct test_info *info)
{
}

static void counter_set_access(struct test_info *info)
{
	struct counter_test *t = to_counter(info);

	t->desc.ticks = t->ticks;
}

static bool counter_diff_ok(struct test_info *info)
{
	return true;
}

static struct counter_test counter_test = {
	.info = {
		.name		= NAME,
		.devname	= DEVNAME,
		.alloc_buf	= counter_alloc_buf,
		.alloc_contig	= counter_alloc_contig,
		.init_bufs	= counter_init_bufs,
		.set_access	= counter_set_access,
		.diff_ok	= counter_diff_ok,
		.esp		= &counter_test.desc.esp,
		.cm		= COUNTER_CHISEL_IOC_ACCESS,
	},
};

static void NORETURN usage(void)
{
	fprintf(stderr, "%s", usage_str);
	exit(1);
}

int main(int argc, char *argv[])
{
	if (argc != 2)
		usage();

	counter_test.ticks = strtoul(argv[1], NULL, 0);
	printf(" ** Chisel3 counter Device Test - %d ticks **\n", counter_test.ticks);

	/*
	 * Set coherence to full because memory is not accessed
	 * Run hw-only test because no software comparison is required.
	 */
	return test_main(&counter_test.info, "full", "hw");
}
