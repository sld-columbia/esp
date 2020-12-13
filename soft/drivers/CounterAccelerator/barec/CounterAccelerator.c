/**
 * Baremetal device driver for COUNTERACCELERATOR
 *
 * Select Scatter-Gather in ESP configuration
 */

#include <stdio.h>
#include <stdlib.h>
#include <esp_accelerator.h>
#include <esp_probe.h>

#define SLD_COUNTERACCELERATOR   0x12
#define DEV_NAME "sld,counteraccelerator"

// User defined registers
#define COUNTERACCELERATOR_GITHASH_REG		0x40
#define COUNTERACCELERATOR_TICKS_REG		0x44


int main(int argc, char * argv[])
{
	int n;
	int ndev;
	struct esp_device *espdevs = NULL;

	ndev = probe(&espdevs, SLD_COUNTERACCELERATOR, DEV_NAME);
	if (!ndev) {
		printf("Error: %s device not found!\n", DEV_NAME);
		exit(EXIT_FAILURE);
	}

	for (n = 0; n < ndev; n++) {
		struct esp_device *dev = &espdevs[n];
		const int test_ticks = 8;
		unsigned done;


		printf("******************** %s.%d ********************\n", DEV_NAME, n);


		// Configure device
		iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));

		iowrite32(dev, COUNTERACCELERATOR_TICKS_REG, test_ticks);

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


		printf("************************************************\n\n");
	}
	return 0;
}

