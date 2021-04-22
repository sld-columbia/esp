#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

#include "le_zcu.h"
#include "socmap.h"

/**
 * fread()  and  fwrite()  return  the number of items successfully read
 * or written (i.e., not the number of characters).  If an error occurs,
 * or the end-of-file is reached, the return value is a short item count
 * (or zero).
 *
 * fread() does not distinguish between end-of-file and error, and
 * callers must use feof(3) and ferror(3) to determine which occurred.
 */


size_t lefread_udma(u_int64_t *ptr, size_t size, size_t nmemb, FILE *stream)
{
#if TARGET_BYTE_ORDER == __ORDER_LITTLE_ENDIAN__
	printf("Little endian \n");
	return fread(ptr, size, nmemb, stream);

#else /* __ORDER_BIG_ENDIAN__ */
//	printf("Big endian \n");
//	size_t n;
//	unsigned char *p;
//	unsigned char *buf;
//	int i, j;
//	if (size == 1)
//		return fread(ptr, size, nmemb, stream);
//
//	n = fread(ptr, size, nmemb, stream);
//	if (n == 0)
//		return n;
//	p = ptr;
//	buf = malloc(size);
//	if (!buf || !p)
//		return 0;
//
//	for (i = 0; i < nmemb; i++) {
//		memcpy((void *) buf, (void *) p + size*i, size);
//		for (j = 0; j < size; j++)
//			p[size*i + j] = buf[size-j-1];
//	}
//
//
//	free(buf);
//	return n;
	//////////////////////////////////////////
	char ch;
	u_int64_t temp;
	fseek(stream, 0L, SEEK_END);
	size_t sz;
	size_t rem;
	sz = ftell(stream);
	rewind(stream);
	rem = sz;
	for(int i=0;i<rem;i=i+8){
		temp=0;
		ch=(char)fgetc(stream);
		temp=temp+(((u_int64_t)ch)<<56);
		ch=(char)fgetc(stream);
		temp=temp+(((u_int64_t)ch)<<48);
		ch=(char)fgetc(stream);
		temp=temp+(((u_int64_t)ch)<<40);
		ch=(char)fgetc(stream);
		temp=temp+(((u_int64_t)ch)<<32);
		ch=(char)fgetc(stream);
		temp=temp+(((u_int64_t)ch)<<24);
		ch=(char)fgetc(stream);
		temp=temp+(((u_int64_t)ch)<<16);
		ch=(char)fgetc(stream);
		temp=temp+(((u_int64_t)ch)<<8);
		ch=(char)fgetc(stream);
		temp=temp+(((u_int64_t)ch)<<0);
		*(ptr+(i>>3))=temp;

	}
	//////////////////////////
/*
	char ch;
	u_int32_t temp;
	size_t sz;
	size_t rem;
	// Get binary size
	fseek(stream, 0L, SEEK_END);
	sz = ftell(stream);
	rewind(stream);
	rem = sz;
	for(int i=0;i<rem;i=i+4){
		temp=0;
		ch=(char)fgetc(stream);
		temp=temp+(u_int32_t)(ch<<24);
		ch=(char)fgetc(stream);
		temp=temp+(u_int32_t)(ch<<16);
		ch=(char)fgetc(stream);
		temp=temp+(u_int32_t)(ch<<8);
		ch=(char)fgetc(stream);
		temp=temp+(u_int32_t)ch;
		*(ptr+(i>>2))=temp;
	}
*/
	return sz;
#endif /* TARGET_BYTE_ORDER */
}

size_t lefread_uio(unsigned *ptr, size_t size, size_t nmemb, FILE *stream)
{
#if TARGET_BYTE_ORDER == __ORDER_LITTLE_ENDIAN__
	printf("Little endian \n");
	return fread(ptr, size, nmemb, stream);

#else /* __ORDER_BIG_ENDIAN__ */
//	printf("Big endian \n");
//	size_t n;
//	unsigned char *p;
//	unsigned char *buf;
//	int i, j;
//	if (size == 1)
//		return fread(ptr, size, nmemb, stream);
//
//	n = fread(ptr, size, nmemb, stream);
//	if (n == 0)
//		return n;
//	p = ptr;
//	buf = malloc(size);
//	if (!buf || !p)
//		return 0;
//
//	for (i = 0; i < nmemb; i++) {
//		memcpy((void *) buf, (void *) p + size*i, size);
//		for (j = 0; j < size; j++)
//			p[size*i + j] = buf[size-j-1];
//	}
//
//
//	free(buf);
//	return n;
	char ch;
	u_int32_t temp;
	size_t sz;
	size_t rem;
	// Get binary size
	fseek(stream, 0L, SEEK_END);
	sz = ftell(stream);
	rewind(stream);
	rem = sz;
	for(int i=0;i<rem;i=i+4){
		temp=0;
		ch=(char)fgetc(stream);
		temp=temp+(u_int32_t)(ch<<24);
		ch=(char)fgetc(stream);
		temp=temp+(u_int32_t)(ch<<16);
		ch=(char)fgetc(stream);
		temp=temp+(u_int32_t)(ch<<8);
		ch=(char)fgetc(stream);
		temp=temp+(u_int32_t)ch;
		*(ptr+(i>>2))=temp;
	}

	return sz;
#endif /* TARGET_BYTE_ORDER */
}

size_t lefwrite(const void *ptr, size_t size, size_t nmemb, FILE *stream)
{
#if TARGET_BYTE_ORDER == __ORDER_LITTLE_ENDIAN__

	return fwrite(ptr, size, nmemb, stream);

#else /* __ORDER_BIG_ENDIAN__ */

	const unsigned char *p;
	unsigned char *buf;
	size_t n;
	int i, j;

	if (size == 1)
		return fwrite(ptr, size, nmemb, stream);

	p = ptr;
	buf = malloc(nmemb * size);
	if (!buf)
		return 0;

	for (i = 0; i < nmemb; i++)
		for (j = 0; j < size; j++)
			buf[size * i + j] = p[size * (i + 1) - j - 1];

	n = fwrite(buf, size, nmemb, stream);
	free(buf);

	return n;
#endif /* TARGET_BYTE_ORDER */
}
