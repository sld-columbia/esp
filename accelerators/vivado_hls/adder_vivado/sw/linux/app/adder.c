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
#include <adder_vivado.h>

#define DEVNAME "/dev/adder_vivado.0"
#define NAME "adder_vivado"

// Default command line arguments
#define DEFAULT_NBURSTS 4
// TODO pass as command line argument and use it
#define DEFAULT_NINVOKE 4


/////////////////////////////////
// TODO include accelerators configuration header
//      instead of copying its content here
// #include "espacc_config.h"
#define IS_TYPE_FIXED_POINT 0
#define FRAC_BITS 0
#define IS_TYPE_UINT 0
#define IS_TYPE_INT 1
// In/out arrays
#define SIZE_IN_CHUNK_DATA 64
#define SIZE_OUT_CHUNK_DATA 32
/////////////////////////////////

/////////////////////////////////
// TODO read HLS config directly from the accelerator registers
//      instead of setting it here
#ifndef __riscv
#define DMA_SIZE  32
#else
#define DMA_SIZE  64
#endif

#define DATA_BITWIDTH 32
/////////////////////////////////

// Define datatype
// TODO this app currently doesn't support fixed point
#if (DATA_BITWIDTH == 8)
#if (IS_TYPE_UINT == 1)
typedef uint8_t word_t;
#elif (IS_TYPE_INT == 1)
typedef int8_t word_t;
#else
// fixed point not supported right now
#endif

#elif (DATA_BITWIDTH == 16)
#if (IS_TYPE_UINT == 1)
typedef uint16_t word_t;
#elif (IS_TYPE_INT == 1)
typedef int16_t word_t;
#else
// fixed point not supported right now
#endif

#elif (DATA_BITWIDTH == 32)
#if (IS_TYPE_UINT == 1)
typedef uint32_t word_t;
#elif (IS_TYPE_INT == 1)
typedef int32_t word_t;
#else
// fixed point not supported right now
#endif

#else
// other bitwidths not supported right now
#endif


static const char usage_str[] =
	"usage: ./adder_vivado.exe coherence [size] [-v]\n"
	"  coherence: non-coh-dma|llc-coh-dma|coh-dma|coh\n"
	"\n"
	"Optional arguments:.\n"
	"  nbursts : # of memory bursts for 1 invocation of the accelerator. Default: 4\n"
	"\n"
	"The remaining option is only optional for 'test':\n"
        "  -v: enable verbose output for output-to-gold comparison\n";

struct adder_test {
	struct test_info info;
	struct adder_vivado_access desc;
	unsigned int nbursts;
        word_t *hbuf;
	word_t *sbuf;
	bool verbose;
};

static inline struct adder_test *to_adder(struct test_info *info)
{
	return container_of(info, struct adder_test, info);
}

static int check_gold (word_t *gold, word_t *array, unsigned len, bool verbose)
{
	int i;
	int rtn = 0;
	for (i = 0; i < len; i++) {
		if ((array[i]) != gold[i]) {
			if (verbose)
				printf("A[%d]: array=%d; gold=%d\n",
				       i, array[i], gold[i]);
			rtn++;
		}
	}

	return rtn;
}

static void init_buf (struct adder_test *t)
{
        //  ========================  ^
        //  |  in                  |  | input (in bytes)
        //  ========================  v
        //  |  out                 |  | output (in bytes)
        //  ========================  v

        printf("init buffers\n");

        int i = 0;

	const unsigned IN_SIZE_DATA = (SIZE_IN_CHUNK_DATA * t->nbursts);
        const unsigned OUT_SIZE_DATA = (SIZE_OUT_CHUNK_DATA * t->nbursts);
        const unsigned SIZE_DATA = (IN_SIZE_DATA + OUT_SIZE_DATA);

        // Initialize input and output
	for (i = 0; i < IN_SIZE_DATA; i++) {
	    t->hbuf[i] = i;
	    t->sbuf[i] = i;
	}
	for (; i < SIZE_DATA; i++) {
	    t->hbuf[i] = 10;
	    t->sbuf[i] = 10;
	}
}

