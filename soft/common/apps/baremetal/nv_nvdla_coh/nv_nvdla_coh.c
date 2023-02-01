/* Copyright (c) 2011-2023 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>
#include <fixed_point.h>


typedef unsigned long long int token_t;
typedef unsigned long long int native_t;

static unsigned DMA_WORD_PER_BEAT(unsigned _st)
{
		return (sizeof(void *) / _st);
}

#define MAX_PRINTED_ERRORS 10


#define NV_NVDLA  0x100
#define DEV_NAME "nvidia,nv_small"

#define CSR_TILE_SIZE 0x200
#define CSR_BASE_ADDR 0x60090000
#define COH_REG_INDEX 107

static unsigned i_base;
static unsigned w_base;
static unsigned b_base;
static unsigned o_base;
static unsigned mem_size;
static unsigned out_len;
static unsigned out_size;
static unsigned out_offset;

static int validate_buf(token_t *out, native_t *gold)
{
	int j;
	native_t val;
	unsigned errors = 0;

		for (j = 0; j < out_len; j++) {
			val = out[j];

			if (gold[j] != val) {
				errors++;
				if (errors <= MAX_PRINTED_ERRORS) {
			printf("%d : %llu : %llu\n", j, val, gold[j]);
		}
			}
	}

	return errors;
}

static void init_buf (token_t *in, native_t * gold)
{
#include "input.h"
#include "gold.h"
}

int main(int argc, char * argv[])
{
	int i;
	int n;
	int ndev;
	struct esp_device *espdevs;
	struct esp_device *dev;
	unsigned done;
	token_t *mem;
	native_t *gold;
	unsigned errors = 0;
	unsigned coherence;
	unsigned error_id;
	unsigned read_val;
	unsigned int coh;
	unsigned int tile_offset;
	unsigned int* coh_reg_addr;

	//change this depending on the SoC layout and number of NVDLA instances
	unsigned int nvdla_tile_numbers[1] = {2};
	i_base = 0x200;
	w_base = 0x000;
	b_base = 0x280;
	o_base = 0x400;
	mem_size = 0x500;

	out_len = 12;
	out_size = 12 * sizeof(native_t);
	out_offset = o_base / sizeof(native_t);

	// Search for the device
	printf("Scanning device tree... \n");

	ndev = probe(&espdevs, VENDOR_SLD, NV_NVDLA, DEV_NAME);
	if (ndev == 0) {
		printf("nv_nvdla not found\n");
		return 0;
	}

	for (n = 0; n < ndev; n++) {

		dev = &espdevs[n];

		// Allocation of the accelerator data array (mem) and of the expected output array (gold)
		mem = aligned_malloc(mem_size);
		gold = aligned_malloc(out_size);
		printf("  memory buffer base-address = %p\n", mem);
		printf("  memory buffer base-address for gold = %p\n", gold);

		printf("  Generate input...\n");

		init_buf(mem, gold);

		// Write coherence mode and flush (customize coherence model here)
		tile_offset = (CSR_TILE_SIZE / sizeof(unsigned int)) * nvdla_tile_numbers[n];
		coh_reg_addr = ((unsigned int*) CSR_BASE_ADDR) + tile_offset + COH_REG_INDEX;
		coh = ACC_COH_RECALL;
		*coh_reg_addr = coh;
		esp_flush(coh);

		// Write the accelerator configuration registers

		error_id = 0;

		//read_val = ioread32(dev, 28676);
		//if (read_val != 1 && read_val != 65536)
		//	printf("error %u\n", error_id);
		//error_id++;

		iowrite32(dev, 28676, 0);
		iowrite32(dev, 20484, 0);
		iowrite32(dev, 24580, 0);
		iowrite32(dev, 16388, 0);
		iowrite32(dev, 12292, 0);

		read_val = ioread32(dev, 28672);
		if (read_val != 0)
			printf("error %u\n", error_id);
		error_id++;

		read_val = ioread32(dev, 20480);
		if (read_val != 0)
			printf("error %u\n", error_id);
		error_id++;

		read_val = ioread32(dev, 24576);
		if (read_val != 0)
			printf("error %u\n", error_id);
		error_id++;

		read_val = ioread32(dev, 16384);
		if (read_val != 0)
			printf("error %u\n", error_id);
		error_id++;

		read_val = ioread32(dev, 12288);
		if (read_val != 0)
			printf("error %u\n", error_id);
		error_id++;

		iowrite32(dev, 28684, 0);
		iowrite32(dev, 28688, 65537);
		iowrite32(dev, 28692, 19);
		iowrite32(dev, 28696, 0);
		iowrite32(dev, 28700, 0);
		iowrite32(dev, 28704, 16);
		iowrite32(dev, 28708, 32);
		iowrite32(dev, 28712, 0);
		iowrite32(dev, 28716, 0);
		iowrite32(dev, 20492, 0);
		iowrite32(dev, 24588, 0);
		iowrite32(dev, 16396, 0);
		iowrite32(dev, 16400, 0);
		iowrite32(dev, 16404, 327685);
		iowrite32(dev, 16408, 0);
		iowrite32(dev, 16412, 0);
		iowrite32(dev, 16416, 0);
		iowrite32(dev, 16420, 5);
		iowrite32(dev, 16424, 0);
		iowrite32(dev, 16428, 262148);
		iowrite32(dev, 16432, 1245184);
		iowrite32(dev, 16436, 504);
		iowrite32(dev, 16440, 0);
		iowrite32(dev, 16444, 65537);
		iowrite32(dev, 16448, 19);
		iowrite32(dev, 16452, 3);
		iowrite32(dev, 16456, 5);
		iowrite32(dev, 16460, 0);
		iowrite32(dev, 16464, 0);
		iowrite32(dev, 16468, 0);
		iowrite32(dev, 16472, 0);
		iowrite32(dev, 16476, 0);
		iowrite32(dev, 16480, 0);
		iowrite32(dev, 12308, 0);
		iowrite32(dev, 12312, 1048576);
		iowrite32(dev, 12316, 327685);
		iowrite32(dev, 12320, 0);
		iowrite32(dev, 12324, 327685);
		iowrite32(dev, 12332, 1);
		iowrite32(dev, 12336, 0);
		iowrite32(dev, 12340, ((uint64_t) mem) + b_base); // 2686488576
		iowrite32(dev, 12344, 0);
		iowrite32(dev, 12348, ((uint64_t) mem) + b_base); // 2686488576
		iowrite32(dev, 12352, 48);
		iowrite32(dev, 12360, 288);
		iowrite32(dev, 12356, 0);
		iowrite32(dev, 12364, 65537);
		iowrite32(dev, 12376, 0);
		iowrite32(dev, 12380, 0);
		iowrite32(dev, 12384, 5);
		iowrite32(dev, 12388, 0);
		iowrite32(dev, 12392, 0);
		iowrite32(dev, 12396, 24);
		iowrite32(dev, 12400, 19);
		iowrite32(dev, 12404, 1);
		iowrite32(dev, 12408, 0);
		iowrite32(dev, 12412, ((uint64_t) mem) + w_base); // 2686459904
		iowrite32(dev, 12416, 504);
		iowrite32(dev, 12440, 0);
		iowrite32(dev, 12452, 1);
		iowrite32(dev, 12456, 0);
		iowrite32(dev, 12460, 1);
		iowrite32(dev, 12464, 0);
		iowrite32(dev, 12468, 0);
		iowrite32(dev, 12472, 0);
		iowrite32(dev, 12476, 0);

		//read_val = ioread32(dev, 36868);
		//if (read_val != 1 && read_val != 65536)
		//	printf("error %u\n", error_id);
		//error_id++;

		//read_val = ioread32(dev, 32772);
		//if (read_val != 1 && read_val != 65536)
		//	printf("error %u\n", error_id);
		//error_id++;

		iowrite32(dev, 36868, 0);
		iowrite32(dev, 32772, 0);

		read_val = ioread32(dev, 4100);
		if (read_val != 0)
			printf("error %u\n", error_id);
		error_id++;

		iowrite32(dev, 4100, 0);
		iowrite32(dev, 32880, 0);
		iowrite32(dev, 32808, 0);
		iowrite32(dev, 32832, 0);
		iowrite32(dev, 32856, 0);
		iowrite32(dev, 32880, 1);
		iowrite32(dev, 32780, 1);
		iowrite32(dev, 32784, 1);
		iowrite32(dev, 32788, 19);
		iowrite32(dev, 32808, 44);
		iowrite32(dev, 32812, ((uint64_t) mem) + i_base); // 2686464000
		iowrite32(dev, 32816, 0);
		iowrite32(dev, 32820, 32);
		iowrite32(dev, 32824, 32);
		iowrite32(dev, 32832, 49);
		iowrite32(dev, 32856, 49);
		iowrite32(dev, 36924, 1);
		iowrite32(dev, 36928, 1);
		iowrite32(dev, 36932, 19);
		iowrite32(dev, 36940, 0);
		iowrite32(dev, 36936, ((uint64_t) mem) + o_base); // 2686492672
		iowrite32(dev, 36944, 16);
		iowrite32(dev, 36948, 32);
		iowrite32(dev, 36952, 72);
		iowrite32(dev, 36956, 1);
		iowrite32(dev, 36964, 6145);
		iowrite32(dev, 36972, 83);
		iowrite32(dev, 36992, 83);
		iowrite32(dev, 37040, 1);
		iowrite32(dev, 37044, 1);
		iowrite32(dev, 37052, 0);
		iowrite32(dev, 37056, 0);
		iowrite32(dev, 37060, 1);
		iowrite32(dev, 37064, 0);
		iowrite32(dev, 36868, 0);
		iowrite32(dev, 32772, 0);
		iowrite32(dev, 32776, 1);
		iowrite32(dev, 36920, 1);
		iowrite32(dev, 28676, 0);
		iowrite32(dev, 20484, 0);
		iowrite32(dev, 24580, 0);
		iowrite32(dev, 16388, 0);
		iowrite32(dev, 12292, 0);

		read_val = ioread32(dev, 12300);
		if (read_val != 1)
			printf("error %u\n", error_id);
		error_id++;

		iowrite32(dev, 28680, 1);
		iowrite32(dev, 20488, 1);
		iowrite32(dev, 24584, 1);
		iowrite32(dev, 16392, 1);
		iowrite32(dev, 12304, 1);

		for (i = 0; i < 10; ++i)
			printf("wait...\n");

		read_val = ioread32(dev, 4100);
		if (read_val != 0)
			printf("error %u\n", error_id);
		error_id++;

		read_val = ioread32(dev, 4108);
		if (read_val != 1376257  && read_val != 2752514)
			printf("error %u\n", error_id);
		error_id++;
		iowrite32(dev, 4108, read_val);

		read_val = ioread32(dev, 4100);
		if (read_val != 0)
			printf("error %u\n", error_id);
		error_id++;

		read_val = ioread32(dev, 4108);
		if (read_val != 0)
			printf("error %u\n", error_id);
		error_id++;

		printf("  Done\n");

		/* Validation */
		printf("  validating...\n");
		errors = validate_buf(&mem[out_offset], gold);

		if (errors)
			printf("  ... FAIL\n");
		else
			printf("  ... PASS\n");

		aligned_free(mem);
		aligned_free(gold);
	}

	return 0;
}
