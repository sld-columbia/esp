#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>

#include <my_stringify.h>
#include <test/test.h>
#include <test/time.h>
#include <CounterAccelerator.h>

#define DEVNAME "/dev/CounterAccelerator.0"
#define NAME "CounterAccelerator"

static const char usage_str[] = "usage: CounterAccelerator <ticks>\n"
	"  ticks: counter initialization\n"
	"\n";

struct CounterAccelerator_test {
	struct test_info info;
	struct CounterAccelerator_access desc;
	unsigned int ticks;
};

static inline struct CounterAccelerator_test *to_CounterAccelerator(struct test_info *info)
{
	return container_of(info, struct CounterAccelerator_test, info);
}

static inline size_t CounterAccelerator_size()
{
	return 4096;
}

static void CounterAccelerator_alloc_buf(struct test_info *info)
{
}

static void CounterAccelerator_alloc_contig(struct test_info *info)
{
	if (contig_alloc(CounterAccelerator_size(), &info->contig) == NULL)
		die_errno(__func__);

}

static void CounterAccelerator_init_bufs(struct test_info *info)
{
}

static void CounterAccelerator_set_access(struct test_info *info)
{
	struct CounterAccelerator_test *t = to_CounterAccelerator(info);

	t->desc.ticks = t->ticks;
}

static bool CounterAccelerator_diff_ok(struct test_info *info)
{
	return true;
}

static struct CounterAccelerator_test CounterAccelerator_test = {
	.info = {
		.name		= NAME,
		.devname	= DEVNAME,
		.alloc_buf	= CounterAccelerator_alloc_buf,
		.alloc_contig	= CounterAccelerator_alloc_contig,
		.init_bufs	= CounterAccelerator_init_bufs,
		.set_access	= CounterAccelerator_set_access,
		.diff_ok	= CounterAccelerator_diff_ok,
		.esp		= &CounterAccelerator_test.desc.esp,
		.cm		= COUNTERACCELERATOR_IOC_ACCESS,
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

	CounterAccelerator_test.ticks = strtoul(argv[1], NULL, 0);
	printf(" ** Chisel3 Counter Device Test - %d ticks **\n", CounterAccelerator_test.ticks);

	/*
	 * Set coherence to full because memory is not accessed
	 * Run hw-only test because no software comparison is required.
	 */
	return test_main(&CounterAccelerator_test.info, "full", "hw");
}


