// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <assert.h>

#define WRITE_OUTPUT
#define CHECK_OUTPUT

#include "support.h"

int main(int argc, char **argv)
{
    char *p = NULL;
    char in_file[25];
    char chk_file[25];
    char out_file[25];
    int errno = 0, ret = 0;
    struct bench_args_t data;

    /* Parse command line. */

    assert((argc == 5) && "Wrong command line arguments" );

    ret = sprintf(in_file, "inputs/in%s.data", argv[1]);
    assert((ret >= 0) && "Error sprintf");

    ret = sprintf(chk_file, "outputs/chk%s.data", argv[1]);
    assert((ret >= 0) && "Error sprintf");

    ret = sprintf(out_file, "outputs/out%s.data", argv[1]);
    assert((ret >= 0) && "Error sprintf");

    data.mtx_len = strtol(argv[2], &p, 10);
    assert((*p == '\0' && errno == 0) && "Error strtol");

    data.nrows = strtol(argv[3], &p, 10);
    assert((*p == '\0' && errno == 0) && "Error strtol");

    data.ncols = strtol(argv[4], &p, 10);
    assert((*p == '\0' && errno == 0) && "Error strtol");

    /* Allocate memory for input - output data */

    data.val = malloc(sizeof(TYPE) * data.mtx_len);
    assert(data.val != NULL && "Out of memory");
    memset((void *) data.val, 0, sizeof(TYPE) * data.mtx_len);

    data.cols = malloc(sizeof(int) * data.mtx_len);
    assert(data.cols != NULL && "Out of memory");
    memset((void *) data.cols, 0, sizeof(int) * data.mtx_len);

    data.rowDelimiters = malloc(sizeof(int) * (data.nrows + 1));
    assert(data.rowDelimiters != NULL && "Out of memory");
    memset((void *) data.rowDelimiters, 0, sizeof(int) * data.nrows);

    data.vec = malloc(sizeof(TYPE) * data.ncols);
    assert(data.vec != NULL && "Out of memory");
    memset((void *) data.vec, 0, sizeof(TYPE) * data.ncols);

    data.out = malloc(sizeof(TYPE) * data.nrows);
    assert(data.out != NULL && "Out of memory");
    memset((void *) data.out, 0, sizeof(TYPE) * data.nrows);

    data.chk = malloc(sizeof(TYPE) * data.nrows);
    assert(data.chk != NULL && "Out of memory");
    memset((void *) data.chk, 0, sizeof(TYPE) * data.nrows);

    /* Load input data */

    int in_fd = open(in_file, O_RDONLY);
    assert(in_fd > 0 && "Couldn't open input data file");

    input_to_data(in_fd, &data);

    close(in_fd);

    /* Run benchmark */

    run_benchmark(&data);

    /* Write output */

#ifdef WRITE_OUTPUT
    int out_fd;
    out_fd = open(out_file, O_WRONLY|O_CREAT|O_TRUNC, S_IRUSR|S_IWUSR|S_IRGRP|S_IWGRP|S_IROTH|S_IWOTH);
    assert(out_fd > 0 && "Couldn't open output data file" );
    data_to_output(out_fd, &data);
    close(out_fd);
#endif

    /* Load check data */

#ifdef CHECK_OUTPUT
    int check_fd;
    
    check_fd = open(chk_file, O_RDONLY);
    assert(check_fd > 0 && "Couldn't open check data file");
    output_to_data(check_fd, &data);
    close(check_fd);
#endif
    
    /* Validate results */

#ifdef CHECK_OUTPUT
    if(!check_data(&data) ) {
	fprintf(stderr, "Benchmark results are incorrect\n");
	return -1;
    }
#endif
    
    free(data.val);
    free(data.cols);
    free(data.rowDelimiters);
    free(data.vec);
    free(data.out);
    free(data.chk);
    
    printf("Success.\n");

    return 0;
}
