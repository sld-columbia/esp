// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include <assert.h>

#if defined(USE_CBLAS)
#include "cblas.h"
#endif // USE_CBLAS

#include "gemm_pv.h"

void _gemm_pv(double *mtx_inA, double *mtx_inB, double *mtx_out,
	      size_t is_trans, size_t rowsA, size_t colsA, size_t colsB)
{

#if defined(USE_CBLAS)

    if (is_trans) {

	// Perform the following operation: C := alpha * A *  B^T + beta * C
	cblas_dgemm(CblasRowMajor,        // row-major order representation
		    CblasNoTrans,         // matrix_in1 no transposed
		    CblasTrans,           // matrix_in2 is transposed
		    rowsA,                // mtx_in1 rows
		    colsA,                // mtx_in1 cols
		    colsB,                // mtx_in2 cols
		    (double) 1.0,         // alpha coeff -> 1.0
		    mtx_inA,              // mtx_in1 val
		    colsA,                // matrix_in1 ld
		    mtx_inB,              // mtx_in2 val
		    colsA,                // matrix_in2 ld
		    (double) 0.0,         // beta coeff -> 0.0
		    mtx_out,              // mtx_out val
		    colsB);                // mtx_out ld
    } else {

	// Perform the following operation: C := alpha * A *  B^T + beta * C
	cblas_dgemm(CblasRowMajor,        // row-major order representation
		    CblasNoTrans,         // matrix_in1 no transposed
		    CblasNoTrans,         // matrix_in2 is transposed
		    rowsA,                // mtx_in1 rows
		    colsA,                // mtx_in1 cols
		    colsB,                // mtx_in2 cols
		    (double) 1.0,         // alpha coeff -> 1.0
		    mtx_inA,              // mtx_in1 val
		    colsA,                // matrix_in1 ld
		    mtx_inB,              // mtx_in2 val
		    colsA,                // matrix_in2 ld
		    (double) 0.0,         // beta coeff -> 0.0
		    mtx_out,              // mtx_out val
		    colsB);                // mtx_out ld
    }

#else //  Inefficient implementation

    unsigned d1, d2, d3, mtx_inA_i, mtx_inB_i;
    double accumulator;

	for (d1 = 0; d1 < rowsA; ++d1)
	{
	    for (d2 = 0; d2 < colsB; ++d2)
	    {
		accumulator = 0.0;

		for (d3 = 0; d3 < colsA; ++d3)
		{
		    mtx_inA_i = d1 * colsA + d3;
		    mtx_inB_i = is_trans ? (d2 * colsA + d3) : (d3 * colsB + d2);

		    accumulator += mtx_inA[mtx_inA_i] * mtx_inB[mtx_inB_i];
		}

		mtx_out[d1 * colsB + d2] = accumulator;
	    }
	}
#endif
}

void gemm_pv(double_matrix_t *mtx_inA, double_matrix_t *mtx_inB, double_matrix_t **mtx_out)
{
    int i;
    unsigned batch_size = mtx_inA->dims[0];
    unsigned rowsA = mtx_inA->dims[1];
    unsigned colsA = mtx_inA->dims[2];
    unsigned colsB = mtx_inB->dims[2];
    unsigned size_inA = rowsA * colsA;
    unsigned size_inB = colsA * colsB;
    unsigned size_out = rowsA * colsB;
    size_t out_sizes[M_DIMS] = {batch_size, rowsA, colsB};

    assert(mtx_inA->dim == M_DIMS);
    assert(mtx_inB->dim == M_DIMS);
    assert(mtx_inA->dims[0] == mtx_inB->dims[0]);
    assert(mtx_inA->dims[2] == mtx_inB->dims[1]);

    create_double_matrix_t(mtx_out, out_sizes, M_DIMS);

    for (i = 0; i < batch_size; ++i) {
    
        _gemm_pv(&(mtx_inA->data[i * size_inA]),
	         &(mtx_inB->data[i * size_inB]),
	         &((*mtx_out)->data[i * size_out]),
	         mtx_inB->is_transposed,
	         rowsA, colsA, colsB);
    }
}
