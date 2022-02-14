#include "uart.h"

int main()
{
	__asm__ volatile(
		"csrr a0, mhartid;"
		"bne a0, x0, 1f");

	init_uart();

	// jump to the address
	__asm__ volatile(
		"1:"
		"li s0, 0x80000000;"
		"la a1, _dtb;"
		"jr s0");

	while (1)
	{
		// do nothing
	}
}

void handle_trap(void)
{

}
