#include "token_pm_4x4_Ccommon.h"
#define total_tokens 50
const unsigned total_tokens_ini = 50; //Change to 24 for original test
//#define N_ACC 6 //Already define in main .h
#define LUT_SIZE 64

#define max_tokens_GEMM 38
#define max_tokens_NV 24
#define max_tokens_CONV2D 48

const unsigned max_tokens[N_ACC] = {max_tokens_GEMM, max_tokens_GEMM, max_tokens_GEMM, max_tokens_GEMM, max_tokens_NV, max_tokens_NV, max_tokens_NV, max_tokens_NV, max_tokens_CONV2D, max_tokens_CONV2D, max_tokens_CONV2D, max_tokens_NV, max_tokens_NV};

	const unsigned lut_data_const_vc707_GEMM[LUT_SIZE] ={ 255,  239,  215,  191,  163,  136,  115,   97,   88,   79,   70,   60,
   51,   46,   46,   46,   46,   46,   46,   46,   46,   46,   46,   46,
   46,   46,   46,   46,   46,   46,   46,   46,   46,   46,   46,   46,
   46,   46,   46,   46,   46,   46,   46,   46,   46,   46,   46,   46,
   46,   46,   46,   46,   46,   46,   46,   46,   46,   46,   46,   46,
   46,   46,   46,   46};
								
	const unsigned lut_data_const_vc707_CONV2D[LUT_SIZE] = { 255,  242,  221,  200,  179,  153,  128,  111,   94,   81,   73,   65,
   57,   48,   40,   32,   24,   24,   24,   24,   24,   24,   24,   24,
   24,   24,   24,   24,   24,   24,   24,   24,   24,   24,   24,   24,
   24,   24,   24,   24,   24,   24,   24,   24,   24,   24,   24,   24,
   24,   24,   24,   24,   24,   24,   24,   24,   24,   24,   24,   24,
   24,   24,   24,   24};

	const unsigned lut_data_const_vc707_NV[LUT_SIZE] = { 255,  221,  179,  132,  103,   86,   75,   63,   52,   52,   52,   52,
   52,   52,   52,   52,   52,   52,   52,   52,   52,   52,   52,   52,
   52,   52,   52,   52,   52,   52,   52,   52,   52,   52,   52,   52,
   52,   52,   52,   52,   52,   52,   52,   52,   52,   52,   52,   52,
   52,   52,   52,   52,   52,   52,   52,   52,   52,   52,   52,   52,
   52,   52,   52,   52};

const unsigned *LUT_DATA[N_ACC] = {lut_data_const_vc707_GEMM, lut_data_const_vc707_GEMM, lut_data_const_vc707_GEMM, lut_data_const_vc707_GEMM, lut_data_const_vc707_NV, lut_data_const_vc707_NV, lut_data_const_vc707_NV, lut_data_const_vc707_NV, lut_data_const_vc707_CONV2D, lut_data_const_vc707_CONV2D, lut_data_const_vc707_CONV2D, lut_data_const_vc707_NV, lut_data_const_vc707_NV}; 
