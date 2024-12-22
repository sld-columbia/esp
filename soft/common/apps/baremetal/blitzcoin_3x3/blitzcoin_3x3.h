

#ifndef __TOKEN_PM_H__
    #define __TOKEN_PM_H__

    // DEBUG Flag
    //#define DEBUG
    ///////////////////////
    // Offset and width of CSR fields of token FSM
    ///////////////////////

    // Configuration Register 0 (token FSM)
    #define OFFSET_ENABLE           0
    #define WIDTH_ENABLE            1
    #define OFFSET_MAX_TOKENS       (OFFSET_ENABLE + WIDTH_ENABLE)
    #define WIDTH_MAX_TOKENS        6
    #define OFFSET_REFRESH_RATE_MIN (OFFSET_MAX_TOKENS + WIDTH_MAX_TOKENS)
    #define WIDTH_REFRESH_RATE_MIN  12
    #define OFFSET_REFRESH_RATE_MAX (OFFSET_REFRESH_RATE_MIN + WIDTH_REFRESH_RATE_MIN)
    #define WIDTH_REFRESH_RATE_MAX  12
    // Configuration Register 1 (token FSM)
    #define OFFSET_ACTIVITY               0
    #define WIDTH_ACTIVITY                1
    #define OFFSET_RANDOM_RATE            (OFFSET_ACTIVITY + WIDTH_ACTIVITY)
    #define WIDTH_RANDOM_RATE             5
    #define OFFSET_LUT_WRITE              (OFFSET_RANDOM_RATE + WIDTH_RANDOM_RATE)
    #define WIDTH_LUT_WRITE               18
    #define OFFSET_TOKEN_COUNTER_OVERRIDE (OFFSET_LUT_WRITE + WIDTH_LUT_WRITE)
    #define WIDTH_TOKEN_COUNTER_OVERRIDE  8
    // Configuration Register 2 (token FSM)
    #define OFFSET_NEIGHBORS_ID 0
    #define WIDTH_NEIGHBORS_ID  20
    // Configuration Register 3 (token FSM)
    #define OFFSET_PM_NETWORK 0
    #define WIDTH_PM_NETWORK  32
    // Status Register 0 (token FSM)
    #define OFFSET_TOKENS_NEXT 0
    #define WIDTH_TOKENS_NEXT  7
    #define OFFSET_LUT_READ    (OFFSET_TOKENS_NEXT + WIDTH_TOKENS_NEXT)
    #define WIDTH_LUT_READ     8

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
    #ifdef PID_CONFIG
        #define TOKEN_PM_CONFIG8_REG_DEFAULT 0x07FFFAA7
    #else
        #define TOKEN_PM_CONFIG8_REG_DEFAULT 0x2FFFFAFD
    #endif

    ///////////////////////
    // Accelerator Tiles and Address Map
    ///////////////////////
    #define N_ACC               6
    #define CSR_BASE_ADDR       0x60090000
    #define CSR_TILE_OFFSET     0x200
    #define CSR_TOKEN_PM_OFFSET 0x1d0

    #define ACC_BASE_ADDR             0x60010000
    #define ACC_THIRD_PARTY_BASE_ADDR 0x60400000
    #define ACC_OFFSET                0x100
    // Set accelerator ID (ACC_TILE_ID) according to the position of the accelerator in the
    // SoC. Acc IDs increment from left to right and from top to bottom.
    // Running for config
    // cpu - IO  - nvdla
    // FFT - Mem - Vit
    // FFT - Vit - FFT
    #define ACC_ID_NVDLA      0
    #define ACC_ADDR_NVDLA    (ACC_THIRD_PARTY_BASE_ADDR + (ACC_OFFSET * ACC_ID_NVDLA))
    #define ACC_ID_FFT0       1
    #define ACC_ADDR_FFT0     (ACC_BASE_ADDR + (ACC_OFFSET * ACC_ID_FFT0))
    #define ACC_ID_VITERBI0   2
    #define ACC_ADDR_VITERBI0 (ACC_BASE_ADDR + (ACC_OFFSET * ACC_ID_VITERBI0))
    #define ACC_ID_FFT1       3
    #define ACC_ADDR_FFT1     (ACC_BASE_ADDR + (ACC_OFFSET * ACC_ID_FFT1))
    #define ACC_ID_VITERBI1   4
    #define ACC_ADDR_VITERBI1 (ACC_BASE_ADDR + (ACC_OFFSET * ACC_ID_VITERBI1))
    #define ACC_ID_FFT2       5
    #define ACC_ADDR_FFT2     (ACC_BASE_ADDR + (ACC_OFFSET * ACC_ID_FFT2))

// Common params
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
    #define CHUNK_SIZE  BIT(CHUNK_SHIFT)
    #define NCHUNK(_sz) ((_sz % CHUNK_SIZE == 0) ? (_sz / CHUNK_SIZE) : (_sz / CHUNK_SIZE) + 1)

// Tile ID of the tiles with BlitzCoin enabled
const unsigned acc_tile_ids[N_ACC] = {2, 3, 5, 6, 7, 8};

///////////////////////
// Parameters
///////////////////////
const unsigned enable_const      = 1;
const unsigned activity_const    = 1;
const unsigned no_activity_const = 0;

// Value setting of the ḿax'register of the tiles with PM 63 -> NVLDA, 10 -> FFT, 36 -> Viterbi
const unsigned max_tokens[N_ACC]      = {63, 10, 36, 10, 36, 10};
const unsigned max_tokens_EXP0[N_ACC] = {40, 0, 40, 0, 0, 0};

