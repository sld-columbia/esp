#ifndef _HIST_H
#define _HIST_H

#include "defs.h"
/**
 *  nBpp = Number of Bits per pixel
 */

int hist(int *streamA, int *h, int nRows, int nCols, int nBpp);
int histEq(int *streamA, int *out, int *h, int nRows, int nCols, int nInpBpp, int nOutBpp);

int hist(int *stream, int *h, int n_rows, int n_cols, int n_in_bits_pp)
{
	int nBins = 1 << n_in_bits_pp;
	int nPxls = n_rows * n_cols;
	int i = 0;

	if (h == (int *)NULL)
	{
		fprintf(stderr, "File %s, Line %d, Memory Allocation Error\n", __FILE__, __LINE__);
		return -1;
	}

	memset((void *)h, 0, nBins * sizeof(int));

	for (i = 0; i < nPxls; i++)
	{
		if (stream[i] >= nBins)
		{
			fprintf(stderr, "File %s, Line %d, Range Error in hist() -- using max val ---", __FILE__, __LINE__);
			h[nBins-1]++;
		}
		else
		{
			h[(int)stream[i]]++;
		}
	}

	return 0;
}

int histEq(int *stream, int *out, int *h, int n_rows, int n_cols, int n_in_bits_pp, int n_out_bits_pp)
{
	int nOutBins = (1 << n_out_bits_pp);
	int nInpBins = (1 << n_in_bits_pp);
	int *CDF = (int *)calloc(nInpBins, sizeof(int));
	int *LUT = (int *)calloc(nInpBins, sizeof(int));

	if (!(CDF && LUT))
    {	
		free(CDF);
		free(LUT);
		fprintf(stderr, "File %s, Line %d, Memory Allocation Error\n", __FILE__, __LINE__);
		return -1;
	}

	int CDFmin = INT_MAX;
	int sum = 0;
	int nPxls = n_rows * n_cols;
	int i = 0;

	for (i = 0; i < nInpBins; i++)
	{
		sum += h[i];
		CDF[i] = sum;
	}

	for (i = 0; i < nInpBins; i++)
	{
		CDFmin = MIN(CDFmin, h[i]);
	}

	for (i = 0; i < nInpBins; i++)
	{
		LUT[i] = ((CDF[i] - CDFmin) * (nOutBins - 1)) / (nPxls - CDFmin);
	}

	for (i = 0; i < nPxls; i++)
	{
		out[i] = LUT[(int)stream[i]];
	}

	free(CDF);
	free(LUT);

	return 0;
}

#endif //_HIST_H
