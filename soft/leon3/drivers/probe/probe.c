#include <stdio.h>
#include <stdlib.h>
#include <esp_probe.h>

int probe(struct esp_device **espdevs, unsigned devid, const char *name)
{
	int i;
	int ndev = 0;
	unsigned id_reg, bank_addr_reg;
	unsigned *devtable = (unsigned *) APB_PLUGNPLAY;
	unsigned vendor;
	unsigned id;
	unsigned number;
	unsigned irq;
	unsigned addr;
	for (i = 0; i < NAPBSLV; i++) {
		id_reg = devtable[2 * i];
		bank_addr_reg = devtable[2 * i + 1];
		vendor = (id_reg >> 24);
		id     = (id_reg >> 12) & 0x00fff;

		if (vendor == VENDOR_SLD && id == devid) {
			number = ndev;
			addr   = ((bank_addr_reg >> 20) << 8) + APB_BASE_ADDR;
			irq    = id_reg & 0x0000000f;

			ndev++;
			(*espdevs) = realloc((*espdevs), ndev * sizeof(struct esp_device));
			if (!(*espdevs)) {
				fprintf(stderr, "Error: cannot allocate esp_device list\n");
				exit(EXIT_FAILURE);
			}
			(*espdevs)[ndev-1].vendor = VENDOR_SLD;
			(*espdevs)[ndev-1].id = id;
			(*espdevs)[ndev-1].number = number;
			(*espdevs)[ndev-1].irq = irq;
			(*espdevs)[ndev-1].addr = addr;
			printf("Registered %s.%d:\n", name, (*espdevs)[ndev-1].number);
			printf("  addr = 0x%08x\n", (*espdevs)[ndev-1].addr);
			printf("  irq  = %d\n", (*espdevs)[ndev-1].irq);
		}
	}
	printf("\n");
	return ndev;
}

unsigned ioread32(struct esp_device *dev, unsigned offset)
{
	volatile unsigned *reg = (unsigned *) (dev->addr + offset);
	return *reg;
}

void iowrite32(struct esp_device *dev, unsigned offset, unsigned payload)
{
	volatile unsigned *reg = (unsigned *) (dev->addr + offset);
	*reg = payload;
}
