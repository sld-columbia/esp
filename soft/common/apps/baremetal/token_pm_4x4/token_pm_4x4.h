

#ifndef __TOKEN_PM_H__
#define __TOKEN_PM_H__

//Define to run dummy config
#define PID_CONFIG 1

//DEBUG Flag
#define DEBUG
///////////////////////
// Offset and width of CSR fields of token FSM
///////////////////////

// Configuration Register 0 (token FSM)
#define OFFSET_ENABLE 0
#define  WIDTH_ENABLE 1
#define OFFSET_MAX_TOKENS (OFFSET_ENABLE + WIDTH_ENABLE)
#define  WIDTH_MAX_TOKENS 6
#define OFFSET_REFRESH_RATE_MIN (OFFSET_MAX_TOKENS + WIDTH_MAX_TOKENS)
#define  WIDTH_REFRESH_RATE_MIN 12
#define OFFSET_REFRESH_RATE_MAX (OFFSET_REFRESH_RATE_MIN + WIDTH_REFRESH_RATE_MIN)
#define  WIDTH_REFRESH_RATE_MAX 12
// Configuration Register 1 (token FSM)
#define OFFSET_ACTIVITY 0
#define  WIDTH_ACTIVITY 1
#define OFFSET_RANDOM_RATE (OFFSET_ACTIVITY + WIDTH_ACTIVITY)
#define  WIDTH_RANDOM_RATE 5
#define OFFSET_LUT_WRITE (OFFSET_RANDOM_RATE + WIDTH_RANDOM_RATE)
#define  WIDTH_LUT_WRITE 18
#define OFFSET_TOKEN_COUNTER_OVERRIDE (OFFSET_LUT_WRITE + WIDTH_LUT_WRITE)
#define  WIDTH_TOKEN_COUNTER_OVERRIDE 8
// Configuration Register 2 (token FSM)
#define OFFSET_NEIGHBORS_ID 0
#define  WIDTH_NEIGHBORS_ID 20
// Configuration Register 3 (token FSM)
#define OFFSET_PM_NETWORK 0
#define  WIDTH_PM_NETWORK 32
// Status Register 0 (token FSM)
#define OFFSET_TOKENS_NEXT 0
#define  WIDTH_TOKENS_NEXT 7
#define OFFSET_LUT_READ (OFFSET_TOKENS_NEXT + WIDTH_TOKENS_NEXT)
#define  WIDTH_LUT_READ 8

// CSR register offsets
#define TOKEN_PM_CONFIG0_REG 0x0
#define TOKEN_PM_CONFIG1_REG 0x4
#define TOKEN_PM_CONFIG2_REG 0x8
#define TOKEN_PM_CONFIG3_REG 0xc
#define TOKEN_PM_CONFIG4_REG 0x10
#define TOKEN_PM_CONFIG5_REG 0x14
#define TOKEN_PM_CONFIG6_REG 0x18
#define TOKEN_PM_CONFIG7_REG 0x1c
#define TOKEN_PM_CONFIG8_REG 0x20
#define TOKEN_PM_STATUS0_REG 0x24
#define TOKEN_PM_STATUS1_REG 0x28

// CSR config registers default values
#define TOKEN_PM_CONFIG0_REG_DEFAULT 0
#define TOKEN_PM_CONFIG1_REG_DEFAULT 0
#define TOKEN_PM_CONFIG2_REG_DEFAULT 0
#define TOKEN_PM_CONFIG3_REG_DEFAULT 0

#define TOKEN_PM_CONFIG4_REG_DEFAULT 0x66666666
#define TOKEN_PM_CONFIG5_REG_DEFAULT 0x666663E0
#define TOKEN_PM_CONFIG6_REG_DEFAULT 0x7CFFFFFF
#define TOKEN_PM_CONFIG7_REG_DEFAULT 0xFFFFF830
//#ifdef PID_CONFIG
//	#define TOKEN_PM_CONFIG8_REG_DEFAULT 0x07FFFAA7
//#else
//	#define TOKEN_PM_CONFIG8_REG_DEFAULT 0x2FFFFAFD
//#endif
#define TOKEN_PM_CONFIG8_REG_DEFAULT 0x2FFFFAFD


