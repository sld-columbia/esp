#include <stdio.h>
#include "defines.h"

/* Global arrays containing test results */
int report_test_array[MAX_N_CPU][N_IDS]; /* list of executed tests */
int report_fail_array[MAX_N_CPU][N_IDS]; /* info on execution errors occurred */

char report_test_string[N_IDS_TEST][MAX_REPORT_STRING] = {"Test     start : ",
							  "Leon3    test  : ",
							  "Reg      test  : ",
							  "Mul      test  : ",
							  "Div      test  : ",
							  "FPU      test  : ",
							  "Fill     test  : ",
							  "Sharing  test  : ",
							  "Rand RW  test  : ",
							  "Lock     test  : ",
							  "MESI     test  : ",
							  "MP end   test  : ",
							  "Test     end   : "};

char report_fail_string[N_IDS_FAIL][MAX_REPORT_STRING] = {"Reg      fail  : ",
							  "Mul      fail  : ",
							  "Div      fail  : ",
							  "FPU      fail  : ",
							  "Fill     fail  : ",
							  "Sharing  fail  : ",
							  "Rand RW  fail  : ",
							  "Lock     fail  : ",
							  "MESI     fail  : ",
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
