/**
 * Baremetal device driver for SORT
 *
 * Select Scatter-Gather in ESP configuration
 */

#include <stdio.h>
#include <stdlib.h>
#include <esp_accelerator.h>
#include <esp_probe.h>

#define SLD_SORT   0x0B
#define DEV_NAME "sort"

#define SORT_LEN 32
#define SORT_BATCH 2

#define SORT_BUF_SIZE (SORT_LEN * SORT_BATCH * sizeof(unsigned))

/* Size of the contiguous chunks for scatter/gather */
#define CHUNK_SHIFT 6
#define CHUNK_SIZE BIT(CHUNK_SHIFT)
#define NCHUNK ((SORT_BUF_SIZE % CHUNK_SIZE == 0) ?			\
			(SORT_BUF_SIZE / CHUNK_SIZE) :			\
			(SORT_BUF_SIZE / CHUNK_SIZE) + 1)

// User defined registers
#define SORT_LEN_REG		0x40
#define SORT_BATCH_REG		0x44
#define SORT_LEN_MIN_REG	0x48
#define SORT_LEN_MAX_REG	0x4c
#define SORT_BATCH_MAX_REG	0x50


static int validate_sorted(float *array, int len)
{
	int i;
	int rtn = 0;
	for (i = 1; i < len; i++)
		if (array[i] < array[i-1])
			rtn++;
	return rtn;
}

