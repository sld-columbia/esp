/**
 * Baremetal device driver for VivadoHLS accelerators
 *
 * Select Scatter-Gather in ESP configuration
 */

#ifndef __riscv
#include <stdio.h>
#endif
#include <stdlib.h>
#include <esp_accelerator.h>
#include <esp_probe.h>

/////////////////////////////////
// TODO include accelerators configuration header
//      instead of copying its content here
// #include "espacc_config.h"
// In/out arrays
#define SIZE_IN_CHUNK_DATA 64
#define SIZE_OUT_CHUNK_DATA 32
/////////////////////////////////

/////////////////////////////////
// TODO read HLS config directly from the accelerator registers
//      instead of setting it here
#ifndef __riscv
#define DMA_SIZE  32
#else
#define DMA_SIZE  64
#endif

#define DATA_BITWIDTH 32
typedef int32_t word_t;
/////////////////////////////////

// Specify accelerator type
#define SLD_ADDER   0x40
#define DEV_NAME "sld,adder"

// Sizes
#define NINVOKE 4
#define NBURSTS 4
#define IN_SIZE_DATA (SIZE_IN_CHUNK_DATA * NBURSTS)
#define OUT_SIZE_DATA (SIZE_OUT_CHUNK_DATA * NBURSTS)
#define IN_SIZE (IN_SIZE_DATA * sizeof(word_t))
#define OUT_SIZE (OUT_SIZE_DATA * sizeof(word_t))
#define SIZE_DATA (IN_SIZE_DATA + OUT_SIZE_DATA)
#define SIZE (IN_SIZE + OUT_SIZE)

/* Size of the contiguous chunks for scatter/gather */
#define CHUNK_SHIFT 9
#define CHUNK_SIZE BIT(CHUNK_SHIFT)
#define NCHUNK ((SIZE % CHUNK_SIZE == 0) ?		\
		(SIZE / CHUNK_SIZE) :			\
		(SIZE / CHUNK_SIZE) + 1)

// User defined registers
#define NBURSTS_REG   0x40

//#define VERBOSE

