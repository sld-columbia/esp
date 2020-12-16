#include <stdio.h>
#include <stdlib.h>
#include <defines.h>


int rand_rw(int words, int ncpu) // words < 256
{
    unsigned int set;
    int i, sem, offset, cnt = 0;
    int pid = get_pid();

    psync(sync_rand_rw, pid, ncpu);

    /* srand(1); */

/* #if INT */

    int *ptr = cache_fill_matrix[pid];

    /* int max_range = L2_CACHE_WORDS * 2; */

/* #elif HALFWORD */

/*     short *ptr = (short *) cache_fill_matrix[pid]; */

/*     int max_range = L2_CACHE_WORDS * 4; */

/* #elif BYTE */

/*     char *ptr = (char *) cache_fill_matrix[pid]; */

/*     int max_range = L2_CACHE_BYTES * 2; */

/* #endif */

    for (i = 0; i < words; i++) {

	offset = i * 4 ; // rand() % 256;

	ptr[offset] = i + pid + (int) &ptr[offset];

	evict(ptr, offset, L2_WAYS, 0, WORD);

	if (ptr[offset] != i + pid + (int) &ptr[offset]) {

	    report_fail(FAIL_RAND_RW);

	    do {sem = get_sem();} while (sem);
	    printf("Rand RW fail cpu%d!\n", pid);
	    ret_sem();

	    return 1;
	}
    }

    return 0;
}
