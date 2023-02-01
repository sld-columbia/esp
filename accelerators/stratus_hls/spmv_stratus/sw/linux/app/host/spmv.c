// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include "spmv.h"

void spmv(struct bench_args_t *data)
{
    long i, j;
    TYPE sum, Si;

    for(i = 0; i < data->nrows; i++) {

        sum = 0; Si = 0;

        int tmp_begin = data->rowDelimiters[i];

        int tmp_end = data->rowDelimiters[i + 1];

        for (j = tmp_begin; j < tmp_end; j++) {

            Si = data->val[j] * data->vec[data->cols[j]];
            sum = sum + Si;
        }

        data->out[i] = sum;
    }
}
