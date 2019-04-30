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


#include "ensembles.h"


int ensemble_1(algPixel_t *streamA, algPixel_t *out, int nRows, int nCols, int nInpBpp, int nOutBpp)
{	
	// NF
	// H
	// HE 
	// DWT

	int err = 0;
	int nHistBins = 1 << nInpBpp;
	int *h = (int *)calloc(nHistBins, sizeof(int));
	algPixel_t *wrkBuf1 = (algPixel_t *)calloc(nRows * nCols, sizeof(algPixel_t));
	algPixel_t *wrkBuf2 = (algPixel_t *)calloc(nRows * nCols, sizeof(algPixel_t));

	if (!(h && wrkBuf1 && wrkBuf2))
	{
		free(h);
		free(wrkBuf1);
		free(wrkBuf2);
		fprintf(stderr, "File %s, Line %d, Memory Allocation Error\n", __FILE__, __LINE__);
		return -1;
	}

	memcpy(wrkBuf1, streamA, nRows * nCols * sizeof(algPixel_t));
	// memcpy(wrkBuf2, streamA, nRows * nCols * sizeof(algPixel_t));
	memset(wrkBuf2, 0, nRows * nCols * sizeof(algPixel_t));

	
	err = nf(wrkBuf1, wrkBuf2, nRows, nCols);
	err = hist(wrkBuf2, h, nRows, nCols, nInpBpp);
	err = histEq(wrkBuf2, out, h, nRows, nCols, nInpBpp, nOutBpp);
	err = dwt53(out, nRows, nCols);


// -----------------------------------------
    /* 	int i = 0; */
    /* 	FILE *fileNF = fopen("AfterNF-gold.txt", "w"); */
    /* 	FILE *fileHist = fopen("AfterHist-gold.txt", "w"); */
    /* 	FILE *fileHistEq = fopen("AfterHistEq-nogold.txt", "w"); */
    /* 	FILE *fileDWT = fopen("AfterDWT-gold.txt", "w"); */
    /* for(i = 0 ; i < nRows*nCols ; i++) */
    /* { */
    /*     fprintf(fileNF, "%d\n", wrkBuf2[i]); */

    /*     fprintf(fileHistEq, "%d\n", out[i]); */
    /*     fprintf(fileDWT, "%d\n", out[i]); */
    /* } */
    /* for(i = 0 ; i < nHistBins ; i++) */
    /* { */
    /*     fprintf(fileHist, "%d\n", h[i]); */
    /* } */

    /* fclose(fileNF); */
    /* fclose(fileHist); */
    /* fclose(fileHistEq); */
    /* fclose(fileDWT); */
// -----------------------------------------

	// FOR TESTING, INVERT BACK TO GET DECENT IMAGE FOR COMPARISON...
	// dwt53_inverse(wrkBuf2, nRows, nCols);

	memcpy(out, wrkBuf2, nRows * nCols * sizeof(algPixel_t));
	
	free(wrkBuf2);
	free(wrkBuf1);
	free(h);

	return err;
}
