#include <stdlib.h>
#include <stdio.h>
#include "defines.h"

void data_structures_setup()
{
    int i;

    /* Setup for cache_fill() */
    for (i = 0; i < MAX_N_CPU; i++) {
	cache_fill_matrix[i] = (int *) malloc(SETS * L2_WAYS * LINE_SIZE * 2);
    }
}
