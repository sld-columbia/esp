#include "token_pm_4x4_Ccommon.h"
//#define total_tokens 50
#define total_tokens 100
const unsigned total_tokens_ini = total_tokens; //Change to 24 for original test
//#define N_ACC 6 //Already define in main .h
#define LUT_SIZE 64

#define P_TOTAL 450
//#define P_TOTAL 900
#define max_power_GEMM 113
#define max_power_CONV 145
#define max_power_NV 72
//TODO to add values
#define min_power_GEMM 9
#define min_power_CONV 9
#define min_power_NV 9

#define max_tokens_GEMM 13
#define max_tokens_NV 8
#define max_tokens_CONV2D 9

const unsigned max_tokens[N_ACC] = {max_tokens_GEMM, max_tokens_GEMM, max_tokens_GEMM, max_tokens_GEMM, max_tokens_NV, max_tokens_NV, max_tokens_NV, max_tokens_NV, max_tokens_CONV2D, max_tokens_CONV2D, max_tokens_CONV2D, max_tokens_NV, max_tokens_NV};

	const unsigned lut_data_const_GEMM[LUT_SIZE] ={ 255,  239,  215,  191,  163,  136,  115,   97,   88,   79,   70,   60,
   51,   46,   46,   46,   46,   46,   46,   46,   46,   46,   46,   46,
   46,   46,   46,   46,   46,   46,   46,   46,   46,   46,   46,   46,
   46,   46,   46,   46,   46,   46,   46,   46,   46,   46,   46,   46,
   46,   46,   46,   46,   46,   46,   46,   46,   46,   46,   46,   46,
   46,   46,   46,   46};
								
	const unsigned lut_data_const_CONV2D[LUT_SIZE] = { 255,  242,  221,  200,  179,  153,  128,  111,   94,   81,   73,   65,
   57,   48,   40,   32,   24,   24,   24,   24,   24,   24,   24,   24,
   24,   24,   24,   24,   24,   24,   24,   24,   24,   24,   24,   24,
   24,   24,   24,   24,   24,   24,   24,   24,   24,   24,   24,   24,
   24,   24,   24,   24,   24,   24,   24,   24,   24,   24,   24,   24,
   24,   24,   24,   24};

	const unsigned lut_data_const_NV[LUT_SIZE] = { 255,  221,  179,  132,  103,   86,   75,   63,   52,   52,   52,   52,
   52,   52,   52,   52,   52,   52,   52,   52,   52,   52,   52,   52,
   52,   52,   52,   52,   52,   52,   52,   52,   52,   52,   52,   52,
   52,   52,   52,   52,   52,   52,   52,   52,   52,   52,   52,   52,
   52,   52,   52,   52,   52,   52,   52,   52,   52,   52,   52,   52,
   52,   52,   52,   52};

const unsigned *LUT_DATA[N_ACC] = {lut_data_const_GEMM, lut_data_const_GEMM, lut_data_const_GEMM, lut_data_const_GEMM, lut_data_const_NV, lut_data_const_NV, lut_data_const_NV, lut_data_const_NV, lut_data_const_CONV2D, lut_data_const_CONV2D, lut_data_const_CONV2D, lut_data_const_NV, lut_data_const_NV}; 
