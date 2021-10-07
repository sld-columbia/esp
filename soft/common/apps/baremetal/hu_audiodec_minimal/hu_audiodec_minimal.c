/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>
#include <fixed_point.h>
#include "hu_audiodec_minimal.h"

typedef int32_t token_t;

static unsigned DMA_WORD_PER_BEAT(unsigned _st)
{
    return (sizeof(void *) / _st);
}

#define SLD_HU_AUDIODEC 0x089
#define DEV_NAME "sld,hu_audiodec_rtl"

/* <<--params-->> */
const int32_t conf_0  =  0;   // 0: dummy
const int32_t conf_1  =  0;   // 1: dummy, channel is fixed a 16
const int32_t conf_2  =  8;   // audio block size
// FIXME need to set dma_read_index and dma_write_index properly
const int32_t conf_3  =  0;   // dma_read_index  
const int32_t conf_4  =  64;  // dma_write_index 128*32b/64b = 64 
const int32_t conf_5  =  0;   // 5-07: dummy
const int32_t conf_6  =  0;
const int32_t conf_7  =  0;   
const int32_t conf_8  =  39413;   // 08: cfg_cos_alpha;  
const int32_t conf_9  =  60968;   // 09: cfg_sin_alpha;
const int32_t conf_10 =  -46013;   // 10: cfg_cos_beta;
const int32_t conf_11 =  -56152;   // 11: cfg_sin_beta;
const int32_t conf_12 =  -35750;   // 12: cfg_cos_gamma;
const int32_t conf_13 =  -22125;   // 13: cfg_sin_gamma;
const int32_t conf_14 =  -39414;   // 14: cfg_cos_2_alpha;
const int32_t conf_15 =  57035;   // 15: cfg_sin_2_alpha;
const int32_t conf_16 =  -15211;   // 16: cfg_cos_2_beta;
const int32_t conf_17 =  10276;   // 17: cfg_sin_2_beta;
const int32_t conf_18 =  27688;   // 18: cfg_cos_2_gamma;
const int32_t conf_19 =  -48707;   // 19: cfg_sin_2_gamma;
const int32_t conf_20 =  -42691;   // 20: cfg_cos_3_alpha;
const int32_t conf_21 =  -11292;   // 21: cfg_sin_3_alpha;
const int32_t conf_22 =  48018;   // 22: cfg_cos_3_beta;
const int32_t conf_23 =  23121;   // 23: cfg_sin_3_beta;
const int32_t conf_24 =  -53190;   // 24: cfg_cos_3_gamma;
const int32_t conf_25 =  22878;   // 25: cfg_sin_3_gamma;
const int32_t conf_26 =  0;		// 26-31: dummy
const int32_t conf_27 =  0;
const int32_t conf_28 =  0;
const int32_t conf_29 =  0;
const int32_t conf_30 =  0;
const int32_t conf_31 =  0; 

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
#define NCHUNK(_sz) ((_sz % CHUNK_SIZE == 0) ?	\
		     (_sz / CHUNK_SIZE) :	\
		     (_sz / CHUNK_SIZE) + 1)

/* User defined registers */
/* <<--regs-->> */

static int validate_buf(token_t* out, token_t* gold)
{
    int i;
    unsigned errors = 0;

    for (i = 0; i < 128; i++) {
	if (gold[i] != out[i]) {
	    printf("%d : %d <-- error \n", gold[i], out[i]);
	    errors++;
	} /*else {
	    printf("%d : %d\n", gold[i], out[i]);
	}*/
    }

    return errors;
}


static void init_buf (token_t* in, token_t* gold)
{
    int i;
    int j;
  

    // audio_in[8][16] block size of 8 and 16 channels
    int32_t audio_in[128] = {
	0, 46956, 20486, -7767, 8080, -15972, 48876, -61539, 17530, 6186, 55830, 1599, -17846, -46806, -22604, -48556,
	0, 14640, -6849, 39524, -39538, 49604, -62424, 30140, 39773, 57357, 30140, -20913, 1893, 5786, 6343, -39217,
	0, 31444, 59546, -24019, -39073, 52264, 10492, -53281, 4469, -21024, -14012, -17243, -37146, 19890, 14424, -2648,
	0, 39511, 45462, 1795, -55876, 31378, 2549, -48556, 31496, -8206, 12537, -6489, -35705, -32139, -1967, 4338,
	0, -8546, 52, 18920, -23613, -62404, 4194, -41072, 14693, 16495, 11429, -10211, -25297, -55149, -14956, 51098,
	0, 42283, -45751, -5604, 44479, 5767, -45574, 21889, -8278, -39728, 2824, 58903, -17204, 1644, -25900, -16666,
	0, 35730, -60104, 14955, -60195, -9982, 45278, -25055, -52849, 63714, 144, -28004, 20289, 57271, -8363, -2471,
	0, -603, -17682, 63740, -17636, 62023, 17897, 29314, 17137, 43312, -2255, 23802, 5426, 9083, 20270, 2097
    };

    // audio_out[8][16] block size of 8, and 16 channels 
    // reference output
    int32_t audio_out[128] = {
	0, -34519, -47810, 12544, 67691, -41491, -52565, 5253, -15552, -39352, -23717, -20250, -95006, 14865, 33953, -12760, 
	0, 8373, -27227, 20559, -84368, -675, 25143, -11761, -56951, 10040, -12294, 117, -30892, 15658, 2782, -19321, 
	0, -43239, -54495, 19574, 2178, -34299, -5259, 6577, -53469, 20580, 44490, -2974, -11615, -3359, -12250, 24679, 
	0, -34170, -64338, 28282, -12197, -36253, -42778, 10233, -56617, -22731, 24930, -12662, -42978, 1134, 32743, 5401, 
	0, 11577, -2974, 9014, 23693, -559, -104591, 1797, 13873, -37102, 28600, -4373, -26765, 3208, 61310, -26930, 
	0, -12007, 1306, -17954, -7670, 20787, 43619, -39543, -3619, -5217, -23187, 6950, -32588, -16501, 6610, 35080, 
	0, 3242, 6013, -14474, 3569, 13586, -35038, 49086, 44199, 57691, 1437, 31054, 16639, 14147, -32750, -39608, 
	0, 28706, -19949, 26343, -33509, -23263, 63536, 24505, -30473, 4608, -14731, 9332, 26619, -11470, 13574, 13357
    };

    // pack int16_t into int32_t data, little endian
    for (i = 0; i < 128; i++) {
	in[i] = audio_in[i];
    }
    for (i = 0; i < 128; i++) {
	gold[i] = audio_out[i];
    }
}

