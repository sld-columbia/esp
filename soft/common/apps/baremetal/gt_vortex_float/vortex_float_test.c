/* Copyright (c) 2011-2025 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>
#include "monitors.h"
#include "soc_locs.h"
#define FFT_FX_WIDTH 32

/*
 * Bare-metal Vortex floating-point test:
 * - A prebuilt image in input.h initializes data and kernel code.
 * - Vortex runs from that image and updates a known 64-bit slot.
 * - Host reads the slot before/after to validate floating-point execution.
 */

#if (FFT_FX_WIDTH == 64)
typedef long long token_t;
typedef double native_t;
#define fx2float fixed64_to_double
#define float2fx double_to_fixed64
#define FX_IL 42
#else // (FFT_FX_WIDTH == 32)
typedef int token_t;
typedef float native_t;
typedef long long token_t_l;
#define fx2float fixed32_to_float
#define float2fx float_to_fixed32
#define FX_IL 12
#endif /* FFT_FX_WIDTH */

const float ERR_TH = 0.05;

static unsigned DMA_WORD_PER_BEAT(unsigned _st)
{
        return (sizeof(void *) / _st);
}

#define DEV_NAME "GATech,gt_vortex"
#define START_VORTEX 1

#define CSR_CFG_BASE_WORD (0x180 / sizeof(unsigned int))
#define COH_REG_INDEX     (CSR_CFG_BASE_WORD + 3) /* ESP_CSR_ACC_COH_ADDR */

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
#define VX_BUSY_INT	    0x58 // Vortex busy signal read only	 
#define VX_DCR_ADDR0    0x60
#define VX_DCR_ADDR1    0x64
#define VX_DCR_ARG0     0x68
#define VX_DCR_ARG1     0x6C
#define MPM_CLASS       0x70

static void init_buf(token_t *in)
{
 /* input.h embeds the precompiled Vortex memory image. */
 #include "input.h"
}

static int acc_id_from_irq_line(int irq_line)
{
#ifdef __riscv
	int acc_irq = 5;
#else
	int acc_irq = 3;
#endif
	for (int acc_id = 0; acc_id < SOC_NACC; acc_id++) {
		if (acc_irq == irq_line)
			return acc_id;
		acc_irq++;
#ifdef __riscv
		if (acc_irq == 11)
			acc_irq = 13;
#endif
	}
	return -1;
}

static int tile_id_from_irq_line(int irq_line)
{
	int acc_id = acc_id_from_irq_line(irq_line);

	if (acc_id < 0 || acc_id >= SOC_NACC)
		return -1;

	return acc_locs[acc_id].row * SOC_COLS + acc_locs[acc_id].col;
}

static int dev_irq_line(const struct esp_device *dev)
{
#ifdef __riscv
	if (dev->irq == 0)
		return -1;
	return (int)dev->irq - 1;
#else
	return (int)dev->irq;
#endif
}

static unsigned select_vortex_coherence(struct esp_device *dev)
{
	unsigned coh_caps = ioread32(dev, COHERENCE_REG) & 0x3;

	/* Vortex uses DMA traffic, so choose the strongest DMA-safe mode. */
	if (coh_caps == ACC_COH_FULL || coh_caps == ACC_COH_RECALL)
		return ACC_COH_RECALL;
	if (coh_caps == ACC_COH_LLC)
		return ACC_COH_LLC;
	return ACC_COH_NONE;
}