/* #define TOKEN_PM_CONFIG4_REG_DEFAULT 0x0A3D70A3 */
/* #define TOKEN_PM_CONFIG5_REG_DEFAULT 0xD70A3D80 */
/* #define TOKEN_PM_CONFIG6_REG_DEFAULT 0xC800000 */
/* //#define TOKEN_PM_CONFIG6_REG_DEFAULT 0x0000000 */
/* #define TOKEN_PM_CONFIG7_REG_DEFAULT 0x00000000 */
/* #define TOKEN_PM_CONFIG8_REG_DEFAULT 0x07fffaa9 */
//#define TOKEN_PM_CONFIG8_REG_DEFAULT 0x2FFFFAFD
//#define TOKEN_PM_CONFIG8_REG_DEFAULT 0x07FFFAA7
///////////////////////
// Accelerator Tiles and Address Map
///////////////////////
#define N_ACC 13
#define CSR_BASE_ADDR 0x60090000
#define CSR_TILE_OFFSET 0x200
#define CSR_TOKEN_PM_OFFSET 0x1d0


#define ACC_BASE_ADDR 0x60010000
#define ACC_THIRD_PARTY_BASE_ADDR 0x60400000
#define ACC_OFFSET 0x100
// Set accelerator ID (ACC_TILE_ID) according to the position of the accelerator in the
// SoC. Acc IDs increment from left to right and from top to bottom.
// Running for config
// gemm - gemm - gemm   - gemm  
// nv   - nv   - nv	- nv  
// conv - conv - conv   - mem  
// nv   - nv   - cpu    - io  
//
#define ACC_ID_GEMM1 0
#define ACC_ADDR_GEMM1 (ACC_BASE_ADDR + (ACC_OFFSET * ACC_ID_GEMM1))
#define ACC_ID_GEMM2 1
#define ACC_ADDR_GEMM2 (ACC_BASE_ADDR + (ACC_OFFSET * ACC_ID_GEMM2))
#define ACC_ID_GEMM3 2
#define ACC_ADDR_GEMM3 (ACC_BASE_ADDR + (ACC_OFFSET * ACC_ID_GEMM3))
#define ACC_ID_GEMM4 3
#define ACC_ADDR_GEMM4 (ACC_BASE_ADDR + (ACC_OFFSET * ACC_ID_GEMM4))
#define ACC_ID_NV1 4
#define ACC_ADDR_NV1 (ACC_BASE_ADDR + (ACC_OFFSET * ACC_ID_NV1))
#define ACC_ID_NV2 5
#define ACC_ADDR_NV2 (ACC_BASE_ADDR + (ACC_OFFSET * ACC_ID_NV2))
#define ACC_ID_NV3 6
#define ACC_ADDR_NV3 (ACC_BASE_ADDR + (ACC_OFFSET * ACC_ID_NV3))
#define ACC_ID_NV4 7
#define ACC_ADDR_NV4 (ACC_BASE_ADDR + (ACC_OFFSET * ACC_ID_NV4))
#define ACC_ID_CONV2D1 8
#define ACC_ADDR_CONV2D1 (ACC_BASE_ADDR + (ACC_OFFSET * ACC_ID_CONV2D1))
#define ACC_ID_CONV2D2 9
#define ACC_ADDR_CONV2D2 (ACC_BASE_ADDR + (ACC_OFFSET * ACC_ID_CONV2D2))
#define ACC_ID_CONV2D3 10
#define ACC_ADDR_CONV2D3 (ACC_BASE_ADDR + (ACC_OFFSET * ACC_ID_CONV2D3))
#define ACC_ID_NV5 11
#define ACC_ADDR_NV5 (ACC_BASE_ADDR + (ACC_OFFSET * ACC_ID_NV5))
#define ACC_ID_NV6 12
#define ACC_ADDR_NV6 (ACC_BASE_ADDR + (ACC_OFFSET * ACC_ID_NV6))

//Common params
static unsigned in_words_adj;
static unsigned out_words_adj;
static unsigned in_len;
static unsigned out_len;
static unsigned in_size;
static unsigned out_size;
static unsigned out_offset;
/* Size of the contiguous chunks for scatter/gather */
#define CHUNK_SHIFT 20
#define CHUNK_SIZE BIT(CHUNK_SHIFT)
#define NCHUNK(_sz) ((_sz % CHUNK_SIZE == 0) ?		\
			(_sz / CHUNK_SIZE) :		\
			(_sz / CHUNK_SIZE) + 1)




const unsigned acc_tile_ids[N_ACC] = {0,1,2,3,4,5,6,7,8,9,10,12,13};


///////////////////////
// Parameters
///////////////////////
const unsigned enable_const = 1;
const unsigned activity_const = 1;
const unsigned no_activity_const = 0;

