/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>
#include "edgebert_minimal.h"

typedef char token_t;
typedef char native_t;

static unsigned DMA_WORD_PER_BEAT(unsigned _st)
{
    return (sizeof(void *) / _st);
}

#define MAX_PRINTED_ERRORS 10

#define HU_EDGEBERT  0x104
#define DEV_NAME "hu,hu_edgebert"

static unsigned in_len1;
static unsigned in_len2;
static unsigned in_len3;
static unsigned in_offset1;
static unsigned in_offset2;
static unsigned in_offset3;
static unsigned in_size1;
static unsigned in_size2;
static unsigned in_size3;
static unsigned out_len1;
static unsigned out_len2;
static unsigned out_size1;
static unsigned out_size2;
static unsigned out_offset1;
static unsigned out_offset2;

static unsigned mem_size;

const static int N = 16;
const static int M = N;

const static unsigned is_relu = 0;
const static unsigned is_bias = 1;
const static int   weight_bias = -8;
const static int   adf_accum_bias = 2;
const static int   accum_right_shift = 2;

const static int base_output = 1024;
const static int base_input0 = 0;
const static int base_input1 = 0;

// Matrix configurations
const static unsigned N0 = 16;
const static unsigned N1 = 16;
const static unsigned M_mat = 16;

static void iointerrupt()
{
    int i;
    for (i = 0; i < 2; i++)
	printf("wait...\n");
}

// output validation
static int validate_buf(token_t *out, native_t *gold, int out_len)
{
    int j;
    native_t val;
    unsigned errors = 0;

    printf("val\n");
    
    for (j = 0; j < out_len; j++) {
	val = out[j];
	if (gold[j] != val) {
	    errors++;
	    if (errors <= MAX_PRINTED_ERRORS) {
		printf("%d : %d : %d\n", j, (int) val, (int) gold[j]);
	    }
	}
    }

    return errors;
}

// input and expected output initialization
static void init_buf(token_t *Mask_mat, token_t *D_mat, token_t *Aux_mat, native_t *O_mat)
{
#include "Aux_mat.h"
#include "D_mat.h"
#include "Mask_mat.h"
#include "O_mat.h"
}

