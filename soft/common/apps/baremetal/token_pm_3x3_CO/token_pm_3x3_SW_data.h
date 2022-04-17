#include "token_pm_3x3_Ccommon.h"
#define total_tokens 24
//#define N_ACC 6 //Already define in main .h
#define LUT_SIZE 64

#define max_tokens_FFT 4
#define max_tokens_VIT 11
#define max_tokens_NVDLA 24

const unsigned max_tokens[N_ACC] = {max_tokens_NVDLA, max_tokens_FFT, max_tokens_VIT, max_tokens_FFT, max_tokens_VIT, max_tokens_FFT};

 	const unsigned lut_data_const_FFT[LUT_SIZE] = {0xB,7, 4, 2, 1, 0, 0, 0,
						 0, 0, 0, 0, 0, 0, 0, 0,
						 0, 0, 0, 0, 0, 0, 0, 0,
						 0, 0, 0, 0, 0, 0, 0, 0,
						 0, 0, 0, 0, 0, 0, 0, 0,
						 0, 0, 0, 0, 0, 0, 0, 0,
						 0, 0, 0, 0, 0, 0, 0, 0,
						 0, 0, 0, 0, 0, 0, 0, 0};
						 
	const unsigned lut_data_const_VIT[LUT_SIZE] = {0xB, 0xA, 9, 8, 7, 6, 6, 5,
						 4, 4, 3, 3, 2, 2, 2, 2,
						 0, 0, 0, 0, 0, 0, 0, 0,
						 0, 0, 0, 0, 0, 0, 0, 0,
						 0, 0, 0, 0, 0, 0, 0, 0,
						 0, 0, 0, 0, 0, 0, 0, 0,
						 0, 0, 0, 0, 0, 0, 0, 0,
						 0, 0, 0, 0, 0, 0, 0, 0};							
						 
	const unsigned lut_data_const_NVDLA[LUT_SIZE] = {0xB, 0xB, 0xB, 0xB, 0xA, 0xA, 9, 9,
						 8, 8, 8, 8, 7, 7, 6, 6,
						 5, 5, 5, 5, 4, 4, 4, 4,
						 3, 3, 3, 3, 2, 2, 0, 0,
						 0, 0, 0, 0, 0, 0, 0, 0,
						 0, 0, 0, 0, 0, 0, 0, 0,
						 0, 0, 0, 0, 0, 0, 0, 0,
						 0, 0, 0, 0, 0, 0, 0, 0};

	const unsigned *LUT_DATA[N_ACC] = {lut_data_const_NVDLA, lut_data_const_FFT, lut_data_const_VIT, lut_data_const_FFT, lut_data_const_VIT, lut_data_const_FFT}; 
