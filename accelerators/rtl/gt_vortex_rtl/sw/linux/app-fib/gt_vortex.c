// Copyright (c) 2011-2026 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include "libesp.h"
#include "cfg.h"
#include <esp_accelerator.h>
#include <time.h>

#define BUFFER_OFFSET 0xA5000000

/*
 * Legacy Fibonacci Linux sample.
 * Kept as reference; the main ESP Linux flow builds from sw/linux/app.
 * Runtime sequence is the same as app/gt_vortex.c.
 */

/* User-defined code */
static int validate_buffer(token_t *out, token_t *gold)
{

	unsigned errors = 0;
		if(*out != *gold)
		{
		   errors+=1;
		}
		printf("out = %d, gold = %d \n", *out, *gold); 
	return errors;
}


static void init_buf(token_t *in)
{
  /* input.h embeds a precompiled Vortex program + initial data image. */
  #include "input.h"
}


int fibonacci(int n)
{
	if (n <= 1)
	  return n;
	return fibonacci(n - 1) + fibonacci(n - 2);
}


int main(int argc, char **argv)
{
	int errors;

	int input_val = 30;

	token_t *gold;
	token_t *acc_out; 
	token_t *buf;
	token_t *mem; 

	unsigned int _fibonacci_bin_len_in_words = 8104/4;
	clock_t start, end;
	double cpu_time_used;


	gold = esp_alloc(sizeof(token_t));
	
	printf("Running CPU Calculations\n");
	start = clock();
	*gold = fibonacci(input_val);	
	end = clock();
	
	cpu_time_used = ((double) (end - start)) / CLOCKS_PER_SEC;
	printf("Fibonacci CPU took %f seconds to execute \n", cpu_time_used);
	
	size_t mem_size = _fibonacci_bin_len_in_words * sizeof(token_t);	
	mem = esp_alloc(mem_size); 
	init_buf(mem); 
	intptr_t mem_top = (intptr_t)mem;
	
	buf = (token_t *) (mem_top+0x1f98);
	/* Kernel reads its input operand from this fixed offset. */
	*buf = input_val;
	cfg_000[0].hw_buf = mem;
	printf("Input value set to %d\n", input_val);

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

	printf("print acc_out set\n");
	printf("\n====== %s ======\n\n", cfg_000[0].devname);

	// Set memory offset
	/* Wrapper adds this base to Vortex memory requests. */
	gt_vortex_cfg_000[0].BASE_ADDR = BUFFER_OFFSET;	

	printf("\n	** START **\n");
	esp_run(cfg_000, NACC);
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

	/* Kernel writes result at this fixed output offset. */
	acc_out = (token_t *) (mem_top+0x1fa0); 
	
	errors = validate_buffer(acc_out, gold);

	if (!errors)
		printf("+ Test PASSED\n");
	else
		printf("+ Test FAILED\n");

	printf("\n====== %s ======\n\n", cfg_000[0].devname);

	return errors;
}
