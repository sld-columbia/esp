/*
 * Copyright (c) 2011-2019 Columbia University, System Level Design Group
 * SPDX-License-Identifier: Apache-2.0
 */

#include <stdlib.h>
#include <string.h>

#ifndef __riscv
#include <stdio.h>
#endif

#include <esp_probe.h>

#ifdef __riscv
uintptr_t dtb = DTB_ADDRESS;
/*
 * The RISC-V bare-metal toolchain does not have support for malloc
 * on unthethered systems. This simple hack is used to enable RTL
 * simulation of an accelerator invoked by bare-metal software.
 * Note that The RISC-V core in ESP is unthethered and cannot rely
 * proxy kernel running on a host system.
 */
static uintptr_t uncached_area_ptr = 0xa0100000;
#endif

#ifdef __sparc
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
#elif __riscv
int get_pid()
{
	int hartid = (int) read_csr(mhartid);
	return hartid;
}
#else
#error Unsupported ISA
#endif

const char* const coherence_label[5] = {
	"non-coherent DMA",
	"LLC-coherent DMA",
	"coherent-DMA",
	"fully-coherent access",
	0 };

void *aligned_malloc(int size) {
#ifndef __riscv
	void *mem = malloc(size + CACHELINE_SIZE + sizeof(void*));
#else
	void *mem = (void *) uncached_area_ptr;
	uncached_area_ptr += size + CACHELINE_SIZE + sizeof(void*);
#endif

	void **ptr = (void**) ((uintptr_t) (mem + CACHELINE_SIZE + sizeof(void*)) & ~(CACHELINE_SIZE-1));
	ptr[-1] = mem;
	return ptr;
}

void aligned_free(void *ptr) {
	// On RISC-V we never free memory
	// This hack is intended for simulation only
#ifndef __riscv
	free(((void**)ptr)[-1]);
#endif
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
#ifndef __riscv
	case ACC_COH_NONE   : printf("  -> Non-coherent DMA\n"); break;
	case ACC_COH_LLC    : printf("  -> LLC-coherent DMA\n"); break;
	case ACC_COH_RECALL : printf("  -> Coherent DMA\n"); break;
	case ACC_COH_FULL   : printf("  -> Fully-coherent cache access\n"); break;
#else
	case ACC_COH_NONE   : print_uart("  -> Non-coherent DMA\n"); break;
	case ACC_COH_LLC    : print_uart("  -> LLC-coherent DMA\n"); break;
	case ACC_COH_RECALL : print_uart("  -> Coherent DMA\n"); break;
	case ACC_COH_FULL   : print_uart("  -> Fully-coherent cache access\n"); break;
#endif
	}


	if (coherence == ACC_COH_NONE)
		/* Look for LLC controller */
		nllc = probe(&llcs, SLD_LLC_CACHE, "sld,llc_cache");

	if (coherence < ACC_COH_RECALL)
		/* Look for L2 controller */
		nl2 = probe(&l2s, SLD_L2_CACHE, "sld,l2_cache");

	if (coherence < ACC_COH_RECALL) {

		if (nl2 > 0) {
			/* Set L2 flush (waits for L1 to flush first) */
			for (i = 0; i < nl2; i++) {
				struct esp_device *l2 = &l2s[i];
				int cpuid = (ioread32(l2, ESP_CACHE_REG_STATUS) & ESP_CACHE_STATUS_CPUID_MASK) >> ESP_CACHE_STATUS_CPUID_SHIFT;
				if (cpuid == pid) {
					iowrite32(l2, ESP_CACHE_REG_CMD, cmd);
					break;
				}
			}

#ifdef __sparc
			/* Flush L1 - also execute L2 flush */
			__asm__ __volatile__("sta %%g0, [%%g0] %0\n\t" : :
					"i"(ASI_LEON_DFLUSH) : "memory");
#endif

			/* Wait for L2 flush to complete */
			struct esp_device *l2 = &l2s[i];
			/* Poll for completion */
			while (!(ioread32(l2, ESP_CACHE_REG_STATUS) & ESP_CACHE_STATUS_DONE_MASK));
			/* Clear IRQ */
			iowrite32(l2, ESP_CACHE_REG_CMD, 0);
		}

		if (nllc > 0) {

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
	}


#ifndef __riscv
	if (llcs)
		free(llcs);
	if (l2s)
		free(l2s);
#endif

}

