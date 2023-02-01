/* Copyright (c) 2011-2023 Columbia University, System Level Design Group */

#include <stdio.h>

#define SIZE 64

int main(int argc, char **argv)
{
    printf("Testing SLM tile with CPU writes/reads...\n\n");

    char* slm_base_0 = (char *) 0x04000000;
	for (int i = 0; i < SIZE; i++)
		slm_base_0[i] = i;

    int tot_errors = 0;
	int errors = 0;
	for (int i = 0; i < SIZE; i++)
		if (slm_base_0[i] != i)
			errors++;
	tot_errors += errors;
    if (errors)
		printf("char errors: %d\n", errors);

	short* slm_base_1 = (short *) 0x04001000;
	for (int i = 0; i < SIZE; i++)
		slm_base_1[i] = i;

	errors = 0;
	for (int i = 0; i < SIZE; i++)
		if (slm_base_1[i] != i)
			errors++;
	tot_errors += errors;
	if (errors)
		printf("short errors: %d\n", errors);

	int* slm_base_2 = (int *) 0x04002000;
	for (int i = 0; i < SIZE; i++)
		slm_base_2[i] = i;

	errors = 0;
	for (int i = 0; i < SIZE; i++)
		if (slm_base_2[i] != i)
			errors++;
	tot_errors += errors;
	if (errors)
		printf("int errors: %d\n", errors);

	long long* slm_base_3 = (long long *) 0x04003000;
	for (int i = 0; i < SIZE; i++)
		slm_base_3[i] = i;

	errors = 0;
	for (int i = 0; i < SIZE; i++)
		if (slm_base_3[i] != i)
			errors++;
	tot_errors += errors;
	if (errors)
		printf("ll errors: %d\n", errors);

	printf("Completed with %d errors\n", tot_errors);

    return 0;
}
