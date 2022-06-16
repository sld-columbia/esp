/* Copyright (c) 2011-2022 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>
#include <fixed_point.h>

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

#define ITERATIONS 10
#define ESP
#define COH_MODE 0
/* 3 - Owner Prediction, 2 - Write-through forwarding, 1 - Baseline Spandex (ReqV), 0 - Baseline Spandex (MESI) */
/* 3 - Non-Coherent DMA, 2 - LLC Coherent DMA, 1 - Coherent DMA, 0 - Fully Coherent MESI */

#define SLD_SM_SENSOR 0x051
#define DEV_NAME "sld,sm_sensor_stratus"

/* Size of the contiguous chunks for scatter/gather */
#define CHUNK_SHIFT 20
#define CHUNK_SIZE BIT(CHUNK_SHIFT)
#define NCHUNK(_sz) ((_sz % CHUNK_SIZE == 0) ?		\
			(_sz / CHUNK_SIZE) :		\
			(_sz / CHUNK_SIZE) + 1)

/* User defined registers */
/* <<--regs-->> */
#define SM_SENSOR_SIZE_REG 0x40


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
	ndev = probe(&espdevs, VENDOR_SLD, SLD_SM_SENSOR, DEV_NAME);
	if (ndev == 0) {
		printf("sm_sensor not found\n");
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
	mem = (token_t *) aligned_malloc(((ITERATIONS+2)*mem_size)+10);
	gold = mem + mem_words;
	printf("  memory = %p\n", mem);
	printf("  gold = %p\n", gold);

	volatile token_t* sm_sync = (volatile token_t*) mem;
		
	// Alocate and populate page table
	ptable = aligned_malloc(NCHUNK(2*mem_size) * sizeof(unsigned *));
	for (i = 0; i < NCHUNK(2*mem_size); i++)
		ptable[i] = (unsigned *) &mem[i * (CHUNK_SIZE / sizeof(token_t))];

	printf("  ptable = %p\n", ptable);
	printf("  nchunk = %lu\n", NCHUNK(2*mem_size));

	for (j = 0; j < 10; j++)
		sm_sync[j] = 0;

    asm volatile ("fence rw, rw");

	/* ********************************************************** */
	/* Fully Coherent MESI */
	/* ********************************************************** */
	printf("Fully Coherent MESI\n");

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

	// Start accelerators
	iowrite32(dev, CMD_REG, CMD_MASK_START);

	for (i = 0; i < ITERATIONS; i++)
	{
		for (j = 0; j < mem_words; j++)
			mem[j+10] = (j+i)*2;

		// Op 1 - load mem_words data from 0 in mem to mem_words in SP
		sm_sync[1] = 0; // load/store
		sm_sync[2] = 0; // abort
		sm_sync[3] = mem_words; // rd_size
		sm_sync[4] = mem_words; // rd_sp_offset
		sm_sync[5] = 0; // src_offset

		sm_sync[0] = 1;
		while(sm_sync[0] != 0);

		// Op 2 - store mem_words data from mem_words in SP to mem_words in mem, and abort
		sm_sync[1] = 1; // load/store
		sm_sync[6] = (i+1)/ITERATIONS; // abort
		sm_sync[7] = mem_words; // wr_size
		sm_sync[8] = mem_words; // wr_sp_offset
		sm_sync[9] = (i+1)*mem_words; // dst_offset

		sm_sync[0] = 1;
		while(sm_sync[0] != 0);

		if(i == ITERATIONS)
		{
			// Wait for completion
			done = 0;
			while (!done) {
				done = ioread32(dev, STATUS_REG);
				done &= STATUS_MASK_DONE;
			}

			iowrite32(dev, CMD_REG, 0x0);
		}

		for (j = 0; j < mem_words; j++)
		{
			if (gold[i*mem_words+j+10] != (j+i)*2)
			{
				errors++;
			}
		}

		printf("Errors = %d\n", errors);
	}

	aligned_free(ptable);
	aligned_free(mem);
	aligned_free(gold);

	// while(1);

	return 0;
}
