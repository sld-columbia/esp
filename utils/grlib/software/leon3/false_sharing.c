#include <stdio.h>
#include <defines.h>
#include <math.h>

int false_sharing(int lines, int ncpu)
{
    int i, j, sem;
    int pid = get_pid();
    int *mem_ptr = cache_fill_matrix[0];

    psync(sync_false_sharing1, pid, ncpu);

    for (i = 0; i < lines; i++) {
	j = i * WORDS_PER_LINE + pid;
	mem_ptr[j] = pid + 5 + (int) &mem_ptr[j];
    }

    psync(sync_false_sharing2, pid, ncpu);

    for (i = 0; i < lines; i++) {
	j = i * WORDS_PER_LINE + pid;
	if (mem_ptr[j] != pid + 5 + (int) &mem_ptr[j]) {
	    report_fail(FAIL_SHARING);

	    do {sem = get_sem();} while (sem);
	    printf("Sharing fail cpu%d!\n", pid);
	    ret_sem();

	    return 1;
	}
    }

    return 0;
}
