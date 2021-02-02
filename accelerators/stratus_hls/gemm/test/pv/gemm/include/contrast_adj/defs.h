#ifndef _DEFS_H
#define _DEFS_H

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

#define DBGMSG(MSG)	{printf("%s, line %d: %s", __FILE__, __LINE__, MSG);}



#endif //_DEFS_H
