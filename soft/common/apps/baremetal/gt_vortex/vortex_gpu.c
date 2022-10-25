/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>
#define FFT_FX_WIDTH 32

#if (FFT_FX_WIDTH == 64)
typedef long long token_t;
typedef double native_t;
#define fx2float fixed64_to_double
#define float2fx double_to_fixed64
#define FX_IL 42
#else // (FFT_FX_WIDTH == 32)
typedef int token_t;
typedef float native_t;
#define fx2float fixed32_to_float
#define float2fx float_to_fixed32
#define FX_IL 12
#endif /* FFT_FX_WIDTH */

const float ERR_TH = 0.05;

static unsigned DMA_WORD_PER_BEAT(unsigned _st)
{
        return (sizeof(void *) / _st);
}


#define GT_VORTEX 0x108
#define DEV_NAME "GATech,gt_vortex"
#define START_VORTEX 1
#define  BASE_ADDR 0x20000000
#define VX_ADDR 0x60400000+0x100000+3

#define CSR_TILE_SIZE 0x200
#define CSR_BASE_ADDR 0x60090000
#define COH_REG_INDEX 107

/* <<--params-->> */
const int32_t log_len = 3;
int32_t len;
int32_t vortex_busy; // Stores polled value of busy signal

static unsigned in_words_adj;
static unsigned out_words_adj;
static unsigned in_len;
static unsigned out_len;
static unsigned in_size;
static unsigned out_size;
static unsigned out_offset;
static unsigned mem_size;

/* Size of the contiguous chunks for scatter/gather */
#define CHUNK_SHIFT 20
#define CHUNK_SIZE BIT(CHUNK_SHIFT)
#define NCHUNK(_sz) ((_sz % CHUNK_SIZE == 0) ?		\
			(_sz / CHUNK_SIZE) :		\
			(_sz / CHUNK_SIZE) + 1)

/* Configuration registers */
/* <<--regs-->> */
#define VX_BASE_ADDR    0x50
#define VX_SOFT_RESET   0x54
#define VX_BUSY_INT	0x58 // Vortex busy signal read only	 

/*static int validate_buf(token_t *out, float *gold)
{
	int j;
	unsigned errors = 0;

	for (j = 0; j < 2 * len; j++) {
		native_t val = fx2float(out[j], FX_IL);
		if ((fabs(gold[j] - val) / fabs(gold[j])) > ERR_TH)
			errors++;
	}

	printf("  %u errors\n", errors);
	return errors;
}*/


static void init_buf(token_t *in)
{
 #include "input.h"
}

int fibonacci(int n)
{
	if (n <= 1) 
	  return n; 
        return fibonacci(n - 1) + fibonacci(n - 2); 
}