#ifdef __sparc
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
			printf("[probe]  %s.%u registered\n", name, (*espdevs)[ndev-1].number);
			printf("         Address   : 0x%08x\n", (unsigned) (*espdevs)[ndev-1].addr);
			printf("         Interrupt : %u\n", (*espdevs)[ndev-1].irq);
		}
	}
	printf("\n");
	return ndev;
}
#elif __riscv

static unsigned ndev = 0;

static void esp_open(const struct fdt_scan_node *node, void *extra)
{
}

static void esp_prop(const struct fdt_scan_prop *prop, void *extra)
{
	// Get pointer to last entry in espdevs. This has not been discovered yet.
	struct esp_device **espdevs = (struct esp_device **) extra;
	const char *name = (*espdevs)[0].name;

	if (!strcmp(prop->name, "compatible") && !strcmp((const char*)prop->value, name))
		(*espdevs)[ndev].compat = 1;
	else if (!strcmp(prop->name, "reg"))
		fdt_get_address(prop->node->parent, prop->value, (uint64_t *) &(*espdevs)[ndev].addr);
	else if (!strcmp(prop->name, "interrupts"))
		fdt_get_value(prop->value, &(*espdevs)[ndev].irq);
}

static void esp_done(const struct fdt_scan_node *node, void *extra)
{
	struct esp_device **espdevs = (struct esp_device **)extra;
	const char *name = (*espdevs)[0].name;

	if ((*espdevs)[ndev].compat != 0) {
		print_uart("[probe] "); print_uart(name); print_uart("."); print_uart_int(ndev); print_uart(" registered\n");
		print_uart("        "); print_uart("Address   : 0x"); print_uart_int((uint32_t) (*espdevs)[ndev].addr); print_uart("\n");
		print_uart("        "); print_uart("Interrupt : "); print_uart_int((uint32_t) (*espdevs)[ndev].irq); print_uart("\n");
		ndev++;

		// Initialize new entry (may not be discovered!)
		(*espdevs)[ndev].vendor = VENDOR_SLD;
		(*espdevs)[ndev].id = (*espdevs)[ndev].id;
		(*espdevs)[ndev].number = ndev;
		(*espdevs)[ndev].compat = 0;
		strcpy((*espdevs)[ndev].name, name);
	}
}

int probe(struct esp_device **espdevs, unsigned devid, const char *name)
{
	struct fdt_cb cb;
	ndev = 0;

	// Initialize first entry of the device structure (may not be discovered!)
	(*espdevs) = (struct esp_device *) aligned_malloc(NACC_MAX * sizeof(struct esp_device));
	if (!(*espdevs)) {
		print_uart("Error: cannot allocate esp_device list\n");
		return -1;
	}
	memset((*espdevs), 0, NACC_MAX * sizeof(struct esp_device));

	(*espdevs)[0].vendor = VENDOR_SLD;
	(*espdevs)[0].id = devid;
	(*espdevs)[0].number = 0;
	(*espdevs)[0].compat = 0;
	strcpy((*espdevs)[0].name, name);

	memset(&cb, 0, sizeof(cb));
	cb.open = esp_open;
	cb.prop = esp_prop;
	cb.done = esp_done;
	cb.extra = espdevs;

	fdt_scan(dtb, &cb);

	return ndev;
}

#else /* !__riscv && !__sparc */

#error Unsupported ISA

#endif

unsigned ioread32(struct esp_device *dev, unsigned offset)
{
	const long unsigned addr = dev->addr + offset;
	volatile unsigned *reg = (unsigned *) addr;
	return *reg;
}

void iowrite32(struct esp_device *dev, unsigned offset, unsigned payload)
{
	const long unsigned addr = dev->addr + offset;
	volatile unsigned *reg = (unsigned *) addr;
	*reg = payload;
}

void esp_p2p_init(struct esp_device *dev, struct esp_device **srcs, unsigned nsrcs)
{
	unsigned i;

	esp_p2p_reset(dev);
	esp_p2p_enable_src(dev);
	esp_p2p_set_nsrcs(dev, nsrcs);
	for (i = 0; i < nsrcs; i++) {
		esp_p2p_enable_dst(srcs[i]);
		esp_p2p_set_y(dev, i, esp_get_y(srcs[i]));
		esp_p2p_set_x(dev, i, esp_get_x(srcs[i]));
	}
}
