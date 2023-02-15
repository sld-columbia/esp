// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
/*
Based on algorithm described here:
http://www.cs.berkeley.edu/~mhoemmen/matrix-seminar/slides/UCB_sparse_tutorial_1.pdf
*/

#include <stdlib.h>
#include <stdio.h>
#include "support.h"

/* void spmv(TYPE val[NNZ], int32_t cols[NNZ], int32_t rowDelimiters[N + 1], */
/*           TYPE vec[N], TYPE out[N]); */
void spmv(struct bench_args_t *data);

