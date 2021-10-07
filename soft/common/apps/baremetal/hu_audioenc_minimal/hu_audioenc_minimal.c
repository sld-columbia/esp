/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>
#include <fixed_point.h>
#include "hu_audioenc_minimal.h"

typedef int32_t token_t;

static unsigned DMA_WORD_PER_BEAT(unsigned _st)
{
    return (sizeof(void *) / _st);
}

#define SLD_HU_AUDIOENC 0x088
#define DEV_NAME "sld,hu_audioenc_rtl"

/* <<--params-->> */
const int32_t conf_0  =  0;   // 0: dummy
const int32_t conf_1  = 16;   // 16 source audios
const int32_t conf_2  =  8;   // audio block dize
// FIXME need to set dma_read_index and dma_write_index properly
const int32_t conf_3  =  0;   // dma_read_index  
const int32_t conf_4  =  32;  // dma_write_index 128*16b/64b = 32 
const int32_t conf_5  =  0;   // 5-15: dummy
const int32_t conf_6  =  0;
const int32_t conf_7  =  0;
const int32_t conf_8  =  0;
const int32_t conf_9  =  0;
const int32_t conf_10 =  0;
const int32_t conf_11 =  0;
const int32_t conf_12 =  0;
const int32_t conf_13 =  0;
const int32_t conf_14 =  0;
const int32_t conf_15 =  0;
// 16:31 cfg_src_coeff[16], bitcast fxp<32,16> to int32
const int32_t conf_16 = 38915; 
const int32_t conf_17 = 71047; 
const int32_t conf_18 = 50547;
const int32_t conf_19 = 59133;
const int32_t conf_20 = 87923;
const int32_t conf_21 = 84679;
const int32_t conf_22 = 45665;
const int32_t conf_23 = 97897;
const int32_t conf_24 = 80530;
const int32_t conf_25 = 63615;
const int32_t conf_26 = 78066;
const int32_t conf_27 = 48883;
const int32_t conf_28 = 60044;
const int32_t conf_29 = 90026;
const int32_t conf_30 = 45442;
const int32_t conf_31 = 50646; 
// 32:47 cfg_chan_coeff[16], bitcast fxp<32,16> to int32
const int32_t conf_32 = 88657;
const int32_t conf_33 = 66800;
const int32_t conf_34 = 73013;
const int32_t conf_35 = 36542;
const int32_t conf_36 = 42277;
const int32_t conf_37 = 38620;
const int32_t conf_38 = 82234;
const int32_t conf_39 = 68884;
const int32_t conf_40 = 69933;
const int32_t conf_41 = 55620;
const int32_t conf_42 = 45396;
const int32_t conf_43 = 89620;
const int32_t conf_44 = 65149;
const int32_t conf_45 = 47625;
const int32_t conf_46 = 44190;
const int32_t conf_47 = 95558;

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

    for (i = 0; i < 128; i++)
	if (gold[i] != out[i])
	    errors++;

    return errors;
}