int main(int argc, char * argv[])
{
	int i;
	int n;
	int ndev;
	struct esp_device *espdevs;
	struct esp_device *dev;
	unsigned done;
	unsigned **ptable = NULL;
	token_t *mem;
	int output_golden;
	unsigned errors = 0;
	unsigned coherence;
        const int ERROR_COUNT_TH = 0.001;
	unsigned int vx_tile_numbers[1] = {2};
        // const intptr_t src_addr = 0x7fff0; 
        // const intptr_t dst_addr = 0x7fff4; 	
	token_t *input_n;
	int input_n_val; // Since Vortex writes to this location, storing this value. 
	token_t *output_computed;
	
        len = 1 << log_len;

	/*if (DMA_WORD_PER_BEAT(sizeof(token_t)) == 0) {
		in_words_adj = 2 * len;
		out_words_adj = 2 * len;
	} else {
		in_words_adj = round_up(2 * len, DMA_WORD_PER_BEAT(sizeof(token_t)));
		out_words_adj = round_up(2 * len, DMA_WORD_PER_BEAT(sizeof(token_t)));
	}*/

	in_len   =  in_words_adj;
	out_len  =  out_words_adj;
	in_size  =  in_len * sizeof(token_t);
	out_size =  out_len * sizeof(token_t);
	out_offset  = 0;
	unsigned int _fibonacci_bin_len_in_words = 7780/4; 
	mem_size = _fibonacci_bin_len_in_words * sizeof(token_t);
	unsigned int coh;
        unsigned int tile_offset;
        unsigned int * coh_reg_addr;

	// Search for the device
	printf("Scanning device tree... \n");

	ndev = 1;  
	probe(&espdevs, VENDOR_SLD, GT_VORTEX, DEV_NAME);
	if (ndev == 0) {
		printf("Vortex GPU not found\n");
		return 0;
	} //FIXME
        
	for (n = 0; n < ndev; n++) {

		printf("**************** %s.%d ****************\n", DEV_NAME, n);

		dev = &espdevs[n];

		// Allocate memory
		// gold = aligned_malloc(out_len * sizeof(float));
		mem = aligned_malloc(mem_size);
		// printf("  memory buffer base-address = %p\n", mem);
		init_buf(mem);
		
		intptr_t mem_top = (intptr_t)mem; 
	        input_n  =   (token_t*) (mem_top+0x7fff0); //(mem+0x7fff0)
		input_n_val = 5; 
		*input_n = input_n_val; // Assigning input value to memory
			
		output_computed = (token_t*)(mem_top+0x7fff4); //(mem+0x7fff4) 	
	        output_golden = fibonacci(input_n_val); 
		printf("**************** Memory Details ****************\n");
		printf("  memory buffer base-address = %x\n", (intptr_t)(mem));
		printf(" Last word address: %x \n", (intptr_t)(mem+_fibonacci_bin_len_in_words-1));
		// Allocate and populate page table
		// ptable = aligned_malloc(NCHUNK(mem_size) * sizeof(unsigned *));
		// printf("  nchunk = %lu\n", NCHUNK(mem_size));

		// Write coherence mode and flush (customize coherence model here)
                tile_offset = (CSR_TILE_SIZE / sizeof(unsigned int)) * vx_tile_numbers[n];
                coh_reg_addr = ((unsigned int*) CSR_BASE_ADDR) + tile_offset + COH_REG_INDEX;
                coh = ACC_COH_RECALL;
                *coh_reg_addr = coh;
                esp_flush(coh);

#ifndef __riscv
		for (coherence = ACC_COH_NONE; coherence <= ACC_COH_FULL; coherence++) {
#else
		{
			/* TODO: Restore full test once ESP caches are integrated */
			coherence = ACC_COH_NONE;
#endif
			printf("  --------------------\n");
			printf("  Entering GPU instance \n");

			// Pass accelerator-specific configuration parameters
			/* <<--regs-config-->> */
			
			// Set memory offset
		        	
			iowrite32(dev, VX_BASE_ADDR, mem_top); // -0x20000000

                        
			// Start accelerators
			printf("  Start...\n");

			// START_VORTEX
			iowrite32(dev, VX_SOFT_RESET, START_VORTEX);

			vortex_busy = ioread32(dev, VX_BUSY_INT);
			vortex_busy &= BIT(0);
			// Since higher order bits may contain routing headers
			printf("  Busy Reg Value = %d \n", vortex_busy);
			// Wait for completion
			vortex_busy =  ioread32(dev, VX_BUSY_INT);
                        vortex_busy &= BIT(0);
			
			while (vortex_busy==1) {
		            printf("  Running GPU workload...\n");
		            vortex_busy = ioread32(dev, VX_BUSY_INT);
			    vortex_busy &= BIT(0); // Since higher order bits may contain routing headers
			    // printf(" Busy Reg Value = %d \n", vortex_busy);
			}
			if(*output_computed != output_golden)
			{	
				errors+=1;
			}
			if(errors){
			   printf("Completed run with %d mismatches between computed and golden outputs.", errors); 
			
			}	

			printf("  Value of %dth fibbonacci after computation in Vortex = %llu \n",input_n_val, *(output_computed));
			printf("  Done\n");
		}
		aligned_free(ptable);
		aligned_free(mem);
	}
	return 0;
}
