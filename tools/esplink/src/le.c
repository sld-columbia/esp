// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <le.h>
#include "esplink.h"

/**
 * fread()  and  fwrite()  return  the number of items successfully read
 * or written (i.e., not the number of characters).  If an error occurs,
 * or the end-of-file is reached, the return value is a short item count
 * (or zero).
 *
 * fread() does not distinguish between end-of-file and error, and
 * callers must use feof(3) and ferror(3) to determine which occurred.
 */
size_t lefread(void *ptr, size_t size, size_t nmemb, FILE *stream)
{
#if TARGET_BYTE_ORDER == __ORDER_LITTLE_ENDIAN__

	return fread(ptr, size, nmemb, stream);

#else /* __ORDER_BIG_ENDIAN__ */
	size_t n;
	unsigned char *p;
	unsigned char *buf;
	int i, j;

	if (size == 1)
		return fread(ptr, size, nmemb, stream);

	n = fread(ptr, size, nmemb, stream);
	if (n == 0)
		return n;

	p = ptr;
	buf = malloc(size);
	if (!buf || !p)
		return 0;

	for (i = 0; i < nmemb; i++) {
		memcpy((void *) buf, (void *) p + size*i, size);
		for (j = 0; j < size; j++)
			p[size*i + j] = buf[size-j-1];
	}

	free(buf);
	return n;

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
