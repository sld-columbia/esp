/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>
#include <fixed_point.h>

#define SOC_COLS 2
#define SOC_ROWS 4
#define REQ_PLANE 0
#define FWD_PLANE 1
#define RSP_PLANE 2

typedef int64_t token_t;

typedef union
{
  struct
  {
    unsigned char r_en   : 1;
    unsigned char r_op   : 1;
    unsigned char r_type : 2;
    unsigned char r_cid  : 4;
    unsigned char w_en   : 1;
    unsigned char w_op   : 1;
    unsigned char w_type : 2;
    unsigned char w_cid  : 4;
	uint16_t reserved: 16;
  };
  uint32_t spandex_reg;
} spandex_config_t;

static unsigned DMA_WORD_PER_BEAT(unsigned _st)
{
        return (sizeof(void *) / _st);
}

static void start_network_counter()
{
    uint64_t tile_id;
    for (tile_id = 0; tile_id < SOC_COLS * SOC_ROWS; tile_id++)
    {
        volatile void* monitor_base = (volatile void*)(0x60090000 + 0x200 * tile_id);
        volatile uint32_t* control = ((volatile uint32_t*)monitor_base) + 1; // ctrl_window_size_offset
        *control = 0xffffffff;
    }
}

static uint32_t get_network_counter(int x, int y, int plane)
{
    uint64_t tile_id = x + y * SOC_COLS;
    volatile void* monitor_base = (volatile void*)(0x60090000 + 0x200 * tile_id);
    volatile uint32_t* mon_register = ((volatile uint32_t*)monitor_base) + 4 + 22 + plane;
    return *mon_register;
}

static uint64_t get_counter() {
  uint64_t counter;
  asm volatile (
    "li t0, 0;"
    "csrr t0, mcycle;"
    "mv %0, t0"
    : "=r" ( counter )
    :
    : "t0"
  );

  return counter;
}

uint64_t start_write;
uint64_t stop_write;
uint64_t intvl_write;
uint64_t start_read;
uint64_t stop_read;
uint64_t intvl_read;

uint64_t start_acc_write;
uint64_t stop_acc_write;
uint64_t intvl_acc_write;
uint64_t start_acc_read;
uint64_t stop_acc_read;
uint64_t intvl_acc_read;

uint64_t start_network_cpu[3];
uint64_t stop_network_cpu[3];
uint64_t intvl_network_cpu[3];
uint64_t start_network_acc[3];
uint64_t stop_network_acc[3];
uint64_t intvl_network_acc[3];
uint64_t start_network_llc[3];
uint64_t stop_network_llc[3];
uint64_t intvl_network_llc[3];

#define ITERATIONS 1000
// #define ESP
#define COH_MODE 0
/* 3 - Owner Prediction, 2 - Write-through forwarding, 1 - Baseline Spandex (ReqV), 0 - Baseline Spandex (MESI) */
/* 3 - Non-Coherent DMA, 2 - LLC Coherent DMA, 1 - Coherent DMA, 0 - Fully Coherent MESI */

#define SLD_SENSOR_DMA 0x050
#define DEV_NAME "sld,sensor_dma_stratus"

/* Size of the contiguous chunks for scatter/gather */
#define CHUNK_SHIFT 20
#define CHUNK_SIZE BIT(CHUNK_SHIFT)
#define NCHUNK(_sz) ((_sz % CHUNK_SIZE == 0) ?		\
			(_sz / CHUNK_SIZE) :		\
			(_sz / CHUNK_SIZE) + 1)

/* User defined registers */
/* <<--regs-->> */
#define SENSOR_DMA_RD_SP_OFFSET_REG 0x58
#define SENSOR_DMA_RD_WR_ENABLE_REG 0x54
#define SENSOR_DMA_WR_SIZE_REG 0x50
#define SENSOR_DMA_WR_SP_OFFSET_REG 0x4c
#define SENSOR_DMA_RD_SIZE_REG 0x48
#define SENSOR_DMA_DST_OFFSET_REG 0x44
#define SENSOR_DMA_SRC_OFFSET_REG 0x40

