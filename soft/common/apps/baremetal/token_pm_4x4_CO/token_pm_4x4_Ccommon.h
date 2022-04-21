#ifndef __TOKEN_PM_H__
#define __TOKEN_PM_H__

#include <esp_accelerator.h>
#include <esp_probe.h>
//Define to run dummy config
//#define PID_CONFIG 1

//DEBUG Flag
//#define DEBUG
//
//#define SHORT 1
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
#define TOKEN_PM_CONFIG8_REG_DEFAULT 0x00000000


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
static unsigned mem_size;
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


#define TOKEN_NEXT_MASK 0x7f


///////////////////////
// Tests
///////////////////////

// Set of tests of the bare-metal app.
// Uncomment the tests that you want to execute
//// basic test to directly set frequencies from CPU SW
// #define TEST_0 1
////Test with dummy activity changes for faster debug
// #define TEST_1 1
//Test with activity from all tiles 
#define TEST_2 1


///////////////////////
// Functions
///////////////////////



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


void set_freq(struct esp_device *espdev, unsigned freq_set)
{
	iowrite32(espdev, TOKEN_PM_CONFIG8_REG, (freq_set<<(11+4)));
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
