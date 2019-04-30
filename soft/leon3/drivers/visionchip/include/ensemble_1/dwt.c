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

#include "dwt.h"


/***

 THE FOLLOWING IS THE TEXTUAL DESCRIPTION FROM THE
 DEVELOPER'S ORIGINAL CODE -- PROVIDED FOR CONTEXT

 The idea is to split the data into evens and odds.
 E = even, O = odd
 We then predict the odd values using the
 even (a linear interpolation)
 Oi = Oi - 0.5 * (Ei-1 + Ei+1)
 We then update the evens using the new odd 
 values to preserve the data mean
 Ei = Ei + 0.25 * (Oi-1 + Oi+1)

 The algorithm consists mainly of additions 
 and multiplies by either 2 or 4.
 This lends itself to adds and shifts pretty well.
 The actuall algorithm has the normalizing by sqrt(2),
 but I am not sure that is actually necessary in practice.
 The sqrt(2) comes from the mathimatical derivation of the
 lifting algorithm from the low and high pass filter coefficients.
 We will have to look at how OpenJPEG does it.

 Also, this is just one iteration of the algorithm.
 It would result in 4 quadrants each a quarter of the image:
 upper left a smaller representation of the original image,
 upper right is the high frequency vertical components,
 lower left the high frequency horizontal components,
 and lower right the high frequency diagonal components.
 We could run the algorithm again on the upper left quadrant
 creating 4 more quadrants and we could continue that until
 the upper left quadrant was a single pixel.

 Also, the algorithm is completely reversible.
 You just do the steps in the reverse order,
 doing the opposite at each step.

***/


int dwt53(algPixel_t *data, int nrows, int ncols)
{
	int err = 0;
    algPixel_t *data2 = (algPixel_t *)calloc(nrows * ncols, sizeof(algPixel_t));
	if (!data2)
	{
		fprintf(stderr, "File %s, Line %d, Memory Allocation Error", __FILE__, __LINE__);
		return -1;
	}
    
    // First do all rows; This function will transpose the data 
	// as it performs its final shuffling

	err = dwt53_row_transpose(data, data2, nrows, ncols);

    // We next do all the columns (they are now the rows)
	
	err = dwt53_row_transpose(data2, data, ncols, nrows);

	free(data2);
    
    return err;
}


int dwt53_row_transpose(algPixel_t *data, algPixel_t *data2, int nrows, int ncols)
{
	int i, j, cur;

	for (i = 0; i < nrows; i++)
    {
        // Predict the odd pixels using linear interpolation of the even pixels
        for (j = 1; j < ncols - 1; j += 2)
        {
            cur = i * ncols + j;
#ifdef USE_SHIFT
			data[cur] -= (data[cur - 1] + data[cur + 1]) >> 1;
#else
			data[cur] -= (algPixel_t)(0.5 * (data[cur - 1] + data[cur + 1]));
#endif
        }
        // The last odd pixel only has its left neighboring even pixel
        cur = i * ncols + ncols - 1;
        data[cur] -= data[cur - 1];
        
        // Update the even pixels using the odd pixels
        // to preserve the mean value of the pixels
        for (j = 2; j < ncols; j += 2)
        {
            cur = i * ncols + j;
#ifdef USE_SHIFT
			data[cur] += (data[cur - 1] + data[cur + 1]) >> 2;
#else
            data[cur] += (algPixel_t)(0.25 * (data[cur - 1] + data[cur + 1]));
#endif
        }
        // The first even pixel only has its right neighboring odd pixel
        cur = i * ncols + 0;
#ifdef USE_SHIFT
		data[cur] += data[cur + 1] >> 1;
#else
		data[cur] += (algPixel_t)(0.5 * data[cur + 1]);      
#endif
        
        // Now rearrange the data putting the low
        // frequency components at the front and the 
		// high frequency components at the back,
		// transposing the data at the same time

        for (j = 0; j < ncols / 2; j++)
        {
            data2[j * nrows + i] = data[i * ncols + 2 * j];
            data2[(j + ncols / 2)* nrows + i] = data[i * ncols + 2 * j + 1];
        }
    }

	return 0;
}



int dwt53_inverse(algPixel_t *data, int nrows, int ncols)
{
	int err = 0;
    algPixel_t *data2 = (algPixel_t *)calloc(nrows * ncols, sizeof(algPixel_t));  
	if (!data2)
	{
		perror("Could not allocate temp space for dwt53_inverse op");
		return -1;
	}

	err = dwt53_row_transpose_inverse(data, data2, ncols, nrows);
	err = dwt53_row_transpose_inverse(data2, data, nrows, ncols);

	free(data2);
    
    return err;
}


int dwt53_row_transpose_inverse(algPixel_t *data, algPixel_t *data2, int nrows, int ncols)
{
	int i, j, cur;
	for (i = 0; i < nrows; i++)
    {     
		// Rearrange the data putting the low frequency components at the front
        // and the high frequency components at the back, transposing the data
		// at the same time
        for (j = 0; j < ncols / 2; j++)
        {
			data2[i * ncols + 2 * j] = data[j * nrows + i];
			data2[i * ncols + 2 * j + 1] = data[(j + ncols / 2) * nrows + i];
        }

		// Update the even pixels using the odd pixels
        // to preserve the mean value of the pixels
        for (j = 2; j < ncols; j += 2)
        {
            cur = i * ncols + j;
#ifdef USE_SHIFT
			data2[cur] -= ((data2[cur - 1] + data2[cur + 1]) >> 2);
#else
			data2[cur] -= (algPixel_t)(0.25 * (data2[cur - 1] + data2[cur + 1]));
#endif
        }
        //The first even pixel only has its right neighboring odd pixel
        cur = i * ncols + 0;
#ifdef USE_SHIFT
        data2[cur] -= (data2[cur + 1] >> 1);
#else
	    data2[cur] -= (algPixel_t)(0.5 * data2[cur + 1]);
#endif

        // Predict the odd pixels using linear
        // interpolation of the even pixels
        for (j = 1; j < ncols - 1; j += 2)
        {
            cur = i * ncols + j;
#ifdef USE_SHIFT
            data2[cur] += ((data2[cur - 1] + data2[cur + 1]) >> 1);
#else
			data2[cur] += (algPixel_t)(0.5 * (data2[cur - 1] + data2[cur + 1]));
#endif
        }
        // The last odd pixel only has its left neighboring even pixel
        cur = i * ncols + ncols - 1;
        data2[cur] += data2[cur - 1];
    }

	return 0;
}
