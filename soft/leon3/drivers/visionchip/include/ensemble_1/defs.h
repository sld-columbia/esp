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


#ifndef _DEFS_H
#define _DEFS_H

#ifdef _WIN32
 #include <windows.h>
 #include <direct.h>
#else
 #include <unistd.h>
 #include <byteswap.h>
 #define	_byteswap_ushort(p16)	bswap_16(p16)
 #define	_byteswap_ulong(p32)	bswap_32(p32)
 #define	_byteswap_uint64(p64)	bswap_64(p64)
 #define	MAX_PATH			(1024)
 #define	bool				int
 #define	__int64				long long
 #define	true				(1)
 #define	false				(0)
 #define	_getcwd(a,b)		getcwd(a,b)
 #define	_chdir(a)			chdir(a)
#endif

#include <assert.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <limits.h>
#include <math.h>


#define ODD(A)		((A) & 0x01)
#define EVEN(A)		(!ODD(A))
#define ABS(X)		((X) < 0 ? (-(X)) : (X))
#define	MAX(A,B)	((A) > (B) ? (A) : (B))
#define MIN(A,B)	((A) < (B) ? (A) : (B))

#define DBGMSG(MSG)	{printf("%s, line %d: %s", __FILE__, __LINE__, MSG);}

#define CLIP_INRANGE(LOW,VAL,HIGH) ( (VAL) < (LOW) ? (LOW) : ((VAL) > (HIGH) ? (HIGH) : (VAL)) )

#define _USE_FOPEN_FWRITES
#define _USE_DOUBLEDENSITY_LAP_FUSION

#endif //_DEFS_H
