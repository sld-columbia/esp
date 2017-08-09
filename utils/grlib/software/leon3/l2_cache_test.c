#include "testmod.h"

#define ARRAY_SIZE 64
#define BASE_WORD 0x12345680
#define BASE_HWORD 0x8980
#define BASE_BYTE 0x80

void write_words_test(int dev)
{
    report_subtest(dev);

    unsigned int array[ARRAY_SIZE];
    int i;

    for (i = 0; i < ARRAY_SIZE; i++) {
	array[i] = BASE_WORD;
    }

    flush();

    for (i = 0; i < ARRAY_SIZE; i++) {
	array[i] = BASE_WORD + i + 1;
    }

    flush();

    for (i = 0; i < ARRAY_SIZE; i++) {
	if (array[i] != BASE_WORD + i + 1) {
	    fail(dev + i + 1);
	}
    }

    flush();
}

void write_hwords_test(int dev)
{
    report_subtest(dev);

    unsigned short array[ARRAY_SIZE];
    int i;

    for (i = 0; i < ARRAY_SIZE; i++) {
	array[i] = BASE_HWORD;
    }

    flush();

    for (i = 0; i < ARRAY_SIZE; i++) {
	array[i] = BASE_HWORD + i + 1;
    }

    for (i = 0; i < ARRAY_SIZE; i++) {
	if (array[i] != BASE_HWORD + i + 1) {
	    fail(dev + i + 1);
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

    flush();

    for (i = 0; i < ARRAY_SIZE; i++) {
	if (array[i] != BASE_BYTE + i + 1) {
	    fail(dev + i + 1);
	}
    }

    flush();
}

void l2_cache_test(int domp, volatile int* irqmp)
{
    init_report();

    report_start();
    report_device(0xcace0000);

    write_words_test(0xcace1000);
    write_hwords_test(0xcace2000);
    write_bytes_test(0xcace3000);

    report_end();

    read_report();

    /* if (!get_pid()) report_device(0x00000000); */
    /* if (domp) mptest_start(irqmp);	 */
    /* if (domp) mptest_end(irqmp);	 */
}
