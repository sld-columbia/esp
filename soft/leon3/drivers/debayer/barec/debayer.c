#include <stdio.h>
#include <stdlib.h>
#include <esp_accelerator.h>
#include <esp_probe.h>

#define SLD_DEBAYER  0x0d
#define DEV_NAME "debayer"

#define DEBAYER_ROWS 16
#define DEBAYER_COLS 16

#define DEBAYER_BUF_SIZE						\
	((DEBAYER_ROWS * DEBAYER_COLS * sizeof(short)) +		\
		((DEBAYER_ROWS - 4) * (DEBAYER_COLS - 4) * 3 * sizeof(short)))

#define CHUNK_SHIFT 8
#define DEV_CHUNK_SIZE (1 << CHUNK_SHIFT)
#define NCHUNK ((DEBAYER_BUF_SIZE % DEV_CHUNK_SIZE == 0) ?			\
			(DEBAYER_BUF_SIZE / DEV_CHUNK_SIZE) :			\
			(DEBAYER_BUF_SIZE / DEV_CHUNK_SIZE) + 1)

// User defined registers
#define DEBAYER_ROWS_REG 0x40
#define DEBAYER_COLS_REG 0x44
#define DEBAYER_ROWS_MAX_REG 0x48


int main(int argc, char **argv)
{

	int i, n;
	struct esp_device *espdevs = NULL;
	unsigned coherence;

	int ndev;

	unsigned input_size = DEBAYER_ROWS * DEBAYER_COLS;
	unsigned output_size = (DEBAYER_ROWS - 4) * (DEBAYER_COLS - 4);
	unsigned img_num_row = DEBAYER_ROWS;
	unsigned img_num_col = DEBAYER_COLS;

	unsigned a[(input_size / 2) + ((output_size * 3) / 2)];
	unsigned c[output_size * 3 / 2];

	ndev = probe(&espdevs, SLD_DEBAYER, DEV_NAME);
	if (!ndev) {
		fprintf(stderr, "Error: %s device not found!\n", DEV_NAME);
		exit(EXIT_FAILURE);
	}

	printf("Allocating buffers for %s - %ux%u... \n\n", DEV_NAME, DEBAYER_ROWS, DEBAYER_COLS);

	for (n = 0; n < ndev; n++) {
		for (coherence = ACC_COH_NONE; coherence <= ACC_COH_FULL; coherence++) {
			struct esp_device *dev = &espdevs[n];
			unsigned max_rows;
			unsigned done;

			printf("=== Test %s.%d ===\n", DEV_NAME, n);

			//Check access ok
			max_rows = ioread32(dev, DEBAYER_ROWS_MAX_REG);
			printf("%s.%d rows max is %d\n", DEV_NAME, n, max_rows);
			if (DEBAYER_ROWS != DEBAYER_COLS ||
				DEBAYER_ROWS < 16 ||
				DEBAYER_ROWS > ioread32(dev, DEBAYER_ROWS_MAX_REG)) {

				fprintf(stderr, "Unsupported debayer size\n");
				exit(EXIT_FAILURE);
			}

			//Alocate page table
			int **ptable = malloc(NCHUNK * sizeof(unsigned *));
			for (i = 0; i < NCHUNK; i++)
				ptable[i] = (int *) &a[i * (DEV_CHUNK_SIZE / sizeof(int))];

			printf("ptable = %p\n", ptable);
			printf("nchunk = %d\n", NCHUNK);
			if (ioread32(dev, PT_NCHUNK_MAX_REG) < NCHUNK) {
				fprintf(stderr, "Trying to allocate %d chunks on %d TLB available entries\n",
					NCHUNK, ioread32(dev, PT_NCHUNK_MAX_REG));
				exit(EXIT_FAILURE);
			}

			//Reload data
#include "data.c"

			// Configure device
			iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
			iowrite32(dev, COHERENCE_REG, coherence);

			iowrite32(dev, PT_ADDRESS_REG, (unsigned) ptable);
			iowrite32(dev, PT_NCHUNK_REG, NCHUNK);
			iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);
			iowrite32(dev, SRC_OFFSET_REG, 0);
			iowrite32(dev, DST_OFFSET_REG, input_size * sizeof(short));
			iowrite32(dev, DEBAYER_ROWS_REG, img_num_row);
			iowrite32(dev, DEBAYER_COLS_REG, img_num_col);

			// Flush for non-coherent DMA
			esp_flush(coherence);

			printf("Start!\n");
			iowrite32(dev, CMD_REG, CMD_MASK_START);

			done = 0;
			while (!done) {
				done = ioread32(dev, STATUS_REG);
				done &= STATUS_MASK_DONE;
			}
			iowrite32(dev, CMD_REG, 0x0);
			printf("Done!\n");

			printf("********\n");
			printf("START VALIDATION:\n");
			int errors = 0;
			for (i = 0; i < output_size; i++) {
				if (a[input_size/2 + i] != c[i]) errors++;
			}
			printf("Total errors: %d\n", errors);
			if (errors == 0) printf("VALIDATION PASS!\n");
			else printf("VALIDATION FAIL!\n");
			printf("********\n\n");

			/* Free page table */
			free(ptable);
		}
	}

	if (espdevs)
		free(espdevs);
	return 0;
}
