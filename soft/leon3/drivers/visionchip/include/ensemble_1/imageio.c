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


#include "imageio.h"

// Read next frame from (previously opened) file... assumes frames
// are sequential... leaves file open and file pointer positioned 
// at start of next frame in file... performs byteswap if needed

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



// Supply "." for srcDir if files reside in current working directory

int readImage(void *image, char *srcDir, char *fileName, int nRows, int nCols, int nFrames, int nBytesPerPxl, bool bSwap)
{
	char *origDir = NULL;
	__int64 *p64 = (__int64 *)image;
	unsigned long *p32 = (unsigned long *)image;
	unsigned short *p16 = (unsigned short *)image;
	int nPxlsRead = 0;
	int i = 0;

	origDir = _getcwd(NULL, MAX_PATH);
	if (_chdir(srcDir) == -1)
	{
		fprintf(stderr, "File %s, Line %d, Could not change to directory=%s\n", __FILE__, __LINE__, srcDir);
		return -1;
	}

	FILE *fp = fopen(fileName, "rb");
	if (fp == (FILE *)NULL)
	{
		fprintf(stderr, "File %s, Line %d, Could not open %s for reading\n", __FILE__, __LINE__, fileName);
		return -2;
	}
	nPxlsRead = fread(image, nBytesPerPxl, nRows * nCols * nFrames, fp);
	fclose(fp);

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

	_chdir(origDir);
	free(origDir);

	return nPxlsRead;
}



int saveFrame(void *image, char *dstDir, char *baseFileName, int nRows, int nCols, int frameNo, int nBytesPerPxl, bool bSwap)
{
	char *origDir = NULL;
	__int64 *p64 = (__int64 *)image;
	unsigned long *p32 = (unsigned long *)image;
	unsigned short *p16 = (unsigned short *)image;

	char fullFileName[MAX_PATH];
	int nPxlsToWrite = nRows * nCols;
	int err = 0;
	int i = 0;

	origDir = _getcwd(NULL, MAX_PATH);

	if (_chdir(dstDir) == -1)
	{
		fprintf(stderr, "File %s, Line %d, Could not change to directory=%s\n", __FILE__, __LINE__, dstDir);
		return -1;
	}

	sprintf(fullFileName, "%s_%dR_%dC_%dBpp_Frame%d.raw", baseFileName, nRows, nCols, nBytesPerPxl, frameNo);
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
#ifdef _USE_FOPEN_FWRITES
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
	err = _chdir(origDir);
	return nPxlsToWrite * nBytesPerPxl;
#else
	DWORD nBytesToWrite = nRows * nCols * nBytesPerPxl;
	DWORD nBytesWritten = 0;
    HANDLE hFile = CreateFileA(fullFileName,             
                        GENERIC_WRITE | GENERIC_READ,     
                        NULL, //FILE_SHARE_READ | FILE_SHARE_WRITE,	 
                        NULL,                
                        CREATE_ALWAYS,  
                        FILE_ATTRIBUTE_NORMAL,
						//FILE_FLAG_NO_BUFFERING | FILE_FLAG_WRITE_THROUGH,
					    NULL);  
 
    if (hFile == INVALID_HANDLE_VALUE) 
    { 
		char msg[256];
		sprintf(msg, "Failed CreateFileA() on file: %s, error code = %d\n", fullFileName, GetLastError());
        perror(msg);
		fflush(stdout);
        return -1; 
    }

	if (WriteFile(hFile, image, nBytesToWrite, &nBytesWritten, NULL) == 0)
    {
		char msg[256];
		sprintf(msg, "Failed WriteFile() on file: %s, error code = %d\n", fullFileName, GetLastError());
        perror(msg);
		fflush(stdout);
        return -2;
    }

	if (!FlushFileBuffers(hFile))
    {
		char msg[256];
		sprintf(msg, "Failed FlushFileBuffers() on file: %s, error code = %d\n", fullFileName, GetLastError());
        perror(msg);
		fflush(stdout);
        return -3;
    }

	if (!CloseHandle(hFile))
	{
		char msg[256];
		sprintf(msg, "Failed CloseHandle() on file: %s, error code = %d\n", fullFileName, GetLastError());
        perror(msg);
		fflush(stdout);
		return -4;
	}

	_chdir(origDir);
	free(origDir);
	return nBytesWritten;
#endif
}

