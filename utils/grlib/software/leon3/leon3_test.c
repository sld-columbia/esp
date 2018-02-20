#include "testmod.h"
#include "defines.h"

/* void (*mpfunc[16])(int index); */

leon3_test(int domp, int *irqmp, int mtest)
{
    int tmp, i;

    /* if (domp) */
    /*     mptest_start(irqmp); */

    report_test(TEST_REG);
    if (regtest()) report_fail(FAIL_REG);

    report_test(TEST_MUL);
    multest();

    report_test(TEST_DIV);
    divtest();

    report_test(TEST_FPU);
    fputest();

    /* if (mtest) cramtest(); */
    /* if ((*mpfunc[get_pid()])) mpfunc[get_pid()](get_pid()); */

    /* if (domp) */
    /*     mptest_end(irqmp); */

    /* grfpu_test(); */
    /* cachetest(); */
    /* mmu_test(); */
    /* rextest(); */
    /* awptest(); */
}