int main(int argc, char * argv[])
{
	int n;
	int ndev;
	struct esp_device *espdevs = NULL;

	ndev = probe(&espdevs, SLD_SORT, DEV_NAME);
	if (!ndev) {
		fprintf(stderr, "Error: %s device not found!\n", DEV_NAME);
		exit(EXIT_FAILURE);
	}

	printf("Test parameters: [LEN, BATCH] = [%d, %d]\n\n", SORT_LEN, SORT_BATCH);

	for (n = 0; n < ndev; n++) {
		struct esp_device *dev = &espdevs[n];
		unsigned sort_batch_max;
		unsigned sort_len_max;
		unsigned sort_len_min;
		unsigned done;
		int i, j;
		unsigned **ptable;
		unsigned *mem;
		unsigned errors = 0;
		int scatter_gather = 1;
		int coherence;

		// Get coherence type
		coherence = ioread32(dev, COHERENCE_REG);

		sort_batch_max = ioread32(dev, SORT_BATCH_MAX_REG);
		sort_len_min = ioread32(dev, SORT_LEN_MIN_REG);
		sort_len_max = ioread32(dev, SORT_LEN_MAX_REG);

		printf("Testing %s.%d \n  -> process up to %d fp-vectors of size [%d, %d]\n",
			DEV_NAME, n, sort_batch_max, sort_len_min, sort_len_max);

		// Check access ok
		if (SORT_LEN < sort_len_min ||
			SORT_LEN > sort_len_max ||
			SORT_BATCH < 1 ||
			SORT_BATCH > sort_batch_max) {
			fprintf(stderr, "  Error: unsopported configuration parameters for %s.%d\n", DEV_NAME, n);
			break;
		}

		// Check if scatter-gather DMA is disabled
		if (ioread32(dev, PT_NCHUNK_MAX_REG) == 0) {
			printf("  -> scatter-gather DMA is disabled; revert to contiguous buffer.\n");
			scatter_gather = 0;
		} else {
			printf("  -> scatter-gather DMA is enabled.\n");
		}

		if (scatter_gather)
			if (ioread32(dev, PT_NCHUNK_MAX_REG) < NCHUNK) {
				fprintf(stderr, "  Trying to allocate %lu chunks on %d TLB available entries\n",
					NCHUNK, ioread32(dev, PT_NCHUNK_MAX_REG));
				break;
			}

		// Allocate memory (will be contigous anyway in baremetal)
		mem = malloc(SORT_BUF_SIZE);
		printf("  memory buffer base-address = %p\n", mem);

		if (scatter_gather) {
			//Alocate and populate page table
			ptable = malloc(NCHUNK * sizeof(unsigned *));
			for (i = 0; i < NCHUNK; i++)
				ptable[i] = (unsigned *) &mem[i * (CHUNK_SIZE / sizeof(unsigned))];
			printf("  ptable = %p\n", ptable);
			printf("  nchunk = %lu\n", NCHUNK);
		}

		// Initialize input: write floating point hex values (simpler to debug)
		printf("  Prepare input... ");
		mem[0] = 0x42000000;
		mem[1] = 0x41f80000;
		mem[2] = 0x41f00000;
		mem[3] = 0x41e80000;
		mem[4] = 0x41e00000;
		mem[5] = 0x41d80000;
		mem[6] = 0x41d00000;
		mem[7] = 0x41c80000;
		mem[8] = 0x41c00000;
		mem[9] = 0x41b80000;
		mem[10] = 0x41b00000;
		mem[11] = 0x41a80000;
		mem[12] = 0x41a00000;
		mem[13] = 0x41980000;
		mem[14] = 0x41900000;
		mem[15] = 0x41880000;
		mem[16] = 0x41800000;
		mem[17] = 0x41700000;
		mem[18] = 0x41600000;
		mem[19] = 0x41500000;
		mem[20] = 0x41400000;
		mem[21] = 0x41300000;
		mem[22] = 0x41200000;
		mem[23] = 0x41100000;
		mem[24] = 0x41000000;
		mem[25] = 0x40e00000;
		mem[26] = 0x40c00000;
		mem[27] = 0x40a00000;
		mem[28] = 0x40800000;
		mem[29] = 0x40400000;
		mem[30] = 0x40000000;
		mem[31] = 0x3f800000;
		mem[32] = 0x42000000;
		mem[33] = 0x41f80000;
		mem[34] = 0x41f00000;
		mem[35] = 0x41e80000;
		mem[36] = 0x41e00000;
		mem[37] = 0x41d80000;
		mem[38] = 0x41d00000;
		mem[39] = 0x41c80000;
		mem[40] = 0x41c00000;
		mem[41] = 0x41b80000;
		mem[42] = 0x41b00000;
		mem[43] = 0x41a80000;
		mem[44] = 0x41a00000;
		mem[45] = 0x41980000;
		mem[46] = 0x41900000;
		mem[47] = 0x41880000;
		mem[48] = 0x41800000;
		mem[49] = 0x41700000;
		mem[50] = 0x41600000;
		mem[51] = 0x41500000;
		mem[52] = 0x41400000;
		mem[53] = 0x41300000;
		mem[54] = 0x41200000;
		mem[55] = 0x41100000;
		mem[56] = 0x41000000;
		mem[57] = 0x40e00000;
		mem[58] = 0x40c00000;
		mem[59] = 0x40a00000;
		mem[60] = 0x40800000;
		mem[61] = 0x40400000;
		mem[62] = 0x40000000;
		mem[63] = 0x3f800000;
		printf("Input ready\n");

		// Configure device
		iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
		if (scatter_gather) {
			iowrite32(dev, PT_ADDRESS_REG, (unsigned) ptable);
			iowrite32(dev, PT_NCHUNK_REG, NCHUNK);
			iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);
			iowrite32(dev, SRC_OFFSET_REG, 0);
			iowrite32(dev, DST_OFFSET_REG, 0); // Sort runs in place
		} else {
			iowrite32(dev, SRC_OFFSET_REG, (unsigned) mem);
			iowrite32(dev, DST_OFFSET_REG, (unsigned) mem); // Sort runs in place
		}
		iowrite32(dev, SORT_LEN_REG, SORT_LEN);
		iowrite32(dev, SORT_BATCH_REG, SORT_BATCH);

		// Flush for non-coherent DMA
		esp_flush(coherence);

		// Start accelerator
		printf("  Start..\n");
		iowrite32(dev, CMD_REG, CMD_MASK_START);

		done = 0;
		while (!done) {
			done = ioread32(dev, STATUS_REG);
			done &= STATUS_MASK_DONE;
		}
		iowrite32(dev, CMD_REG, 0x0);
		printf("  Done\n");

		/* /\* Print output *\/ */
		/* printf("  output:\n"); */
		/* for (j = 0; j < SORT_BATCH; j++) */
		/* 	for (i = 0; i < SORT_LEN; i++) */
		/* 		printf("    mem[%d][%d] = %08x\n", j, i, mem[j*SORT_LEN + i]); */

		/* Validation */
		printf("  validating...\n");
		for (j = 0; j < SORT_BATCH; j++) {
			int err = validate_sorted((float *) &mem[j * SORT_LEN], SORT_LEN);
			if (err != 0)
				fprintf(stderr, "  Error: %s.%d mismatch on batch %d\n", DEV_NAME, n, j);
			errors += err;
		}
		if (errors)
			printf("  ... FAIL\n");
		else
			printf("  ... PASS\n");
		printf("\n");

		if (scatter_gather)
			free(ptable);
		free(mem);
	}
	return 0;
}

