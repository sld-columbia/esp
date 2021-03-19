// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <assert.h>

/* #if defined(USE_CBLAS) */
/* #include "cblas.h" */
/* #endif // USE_CBLAS */

#include "gemm_pvt.h"
// #include "gemm_pvt.hpp"

void _gemm_pv(double *mtx_inA, double *mtx_inB, double *mtx_out,
	      size_t is_trans, size_t rowsA, size_t colsA, size_t colsB)
{
    unsigned d1, d2, d3, mtx_inA_i, mtx_inB_i;
    double accumulator;
    // double accumulator;
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
    size_t out_sizes[3] = {batch_size, rowsA, colsB};

    assert(mtx_inA->dim == 3);
    assert(mtx_inB->dim == 3);
    assert(mtx_inA->dims[0] == mtx_inB->dims[0]);
    assert(mtx_inA->dims[2] == mtx_inB->dims[1]);

    create_double_matrix_t(mtx_out, out_sizes, 3);

    for (i = 0; i < batch_size; ++i) {
        _gemm_pv(&(mtx_inA->data[i * size_inA]),
	         &(mtx_inB->data[i * size_inB]),
	         &((*mtx_out)->data[i * size_out]),
	         mtx_inB->is_transposed,
	         rowsA, colsA, colsB);
    }
}


void gemm_pvt(int l_n,float* layer_node,float* layer_bias,bool relu,float*w,int wr,int wc,int ws,float* out)
{
	
	size_t sizeA[3]={(size_t)1,(size_t)wr,(size_t)wc};
	size_t sizeB[3]={(size_t)1,(size_t)wc,(size_t)1};

	double* in1=new double[ws];
	double* in2=new double[ws];

	double_matrix_t * matrixA;
	double_matrix_t * matrixB;
	double_matrix_t * matrixC;
	
	double rel_error=0;
	int tot_errors1=0;
	
	create_double_matrix_t(&matrixA, sizeA, 3);
	create_double_matrix_t(&matrixB, sizeB, 3);


	for( int i = 0; i <ws; i = i + 1 ) {
		in1[i]=(double)w[i];}

	
	for( int i = 0; i <wc; i = i + 1 ) {
		in2[i]=(double)layer_node[i];}


	matrixA->data=in1;
	matrixB->data=in2;
	matrixB->is_transposed=1;
	gemm_pv(matrixA, matrixB, &matrixC);

	for( int i = 0; i < wr; i = i + 1 ) {
		out[i]=(float)matrixC->data[i];
	}

	for (int i = 0; i < wr; i++) {
		if (relu) {
			if (out[i] + layer_bias[i] < 0)
				out[i] = 0;
			else
				out[i] += layer_bias[i];
		}
	}
	// Softmax for layer without relu
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
//			printf("%f ",out[i]);
		}
	}

	// printf("Layer %d validation \n",l_n);
	// for (int i=0;i<wr;i++)
	// {
	// 	if (check_error_threshold((double)out[i],(double)gold[i], rel_error)){
	// 		tot_errors1++;
	// 		std::cout<<"Mismatch "<<tot_errors1<<" (index "<<i<<"): ref|gemm_pv     "<<
	// 			gold[i]<<"|"<<out[i]<<std::endl;
	// 	}
	// }

	// if (tot_errors1>0)
	// 	std::cout<<"Total amount of mismatches :"<<tot_errors1<<std::endl;
	// else
	// 	std::cout<<"Validated"<<std::endl;


	

}
