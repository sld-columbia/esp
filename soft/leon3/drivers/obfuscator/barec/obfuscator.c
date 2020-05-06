/* Copyright (c) 2011-2019 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#ifndef __riscv
#include <stdio.h>
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>

#include <fixed_point.h>
typedef float native_t;
typedef unsigned token_t;

static unsigned DMA_WORD_PER_BEAT(unsigned _st)
{
        return (sizeof(void *) / _st);
}

#define SLD_OBFUSCATOR 0x04A
#define DEV_NAME "sld,obfuscator"

#define DIFT_SUPPORT_ENABLED
#define ENABLE_REGS_ATTACK

const int32_t num_rows   = 20;
const int32_t num_cols   = 20;

const int32_t i_row_blur = 5;
const int32_t e_row_blur = 10;
const int32_t i_col_blur = 0;
const int32_t e_col_blur = 20;

const int32_t ld_offset  = 0;

#ifdef DIFT_SUPPORT_ENABLED
const int32_t st_offset  = 20 * 20 * 2;
#else // !DIFT_SUPPORT_ENABLED
const int32_t st_offset  = 20 * 20;
#endif // DIFT_SUPPORT_ENABLED

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
/* <<--regs-->> */
#define OBFUSCATOR_NUM_ROWS_REG   0x40
#define OBFUSCATOR_NUM_COLS_REG   0x44
#define OBFUSCATOR_I_ROW_BLUR_REG 0x48
#define OBFUSCATOR_I_COL_BLUR_REG 0x4c
#define OBFUSCATOR_E_ROW_BLUR_REG 0x50
#define OBFUSCATOR_E_COL_BLUR_REG 0x54
#define OBFUSCATOR_LD_OFFSET_REG  0x58
#define OBFUSCATOR_ST_OFFSET_REG  0x5c

static float exp[20][20] = {
{ 32.0, 31.0, 32.0, 31.0, 32.0, 31.0, 32.0, 31.0, 32.0, 31.0, 32.0, 31.0, 32.0, 31.0, 32.0, 31.0, 32.0, 31.0, 32.0, 31.0 },
{ 32.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 31.0 },
{ 32.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 31.0 },
{ 32.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 31.0 },
{ 32.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 31.0 },
{ 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0 },
{ 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0 },
{ 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0 },
{ 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0 },
{ 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0, 34.0 },
{ 32.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 31.0 },
{ 32.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 31.0 },
{ 32.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 31.0 },
{ 32.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 31.0 },
{ 32.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 31.0 },
{ 32.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 31.0 },
{ 32.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 31.0 },
{ 32.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 31.0 },
{ 32.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 29.0, 34.0, 31.0 },
{ 32.0, 31.0, 32.0, 31.0, 32.0, 31.0, 32.0, 31.0, 32.0, 31.0, 32.0, 31.0, 32.0, 31.0, 32.0, 31.0, 32.0, 31.0, 32.0, 31.0 }};

static int validate_buf(token_t *out, token_t *gold)
{
    int x, y;
	int index = 0;
    unsigned errors = 0;

    for (x = 0; x < num_rows; ++x)
    {
        for (y = 0; y < num_cols; ++y)
        {
            // Val

            native_t value = fixed32_to_float(out[index], 11);

            if (value != exp[x][y])
            {
                errors += 1;
            }

            index++;

            // Tag

#ifdef DIFT_SUPPORT_ENABLED
            if (out[index] != 0)
            {
                errors += 1;
            }

            index++;
#endif // DIFT_SUPPORT_ENABLED

        }
    }

	return errors;
}

