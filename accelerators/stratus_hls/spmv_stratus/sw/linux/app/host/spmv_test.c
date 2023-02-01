// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
//http://www.cs.berkeley.edu/~mhoemmen/matrix-seminar/slides/UCB_sparse_tutorial_1.pdf
#include "spmv.h"

#define ran (TYPE)(((double) rand() / (MAX)) * (MAX-MIN) + MIN)

void fillVal(TYPE A[NNZ]){
	int j;
    srand48(8650341L);
	for (j = 0; j < NNZ; j++){
		A[j] = ran;
	}
}

void fill(TYPE x[N])
{
	int j;
    srand48(8650341L);
	for (j = 0; j < N; j++)
	{
		x[j] = ran;
	}
}

void initMat(int colind[NNZ], int rowDelimiters[N + 1])
{
	int nnzAssigned = 0;
	float prob = (float)NNZ / ((float)N * (float)N);

	srand48(8675307L);
	int fillRemaining = 0;
	int i, j;
	for (i = 0; i < N; i++)
	{
		rowDelimiters[i] = nnzAssigned;
		for (j = 0; j < N; j++)
		{
			int numEntriesLeft = (N * N) - ((i * N) + j);
			int needToAssign   = NNZ - nnzAssigned;
			if (numEntriesLeft <= needToAssign) {
				fillRemaining = 1;
			}
			if ((nnzAssigned < NNZ && drand48() <= prob) || fillRemaining == 1)
			{
				colind[nnzAssigned] = j;
				nnzAssigned++;
			}
		}
	}
	rowDelimiters[N] = NNZ;
}

void initOut(TYPE y[N]){
    int i;
    for (i=0; i<N; i++){
        y[i] = 0;
    }
}

int main(){
    TYPE nzval[NNZ];
    TYPE x[N];
    TYPE y[N];
    int colind[NNZ];
    int rowptr[N+1]; 
    int i;

    srand48(8650341L);

	fillVal(nzval);
	fill(x);
    initMat(colind, rowptr);
    initOut(y);
    
	spmv(nzval, colind, rowptr, x, y);

	printf("\n");
	for(i = 0; i < N; i++){
		printf("%d ", y[i]);
	}
	printf("\n");

	return 0;
}
