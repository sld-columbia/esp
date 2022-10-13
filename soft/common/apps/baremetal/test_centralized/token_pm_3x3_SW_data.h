//#include "token_pm_3x3_Ccommon.h"
//CO params
#define total_tokens 24
#define N_ACC 6 //Already define in main .h
#define LUT_SIZE 64

#define max_tokens_FFT 4
#define max_tokens_VIT 11
#define max_tokens_NVDLA 24

const unsigned max_tokens[N_ACC] = {max_tokens_NVDLA, max_tokens_FFT, max_tokens_VIT, max_tokens_FFT, max_tokens_VIT, max_tokens_FFT};

//CRR params
#define P_TOTAL 120
#define max_power_NVDLA 120
#define max_power_FFT 20
#define max_power_VIT 64
#define min_power_NVDLA 12
#define min_power_FFT 1
#define min_power_VIT 3
unsigned p_available = P_TOTAL;

const unsigned lut_data_const_FFT[LUT_SIZE] = {0xB, 7, 4, 2, 1, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0};

const unsigned lut_data_const_VIT[LUT_SIZE] = {0xB, 0xA, 9, 8, 7, 6, 6, 5,
	4, 4, 3, 3, 0, 0, 0, 0,
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

const unsigned Pmax[N_ACC] = {max_power_NVDLA, max_power_FFT,max_power_VIT,max_power_FFT,max_power_VIT,max_power_FFT};
const unsigned Pmin[N_ACC] = {min_power_NVDLA,min_power_FFT,min_power_VIT,min_power_FFT,min_power_VIT,min_power_FFT};
const unsigned Fmax[N_ACC]= {lut_data_const_NVDLA[max_tokens_NVDLA],lut_data_const_FFT[max_tokens_FFT],lut_data_const_VIT[max_tokens_VIT],lut_data_const_FFT[max_tokens_FFT],lut_data_const_VIT[max_tokens_VIT],lut_data_const_FFT[max_tokens_FFT]};
const unsigned Fmin[N_ACC] = {lut_data_const_NVDLA[0],lut_data_const_FFT[0],lut_data_const_VIT[0],lut_data_const_FFT[0],lut_data_const_VIT[0],lut_data_const_FFT[0]};

//Karthik -- All assuming in run queue. For idle queue we assume a 1:2 ratio.
const unsigned ACC_RUNTIME[N_ACC] = {6, 8, 12, 8, 12, 8};


