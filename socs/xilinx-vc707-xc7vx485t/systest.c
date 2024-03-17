// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include <stdio.h>

int main(int argc, char **argv)
{
	printf("Hello from ESP!\n");

        int *x = (int *) (1L << 33);
        printf("Here: %x at %lx\n", *x, (unsigned long) x);

	return 0;
}
