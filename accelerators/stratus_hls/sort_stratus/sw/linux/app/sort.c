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
#include <sort_stratus.h>

#define DEVNAME "/dev/sort_stratus.0"
#define NAME "sort_stratus"

static const char usage_str[] = "usage: sort coherence cmd [n_elems] [n_batches] [-v]\n"
	"  coherence: none|llc-coh-dma|coh-dma|coh\n"
	"  cmd: config|test|run|hw|flush\n"
	"\n"
	"Optional arguments: n_elems and batch apply to 'config', 'hw' and 'test':\n"
	"  n_elems: number of elements per batch to be sorted\n"
	"  n_batches: number of batches\n"
	"\n"
	"The remaining option is only optional for 'test':\n"
	"  -v: enable verbose output for output-to-gold comparison\n";

struct sort_test {
	struct test_info info;
	struct sort_stratus_access desc;
	float *hbuf;
	float *sbuf;
	unsigned int n_elems;
	unsigned int n_batches;
	bool verbose;
};

static inline struct sort_test *to_sort(struct test_info *info)
{
	return container_of(info, struct sort_test, info);
}

static void insertion_sort(float *value, int len)
{
	int i;

	for (i = 1; i < len; i++) {
		double current;
		int empty;

		current = value[i];
		empty = i;

		while (empty > 0 && current < value[empty-1]) {
			value[empty] = value[empty-1];
			empty--;
		}

		value[empty] = current;
	}
}

static int partition(float * array, int low, int high)
{
	int left, right, mid;
	int pivot;
	float cur;

	mid = (low + high) / 2;
	left = low;
	right = high;

	/* choose pivot as median of 3: low, high, and mid */
	if ((array[low] - array[mid]) * (array[high] - array[low]) >= 0)
		pivot = low;
	else if ((array[mid] - array[low]) * (array[high] - array[mid]) >= 0)
		pivot = mid;
	else
		pivot = high;

	/* store value,index at the pivot */
	cur = array[pivot];

	/* swap pivot with the first entry in the list */
	array[pivot] = array[low];
	array[low] = cur;

	/* the quicksort itself */
	while (left < right)
	{
		while (array[left] <= cur && left < high)
			left++;
		while (array[right] > cur)
			right--;
		if (left < right)
		{
			float tmp_val;

			tmp_val = array[right];
			array[right] = array[left];
			array[left] = tmp_val;

		}
	}

	/* pivot was in low, but now moves into position at right */
	array[low] = array[right];
	array[right] = cur;

	return right;
}


/* This defines the length at which we switch to insertion sort */
#define MAX_THRESH 10

int quicksort_inner(float *array, int low, int high)
{
	int pivot;
	int length = high - low + 1;

	if (high > low) {
		if (length > MAX_THRESH) {
			pivot = partition (array, low, high);
			quicksort_inner (array, low, pivot-1);
			quicksort_inner (array, pivot+1, high);
		}
	}

	return 0;
}

int quicksort(float *array, int len)
{
	quicksort_inner(array, 0, len-1);
	insertion_sort(array, len);
	return 0;
}

static int check_gold (float *gold, float *array, int len, bool verbose)
{
	int i;
	int rtn = 0;
	for (i = 0; i < len; i++) {
		if (array[i] != gold[i]) {
			if (verbose)
				printf("A[%d]: array=%.15g; gold=%.15g\n", i, array[i], gold[i]);
			rtn++;
		}
	}
	return rtn;
}

static void init_buf (float *buf, unsigned sort_size, unsigned sort_batch)
{
	int i, j;
	printf("Generate random input...\n");
	srand(time(NULL));
	for (j = 0; j < sort_batch; j++)
		for (i = 0; i < sort_size; i++) {
			/* TAV rand between 0 and 1 */
			buf[sort_size * j + i] = ((float) rand () / (float) RAND_MAX);
			/* /\* More general testbench *\/ */
			/* float M = 100000.0; */
			/* buf[sort_size * j + i] =  M * ((float) rand() / (float) RAND_MAX) - M/2; */
			/* /\* Easyto debug...! *\/ */
			/* buf[sort_size * j + i] = (float) (sort_size - i);; */
		}
}

