/*
 * Copyright (c) 2011-2023 Columbia University, System Level Design Group
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef TEST_LE_H
#define TEST_LE_H

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

size_t lefread(void *ptr, size_t size, size_t nmemb, FILE *stream);
size_t lefwrite(const void *ptr, size_t size, size_t nmemb, FILE *stream);
void le_read_elem(void *dest, size_t size_elem, size_t n_elems, FILE *fp, const char *path);

#endif /* TEST_LE_H */