int main(int argc, char * argv[])
{
	int i, j;
	int n;
	int ndev;
	struct esp_device *espdevs;
	struct esp_device *dev;
	unsigned done;
	unsigned **ptable;
	token_t *mem;
	token_t *gold;
	unsigned errors = 0;
	unsigned coherence;

    unsigned mem_words = 2048; 
    unsigned mem_size = mem_words*sizeof(token_t); 

	// Search for the device
	ndev = probe(&espdevs, VENDOR_SLD, SLD_SENSOR_DMA, DEV_NAME);
	if (ndev == 0) {
		printf("sensor_dma not found\n");
		return 0;
	}

	dev = &espdevs[0];

	// Check DMA capabilities
	if (ioread32(dev, PT_NCHUNK_MAX_REG) == 0) {
		printf("  -> scatter-gather DMA is disabled. Abort.\n");
		return 0;
	}

	if (ioread32(dev, PT_NCHUNK_MAX_REG) < NCHUNK(mem_size)) {
		printf("  -> Not enough TLB entries available. Abort.\n");
		return 0;
	}

	// Allocate memory
	mem = (token_t *) aligned_malloc(2*mem_size);
	gold = mem + mem_words;
	printf("  memory = %p\n", mem);
	printf("  gold = %p\n", gold);

    for (i = 0; i < mem_words; i++)
    {
        mem[i] = i;
    }
		
	// Alocate and populate page table
	ptable = aligned_malloc(NCHUNK(2*mem_size) * sizeof(unsigned *));
	for (i = 0; i < NCHUNK(2*mem_size); i++)
		ptable[i] = (unsigned *) &mem[i * (CHUNK_SIZE / sizeof(token_t))];

	printf("  ptable = %p\n", ptable);
	printf("  nchunk = %lu\n", NCHUNK(2*mem_size));

    asm volatile ("fence rw, rw");

#ifndef ESP
	spandex_config_t spandex_config;
	
#if (COH_MODE == 3)
	/* ********************************************************** */
	/* Owner Prediction */
	/* ********************************************************** */
	printf("Owner Prediction\n");

	spandex_config.spandex_reg = 0;
	spandex_config.r_en = 1;
	spandex_config.r_type = 2;
	spandex_config.w_en = 1;
	spandex_config.w_op = 1;
	spandex_config.w_type = 1;
	iowrite32(dev, SPANDEX_REG, spandex_config.spandex_reg);

	intvl_write = 0;
	intvl_acc_write = 0;
	intvl_read = 0;
	intvl_acc_read = 0;

	for (j = 0; j < 3; j++) {
		intvl_network_cpu[j] = 0;
		intvl_network_llc[j] = 0;
		intvl_network_acc[j] = 0;
	}

	for (i = 0; i < ITERATIONS; i++)
	{
		/* TODO: Restore full test once ESP caches are integrated */
		coherence = ACC_COH_FULL;

		// Pass common configuration parameters 
		iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
		iowrite32(dev, COHERENCE_REG, coherence);

		iowrite32(dev, PT_ADDRESS_REG, (unsigned long) ptable);
		iowrite32(dev, PT_NCHUNK_REG, NCHUNK(2*mem_size));
		iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);

		// Use the following if input and output data are not allocated at the default offsets
		iowrite32(dev, SRC_OFFSET_REG, 0);
		iowrite32(dev, DST_OFFSET_REG, 0);

		// Pass accelerator-specific configuration parameters
		/* <<--regs-config-->> */
	    iowrite32(dev, SENSOR_DMA_RD_SP_OFFSET_REG, 2*mem_words);
	    iowrite32(dev, SENSOR_DMA_RD_WR_ENABLE_REG, 0);
	    iowrite32(dev, SENSOR_DMA_RD_SIZE_REG, mem_words);
	    iowrite32(dev, SENSOR_DMA_SRC_OFFSET_REG, 0);

  		void* dst = (void*)(mem);
		int64_t value_64 = 123;

		// for (j = 0; j < 3; j++) {
		// 	start_network_cpu[j] = get_network_counter(1,1,j);
		// 	start_network_acc[j] = get_network_counter(1,0,j);
		// 	start_network_llc[j] = get_network_counter(0,0,j);
		// }

      	start_write = get_counter();

    	for (j = 0; j < mem_words; j+=2)
    	{
			asm volatile (
				"mv t0, %0;"
				"mv t1, %1;"
				".word 0x2262B82B"
				: 
				: "r" (dst), "r" (value_64)
				: "t0", "t1", "memory"
			);

			dst += 16;
    	}

      	stop_write = get_counter();
		intvl_write += stop_write - start_write;

		// for (j = 0; j < 3; j++) {
		// 	stop_network_cpu[j] = get_network_counter(1,1,j);
		// 	stop_network_llc[j] = get_network_counter(0,0,j);
		// 	stop_network_acc[j] = get_network_counter(1,0,j);
		// 	intvl_network_cpu[j] += stop_network_cpu[j] - start_network_cpu[j];
		// 	intvl_network_llc[j] += stop_network_llc[j] - start_network_llc[j];
		// 	intvl_network_acc[j] += stop_network_acc[j] - start_network_acc[j];
		// }

		// if(i == 2) printf("CPU write %d = %lu\n", i, stop_write - start_write);

		// Start accelerators
		iowrite32(dev, CMD_REG, CMD_MASK_START);

      	start_acc_read = get_counter();

		// Wait for completion
		done = 0;
		while (!done) {
			done = ioread32(dev, STATUS_REG);
			done &= STATUS_MASK_DONE;
		}

      	stop_acc_read = get_counter();
		intvl_acc_read += stop_acc_read - start_acc_read;

		// if(i == 2) printf("ACC read %d = %lu\n", i, stop_acc_read - start_acc_read);

		iowrite32(dev, CMD_REG, 0x0);

	    iowrite32(dev, SENSOR_DMA_RD_WR_ENABLE_REG, 1);
	    iowrite32(dev, SENSOR_DMA_WR_SIZE_REG, mem_words);
	    iowrite32(dev, SENSOR_DMA_WR_SP_OFFSET_REG, 2*mem_words);
	    iowrite32(dev, SENSOR_DMA_DST_OFFSET_REG, mem_words);

		// Start accelerators
		iowrite32(dev, CMD_REG, CMD_MASK_START);

      	start_acc_write = get_counter();

		// Wait for completion
		done = 0;
		while (!done) {
			done = ioread32(dev, STATUS_REG);
			done &= STATUS_MASK_DONE;
		}

      	stop_acc_write = get_counter();
		intvl_acc_write += stop_acc_write - start_acc_write;

		// if(i == 2) printf("ACC write %d = %lu\n", i, stop_acc_write - start_acc_write);

		iowrite32(dev, CMD_REG, 0x0);

  		dst = (void*)(gold);

      	start_read = get_counter();

 	   	for (j = 0; j < mem_words; j+=2)
 	   	{
			asm volatile (
				"mv t0, %1;"
				".word 0x4002B30B;"
				"mv %0, t1"
				: "=r" (value_64)
				: "r" (dst)
				: "t0", "t1", "memory"
			);

			dst += 16;
 	   	}

      	stop_read = get_counter();
		intvl_read += stop_read - start_read;

		// if(i == 2) printf("CPU read %d = %lu\n", i, stop_read - start_read);
	}

	printf("CPU write = %lu\n", intvl_write/ITERATIONS);
	printf("ACC read = %lu\n", intvl_acc_read/ITERATIONS);
	printf("ACC write = %lu\n", intvl_acc_write/ITERATIONS);
	printf("CPU read = %lu\n", intvl_read/ITERATIONS);
	printf("Total time = %lu\n", (intvl_write + intvl_acc_read + intvl_acc_write + intvl_read)/ITERATIONS);

	// printf("REQ Plane:\n");
	// printf("CPU = %lu\n", intvl_network_cpu[0]);
	// printf("LLC = %lu\n", intvl_network_llc[0]);
	// printf("ACC = %lu\n", intvl_network_acc[0]);
	// printf("FWD Plane:\n");
	// printf("CPU = %lu\n", intvl_network_cpu[1]);
	// printf("LLC = %lu\n", intvl_network_llc[1]);
	// printf("ACC = %lu\n", intvl_network_acc[1]);
	// printf("RSP Plane:\n");
	// printf("CPU = %lu\n", intvl_network_cpu[2]);
	// printf("LLC = %lu\n", intvl_network_llc[2]);
	// printf("ACC = %lu\n", intvl_network_acc[2]);

