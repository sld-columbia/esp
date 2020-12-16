#include <stdio.h>
#include "defines.h"
#include <math.h>

#if SPINLOCK

#define DO_LOCK   arch_spin_lock(&lock)
#define DO_UNLOCK arch_spin_unlock(&lock)

#elif SEMAPHORE

#define DO_LOCK   do {sem = get_sem();} while (sem)
#define DO_UNLOCK ret_sem()

#endif

int mesi_test(int ncpu, int loops)
{
    int i, j, sem;
    int pid = get_pid();
    int data;
    int *ptr = cache_fill_matrix[0];
    int set_offset = 1 << (int) log2(WORDS_PER_LINE);

    for (j = 0; j < loops * set_offset; j += set_offset)
    {
	evict(ptr, j, L2_WAYS, L2_CACHE_WORDS, BYTE);

	i = 0;

	for (i = 0; i < ncpu; i++)
	{
	    /* sync point */
	    psync(sync_mesi1, pid, ncpu);

	    /* I -> E -> M */
	    if(pid == i)
	    {
		DO_LOCK;
		data = ptr[j];
		ptr[j] = 0xAA;
		DO_UNLOCK;
	    }

	    /* sync point */
	    psync(sync_mesi2, pid, ncpu);
	    sync_mesi1[pid] = 0;

	    /* I -> S and M -> S */
	    if(pid != i)
	    {
		if (ptr[j] != 0xAA) {
		    DO_LOCK;
		    printf("Lock fail 1, cpu %d\n", pid);
		    DO_UNLOCK;
		    return 1;
		}
	    }

	    /* sync point */
	    psync(sync_mesi3, pid, ncpu);
	    sync_mesi2[pid] = 0;

	    /* S -> I and S -> M */
	    DO_LOCK;
	    ptr[j] = 0x55;
	    DO_UNLOCK;

	    /* M -> I */
	    evict(ptr, j, L2_WAYS, L2_CACHE_WORDS, BYTE);

	    /* sync point */
	    psync(sync_mesi1, pid, ncpu);
	    sync_mesi3[pid] = 0;

	    /* check evicted word and E -> S */
	    DO_LOCK;
	    if (ptr[j] != 0x55) {
		printf("Lock fail 2, cpu %d\n", pid);
		DO_UNLOCK;
		return 1;
	    }
	    DO_UNLOCK;

	    /* sync point */
	    psync(sync_mesi2, pid, ncpu);
	    sync_mesi1[pid] = 0;

	    /* S -> M and S -> I */
	    if(pid == i) {
		DO_LOCK;
		ptr[j] = 0xBB;
		evict(ptr, j, L2_WAYS, L2_CACHE_WORDS, BYTE);
		ptr[j] = 0x55;
		DO_UNLOCK;
	    }

	    /* sync point */
	    psync(sync_mesi3, pid, ncpu);
	    sync_mesi2[pid] = 0;

	    if (pid != i) {
		DO_LOCK;
		ptr[j] = 0xAA;
		DO_UNLOCK;
	    }

	    DO_LOCK;
	    evict(ptr, j, L2_WAYS, L2_CACHE_WORDS, BYTE);
	    DO_UNLOCK;

	    /* sync point */
	    psync(sync_mesi1, pid, ncpu);
	    sync_mesi3[pid] = 0;

	    if(ptr[j] != 0xAA) {
		DO_LOCK;
		printf("Lock fail 3, cpu %d\n", pid);
		DO_UNLOCK;
		return 1;
	    }
    	}
    }

    return 0;
}
