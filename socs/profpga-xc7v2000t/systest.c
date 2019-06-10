
#ifdef __riscv
#include "uart.h"
#else
#include <stdio.h>
#endif

int main(int argc, char **argv)
{
#ifdef __riscv
	print_uart("Hello from ESP!\n");
#else
	printf("Hello from ESP!\n");
#endif

	return 0;
}
