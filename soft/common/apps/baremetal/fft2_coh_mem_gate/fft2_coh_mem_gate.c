/* Copyright (c) 2011-2019 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>
#include "utils/fft2_utils.h"
#include "fft2_coh_mem_gate.h"

typedef int token_t;
typedef float native_t;
#define fx2float fixed32_to_float
#define float2fx float_to_fixed32
#define FX_IL 14

const float ERR_TH = 0.05;

static unsigned DMA_WORD_PER_BEAT(unsigned _st)
{
        return (sizeof(void *) / _st);
}


#define SLD_FFT2 0x057
#define DEV_NAME "sld,fft2_stratus"

/* <<--params-->> */
const int32_t logn_samples = 3; // change to 10 for a longer accelerator execution
const int32_t num_samples = (1 << logn_samples);
const int32_t num_ffts = 1;
const int32_t do_inverse = 0;
const int32_t do_shift = 0;
const int32_t scale_factor = 1;
int32_t len;

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
#define FFT2_LOGN_SAMPLES_REG 0x40
#define FFT2_NUM_FFTS_REG 0x44
#define FFT2_DO_INVERSE_REG 0x48
#define FFT2_DO_SHIFT_REG 0x4c
#define FFT2_SCALE_FACTOR_REG 0x50


static int validate_buf(token_t *out, token_t *gold)
{
	int j;
	unsigned errors = 0;

	for (j = 0; j < 2 * len; j++) {
	    //printf("gold[%d] = 0x%x\n", j, out[j]);
        if (out[j] != gold[j]){
		    errors++;
            printf("j: %d, exp: %x, got: %x\n", j, gold[j], out[j]);
        }
	}

	// printf("  %u errors\n", errors);

	return errors;
}


static void init_buf(token_t *in, token_t *gold)
{

// Decomment the header files corresponding to the value of logn_samples (3 or 10)
#include "input_logn_3.h"
#include "gold_logn_3.h"
//#include "input_logn_7.h"
//#include "gold_logn_7.h"
}

#define N_MEM_TILES 1
int coh_modes[2] = {ACC_COH_RECALL, ACC_COH_NONE};

int main(int argc, char * argv[])
{
    int i;
    int n;
    struct esp_device dev;
    unsigned done;
    unsigned **ptable = NULL;
    token_t *mem;
    token_t *gold;
    unsigned errors = 0;
    unsigned coherence;

    len = num_ffts * (1 << logn_samples);
    in_words_adj = round_up(2 * len, DMA_WORD_PER_BEAT(sizeof(token_t)));
    out_words_adj = round_up(2 * len, DMA_WORD_PER_BEAT(sizeof(token_t)));

    in_len = in_words_adj;
    out_len = out_words_adj;
    in_size = in_len * sizeof(token_t);
    out_size = out_len * sizeof(token_t);
    out_offset  = 0;
    mem_size = (out_offset * sizeof(token_t)) + out_size;

    dev.addr = ACC_ADDR;
    // Allocate memory

    for (int m = 0; m < N_MEM_TILES; m++) {

        gold = aligned_malloc(out_len * sizeof(float));
        mem = aligned_malloc(mem_size);
        // printf("  memory buffer base-address = %p\n", mem);

        // Allocate and populate page table
        ptable = aligned_malloc(NCHUNK(mem_size) * sizeof(unsigned *));
        for (i = 0; i < NCHUNK(mem_size); i++)
            ptable[i] = (unsigned *) &mem[i * (CHUNK_SIZE / sizeof(token_t))];
        // printf("  ptable = %p\n", ptable);
        // printf("  nchunk = %lu\n", NCHUNK(mem_size));

        // Set coherence mode
        for (int i = 0; i < 2; i++) {
            coherence = coh_modes[i];
            printf("test %d of 2, coh = %d\n", i, coherence);

            // Initialize input
            // printf("  Generate input...\n");
            init_buf(mem, gold);

            // Pass common configuration parameters
            iowrite32(&dev, SELECT_REG, ioread32(&dev, DEVID_REG));
            iowrite32(&dev, COHERENCE_REG, coherence);

            iowrite32(&dev, PT_ADDRESS_REG, (unsigned long long) ptable);
            iowrite32(&dev, PT_NCHUNK_REG, NCHUNK(mem_size));
            iowrite32(&dev, PT_SHIFT_REG, CHUNK_SHIFT);

            // Use the following if input and output data are not allocated at the default offsets
            // iowrite32(&dev, SRC_OFFSET_REG, 0x0);
            // iowrite32(&dev, DST_OFFSET_REG, 0x0);

            // Pass accelerator-specific configuration parameters
            /* <<--regs-config-->> */
            iowrite32(&dev, FFT2_LOGN_SAMPLES_REG, logn_samples);
            iowrite32(&dev, FFT2_NUM_FFTS_REG, num_ffts);
            iowrite32(&dev, FFT2_SCALE_FACTOR_REG, scale_factor);
            iowrite32(&dev, FFT2_DO_SHIFT_REG, do_shift);
            iowrite32(&dev, FFT2_DO_INVERSE_REG, do_inverse);

            // Flush (customize coherence model here)
            if (coherence != ACC_COH_RECALL)
                esp_flush(coherence, 4);

            // Start accelerators
            // printf("  Start...\n");
            iowrite32(&dev, CMD_REG, CMD_MASK_START);

            // Wait for completion
            done = 0;
            while (!done) {
            done = ioread32(&dev, STATUS_REG);
            done &= STATUS_MASK_DONE;
            }
            iowrite32(&dev, CMD_REG, 0x0);
            // printf("  Done\n");

            // Validation
            // printf("  validating...\n");
            errors = validate_buf(&mem[out_offset], gold);
            if (errors)
            printf("  ... FAIL : %u errors out of %u\n", errors, 2*len);
            else
            printf("  ... PASS\n");
        }
        aligned_free(ptable);
        aligned_free(mem);
        aligned_free(gold);
    }

    return 0;
}
