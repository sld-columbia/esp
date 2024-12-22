#include "leon3.h"
#include "testmod.h"
#include <math.h>
#include "defines.h"

int __errno;
fputest()
{
    int tmp;

    tmp = xgetpsr();
    setpsr(tmp | (1 << 12));
    tmp = xgetpsr();
    if (!(tmp & (1 << 12))) return (0);
    set_fsr(0);

    /* report_subtest(FPU_TEST+(get_pid()<<4)); */

    fpu_main();
}

extern fpu_pipe();
extern fpu_chkft();

fpu_main()
{
    volatile double a, c, d;
    double e;
    extern volatile double a1, b1, c1;
    float b;
    int tmp;

    d = 3.0;
    e = d;
    a = *(double *)&a1 - *(double *)&b1;
    if (a != c1) report_fail(FAIL_FPU);
    a = sqrt(e);
    if (fabs((a * a) - d) > 1E-15) report_fail(FAIL_FPU);
    b = sqrt(e);
    if (fabs((b * b) - d) > 1E-7) report_fail(FAIL_FPU);
    initfpreg();
    tmp = fpu_pipe();
    if (tmp) report_fail(FAIL_FPU);
    tmp = fpu_chkft();
    if (tmp) report_fail(FAIL_FPU);
    //	if (((get_asr17() >> 10) & 0x3C0003) == 1) grfpu_test();
}

float f1x       = -1.0;
double fmin1    = -1.0;
int fsr1[4]     = {0x80000000, 0, 0, 0};
double ftest[3] = {2.0, 3.0, 6.0};
