// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include <stdio.h>
#include <stdlib.h>

#include <assert.h>
#include <iostream>
#include <fstream>
#include <math.h>
#if defined(USE_CBLAS)
#include "cblas.h"
#endif // USE_CBLAS
// #include "validation.hpp"
#include "double_matrix_t.h"
#define M_DIMS 3
void _gemm_pv(double *mtx_inA, double *mtx_inB, double *mtx_out,
	      size_t is_trans, size_t rowsA, size_t colsA, size_t colsB)
// void _gemm_pv(float *mtx_inA, float *mtx_inB, float *mtx_out,
// 	      size_t is_trans, size_t rowsA, size_t colsA, size_t colsB)
{

#if defined(USE_CBLAS)
	std::cout<<"CBLAS"<<std::endl;
    if (is_trans) {
	    std::cout<<"is _trans"<<std::endl;
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
	    std::cout<<"not_trans"<<std:endl;
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
    // double accumulator;
    for (d1 = 0; d1 < rowsA; ++d1)
	{
		/* std::cout<<"rowa_no : "<<d1<<std::endl; */
	    for (d2 = 0; d2 < colsB; ++d2)
	    {
		accumulator = 0.0;

		for (d3 = 0; d3 < colsA; ++d3)
		{
		    mtx_inA_i = d1 * colsA + d3;
		    mtx_inB_i = is_trans ? (d2 * colsA + d3) : (d3 * colsB + d2);    
		    /* std::cout<<"indx_a,indx_b,val_a,val_b = " <<mtx_inA_i<<" "<<mtx_inB_i<<" "<<mtx_inA[mtx_inA_i]<<" "<<mtx_inB[mtx_inB_i]<<" "; */
		    accumulator += mtx_inA[mtx_inA_i] * mtx_inB[mtx_inB_i]; 
		}

		mtx_out[d1 * colsB + d2] = accumulator;
		/* std::cout<<std::endl; */
	    }
	}
#endif
}

void gemm_pv(double_matrix_t *mtx_inA, double_matrix_t *mtx_inB, double_matrix_t **mtx_out)
{
    unsigned i;
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

void gemm_pvt(int l_n,int prev_soft,float*layer_in_sw,float* layer_in_hw,float*out,float* W,float*bias, bool relu,int wr,int wc,int ws)
{
	
	//input typcast into new data-structures expected from gemm pv

	size_t sizeA[3]={(size_t)1,(size_t)wr,(size_t)wc};
	size_t sizeB[3]={(size_t)1,(size_t)wc,(size_t)1};

	double* w=new double[ws];
	double* in_hw=new double[ws];
	double* in_sw=new double[ws];

	double_matrix_t * matrixA;
	double_matrix_t * matrixB;
	double_matrix_t * matrixC;
	
	create_double_matrix_t(&matrixA, sizeA, 3);
	create_double_matrix_t(&matrixB, sizeB, 3);


	for( int i = 0; i <ws; i = i + 1 ) {
		w[i]=(double)W[i];}

	
	for( int i = 0; i <wc; i = i + 1 ) {
		in_hw[i]=(double)layer_in_hw[i];
	        in_sw[i]=(double)layer_in_sw[i];}

	matrixA->data=w;
	matrixB->is_transposed=1;

        //select input between: reshaped input from dwarf model (in_sw) and outputs of previous layer executed by the accelerator's programmer's view (in_hw)
	
	if (prev_soft==1)
		matrixB->data=in_sw;
	else
		matrixB->data=in_hw;

	//Call to GeMM programmer's view 

	gemm_pv(matrixA, matrixB, &matrixC);

	//output processing with features not yet supported by GeMM
	//type-cast
	for( int i= 0; i < wr; i = i + 1 ) {
		out[i]=(float)matrixC->data[i];
	}
	//relu
	for (int i = 0; i < wr; i++) {
		if (relu) {
			if (out[i] + bias[i] < 0)
				out[i] = 0;
			else
				out[i] += bias[i];
		}
	}
	// softmax for layer without relu
	if (!relu)
	{
		for (int i = 0; i < wr; i++) {
			float max = out[0];
			for (int j = 1; j < wr; j++)
				if (out[j] > max)
					max = out[j];

			float denom = 0;
			for (int j = 0; j <wr; j++)
				denom += exp(out[j] - max);

			out[i] = exp(out[i] - max) / denom;
		}
	}


}

