// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __PVC_DOUBLE_MATRIX_T_H__
#define __PVC_DOUBLE_MATRIX_T_H__

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

typedef struct
{
    double *data;

    size_t *dims;

    size_t dim;

    size_t is_transposed;

} double_matrix_t;

__attribute__((unused))
static void create_double_matrix_t(double_matrix_t
  **matrix, size_t *dims, size_t dim)
{
    unsigned i, size = 1;

    for (i = 0; i < dim; ++i)
        size *= dims[i];

    (*matrix) = (double_matrix_t*)
      malloc(sizeof(double_matrix_t));

    (*matrix)->data = (double*)
       malloc(sizeof(double) * size);

    (*matrix)->dims = (size_t*)
       malloc(sizeof(size_t) * dim);

    (*matrix)->dim = dim;
    for (i = 0; i < dim; ++i)
       (*matrix)->dims[i] = dims[i];
}


__attribute__((unused))
static int store_double_matrix_t(double_matrix_t *matrix, const char *file)
{
    unsigned int i, size = 1;

    FILE *fp = fopen(file, "w");
    FILE *fp_barec = fopen("golden.h", "w");

    if (!fp) { return -1; }

    fprintf(fp, "%zu ", matrix->dim);

    for (i = 0; i < matrix->dim; ++i)
    {
        fprintf(fp, "%zu ", matrix->dims[i]);

        size *= matrix->dims[i];
    }

    fprintf(fp, "\n");

    for (i = 0; i < size; ++i) {
        fprintf(fp, "%lf ", matrix->data[i]);
        fprintf(fp_barec, "golden[%d] = %f;\n", i, matrix->data[i]);
    }

    fprintf(fp, "\n");

    fclose(fp);
    fclose(fp_barec);

    return 0;
}

__attribute__((unused))
static int load_double_matrix_t(double_matrix_t **matrix, const char *file)
{
    unsigned int i, size = 1;

    FILE *fp = fopen(file, "r");

    if (!fp) { return -1; }

    *matrix = (double_matrix_t*)
      malloc(sizeof(double_matrix_t));

    fscanf(fp, "%zu\n", &((*matrix)->dim));

    fscanf(fp, "%zu\n", &((*matrix)->is_transposed));

    (*matrix)->dims = (size_t*) malloc(
      sizeof(size_t) * (*matrix)->dim);

    for (i = 0; i < (*matrix)->dim; ++i)
    {
        fscanf(fp, "%zu\n", &((*matrix)->dims[i]));

        size *= (*matrix)->dims[i];
    }

    (*matrix)->data = (double*)
      malloc(sizeof(double) * size);

    for (i = 0; i < size; ++i)
        fscanf(fp, "%lf", &((*matrix)->data[i]));

    fclose(fp);

    return 0;
}

__attribute__((unused))
static void free_double_matrix_t(double_matrix_t **matrix)
{
    free((*matrix)->data);
    free((*matrix)->dims);
    free(*matrix);
}

#endif // __PVC_DOUBLE_MATRIX_T_H__

