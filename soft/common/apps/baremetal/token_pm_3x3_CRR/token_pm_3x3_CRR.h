

#ifndef __TOKEN_PM_H__
#define __TOKEN_PM_H__

//Define to run dummy config
//#define PID_CONFIG 1

//DEBUG Flag
//#define DEBUG
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
#define N_ACC 6
#define CSR_BASE_ADDR 0x60090000
#define CSR_TILE_OFFSET 0x200
#define CSR_TOKEN_PM_OFFSET 0x1d0


#define ACC_BASE_ADDR 0x60010000
#define ACC_OFFSET 0x100
// Set accelerator ID (ACC_TILE_ID) according to the position of the accelerator in the
// SoC. Acc IDs increment from left to right and from top to bottom.
// Running for config
// cpu - IO  - nvdla 
// FFT - Mem - Vit
// FFT - Vit - FFT
#define ACC_ID_NVDLA 0
#define ACC_ADDR_VITERBI1 (ACC_BASE_ADDR + (ACC_OFFSET * ACC_ID_VITERBI1))
#define ACC_ID_FFT1 1
#define ACC_ADDR_FFT1 (ACC_BASE_ADDR + (ACC_OFFSET * ACC_ID_FFT1))
#define ACC_ID_VITERBI1 2
#define ACC_ADDR_VITERBI2 (ACC_BASE_ADDR + (ACC_OFFSET * ACC_ID_VITERBI2))
#define ACC_ID_FFT2 3
#define ACC_ADDR_FFT2 (ACC_BASE_ADDR + (ACC_OFFSET * ACC_ID_FFT2))
#define ACC_ID_VITERBI2 4
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
	unsigned p_available;
	const unsigned Pmax[N_ACC] ;
	const unsigned Fmax[N_ACC];
	const unsigned Fmin[N_ACC] ;
	unsigned dev_list[N_ACC];



#define TOKEN_NEXT_MASK 0x7f


///////////////////////
// Tests
///////////////////////

// Set of tests of the bare-metal app.
// Uncomment the tests that you want to execute
 #define TEST_0 1
//// basic test to directly set frequencies from CPU SW
// #define TEST_1 1
////Test with dummy actiivyt changes for faster debug


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

void start_tile(struct esp_device espdevs[], unsigned i)
{
	if(Pmax[i]<p_available) {
		set_freq(&espdevs[i],Fmax[i]);
		p_available=p_available-Pmax[i];
	}
	else
	{
		set_freq(&espdevs[i],Fmin[i]);
	}
	write_config1(&espdevs[i],1,0,0,0);
	//Add to running list
}

void CRR_step_checkend(struct esp_device espdevs[], unsigned i)
{
	unsigned done_i=0;
	unsigned done_i_before=0;

 	for (i = 0; i < N_ACC; i++) {   
   			//if(i==1)

			//else if(i==2)
			
        	done_i = ioread32(i, STATUS_REG);
			done_i &= STATUS_MASK_DONE;
		
		if(done_i && !done_i_before) {
			write_config1(&espdevs[i], 0, 0, 0, 0);
			done_i_before=done_i;
			set_freq(&espdevs[i],Fmin[1]);
			p_available=p_available+Pmax[i];
    			#ifdef DEBUG
				printf("Finished F1\n");
    			#endif
		}
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
