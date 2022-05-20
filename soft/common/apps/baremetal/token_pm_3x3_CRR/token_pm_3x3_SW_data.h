#define P_TOTAL 60
#define max_power_NVDLA 120
#define max_power_FFT 20
#define max_power_VIT 64
#define min_power_NVDLA 12
#define min_power_FFT 1
#define min_power_VIT 3

//#define NACC 6 //Already define in main .h
#define LUT_SIZE 64


#define max_tokens_FFT 4
#define max_tokens_VIT 13
#define max_tokens_NVDLA 24

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
