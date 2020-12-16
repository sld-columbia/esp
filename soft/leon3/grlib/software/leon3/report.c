#include <stdio.h>
#include "defines.h"

/* Global synchronization array */
volatile int sync_loop_start[MAX_N_CPU] = {0, 0, 0, 1};

/* Global arrays containing test results */
int report_test_array[MAX_N_CPU][N_IDS]; /* list of executed tests */
int report_fail_array[MAX_N_CPU][N_IDS]; /* info on execution errors occurred */

char report_test_string[N_IDS_TEST][MAX_REPORT_STRING] = {"Test     start : ",
							  "Leon3    test  : ",
							  "Reg      test  : ",
							  "Mul      test  : ",
							  "Div      test  : ",
							  "FPU      test  : ",
							  "Fill B   test  : ",
							  "Sharing  test  : ",
							  "L2       test  : ",
							  "Rand RW  test  : ",
							  "Fill HW  test  : ",
							  "MESI     test  : ",
							  "Lock     test  : ",
							  "Fill W   test  : ",
							  "Test     end   : "};

char report_fail_string[N_IDS_FAIL][MAX_REPORT_STRING] = {"Reg      fail  : ",
							  "Mul      fail  : ",
							  "Div      fail  : ",
							  "FPU      fail  : ",
							  "Fill B   fail  : ",
							  "Sharing  fail  : ",
							  "Rand RW  fail  : ",
							  "Fill HW  fail  : ",
							  "MESI     fail  : ",
							  "Lock     fail  : ",
							  "Fill W   fail  : ",
							  "MP       fail  : "};

void report_init()
{
    int i, j;

    for (i = 0; i < MAX_N_CPU; i++) {
	for (j = 0; j < N_IDS; j++) {
	    report_test_array[i][j] = 0;
	    report_fail_array[i][j] = 0;
	}
    }
}

void report(int array_type, int report_id)
{
    if (array_type == TEST)
	report_test_array[get_pid()][report_id] = 1;
    else
	report_fail_array[get_pid()][report_id] = 1;
}

void report_test(int report_id)
{
    report(TEST, report_id);
}

void report_fail(int report_id)
{
    report(FAIL, report_id);
}

void report_parse(int ncpu)
{
    int i, j;
    int error_cnt = 0;

    /* Only CPU0 can reach this point */

    printf("\n*** Test flow: ***\n");

    for (j = 0; j < N_IDS_TEST; j++) {

	printf("%s", report_test_string[j]);

	for (i = 0; i < ncpu; i++)
	    if (report_test_array[i][j])
		printf("cpu%d ", i);

	printf("\n");
    }

    printf("\n*** Fails: ***\n");

    for (j = 0; j < N_IDS_FAIL; j++) {

	printf("%s", report_fail_string[j]);

	for (i = 0; i < ncpu; i++) {
	    if (report_fail_array[i][j]) {
		printf("cpu%d ", i);
		error_cnt++;
	    }
	}

	printf("\n");
    }

    printf("\nSimulation terminated with %d fails.\n\n", error_cnt);
}

void test_loop_start()
{
    int i;
    int * irqmp_ptr = (int *) 0x80000200;
    int ncpu = (((*(irqmp_ptr + 0x10/4)) >> 28) & 0x0f) + 1;
    int pid = get_pid();

    if (!pid) {
	for (i = 0; i < MAX_N_CPU; i++) {
	    sync_leon3_test[i] = 0;
	    sync_cache_fill_bytes[i] = 0;
	    sync_cache_fill_halfwords[i] = 0;
	    sync_cache_fill_words[i] = 0;
	    sync_false_sharing1[i] = 0;
	    sync_false_sharing2[i] = 0;
	    sync_rand_rw[i] = 0;
	    sync_mesi1[i] = 0;
	    sync_mesi2[i] = 0;
	    sync_mesi3[i] = 0;
	    sync_lock1[i] = 0;
	    sync_lock2[i] = 0;
	    sync_loop_end[i] = 0;
	}
    }

    psync(sync_loop_start, pid, ncpu);

    report_test(TEST_START);
}

void test_loop_end()
{
    int i;
    int * irqmp_ptr = (int *) 0x80000200;
    int ncpu = (((*(irqmp_ptr + 0x10/4)) >> 28) & 0x0f) + 1;
    int pid = get_pid();

    if (!pid) {
	for (i = 0; i < MAX_N_CPU; i++) {
	    sync_loop_start[i] = 0;
	}
    }

    psync(sync_loop_end, pid, ncpu);

    report_test(TEST_END);
}
