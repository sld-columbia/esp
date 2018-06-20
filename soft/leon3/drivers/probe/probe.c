#include <stdio.h>
#include <stdlib.h>
#include <esp_probe.h>

asm(
    "	.text\n"
    "	.align 4\n"
    "	.global get_pid\n"

    "get_pid:\n"
    "        mov  %asr17, %o0\n"
    "        srl  %o0, 28, %o0\n"
    "        retl\n"
    "        and %o0, 0xf, %o0\n"
    );


const char *coherence_label[3] = {"none", "llc", "full"};


void *aligned_malloc(int size) {
	void *mem = malloc(size + CACHELINE_SIZE + sizeof(void*));
	void **ptr = (void**) ((uintptr_t) (mem + CACHELINE_SIZE + sizeof(void*)) & ~(CACHELINE_SIZE-1));
	ptr[-1] = mem;
	return ptr;
}

void aligned_free(void *ptr) {
	free(((void**)ptr)[-1]);
}


void esp_flush(int coherence)
{
	int i;
	const int cmd = 1 << ESP_CACHE_CMD_FLUSH_BIT;
	struct esp_device *llcs = NULL;
	struct esp_device *l2s = NULL;
	int nllc = 0;
	int nl2 = 0;
	int pid = get_pid();

	switch (coherence) {
	case ACC_COH_NONE   : printf("  -> Non-coherent DMA\n"); break;
	case ACC_COH_LLC    : printf("  -> LLC-coherent DMA\n"); break;
	case ACC_COH_RECALL : printf("  -> Coherent DMA\n"); break;
	case ACC_COH_FULL   : printf("  -> Fully-coherent cache access\n"); break;
	}


	if (coherence == ACC_COH_NONE)
		/* Look for LLC controller */
		nllc = probe(&llcs, SLD_L3_CACHE, "llc_cache");

	if (coherence < ACC_COH_RECALL)
		/* Look for L2 controller */
		nl2 = probe(&l2s, SLD_L2_CACHE, "l2_cache");

	if (coherence < ACC_COH_RECALL) {

		/* Set L2 flush (waits for L1 to flush first) */
		for (i = 0; i < nl2; i++) {
			struct esp_device *l2 = &l2s[i];
			int cpuid = (ioread32(l2, ESP_CACHE_REG_STATUS) & ESP_CACHE_STATUS_CPUID_MASK) >> ESP_CACHE_STATUS_CPUID_SHIFT;
			if (cpuid == pid) {
				iowrite32(l2, ESP_CACHE_REG_CMD, cmd);
				break;
			}
		}

		/* Flush L1 - also execute L2 flush */
		__asm__ __volatile__("sta %%g0, [%%g0] %0\n\t" : :
				"i"(ASI_LEON_DFLUSH) : "memory");

		/* Wait for L2 flush to complete */
		struct esp_device *l2 = &l2s[i];
		/* Poll for completion */
		while (!(ioread32(l2, ESP_CACHE_REG_STATUS) & ESP_CACHE_STATUS_DONE_MASK));
		/* Clear IRQ */
		iowrite32(l2, ESP_CACHE_REG_CMD, 0);

		/* Flus LLC */
		for (i = 0; i < nllc; i++) {
			struct esp_device *llc = &llcs[i];
			iowrite32(llc, ESP_CACHE_REG_CMD, cmd);
		}

		/* Wait for LLC flush to complete */
		for (i = 0; i < nllc; i++) {
			struct esp_device *llc = &llcs[i];
			/* Poll for completion */
			while (!(ioread32(llc, ESP_CACHE_REG_STATUS) & ESP_CACHE_STATUS_DONE_MASK));
			/* Clear IRQ */
			iowrite32(llc, ESP_CACHE_REG_CMD, 0);
		}


	}


	if (llcs)
		free(llcs);
	if (l2s)
		free(l2s);
}

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
			printf("  Registered %s.%d:\n", name, (*espdevs)[ndev-1].number);
			printf("    addr = 0x%08x\n", (*espdevs)[ndev-1].addr);
			printf("    irq  = %d\n", (*espdevs)[ndev-1].irq);
		}
	}
	printf("\n");
	return ndev;
}

unsigned ioread32(struct esp_device *dev, unsigned offset)
{
	const long addr = dev->addr + offset;
	volatile unsigned *reg = (unsigned *) addr;
	return *reg;
}

void iowrite32(struct esp_device *dev, unsigned offset, unsigned payload)
{
	const long addr = dev->addr + offset;
	volatile unsigned *reg = (unsigned *) addr;
	*reg = payload;
}
