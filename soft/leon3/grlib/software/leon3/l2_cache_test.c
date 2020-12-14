#include "testmod.h"

#define ARRAY_SIZE 64
#define BASE_WORD 0x12345680
#define BASE_HWORD 0x8980
#define BASE_BYTE 0x80
#define WHOLE_TEST_SIZE 8000

void write_words_test(int dev)
{
    report_subtest(dev);

    unsigned int array[ARRAY_SIZE];
    int i;

    for (i = 0; i < ARRAY_SIZE; i++) {
	array[i] = BASE_WORD;
    }

    /* flush(); */

    for (i = 0; i < ARRAY_SIZE; i++) {
	array[i] = BASE_WORD + i + 1;
    }

    /* flush(); */

    for (i = 0; i < ARRAY_SIZE; i++) {
	if (array[i] != BASE_WORD + i + 1) {
	    my_fail(dev + i + 1);
	}
    }

    /* flush(); */
}

void write_hwords_test(int dev)
{
    report_subtest(dev);

    unsigned short array[ARRAY_SIZE];
    int i;

    for (i = 0; i < ARRAY_SIZE; i++) {
	array[i] = BASE_HWORD;
    }

    /* flush(); */

    for (i = 0; i < ARRAY_SIZE; i++) {
	array[i] = BASE_HWORD + i + 1;
    }

    for (i = 0; i < ARRAY_SIZE; i++) {
	if (array[i] != BASE_HWORD + i + 1) {
	    my_fail(dev + i + 1);
	}

    }
}

void write_bytes_test(int dev)
{
    report_subtest(dev);

    unsigned char array[ARRAY_SIZE];
    int i;

    for (i = 0; i < ARRAY_SIZE; i++) {
	array[i] = BASE_BYTE;
    }

    for (i = 0; i < ARRAY_SIZE; i++) {
	array[i] = BASE_BYTE + i + 1;
    }

    /* flush(); */

    for (i = 0; i < ARRAY_SIZE; i++) {
	if (array[i] != BASE_BYTE + i + 1) {
	    my_fail(dev + i + 1);
	}
    }
}

void write_mixed_test(int dev)
{
    report_subtest(dev);

    unsigned int ints[ARRAY_SIZE];
    unsigned short shorts[ARRAY_SIZE];
    unsigned char chars[ARRAY_SIZE];
    int i;

    for (i = 0; i < ARRAY_SIZE; i++) {
	ints[i] = BASE_WORD;
	shorts[i] = BASE_HWORD;
	chars[i] = BASE_BYTE;
    }

    /* flush(); */

    for (i = 0; i < ARRAY_SIZE; i++) {
	chars[i] = BASE_BYTE + i + 1;
	ints[i] = BASE_WORD + i + 1;
	shorts[i] = BASE_HWORD + i + 1;
    }

    for (i = 0; i < ARRAY_SIZE; i++) {
	if (shorts[i] != BASE_HWORD + i + 1)
	    my_fail(dev + i + 1);
	if (chars[i] != BASE_BYTE + i + 1)
	    my_fail(dev + i + 1);
	if (ints[i] != BASE_WORD + i + 1)
	    my_fail(dev + i + 1);
    }
}

void write_whole_test(int dev)
{
    report_subtest(dev);

    unsigned int ints[WHOLE_TEST_SIZE];
    int i;

    for (i = 0; i < WHOLE_TEST_SIZE; i++) {
	ints[i] = BASE_WORD + 1 + i;
    }

    /* flush(); */

    for (i = 0; i < WHOLE_TEST_SIZE; i++) {
	if (ints[i] != BASE_WORD + i + 1)
	    my_fail(dev + i + 1);
    }
}

void l2_cache_test(int domp, volatile int* irqmp)
{
    init_report();

    report_start();
    report_device(0xcace0000);

    write_words_test(0xcace1000);
    write_hwords_test(0xcace2000);
    write_bytes_test(0xcace3000);
    write_mixed_test(0xcace4000);
    write_whole_test(0xcace5000);
    report_end();

    flush();

    /* if (!get_pid()) report_device(0x00000000); */
    /* if (domp) mptest_start(irqmp);	 */
    /* if (domp) mptest_end(irqmp);	 */
}
