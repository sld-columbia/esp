/*
 * Copyright (c) 2011-2023 Columbia University, System Level Design Group
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef TEST_TIME_H
#define TEST_TIME_H

#include <stdlib.h>
#include <stdio.h>
#include <time.h>

static inline unsigned long long ts_subtract(const struct timespec *a, const struct timespec *b)
{
	unsigned long long ns;

	ns = (b->tv_sec - a->tv_sec) * 1000000000ULL;
	ns += (b->tv_nsec - a->tv_nsec);
	return ns;
}

static inline void gettime(struct timespec *ts)
{
	if (clock_gettime(CLOCK_MONOTONIC, ts)) {
		perror("cannot get time");
		exit(1);
	}
}

static inline unsigned long long getformattedtime(const struct timespec *a)
{
   unsigned long long ns;

   ns = a->tv_sec * 1000000000ULL + a->tv_nsec;
   return ns;
}

#endif /* TEST_TIME_H */
