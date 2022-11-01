#include <stdio.h>
#include <stdlib.h>
#include "esp_probe.h"


#define DEV_ID 0x102
#define DEV_NAME "hu,hu_sysarray"

const static int N = 8;
const static int M = 4*N;

// bias left shift,
const static int   IsRelu = 1;
const static int   BiasShift = 6;
const static int   AccumShift = 10;
const static int   AccumMul   = 93;


static void access_csr(struct esp_device *dev, size_t offset, unsigned data)
{
	unsigned data_read;
	iowrite32(dev, offset, data);
	data_read = ioread32(dev, offset);
	if (data != data_read) {
		printf("Error: register access failed at offset %02x\n", offset);
		exit(EXIT_FAILURE);
	}
}

int main(int argc, char **argv)
{
	struct esp_device *espdevs = NULL;
	struct esp_device *dev;
	int ndev;

	unsigned data = 0;
	unsigned data_read;
	long unsigned *w_rd = (long unsigned *) aligned_malloc(0x4000);
	long unsigned *d_rd = (long unsigned *) aligned_malloc(0x4000);
	long unsigned *d_wr = (long unsigned *) aligned_malloc(0x4000);

	printf("Searching device %s\n", DEV_NAME);

	/* Probe */
	ndev = probe(&espdevs, DEV_ID, DEV_NAME);
	if (!ndev) {
		printf("Error: %s device not found!\n", DEV_NAME);
		exit(EXIT_FAILURE);
	}
	dev = &espdevs[0];

	/* Config_reg[2-5] */
 	data += (M-1);  /* M_1 */
	data += IsRelu << 8;
	data += BiasShift << 16;
	data += AccumShift << 20;
	data += AccumMul << 24;
	access_csr(dev, 0x08, data);

	data = (unsigned) (long unsigned) w_rd;
	access_csr(dev, 0x0C, data);

	data = (unsigned) (long unsigned) d_rd;
	access_csr(dev, 0x10, data);

	data = (unsigned) (long unsigned) d_wr;
	access_csr(dev, 0x14, data);

	printf("Finish Axi Config[2-5]\n");

	/* TODO: prepare input data */

	printf("Start Input Master Read\n");
	data = 0x02;
	access_csr(dev, 0x4, data);
	/* wait for IRQ -- TODO status register */
	/* while (interrupt.read() == 0) wait(); */

	/* Program will not terminate! */
	while(1);

	/* wait for IRQ -- TODO status register */
	/* while (interrupt.read() == 0) wait(); */

	/* printf("Start Weight Master Read\n"); */
	/* data = 0x01; */
	/* access_csr(dev, 0x4, data); */
	/* /\* while (interrupt.read() == 0) wait(); *\/ */

	/* printf("Start Computation\n"); */
	/* data = 0x04; */
	/* access_csr(dev, 0x4, data); */
	/* /\* while (interrupt.read() == 0) wait(); *\/ */

	/* printf("Finish Computation\n"); */

	/* printf("Start Input Master Write\n"); */
	/* data = 0x03; */
	/* access_csr(dev, 0x4, data); */
	/* /\* while (interrupt.read() == 0) wait(); *\/ */

	/* printf("Finish Input Master Write\n"); */

	/* TODO: Validation */

	aligned_free(w_rd);
	aligned_free(d_rd);
	aligned_free(d_wr);

	return 0;
}