#elif (COH_MODE == 2)
	/* ********************************************************** */
	/* Write-through forwarding */
	/* ********************************************************** */
	printf("Write-through forwarding\n");

	spandex_config.spandex_reg = 0;
	spandex_config.r_en = 1;
	spandex_config.r_type = 2;
	spandex_config.w_en = 1;
	spandex_config.w_type = 1;
	iowrite32(dev, SPANDEX_REG, spandex_config.spandex_reg);

	intvl_write = 0;
	intvl_acc_write = 0;
	intvl_read = 0;
	intvl_acc_read = 0;

	for (i = 0; i < ITERATIONS; i++)
	{
		/* TODO: Restore full test once ESP caches are integrated */
		coherence = ACC_COH_FULL;

		// Pass common configuration parameters 
		iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
		iowrite32(dev, COHERENCE_REG, coherence);

		iowrite32(dev, PT_ADDRESS_REG, (unsigned long) ptable);
		iowrite32(dev, PT_NCHUNK_REG, NCHUNK(2*mem_size));
		iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);

		// Use the following if input and output data are not allocated at the default offsets
		iowrite32(dev, SRC_OFFSET_REG, 0);
		iowrite32(dev, DST_OFFSET_REG, 0);

		// Pass accelerator-specific configuration parameters
		/* <<--regs-config-->> */
	    iowrite32(dev, SENSOR_DMA_RD_SP_OFFSET_REG, 2*mem_words);
	    iowrite32(dev, SENSOR_DMA_RD_WR_ENABLE_REG, 0);
	    iowrite32(dev, SENSOR_DMA_RD_SIZE_REG, mem_words);
	    iowrite32(dev, SENSOR_DMA_SRC_OFFSET_REG, 0);

  		void* dst = (void*)(mem);
		int64_t value_64 = 123;

      	start_write = get_counter();

    	for (j = 0; j < mem_words; j+=2)
    	{
			asm volatile (
				"mv t0, %0;"
				"mv t1, %1;"
				".word 0x2062B02B"
				: 
				: "r" (dst), "r" (value_64)
				: "t0", "t1", "memory"
			);

			dst += 16;
    	}

      	stop_write = get_counter();
		intvl_write += stop_write - start_write;

		// if(i == 2) printf("CPU write %d = %lu\n", i, stop_write - start_write);

		// Start accelerators
		iowrite32(dev, CMD_REG, CMD_MASK_START);

      	start_acc_read = get_counter();

		// Wait for completion
		done = 0;
		while (!done) {
			done = ioread32(dev, STATUS_REG);
			done &= STATUS_MASK_DONE;
		}

      	stop_acc_read = get_counter();
		intvl_acc_read += stop_acc_read - start_acc_read;

		// if(i == 2) printf("ACC read %d = %lu\n", i, stop_acc_read - start_acc_read);

		iowrite32(dev, CMD_REG, 0x0);

	    iowrite32(dev, SENSOR_DMA_RD_WR_ENABLE_REG, 1);
	    iowrite32(dev, SENSOR_DMA_WR_SIZE_REG, mem_words);
	    iowrite32(dev, SENSOR_DMA_WR_SP_OFFSET_REG, 2*mem_words);
	    iowrite32(dev, SENSOR_DMA_DST_OFFSET_REG, mem_words);

		// Start accelerators
		iowrite32(dev, CMD_REG, CMD_MASK_START);

      	start_acc_write = get_counter();

		// Wait for completion
		done = 0;
		while (!done) {
			done = ioread32(dev, STATUS_REG);
			done &= STATUS_MASK_DONE;
		}

      	stop_acc_write = get_counter();
		intvl_acc_write += stop_acc_write - start_acc_write;

		// if(i == 2) printf("ACC write %d = %lu\n", i, stop_acc_write - start_acc_write);

		iowrite32(dev, CMD_REG, 0x0);

  		dst = (void*)(gold);

      	start_read = get_counter();

 	   	for (j = 0; j < mem_words; j+=2)
 	   	{
			asm volatile (
				"mv t0, %1;"
				".word 0x4002B30B;"
				"mv %0, t1"
				: "=r" (value_64)
				: "r" (dst)
				: "t0", "t1", "memory"
			);

			dst += 16;
 	   	}

      	stop_read = get_counter();
		intvl_read += stop_read - start_read;

		// if(i == 2) printf("CPU read %d = %lu\n", i, stop_read - start_read);
	}

	printf("CPU write = %lu\n", intvl_write/ITERATIONS);
	printf("ACC read = %lu\n", intvl_acc_read/ITERATIONS);
	printf("ACC write = %lu\n", intvl_acc_write/ITERATIONS);
	printf("CPU read = %lu\n", intvl_read/ITERATIONS);
	printf("Total time = %lu\n", (intvl_write + intvl_acc_read + intvl_acc_write + intvl_read)/ITERATIONS);

