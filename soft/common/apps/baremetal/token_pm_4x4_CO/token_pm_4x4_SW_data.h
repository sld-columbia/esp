#include "token_pm_4x4_Ccommon.h"
#define total_tokens 150
//#define N_ACC 6 //Already define in main .h
#define LUT_SIZE 64

#define max_tokens_GEMM 38
#define max_tokens_NV 24
#define max_tokens_CONV2D 48

const unsigned max_tokens[N_ACC] = {max_tokens_GEMM, max_tokens_GEMM, max_tokens_GEMM, max_tokens_GEMM, max_tokens_NV, max_tokens_NV, max_tokens_NV, max_tokens_NV, max_tokens_CONV2D, max_tokens_CONV2D, max_tokens_CONV2D, max_tokens_NV, max_tokens_NV};

	const unsigned lut_data_const_vc707_GEMM[LUT_SIZE] = {  11,  11,  11,  11,  11,  10,  10,  10,   9,   9,   9,   8,   8,   7,   7,
					       	        	6,   6,   6,   5,   5,   5,   5,   5,   4,   4,   4,   4,   4,   4,   3,
					  	        	3,   3,   3,   3,   3,   3,   2,   2,   2,   2,   2,   2,   2,   2,   2,
							        2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,
								2,   2,   2,   2};
						
								
	const unsigned lut_data_const_vc707_CONV2D[LUT_SIZE] = {  11,  11,  11,  11,  11,  11,  10,  10,  10,   9,   9,   9,   8,   8,   8,
								7,   7,   6,   6,   6,   6,   5,   5,   5,   5,   4,   4,   4,   4,   4,
								3,   3,   3,   3,   3,   3,   3,   3,   2,   2,   2,   2,   2,   2,   2,
								2,   2,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
								1,   1,   1,   1};

	const unsigned lut_data_const_vc707_NV[LUT_SIZE] = {  11,  11,  11,  10,  10,   9,   8,   8,   7,   6,   6,   5,   5,   5,   4,
								4,   4,   4,   4,   3,   3,   3,   3,   3,   2,   2,   2,   2,   2,   2,
								2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,
								2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,
								2,   2,   2,   2};

const unsigned *LUT_DATA[N_ACC] = {lut_data_const_vc707_GEMM, lut_data_const_vc707_GEMM, lut_data_const_vc707_GEMM, lut_data_const_vc707_GEMM, lut_data_const_vc707_NV, lut_data_const_vc707_NV, lut_data_const_vc707_NV, lut_data_const_vc707_NV, lut_data_const_vc707_CONV2D, lut_data_const_vc707_CONV2D, lut_data_const_vc707_CONV2D, lut_data_const_vc707_NV, lut_data_const_vc707_NV}; 
