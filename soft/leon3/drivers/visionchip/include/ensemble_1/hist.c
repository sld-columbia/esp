/**************************/
/***    UNCLASSIFIED    ***/
/**************************/

/***

ALL SOURCE CODE PRESENT IN THIS FILE IS UNCLASSIFIED AND IS
BEING PROVIDED IN SUPPORT OF THE DARPA PERFECT PROGRAM.

THIS CODE IS PROVIDED AS-IS WITH NO WARRANTY, EXPRESSED, IMPLIED, 
OR OTHERWISE INFERRED. USE AND SUITABILITY FOR ANY PARTICULAR
APPLICATION IS SOLELY THE RESPONSIBILITY OF THE IMPLEMENTER. 
NO CLAIM OF SUITABILITY FOR ANY APPLICATION IS MADE.
USE OF THIS CODE FOR ANY APPLICATION RELEASES THE AUTHOR
AND THE US GOVT OF ANY AND ALL LIABILITY.

THE POINT OF CONTACT FOR QUESTIONS REGARDING THIS SOFTWARE IS:

US ARMY RDECOM CERDEC NVESD, RDER-NVS-SI (JOHN HODAPP), 
10221 BURBECK RD, FORT BELVOIR, VA 22060-5806

THIS HEADER SHALL REMAIN PART OF ALL SOURCE CODE FILES.

***/


#include "hist.h"

// hist must be allocated prior to call.

int hist(algPixel_t *streamA, int *h, int nRows, int nCols, int nBpp)
{
	int nBins = 1 << nBpp;
	int nPxls = nRows * nCols;
	int i = 0;

	if (h == (int *)NULL)
	{
		fprintf(stderr, "File %s, Line %d, Memory Allocation Error\n", __FILE__, __LINE__);
		return -1;
	}

	memset((void *)h, 0, nBins * sizeof(int));

	for (i = 0; i < nPxls; i++)
	{
		if (streamA[i] >= nBins)
		{
			fprintf(stderr, "File %s, Line %d, Range Error in hist() -- using max val ---", __FILE__, __LINE__);
			h[nBins-1]++;
		}
		else
		{
			h[(int)streamA[i]]++;
		}
	}

	return 0;
}

int histEq(algPixel_t *streamA, algPixel_t *out, int *h, int nRows, int nCols, int nInpBpp, int nOutBpp)
{
	int nOutBins = (1 << nOutBpp);
	int nInpBins = (1 << nInpBpp);
	int *CDF = (int *)calloc(nInpBins, sizeof(int));
	int *LUT = (int *)calloc(nInpBins, sizeof(int));

	if (!(CDF && LUT))
	{	// Ok to call free() on potentially NULL pointer
		free(CDF);
		free(LUT);
		fprintf(stderr, "File %s, Line %d, Memory Allocation Error\n", __FILE__, __LINE__);
		return -1;
	}

	int CDFmin = INT_MAX;
	int sum = 0;
	int nPxls = nRows * nCols;
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
		out[i] = LUT[(int)streamA[i]];
	}

	free(CDF);
	free(LUT);

	return 0;
}


//int histEq(algPixel_t *streamA, algPixel_t *out, int nRows, int nCols, int nInpBpp, int nOutBpp)
//{
//	int nOutBins = (1 << nOutBpp);
//	int nInpBins = (1 << nInpBpp);
//	int *h   = (int *)calloc(nInpBins, sizeof(int));
//	int *CDF = (int *)calloc(nInpBins, sizeof(int));
//	int *LUT = (int *)calloc(nInpBins, sizeof(int));
//
//	if (!(h && CDF && LUT))
//	{
//		// Ok to call free() on potentially NULL pointer, so just run through these
//		free(h);
//		free(CDF);
//		free(LUT);
//		fprintf(stderr, "File: %s, Line %d, Memory Allocation Error\n", __FILE__, __LINE__);
//		return -1;
//	}
//
//	int CDFmin = INT_MAX;
//	int sum = 0;
//	int nPxls = nRows * nCols;
//
//	for (int i = 0; i < nPxls; i++)
//	{
//		h[(int)streamA[i]]++;
//	}
//
//	for (int i = 0; i < nInpBins; i++)
//	{
//		sum += h[i];
//		CDF[i] = sum;
//	}
//
//	for (int i = 0; i < nInpBins; i++)
//	{
//		CDFmin = MIN(CDFmin, h[i]);
//	}
//
//	for (int i = 0; i < nInpBins; i++)
//	{
//		LUT[i] = ((CDF[i] - CDFmin) * (nOutBins - 1)) / (nPxls - CDFmin);
//	}
//
//	for (int i = 0; i < nPxls; i++)
//	{
//		out[i] = LUT[(int)streamA[i]];
//	}
//
//	free(CDF);
//	free(LUT);
//	free(h);
//
//	return 0;
//}