#elif (COH_MODE == 1)
	/* ********************************************************** */
	/* Baseline Spandex (ReqV) */
	/* ********************************************************** */
	printf("Baseline Spandex (ReqV)\n");

	spandex_config.spandex_reg = 0;
	spandex_config.r_en = 1;
	spandex_config.r_type = 1;
	iowrite32(dev, SPANDEX_REG, spandex_config.spandex_reg);

	intvl_write = 0;
	intvl_acc_write = 0;
	intvl_read = 0;
	intvl_acc_read = 0;

	for (i = 0; i < ITERATIONS; i++)
	{
		/* TODO: Restore full test once ESP caches are integrated */
		coherence = ACC_COH_FULL;

		// Pass common configuration parameters 
		iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
		iowrite32(dev, COHERENCE_REG, coherence);

		iowrite32(dev, PT_ADDRESS_REG, (unsigned long) ptable);
		iowrite32(dev, PT_NCHUNK_REG, NCHUNK(2*mem_size));
		iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);

		// Use the following if input and output data are not allocated at the default offsets
		iowrite32(dev, SRC_OFFSET_REG, 0);
		iowrite32(dev, DST_OFFSET_REG, 0);

		// Pass accelerator-specific configuration parameters
		/* <<--regs-config-->> */
	    iowrite32(dev, SENSOR_DMA_RD_SP_OFFSET_REG, 2*mem_words);
	    iowrite32(dev, SENSOR_DMA_RD_WR_ENABLE_REG, 0);
	    iowrite32(dev, SENSOR_DMA_RD_SIZE_REG, mem_words);
	    iowrite32(dev, SENSOR_DMA_SRC_OFFSET_REG, 0);

  		void* dst = (void*)(mem);
		int64_t value_64 = 123;

      	start_write = get_counter();

    	for (j = 0; j < mem_words; j+=2)
    	{
			asm volatile (
				"mv t0, %0;"
				"mv t1, %1;"
				".word 0x0062B02B"
				: 
				: "r" (dst), "r" (value_64)
				: "t0", "t1", "memory"
			);

			dst += 16;
    	}

      	stop_write = get_counter();
		intvl_write += stop_write - start_write;

		// if(i == 2) printf("CPU write %d = %lu\n", i, stop_write - start_write);

		// Start accelerators
		iowrite32(dev, CMD_REG, CMD_MASK_START);

      	start_acc_read = get_counter();

		// Wait for completion
		done = 0;
		while (!done) {
			done = ioread32(dev, STATUS_REG);
			done &= STATUS_MASK_DONE;
		}

      	stop_acc_read = get_counter();
		intvl_acc_read += stop_acc_read - start_acc_read;

		// if(i == 2) printf("ACC read %d = %lu\n", i, stop_acc_read - start_acc_read);

		iowrite32(dev, CMD_REG, 0x0);

	    iowrite32(dev, SENSOR_DMA_RD_WR_ENABLE_REG, 1);
	    iowrite32(dev, SENSOR_DMA_WR_SIZE_REG, mem_words);
	    iowrite32(dev, SENSOR_DMA_WR_SP_OFFSET_REG, 2*mem_words);
	    iowrite32(dev, SENSOR_DMA_DST_OFFSET_REG, mem_words);

		// Start accelerators
		iowrite32(dev, CMD_REG, CMD_MASK_START);

      	start_acc_write = get_counter();

		asm volatile ("fence r, r");

		// Wait for completion
		done = 0;
		while (!done) {
			done = ioread32(dev, STATUS_REG);
			done &= STATUS_MASK_DONE;
		}

      	stop_acc_write = get_counter();
		intvl_acc_write += stop_acc_write - start_acc_write;

		// if(i == 2) printf("ACC write %d = %lu\n", i, stop_acc_write - start_acc_write);

		iowrite32(dev, CMD_REG, 0x0);

  		dst = (void*)(gold);

      	start_read = get_counter();

 	   	for (j = 0; j < mem_words; j+=2)
 	   	{
			asm volatile (
				"mv t0, %1;"
				".word 0x2002B30B;"
				"mv %0, t1"
				: "=r" (value_64)
				: "r" (dst)
				: "t0", "t1", "memory"
			);

			dst += 16;
 	   	}

      	stop_read = get_counter();
		intvl_read += stop_read - start_read;

		// if(i == 2) printf("CPU read %d = %lu\n", i, stop_read - start_read);
	}

	printf("CPU write = %lu\n", intvl_write/ITERATIONS);
	printf("ACC read = %lu\n", intvl_acc_read/ITERATIONS);
	printf("ACC write = %lu\n", intvl_acc_write/ITERATIONS);
	printf("CPU read = %lu\n", intvl_read/ITERATIONS);
	printf("Total time = %lu\n", (intvl_write + intvl_acc_read + intvl_acc_write + intvl_read)/ITERATIONS);