int main(int argc, char * argv[])
{
    int n, k;
    int ndev;
    struct esp_device *espdevs = NULL;
    unsigned coherence;

#ifndef __riscv
    printf("STARTING!\n");
#else
    print_uart("STARTING!\n");
#endif

    ndev = probe(&espdevs, SLD_ADDER, DEV_NAME);
    if (!ndev) {
#ifndef __riscv
	    printf("Error: device not found!");
#else
	    print_uart("Error: device not found!");
#endif
#ifndef __riscv
	    printf(DEV_NAME);
#else
	    print_uart(DEV_NAME);
#endif
	exit(EXIT_FAILURE);
    }

    for (n = 0; n < ndev; n++) {

	for (k = 0; k < NINVOKE; ++k) {

	    coherence = ACC_COH_NONE;

	    struct esp_device *dev = &espdevs[n];
	    int done;
	    int i;
	    unsigned **ptable;
	    word_t *mem;
	    unsigned errors = 0;
	    int scatter_gather = 1;

#ifndef __riscv
	    printf("\n********************************\n");
	    printf("Process input # ");
	    printf("%u\n", (unsigned) k);
#else
	    print_uart("\n********************************\n");
	    print_uart("Process input # ");
	    print_uart_int((uint32_t) k);
	    print_uart("\n");
#endif

	    // Check access ok (TODO)

	    // Check if scatter-gather DMA is disabled
	    if (ioread32(dev, PT_NCHUNK_MAX_REG) == 0) {
#ifndef __riscv
		    printf("  -> scatter-gather DMA is disabled; revert to contiguous buffer.\n");
#else
		    print_uart("  -> scatter-gather DMA is disabled; revert to contiguous buffer.\n");
#endif
		scatter_gather = 0;
	    } else {
#ifndef __riscv
		    printf("  -> scatter-gather DMA is enabled.\n");
#else
		    print_uart("  -> scatter-gather DMA is enabled.\n");
#endif
	    }

	    if (scatter_gather) {
		if (ioread32(dev, PT_NCHUNK_MAX_REG) < NCHUNK) {
#ifndef __riscv
		    printf("  Trying to allocate # chunks on # TLB available entries: \n");
		    printf("%u\t%u\n", (unsigned) NCHUNK, (unsigned) ioread32(dev, PT_NCHUNK_MAX_REG));
#else
		    print_uart("  Trying to allocate # chunks on # TLB available entries: \n");
		    print_uart_int(NCHUNK);
		    print_uart("\t");
		    print_uart_int((unsigned) ioread32(dev, PT_NCHUNK_MAX_REG));
		    print_uart("\n");
#endif
		    break;
		}
	    }

	    // Allocate memory (will be contiguos anyway in baremetal)
	    mem = aligned_malloc(SIZE);
#ifndef __riscv
	    printf("  memory buffer base-address = %lu\n", (unsigned long) mem);
#else
	    print_uart("  memory buffer base-address = ");
	    print_uart_addr((uint64_t) mem);
	    print_uart("\n");
#endif
	    if (scatter_gather) {
		// Allocate and populate page table
		ptable = aligned_malloc(NCHUNK * sizeof(unsigned *));
		for (i = 0; i < NCHUNK; i++)
		    ptable[i] = (unsigned *)
			&mem[i * (CHUNK_SIZE / sizeof(unsigned))];

#ifndef __riscv
		printf("  ptable = %p\n", ptable);
		printf("  nchunk = %lu\n", NCHUNK);
#else
		print_uart("  ptable = "); print_uart_addr((uintptr_t) ptable); print_uart("\n");
		print_uart("  nchunk = "); print_uart_int(NCHUNK); print_uart("\n");
#endif
	    }

	    // Initialize input and output
	    for (i = 0; i < IN_SIZE_DATA; ++i)
		mem[i] = i;
	    for (; i < SIZE_DATA; ++i)
		mem[i] = 63;

	    // Allocate memory for gold output
	    word_t *mem_gold;
	    mem_gold = aligned_malloc(OUT_SIZE);
#ifndef __riscv
	    printf("  memory buffer base-address = %lu\n", (unsigned long) mem_gold);
#else
	    print_uart("  memory buffer base-address = ");
	    print_uart_addr((uint64_t) mem_gold);
	    print_uart("\n");
#endif

	    // Populate memory for gold output
	    for (i = 0; i < OUT_SIZE_DATA; ++i) {
		mem_gold[i] = mem[i*2] + mem[i*2+1];
	    }

	    // Configure device
	    iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
	    iowrite32(dev, COHERENCE_REG, coherence);

	    if (scatter_gather) {
		iowrite32(dev, PT_ADDRESS_REG, (unsigned long) ptable);
		iowrite32(dev, PT_NCHUNK_REG, NCHUNK);
		iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);
		iowrite32(dev, SRC_OFFSET_REG, 0);
		iowrite32(dev, DST_OFFSET_REG, 0);
	    } else {
		iowrite32(dev, SRC_OFFSET_REG, (unsigned long) mem);
		iowrite32(dev, DST_OFFSET_REG, (unsigned long) mem);
	    }

	    // Accelerator-specific registers
	    iowrite32(dev, NBURSTS_REG, 4);

	    // Flush for non-coherent DMA
	    esp_flush(coherence);

	    // Start accelerator
#ifndef __riscv
	    printf("  Start..\n");
#else
	    print_uart("  Start..\n");
#endif
	    iowrite32(dev, CMD_REG, CMD_MASK_START);

	    done = 0;

	    while (!done) {
		done = ioread32(dev, STATUS_REG);
		done &= STATUS_MASK_DONE;
	    }

	    iowrite32(dev, CMD_REG, 0x0);
#ifndef __riscv
	    printf("  Done\n");
#else
	    print_uart("  Done\n");
#endif
	    /* Validation */
#ifndef __riscv
	    printf("  validating...\n");
#else
	    print_uart("  validating...\n");
#endif

	    errors = 0;
	    for (i = 0; i < OUT_SIZE_DATA; i++) {
		if (mem[i + IN_SIZE_DATA] != mem_gold[i]) {
		    errors++;
#ifndef __riscv
		    printf("ERROR: i mem mem_gold\n");
		    printf("%d\n%lu\n%lu\n", i, mem[i + IN_SIZE_DATA], mem_gold[i]);
#else
		    print_uart("ERROR: i mem mem_gold\n");
		    print_uart_int((uint32_t) i);
		    print_uart("\n");
		    print_uart_int((uint32_t) mem[i + IN_SIZE_DATA]);
		    print_uart("\n");
		    print_uart_int((uint32_t) mem_gold[i]);
		    print_uart("\n");
#endif
		} else {
#ifdef VERBOSE
#ifndef __riscv
		    printf("ERROR: i mem mem_gold\n");
		    printf("%u\n%u\n%u\n", (uint32_t) i, (uint32_t) mem[i + IN_SIZE_DATA],
			   (uint32_t) mem_gold[i]);
#else
		    print_uart("ERROR: i mem mem_gold\n");
		    print_uart_int((uint32_t) i);
		    print_uart("\n");
		    print_uart_int((uint32_t) mem[i + IN_SIZE_DATA]);
		    print_uart("\n");
		    print_uart_int((uint32_t) mem_gold[i]);
		    print_uart("\n");
#endif
#endif
		}
	    }

	    if (!errors) {
#ifndef __riscv
		printf("\n  Test PASSED!\n");
#else
		print_uart("\n  Test PASSED!\n");
#endif
	    } else {

#ifndef __riscv
		printf("\n  Test FAILED. Number of errors: %d\n", errors);
#else
		print_uart("\n  Test FAILED. Number of errors: ");
		print_uart_int((uint32_t) errors); print_uart("\n");
#endif

	    }
	}
    }

    return 0;
}