const unsigned max_tokens_vc707[N_ACC] = {324, 324, 324, 324, 24, 24, 24, 24, 48, 48, 48, 24, 24};
const unsigned refresh_rate_min_const = 90;
const unsigned refresh_rate_max_const = 90;
const unsigned total_tokens = 150;
const unsigned total_tokens_ini = 150; //Change to 24 for original test

#define LUT_SIZE 64

#ifdef PID_CONFIG
	const unsigned lut_data_const[LUT_SIZE] = { 0, 0, 0, 0, 0, 0, 0, 0,
						    0, 0, 0, 0, 0, 0, 0, 0,
						    0, 0, 0, 0, 0, 0, 0, 0,
						    0, 0, 0, 0, 0, 0, 0, 0,
						    0, 0, 0, 0, 0, 0, 0, 0,
						    0, 0, 0, 0, 0, 0, 0, 0,
						    0, 0, 0, 0, 0, 0, 0, 0,
						    0, 0, 0, 0, 0, 0, 0, 0};
	const unsigned lut_data_const_vc707[LUT_SIZE] = { 0, 0, 0, 0, 0, 0, 0, 0,
						    0, 0, 0, 0, 0, 0, 0, 0,
						    0, 0, 0, 0, 0, 0, 0, 0,
						    0, 0, 0, 0, 0, 0, 0, 0,
						    0, 0, 0, 0, 0, 0, 0, 0,
						    0, 0, 0, 0, 0, 0, 0, 0,
						    0, 0, 0, 0, 0, 0, 0, 0,
						    0, 0, 0, 0, 0, 0, 0, 0};
#else
	const unsigned lut_data_const_vc707_GEMM[LUT_SIZE] = {  11<<4,  11<<4,  11<<4,  11<<4,  11<<4,  10<<4,  10<<4,  10<<4,   9<<4,   9<<4,   9<<4,   8<<4,   8<<4,   7<<4,   7<<4,
					       	        	6<<4,   6<<4,   6<<4,   5<<4,   5<<4,   5<<4,   5<<4,   5<<4,   4<<4,   4<<4,   4<<4,   4<<4,   4<<4,   4<<4,   3<<4,
					  	        	3<<4,   3<<4,   3<<4,   3<<4,   3<<4,   3<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,
							        2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,
								2<<4,   2<<4,   2<<4,   2<<4};
						
								
	const unsigned lut_data_const_vc707_CONV2D[LUT_SIZE] = {  11<<4,  11<<4,  11<<4,  11<<4,  11<<4,  11<<4,  10<<4,  10<<4,  10<<4,   9<<4,   9<<4,   9<<4,   8<<4,   8<<4,   8<<4,
								7<<4,   7<<4,   6<<4,   6<<4,   6<<4,   6<<4,   5<<4,   5<<4,   5<<4,   5<<4,   4<<4,   4<<4,   4<<4,   4<<4,   4<<4,
								3<<4,   3<<4,   3<<4,   3<<4,   3<<4,   3<<4,   3<<4,   3<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,
								2<<4,   2<<4,   1<<4,   1<<4,   1<<4,   1<<4,   1<<4,   1<<4,   1<<4,   1<<4,   1<<4,   1<<4,   1<<4,   1<<4,   1<<4,
								1<<4,   1<<4,   1<<4,   1<<4};

	const unsigned lut_data_const_vc707_NV[LUT_SIZE] = {  11<<4,  11<<4,  11<<4,  10<<4,  10<<4,   9<<4,   8<<4,   8<<4,   7<<4,   6<<4,   6<<4,   5<<4,   5<<4,   5<<4,   4<<4,
								4<<4,   4<<4,   4<<4,   4<<4,   3<<4,   3<<4,   3<<4,   3<<4,   3<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,
								2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,
								2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,   2<<4,
								2<<4,   2<<4,   2<<4,   2<<4};

	/* const unsigned lut_data_const_vc707[LUT_SIZE] = {1, 1, 1, 1, 1, 1, 1, 1, */
	/* 						 1, 1, 1, 1, 1, 1, 1, 1, */
	/* 						 3, 3, 3, 3, 3, 3, 3, 3, */
	/* 						 3, 3, 3, 3, 3, 3, 3, 3, */
	/* 						 4, 4, 4, 4, 4, 4, 4, 4, */
	/* 						 4, 4, 4, 4, 4, 4, 4, 4, */
	/* 						 10, 10, 10, 10, 10, 10, 10, 10, */
	/* 						 10, 10, 10, 10, 10, 10, 10, 10}; */
#endif

