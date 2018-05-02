#include <stdio.h>
#include <stdlib.h>
#include <esp_accelerator.h>
#include <esp_probe.h>

#define SLD_CHANGE_DETECTION  0x0E
#define DEV_NAME "change_detection"

/* LOG2 = 3 --> BUF_SIZE = 1KB */
#define CHANGE_DETECTION_ROWS 16
#define CHANGE_DETECTION_COLS 16

#define CHANGE_DETECTION_BUF_SIZE					\
	((CHANGE_DETECTION_ROWS * CHANGE_DETECTION_COLS * 15 * sizeof(unsigned)) + \
		(CHANGE_DETECTION_ROWS * CHANGE_DETECTION_COLS * 5  * sizeof(unsigned short)) + \
		(CHANGE_DETECTION_ROWS * CHANGE_DETECTION_COLS * 5  * sizeof(unsigned char)))

#define CHUNK_SHIFT 8
#define DEV_CHUNK_SIZE (1 << CHUNK_SHIFT)
#define NCHUNK ((CHANGE_DETECTION_BUF_SIZE % DEV_CHUNK_SIZE == 0) ?	\
			(CHANGE_DETECTION_BUF_SIZE / DEV_CHUNK_SIZE) :	\
			(CHANGE_DETECTION_BUF_SIZE / DEV_CHUNK_SIZE) + 1)

#define CHANGE_DETECTION_ROWS_REG 0x40
#define CHANGE_DETECTION_COLS_REG 0x44
#define CHANGE_DETECTION_ROWS_MAX_REG 0x48


int main(int argc, char **argv)
{
	int i, n;
	struct esp_device *espdevs = NULL;
	unsigned coherence;

	int ndev;

	unsigned training_size = CHANGE_DETECTION_ROWS * CHANGE_DETECTION_COLS * 15;
	unsigned input_frames_size = (CHANGE_DETECTION_ROWS * CHANGE_DETECTION_COLS * 5) / 2;
	unsigned input_size = training_size + input_frames_size;
	unsigned output_size = (CHANGE_DETECTION_ROWS * CHANGE_DETECTION_COLS * 5) / 4;
	unsigned total_size = input_size + output_size;;
	unsigned allocated_size = total_size + output_size;
	unsigned img_num_row = CHANGE_DETECTION_ROWS;
	unsigned img_num_col = CHANGE_DETECTION_COLS;

	unsigned a[allocated_size];

	printf("Testing CHANGE_DETECTION accelerator\n");
	printf("Allocating buffers for cd - %ux%u... \n", CHANGE_DETECTION_ROWS, CHANGE_DETECTION_COLS);

	ndev = probe(&espdevs, SLD_CHANGE_DETECTION, DEV_NAME);
	if (!ndev) {
		fprintf(stderr, "Error: %s device not found!\n", DEV_NAME);
		exit(EXIT_FAILURE);
	}


	for (n = 0; n < ndev; n++) {
		for (coherence = ACC_COH_NONE; coherence <= ACC_COH_FULL; coherence++) {
			struct esp_device *dev = &espdevs[n];
			unsigned max_rows;
			unsigned done;

			printf("=== Test %s.%d ===\n", DEV_NAME, n);

			//Check access ok
			max_rows = ioread32(dev, CHANGE_DETECTION_ROWS_MAX_REG);
			printf("%s.%d rows max is %d\n", DEV_NAME, n, max_rows);
			if (CHANGE_DETECTION_ROWS != CHANGE_DETECTION_COLS ||
				CHANGE_DETECTION_ROWS < 16 ||
				CHANGE_DETECTION_ROWS > ioread32(dev, CHANGE_DETECTION_ROWS_MAX_REG)) {

				fprintf(stderr, "Unsupported change_detection size\n");
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
			printf("Input data done!\n");

			// Configure device
			iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
			iowrite32(dev, COHERENCE_REG, coherence);
			iowrite32(dev, PT_ADDRESS_REG, (unsigned) ptable);
			iowrite32(dev, PT_NCHUNK_REG, NCHUNK);
			iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);
			iowrite32(dev, SRC_OFFSET_REG, 0);
			iowrite32(dev, DST_OFFSET_REG, 0);
			iowrite32(dev, CHANGE_DETECTION_ROWS_REG, img_num_row);
			iowrite32(dev, CHANGE_DETECTION_COLS_REG, img_num_col);

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

			printf("START VALIDATION:\n");
			int errors = 0;
			for (i = 0; i < output_size; i++) {
				if (a[input_size+i] != a[input_size+output_size+i]) errors++;
			}
			printf("Total errors: %d\n", errors);
			if (errors == 0) printf("VALIDATION PASS!\n");
			else printf("VALIDATION FAIL!\n");
			printf("=====\n");
		}
	}
	return 0;
}