static inline size_t sort_size(struct sort_test *t)
{
	return t->n_elems * t->n_batches * sizeof(float);
}

static void sort_alloc_buf(struct test_info *info)
{
	struct sort_test *t = to_sort(info);

	t->hbuf = malloc0_check(sort_size(t));
	if (!strcmp(info->cmd, "test"))
		t->sbuf = malloc0_check(sort_size(t));
}

static void sort_alloc_contig(struct test_info *info)
{
	struct sort_test *t = to_sort(info);

	printf("HW buf size: %zu\n", sort_size(t));
	if (contig_alloc(sort_size(t), &info->contig) == NULL)
		die_errno(__func__);
}

static void sort_init_bufs(struct test_info *info)
{
	struct sort_test *t = to_sort(info);

	init_buf(t->hbuf, t->n_elems, t->n_batches);
	contig_copy_to(info->contig, 0, t->hbuf, sort_size(t));
	if (!strcmp(info->cmd, "test"))
		memcpy(t->sbuf, t->hbuf, sort_size(t));
}

static void sort_set_access(struct test_info *info)
{
	struct sort_test *t = to_sort(info);

	t->desc.size = t->n_elems;
	t->desc.batch = t->n_batches;
}

static void sort_comp(struct test_info *info)
{
	struct sort_test *t = to_sort(info);
	int i;

	for (i = 0; i < t->n_batches; i++)
		quicksort(&t->sbuf[i * t->n_elems], t->n_elems);
}

static bool sort_diff_ok(struct test_info *info)
{
	struct sort_test *t = to_sort(info);
	int total_err = 0;
	int i;

	contig_copy_from(t->hbuf, info->contig, 0, sort_size(t));
	for (i = 0; i < t->n_batches; i++) {
		int err;

		err = check_gold(t->sbuf, t->hbuf, t->n_elems, t->verbose);
		if (err)
			printf("Batch %d: %d mismatches\n", i, err);
		total_err += err;
	}
	if (t->verbose) {
		for (i = 0; i < t->n_batches; i++) {
			int j;

			printf("BATCH %d\n", i);
			for (j = 0; j < t->n_elems; j++) {
				printf("      \t%d : %.15g\n",
					i, t->hbuf[t->n_elems * i + j]);
			}
			printf("\n");
		}
	}
	if (total_err)
		printf("%d mismatches in total\n", total_err);
	return !total_err;
}

static struct sort_test sort_test = {
	.info = {
		.name		= NAME,
		.devname	= DEVNAME,
		.alloc_buf	= sort_alloc_buf,
		.alloc_contig	= sort_alloc_contig,
		.init_bufs	= sort_init_bufs,
		.set_access	= sort_set_access,
		.comp		= sort_comp,
		.diff_ok	= sort_diff_ok,
		.esp		= &sort_test.desc.esp,
		.cm		= SORT_STRATUS_IOC_ACCESS,
	},
};

static void NORETURN usage(void)
{
	fprintf(stderr, "%s", usage_str);
	exit(1);
}

int main(int argc, char *argv[])
{
	int n_argc;

	if (argc < 3)
		usage();

	if (!strcmp(argv[2], "run") || !strcmp(argv[2], "flush"))
		n_argc = 3;
	else
		n_argc = 5;

	if (argc < n_argc)
		usage();

	if (n_argc > 3) {
		sort_test.n_elems = strtoul(argv[3], NULL, 0);
		sort_test.n_batches = strtoul(argv[4], NULL, 0);
		if (argc == 6) {
			if (strcmp(argv[5], "-v"))
				usage();
			sort_test.verbose = true;
		}
	}
	return test_main(&sort_test.info, argv[1], argv[2]);
}


