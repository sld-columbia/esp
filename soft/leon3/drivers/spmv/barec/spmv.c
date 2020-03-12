/**
 * Baremetal device driver for SPMV
 *
 * Select Scatter-Gather in ESP configuration
 */

#ifndef __riscv
#include <stdio.h>
#endif
#include <stdlib.h>
#include <string.h>
#include <esp_accelerator.h>
#include <esp_probe.h>
#include <math.h>
#include <fixed_point.h>

#define SLD_SPMV   0x0C
#define DEV_NAME "sld,spmv"

/* Size of the contiguous chunks for scatter/gather */
#define CHUNK_SHIFT 14
#define CHUNK_SIZE BIT(CHUNK_SHIFT)
#define NCHUNK(_sz) ((_sz % CHUNK_SIZE == 0) ?		\
			(_sz / CHUNK_SIZE) :		\
			(_sz / CHUNK_SIZE) + 1)

// User defined registers
#define SPMV_NROWS_REG		0x40
#define SPMV_NCOLS_REG		0x44
#define SPMV_MAX_NONZERO_REG	0x48
#define SPMV_MTX_LEN_REG	0x4C
#define SPMV_VALS_PLM_SIZE_REG	0x50
#define SPMV_VECT_FITS_PLM_REG	0x54


#define MAX_REL_ERROR 0.003
#define MAX_ABS_ERROR 0.05

int check_error_threshold(float out, float gold)
{
	float error;

	if (gold != 0)
		error = fabs((gold - out) / gold);
	else if (out != 0)
		error = fabs((out - gold) / out);
	else
		error = 0;

	if (fabs(gold) >= 1) {
		return (error > MAX_REL_ERROR);
	} else {
		return (fabs(gold - out) > MAX_ABS_ERROR);
	}
}

static int validate(float *gold, float *out, int nrows, int verbose)
{
	int i;
	int rtn = 0;

	for (i = 0; i < nrows; i++)
		if (check_error_threshold(out[i], gold[i])) {
			if (verbose) {
#ifndef __riscv
				printf("out[%d]: result=%.15g; gold=%.15g\n", i, out[i], gold[i]);
#else
				print_uart("out["); print_uart_int(i); print_uart("]: result=");
				print_uart_int((unsigned long) &out[i]); print_uart("; gold=");
				print_uart_int((unsigned long) &gold[i]); print_uart("\n");
#endif
			}
			rtn++;
		}

	return rtn;
}

void spmv_comp(unsigned nrows, unsigned ncols,
	float *in_vals_buf, unsigned *in_cols_buf,
	unsigned *in_rows_buf, float *in_vect_buf,
	float *gold_buf)
{
	long i, j;
	double sum, Si;

	for(i = 0; i < nrows; i++) {
		int tmp_begin;
		int tmp_end;
		sum = 0; Si = 0;

		if (i == 0)
			tmp_begin = 0;
		else
			tmp_begin= in_rows_buf[i - 1];

		tmp_end = in_rows_buf[i];

		for (j = tmp_begin; j < tmp_end; j++) {
			Si = in_vals_buf[j] * in_vect_buf[in_cols_buf[j]];
			sum = sum + Si;
		}

		gold_buf[i] = sum;
	}


}

