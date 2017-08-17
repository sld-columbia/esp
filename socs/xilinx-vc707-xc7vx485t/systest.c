#include <stdio.h>

int main(int argc, char **argv)
{
    flush();

    printf("Hello ESP!\n");

    l2_cache_test();
    read_report();

    leon3_test(0, 0x80000200, 1);
    read_report();

    return 0;
}