static void init_buf (token_t* in, token_t* gold)
{
    int i;
    int j;
  
    // union object for bit packing
    union {
	int16_t val16[2];
	int32_t val32;
    } val;

    // audio_in[16][8] 16 sources and block size of 8
    int16_t audio_in[128] = {
	-10817, 10966, -12084, 10039, 30813, -12348, 17160, 28411, 
	10253, -29296, 25301, -16789, -14230, -17301, 8348, 4588, 
	-19607, -18308, -10021, 7911, 14061, -13249, 3225, 5457, 
	22372, 788, -25635, 19719, 13067, -17834, 8915, 14659, 
	-11418, -29502, 30548, -21548,20813, -3633, 3030, -25891, 	
	4086, 24359, -31592, 9563, -30547, -26922, 8009, 10527, 
	222, -8808, 9993, -2524, -14468, -23731, 12290, 11932, 
	-20823, 22710, -928, 8258, -27837, -24694, 6957, 12366, 
	-18070, 11538, -5927, -8955, 15913, -12060, 30240, -5238, 
	16046, 18944, 14095, -13160, -28020, 11720, 31077, -31400, 
	-2936, -6344, 24909, 2056, -31262, -18056, 21943, 23241, 
	31292, -20097, 360, 19472, 32588, 5054, 3723, 28830, 
	-24151, -212, 21569, 1601, -13833, -15816, -11993, 6928, 
	24695, -27484, 9148, 29961, -11617, 14476, 23838, 20758, 
	-5418, 21841, -24430, 3994, -7159, -29303, 26628, -304, 
	-940, 19304, 13329, -2049, -1949, -3207, -2445, -9499
    };

    // audio_out[8][16] block size of 8, and 16 channels 
    // reference output
    int32_t audio_out[128] = {
	-28975, -21831, -23863, -11947, -13822, -12626, -26875, -22516, 
	-22856, -18183, -14840, -29290, -21294, -15570, -14447, -31228, 
	-45580, -34346, -37538, -18792, -21738, -19860, -42279, -35416, 
	-35955, -28600, -23343, -46075, -33496, -24491, -22723, -49125, 
	154648, 116520, 127358, 63737, 73743, 67364, 143443, 120155, 
	121985, 97016, 79184, 156327, 113640, 83072, 77078, 166688, 
	115478, 87006, 95101, 47591, 55062, 50298, 107113, 89721, 
	91088, 72443, 59127, 116731, 84856, 62028, 57554, 124468, 
	-252669, -190379, -208086, -104149, -120492, -110071, -234364, -196317, 
	-199309, -158517, -129380, -255411, -185674, -135734, -125943, -272336, 
	-498011, -375240, -410139, -205273, -237487, -216945, -461933, -386943, 
	-392837, -312437, -255006, -503423, -365963, -267526, -248231, -536776, 
	534921, 403045, 440531, 220476, 255080, 233014, 496169, 415617, 
	421947, 335585, 273898, 540731, 393082, 287349, 266621, 576559, 
	228660, 172283, 188311, 94242, 109034, 99604, 212092, 177658, 
	180366, 143449, 117079, 231146, 168028, 122827, 113969, 246458
    };

    // pack int16_t into int32_t data, little endian
    for (i = 0; i < 64; i++) {
	val.val16[0] = audio_in[i*2];
	val.val16[1] = audio_in[i*2+1];
	in[i] = val.val32;
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

    in_len = 128 >> 1; // 128*16b => 64*32b
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
	iowrite32(&dev, 0xFC, conf_0 );
	iowrite32(&dev, 0xF8, conf_1 );
	iowrite32(&dev, 0xF4, conf_2 );
	iowrite32(&dev, 0xF0, conf_3 );

	iowrite32(&dev, 0xEC, conf_4 );
	iowrite32(&dev, 0xE8, conf_5 );
	iowrite32(&dev, 0xE4, conf_6 );
	iowrite32(&dev, 0xE0, conf_7 );

	iowrite32(&dev, 0xDC, conf_8 );
	iowrite32(&dev, 0xD8, conf_9 );
	iowrite32(&dev, 0xD4, conf_10);
	iowrite32(&dev, 0xD0, conf_11);

	iowrite32(&dev, 0xCC, conf_12);
	iowrite32(&dev, 0xC8, conf_13);
	iowrite32(&dev, 0xC4, conf_14);
	iowrite32(&dev, 0xC0, conf_15);

	iowrite32(&dev, 0xBC, conf_16);
	iowrite32(&dev, 0xB8, conf_17);
	iowrite32(&dev, 0xB4, conf_18);
	iowrite32(&dev, 0xB0, conf_19);

	iowrite32(&dev, 0xAC, conf_20);
	iowrite32(&dev, 0xA8, conf_21);
	iowrite32(&dev, 0xA4, conf_22);
	iowrite32(&dev, 0xA0, conf_23);

	iowrite32(&dev, 0x9C, conf_24);
	iowrite32(&dev, 0x98, conf_25);
	iowrite32(&dev, 0x94, conf_26);
	iowrite32(&dev, 0x90, conf_27);

	iowrite32(&dev, 0x8C, conf_28);
	iowrite32(&dev, 0x88, conf_29);
	iowrite32(&dev, 0x84, conf_30);
	iowrite32(&dev, 0x80, conf_31);

	iowrite32(&dev, 0x7C, conf_32);
	iowrite32(&dev, 0x78, conf_33);
	iowrite32(&dev, 0x74, conf_34);
	iowrite32(&dev, 0x70, conf_35);

	iowrite32(&dev, 0x6C, conf_36);
	iowrite32(&dev, 0x68, conf_37);
	iowrite32(&dev, 0x64, conf_38);
	iowrite32(&dev, 0x60, conf_39);

	iowrite32(&dev, 0x5C, conf_40);
	iowrite32(&dev, 0x58, conf_41);
	iowrite32(&dev, 0x54, conf_42);
	iowrite32(&dev, 0x50, conf_43);

	iowrite32(&dev, 0x4C, conf_44);
	iowrite32(&dev, 0x48, conf_45);
	iowrite32(&dev, 0x44, conf_46);
	iowrite32(&dev, 0x40, conf_47);

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