int main(int argc, char * argv[])
{
	int i;
	int n;
	int ndev;
	struct esp_device *espdevs;
	struct esp_device fallback_dev;
	struct esp_device *dev;
	unsigned done;
	token_t *mem;
	unsigned errors = 0;
	unsigned coherence;
    const int ERROR_COUNT_TH = 0.001;
	token_t_l *output;
	
    len = 1 << log_len;

	in_len   =  in_words_adj;
	out_len  =  out_words_adj;
	in_size  =  in_len * sizeof(token_t);
	out_size =  out_len * sizeof(token_t);
	out_offset  = 0;
	unsigned int _program_bin_len_in_words = 6976/4;
	mem_size = _program_bin_len_in_words * sizeof(token_t);
	unsigned int coh;
    unsigned int tile_offset;
    unsigned int * coh_reg_addr;

	// Search for the device
	printf("Scanning device tree... \n");

	ndev = probe(&espdevs, 0, 0, DEV_NAME);

#ifndef __riscv
	if (ndev == 0) {
		fallback_dev.addr = 0x60400000;
		fallback_dev.irq  = 0;
		espdevs = &fallback_dev;
		ndev = 1;
		printf("  Warning: probe failed, using default Vortex address 0x60400000\n");
	}
#endif

	if (ndev == 0) {
		printf("Vortex GPU not found\n");
		return 0;
	} //FIXME

	for (n = 0; n < ndev; n++) {

		printf("**************** %s.%d ****************\n", DEV_NAME, n);

		dev = &espdevs[n];

		// Allocate memory
		mem = aligned_malloc(mem_size);
		printf("  memory buffer base-address = %p\n", mem);
		init_buf(mem);

		intptr_t mem_top = (intptr_t)mem; 
		/* Location used by this test kernel to store the FP result. */
		output = (token_t_l*)(mem_top+0x00001b38);
		printf("**************** Memory Details ****************\n");
		printf("  memory buffer base-address = %x\n", (intptr_t)(mem));
		printf(" Last word address: %x \n", (intptr_t)(mem+_program_bin_len_in_words-1));

		// Select coherence from hardware capability and flush.
        coh = select_vortex_coherence(dev);
		int tile_id = tile_id_from_irq_line(dev_irq_line(dev));
		if (tile_id >= 0) {
			tile_offset = (MONITOR_TILE_SIZE / sizeof(unsigned int)) * tile_id;
			coh_reg_addr = ((unsigned int *)MONITOR_BASE_ADDR) + tile_offset + COH_REG_INDEX;
			*coh_reg_addr = coh;
		} else {
			printf("  Warning: could not resolve Vortex tile (irq=%u). Skipping coherence config.\n", dev->irq);
		}
        esp_flush(coh);

#ifndef __riscv
		for (coherence = ACC_COH_NONE; coherence <= ACC_COH_FULL; coherence++) {
#else
		{
			/* TODO: Restore full test once ESP caches are integrated */
			coherence = ACC_COH_NONE;
#endif
			
			printf(" Starting value of double in Vortex = %llx \n", *(output));
			
			printf("  --------------------\n");
			printf("  Entering GPU instance \n");

			// Pass accelerator-specific configuration parameters
			/* <<--regs-config-->> */
			// FIXME: READ BUSY EARLIER
                        // Wait for completion  
			
			// Set memory offset
			/* Program-visible address 0 maps to this host pointer. */
		        	
			iowrite32(dev, VX_BASE_ADDR, mem_top);
			iowrite32(dev, VX_DCR_ADDR0, 0);
			iowrite32(dev, VX_DCR_ADDR1, 0);
							
			// Start accelerators

			// START_VORTEX
			/* Trigger wrapper start logic (DCR load + reset pulse). */
			iowrite32(dev, VX_SOFT_RESET, START_VORTEX);

			printf("  Start...\n");
			vortex_busy = ioread32(dev, VX_BUSY_INT);
			vortex_busy &= BIT(0);
			// Since higher order bits may contain routing headers
			printf("  Busy Reg Value = %d \n", vortex_busy);
			// Wait for completion	

			while (vortex_busy==1) {
		        printf("  Running GPU workload...\n");
		        vortex_busy = ioread32(dev, VX_BUSY_INT);
			    vortex_busy &= BIT(0); // Since higher order bits may contain routing headers
			    printf(" Busy Reg Value = %d \n", vortex_busy);
			}	

			/*
			 * The seeded-value debug prints above can repopulate stale cache lines.
			 * Flush again after Vortex completes so CPU reads observe the updated
			 * DDR contents on cache-enabled systems.
			 */
			esp_flush(coh);
			
			printf(" Final value of double in Vortex = %llx \n", *(output));
			

			printf("  Done\n");
		}
		aligned_free(mem);
	}
	return 0;
}
