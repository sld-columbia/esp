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


#ifndef _DWT_H
#define _DWT_H

#include "defs.h"
//#include "imageops.h"
#include "types.h"

// Define this to use integer shifts instead of FP mults for some
// basic ops in the dwt alg...

#define USE_SHIFT

int dwt53(algPixel_t *data, int nRows, int nCols);
int dwt53_row_transpose(algPixel_t *data, algPixel_t *data2, int nRows, int nCols);

int dwt53_inverse(algPixel_t *data, int nRows, int nCols);
int dwt53_row_transpose_inverse(algPixel_t *data, algPixel_t *data2, int nRows, int nCols);


#endif //_DWT_H