#else
	/* ********************************************************** */
	/* Baseline Spandex (MESI) */
	/* ********************************************************** */
	printf("Baseline Spandex (MESI)\n");

	spandex_config.spandex_reg = 0;
	iowrite32(dev, SPANDEX_REG, spandex_config.spandex_reg);

	intvl_write = 0;
	intvl_acc_write = 0;
	intvl_read = 0;
	intvl_acc_read = 0;

	for (i = 0; i < ITERATIONS; i++)
	{
		/* TODO: Restore full test once ESP caches are integrated */
		coherence = ACC_COH_FULL;

		// Pass common configuration parameters 
		iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
		iowrite32(dev, COHERENCE_REG, coherence);

		iowrite32(dev, PT_ADDRESS_REG, (unsigned long) ptable);
		iowrite32(dev, PT_NCHUNK_REG, NCHUNK(2*mem_size));
		iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);

		// Use the following if input and output data are not allocated at the default offsets
		iowrite32(dev, SRC_OFFSET_REG, 0);
		iowrite32(dev, DST_OFFSET_REG, 0);

		// Pass accelerator-specific configuration parameters
		/* <<--regs-config-->> */
	    iowrite32(dev, SENSOR_DMA_RD_SP_OFFSET_REG, 2*mem_words);
	    iowrite32(dev, SENSOR_DMA_RD_WR_ENABLE_REG, 0);
	    iowrite32(dev, SENSOR_DMA_RD_SIZE_REG, mem_words);
	    iowrite32(dev, SENSOR_DMA_SRC_OFFSET_REG, 0);

  		void* dst = (void*)(mem);
		int64_t value_64 = 123;

      	start_write = get_counter();

    	for (j = 0; j < mem_words; j+=2)
    	{
			asm volatile (
				"mv t0, %0;"
				"mv t1, %1;"
				".word 0x0062B02B"
				: 
				: "r" (dst), "r" (value_64)
				: "t0", "t1", "memory"
			);

			dst += 16;
    	}

      	stop_write = get_counter();
		intvl_write += stop_write - start_write;

		// if(i == 2) printf("CPU write %d = %lu\n", i, stop_write - start_write);

		// Start accelerators
		iowrite32(dev, CMD_REG, CMD_MASK_START);

      	start_acc_read = get_counter();

		// Wait for completion
		done = 0;
		while (!done) {
			done = ioread32(dev, STATUS_REG);
			done &= STATUS_MASK_DONE;
		}

      	stop_acc_read = get_counter();
		intvl_acc_read += stop_acc_read - start_acc_read;

		// if(i == 2) printf("ACC read %d = %lu\n", i, stop_acc_read - start_acc_read);

		iowrite32(dev, CMD_REG, 0x0);

	    iowrite32(dev, SENSOR_DMA_RD_WR_ENABLE_REG, 1);
	    iowrite32(dev, SENSOR_DMA_WR_SIZE_REG, mem_words);
	    iowrite32(dev, SENSOR_DMA_WR_SP_OFFSET_REG, 2*mem_words);
	    iowrite32(dev, SENSOR_DMA_DST_OFFSET_REG, mem_words);

		// Start accelerators
		iowrite32(dev, CMD_REG, CMD_MASK_START);

      	start_acc_write = get_counter();

		// Wait for completion
		done = 0;
		while (!done) {
			done = ioread32(dev, STATUS_REG);
			done &= STATUS_MASK_DONE;
		}

      	stop_acc_write = get_counter();
		intvl_acc_write += stop_acc_write - start_acc_write;

		// if(i == 2) printf("ACC write %d = %lu\n", i, stop_acc_write - start_acc_write);

		iowrite32(dev, CMD_REG, 0x0);

  		dst = (void*)(gold);

      	start_read = get_counter();

 	   	for (j = 0; j < mem_words; j+=2)
 	   	{
			asm volatile (
				"mv t0, %1;"
				".word 0x0002B30B;"
				"mv %0, t1"
				: "=r" (value_64)
				: "r" (dst)
				: "t0", "t1", "memory"
			);

			dst += 16;
 	   	}

      	stop_read = get_counter();
		intvl_read += stop_read - start_read;

		// if(i == 2) printf("CPU read %d = %lu\n", i, stop_read - start_read);
	}

	printf("CPU write = %lu\n", intvl_write/ITERATIONS);
	printf("ACC read = %lu\n", intvl_acc_read/ITERATIONS);
	printf("ACC write = %lu\n", intvl_acc_write/ITERATIONS);
	printf("CPU read = %lu\n", intvl_read/ITERATIONS);
	printf("Total time = %lu\n", (intvl_write + intvl_acc_read + intvl_acc_write + intvl_read)/ITERATIONS);
