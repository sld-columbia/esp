// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <test/test.h>
#include <test/le.h>

#ifdef __sparc__

size_t lefread(void *ptr, size_t size, size_t nmemb, FILE *stream)
{
	/**
	 * fread()  and  fwrite()  return  the number of items successfully read
	 * or written (i.e., not the number of characters).  If an error occurs,
	 * or the end-of-file is reached, the return value is a short item count
	 * (or zero).
	 *
	 * fread() does not distinguish between end-of-file and error, and
	 * callers must use feof(3) and ferror(3) to determine which occurred.
	*/
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
}

size_t lefwrite(const void *ptr, size_t size, size_t nmemb, FILE *stream)
{
	/**
	 * fread()  and  fwrite()  return  the number of items successfully read
	 * or written (i.e., not the number of characters).  If an error occurs,
	 * or the end-of-file is reached, the return value is a short item count
	 * (or zero).
	 *
	 * fread() does not distinguish between end-of-file and error, and
	 * callers must use feof(3) and ferror(3) to determine which occurred.
	*/
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
}

#else

size_t lefread(void *ptr, size_t size, size_t nmemb, FILE *stream)
{
	return fread(ptr, size, nmemb, stream);
}
size_t lefwrite(const void *ptr, size_t size, size_t nmemb, FILE *stream)
{
	return fwrite(ptr, size, nmemb, stream);
}

#endif /* __sparc__ */

void le_read_elem(void *dest, size_t size_elem, size_t n_elems, FILE *fp, const char *path)
{
	size_t n;

	n = lefread(dest, size_elem, n_elems, fp);
	if (n != n_elems) {
		die("Unable to read phase history data from %s "
			"(read %zu elements instead of %lu).\n",
			path, n, n_elems);
	}
}
