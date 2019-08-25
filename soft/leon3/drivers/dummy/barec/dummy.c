/**
 * Baremetal device driver for DUMMY
 *
 * (point-to-point communication test)
 */

#ifndef __riscv
#include <stdio.h>
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>

typedef long long unsigned u64;
typedef unsigned u32;

typedef u64 token_t;
#define mask 0xFEED0BAC00000000L

#define SLD_DUMMY   0x42
#define DEV_NAME "sld,dummy"

#define DUMMY_TOKENS 512

#define DUMMY_BUF_SIZE (4 * DUMMY_TOKENS * sizeof(u64))

/* Size of the contiguous chunks for scatter/gather */
#define CHUNK_SHIFT 13
#define CHUNK_SIZE BIT(CHUNK_SHIFT)
#define NCHUNK ((DUMMY_BUF_SIZE % CHUNK_SIZE == 0) ?			\
			(DUMMY_BUF_SIZE / CHUNK_SIZE) :			\
			(DUMMY_BUF_SIZE / CHUNK_SIZE) + 1)

// User defined registers
#define DUMMY_TOKENS_REG	0x40
#define DUMMY_BATCH_REG		0x44


static int validate_dummy(token_t *mem, int tokens)
{
	int i;
	int rtn = 0;
	for (i = 0; i < tokens; i++)
		if (mem[i] != (mask | (token_t) i))
			rtn++;
	return rtn;
}

static void init_buf (token_t *mem, int tokens)
{
	int i;
	for (i = 0; i < tokens; i++)
		mem[i] = (mask | (token_t) i);
}


int main(int argc, char * argv[])
{
	int i;
	int n;
	int ndev;
	struct esp_device *espdevs;
	struct esp_device *dev;
	struct esp_device *srcs[4];
	unsigned done;
	unsigned **ptable;
	token_t *mem;
	unsigned errors = 0;

	printf("Scanning device tree... \n");
	ndev = probe(&espdevs, SLD_DUMMY, DEV_NAME);
	if (ndev < 3) {
		printf("This test requires 3 dummy devices!\n");
		return 0;
	}

	// Check DMA capabilities
	for (n = 0; n < 2; n++) {
		dev = &espdevs[n];

		if (ioread32(dev, PT_NCHUNK_MAX_REG) == 0) {
			printf("  -> scatter-gather DMA is disabled. Abort.\n");
			return 0;
		}

		if (ioread32(dev, PT_NCHUNK_MAX_REG) < NCHUNK) {
			printf("  -> Not enough TLB entries available. Abort.\n");
			return 0;
		}
	}

	// Allocate memory
	mem = aligned_malloc(DUMMY_BUF_SIZE);
#ifndef __riscv
	printf("  memory buffer base-address = %p\n", mem);
#else
	print_uart("  memory buffer base-address = "); print_uart_addr((uintptr_t) mem); print_uart("\n");
#endif
	//Alocate and populate page table
	ptable = aligned_malloc(NCHUNK * sizeof(unsigned *));
	for (i = 0; i < NCHUNK; i++)
		ptable[i] = (unsigned *) &mem[i * (CHUNK_SIZE / sizeof(token_t))];
#ifndef __riscv
	printf("  ptable = %p\n", ptable);
	printf("  nchunk = %lu\n", NCHUNK);
#else
	print_uart("  ptable = "); print_uart_addr((uintptr_t) ptable); print_uart("\n");
	print_uart("  nchunk = "); print_uart_int(NCHUNK); print_uart("\n");
#endif

	printf("  Generate random input...\n");
	init_buf(mem, 2 * DUMMY_TOKENS);

	// Pass common configuration parameters to all devices in the chain
	for (n = 0; n < 3; n++) {
		dev = &espdevs[n];

		iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
		iowrite32(dev, COHERENCE_REG, ACC_COH_NONE);

		iowrite32(dev, PT_ADDRESS_REG, (unsigned long long) ptable);
		iowrite32(dev, PT_NCHUNK_REG, NCHUNK);
		iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);
		if (n == 1)
			iowrite32(dev, SRC_OFFSET_REG, DUMMY_TOKENS * sizeof(u64));
		else
			iowrite32(dev, SRC_OFFSET_REG, 0);

		iowrite32(dev, DST_OFFSET_REG, 2 * DUMMY_TOKENS * sizeof(u64));
		iowrite32(dev, DUMMY_TOKENS_REG, DUMMY_TOKENS);
		if (n != 2)
			iowrite32(dev, DUMMY_BATCH_REG, 1);
		else
			iowrite32(dev, DUMMY_BATCH_REG, 2);
	}

	// Configure point-to-point
	dev = &espdevs[2];
	srcs[0] = &espdevs[0];
	srcs[1] = &espdevs[1];
	esp_p2p_init(dev, srcs, 2);

	// Flush for non-coherent DMA
	esp_flush(ACC_COH_NONE);

	// Start accelerators
	printf("  Start...\n");
	for (n = 0; n < 3; n++) {
		dev = &espdevs[n];

		iowrite32(dev, CMD_REG, CMD_MASK_START);
	}

	// Wait for completion
	for (n = 0; n < 3; n++) {
		dev = &espdevs[n];
		done = 0;
		while (!done) {
			done = ioread32(dev, STATUS_REG);
			done &= STATUS_MASK_DONE;
		}
#ifndef __riscv
		printf("  Done device %d\n", n);
#else
		print_uart("  Done device "); print_uart_int(n); print_uart("\n");
#endif
		iowrite32(dev, CMD_REG, 0x0);
	}
	printf("  Done\n");

	/* Validation */
	printf("  validating...\n");
	errors = validate_dummy(&mem[2 * DUMMY_TOKENS], 2 * DUMMY_TOKENS);
	if (errors)
		printf("  ... FAIL\n");
	else
		printf("  ... PASS\n");

	aligned_free(ptable);
	aligned_free(mem);

	return 0;
}

