// Copyright (c) 2011-2026 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include "libesp.h"
#include "cfg.h"
#include <esp_accelerator.h>
#include <time.h>

#define BUFFER_OFFSET 0xA5000000

/*
 * Legacy memory-pattern Linux sample.
 * Kept as reference; the main ESP Linux flow builds from sw/linux/app.
 */


static void init_buf(token_t *in)
{
  /* input.h embeds the precompiled Vortex program + initial data image. */
  #include "input.h"
}



int main(int argc, char **argv)
{

	token_t *val1;
	token_t *val2;
	token_t *val3;
	token_t *mem; 

	unsigned int _mem_bin_len_in_words = 7024/4;
	
	size_t mem_size = _mem_bin_len_in_words * sizeof(token_t);	
	mem = esp_alloc(mem_size); 
	init_buf(mem); 
	intptr_t mem_top = (intptr_t)mem;
	cfg_000[0].hw_buf = mem;
	printf("cfg set to buf\n");

	val1 = (token_t *) (mem_top+0x00001b68); 
	val2 = (token_t *) (mem_top+0x00001b60); 
	val3 = (token_t *) (mem_top+0x00001b58); 
	/* These offsets are where the kernel updates pattern outputs. */
	printf("print acc_out set\n");

	printf(" Initial value of pointer 1 (expected 0x0000000A) = %x \n", *(val1));
	printf(" Initial value of pointer 2 (expected 0x0000000B) = %x \n", *(val2));
	printf(" Initial value of pointer 3 (expected 0x0000000C) = %x \n", *(val3));

	printf("Mapping Virtual Buffer to Contiguous Physical Memory Buffer\n");
	void *buf_ptr;
	int fd = open("/dev/mem", O_RDWR);
    buf_ptr = mmap(NULL, mem_size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, BUFFER_OFFSET);
    close(fd);

	if (buf_ptr == MAP_FAILED) {
		printf("Error: Buffer Mapping Failed");
		return -1;
	}

	memcpy(buf_ptr, (void *) ((uint8_t *) mem_top), mem_size);


	munmap(buf_ptr, mem_size);
	
	
	printf("\n====== %s ======\n\n", cfg_000[0].devname);

	// Set memory offset
	/* Wrapper adds this base to Vortex memory requests. */
	gt_vortex_cfg_000[0].BASE_ADDR = BUFFER_OFFSET;	
	
	printf("  Busy Reg Value = %d \n", gt_vortex_cfg_000[0].VX_BUSY_INT);
	printf("\n	** START **\n");
	esp_run(cfg_000, NACC);
	printf("  Busy Reg Value = %d \n", gt_vortex_cfg_000[0].VX_BUSY_INT);
	printf("\n	** DONE **\n");

	fd = open("/dev/mem", O_RDWR);
    buf_ptr = mmap(NULL, mem_size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, BUFFER_OFFSET);
    close(fd);

	if (buf_ptr == MAP_FAILED) {
		printf("Error: Buffer Mapping Failed");
		return -1;
	}


	memcpy((void *) ((uint8_t *) mem_top), buf_ptr, mem_size); 
	munmap(buf_ptr, mem_size);


	printf(" Final value of pointer 1 (expected 0xAAAAAAAA) = %x \n", *(val1));
	printf(" Final value of pointer 2 (expected 0xBBBBBBBB) = %x \n", *(val2));
	printf(" Final value of pointer 3 (expected 0xCCCCCCCC) = %x \n", *(val3));

	printf("\n====== %s ======\n\n", cfg_000[0].devname);



	return 0;
}
