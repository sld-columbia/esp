#include <stdlib.h>
#include <stdio.h>
#include <defines.h>

int cache_fill(int ways, int ncpu, int size)
{
    int i, sem;
    int cache_size, no_of_ints;
    int pid = get_pid();
    int *mem_ptr_int;
    short *mem_ptr_short;
    char *mem_ptr_char;

    cache_size = SETS * ways * LINE_SIZE;

    if (size == BYTE) {

	psync(sync_cache_fill_bytes, pid, ncpu);

	no_of_ints = cache_size;
	mem_ptr_char = (char *) cache_fill_matrix[pid];

	/* Fill the whole cache */
	for (i = 0; i < no_of_ints * 2; i++)
	    mem_ptr_char[i] = (char) ((pid + 10 + (unsigned int) &mem_ptr_char[i]) % 0x100);

	/* Read all values written */
	for (i = 0; i < no_of_ints * 2; i++) {
	    if (mem_ptr_char[i] !=  (char) ((pid + 10 + (unsigned int) &mem_ptr_char[i]) % 0x100)) {
		report_fail(FAIL_FILL_B);
	    }
	}

    } else if (size == HALFWORD) {

	psync(sync_cache_fill_halfwords, pid, ncpu);

	no_of_ints = cache_size / sizeof(short);
	mem_ptr_short = (short *) cache_fill_matrix[pid];

	/* Fill the whole cache */
	for (i = 0; i < no_of_ints * 2; i++)
	    mem_ptr_short[i] = (short) ((pid + 11 + (unsigned int) &mem_ptr_short[i]) % 0x10000);

	/* Read all values written */
	for (i = 0; i < no_of_ints * 2; i++) {
	    if (mem_ptr_short[i] !=  (short) ((pid + 11 + (unsigned int) &mem_ptr_short[i]) % 0x10000)) {
		report_fail(FAIL_FILL_HW);
	    }
	}

    } else if (size == WORD) {

	psync(sync_cache_fill_words, pid, ncpu);

	no_of_ints = cache_size / sizeof(int);
	mem_ptr_int = (int *) cache_fill_matrix[pid];

	/* Fill the whole cache */
	for (i = 0; i < no_of_ints * 2; i++)
	    mem_ptr_int[i] = pid + 12 + (int) &mem_ptr_int[i];

	/* Read all values written */
	for (i = 0; i < no_of_ints * 2; i++) {
	    if (mem_ptr_int[i] !=  pid + 12 + (int) &mem_ptr_int[i]) {
		report_fail(FAIL_FILL_W);
	    }
	}
    }

    return 0;
}
