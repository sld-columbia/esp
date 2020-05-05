/* Copyright (c) 2011-2019 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#ifndef __riscv
#include <stdio.h>
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>

typedef uint8_t token_t;

static unsigned DMA_WORD_PER_BEAT(unsigned _st)
{
        return (sizeof(void *) / _st);
}


#define SLD_AES 0x04A
#define DEV_NAME "sld,aes"

/* <<--params-->> */
const int32_t encryption = 0;
const int32_t num_blocks = 3;

static unsigned in_words_adj;
static unsigned out_words_adj;
static unsigned in_len;
static unsigned out_len;
static unsigned in_size;
static unsigned out_size;
static unsigned out_offset;
static unsigned mem_size;

/* Size of the contiguous chunks for scatter/gather */
#define CHUNK_SHIFT 20
#define CHUNK_SIZE BIT(CHUNK_SHIFT)
#define NCHUNK(_sz) ((_sz % CHUNK_SIZE == 0) ?		\
			(_sz / CHUNK_SIZE) :		\
			(_sz / CHUNK_SIZE) + 1)

/* User defined registers */
#define AES_NUM_BLOCKS_REG 0x40
#define AES_ENCRYPTION_REG 0x44

uint8_t key[16]    = { 0x00, 0x01, 0x02, 0x03,
                       0x04, 0x05, 0x06, 0x07,
                       0x08, 0x09, 0x10, 0x11,
                       0x12, 0x13, 0x14, 0x15 };

uint8_t plain[16]  = { 0x01, 0x03, 0x05, 0x07,
                       0x09, 0x11, 0x13, 0x15,
                       0x17, 0x19, 0x21, 0x23,
                       0x25, 0x27, 0x29, 0x31 };

uint8_t cipher[16] = { 0x8f, 0x70, 0xba, 0xf2,
                       0x14, 0x0e, 0x91, 0x30,
                       0xb7, 0x4f, 0x8a, 0x8d,
                       0xcc, 0x72, 0x63, 0x54 };

static int validate_buf(token_t *out)
{
	unsigned errors = 0;

    for (int k = 0; k < num_blocks; ++k)
    {
        for (int i = 0; i < 16; i++)
        {
	    	if (out[k * 16 + i] != cipher[i])
            {
#ifndef __riscv
                printf("error: %02x %02x\n", out[i], cipher[i])
#else
                print_uart("error: ");
                print_uart_byte(out[i]);
                print_uart(" ");
                print_uart_byte(cipher[i]);
                print_uart("\n");
#endif
                errors++;
            }
        }
    }
	return errors;
}


static void init_buf (token_t *in)
{
    // Key

    for (int i = 0; i < 16; ++i)
        in[i] = key[i];

    // Input

    for (int k = 0; k < num_blocks; ++k)
    {
        for (int i = 0; i < 16; ++i)
            in[i + 16 * (k + 1)] = plain[i];
    }
}

