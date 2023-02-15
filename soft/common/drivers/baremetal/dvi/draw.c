// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include <stdio.h>

#define VRES 600
#define HRES 800

int main(int argc, char **argv)
{

	int i, j;
	volatile unsigned *mem = (unsigned *) 0x80000614;

	i = 0;
	for (i = 0; i < 600; i++)
		for (j = 0; j < 200; j++)
			mem[i * 200 + j] = 0;

	for (i = 0; i < 600; i++)
		for (j = 0; j < 200; j++) {
			if (j*4 > 600)
				mem[i * 200 + j] = 0x0;
			else if (i < (j*4 - 4) || i > (j*4 + 4))
				mem[i * 200 + j] = 0x0c0c0c0c;
			else
				mem[i * 200 + j] = 0xc4c4c4c4;
		}


	return 0;
}