const unsigned random_rate_const_0 = 0;//For tile 0
const unsigned random_rate_const = 17;
//const unsigned neighbors_id_const[N_ACC] = {33825, 0}; // 00001 00001 00001 00001, 00000 00000 00000 00000 
/*Define neighbors*/
//const unsigned int neighbors_id_const[N_ACC] = {(1 << 15) + (2 << 10) + (4 << 5) + 5, (0 << 15) + (2 << 10) + (3 << 5) + 5, (0 << 15) + (3 << 10) + (4 << 5) + 5, (0 << 15) + (1 << 10) + (4 << 5) + 5, (0 << 15) +(1 << 10) + (3 << 5) + 5, (0 << 15) + (1 << 10) + (2 << 5) + 3};
//const unsigned int pm_network_const[N_ACC] = {0,4,1,2,2,4};
const unsigned int neighbors_id_const[N_ACC] = {(3 << 15) + (11 << 10) + (1 << 5) + 4, (0 << 15) + (12 << 10) + (2 << 5) + 5, (1 << 15) + (10 << 10) + (3 << 5) + 6, (2 << 15) + (7 << 10) + (0 << 5) + 11, (7 << 15) +(0 << 10) + (5 << 5) + 8, (4 << 15) + (1 << 10) + (6 << 5) + 9, (5 << 15) + (2 << 10) + (7 << 5) + 10, (6 << 15) + (3 << 10) + (4 << 5) + 9, (10 << 15) + (4 << 10) + (9 << 5) + 11, (8 << 15) + (5 << 10) + (10 << 5) + 12, (9 << 15) + (6 << 10) + (8 << 5) + 2, (12 << 15) + (8 << 10) + (3 << 5) + 0, (11 << 15) + (9 << 10) + (0 << 5) + 1};
const unsigned int pm_network_const[N_ACC] = {0,8,0,8,2,0,4,0,2,2,0,4,4};

		// Allocate inital tokens - max 6 bit
//const unsigned pm_network_const = 0;
//Initialized by init_consts()
//unsigned int pm_network_const[N_ACC];
unsigned token_counter_override_vc707[N_ACC];

#define TOKEN_NEXT_MASK 0x7f


///////////////////////
// Tests
///////////////////////

// Set of tests of the bare-metal app.
// Uncomment the tests that you want to execute
// #define TEST_0 0
//// basic test for vc707 FPGA
//#define TEST_1 0
//// test for vc707 FPGA including FFT accelerator execution
//#define TEST_2 1
//// test for vc707 FPGA including Viterbi accelerator execution
//#define TEST_3 0
// test for vc707 FPGA including Viterbi and FFT parallel accelerator executions
#define TEST_4 1

///////////////////////
// Functions
///////////////////////

void init_consts()
{
	int n;
	unsigned remaining_tokens=total_tokens_ini;

	/*for (n = 0; n < N_ACC; n++) {
		// 1 for all accs part of token PM
		
		if(remaining_tokens>(1<<6-1)){
			token_counter_override_vc707[n]=(1 << 7)+1<<6-1;
			remaining_tokens=remaining_tokens-1<<6;
		}
		else{
			token_counter_override_vc707[n]=(1 << 7)+remaining_tokens;
			remaining_tokens=0;
		}
	}*/
	
	token_counter_override_vc707[0]=(1<<7) + total_tokens_ini;
	token_counter_override_vc707[1]=0;
	token_counter_override_vc707[2]=0;
	token_counter_override_vc707[3]=0;
	token_counter_override_vc707[4]=0;
	token_counter_override_vc707[5]=0;
	token_counter_override_vc707[6]=0;
	token_counter_override_vc707[7]=0;
	token_counter_override_vc707[8]=0;
	token_counter_override_vc707[9]=0;
	token_counter_override_vc707[10]=0;
	token_counter_override_vc707[11]=0;
	token_counter_override_vc707[12]=0;


}

