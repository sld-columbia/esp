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


#include "slowmedian.h"

int comparePxls(const void *arg1, const void *arg2)
{
	algPixel_t *p1 = (algPixel_t *)arg1;
	algPixel_t *p2 = (algPixel_t *)arg2;

	if (*p1 < *p2)
		return -1;
	else if (*p1 == *p2)
		return 0;
	else
		return 1;
}


int slowMedian3x3(algPixel_t *src, algPixel_t *dst, int nRows, int nCols)
{
	int i = 0, j = 0, k = 0;
	int r = 0, c = 0;
	algPixel_t *pxlList = (algPixel_t *)calloc(MEDIAN_NELEM, sizeof(algPixel_t));
	
	if (!pxlList)
	{
		fprintf(stderr, "File %s, Line %d, Memory Allocation Error\n", __FILE__, __LINE__);
		return -1;
	}

	for (r = 1; r < nRows-1; r++)
	{
		for (c = 1; c < nCols-1; c++)
		{
			k = 0;
			for (i = -1; i <= 1; i++)
			{
				for (j = -1; j <= 1; j++)
				{
					pxlList[k++] = src[(r + i) * nCols + c + j];
				}
			}			
			qsort((void *)pxlList, MEDIAN_NELEM, sizeof(algPixel_t), comparePxls);
			// qsort() really not necessary for such a small array, 
			// but it works and I don't care about speed right now. 
			dst[r * nCols + c] = pxlList[4];
		}
	}
	free(pxlList);
	return 0;
}
