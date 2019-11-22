/**
 * Baremetal device driver for COUNTERACCELERATOR
 *
 * Select Scatter-Gather in ESP configuration
 */

#ifndef __riscv
#include <stdio.h>
#endif
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
#ifndef __riscv
		printf("Error: %s device not found!\n", DEV_NAME);
#else
		print_uart("Error: "); print_uart(DEV_NAME); print_uart(" device not found!\n");
#endif
		exit(EXIT_FAILURE);
	}

	for (n = 0; n < ndev; n++) {
		struct esp_device *dev = &espdevs[n];
		const int test_ticks = 8;
		unsigned done;


#ifndef __riscv
		printf("******************** %s.%d ********************\n", DEV_NAME, n);
#else
		print_uart("******************** "); print_uart(DEV_NAME); print_uart(".");
		print_uart_int(n); print_uart(" ********************\n");
#endif


		// Configure device
		iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));

		iowrite32(dev, COUNTERACCELERATOR_TICKS_REG, test_ticks);

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


#ifndef __riscv
		printf("************************************************\n\n");
#else
		print_uart("************************************************\n\n");
#endif
	}
	return 0;
}