void reset_token_pm(struct esp_device espdevs[])
{
    int i;

    printf("Reset CSRs\n");

    for (i = 0; i < N_ACC; i++) {
	iowrite32(&espdevs[i], TOKEN_PM_CONFIG0_REG, TOKEN_PM_CONFIG0_REG_DEFAULT);
	iowrite32(&espdevs[i], TOKEN_PM_CONFIG1_REG, TOKEN_PM_CONFIG1_REG_DEFAULT);
	iowrite32(&espdevs[i], TOKEN_PM_CONFIG2_REG, TOKEN_PM_CONFIG2_REG_DEFAULT);
	iowrite32(&espdevs[i], TOKEN_PM_CONFIG3_REG, TOKEN_PM_CONFIG3_REG_DEFAULT);
	iowrite32(&espdevs[i], TOKEN_PM_CONFIG4_REG, TOKEN_PM_CONFIG4_REG_DEFAULT);
	iowrite32(&espdevs[i], TOKEN_PM_CONFIG5_REG, TOKEN_PM_CONFIG5_REG_DEFAULT);
	iowrite32(&espdevs[i], TOKEN_PM_CONFIG6_REG, TOKEN_PM_CONFIG6_REG_DEFAULT);
	iowrite32(&espdevs[i], TOKEN_PM_CONFIG7_REG, TOKEN_PM_CONFIG7_REG_DEFAULT);
	iowrite32(&espdevs[i], TOKEN_PM_CONFIG8_REG, TOKEN_PM_CONFIG8_REG_DEFAULT);
    }
}

void write_config0(struct esp_device *espdev, unsigned enable, unsigned max_tokens,
		   unsigned refresh_rate_min, unsigned refresh_rate_max)
{
    unsigned val;

    val = (refresh_rate_max << OFFSET_REFRESH_RATE_MAX) |
	(refresh_rate_min << OFFSET_REFRESH_RATE_MIN) |
	(max_tokens << OFFSET_MAX_TOKENS) |
	(enable << OFFSET_ENABLE);

    iowrite32(espdev, TOKEN_PM_CONFIG0_REG, val);
}

void write_config1(struct esp_device *espdev,unsigned activity, unsigned random_rate,
		   unsigned lut_write, unsigned token_counter_override)
{
    unsigned val;

    val = (token_counter_override << OFFSET_TOKEN_COUNTER_OVERRIDE) |
	(lut_write << OFFSET_LUT_WRITE) |
	(random_rate << OFFSET_RANDOM_RATE) |
	(activity << OFFSET_ACTIVITY);

    iowrite32(espdev, TOKEN_PM_CONFIG1_REG, val);
}

void write_config2(struct esp_device *espdev, unsigned neighbors_id)
{
    iowrite32(espdev, TOKEN_PM_CONFIG2_REG, neighbors_id);
}

void write_config3(struct esp_device *espdev, unsigned pm_network)
{
    iowrite32(espdev, TOKEN_PM_CONFIG3_REG, pm_network);
}

void wait_for_token_next(struct esp_device *espdev, unsigned tokens_next_expected)
{
    while (tokens_next_expected != (ioread32(espdev, TOKEN_PM_STATUS0_REG) & TOKEN_NEXT_MASK));
}

void write_lut(struct esp_device espdevs[], const unsigned lut_data[LUT_SIZE],
               unsigned random_rate, unsigned activity,unsigned myindex)
{
	int i, j;
	unsigned reg_val = 0, lut_val = 0;

	//printf("Write LUT\n");

	for (j = 0; j < LUT_SIZE; j++) {
		lut_val = (1 << 17) | (0 << 16) | (lut_data[j] << 8) | j;
		write_config1(&espdevs[myindex], activity, random_rate, lut_val, 0); 
	}   
}
				   


void write_lut_all(struct esp_device espdevs[], const unsigned lut_data[LUT_SIZE],
	       unsigned random_rate, unsigned activity)
{
    int i, j;
    unsigned reg_val = 0, lut_val = 0;
    
    printf("Write LUT\n");

  
    for (i = 0; i < N_ACC; i++) {
	for (j = 0; j < LUT_SIZE; j++) {
	    lut_val = (1 << 17) | (0 << 16) | (lut_data[j] << 8) | j;
	    write_config1(&espdevs[i], activity, random_rate, lut_val, 0);
	}
    }
}

/* void validate_lut(struct esp_device espdevs[], unsigned lut_data, */
/* 		  unsigned random_rate, unsigned activity) */
/* { */
/*     int i, j; */
/*     unsigned reg_val = 0; */
    
/*     printf("Write LUT\n"); */

/*     for (i = 0; i < N_ACC; i++) { */
/* 	for (j = 0; j < LUT_SIZE; j++) { */
/* 	    write_config1(&espdevs[i], 0, lut_data[j], 0, random_rate, activity); */
/* 	} */
/*     } */
/* } */


static inline uint64_t get_counter()
{
    uint64_t counter;
    asm volatile (
	"li t0, 0;"
	"csrr t0, mcycle;"
	"mv %0, t0"
	: "=r" ( counter )
	:
	: "t0"
        );
    return counter;
} 

#endif /* __TOKEN_PM_H__ */