const unsigned refresh_rate_min_const[N_ACC] = {
    97,  101, 103, 107,
    109, 113}; // Choosing slighly different and co-prime refresh rates for the different tiles can
               // help avoiding collisions and simplifies convergence
const unsigned refresh_rate_max_const[N_ACC] = {97, 101, 103, 107, 109, 113};
const unsigned total_tokens                  = 30;
const unsigned total_tokens_ini              = total_tokens;

    #define LUT_SIZE 64

// Filled baed on each tile V,F response and our DRCo code vs freq setting
const unsigned lut_data_const_FFT[LUT_SIZE] = {
    255, 215, 168, 126, 98, 77, 58, 40, 24, 18, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14,
    14,  14,  14,  14,  14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14,
    14,  14,  14,  14,  14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14};

const unsigned lut_data_const_VIT[LUT_SIZE] = {
    255, 250, 238, 226, 214, 203, 194, 184, 175, 165, 156, 149, 142, 134, 127, 120,
    113, 106, 101, 96,  91,  87,  82,  77,  73,  68,  63,  59,  55,  51,  47,  43,
    39,  39,  39,  39,  39,  39,  39,  39,  39,  39,  39,  39,  39,  39,  39,  39,
    39,  39,  39,  39,  39,  39,  39,  39,  39,  39,  39,  39,  39,  39,  39,  39};

const unsigned lut_data_const_NVDLA[LUT_SIZE] = {
    255, 255, 254, 251, 247, 243, 239, 235, 231, 227, 223, 219, 215, 211, 207, 203,
    199, 196, 192, 188, 184, 180, 176, 172, 168, 164, 160, 156, 152, 149, 145, 141,
    137, 133, 130, 127, 125, 122, 120, 117, 115, 112, 110, 107, 104, 102, 99,  97,
    94,  92,  89,  87,  84,  82,  79,  77,  74,  73,  71,  70,  68,  67,  65,  64};

#endif

const unsigned random_rate_const_0 = 0; // For tile 0
const unsigned random_rate_const   = 17;
/*Define neighbors for each tile*/
/*Neighbors do not have to be physical neigbors of a given tile, this can be adjusted with CSRs */
const unsigned int neighbors_id_const[N_ACC] = {
    (1 << 15) + (2 << 10) + (4 << 5) + 5, (0 << 15) + (2 << 10) + (3 << 5) + 5,
    (0 << 15) + (3 << 10) + (4 << 5) + 5, (0 << 15) + (1 << 10) + (4 << 5) + 5,
    (0 << 15) + (1 << 10) + (3 << 5) + 5, (0 << 15) + (1 << 10) + (2 << 5) + 3};
const unsigned int neighbors_id_const_EXP0[N_ACC] = {
    (2 << 15) + (2 << 10) + (2 << 5) + 2,
    0,
    (0 << 15) + (0 << 10) + (0 << 5) + 0,
    0,
    0,
    0}; // For Experiment0 only neighbor IDs are defined for tiles 0 and 2, others are unused.
const unsigned int pm_network_const[N_ACC] = {0, 4, 1, 2, 2, 4};

// const unsigned pm_network_const = 0;
// Initialized by init_consts()
// unsigned int pm_network_const[N_ACC];
unsigned token_counter_override[N_ACC];

#define TOKEN_NEXT_MASK 0x7f

///////////////////////
// Tests
///////////////////////

// Set of tests of the bare-metal app.
// Uncomment the tests that you want to execute
#define TEST_0 0
//// basic test for coin exchange between 2 tiles
#define TEST_1 1
//// Test covering coin exchange for 6 tiles with Blitzcoin running parallel workloads on FFT,
///Viterbi and NVDLA
///////////////////////
// Functions
///////////////////////

void init_consts()
{
    int n;
    unsigned remaining_tokens = total_tokens_ini;

    for (n = 0; n < N_ACC; n++) {
        // 1 for all accs part of token PM

        if (remaining_tokens > (1 << 6 - 1)) {
            token_counter_override[n] = (1 << 7) + 1 << 6 - 1;
            remaining_tokens          = remaining_tokens - 1 << 6;
        }
        else {
            token_counter_override[n] = (1 << 7) + remaining_tokens;
            remaining_tokens          = 0;
        }
    }
}

void reset_blitzcoin(struct esp_device espdevs[])
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
        (refresh_rate_min << OFFSET_REFRESH_RATE_MIN) | (max_tokens << OFFSET_MAX_TOKENS) |
        (enable << OFFSET_ENABLE);

    iowrite32(espdev, TOKEN_PM_CONFIG0_REG, val);
}

void write_config1(struct esp_device *espdev, unsigned activity, unsigned random_rate,
                   unsigned lut_write, unsigned token_counter_override)
{
    unsigned val;

    val = (token_counter_override << OFFSET_TOKEN_COUNTER_OVERRIDE) |
        (lut_write << OFFSET_LUT_WRITE) | (random_rate << OFFSET_RANDOM_RATE) |
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
    while (tokens_next_expected != (ioread32(espdev, TOKEN_PM_STATUS0_REG) & TOKEN_NEXT_MASK))
        ;
}

void write_lut(struct esp_device espdevs[], const unsigned lut_data[LUT_SIZE], unsigned random_rate,
               unsigned activity, unsigned myindex)
{
    int i, j;
    unsigned reg_val = 0, lut_val = 0;

    // printf("Write LUT\n");

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

static inline uint64_t get_counter()
{
    uint64_t counter;
    asm volatile("li t0, 0;"
                 "csrr t0, mcycle;"
                 "mv %0, t0"
                 : "=r"(counter)
                 :
                 : "t0");
    return counter;
}
