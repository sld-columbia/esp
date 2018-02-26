#include <stdio.h>
#include "defines.h"

/* Test suite guidelines:
 * - All function names containing the word 'report' set the related flag in an array, that will be
 *   parsed at the end of the execution to verify the correctness of the execution. Those the
 *   additionally contain the word 'fail' will report in the same way execution errors.
 * - Assuming words of 32 bits.
 */

volatile int sync_start[MAX_N_CPU] = {0, 0, 0, 1};

int main()
{
    int i;
    int * irqmp_ptr = (int *) 0x80000200;
    int ncpu = (((*(irqmp_ptr + 0x10/4)) >> 28) & 0x0f) + 1;
    int pid = get_pid();

    /* Start all CPUs */
    if (!pid)
	mptest_start(0x80000200);

    for (i = 0; i < MAX_N_CPU; i++) {
	sync_loop_start[i] = 0;
    }

    /* Initialize the report arrays */
    /* Report the start of the whole test */
    psync(sync_start, pid, ncpu);

    if (!pid) {
	report_init();
	report_test(TEST_START);
	data_structures_setup();
    }

    for (i = 0; i < 100; i++) {

	test_loop_start();

	/* Execute part of the original grlib tests.  */
	report_test(TEST_LEON3);
	leon3_test(1, 0x80000200, 0, ncpu);

	/* Completely fill and evict all caches (bytes) */
	report_test(TEST_FILL_B);
	cache_fill(L2_WAYS, ncpu, BYTE);

	/* Test false sharing */
	report_test(TEST_SHARING);
	false_sharing(SETS, ncpu);

	/* Test some random read and write operations */
	report_test(TEST_RAND_RW);
	rand_rw(SETS, ncpu); // select INT, HALFWORD and BYTE in defines.h

	/* Completely fill and evict all caches (halfwords) */
	report_test(TEST_FILL_HW);
	cache_fill(L2_WAYS, ncpu, HALFWORD);

	/* Test MESI protocol */
	report_test(TEST_MESI);
	if (mesi_test(ncpu, 100))
	    report_fail(FAIL_MESI);

	/* Test some random read and write operations */
	report_test(TEST_LOCK);
	test_lock(10, ncpu); // select INT, HALFWORD and BYTE in defines.h

	/* Completely fill and evict all caches (words) */
	report_test(TEST_FILL_W);
	cache_fill(L2_WAYS, ncpu, WORD);

	test_loop_end();
    }

    /* Test MP and turn off all CPUs but one */
    report_test(TEST_MP_END);
    mptest_end(0x80000200);

    /* Report the end of the whole test */
    report_test(TEST_END);

    /* Printout results */
    report_parse(ncpu);

    return 0;
}