int main(int argc, char * argv[])
{
    int i;
    int n;
    int ndev;
    struct esp_device dev;
    unsigned done;
    unsigned **ptable;
    token_t *mem;
    token_t *gold;
    unsigned errors = 0;
    unsigned coherence;

    in_len = 128;
    out_len = 128;
	
    in_size = in_len * sizeof(token_t);
    out_size = out_len * sizeof(token_t);	
    out_offset = in_len;
    mem_size = in_size + out_size;

    dev.addr = ACC_ADDR;

	// Allocate memory
	gold = aligned_malloc(out_size);
	mem = aligned_malloc(mem_size);
	//printf("  memory buffer base-address = %p\n", mem);

	// Alocate and populate page table
	ptable = aligned_malloc(NCHUNK(mem_size) * sizeof(unsigned *));
	for (i = 0; i < NCHUNK(mem_size); i++)
	    ptable[i] = (unsigned *) &mem[i * (CHUNK_SIZE / sizeof(token_t))];

	//printf("  ptable = %p\n", ptable);
	//printf("  nchunk = %lu\n", NCHUNK(mem_size));

	/* TODO: Restore full test once ESP caches are integrated */
	coherence = ACC_COH_RECALL;

	//printf("  --------------------\n");
	//printf("  Generate input...\n");
	init_buf(mem, gold);

	// Pass common configuration parameters

	iowrite32(&dev, SELECT_REG, ioread32(&dev, DEVID_REG));
	iowrite32(&dev, COHERENCE_REG, coherence);

#ifndef __sparc
	iowrite32(&dev, PT_ADDRESS_REG, (unsigned long long) ptable);
#else
	iowrite32(&dev, PT_ADDRESS_REG, (unsigned) ptable);
#endif
	iowrite32(&dev, PT_NCHUNK_REG, NCHUNK(mem_size));
	iowrite32(&dev, PT_SHIFT_REG, CHUNK_SHIFT);

	// Use the following if input and output data are not allocated at the default offsets
	iowrite32(&dev, SRC_OFFSET_REG, 0x0);
	// TODO need to add output offset?
	iowrite32(&dev, DST_OFFSET_REG, 0x0);

	// Pass accelerator-specific configuration parameters
	/* <<--regs-config-->> */
	iowrite32(&dev, 0xBC, conf_0 );
	iowrite32(&dev, 0xB8, conf_1 );
	iowrite32(&dev, 0xB4, conf_2 );
	iowrite32(&dev, 0xB0, conf_3 );
	iowrite32(&dev, 0xAC, conf_4 );
	iowrite32(&dev, 0xA8, conf_5 );
	iowrite32(&dev, 0xA4, conf_6 );
	iowrite32(&dev, 0xA0, conf_7 );
	iowrite32(&dev, 0x9C, conf_8 );
	iowrite32(&dev, 0x98, conf_9 );
	iowrite32(&dev, 0x94, conf_10);
	iowrite32(&dev, 0x90, conf_11);
	iowrite32(&dev, 0x8C, conf_12);
	iowrite32(&dev, 0x88, conf_13);
	iowrite32(&dev, 0x84, conf_14);
	iowrite32(&dev, 0x80, conf_15);
	iowrite32(&dev, 0x7C, conf_16);
	iowrite32(&dev, 0x78, conf_17);
	iowrite32(&dev, 0x74, conf_18);
	iowrite32(&dev, 0x70, conf_19);
	iowrite32(&dev, 0x6C, conf_20);
	iowrite32(&dev, 0x68, conf_21);
	iowrite32(&dev, 0x64, conf_22);
	iowrite32(&dev, 0x60, conf_23);
	iowrite32(&dev, 0x5C, conf_24);
	iowrite32(&dev, 0x58, conf_25);
	iowrite32(&dev, 0x54, conf_26);
	iowrite32(&dev, 0x50, conf_27);
	iowrite32(&dev, 0x4C, conf_28);
	iowrite32(&dev, 0x48, conf_29);
	iowrite32(&dev, 0x44, conf_30);
	iowrite32(&dev, 0x40, conf_31);


	// Flush (customize coherence model here)
	if (coherence != ACC_COH_RECALL)
        esp_flush(coherence);

	// Start accelerators
	//printf("  Start...\n");
	iowrite32(&dev, CMD_REG, CMD_MASK_START);

	// Wait for completion
	done = 0;
	while (!done) {
	    done = ioread32(&dev, STATUS_REG);
	    done &= STATUS_MASK_DONE;
	}
	iowrite32(&dev, CMD_REG, 0x0);

	//printf("  Done\n");
	//printf("  validating...\n");

	/* Validation */
	errors = validate_buf(&mem[out_offset], gold);
	if (errors)
	    printf("  ... FAIL\n");
	else
	    printf("  ... PASS\n");

    aligned_free(ptable);
    aligned_free(mem);
    aligned_free(gold);

    return 0;
}
