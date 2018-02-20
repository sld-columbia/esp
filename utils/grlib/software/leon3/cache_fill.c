#include <stdlib.h>
#include <stdio.h>
#include <defines.h>

volatile int sync_cache_fill1[MAX_N_CPU] = {0, 0, 0, 0};
volatile int sync_cache_fill2[MAX_N_CPU] = {0, 0, 0, 0};

int cache_fill(int ways, int ncpu)
{
    int i, sem;
    int cache_size, no_of_ints;
    int pid = get_pid();

    psync(sync_cache_fill1, pid, ncpu);

    cache_size = SETS * ways * LINE_SIZE;

/* #if INT */

    int *mem_ptr;

    no_of_ints = cache_size / sizeof(int);

    mem_ptr = (int *) cache_fill_matrix[pid];

/* #elif HALFWORD */

/*     short *mem_ptr; */

/*     no_of_ints = cache_size / sizeof(short); */

/*     mem_ptr = (short *) cache_fill_matrix[pid]; */

/* #elif BYTE */

/*     char *mem_ptr; */

/*     no_of_ints = cache_size; */

/*     mem_ptr = (char *) cache_fill_matrix[pid]; */

/* #endif */

    /* Fill the whole cache */
    for (i = 0; i < no_of_ints * 2; i++)
	mem_ptr[i] = pid + 10 + (int) &mem_ptr[i];

    /* Read all values written */
    for (i = 0; i < no_of_ints * 2; i++) {
	if (mem_ptr[i] !=  pid + 10 + (int) &mem_ptr[i]) {
	    report_fail(FAIL_FILL);

	    /* do {sem = get_sem();} while (sem); */
	    /* printf("Fill fail cpu%d!\n", pid); */
	    /* ret_sem(); */

	    /* return 1; */
	}
    }

    psync(sync_cache_fill2, pid, ncpu);

    return 0;
}