int main(int argc, char * argv[])
{
	int i;
	int n;
	int ndev;
	struct esp_device *espdevs;
	struct esp_device *dev;
	unsigned done;
	unsigned **ptable;
	token_t *mem;
	token_t *gold;
	unsigned errors = 0;

	if (DMA_WORD_PER_BEAT(sizeof(token_t)) == 0)
    {
		in_words_adj = (num_blocks + 1) * 16;
		out_words_adj = num_blocks * 16;
	}
    else
    {
		in_words_adj = round_up((num_blocks + 1) * 16,
            DMA_WORD_PER_BEAT(sizeof(token_t)));
		out_words_adj = round_up(num_blocks * 16,
            DMA_WORD_PER_BEAT(sizeof(token_t)));
	}

	in_len = in_words_adj;
	out_len = out_words_adj;
	in_size = in_len * sizeof(token_t);
	out_size = out_len * sizeof(token_t);
	out_offset  = in_len;
	mem_size = (out_offset * sizeof(token_t)) + out_size;

	// Search for the device
#ifndef __riscv
	printf("Scanning device tree... \n");
#else
	print_uart("Scanning device tree... \n");
#endif

	ndev = probe(&espdevs, SLD_AES, DEV_NAME);
	if (ndev == 0) {
#ifndef __riscv
		printf("aes not found\n");
#else
		print_uart("aes not found\n");
#endif
		return 0;
	}

	for (n = 0; n < ndev; n++) {

		dev = &espdevs[n];

		// Check DMA capabilities
		if (ioread32(dev, PT_NCHUNK_MAX_REG) == 0) {
#ifndef __riscv
			printf("  -> scatter-gather DMA is disabled. Abort.\n");
#else
			print_uart("  -> scatter-gather DMA is disabled. Abort.\n");
#endif
			return 0;
		}

		if (ioread32(dev, PT_NCHUNK_MAX_REG) < NCHUNK(mem_size)) {
#ifndef __riscv
			printf("  -> Not enough TLB entries available. Abort.\n");
#else
			print_uart("  -> Not enough TLB entries available. Abort.\n");
#endif
			return 0;
		}

		// Allocate memory
		mem = aligned_malloc(mem_size);

#ifndef __riscv
		printf("  memory buffer base-address = %p\n", mem);
#else
		print_uart("  memory buffer base-address = "); print_uart_addr((uintptr_t) mem); print_uart("\n");
#endif
		// Alocate and populate page table
		ptable = aligned_malloc(NCHUNK(mem_size) * sizeof(unsigned *));
		for (i = 0; i < NCHUNK(mem_size); i++)
			ptable[i] = (unsigned *) &mem[i * (CHUNK_SIZE / sizeof(token_t))];
#ifndef __riscv
		printf("  ptable = %p\n", ptable);
		printf("  nchunk = %lu\n", NCHUNK(mem_size));
#else
		print_uart("  ptable = "); print_uart_addr((uintptr_t) ptable); print_uart("\n");
		print_uart("  nchunk = "); print_uart_int(NCHUNK(mem_size)); print_uart("\n");
#endif

#ifndef __riscv
		printf("  Generate input...\n");
#else
		print_uart("  Generate input...\n");
#endif
		init_buf(mem);

		// Pass common configuration parameters

		iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
		iowrite32(dev, COHERENCE_REG, ACC_COH_NONE);

#ifndef __sparc
		iowrite32(dev, PT_ADDRESS_REG, (unsigned long long) ptable);
#else
		iowrite32(dev, PT_ADDRESS_REG, (unsigned) ptable);
#endif
		iowrite32(dev, PT_NCHUNK_REG, NCHUNK(mem_size));
		iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);

		// Use the following if input and output data are not allocated at the default offsets
		iowrite32(dev, SRC_OFFSET_REG, 0x0);
		iowrite32(dev, DST_OFFSET_REG, 0x0);

		// Pass accelerator-specific configuration parameters
		/* <<--regs-config-->> */
		iowrite32(dev, AES_ENCRYPTION_REG, encryption);
		iowrite32(dev, AES_NUM_BLOCKS_REG, num_blocks);

		// Flush (customize coherence model here)
		esp_flush(ACC_COH_NONE);

		// Start accelerators
#ifndef __riscv
		printf("  Start...\n");
#else
		print_uart("  Start...\n");
#endif
		iowrite32(dev, CMD_REG, CMD_MASK_START);

		// Wait for completion
		done = 0;
		while (!done) {
			done = ioread32(dev, STATUS_REG);
			done &= STATUS_MASK_DONE;
		}
		iowrite32(dev, CMD_REG, 0x0);

#ifndef __riscv
		printf("  Done\n");
		printf("  validating...\n");
#else
		print_uart("  Done\n");
		print_uart("  validating...\n");
#endif

		/* Validation */
		errors = validate_buf(&mem[out_offset]);
#ifndef __riscv
		if (errors)
			printf("  ... FAIL\n");
		else
			printf("  ... PASS\n");
#else
		if (errors)
			print_uart("  ... FAIL\n");
		else
			print_uart("  ... PASS\n");
#endif

		aligned_free(ptable);
		aligned_free(mem);
	}

	return 0;
}
