#include "testmod.h"

base_test()
{
        /* if (!get_pid()) mem_test(); */
        leon3_test(1, 0x80000200, 0);
        /* irqtest(0x80000200); */
        /* gptimer_test(0x80000300, 8); */
        /* apbuart_test(0x80000100); */
}

base_test_tirq(int irq)
{
        if (!get_pid()) mem_test();
	leon3_test(1, 0x80000200, 0);
	irqtest(0x80000200);
	gptimer_test(0x80000300, irq);
	apbuart_test(0x80000100);
}