static inline size_t adder_size(struct adder_test *t)
{
	const unsigned IN_SIZE_DATA = (SIZE_IN_CHUNK_DATA * t->nbursts);
        const unsigned OUT_SIZE_DATA = (SIZE_OUT_CHUNK_DATA * t->nbursts);
	const unsigned IN_SIZE = (IN_SIZE_DATA * sizeof(word_t));
        const unsigned OUT_SIZE = (OUT_SIZE_DATA * sizeof(word_t));
        const unsigned SIZE = (IN_SIZE + OUT_SIZE);

	return SIZE;
}

static void adder_alloc_buf(struct test_info *info)
{
	struct adder_test *t = to_adder(info);

	t->hbuf = malloc0_check(adder_size(t));
	if (!strcmp(info->cmd, "test")) {
		t->sbuf = malloc0_check(adder_size(t));
	}
}

static void adder_alloc_contig(struct test_info *info)
{
	struct adder_test *t = to_adder(info);

	printf("HW buf size: %zu kB\n", adder_size(t) / 1000);
	if (contig_alloc(adder_size(t), &info->contig) == NULL)
		die_errno(__func__);
}

static void adder_init_bufs(struct test_info *info)
{
	struct adder_test *t = to_adder(info);

	init_buf(t);
	contig_copy_to(info->contig, 0, t->hbuf, adder_size(t));
}

static void adder_set_access(struct test_info *info)
{
	struct adder_test *t = to_adder(info);

	t->desc.nbursts = t->nbursts;
}

static void adder_comp(struct test_info *info)
{
	struct adder_test *t = to_adder(info);
	int i;

	const unsigned IN_SIZE_DATA = (SIZE_IN_CHUNK_DATA * t->nbursts);
        const unsigned OUT_SIZE_DATA = (SIZE_OUT_CHUNK_DATA * t->nbursts);

        // Populate memory for gold output
        for (i = 0; i < OUT_SIZE_DATA; ++i) {
                t->sbuf[i + IN_SIZE_DATA] = i * 4 + 1;
        }
}

static bool adder_diff_ok(struct test_info *info)
{
	struct adder_test *t = to_adder(info);
        const unsigned SIZE_DATA = adder_size(t) / (DMA_SIZE / sizeof(word_t));
	int err = 0;

	contig_copy_from(t->hbuf, info->contig, 0, adder_size(t));

	err = check_gold(t->sbuf, t->hbuf, SIZE_DATA, t->verbose);
	if (err)
		printf("Test FAILED: %d mismatches\n", err);
	else
		printf("Test PASSED: %d mismatches\n", err);

	return !err;
}

static struct adder_test adder_test = {
	.info = {
		.name		= NAME,
		.devname	= DEVNAME,
		.alloc_buf	= adder_alloc_buf,
		.alloc_contig	= adder_alloc_contig,
		.init_bufs	= adder_init_bufs,
		.set_access	= adder_set_access,
		.comp		= adder_comp,
		.diff_ok	= adder_diff_ok,
		.esp		= &adder_test.desc.esp,
		.cm		= ADDER_VIVADO_IOC_ACCESS,
	},
};

static void NORETURN usage(void)
{
	fprintf(stderr, "%s", usage_str);
	exit(1);
}

int main(int argc, char *argv[])
{
	if (argc < 2 || argc > 4) {
		usage();

	} else {
		printf("\nCommand line arguments received:\n");
		printf("\tcoherence: %s\n", argv[1]);

		if (argc == 3) {
		    if (strcmp(argv[2], "-v")) {
			adder_test.nbursts = strtol(argv[2], NULL, 10);
			printf("\tnbursts: %u\n", adder_test.nbursts);
		    } else {
			adder_test.nbursts = DEFAULT_NBURSTS;
			adder_test.verbose = true;
			printf("\tverbose enabled\n");
		    }
		} else {
			adder_test.nbursts = DEFAULT_NBURSTS;
		}

		if (argc == 4) {
			if (strcmp(argv[3], "-v")) {
				usage();
			} else {
			        adder_test.nbursts = strtol(argv[2], NULL, 10);
			        printf("\tnbursts: %u\n", adder_test.nbursts);
				adder_test.verbose = true;
				printf("\tverbose enabled\n");
			}
		}
		printf("\n");
	}

	return test_main(&adder_test.info, argv[1], "test");
}
