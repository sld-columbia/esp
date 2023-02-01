// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include "spmv.h"
#include <string.h>

/* int INPUT_SIZE = sizeof(struct bench_args_t); */

#define EPSILON 1.0e-6

void run_benchmark(struct bench_args_t *data) {
    spmv(data);
}

/* Input format:
%% Section 1
TYPE[NNZ]: the nonzeros of the matrix
%% Section 2
int32_t[NNZ]: the column index of the nonzeros
%% Section 3
int32_t[N+1]: the start of each row of nonzeros
%% Section 4
TYPE[N]: the dense vector
*/

void input_to_data(int fd, struct bench_args_t *data) {

  char *p, *s;

  // Load input string
  p = readfile(fd);

  s = find_section_start(p, 1);
  STAC(parse_,TYPE,_array)(s, data->val, data->mtx_len);

  s = find_section_start(p,2);
  parse_int32_t_array(s, data->cols, data->mtx_len);

  s = find_section_start(p,3);
  parse_int32_t_array(s, data->rowDelimiters, data->nrows + 1);

  s = find_section_start(p,4);
  STAC(parse_,TYPE,_array)(s, data->vec, data->ncols);

  free(p);
}

/* Output format:
%% Section 1
TYPE[N]: The output vector
*/

void output_to_data(int fd, struct bench_args_t *data)
{
  char *p, *s;

  // Load input string
  p = readfile(fd);

  s = find_section_start(p,1);
  STAC(parse_,TYPE,_array)(s, data->chk, data->nrows);
  free(p);
}

void data_to_output(int fd, struct bench_args_t *data)
{
  write_section_header(fd);
  STAC(write_,TYPE,_array)(fd, data->out, data->nrows);
}

int check_data(struct bench_args_t *data)
{
  int has_errors = 0;
  int i;
  TYPE diff;

  for(i = 0; i < data->nrows; i++) {

    diff = data->out[i] - data->chk[i];

    has_errors |= (diff<-EPSILON) || (EPSILON<diff);
  }

  // Return true if it's correct.
  return !has_errors;
}