int main(int argc, char * argv[])
{
	unsigned int nrows;
	unsigned int ncols;
	unsigned int max_nonzero;
	unsigned int mtx_len;
	const unsigned int vals_plm_size = 256;
	const unsigned int vect_fits_plm = 0;

	float    *in_vals_buf;
	unsigned *in_cols_buf;
	unsigned *in_rows_buf;
	float    *in_vect_buf;
	float    *out_buf;
	float    *gold_buf;

	unsigned vals_addr;
	unsigned cols_addr;
	unsigned rows_addr;
	unsigned vect_addr;
	unsigned out_addr;

	unsigned vals_size;
	unsigned cols_size;
	unsigned rows_size;
	unsigned vect_size;
	unsigned out_size;

	int *in_vals_fx_buf;
	int *in_vect_fx_buf;
	int *out_fx_buf;

	int i;
	int n;
	int ndev;
	struct esp_device *espdevs = NULL;
	unsigned coherence;

	// Configure and initialize buffers
	nrows = 512;
	ncols = 512;
	max_nonzero = 8;
	mtx_len = 2385;

	vals_addr = 0;
	vals_size = mtx_len;

	cols_addr = mtx_len;
	cols_size = mtx_len;

	rows_addr = 2 * mtx_len;
	rows_size = nrows;

	vect_addr = nrows + 2 * mtx_len;
	vect_size = ncols;

	out_addr  = nrows + 2 * mtx_len + ncols;
	out_size  = nrows;

#ifndef __riscv
	printf("Memory allocation\n");
#else
	print_uart("Memory allocation\n");
#endif

	in_vals_buf = aligned_malloc(sizeof(float) * vals_size);
	in_cols_buf = aligned_malloc(sizeof(unsigned) * cols_size);
	in_rows_buf = aligned_malloc(sizeof(unsigned) * rows_size);
	in_vect_buf = aligned_malloc(sizeof(float) * vect_size);
	out_buf     = aligned_malloc(sizeof(float) * out_size);
	gold_buf    = aligned_malloc(sizeof(float) * out_size);

	in_vals_fx_buf = aligned_malloc(sizeof(int) * vals_size);
	in_vect_fx_buf = aligned_malloc(sizeof(int) * vect_size);
	out_fx_buf     = aligned_malloc(sizeof(int) * out_size);

	if (!(in_vals_buf && in_cols_buf && in_rows_buf && in_vect_buf && out_buf && in_vals_fx_buf && in_vect_fx_buf && out_fx_buf)) {
#ifndef __riscv
		printf("Error: not enough memory\n");
#else
		print_uart("Error: not enough memory\n");
#endif
		exit(EXIT_FAILURE);
	}

#ifndef __riscv
	printf("Data initialization\n");
#else
	print_uart("Data initialization\n");
#endif

#include "data.h"

	for (i = 0; i < vals_size; i++)
		in_vals_fx_buf[i] = float_to_fixed32(in_vals_buf[i], 16);

	for (i = 0; i < vect_size; i++)
		in_vect_fx_buf[i] = float_to_fixed32(in_vect_buf[i], 16);

	// Search for the device
	ndev = probe(&espdevs, SLD_SPMV, DEV_NAME);
	if (!ndev) {
#ifndef __riscv
		printf("Error: %s device not found!\n", DEV_NAME);
#else
		print_uart("Error: "); print_uart(DEV_NAME); print_uart(" device not found!\n");
#endif
		exit(EXIT_FAILURE);
	}

	// Run software
#ifndef __riscv
	printf("Software execution\n");
#else
	print_uart("Software execution\n");
#endif
	spmv_comp(nrows, ncols, in_vals_buf, in_cols_buf, in_rows_buf, in_vect_buf, gold_buf);

	// Test all devices matching SPMV ID.
	for (n = 0; n < ndev; n++) {
#ifndef __riscv
		for (coherence = ACC_COH_NONE; coherence <= ACC_COH_FULL; coherence++) {
#else
		{
			/* TODO: Restore full test once ESP caches are integrated */
			coherence = ACC_COH_NONE;
#endif
			struct esp_device *dev = &espdevs[n];

			unsigned done;
			unsigned **ptable;
			unsigned *mem;
			unsigned errors = 0;
			int scatter_gather = 1;
			size_t size;
#ifndef __riscv
			printf("Testing %s.%d \n", DEV_NAME, n);
#else
			print_uart("Testing "); print_uart(DEV_NAME); print_uart("."); print_uart_int(n); print_uart("\n");
#endif

			// Check access ok (TODO)

			// Check if scatter-gather DMA is disabled
			if (ioread32(dev, PT_NCHUNK_MAX_REG) == 0) {
#ifndef __riscv
				printf("  -> scatter-gather DMA is disabled; revert to contiguous buffer.\n");
#else
				print_uart("  -> scatter-gather DMA is disabled; revert to contiguous buffer.\n");
#endif
				scatter_gather = 0;
			} else {
#ifndef __riscv
				printf("  -> scatter-gather DMA is enabled.\n");
#else
				print_uart("  -> scatter-gather DMA is enabled.\n");
#endif
			}

			size = sizeof(int) * (vals_size + cols_size + rows_size + vect_size + out_size);

			if (scatter_gather)
				if (ioread32(dev, PT_NCHUNK_MAX_REG) < NCHUNK(size)) {
#ifndef __riscv
					printf("  Trying to allocate %lu chunks on %d TLB available entries\n",
						NCHUNK(size), ioread32(dev, PT_NCHUNK_MAX_REG));
#else
					print_uart("  Trying to allocate more chunks than available TLB entries\n");
#endif
					break;
				}

			// Allocate memory (will be contigous anyway in baremetal)
			mem = aligned_malloc(size);
			if (!mem) {
#ifndef __riscv
				printf("Error: not enough memory\n");
#else
				print_uart("Error: not enough memory\n");
#endif
				exit(EXIT_FAILURE);
			}
#ifndef __riscv
			printf("  memory buffer base-address = %p\n", mem);
#else
			print_uart("  memory buffer base-address = 0x"); print_uart_int((unsigned long) mem); print_uart("\n");
#endif

			if (scatter_gather) {
				//Alocate and populate page table
				ptable = aligned_malloc(NCHUNK(size) * sizeof(unsigned *));
				for (i = 0; i < NCHUNK(size); i++)
					ptable[i] = (unsigned *) &mem[i * (CHUNK_SIZE / sizeof(unsigned))];
#ifndef __riscv
				printf("  ptable = %p\n", ptable);
				printf("  nchunk = %lu\n", NCHUNK(size));
#else
				print_uart("  ptable = 0x"); print_uart_int((unsigned long) ptable); print_uart("\n");
				print_uart("  nchunk = 0x"); print_uart_int(NCHUNK(size)); print_uart("\n");
#endif
			}

			// Initialize input: write floating point hex values (simpler to debug)
#ifndef __riscv
			printf("  Prepare input... ");
#else
			print_uart("  Prepare input... ");
#endif
			memcpy(&mem[vals_addr], in_vals_fx_buf, sizeof(int) * vals_size);
			memcpy(&mem[cols_addr], in_cols_buf, sizeof(int) * cols_size);
			memcpy(&mem[rows_addr], in_rows_buf, sizeof(int) * rows_size);
			memcpy(&mem[vect_addr], in_vect_fx_buf, sizeof(int) * vect_size);
#ifndef __riscv
			printf("Input ready\n");
#else
			print_uart("Input ready\n");
#endif

			// Configure device
			iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
			iowrite32(dev, COHERENCE_REG, coherence);

			if (scatter_gather) {
				iowrite32(dev, PT_ADDRESS_REG, (unsigned long) ptable);
				iowrite32(dev, PT_NCHUNK_REG, NCHUNK(size));
				iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);
				iowrite32(dev, SRC_OFFSET_REG, 0);
				iowrite32(dev, DST_OFFSET_REG, 0); // Sort runs in place
			} else {
				iowrite32(dev, SRC_OFFSET_REG, (unsigned long) mem);
				iowrite32(dev, DST_OFFSET_REG, (unsigned long) mem); // Sort runs in place
			}

			iowrite32(dev, SPMV_NROWS_REG, nrows);
			iowrite32(dev, SPMV_NCOLS_REG, ncols);
			iowrite32(dev, SPMV_MAX_NONZERO_REG, max_nonzero);
			iowrite32(dev, SPMV_MTX_LEN_REG, mtx_len);
			iowrite32(dev, SPMV_VALS_PLM_SIZE_REG, vals_plm_size);
			iowrite32(dev, SPMV_VECT_FITS_PLM_REG, vect_fits_plm);

			// Flush for non-coherent DMA
			esp_flush(coherence);

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


			/* Validation */
#ifndef __riscv
			printf("  validating...\n");
#else
			print_uart("  validating...\n");
#endif


			memcpy(out_fx_buf, &mem[out_addr], out_size * sizeof(int));
			for (i = 0; i < out_size; i++)
				out_buf[i] = fixed32_to_float(out_fx_buf[i], 16);

			errors = validate(gold_buf, out_buf, nrows, 0);

#ifndef __riscv
			if (errors)
				printf("  ... FAIL\n");
			else
				printf("  ... PASS\n");
			printf("\n");
#else
			if (errors)
				print_uart("  ... FAIL\n");
			else
				print_uart("  ... PASS\n");
			print_uart("\n");
#endif

			if (scatter_gather)
				aligned_free(ptable);
			aligned_free(mem);
		}
	}
	return 0;
}

