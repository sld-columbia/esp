// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef TEST_WAMI_H
#define TEST_WAMI_H

#include <stdlib.h>

void wami_read_data_file(void *data, size_t size, const char *path, size_t num_bytes);
void wami_read_image_file(void *data, size_t size, const char *path, size_t num_bytes);
void wami_image_file_dimensions(const char *path, int *rows, int *cols);

#endif /* TEST_WAMI_H */
