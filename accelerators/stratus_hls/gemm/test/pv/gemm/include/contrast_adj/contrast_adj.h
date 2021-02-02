#ifndef _CONTRAST_ADJ_H
#define _CONTRAST_ADJ_H

#include "defs.h"
#include "hist.h"
#include "imageio.h"


int contrast_adj(int *imgSrc, int *imgOut, int n_rows, int n_cols, 
                    int n_in_bits_pp, int n_out_bits_pp)
{
	int algErr = 0;

	int nHistBins = (1 << n_in_bits_pp);

	int *h = (int *)calloc(nHistBins, sizeof(int));


    // -- save source txt files for easy debugging
	// FILE * img = fopen("img.txt", "w");
	// for(i = 0 ; i < nPxls ; i++)
	// {
	//     fprintf(img, "%d\n", imgSrc[i]);
	// }
	// fclose(img);


    // Perform histogram and histogram equalization
	algErr += hist(imgSrc, h, n_rows, n_cols, n_in_bits_pp);
	algErr += histEq(imgSrc, imgOut, h, n_rows, n_cols, n_in_bits_pp, n_out_bits_pp);



    // -- save txt files for easy debugging
    // FILE *fileHist = fopen("AfterHist.txt", "w");
	// FILE *fileHistEq = fopen("AfterHistEq.txt", "w");
    // for(i = 0 ; i < n_rows*n_cols ; i++)
    // {
    //     fprintf(fileHistEq, "%d\n", imgOut[i]);
    // }
    // for(i = 0 ; i < nHistBins ; i++)
    // { 
    //    fprintf(fileHist, "%d\n", h[i]);
    // }
    // fclose(fileHist);
    // fclose(fileHistEq);


	free(h);

	return algErr;
}

#endif //_CONTRAST_ADJ_H
