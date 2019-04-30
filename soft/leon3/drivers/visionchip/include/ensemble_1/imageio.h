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


#ifndef _IMAGEIO_H
#define _IMAGEIO_H

#ifdef _WIN32
#include <windows.h>
#include <direct.h>
#else
#include <byteswap.h>
#include <unistd.h>
#define	_bswap_ushort(p16)	bswap_16(p16)
#define	_bswap_ulong(p32)	bswap_32(p32)
#define	_bswap_uint64(p64)	bswap_64(p64)
#define	MAX_PATH	(1024)
#endif

#include <stdio.h>
#include "defs.h"
#include "types.h"


// Some simple helper functinons. Read an entire image sequence into the buffer (readImage),
// read a single frame from an opened file into a buffer (readFrame), and save a single frame
// out.
//
int readImage(void *image, char *srcDir, char *fileName, int nRows, int nCols, int nFrames, int nBytesPerPxl, bool bSwap);
int readFrame(FILE *fp, void *image, int nPxls, int nBytesPerPxl, bool bSwap);
int saveFrame(void *image, char *dstDir, char *baseFileName, int nRows, int nCols, int frameNo, int nBytesPerPxl, bool bSwap);

#endif //_IMAGEIO_H
