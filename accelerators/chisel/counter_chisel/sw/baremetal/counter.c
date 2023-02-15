// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
/**
 * Baremetal device driver for COUNTER
 *
 * Select Scatter-Gather in ESP configuration
 */

#include <stdio.h>
#include <stdlib.h>
#include <esp_accelerator.h>
#include <esp_probe.h>

#define SLD_COUNTER   0x12
#define DEV_NAME "sld,counter_chisel"

// User defined registers
#define COUNTER_GITHASH_REG		0x40
#define COUNTER_TICKS_REG		0x44


int main(int argc, char * argv[])
{
	int n;
	int ndev;
	struct esp_device *espdevs = NULL;

	ndev = probe(&espdevs, VENDOR_SLD, SLD_COUNTER, DEV_NAME);
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

		iowrite32(dev, COUNTER_TICKS_REG, test_ticks);

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

