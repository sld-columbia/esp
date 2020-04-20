#include "testmod.h"
#include "defines.h"
#include "stdio.h"

/* void (*mpfunc[16])(int index); */

/* Decide between GRLIB tests or the ESP multi-core extension to the GRLIB tests */
/* - Set to 0 for GRLIB tests */
/* - Set to 1 for ESP tests */
#define USE_ESP_TESTS 0

leon3_test(int domp, int *irqmp, int mtest)
{
    int tmp, i;
    int pid = get_pid();
    
    int ncpu = (((*(irqmp + 0x10/4)) >> 28) & 0x0f) + 1;

    if (!pid) printf("Start testing on %d CPUs.\n", ncpu);
    
    if (!pid) report_init();

    if (domp)
        mptest_start(irqmp);

    test_loop_start();
    
    psync(sync_leon3_test, pid, ncpu);
    report_test(TEST_LEON3);

    /* TESTS */
    /* Uncomment the tests you want to execute. */
    
    /* report_test(TEST_REG); */
    /* if (regtest()) report_fail(FAIL_REG); */

    report_test(TEST_MUL);
    multest();
    if (!pid) printf("Finished multest.\n");

    report_test(TEST_DIV);
    divtest();
    if (!pid) printf("Finished divtest.\n");

    /* //report_test(TEST_FPU); */
    /* //fputest(); */

    if (!pid) data_structures_setup();

    report_test(TEST_FILL_B);
    cache_fill(4, ncpu, BYTE);
    if (!pid) printf("Finished cache_fill with BYTE granularity.\n");
    report_test(TEST_FILL_HW);
    cache_fill(4, ncpu, HALFWORD);
    if (!pid) printf("Finished cache_fill with HALFWORD granularity.\n");
    report_test(TEST_FILL_W);
    cache_fill(4, ncpu, WORD);
    if (!pid) printf("Finished cache_fill with WORD granularity.\n");
    
    report_test(TEST_SHARING);
    false_sharing(20, ncpu);

    /* report_test(TEST_LEON3); */
    /* l2_cache_test(domp, irqmp); */

    report_test(TEST_LOCK);
    test_lock(100, ncpu);
    if (!pid) printf("Finished test_lock.\n");

    report_test(TEST_MESI);
    mesi_test(ncpu, 1);
    if (!pid) printf("Finished mesi_test.\n");

    report_test(TEST_RAND_RW);
    rand_rw(200, ncpu);
    if (!pid) printf("Finished rand_rw.\n");
    
    /* End of TESTS */
    
    test_loop_end();
    
    if (domp)
        mptest_end(irqmp);

    /* Other TESTS */
    /* Uncomment the tests you want to execute. */

    /* grfpu_test(); */
    /* cachetest(); */
    /* mmu_test(); */
    /* rextest(); */
    /* awptest(); */

    /* End of other TESTS */

    printf("Parse and print report\n");
    
    report_parse(ncpu);

    printf("Test complete.\n");
}
