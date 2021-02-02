#ifndef _IMAGEIO_H
#define _IMAGEIO_H

#include <byteswap.h>
#include <unistd.h>
#define	_bswap_ushort(p16)	bswap_16(p16)
#define	_bswap_ulong(p32)	bswap_32(p32)
#define	_bswap_uint64(p64)	bswap_64(p64)
#define	MAX_PATH	(1024)

#include <stdio.h>
#include "defs.h"

/**
 * readFrame: read a single frame from an opened file into a buffer
 * saveFrame: save a single frame from a buffer out to a file
 */

int readFrame(FILE *fp, void *image, int nPxls, int nBytesPerPxl, bool bSwap);
int saveFrame(void *image, char *dstDir, char *baseFileName, int nRows, int nCols, int nBytesPerPxl, bool bSwap);

int readFrame(FILE *fp, void *image, int nPxls, int nBytesPerPxl, bool bSwap)
{
	__int64 *p64 = (__int64 *)image;
	unsigned long *p32 = (unsigned long *)image;
	unsigned short *p16 = (unsigned short *)image;
	int nPxlsRead = 0;
	int i = 0;

	if (fp == (FILE *)NULL)
	{
		fprintf(stderr, "File %s, Line %d, NULL fp passed to readFrame()\n", __FILE__, __LINE__);
		return -1;
	}

	nPxlsRead = fread(image, nBytesPerPxl, nPxls, fp);

	if (bSwap)
	{
		for (i = 0; i < nPxlsRead; i++)
		{
			if (nBytesPerPxl == sizeof(unsigned short))
			{
				*p16 = _byteswap_ushort(*p16);
				p16++;
			} else if (nBytesPerPxl == sizeof(unsigned long))
			{
				*p32 = _byteswap_ulong(*p32);
				p32++;
			}
			else if (nBytesPerPxl == sizeof(unsigned __int64))
			{
				*p64 = _byteswap_uint64(*p64);
				p64++;
			}
		}
	}

	return nPxlsRead;
}


int saveFrame(void *image, char *dstDir, char *baseFileName, int nRows, int nCols, int nBytesPerPxl, bool bSwap)
{
	__int64 *p64 = (__int64 *)image;
	unsigned long *p32 = (unsigned long *)image;
	unsigned short *p16 = (unsigned short *)image;

	char fullFileName[MAX_PATH];
	int nPxlsToWrite = nRows * nCols;
	int i = 0;


	if (_chdir(dstDir) == -1)
	{
		fprintf(stderr, "File %s, Line %d, Could not change to directory=%s\n", __FILE__, __LINE__, dstDir);
		return -1;
	}

	sprintf(fullFileName, "%s_%dR_%dC_%dBpp.raw", baseFileName, nRows, nCols, nBytesPerPxl);
	if (bSwap)
	{
		for (i = 0; i < nPxlsToWrite; i++)
		{
			if (nBytesPerPxl == sizeof(unsigned short))
			{
				*p16 = _byteswap_ushort(*p16);
				p16++;
			} else if (nBytesPerPxl == sizeof(unsigned long))
			{
				*p32 = _byteswap_ulong(*p32);
				p32++;
			}
			else if (nBytesPerPxl == sizeof(unsigned __int64))
			{
				*p64 = _byteswap_uint64(*p64);
				p64++;
			}
		}
	}

	FILE *fp = fopen(fullFileName, "wb");
	if (fp == (FILE *)NULL)
	{
		fprintf(stderr, "File %s, Line %d, Failed fopen() on file: %s\n", __FILE__, __LINE__, fullFileName);
        return -1; 
	}
	if (fwrite((void *)image, nBytesPerPxl, nPxlsToWrite, fp) != (size_t)nPxlsToWrite)
	{
		fclose(fp);
		fprintf(stderr, "File %s, Line %d, Failed fwrite() on file: %s\n", __FILE__, __LINE__, fullFileName);
		return -1;
	}

	fclose(fp);

	return nPxlsToWrite * nBytesPerPxl;
}

#endif //_IMAGEIO_H