#endif
#else
#if (COH_MODE == 3)

	/* ********************************************************** */
	/* Non-Coherent DMA */
	/* ********************************************************** */
	printf("Non-Coherent DMA\n");
	intvl_write = 0;
	intvl_acc_write = 0;
	intvl_read = 0;
	intvl_acc_read = 0;

	for (i = 0; i < ITERATIONS; i++)
	{
		/* TODO: Restore full test once ESP caches are integrated */
		coherence = ACC_COH_NONE;

		// Pass common configuration parameters 
		iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
		iowrite32(dev, COHERENCE_REG, coherence);

		iowrite32(dev, PT_ADDRESS_REG, (unsigned long) ptable);
		iowrite32(dev, PT_NCHUNK_REG, NCHUNK(2*mem_size));
		iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);

		// Use the following if input and output data are not allocated at the default offsets
		iowrite32(dev, SRC_OFFSET_REG, 0);
		iowrite32(dev, DST_OFFSET_REG, 0);

		// Pass accelerator-specific configuration parameters
		/* <<--regs-config-->> */
	    iowrite32(dev, SENSOR_DMA_RD_SP_OFFSET_REG, 2*mem_words);
	    iowrite32(dev, SENSOR_DMA_RD_WR_ENABLE_REG, 0);
	    iowrite32(dev, SENSOR_DMA_RD_SIZE_REG, mem_words);
	    iowrite32(dev, SENSOR_DMA_SRC_OFFSET_REG, 0);

  		void* dst = (void*)(mem);
		int64_t value_64 = 123;

      	start_write = get_counter();

    	for (j = 0; j < mem_words; j+=2)
    	{
			asm volatile (
				"mv t0, %0;"
				"mv t1, %1;"
				".word 0x0062B02B"
				: 
				: "r" (dst), "r" (value_64)
				: "t0", "t1", "memory"
			);

			dst += 16;
    	}

		esp_flush(coherence);

      	stop_write = get_counter();
		intvl_write += stop_write - start_write;

		// if(i == 2) printf("CPU write %d = %lu\n", i, stop_write - start_write);

		// Start accelerators
		iowrite32(dev, CMD_REG, CMD_MASK_START);

      	start_acc_read = get_counter();

		// Wait for completion
		done = 0;
		while (!done) {
			done = ioread32(dev, STATUS_REG);
			done &= STATUS_MASK_DONE;
		}

      	stop_acc_read = get_counter();
		intvl_acc_read += stop_acc_read - start_acc_read;

		// if(i == 2) printf("ACC read %d = %lu\n", i, stop_acc_read - start_acc_read);

		iowrite32(dev, CMD_REG, 0x0);

	    iowrite32(dev, SENSOR_DMA_RD_WR_ENABLE_REG, 1);
	    iowrite32(dev, SENSOR_DMA_WR_SIZE_REG, mem_words);
	    iowrite32(dev, SENSOR_DMA_WR_SP_OFFSET_REG, 2*mem_words);
	    iowrite32(dev, SENSOR_DMA_DST_OFFSET_REG, mem_words);

		// Start accelerators
		iowrite32(dev, CMD_REG, CMD_MASK_START);

      	start_acc_write = get_counter();

		// Wait for completion
		done = 0;
		while (!done) {
			done = ioread32(dev, STATUS_REG);
			done &= STATUS_MASK_DONE;
		}

      	stop_acc_write = get_counter();
		intvl_acc_write += stop_acc_write - start_acc_write;

		// if(i == 2) printf("ACC write %d = %lu\n", i, stop_acc_write - start_acc_write);

		iowrite32(dev, CMD_REG, 0x0);

  		dst = (void*)(gold);

      	start_read = get_counter();

 	   	for (j = 0; j < mem_words; j+=2)
 	   	{
			asm volatile (
				"mv t0, %1;"
				".word 0x0002B30B;"
				"mv %0, t1"
				: "=r" (value_64)
				: "r" (dst)
				: "t0", "t1", "memory"
			);

			dst += 16;
 	   	}

      	stop_read = get_counter();
		intvl_read += stop_read - start_read;

		// if(i == 2) printf("CPU read %d = %lu\n", i, stop_read - start_read);
	}

	printf("CPU write = %lu\n", intvl_write/ITERATIONS);
	printf("ACC read = %lu\n", intvl_acc_read/ITERATIONS);
	printf("ACC write = %lu\n", intvl_acc_write/ITERATIONS);
	printf("CPU read = %lu\n", intvl_read/ITERATIONS);
	printf("Total time = %lu\n", (intvl_write + intvl_acc_read + intvl_acc_write + intvl_read)/ITERATIONS);

#elif (COH_MODE == 2)
	/* ********************************************************** */
	/* LLC Coherent DMA */
	/* ********************************************************** */
	printf("LLC Coherent DMA\n");
	intvl_write = 0;
	intvl_acc_write = 0;
	intvl_read = 0;
	intvl_acc_read = 0;

	for (i = 0; i < ITERATIONS; i++)
	{
		/* TODO: Restore full test once ESP caches are integrated */
		coherence = ACC_COH_LLC;

		// Pass common configuration parameters 
		iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
		iowrite32(dev, COHERENCE_REG, coherence);

		iowrite32(dev, PT_ADDRESS_REG, (unsigned long) ptable);
		iowrite32(dev, PT_NCHUNK_REG, NCHUNK(2*mem_size));
		iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);

		// Use the following if input and output data are not allocated at the default offsets
		iowrite32(dev, SRC_OFFSET_REG, 0);
		iowrite32(dev, DST_OFFSET_REG, 0);

		// Pass accelerator-specific configuration parameters
		/* <<--regs-config-->> */
	    iowrite32(dev, SENSOR_DMA_RD_SP_OFFSET_REG, 2*mem_words);
	    iowrite32(dev, SENSOR_DMA_RD_WR_ENABLE_REG, 0);
	    iowrite32(dev, SENSOR_DMA_RD_SIZE_REG, mem_words);
	    iowrite32(dev, SENSOR_DMA_SRC_OFFSET_REG, 0);

  		void* dst = (void*)(mem);
		int64_t value_64 = 123;

      	start_write = get_counter();

    	for (j = 0; j < mem_words; j+=2)
    	{
			asm volatile (
				"mv t0, %0;"
				"mv t1, %1;"
				".word 0x0062B02B"
				: 
				: "r" (dst), "r" (value_64)
				: "t0", "t1", "memory"
			);

			dst += 16;
    	}

		esp_flush(coherence);

      	stop_write = get_counter();
		intvl_write += stop_write - start_write;

		// if(i == 2) printf("CPU write %d = %lu\n", i, stop_write - start_write);

		// Start accelerators
		iowrite32(dev, CMD_REG, CMD_MASK_START);

      	start_acc_read = get_counter();

		// Wait for completion
		done = 0;
		while (!done) {
			done = ioread32(dev, STATUS_REG);
			done &= STATUS_MASK_DONE;
		}

      	stop_acc_read = get_counter();
		intvl_acc_read += stop_acc_read - start_acc_read;

		// if(i == 2) printf("ACC read %d = %lu\n", i, stop_acc_read - start_acc_read);

		iowrite32(dev, CMD_REG, 0x0);

	    iowrite32(dev, SENSOR_DMA_RD_WR_ENABLE_REG, 1);
	    iowrite32(dev, SENSOR_DMA_WR_SIZE_REG, mem_words);
	    iowrite32(dev, SENSOR_DMA_WR_SP_OFFSET_REG, 2*mem_words);
	    iowrite32(dev, SENSOR_DMA_DST_OFFSET_REG, mem_words);

		// Start accelerators
		iowrite32(dev, CMD_REG, CMD_MASK_START);

      	start_acc_write = get_counter();

		// Wait for completion
		done = 0;
		while (!done) {
			done = ioread32(dev, STATUS_REG);
			done &= STATUS_MASK_DONE;
		}

      	stop_acc_write = get_counter();
		intvl_acc_write += stop_acc_write - start_acc_write;

		// if(i == 2) printf("ACC write %d = %lu\n", i, stop_acc_write - start_acc_write);

		iowrite32(dev, CMD_REG, 0x0);

  		dst = (void*)(gold);

      	start_read = get_counter();

 	   	for (j = 0; j < mem_words; j+=2)
 	   	{
			asm volatile (
				"mv t0, %1;"
				".word 0x0002B30B;"
				"mv %0, t1"
				: "=r" (value_64)
				: "r" (dst)
				: "t0", "t1", "memory"
			);

			dst += 16;
 	   	}

      	stop_read = get_counter();
		intvl_read += stop_read - start_read;

		// if(i == 2) printf("CPU read %d = %lu\n", i, stop_read - start_read);
	}

	printf("CPU write = %lu\n", intvl_write/ITERATIONS);
	printf("ACC read = %lu\n", intvl_acc_read/ITERATIONS);
	printf("ACC write = %lu\n", intvl_acc_write/ITERATIONS);
	printf("CPU read = %lu\n", intvl_read/ITERATIONS);
	printf("Total time = %lu\n", (intvl_write + intvl_acc_read + intvl_acc_write + intvl_read)/ITERATIONS);