static void init_buf(token_t *in, token_t * gold)
{
    int x, y;
    int index = 0;

    // Populate in

	for (x = 0; x < num_rows; ++x)
    {
        for (y = 0; y < num_cols; ++y)
        {
            // Val

			if (y % 2 == 0)
            	in[index] = float_to_fixed32((native_t) 32.0, 11);
            else // y % 2 == 1
				in[index] = float_to_fixed32((native_t) 31.0, 11);

            index++;

            // Tag

#ifdef DIFT_SUPPORT_ENABLED
            if (x >= i_row_blur &&
                x <= e_row_blur &&
                y >= i_col_blur &&
                y <= e_col_blur)
            {
                in[index] = 1;
            }
            else
            {
                in[index] = 0;
            }

            index++;
#endif // DIFT_SUPPORT_ENABLED

        }
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
#ifdef DIFT_SUPPORT_ENABLED
		in_words_adj = num_rows * num_cols * 2;
		out_words_adj = num_rows * num_cols * 2;
#else // !DIFT_SUPPORT_ENABLED
		in_words_adj = num_rows * num_cols;
		out_words_adj = num_rows * num_cols;
#endif // DIFT_SUPPORT_ENABLED
    }
    else
    {
#ifdef DIFT_SUPPORT_ENABLED
        in_words_adj = round_up(num_rows * num_cols * 2,
                DMA_WORD_PER_BEAT(sizeof(token_t)));
        out_words_adj = round_up(num_rows * num_cols * 2,
                DMA_WORD_PER_BEAT(sizeof(token_t)));
#else // !DIFT_SUPPORT_ENABLED
        in_words_adj = round_up(num_rows * num_cols,
                DMA_WORD_PER_BEAT(sizeof(token_t)));
        out_words_adj = round_up(num_rows * num_cols,
                DMA_WORD_PER_BEAT(sizeof(token_t)));
#endif // DIFT_SUPPORT_ENABLED
    }

    in_len   = in_words_adj;
	out_len  = out_words_adj;
    in_size  = in_len * sizeof(token_t);
	out_size = out_len * sizeof(token_t);

    out_offset = in_len;
	mem_size = (out_offset * sizeof(token_t)) + out_size;

	// Search for the device
#ifndef __riscv
	printf("Scanning device tree... \n");
#else
	print_uart("Scanning device tree... \n");
#endif

	ndev = probe(&espdevs, SLD_OBFUSCATOR, DEV_NAME);
	if (ndev == 0)
    {
#ifndef __riscv
		printf("obfuscator not found\n");
#else
		print_uart("obfuscator not found\n");
#endif
		return 0;
	}

	for (n = 0; n < ndev; n++)
    {
		dev = &espdevs[n];

		// Check DMA capabilities

        if (ioread32(dev, PT_NCHUNK_MAX_REG) == 0)
        {
#ifndef __riscv
			printf("  -> scatter-gather DMA is disabled. Abort.\n");
#else
			print_uart("  -> scatter-gather DMA is disabled. Abort.\n");
#endif
			return 0;
		}

		if (ioread32(dev, PT_NCHUNK_MAX_REG) < NCHUNK(mem_size))
        {
#ifndef __riscv
			printf("  -> Not enough TLB entries available. Abort.\n");
#else
			print_uart("  -> Not enough TLB entries available. Abort.\n");
#endif
			return 0;
		}

		// Allocate memory
		gold = aligned_malloc(out_size);
		mem = aligned_malloc(mem_size);

#ifndef __riscv
		printf("  memory buffer base-address = %p\n", mem);
#else
		print_uart("  memory buffer base-address = ");
        print_uart_addr((uintptr_t) mem); print_uart("\n");
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
		printf("  Generate input... =) \n");
#else
		print_uart("  Generate input... =) \n");
#endif
		init_buf(mem, gold);

#ifdef DIFT_SUPPORT_ENABLED
#ifndef __riscv
		printf("  DIFT enabled... =) \n");
#else
		print_uart("  DIFT enabled... =) \n");
#endif
#endif
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

#ifdef DIFT_SUPPORT_ENABLED
#ifndef __riscv
		printf("  REGS attacked... =) \n");
#else
		print_uart("  REGS attacked... =) \n");
#endif
#endif	
		// Pass accelerator-specific configuration parameters
		/* <<--regs-config-->> */
#ifdef ENABLE_REGS_ATTACK
        iowrite32(dev, OBFUSCATOR_NUM_ROWS_REG, num_rows + 2);
#else // !ENABLE_REGS_ATTACK
        iowrite32(dev, OBFUSCATOR_NUM_ROWS_REG, num_rows);
#endif // ENABLE_REGS_ATTACK
        iowrite32(dev, OBFUSCATOR_NUM_COLS_REG, num_cols);
		iowrite32(dev, OBFUSCATOR_I_ROW_BLUR_REG, i_row_blur);
		iowrite32(dev, OBFUSCATOR_I_COL_BLUR_REG, i_col_blur);
		iowrite32(dev, OBFUSCATOR_E_ROW_BLUR_REG, e_row_blur);
		iowrite32(dev, OBFUSCATOR_E_COL_BLUR_REG, e_col_blur);
		iowrite32(dev, OBFUSCATOR_LD_OFFSET_REG, ld_offset);
		iowrite32(dev, OBFUSCATOR_ST_OFFSET_REG, st_offset);

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
		errors = validate_buf(&mem[out_offset], gold);
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
		aligned_free(gold);
	}

	return 0;
}
