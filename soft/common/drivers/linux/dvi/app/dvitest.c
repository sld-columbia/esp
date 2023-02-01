// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <fcntl.h>
#include <linux/fb.h>
#include <sys/mman.h>
#include <sys/ioctl.h>

int main()
{
	int fbfd = 0;
	struct fb_var_screeninfo vinfo;
	struct fb_fix_screeninfo finfo;
	long int screensize = 0;
	char *fbpc = 0;
	unsigned *fbp = 0;
	int x = 0, y = 0;
	long int location = 0;

	// Open the file for reading and writing
	fbfd = open("/dev/fb0", O_RDWR);
	if (fbfd == -1) {
		perror("Error: cannot open framebuffer device");
		exit(1);
	}
	printf("The framebuffer device was opened successfully.\n");

	// Get fixed screen information
	if (ioctl(fbfd, FBIOGET_FSCREENINFO, &finfo) == -1) {
		perror("Error reading fixed information");
		exit(2);
	}

	// Get variable screen information
	if (ioctl(fbfd, FBIOGET_VSCREENINFO, &vinfo) == -1) {
		perror("Error reading variable information");
		exit(3);
	}

	printf("%dx%d, %dbpp\n", vinfo.xres, vinfo.yres, vinfo.bits_per_pixel);

	// Figure out the size of the screen in bytes
	screensize = vinfo.xres * vinfo.yres * vinfo.bits_per_pixel / 8;

	// Map the device to memory
	fbpc = mmap(0, screensize, PROT_READ | PROT_WRITE, MAP_SHARED, fbfd, 0);
	if (fbpc == MAP_FAILED) {
		perror("Error: failed to map framebuffer device to memory");
		exit(4);
	}
	fbp = (unsigned *) fbpc;
	printf("The framebuffer device was mapped to memory successfully.\n");

	// Figure out where in memory to put the pixel
	printf("xoffset: %d\n", vinfo.xoffset);
	printf("bits_per_pixel: %d\n", vinfo.bits_per_pixel);
	printf("yoffset: %d\n", vinfo.yoffset);
	printf("line_length: %d\n", finfo.line_length);

	for (y = 100; y < 150; y++)
		for (x = 100; x < 150; x++) {

			location = (x+vinfo.xoffset) * (vinfo.bits_per_pixel/8) +
				(y+vinfo.yoffset) * finfo.line_length / 4;

			/* Writing for pixels at a time; each 1-byts (2 hex digits) */
			*(fbp + location) = 0xc4c4c4c4;

		}
	munmap(fbp, screensize);
	close(fbfd);
	return 0;
}
