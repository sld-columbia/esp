#define P_TOTAL 450
#define max_power_GEMM 113
#define max_power_CONV 145
#define max_power_NV 72
//TODO to add values
#define min_power_GEMM 10
#define min_power_CONV 10
#define min_power_NV 10

//#define NACC 6 //Already define in main .h
#define LUT_SIZE 64

//TODO to add values
#define max_tokens_GEMM 38
#define max_tokens_CONV 48
#define max_tokens_NV 24

	const unsigned lut_data_const_GEMM[LUT_SIZE] = {  11,  11,  11,  11,  11,  10,  10,  10,   9,   9,   9,   8,   8,   7,   7,
					       	        	6,   6,   6,   5,   5,   5,   5,   5,   4,   4,   4,   4,   4,   4,   3,
					  	        	3,   3,   3,   3,   3,   3,   2,   2,   2,   2,   2,   2,   2,   2,   2,
							        2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,
								2,   2,   2,   2};
						
								
	const unsigned lut_data_const_CONV[LUT_SIZE] = {  11,  11,  11,  11,  11,  11,  10,  10,  10,   9,   9,   9,   8,   8,   8,
								7,   7,   6,   6,   6,   6,   5,   5,   5,   5,   4,   4,   4,   4,   4,
								3,   3,   3,   3,   3,   3,   3,   3,   2,   2,   2,   2,   2,   2,   2,
								2,   2,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
								1,   1,   1,   1};

	const unsigned lut_data_const_NV[LUT_SIZE] = {  11,  11,  11,  10,  10,   9,   8,   8,   7,   6,   6,   5,   5,   5,   4,
								4,   4,   4,   4,   3,   3,   3,   3,   3,   2,   2,   2,   2,   2,   2,
								2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,
								2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,
								2,   2,   2,   2};
