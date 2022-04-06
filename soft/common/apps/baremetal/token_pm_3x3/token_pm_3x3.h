/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#ifndef __TOKEN_PM_H__
#define __TOKEN_PM_H__


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
#define TOKEN_PM_CONFIG8_REG_DEFAULT 0x07FFFAA7

/* #define TOKEN_PM_CONFIG4_REG_DEFAULT 0x0A3D70A3 */
/* #define TOKEN_PM_CONFIG5_REG_DEFAULT 0xD70A3D80 */
/* #define TOKEN_PM_CONFIG6_REG_DEFAULT 0xC800000 */
/* //#define TOKEN_PM_CONFIG6_REG_DEFAULT 0x0000000 */
/* #define TOKEN_PM_CONFIG7_REG_DEFAULT 0x00000000 */
/* #define TOKEN_PM_CONFIG8_REG_DEFAULT 0x07fffaa9 */

///////////////////////
// Accelerator Tiles and Address Map
///////////////////////
#define N_ACC 6
#define CSR_BASE_ADDR 0x60090000
#define CSR_TILE_OFFSET 0x200
#define CSR_TOKEN_PM_OFFSET 0x1d0


#define ACC_BASE_ADDR 0x60010000
#define ACC_OFFSET 0x100
// Set accelerator ID (ACC_TILE_ID) according to the position of the accelerator in the
// SoC. Acc IDs increment from left to right and from top to bottom.
// Running for config
// cpu - IO  - Vit 
// FFT - Mem - Vit
// FFT - Vit - FFT
#define ACC_ID_VITERBI1 0
#define ACC_ADDR_VITERBI1 (ACC_BASE_ADDR + (ACC_OFFSET * ACC_ID_VITERBI1))
#define ACC_ID_FFT1 1
#define ACC_ADDR_FFT1 (ACC_BASE_ADDR + (ACC_OFFSET * ACC_ID_FFT1))
#define ACC_ID_VITERBI2 2
#define ACC_ADDR_VITERBI2 (ACC_BASE_ADDR + (ACC_OFFSET * ACC_ID_VITERBI2))
#define ACC_ID_FFT2 3
#define ACC_ADDR_FFT2 (ACC_BASE_ADDR + (ACC_OFFSET * ACC_ID_FFT2))
#define ACC_ID_VITERBI3 4
#define ACC_ADDR_VITERBI3 (ACC_BASE_ADDR + (ACC_OFFSET * ACC_ID_VITERBI3))
#define ACC_ID_FFT3 5
#define ACC_ADDR_FFT3 (ACC_BASE_ADDR + (ACC_OFFSET * ACC_ID_FFT3))

//Common params
static unsigned in_words_adj;
static unsigned out_words_adj;
static unsigned in_len;
static unsigned out_len;
static unsigned in_size;
static unsigned out_size;
static unsigned out_offset;
static unsigned mem_size;
/* Size of the contiguous chunks for scatter/gather */
#define CHUNK_SHIFT 20
#define CHUNK_SIZE BIT(CHUNK_SHIFT)
#define NCHUNK(_sz) ((_sz % CHUNK_SIZE == 0) ?		\
			(_sz / CHUNK_SIZE) :		\
			(_sz / CHUNK_SIZE) + 1)




const unsigned acc_tile_ids[N_ACC] = {2,3,5,6,7,8};


///////////////////////
// Parameters
///////////////////////
const unsigned enable_const = 1;
const unsigned activity_const = 1;
const unsigned no_activity_const = 0;

const unsigned max_tokens_vc707[N_ACC] = {60, 60, 60, 60, 60, 60};
const unsigned refresh_rate_min_const = 1000;
const unsigned refresh_rate_max_const = 1000;
const unsigned total_tokens = 200;

#define LUT_SIZE 64
const unsigned lut_data_const[LUT_SIZE] = {  0,   4,   8,  12,  16,  20,  24,  28,
					    32,  36,  40,  44,  48,  52,  56,  60,
					    64,  68,  72,  76,  80,  84,  88,  92,
					    96, 100, 104, 108, 112, 116, 120, 124,
					   128, 132, 136, 140, 144, 148, 152, 156,
					   160, 164, 168, 172, 176, 180, 184, 188,
					   192, 196, 200, 204, 208, 212, 216, 220,
					   224, 228, 232, 236, 240, 244, 248, 252};
const unsigned lut_data_const_vc707[LUT_SIZE] = {2, 2, 2, 2, 2, 2, 2, 2,
						 2, 2, 2, 2, 2, 2, 2, 2,
						 3, 3, 3, 3, 3, 3, 3, 3,
						 3, 3, 3, 3, 3, 3, 3, 3,
						 5, 5, 5, 5, 5, 5, 5, 5,
						 5, 5, 5, 5, 5, 5, 5, 5,
						 10, 10, 10, 10, 10, 10, 10, 10,
						 10, 10, 10, 10, 10, 10, 10, 10};
/* const unsigned lut_data_const_vc707[LUT_SIZE] = {1, 1, 1, 1, 1, 1, 1, 1, */
/* 						 1, 1, 1, 1, 1, 1, 1, 1, */
/* 						 3, 3, 3, 3, 3, 3, 3, 3, */
/* 						 3, 3, 3, 3, 3, 3, 3, 3, */
/* 						 4, 4, 4, 4, 4, 4, 4, 4, */
/* 						 4, 4, 4, 4, 4, 4, 4, 4, */
/* 						 10, 10, 10, 10, 10, 10, 10, 10, */
/* 						 10, 10, 10, 10, 10, 10, 10, 10}; */

const unsigned random_rate_const = 0;
//const unsigned neighbors_id_const[N_ACC] = {33825, 0}; // 00001 00001 00001 00001, 00000 00000 00000 00000 
/*Define neighbors*/
const unsigned int neighbors_id_const[N_ACC] = {(5 << 15) + (2 << 10) + (2 << 5) + 1, (0 << 15) + (2 << 10) + (3 << 5) + 4, (1 << 15) + (0 << 10) + (0 << 5) + 5, (1 << 15) + (4 << 10) + (5 << 5) + 4, (1 << 10) + (3 << 5) + 5, (4 << 15) + (2 << 10) + (3 << 5) + 0};
//const unsigned pm_network_const = 0;
//Initialized by init_consts()
unsigned int pm_network_const[N_ACC];
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
//#define TEST_2 0
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
	unsigned remaining_tokens=total_tokens;

	for (n = 0; n < N_ACC; n++) {
		// 1 for all accs part of token PM
		pm_network_const[n] = 1<<(N_ACC+1)-1;
		// Allocate inital tokens - max 6 bit
		if(remaining_tokens>(2<<6-1)){
			token_counter_override_vc707[n]=(1 << 7)+2<<6;
			remaining_tokens=remaining_tokens-2<<6;
		}
		else{
			token_counter_override_vc707[n]=(1 << 7)+remaining_tokens;
			remaining_tokens=0;
		}
	}
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
