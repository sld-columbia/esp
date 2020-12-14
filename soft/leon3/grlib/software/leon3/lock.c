#include <stdio.h>
#include "defines.h"

int spinlock_cnt, sem_casa_cnt, sem_cnt;

inline void arch_spin_lock(arch_spinlock_t *lock)
{
    __asm__ __volatile__(
	"\n1:\n\t"
	"ldstub	[%0], %%g2\n\t"
	"orcc	%%g2, 0x0, %%g0\n\t"
	"bne,a	2f\n\t"
	" ldub	[%0], %%g2\n\t"
	".subsection	2\n"
	"2:\n\t"
	"orcc	%%g2, 0x0, %%g0\n\t"
	"bne,a	2b\n\t"
	" ldub	[%0], %%g2\n\t"
	"b,a	1b\n\t"
	".previous\n"
	: /* no outputs */
	: "r" (lock)
	: "g2", "memory", "cc");
}

inline void arch_spin_lock_and_flush(arch_spinlock_t *lock)
{
    __asm__ __volatile__(
	"\n1:\n\t"
	"sta %%g0, [%%g0] %1\n\t" /* Flush */
	"ldstub	[%0], %%g2\n\t"
	"sta %%g0, [%%g0] %1\n\t" /* Flush */
	"orcc	%%g2, 0x0, %%g0\n\t"
	"bne,a	2f\n\t"
	" ldub	[%0], %%g2\n\t"
	".subsection	2\n"
	"2:\n\t"
	"sta %%g0, [%%g0] %1\n\t" /* Flush */
	"orcc	%%g2, 0x0, %%g0\n\t"
	"bne,a	2b\n\t"
	" ldub	[%0], %%g2\n\t"
	"b,a	1b\n\t"
	".previous\n"
	: /* no outputs */
	: "r" (lock), "i"(ASI_LEON_DFLUSH)
	: "g2", "memory", "cc");
}

inline void arch_spin_lock_try(unsigned int retry, arch_spinlock_t *lock)
{
    __asm__ __volatile__(
	"\n1:\n\t"
	"ldstub	[%0], %%g2\n\t"
	"orcc	%%g2, 0x0, %%g0\n\t"
	"bne,a	2f\n\t"
	" ldub	[%0], %%g2\n\t"
	"3:\n\t"
	".subsection	2\n"
	"2:\n\t"
	"orcc	%%g2, 0x0, %%g0\n\t"
	"be	1b\n\t"
	" ldub	[%0], %%g2\n\t"
	"orcc	%1, 0x0, %%g0\n\t"
	"bne	2b\n\t"
	" sub	%1, 0x1, %1\n\t"
	"b,a	3b\n\t"
	".previous\n"
	: /* no outputs */
	: "r" (lock), "r" (retry), "i"(ASI_LEON_DFLUSH)
	: "g2", "memory", "cc");
}

inline void arch_spin_lock_try_and_flush(unsigned int retry, arch_spinlock_t *lock)
{
    __asm__ __volatile__(
	"\n1:\n\t"
	"sta %%g0, [%%g0] %2\n\t" /* Flush */
	"ldstub	[%0], %%g2\n\t"
	"sta %%g0, [%%g0] %2\n\t" /* Flush */
	"orcc	%%g2, 0x0, %%g0\n\t"
	"bne,a	2f\n\t"
	" ldub	[%0], %%g2\n\t"
	"3:\n\t"
	".subsection	2\n"
	"2:\n\t"
	"sta %%g0, [%%g0] %2\n\t" /* Flush */
	"orcc	%%g2, 0x0, %%g0\n\t"
	"be	1b\n\t"
	" ldub	[%0], %%g2\n\t"
	"orcc	%1, 0x0, %%g0\n\t"
	"bne	2b\n\t"
	" sub	%1, 0x1, %1\n\t"
	"b,a	3b\n\t"
	".previous\n"
	: /* no outputs */
	: "r" (lock), "r" (retry), "i"(ASI_LEON_DFLUSH)
	: "g2", "memory", "cc");
}

inline void arch_spin_unlock(arch_spinlock_t *lock)
{
    __asm__ __volatile__("stb %%g0, [%0]" : : "r" (lock) : "memory");
}

inline void arch_spin_unlock_and_flush(arch_spinlock_t *lock)
{
    __asm__ __volatile__(
	"\n1:\n\t"
	"sta %%g0, [%%g0] %1\n\t" /* Flush */
	"stb %%g0, [%0]\n\t"
	"sta %%g0, [%%g0] %1\n\t" /* Flush */
	: /* no outputs */
	: "r" (lock), "i"(ASI_LEON_DFLUSH)
	: "memory");
}

int test_lock(int loops, int ncpu)
{
    int i, sem, sem_casa, cnt;
    int pid = get_pid();

    if (!pid) {
	spinlock_cnt = 0;
	sem_casa_cnt = 0;
	sem_cnt = 0;
    }

    psync(sync_lock1, pid, ncpu);

    for (i = 0; i < loops; i++) {

	/* Regular spinlock */

	arch_spin_lock(&lock);

	spinlock_cnt++;

	arch_spin_unlock(&lock);

	/* Spinlock and multi-thread on single core emulation */

	arch_spin_lock(&lock);

	/* arch_spin_lock_try(10, &lock); */

	spinlock_cnt++;

	arch_spin_unlock(&lock);

	/* Spinlock and flush */

	arch_spin_lock_and_flush(&lock);

	spinlock_cnt++;

	arch_spin_unlock_and_flush(&lock);

	/* Casa lock */

	do {sem_casa = get_sem_casa();} while (sem_casa);

	sem_casa_cnt++;

	ret_sem_casa();

	/* Regular semaphore */

	do {sem = get_sem();} while (sem);

	sem_cnt++;

	ret_sem();

	/* Semaphore and multi-thread on single core emulation */

	do {sem = get_sem();} while (sem);

	cnt = 0;
	do {
	    sem = get_sem();
	    cnt++;
	} while (cnt < 10);

	sem_cnt++;

	ret_sem();
    }

    psync(sync_lock2, pid, ncpu);

    /* Check correctness of counters */
    if (!pid) {
	if ((spinlock_cnt != 3 * loops * ncpu) ||
	    (sem_cnt != 2 * loops * ncpu) ||
	    (sem_casa_cnt != loops * ncpu)) {

	    report_fail(FAIL_LOCK);

	    do {sem = get_sem();} while (sem);
	    printf("Lock test fail!\n");
	    ret_sem();

	    return 1;
	}
    }

    return 0;
}

