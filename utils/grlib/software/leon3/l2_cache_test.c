#include "testmod.h"

void write_array_test(int dev)
{
    report_subtest(dev);

    int array[16];
    int i;

    for (i = 0; i < 16; i++) {
	array[i] = 0;
    }

    flush();

    for (i = 0; i < 16; i++) {
	array[i] = i + 1;
    }

    flush();

    for (i = 0; i < 16; i++) {
	if (array[i] != i + 1) {
	    fail(dev);
	}
    }

    flush();

    read_report();
}

void l2_cache_test(int domp, volatile int* irqmp)
{
    report_start();
    report_device(0xcac8e000);

    write_array_test(0xcac8e100);

    report_end();

    /* if (!get_pid()) report_device(0x00000000); */
    /* if (domp) mptest_start(irqmp);	 */
    /* if (domp) mptest_end(irqmp);	 */
}
