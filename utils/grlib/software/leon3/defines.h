#ifndef __DEFINES_H__
#define __DEFINES_H__

/* Cache parameters */
#define SETS 512
#define L2_WAYS 4
// #define N_CPU 4
#define MAX_N_CPU 4
//#define LLC_WAYS CPUS*L2_WAYS
// #define LLC_WAYS (MAX_N_CPU * L2_WAYS)
#define LINE_SIZE 16
#define BYTES_PER_WORD 4
#define WORDS_PER_LINE 4
#define ASI_LEON_DFLUSH 0x11
#define WORD_SIZE 32 /* Assuming words of 32 bits */
#define L2_CACHE_BYTES (SETS * L2_WAYS * LINE_SIZE)
#define L2_CACHE_WORDS (L2_CACHE_BYTES / BYTES_PER_WORD)

#define TAG_OFFSET 13
#define SET_OFFSET 4
#define WORD_OFFSET 2
#define BYTE_OFFSET 0

/* Test features */
#define SPINLOCK 0
#define SEMAPHORE 1

#define WORD 0
#define HALFWORD 1
#define BYTE 2

/* Address map */
#define BASE_CACHEABLE_ADDRESS 0X45000000
#define LAST_CACHEABLE_ADDRESS 0X4FFFFFFF

/*
 * Test report
 */
#define TEST 0
#define FAIL 1

#define N_IDS_TEST 15
#define N_IDS_FAIL 12
#define N_IDS (N_IDS_TEST > N_IDS_FAIL ? N_IDS_TEST : N_IDS_FAIL)

#define MAX_REPORT_STRING 18

/* Test IDs (max 32, which is the word size) */
#define TEST_START 0
#define TEST_LEON3 1
#define TEST_REG 2
#define TEST_MUL 3
#define TEST_DIV 4
#define TEST_FPU 5
#define TEST_FILL_B 6
#define TEST_SHARING 7
#define TEST_L2 8
#define TEST_RAND_RW 9
#define TEST_FILL_HW 10
#define TEST_MESI 11
#define TEST_LOCK 12
#define TEST_FILL_W 13
#define TEST_END 14

/* Fail IDs (max 32, which is the word size) */
#define FAIL_REG 0
#define FAIL_MUL 1
#define FAIL_DIV 2
#define FAIL_FPU 3
#define FAIL_FILL_B 4
#define FAIL_SHARING 5
#define FAIL_RAND_RW 6
#define FAIL_FILL_HW 7
#define FAIL_MESI 8
#define FAIL_LOCK 9
#define FAIL_FILL_W 10
#define FAIL_MPTEST 11

/* Report functions */
extern void report_init();
extern void report_test();
extern void report_fail();
extern void report_parse();
extern void test_loop_start();
extern void test_loop_end();
/* Data structures */
int *cache_fill_matrix[MAX_N_CPU];

typedef volatile unsigned int arch_spinlock_t;
arch_spinlock_t lock;

/* Sync arrays */
volatile int sync_loop_end[MAX_N_CPU]; // = {0, 0, 0, 0};
volatile int sync_leon3_test[MAX_N_CPU]; // = {0, 0, 0, 0};
volatile int sync_cache_fill_bytes[MAX_N_CPU]; // = {0, 0, 0, 0};
volatile int sync_cache_fill_halfwords[MAX_N_CPU]; // = {0, 0, 0, 0};
volatile int sync_cache_fill_words[MAX_N_CPU]; // = {0, 0, 0, 0};
volatile int sync_false_sharing1[MAX_N_CPU]; // = {0, 0, 0, 0};
volatile int sync_false_sharing2[MAX_N_CPU]; // = {0, 0, 0, 0};
volatile int sync_rand_rw[MAX_N_CPU]; // = {0, 0, 0, 0};
volatile int sync_mesi1[MAX_N_CPU]; // = {0, 0, 0, 0};
volatile int sync_mesi2[MAX_N_CPU]; // = {0, 0, 0, 0};
volatile int sync_mesi3[MAX_N_CPU]; // = {0, 0, 0, 0};
volatile int sync_lock1[MAX_N_CPU]; // = {0, 0, 0, 0};
volatile int sync_lock2[MAX_N_CPU]; // = {0, 0, 0, 0};

/* Leon3 constants */
#define ASI_LEON_DFLUSH 0x11

#endif /* __DEFINES_H__ */