#elif (COH_MODE == 1)
	/* ********************************************************** */
	/* Coherent DMA */
	/* ********************************************************** */
	printf("Coherent DMA\n");
	intvl_write = 0;
	intvl_acc_write = 0;
	intvl_read = 0;
	intvl_acc_read = 0;

	for (i = 0; i < ITERATIONS; i++)
	{
		/* TODO: Restore full test once ESP caches are integrated */
		coherence = ACC_COH_RECALL;

		// Pass common configuration parameters 
		iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
		iowrite32(dev, COHERENCE_REG, coherence);

		iowrite32(dev, PT_ADDRESS_REG, (unsigned long) ptable);
		iowrite32(dev, PT_NCHUNK_REG, NCHUNK(2*mem_size));
		iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);

		// Use the following if input and output data are not allocated at the default offsets
		iowrite32(dev, SRC_OFFSET_REG, 0);
		iowrite32(dev, DST_OFFSET_REG, 0);

		// Pass accelerator-specific configuration parameters
		/* <<--regs-config-->> */
	    iowrite32(dev, SENSOR_DMA_RD_SP_OFFSET_REG, 2*mem_words);
	    iowrite32(dev, SENSOR_DMA_RD_WR_ENABLE_REG, 0);
	    iowrite32(dev, SENSOR_DMA_RD_SIZE_REG, mem_words);
	    iowrite32(dev, SENSOR_DMA_SRC_OFFSET_REG, 0);

  		void* dst = (void*)(mem);
		int64_t value_64 = 123;

      	start_write = get_counter();

    	for (j = 0; j < mem_words; j+=2)
    	{
			asm volatile (
				"mv t0, %0;"
				"mv t1, %1;"
				".word 0x0062B02B"
				: 
				: "r" (dst), "r" (value_64)
				: "t0", "t1", "memory"
			);

			dst += 16;
    	}

      	stop_write = get_counter();
		intvl_write += stop_write - start_write;

		// if(i == 2) printf("CPU write %d = %lu\n", i, stop_write - start_write);

		// Start accelerators
		iowrite32(dev, CMD_REG, CMD_MASK_START);

      	start_acc_read = get_counter();

		// Wait for completion
		done = 0;
		while (!done) {
			done = ioread32(dev, STATUS_REG);
			done &= STATUS_MASK_DONE;
		}

      	stop_acc_read = get_counter();
		intvl_acc_read += stop_acc_read - start_acc_read;

		// if(i == 2) printf("ACC read %d = %lu\n", i, stop_acc_read - start_acc_read);

		iowrite32(dev, CMD_REG, 0x0);

	    iowrite32(dev, SENSOR_DMA_RD_WR_ENABLE_REG, 1);
	    iowrite32(dev, SENSOR_DMA_WR_SIZE_REG, mem_words);
	    iowrite32(dev, SENSOR_DMA_WR_SP_OFFSET_REG, 2*mem_words);
	    iowrite32(dev, SENSOR_DMA_DST_OFFSET_REG, mem_words);

		// Start accelerators
		iowrite32(dev, CMD_REG, CMD_MASK_START);

      	start_acc_write = get_counter();

		// Wait for completion
		done = 0;
		while (!done) {
			done = ioread32(dev, STATUS_REG);
			done &= STATUS_MASK_DONE;
		}

      	stop_acc_write = get_counter();
		intvl_acc_write += stop_acc_write - start_acc_write;

		// if(i == 2) printf("ACC write %d = %lu\n", i, stop_acc_write - start_acc_write);

		iowrite32(dev, CMD_REG, 0x0);

  		dst = (void*)(gold);

      	start_read = get_counter();

 	   	for (j = 0; j < mem_words; j+=2)
 	   	{
			asm volatile (
				"mv t0, %1;"
				".word 0x0002B30B;"
				"mv %0, t1"
				: "=r" (value_64)
				: "r" (dst)
				: "t0", "t1", "memory"
			);

			dst += 16;
 	   	}

      	stop_read = get_counter();
		intvl_read += stop_read - start_read;

		// if(i == 2) printf("CPU read %d = %lu\n", i, stop_read - start_read);
	}

	printf("CPU write = %lu\n", intvl_write/ITERATIONS);
	printf("ACC read = %lu\n", intvl_acc_read/ITERATIONS);
	printf("ACC write = %lu\n", intvl_acc_write/ITERATIONS);
	printf("CPU read = %lu\n", intvl_read/ITERATIONS);
	printf("Total time = %lu\n", (intvl_write + intvl_acc_read + intvl_acc_write + intvl_read)/ITERATIONS);

