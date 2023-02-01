// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include <stdlib.h>
#include <stdio.h>

#include <test/test.h>
#include <test/wami.h>
#include <test/le.h>

void wami_read_data_file(void *data, size_t size, const char *path, size_t num_bytes)
{
	size_t nread;
	FILE *fp;

	fp = fopen(path, "rb");
	if (fp == NULL)
		die_errno("Unable to open input file %s for reading", path);

	nread = lefread(data, size, num_bytes / size, fp);
	if (nread != num_bytes/size) {
		die("read failure on %s. Expected %zu bytes, but only read %zu",
			path, num_bytes, nread);
	}

	if (fclose(fp))
		die_errno("cannot close %s", path);
}

void wami_image_file_dimensions(const char *path, int *rows, int *cols)
{
	uint16_t width, height;
	FILE *fp;
	int ok;

	fp = fopen(path, "rb");
	if (fp == NULL)
		die_errno("Unable to open input file %s for reading", path);

	ok = 1;
	ok &= lefread(&width, sizeof(uint16_t), 1, fp) == 1;
	ok &= lefread(&height, sizeof(uint16_t), 1, fp) == 1;
	if (!ok)
		die("header read failure on %s", path);

	if (fclose(fp))
		die_errno("cannot close %s", path);

	*rows = height;
	*cols = width;
}

void wami_read_image_file(void *data, size_t size, const char *path, size_t num_bytes)
{
	uint16_t width, height, channels, depth;
	size_t header_bytes;
	size_t nread;
	FILE *fp;
	int ok;

	fp = fopen(path, "rb");
	if (fp == NULL)
		die_errno("Unable to open input file %s for reading", path);

	ok = 1;
	ok &= lefread(&width, sizeof(uint16_t), 1, fp) == 1;
	ok &= lefread(&height, sizeof(uint16_t), 1, fp) == 1;
	ok &= lefread(&channels, sizeof(uint16_t), 1, fp) == 1;
	ok &= lefread(&depth, sizeof(uint16_t), 1, fp) == 1;
	if (!ok)
		die("header read failure on %s", path);

	header_bytes = (size_t)width * height * channels * depth;
	if (header_bytes != num_bytes) {
		die("header dimensions in %s (%zu bytes) inconsistent with requested "
			"number of bytes to read %zu", path, header_bytes, num_bytes);
	}

	nread = lefread(data, size, num_bytes / size, fp);
	if (nread != num_bytes / size) {
		die("read failure on %s. Expected %zu bytes, but only read %zu",
			path, num_bytes, nread);
	}

	if (fclose(fp))
		die_errno("cannot close %s", path);
}
