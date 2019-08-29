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

#define TOKENS 256
#define BATCH 4

const unsigned out_offset = BATCH * TOKENS * sizeof(u64);
const unsigned size = 3 * out_offset;

/* Size of the contiguous chunks for scatter/gather */
#define CHUNK_SHIFT 20
#define CHUNK_SIZE BIT(CHUNK_SHIFT)
#define NCHUNK ((size % CHUNK_SIZE == 0) ?			\
			(size / CHUNK_SIZE) :		\
			(size / CHUNK_SIZE) + 1)

// User defined registers
#define TOKENS_REG	0x40
#define BATCH_REG	0x44


static int validate_dummy(token_t *mem)
{
	int i, j;
	int rtn = 0;
	for (j = 0; j < BATCH; j++)
		for (i = 0; i < TOKENS; i++)
			if (mem[i + j * TOKENS + 2 * BATCH * TOKENS] != (mask | (token_t) i)) {
				print_uart_int(mem[i + j * TOKENS + 2 * BATCH * TOKENS]);
				rtn++;
			}
	return rtn;
}

static void init_buf (token_t *mem)
{
	int i, j;
	for (j = 0; j < BATCH; j++)
		for (i = 0; i < TOKENS; i++)
			mem[i + j * TOKENS] = (mask | (token_t) i);

	for (i = 0; i < 2 * BATCH * TOKENS; i++)
		mem[i + BATCH * TOKENS] = 0xFFFFFFFFFFFFFFFFL;
}


int main(int argc, char * argv[])
{
	int i;
	int n;
	int ndev;
	struct esp_device *espdevs;
	struct esp_device *dev;
	struct esp_device *srcs[4];
	unsigned all_done;
	unsigned done[3];
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
	mem = aligned_malloc(size);
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
	init_buf(mem);

	// Pass common configuration parameters to all devices in the chain
	for (n = 0; n < 3; n++) {
		dev = &espdevs[n];

		iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
		iowrite32(dev, COHERENCE_REG, ACC_COH_NONE);

		iowrite32(dev, PT_ADDRESS_REG, (unsigned long long) ptable);
		iowrite32(dev, PT_NCHUNK_REG, NCHUNK);
		iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);
		iowrite32(dev, TOKENS_REG, TOKENS);
		switch (n) {
		case 0:
			iowrite32(dev, BATCH_REG, BATCH / 2);
			iowrite32(dev, SRC_OFFSET_REG, 0x0);
			iowrite32(dev, DST_OFFSET_REG, out_offset);
			break;
		case 1:
			iowrite32(dev, BATCH_REG, BATCH / 2);
			iowrite32(dev, SRC_OFFSET_REG, out_offset / 2);
			iowrite32(dev, DST_OFFSET_REG, 3 * out_offset / 2);
			break;
		default :
			iowrite32(dev, BATCH_REG, BATCH);
			iowrite32(dev, SRC_OFFSET_REG, out_offset);
			iowrite32(dev, DST_OFFSET_REG, 2 * out_offset);
			break;
		}

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
	all_done = 0;
	while (!all_done) {
		for (n = 0; n < 3; n++) {
			dev = &espdevs[n];
			done[n] = ioread32(dev, STATUS_REG);
			done[n] & STATUS_MASK_DONE;
			/* if (done[n]) { */
			/* 	print_uart("Done "); print_uart_int(n); print_uart("\n"); */
			/* } */
		}
		all_done = done[0] & done[1] & done[2];
	}

	for (n = 0; n < 3; n++) {
		dev = &espdevs[n];
		iowrite32(dev, CMD_REG, 0x0);
	}

	printf("  Done\n");

	/* Validation */
	printf("  validating...\n");
	errors = validate_dummy(mem);
	if (errors)
		printf("  ... FAIL\n");
	else
		printf("  ... PASS\n");

	aligned_free(ptable);
	aligned_free(mem);

	return 0;
}