int main(int argc, char * argv[])
{
    int i;
    int n;
    int ndev;
    struct esp_device dev, coh_dev;
    unsigned done;
    token_t *mem;
    native_t *gold;
    unsigned errors1 = 0;
    unsigned errors2 = 0;
    unsigned coherence;
    unsigned data = 0, data_read = 0;
    // base address
    unsigned mask_rd_base;
    unsigned input_rd_base;
    unsigned aux_rd_base;
    unsigned mask_wr_base;
    unsigned input_wr_base;
    
    int num_interrupts = 0;

    // offsets in data buffer
    in_len1 = 256;  // mask read, Mask_mat.h
    in_len2 = 256;  // input (D) read, D_mat.h      
    in_len3 = 256;  // aux read, Aux_mat.h
    out_len1 = 256; // mask data output, compared with Mask_mat.h
    out_len2 = 256; // computation data output, compared with O_mat.h
	
    in_offset1 = 0;
    in_offset2 = in_offset1 + in_len1;
    in_offset3 = in_offset2 + in_len2;
    out_offset1 = in_offset3 + in_len3;
    out_offset2 = out_offset1 + out_len1;

    in_size1 = (in_len1) * sizeof(token_t); 
    in_size2 = (in_len2) * sizeof(token_t);
    in_size3 = (in_len3) * sizeof(token_t);
    out_size1 = out_len1 * sizeof(token_t);
    out_size2 = out_len2 * sizeof(token_t);

    mem_size = (out_offset2 * sizeof(token_t)) + out_size2;

    dev.addr = ACC_ADDR;
    
    // TO MODIFY: Allocate memory
    // Allocation of the accelerator data array (mem) and of the expected output array (gold)
    mem = aligned_malloc(mem_size);
    gold = aligned_malloc(out_size2);

    mask_rd_base = ((unsigned) mem);
    input_rd_base = ((unsigned) mem) + in_size1;
    aux_rd_base = ((unsigned) mem) + in_size1 + in_size2;
    mask_wr_base = ((unsigned) mem) + in_size1 + in_size2 + in_size3;
    input_wr_base = ((unsigned) mem) + in_size1 + in_size2 + in_size3 + out_size1;
	    
    printf("  Generate input...\n");

    init_buf(&mem[in_offset1], &mem[in_offset2], &mem[in_offset3], gold);

    // Flush (customize coherence model here)
    coherence = ACC_COH_RECALL;
    coh_dev.addr = CSR_TILE_ADDR;
    iowrite32(&coh_dev, CSR_REG_OFFSET*4, coherence);
    if (coherence != ACC_COH_RECALL)
	esp_flush(coherence);

    // Start base_output 0x48 and use_gb 0x50 and reset_mode 0x58 and use_lowprec_mac 0x60
    data = 0;
    data += base_output;
    iowrite32(&dev, 0x48, data);

    data = 0;
    iowrite32(&dev, 0x50, data);

    data = 0x81;
    iowrite32(&dev,  0x58, data);


    data = 0;
    iowrite32(&dev, 0x60, data);

    // Start AccelConfig 0x0c
    data = 0;
    data += is_relu;
    data += is_bias << 4;
    data += weight_bias << 8;
    data += adf_accum_bias << 16;
    data += accum_right_shift << 20;
    iowrite32(&dev, 0x0C, data);

    //Start InputBufferConfig 0x14 and BufferOffsetConfig 0x18
    data = 0;
    data += base_input0;
    data += base_input1 << 16;
    iowrite32(&dev, 0x14, data);
    iowrite32(&dev, 0x18, data);

    //Start num_words M_1 for Input/Mask AXI 0x40
    data = 0;
    data += (M-1);
    iowrite32(&dev, 0x40, data);
    
    //Start mask_read_base (0x28) and input_read_base (0x30)
    data = mask_rd_base;
    iowrite32(&dev, 0x28, data);
    
    data = mask_wr_base;
    iowrite32(&dev, 0x2C, data);
	    
    data = input_rd_base;
    iowrite32(&dev, 0x30, data);
    
    data = input_wr_base;
    iowrite32(&dev, 0x34, data);
    
    //Start InputMem0/1 Master Read 0x04-data=3
    data = 0x0;
    iowrite32(&dev, 0x4C, data);
    iowrite32(&dev, 0x08, data);

    data = 0x03;
    iowrite32(&dev, 0x04, data);

    // 1st interrupt
    iointerrupt();
    num_interrupts++;

    data = 0x1;
    iowrite32(&dev, 0x08, data); //flip_mem = 1;

    data = 0x03;
    iowrite32(&dev, 0x04, data);

    // 2nd interrupt
    iointerrupt();
    num_interrupts++;

    //Start MaskMem0/1 Master Read 0x04-data=1
    data = 0x0;
    iowrite32(&dev, 0x08, data); //flip_mem = 0;
    
    data = 0x01;
    iowrite32(&dev, 0x04, data);
    
    // 3nd interrupt
    iointerrupt();
    num_interrupts++;

    data = 0x1;
    iowrite32(&dev, 0x08, data); //flip_mem = 1;

    data = 0x01;
    iowrite32(&dev,0x04, data);
    
    // 4th interrupt
    iointerrupt();
    num_interrupts++;

    //Start num_words M_1 for Aux AXI 0x44
    data = 0;
    data += (M-1);
    iowrite32(&dev, 0x44, data);

    //Start aux_read_base (0x38)" 
    data = aux_rd_base;
    iowrite32(&dev, 0x38, data);

    // " Start Aux Master Read 0x04-data=5 " 
    data = 0x05;
    iowrite32(&dev, 0x04, data);
    
    // 5th interrupt
    iointerrupt();
    num_interrupts++;

    // Start MatrixConfig 0x10" 
    data = 0x0;
    data += N0;
    data += N1 << 10;
    data += M_mat << 20;
    iowrite32(&dev, 0x10, data);
    
    // Start PUModule Computation with use_lowprec_mac=0" 
    data = 0x07;
    iowrite32(&dev, 0x04, data);
    
    // 6th interrupt
    iointerrupt();
    num_interrupts++;

    // Start use_axi (0x4C) to 1" << endl;
    data = 0x1;
    iowrite32(&dev,  0x4C, data); 

    // Start Input Master Write" << endl;
    data = 0x04;
    iowrite32(&dev,  0x04, data);
    
    // 7th interrupt
    iointerrupt();
    num_interrupts++;

    // // Start Mask Master Write" << endl;
    // data = 0x02;
    // iowrite32(&dev,  0x04, data);
   
    // // 8th interrupt
    // iointerrupt();
    // num_interrupts++;

    /* Validation */
    // errors1 = validate_buf(&mem[out_offset1], &mem[in_offset1], out_len1); //mask data output, compared with Mask_mat.h
    errors2 = validate_buf(&mem[out_offset2], gold, out_len2);  //computation data output, compared with O_mat.h

    if ((num_interrupts == 7) && (errors1 + errors2 == 0))
	printf("PASS\n");
    else
	printf("FAIL\n");

    aligned_free(mem);
    aligned_free(gold);

    return 0;
}
