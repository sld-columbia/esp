#include "token_pm_3x3_Ccommon.h"

#define P_TOTAL 60
#define max_power_NVDLA 120
#define max_power_FFT 20
#define max_power_VIT 64
#define min_power_NVDLA 12
#define min_power_FFT 1
#define min_power_VIT 3

//#define NACC 6 //Already define in main .h
//#define LUT_SIZE 64
//
//
//#define max_tokens_FFT 4
//#define max_tokens_VIT 13
//#define max_tokens_NVDLA 24
//

#define total_tokens 12
//#define N_ACC 6 //Already define in main .h
#define LUT_SIZE 64

#define max_tokens_FFT 4
#define max_tokens_VIT 11
#define max_tokens_NVDLA 24

const unsigned max_tokens[N_ACC] = {max_tokens_NVDLA, max_tokens_FFT, max_tokens_VIT, max_tokens_FFT, max_tokens_VIT, max_tokens_FFT};

	const unsigned lut_data_const_FFT[LUT_SIZE]= {255,  215,  168,  126,   98,   77,   58,   40,   24,   18,   14,   14,
		14,   14,   14,   14,   14,   14,   14,   14,   14,   14,   14,   14,
		14,   14,   14,   14,   14,   14,   14,   14,   14,   14,   14,   14,
		14,   14,   14,   14,   14,   14,   14,   14,   14,   14,   14,   14,
		14,   14,   14,   14,   14,   14,   14,   14,   14,   14,   14,   14,
		14,   14,   14,   14};

	const unsigned lut_data_const_VIT[LUT_SIZE]= { 255,  250,  238,  226,  214,  203,  194,  184,  175,  165,  156,  149,
  142,  134,  127,  120,  113,  106,  101,   96,   91,   87,   82,   77,
   73,   68,   63,   59,   55,   51,   47,   43,   39,   39,   39,   39,
   39,   39,   39,   39,   39,   39,   39,   39,   39,   39,   39,   39,
   39,   39,   39,   39,   39,   39,   39,   39,   39,   39,   39,   39,
   39,   39,   39,   39};

	const unsigned lut_data_const_NVDLA[LUT_SIZE]= {255,  255,  254,  251,  247,  243,  239,  235,  231,  227,  223,  219,
		215,  211,  207,  203,  199,  196,  192,  188,  184,  180,  176,  172,
		168,  164,  160,  156,  152,  149,  145,  141,  137,  133,  130,  127,
		125,  122,  120,  117,  115,  112,  110,  107,  104,  102,   99,   97,
		94,   92,   89,   87,   84,   82,   79,   77,   74,   73,   71,   70,
		68,   67,   65,   64};

	const unsigned *LUT_DATA[N_ACC] = {lut_data_const_NVDLA, lut_data_const_FFT, lut_data_const_VIT, lut_data_const_FFT, lut_data_const_VIT, lut_data_const_FFT}; 
