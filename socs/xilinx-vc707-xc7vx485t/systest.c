// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include <stdio.h>

int main(int argc, char **argv)
{
	printf("Hello from ESP!\n");

        int *x = (int *) 0x8004e110;
        int *y = (int *) ((unsigned long) x | (1L << 33));
        printf("1: %x at %lx\n", *x, (unsigned long) x);
        printf("2: %x at %lx\n", *y, (unsigned long) y);

        *x = 0xff00ff00;

        printf("3: %x at %lx\n", *x, (unsigned long) x);
        printf("4: %x at %lx\n", *y, (unsigned long) y);
        
        *y = 0x00ff00ff;

        printf("5: %x at %lx\n", *x, (unsigned long) x);
        printf("6: %x at %lx\n", *y, (unsigned long) y);

	return 0;
}