#else
	/* ********************************************************** */
	/* Fully Coherent MESI */
	/* ********************************************************** */
	printf("Fully Coherent MESI\n");
	intvl_write = 0;
	intvl_acc_write = 0;
	intvl_read = 0;
	intvl_acc_read = 0;

	for (i = 0; i < ITERATIONS; i++)
	{
		/* TODO: Restore full test once ESP caches are integrated */
		coherence = ACC_COH_FULL;

		// Pass common configuration parameters 
		iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
		iowrite32(dev, COHERENCE_REG, coherence);

		iowrite32(dev, PT_ADDRESS_REG, (unsigned long) ptable);
		iowrite32(dev, PT_NCHUNK_REG, NCHUNK(2*mem_size));
		iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);

		// Use the following if input and output data are not allocated at the default offsets
		iowrite32(dev, SRC_OFFSET_REG, 0);
		iowrite32(dev, DST_OFFSET_REG, 0);

		// Pass accelerator-specific configuration parameters
		/* <<--regs-config-->> */
	    iowrite32(dev, SENSOR_DMA_RD_SP_OFFSET_REG, 2*mem_words);
	    iowrite32(dev, SENSOR_DMA_RD_WR_ENABLE_REG, 0);
	    iowrite32(dev, SENSOR_DMA_RD_SIZE_REG, mem_words);
	    iowrite32(dev, SENSOR_DMA_SRC_OFFSET_REG, 0);

  		void* dst = (void*)(mem);
		int64_t value_64 = 123;

      	start_write = get_counter();

    	for (j = 0; j < mem_words; j+=2)
    	{
			asm volatile (
				"mv t0, %0;"
				"mv t1, %1;"
				".word 0x0062B02B"
				: 
				: "r" (dst), "r" (value_64)
				: "t0", "t1", "memory"
			);

			dst += 16;
    	}

      	stop_write = get_counter();
		intvl_write += stop_write - start_write;

		// if(i == 2) printf("CPU write %d = %lu\n", i, stop_write - start_write);

		// Start accelerators
		iowrite32(dev, CMD_REG, CMD_MASK_START);

      	start_acc_read = get_counter();

		// Wait for completion
		done = 0;
		while (!done) {
			done = ioread32(dev, STATUS_REG);
			done &= STATUS_MASK_DONE;
		}

      	stop_acc_read = get_counter();
		intvl_acc_read += stop_acc_read - start_acc_read;

		// if(i == 2) printf("ACC read %d = %lu\n", i, stop_acc_read - start_acc_read);

		iowrite32(dev, CMD_REG, 0x0);

	    iowrite32(dev, SENSOR_DMA_RD_WR_ENABLE_REG, 1);
	    iowrite32(dev, SENSOR_DMA_WR_SIZE_REG, mem_words);
	    iowrite32(dev, SENSOR_DMA_WR_SP_OFFSET_REG, 2*mem_words);
	    iowrite32(dev, SENSOR_DMA_DST_OFFSET_REG, mem_words);

		// Start accelerators
		iowrite32(dev, CMD_REG, CMD_MASK_START);

      	start_acc_write = get_counter();

		// Wait for completion
		done = 0;
		while (!done) {
			done = ioread32(dev, STATUS_REG);
			done &= STATUS_MASK_DONE;
		}

      	stop_acc_write = get_counter();
		intvl_acc_write += stop_acc_write - start_acc_write;

		// if(i == 2) printf("ACC write %d = %lu\n", i, stop_acc_write - start_acc_write);

		iowrite32(dev, CMD_REG, 0x0);

  		dst = (void*)(gold);

      	start_read = get_counter();

 	   	for (j = 0; j < mem_words; j+=2)
 	   	{
			asm volatile (
				"mv t0, %1;"
				".word 0x0002B30B;"
				"mv %0, t1"
				: "=r" (value_64)
				: "r" (dst)
				: "t0", "t1", "memory"
			);

			dst += 16;
 	   	}

      	stop_read = get_counter();
		intvl_read += stop_read - start_read;

		// if(i == 2) printf("CPU read %d = %lu\n", i, stop_read - start_read);
	}

	printf("CPU write = %lu\n", intvl_write/ITERATIONS);
	printf("ACC read = %lu\n", intvl_acc_read/ITERATIONS);
	printf("ACC write = %lu\n", intvl_acc_write/ITERATIONS);
	printf("CPU read = %lu\n", intvl_read/ITERATIONS);
	printf("Total time = %lu\n", (intvl_write + intvl_acc_read + intvl_acc_write + intvl_read)/ITERATIONS);

#endif
#endif
	
	aligned_free(ptable);
	aligned_free(mem);
	aligned_free(gold);

	// while(1);

	return 0;
}
