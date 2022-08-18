/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>
#include "edgebert_demo.h"


#include <stdlib.h>
#include <string.h>
#include <math.h>

#define __STDC_FORMAT_MACROS
#include <inttypes.h>

#define PLIC_ADDR 0x6c000000
#define PLIC_IP_OFFSET 0x1000
#define PLIC_INTACK_OFFSET 0x200004
#define EDGEBERT_IRQ 5



typedef char token_t;
typedef char native_t;

static unsigned DMA_WORD_PER_BEAT(unsigned _st)
{
    return (sizeof(void *) / _st);
}

#define MAX_PRINTED_ERRORS 10

#define HU_EDGEBERT  0x104
#define DEV_NAME "hu,hu_edgebert"


static unsigned mem_size;

const static int N = 16;
const static int M = N;

static unsigned is_relu;
const static unsigned is_bias = 1;
const static int   weight_bias = -8;
const static int   adf_accum_bias = 2;
const static int   accum_right_shift = 2;

const static int base_attn_span = 0;
const static int base_gamma = 8;
const static int base_beta = 56;
const static int adpbias_attn_span = 2;
const static int adpbias_gamma = 2;
const static int adpbias_beta = 2;

const static int num_vector = 8;
const static int num_timestep = 128;

const static int adpbias_act1 = 2;
const static int adpbias_act2 = 2;
const static int adpbias_act3 = 2;


const static int base_output = 1024;
const static int base_input0 = 0;
const static int base_input1 = 0;

// Matrix configurations
//const static unsigned N0 = 16;
//const static unsigned N1 = 16;
//const static unsigned M_mat = 16;

const static unsigned Mask_buffer_size = 8192; // in 'bytes'
const static unsigned input_buffer_size = 65536;
const static unsigned aux_buffer_size = 4096; // 128X128 ??


static inline uint64_t get_counter()
{
    uint64_t counter;
    asm volatile (
    "li t0, 0;"
    "csrr t0, mcycle;"
    "mv %0, t0"
    : "=r" ( counter )
    :
    : "t0"
        );
    return counter;
} 

void CPU_transpose(token_t *array, int m, int n){

    token_t new_array[m*n];
    for (int i = 0; i < m; ++i )
    {
       for (int j = 0; j < n; ++j )
       {
          // Index in the original matrix.
          int index1 = i*n+j;

          // Index in the transpose matrix.
          int index2 = j*m+i;

          new_array[index2] = array[index1];
       }
    }

    for (int i=0; i<m*n; i++) {
        array[i] = new_array[i];
    }
}

/*
void CPU_softmax(float* input, size_t size) {

  int i;
  float m, sum, constant;

  m = -INFINITY;
  for (i = 0; i < size; ++i) {
    if (m < input[i]) {
      m = input[i];
    }
  }

  sum = 0.0;
  for (i = 0; i < size; ++i) {
    sum += exp(input[i] - m);
  }

  constant = m + log(sum);
  for (i = 0; i < size; ++i) {
    input[i] = exp(input[i] - constant);
  }

}
*/



static int EdgeBert_Init 
(struct esp_device *dev, struct esp_device *plic_dev, token_t *mem)
{
    //our reset hack
    iowrite32(dev, 0x00, 1);

    unsigned data = 0, data_read = 0;
    int num_interrupts = 0;
    
    //printf("...SETTing up base addr for EdgeBert...\n");

    // base address
    unsigned mask_rd_base;
    unsigned input_rd1_base;
    unsigned input_rd2_base;
    unsigned aux_rd_base;
    unsigned input_wr_base;
    unsigned mask_wr_base;

    mask_rd_base = ((unsigned) mem);
    input_rd1_base = ((unsigned) mem) + Mask_buffer_size;
    input_rd2_base = ((unsigned) mem) + Mask_buffer_size+input_buffer_size;
    aux_rd_base = ((unsigned) mem) + Mask_buffer_size+2*input_buffer_size;
    input_wr_base = ((unsigned) mem) + Mask_buffer_size+2*input_buffer_size+aux_buffer_size;
    mask_wr_base  = ((unsigned) mem) + Mask_buffer_size+3*input_buffer_size+aux_buffer_size;  

    // Start base_output 0x48 and use_gb 0x50 and reset_mode 0x58 and use_lowprec_mac 0x60
    //printf("\n start base_output...");
    data = 0;
    data += base_output; 
    iowrite32(dev, 0x48, data);
    data = 0;
    iowrite32(dev, 0x50, data);
    data = 0x81;
    iowrite32(dev,  0x58, data);
    data = 0;
    iowrite32(dev, 0x60, data);


    //Start num_words M_1 for Input/Mask AXI 0x40
    data = 0;
    data += (M-1);
    iowrite32(dev, 0x40, data);
    
    //Start mask_read_base (0x28) and input_read_base (0x30)
    data = mask_rd_base;
    iowrite32(dev, 0x28, data);
    
    data = mask_wr_base;
    iowrite32(dev, 0x2C, data);
    data = input_wr_base;
    iowrite32(dev, 0x34, data);


    //Start MaskMem0/1 Master Read 0x04-data=1
    data = 0x0;
    iowrite32(dev, 0x08, data); //flip_mem = 0;
    
    data = 0x01;
    iowrite32(dev, 0x04, data); //master mask read
    
    // 3nd interrupt
    //printf("......waiting for 1st interrupt\n");
    //iointerrupt();
    while((ioread32(plic_dev, PLIC_IP_OFFSET) & 0x40) == 0);
    iowrite32(plic_dev, PLIC_INTACK_OFFSET, EDGEBERT_IRQ + 1);
    iowrite32(plic_dev, 0x2000, 0x40);
    iowrite32(plic_dev, 0x18, 0x2);
    ioread32(plic_dev, PLIC_INTACK_OFFSET);
    //printf("......receiving the 1st interrupt\n");
    num_interrupts++;


    data = 0x1;
    iowrite32(dev, 0x08, data); //flip_mem = 1;

    data = 0x01;
    iowrite32(dev,0x04, data); //master mask read
    
    // 4th interrupt
    //printf("......waiting for 2nd interrupt\n");
    //iointerrupt();
    while((ioread32(plic_dev, PLIC_IP_OFFSET) & 0x40) == 0);
    iowrite32(plic_dev, PLIC_INTACK_OFFSET, EDGEBERT_IRQ + 1);
    iowrite32(plic_dev, 0x2000, 0x40);
    iowrite32(plic_dev, 0x18, 0x2);
    ioread32(plic_dev, PLIC_INTACK_OFFSET);
    //printf("......receiving the 2nd interrupt\n");
    num_interrupts++;



   // Jeff added for Aux config and setting
    //Start num_words M_1 for Aux AXI 0x44
    data = 0;
    data += (M-1);
    iowrite32(dev, 0x44, data);

    //Start aux_read_base (0x38)" 
    data = aux_rd_base;
    iowrite32(dev, 0x38, data);

    // " Start Aux Master Read 0x04-data=5 " 
    data = 0x05;
    iowrite32(dev, 0x04, data);
    
    // 5th interrupt
    //printf("......waiting for the 3rd interrupt\n");
    //iointerrupt();
    while((ioread32(plic_dev, PLIC_IP_OFFSET) & 0x40) == 0);
    iowrite32(plic_dev, PLIC_INTACK_OFFSET, EDGEBERT_IRQ + 1);
    iowrite32(plic_dev, 0x2000, 0x40);
    iowrite32(plic_dev, 0x18, 0x2);
    ioread32(plic_dev, PLIC_INTACK_OFFSET);
    //printf("......receiving the 3rd interrupt\n");
    num_interrupts++;

    // Jeff added for Aux config and setting
    
    //printf("...FINISHing base addr setting for EdgeBert...\n");


}




static int EdgeBert_MatMul 
(struct esp_device *dev, struct esp_device *plic_dev, int N0, int N1, int M_mat, int is_relu, token_t *mem, token_t *Mask_mat, 
 token_t *D_mat1, token_t *D_mat2, int softmax)

{
	uint64_t count1;
    uint64_t count2;
    uint64_t exe_cycle;
    
    //printf("...STARTing Matmul in EdgeBert...\n");
    
    int num_interrupts = 0;

    unsigned data = 0, data_read = 0;
    unsigned input_rd1_base = ((unsigned) mem) + Mask_buffer_size;
    unsigned input_rd2_base = ((unsigned) mem) + Mask_buffer_size+input_buffer_size;
	

    memcpy(mem, Mask_mat, Mask_buffer_size*sizeof(token_t));
    memcpy(mem+Mask_buffer_size, D_mat1, N0*M_mat*sizeof(token_t));
    memcpy(mem+Mask_buffer_size+input_buffer_size, D_mat2, M_mat*N1*sizeof(token_t));
    //memcpy(mem+Mask_buffer_size+2*input_buffer_size, Aux_mat, aux_buffer_size* sizeof(token_t));


    //printf("\n start accelconfig ...");
    
    // Start AccelConfig 0x0c
    data = 0;
    data += is_relu;
    data += is_bias << 4;
    data += weight_bias << 8;
    data += adf_accum_bias << 16;
    data += accum_right_shift << 20;
    iowrite32(dev, 0x0C, data);
    
    

    //Start InputMem0/1 Master Read 0x04-data=3
    data = 0x0;
    iowrite32(dev, 0x4C, data);
    iowrite32(dev, 0x08, data); //flip_mem = 0;

    data = input_rd1_base;
    iowrite32(dev, 0x30, data);

    data = 0x03;
    iowrite32(dev, 0x04, data); //master input read

    // 1st interrupt
    //printf("......waiting for 1st interrupt\n");
    //iointerrupt();
    while((ioread32(plic_dev, PLIC_IP_OFFSET) & 0x40) == 0);
    iowrite32(plic_dev, PLIC_INTACK_OFFSET, EDGEBERT_IRQ + 1);
    iowrite32(plic_dev, 0x2000, 0x40);
    iowrite32(plic_dev, 0x18, 0x2);
    ioread32(plic_dev, PLIC_INTACK_OFFSET);
    //printf("......receiving the 1st interrupt\n");
    num_interrupts++;

    
    data = 0x1;
    iowrite32(dev, 0x08, data); //flip_mem = 1;

    data = input_rd2_base;
    iowrite32(dev, 0x30, data);

    data = 0x03;
    iowrite32(dev, 0x04, data); //master input read

    // 2nd interrupt
    //printf("......waiting for 2nd interrupt\n");
    //iointerrupt();
    while((ioread32(plic_dev, PLIC_IP_OFFSET) & 0x40) == 0);
    iowrite32(plic_dev, PLIC_INTACK_OFFSET, EDGEBERT_IRQ + 1);
    iowrite32(plic_dev, 0x2000, 0x40);
    iowrite32(plic_dev, 0x18, 0x2);
    ioread32(plic_dev, PLIC_INTACK_OFFSET);
    //printf("......receiving the 2nd interrupt\n");
    num_interrupts++;

   

    // Start MatrixConfig 0x10" 
    data = 0x0;
    data += N0;
    data += N1 << 10;
    data += M_mat << 20;
    iowrite32(dev, 0x10, data);

    
    //printf("\n start inputbufferconfig");
    //Start InputBufferConfig 0x14 and BufferOffsetConfig 0x18
    data = 0;
    data += base_input0;
    data += base_input1 << 16;
    iowrite32(dev, 0x14, data);
    iowrite32(dev, 0x18, data);
    
    count1 = get_counter();
    // Start PUModule Computation with use_lowprec_mac=0" 
    data = 0x07;
    iowrite32(dev, 0x04, data);
    // 6th interrupt
    //printf("......waiting for 3rd interrupt\n");
    //iointerrupt();
    while((ioread32(plic_dev, PLIC_IP_OFFSET) & 0x40) == 0);
    count2 = get_counter();
    iowrite32(plic_dev, PLIC_INTACK_OFFSET, EDGEBERT_IRQ + 1);
    iowrite32(plic_dev, 0x2000, 0x40);
    iowrite32(plic_dev, 0x18, 0x2);
    ioread32(plic_dev, PLIC_INTACK_OFFSET);
    //printf("......receiving the 3rd interrupt\n");
    num_interrupts++;

    
            
    exe_cycle = (count2-count1);
            //printf("...Attention Head %d takes %u ns seconds...\n", i, exe_time);
    printf("...This MatMul takes %"PRIu64" clock cycles...\n", exe_cycle);


    if (softmax==0)
    {
        // Start use_axi (0x4C) to 1" << endl;
    data = 0x1;
    iowrite32(dev,  0x4C, data); 

    // Start Input Master Write" << endl;
    data = 0x04;
    iowrite32(dev,  0x04, data);
    
    // 7th interrupt
    //printf("......waiting for 4th interrupt\n");
    //iointerrupt();
    while((ioread32(plic_dev, PLIC_IP_OFFSET) & 0x40) == 0);
    iowrite32(plic_dev, PLIC_INTACK_OFFSET, EDGEBERT_IRQ + 1);
    iowrite32(plic_dev, 0x2000, 0x40);
    iowrite32(plic_dev, 0x18, 0x2);
    ioread32(plic_dev, PLIC_INTACK_OFFSET);
    //printf("......receiving the 4th interrupt\n");
    num_interrupts++;

    }

    
    //printf("...FINISHing Matmul in EdgeBert...\n");
    
    
    return num_interrupts;
}


static int EdgeBert_SoftAttenM 
(struct esp_device *dev, struct esp_device *plic_dev, int N0, int N1, int M_mat)

{
    //printf("STARTing SoftAttenM in EdgeBert...\n");
    unsigned data = 0, data_read = 0;
    int num_interrupts;
    
    //" Start use_gb 0x50 and reset_mode 0x58"
    data = 0x0;
    iowrite32(dev,  0x08, data); //flip_mem = 0;
    data = 0x1;
    iowrite32(dev, 0x50, data); //use_gb = 1
    data = 0x08;
    iowrite32(dev, 0x58, data); //reset_mode = 0x02 layernorm pu mode
    data = 0x02;
    iowrite32(dev, 0x54, data); //gb_mode_config = 2 // SMax gb mode


    data = 0;
    data += base_attn_span;
    data += base_gamma << 7;
    data += base_beta << 15;
    data += adpbias_attn_span << 23;
    data += adpbias_gamma << 26;
    data += adpbias_beta << 29;
    iowrite32(dev, 0x1C, data);
    
    data = 0;
    data += num_vector;
    data += num_timestep << 8;
    data += adpbias_act1 << 16;
    data += adpbias_act2 << 20;
    data += adpbias_act3 << 24;
    iowrite32(dev, 0x20, data);


    // Start MatrixConfig 0x10" 

    data = 0x0;
    data += N0;
    data += N1 << 10;
    data += M_mat << 20;
    iowrite32(dev, 0x10, data);


    data = 0;
    data += base_input0;
    data += base_input1 << 16;
    iowrite32(dev, 0x14, data);
    iowrite32(dev, 0x18, data);


    //Finish config for SMax

    //Start SMax Computation
    data = 0x0;
    iowrite32(dev,  0x08, data); //flip_mem = 0;

    data = 0x9;
    iowrite32(dev, 0x04, data);

    //End SMax Computation"


    // 1st interrupt
    //printf("...waiting for interrupt\n");
    //iointerrupt();
    while((ioread32(plic_dev, PLIC_IP_OFFSET) & 0x40) == 0);
    iowrite32(plic_dev, PLIC_INTACK_OFFSET, EDGEBERT_IRQ + 1);
    iowrite32(plic_dev, 0x2000, 0x40);
    iowrite32(plic_dev, 0x18, 0x2);
    ioread32(plic_dev, PLIC_INTACK_OFFSET);
    //printf("...receiving the interrupt\n");
    num_interrupts++;

    
    //read masterinput out
    data = 0x1;
    iowrite32(dev,  0x4C, data); 

    // Start Input Master Write" << endl;
    data = 0x04;
    iowrite32(dev,  0x04, data);
    
    // 7th interrupt
    //printf("......waiting for 4th interrupt\n");
    //iointerrupt();
    while((ioread32(plic_dev, PLIC_IP_OFFSET) & 0x40) == 0);
    iowrite32(plic_dev, PLIC_INTACK_OFFSET, EDGEBERT_IRQ + 1);
    iowrite32(plic_dev, 0x2000, 0x40);
    iowrite32(plic_dev, 0x18, 0x2);
    ioread32(plic_dev, PLIC_INTACK_OFFSET);
    //printf("......receiving the 4th interrupt\n");
    num_interrupts++;

    
    //printf("FINISHing SoftAttenM in EdgeBert...\n");
    return num_interrupts;

}


static void EdgeBert_Attension (struct esp_device *dev, struct esp_device *plic_dev, token_t *mem)

{

    //printf("STARTing Attention Head in EdgeBert...\n");
    int num_interrupts;
    int softmax = 0;

    token_t *input_ids1st;
    token_t *input_ids2nd;
    token_t *we_mat1;
    token_t *we_mat2; 
    token_t *we_mat3; 
    token_t *Mask_mat; 
    //token_t *Aux_mat;
    
    input_ids1st  = aligned_malloc(49152); //64*768
    input_ids2nd = aligned_malloc(49152);   
    we_mat1  = aligned_malloc(49152);   //768*64
    we_mat2  = aligned_malloc(49152);
    we_mat3  = aligned_malloc(49152);
    Mask_mat = aligned_malloc(8192);
    //Aux_mat = aligned_malloc(4096);

    //init_buf(input_ids1st, input_ids2nd, we_mat1, we_mat2, we_mat3, Mask_mat, Aux_mat);
    memset(input_ids1st, 11, 49152*sizeof(token_t));
    memset(input_ids2nd, 115, 49152*sizeof(token_t));
    memset(we_mat1, 35, 49152*sizeof(token_t));
    memset(we_mat2, -1, 49152*sizeof(token_t));
    memset(we_mat3, -12, 49152*sizeof(token_t));
    memset(Mask_mat, 255, 8192*sizeof(token_t));
    //memset(Aux_mat, 3, 4096*sizeof(token_t));

      
   EdgeBert_Init(dev, plic_dev, mem); 

    
   unsigned N0 ;
   unsigned N1 ;
   unsigned M_mat;
   unsigned is_relu;
   
   N0 = 64;
   M_mat = 768;
   N1 = 64;
   is_relu = 0;
   token_t *query_mat_1; // appending two 64*64 array to 128X64
   token_t *key_mat_1; // 128x64
   token_t *vaule_mat_1; // 128x64

   query_mat_1 = aligned_malloc(2*N0*N1);
   key_mat_1  = aligned_malloc(2*N0*N1);
   vaule_mat_1 = aligned_malloc(2*N0*N1);
   
   
   //printf("Attension 1 Matmul.\n");
   //Query matmul1 1st half -> 64*768 X 768*64 = 64*64
   EdgeBert_MatMul (dev, plic_dev, N0, N1, M_mat, is_relu, mem, Mask_mat, input_ids1st, we_mat1, softmax);
   memcpy(query_mat_1, mem+Mask_buffer_size+2*input_buffer_size+aux_buffer_size, N0*N1*sizeof(token_t));

   

   //printf("Attension 2 Matmul\n");
   //Query matmul1 2st half -> 64*768 X 768*64 = 64*64
   EdgeBert_MatMul (dev, plic_dev, N0, N1, M_mat, is_relu, mem, Mask_mat, input_ids2nd, we_mat1, softmax);
   //combining to 128X64
   memcpy(query_mat_1 + N0*N1, mem+Mask_buffer_size+2*input_buffer_size+aux_buffer_size, N0*N1*sizeof(token_t));
      
   
   
   EdgeBert_Init(dev, plic_dev, mem); 
   //printf("Attension 3 Matmul\n");
   //Key matmul1 1st half -> 64*768 X 768*64 = 64*64
   EdgeBert_MatMul (dev, plic_dev, N0, N1, M_mat, is_relu, mem, Mask_mat, input_ids1st, we_mat2, softmax);
   memcpy(key_mat_1, mem+Mask_buffer_size+2*input_buffer_size+aux_buffer_size, N0*N1*sizeof(token_t));

   

   
   //printf("Attension 4 Matmul\n");
   //Key matmul1 2st half -> 64*768 X 768*64 = 64*64
   EdgeBert_MatMul (dev, plic_dev, N0, N1, M_mat, is_relu, mem, Mask_mat, input_ids2nd, we_mat2, softmax);
   //combining to 128X64
   memcpy(key_mat_1 + N0*N1, mem+Mask_buffer_size+2*input_buffer_size+aux_buffer_size, N0*N1*sizeof(token_t));

   
   EdgeBert_Init(dev, plic_dev, mem); 
   //printf("Attension 5. Matmul\n");
   //Value matmul1 1st half -> 64*768 X 768*64 = 64*64
   EdgeBert_MatMul (dev, plic_dev, N0, N1, M_mat, is_relu, mem, Mask_mat, input_ids1st, we_mat3, softmax);
   memcpy(vaule_mat_1, mem+Mask_buffer_size+2*input_buffer_size+aux_buffer_size, N0*N1*sizeof(token_t));
   
   

   //printf("Attension  6. Matmul\n");
   //Value matmul1 2st half -> 64*768 X 768*64 = 64*64
   EdgeBert_MatMul (dev, plic_dev, N0, N1, M_mat, is_relu, mem, Mask_mat, input_ids2nd, we_mat3, softmax);
   //combining to 128X64
   memcpy(vaule_mat_1 + N0*N1, mem+Mask_buffer_size+2*input_buffer_size+aux_buffer_size, N0*N1*sizeof(token_t));
   
   //printf("Transpose on CPU\n");
   //transpose on the key_mat_1, now it has shape of 64x128
   CPU_transpose(key_mat_1, 2*N0, N1); 

   


   //query_mat_1 X key_mat_1
   N0 = 128;
   M_mat = 64;
   N1 = 128;
   token_t *query_mat_2; //the input for softmax: 128X128
   query_mat_2 = aligned_malloc(2*N0*N1);    

   
   EdgeBert_Init(dev, plic_dev, mem); 
   //printf("Attension  8. Matmul\n");
   softmax = 1;
   EdgeBert_MatMul (dev, plic_dev, N0, N1, M_mat, is_relu, mem, Mask_mat, query_mat_1, key_mat_1, softmax);
   //combining to 128X128
   //memcpy(query_mat_2, mem+Mask_buffer_size+2*input_buffer_size+aux_buffer_size, N0*N1*sizeof(token_t));
   
   aligned_free(query_mat_1);
   aligned_free(key_mat_1);

   //softmax and attention span
   N0 = 128;
   M_mat = 128;
   N1 = 128;
   //printf("8. SoftAttenM\n");
   EdgeBert_SoftAttenM (dev, plic_dev, N0, N1, M_mat);
   //after softmax and attention span
   memcpy(query_mat_2, mem+Mask_buffer_size+2*input_buffer_size+aux_buffer_size, N0*N1*sizeof(token_t));


   //query_mat_2 X vaule_mat_1: last Matmul in attension heads
   N0 = 128;
   M_mat = 128;
   N1 = 64;

   EdgeBert_Init(dev, plic_dev, mem); 
   //printf("9. Matmul\n");
   EdgeBert_MatMul (dev, plic_dev, N0, N1, M_mat, is_relu, mem, Mask_mat, query_mat_2, vaule_mat_1, softmax);
   memcpy(vaule_mat_1, mem+Mask_buffer_size+2*input_buffer_size+aux_buffer_size, N0*N1*sizeof(token_t));
   //Attension heads are store in vaule_mat_1
   

    aligned_free(input_ids1st);
    aligned_free(input_ids2nd);
    aligned_free(we_mat1);
    aligned_free(we_mat2);
    aligned_free(we_mat3);
    aligned_free(Mask_mat);
    //aligned_free(Aux_mat);

    //printf("FINISHing Attention Head in EdgeBert...\n");
    

}

static void EdgeBert_Attension_MM1 (struct esp_device *dev, struct esp_device *plic_dev, token_t *mem)

{

    //printf("STARTing Attention Head in EdgeBert...\n");
    int num_interrupts;
    int softmax = 0;

    token_t *input_ids1st;
    token_t *input_ids2nd;
    token_t *we_mat1;
    token_t *we_mat2; 
    token_t *we_mat3; 
    token_t *Mask_mat; 
    //token_t *Aux_mat;
    
    input_ids1st  = aligned_malloc(49152); //64*768
    input_ids2nd = aligned_malloc(49152);   
    we_mat1  = aligned_malloc(49152);   //768*64
    we_mat2  = aligned_malloc(49152);
    we_mat3  = aligned_malloc(49152);
    Mask_mat = aligned_malloc(8192);
    //Aux_mat = aligned_malloc(4096);

    //init_buf(input_ids1st, input_ids2nd, we_mat1, we_mat2, we_mat3, Mask_mat, Aux_mat);
    memset(input_ids1st, 11, 49152*sizeof(token_t));
    memset(input_ids2nd, 115, 49152*sizeof(token_t));
    memset(we_mat1, 35, 49152*sizeof(token_t));
    memset(we_mat2, -1, 49152*sizeof(token_t));
    memset(we_mat3, -12, 49152*sizeof(token_t));
    memset(Mask_mat, 255, 8192*sizeof(token_t));
    //memset(Aux_mat, 3, 4096*sizeof(token_t));

      
   EdgeBert_Init(dev, plic_dev, mem); 

    
   unsigned N0 ;
   unsigned N1 ;
   unsigned M_mat;
   unsigned is_relu;
   
   N0 = 64;
   M_mat = 768;
   N1 = 64;
   is_relu = 0;
   token_t *query_mat_1; // appending two 64*64 array to 128X64
   token_t *key_mat_1; // 128x64
   token_t *vaule_mat_1; // 128x64

   query_mat_1 = aligned_malloc(2*N0*N1);
   key_mat_1  = aligned_malloc(2*N0*N1);
   vaule_mat_1 = aligned_malloc(2*N0*N1);
   
   
   //printf("Attension 1 Matmul.\n");
   //Query matmul1 1st half -> 64*768 X 768*64 = 64*64
   EdgeBert_MatMul (dev, plic_dev, N0, N1, M_mat, is_relu, mem, Mask_mat, input_ids1st, we_mat1, softmax);
   memcpy(query_mat_1, mem+Mask_buffer_size+2*input_buffer_size+aux_buffer_size, N0*N1*sizeof(token_t));

   
   //Attension heads are store in vaule_mat_1
   

    aligned_free(input_ids1st);
    aligned_free(input_ids2nd);
    aligned_free(we_mat1);
    aligned_free(we_mat2);
    aligned_free(we_mat3);
    aligned_free(Mask_mat);
    //aligned_free(Aux_mat);

    //printf("FINISHing Attention Head in EdgeBert...\n");
    

}


 static void EdgeBert_ElementAddLayerNorm 
   (struct esp_device *dev, struct esp_device *plic_dev, int N0, int N1, int M_mat, token_t *mem, token_t *D_mat1, token_t *D_mat2)
   { 

    unsigned data = 0, data_read = 0;
    int num_interrupts;

    unsigned input_rd1_base = ((unsigned) mem) + Mask_buffer_size;
    unsigned input_rd2_base = ((unsigned) mem) + Mask_buffer_size+input_buffer_size;
    memcpy(mem+Mask_buffer_size, D_mat1, N0*M_mat*sizeof(token_t));
    memcpy(mem+Mask_buffer_size+input_buffer_size, D_mat2, M_mat*N1*sizeof(token_t));

    
    data = 0x1;
    iowrite32(dev, 0x50, data); //use_gb = 1
    data = 0x800;
    iowrite32(dev, 0x58, data); //reset_mode = 0x800 (6'100000-000000) EADD using PU DecMem1, XXX: flip_mem should be 1
    data = 0x04;
    iowrite32(dev, 0x54, data); //gb_mode_config = 4 // EADD gb mode
    data = 0;
    data += num_vector;
    data += num_timestep << 8;
    data += adpbias_act1 << 16;
    data += adpbias_act2 << 20;
    data += adpbias_act3 << 24;
    iowrite32(dev, 0x20, data);
    

    //Start InputMem0/1 Master Read 0x04-data=3
    data = 0x0;
    iowrite32(dev, 0x4C, data);
    iowrite32(dev, 0x08, data); //flip_mem = 0;

    data = input_rd1_base;
    iowrite32(dev, 0x30, data);

    data = 0x03;
    iowrite32(dev, 0x04, data); //master input read

    // 1st interrupt
    //printf("......waiting for 1st interrupt\n");
    //iointerrupt();
    while((ioread32(plic_dev, PLIC_IP_OFFSET) & 0x40) == 0);
    iowrite32(plic_dev, PLIC_INTACK_OFFSET, EDGEBERT_IRQ + 1);
    iowrite32(plic_dev, 0x2000, 0x40);
    iowrite32(plic_dev, 0x18, 0x2);
    ioread32(plic_dev, PLIC_INTACK_OFFSET);
    //printf("......receiving the 1st interrupt\n");
    num_interrupts++;

    
    data = 0x1;
    iowrite32(dev, 0x08, data); //flip_mem = 1;

    data = input_rd2_base;
    iowrite32(dev, 0x30, data);

    data = 0x03;
    iowrite32(dev, 0x04, data); //master input read

    // 2nd interrupt
    //printf("......waiting for 2nd interrupt\n");
    //iointerrupt();
    while((ioread32(plic_dev, PLIC_IP_OFFSET) & 0x40) == 0);
    iowrite32(plic_dev, PLIC_INTACK_OFFSET, EDGEBERT_IRQ + 1);
    iowrite32(plic_dev, 0x2000, 0x40);
    iowrite32(plic_dev, 0x18, 0x2);
    ioread32(plic_dev, PLIC_INTACK_OFFSET);
    //printf("......receiving the 2nd interrupt\n");
    num_interrupts++;


    // Start MatrixConfig 0x10" 
    data = 0x0;
    data += N0;
    data += N1 << 10;
    data += M_mat << 20;
    iowrite32(dev, 0x10, data);


    data = 0;
    data += base_input0;
    data += base_input1 << 16;
    iowrite32(dev, 0x14, data);
    data = 0;
    iowrite32(dev, 0x18, data);

    
    data = 0xA;
    iowrite32(dev, 0x04, data);

    //printf("......wait for EADD interrupt\n");
    //iointerrupt();
    while((ioread32(plic_dev, PLIC_IP_OFFSET) & 0x40) == 0);
    iowrite32(plic_dev, PLIC_INTACK_OFFSET, EDGEBERT_IRQ + 1);
    iowrite32(plic_dev, 0x2000, 0x40);
    iowrite32(plic_dev, 0x18, 0x2);
    ioread32(plic_dev, PLIC_INTACK_OFFSET);
    num_interrupts++;
    //printf("......got the EADD interrupt\n");


    //layernorm
    data = 0x0;
    iowrite32(dev, 0x08, data); //flip_mem = 0;
    data = 0x1;
    iowrite32(dev, 0x50, data); //use_gb = 1
    data = 0x04;
    iowrite32(dev, 0x58, data); //reset_mode = 0x02 layernorm pu mode
    data = 0x1;
    iowrite32(dev, 0x54, data); //gb_mode_config = 1 // layernorm gb mode
    
    data = 0;
    data += base_attn_span;
    data += base_gamma << 7;
    data += base_beta << 15;
    data += adpbias_attn_span << 23;
    data += adpbias_gamma << 26;
    data += adpbias_beta << 29;
    iowrite32(dev, 0x1C, data);
    
    data = 0;
    data += num_vector;
    data += num_timestep << 8;
    data += adpbias_act1 << 16;
    data += adpbias_act2 << 20;
    data += adpbias_act3 << 24;
    iowrite32(dev, 0x20, data);
    
    data = 0;
    data += base_input0;
    data += base_input1 << 16;
    iowrite32(dev, 0x14, data);
    iowrite32(dev, 0x18, data);
    
    data = 0x8;
    iowrite32(dev, 0x04, data);


    //printf("wait for LayerNorm interrupt\n");
    //iointerrupt();
    while((ioread32(plic_dev, PLIC_IP_OFFSET) & 0x40) == 0);
    iowrite32(plic_dev, PLIC_INTACK_OFFSET, EDGEBERT_IRQ + 1);
    iowrite32(plic_dev, 0x2000, 0x40);
    iowrite32(plic_dev, 0x18, 0x2);
    ioread32(plic_dev, PLIC_INTACK_OFFSET);
    num_interrupts++;
    //printf("got the LayerNorm interrupt\n");

    //read masterinput out
    data = 0x1;
    iowrite32(dev,  0x4C, data); 

    // Start Input Master Write" << endl;
    data = 0x04;
    iowrite32(dev,  0x04, data);
    
    // 7th interrupt
    //printf("......waiting for 4th interrupt\n");
    //iointerrupt();
    while((ioread32(plic_dev, PLIC_IP_OFFSET) & 0x40) == 0);
    iowrite32(plic_dev, PLIC_INTACK_OFFSET, EDGEBERT_IRQ + 1);
    iowrite32(plic_dev, 0x2000, 0x40);
    iowrite32(plic_dev, 0x18, 0x2);
    ioread32(plic_dev, PLIC_INTACK_OFFSET);
    //printf("......receiving the 4th interrupt\n");
    num_interrupts++;

    //data = 0x0;
    //iowrite32(dev,  0x4C, data); 


   }


static void EdgeBert_FeedForward (struct esp_device *dev, struct esp_device *plic_dev, token_t *mem, token_t *attention_out)
{
  
   int softmax = 0;
   //printf("Starting EdgeBERT Feed Forward Nets Computation...\n");
   token_t *Mask_mat; 
   Mask_mat = aligned_malloc(8192);
   memset(Mask_mat, 255, 8192*sizeof(token_t));

   token_t* we1_mat; // 768 X 3072(64*48)
   token_t* we2_mat; // 3072 X 768(16*48)

   we1_mat = aligned_malloc(768*3072);
   we2_mat = aligned_malloc(768*3072);


   //init_buf();
   memset(we1_mat, -1, 768*3072*sizeof(token_t));
   memset(we2_mat, -12, 768*3072*sizeof(token_t));
   
   
 // 1. attention_out X we1_mat 128*768 X 768*3072 (RElU)

   unsigned N0 ;
   unsigned N1 ;
   unsigned M_mat;
   unsigned is_relu;
   N0 = 64;
   M_mat = 768;
   N1 = 64;
   is_relu = 1;

   token_t *input_1;  //64*768
   token_t *input_2;  //768*64
   token_t *Relu_output; //128*3072

   input_1 = aligned_malloc(N0*M_mat);
   input_2  = aligned_malloc(M_mat*N1);
   Relu_output = aligned_malloc(128*3072);


   EdgeBert_Init(dev, plic_dev, mem); 
   int count = 0;

   for (int i=0; i<2; i++)
   {
    memcpy(input_1, attention_out+i*N0*M_mat, N0*M_mat*sizeof(token_t));

    for (int j=0; j<48; j++)
    {   
        memcpy(input_2, we1_mat+j*M_mat*N1, M_mat*N1*sizeof(token_t));


        if (count == 2)
         {
            EdgeBert_Init(dev, plic_dev, mem);
            count = 0; 
          } 

        //if ((i*48+j+1) % 100 == 0)
        //printf("FFN %d Matmul\n", i*48+j+1);
        
        EdgeBert_MatMul (dev, plic_dev, N0, N1, M_mat, is_relu, mem, Mask_mat, input_1, input_2, softmax);
        //revisit the indexing
        //memcpy(Relu_output + N0*N1*i*j, mem+Mask_buffer_size+2*input_buffer_size+aux_buffer_size, N0*N1*sizeof(token_t));
        
        count = count + 1;


        for (int l=0; l<N0; l++)
            {
            for (int k=0; k<N1; k++)
                {
                Relu_output[k+(l+i*N0)*3072 + j*N1] = mem[Mask_buffer_size+2*input_buffer_size+aux_buffer_size+k+l*N0];
                }
            }
    }
   
    }

    //2. Relu_out X we2_mat 128 (8*16)*3072 X 3072*768(16*48)
       
    N0 = 16;
    M_mat = 3072;
    N1 = 16;
    is_relu = 0;

    aligned_free(input_1);  //
    aligned_free(input_2);
    token_t *We2_output; 
    
    input_1 = aligned_malloc(N0*M_mat);
    input_2  = aligned_malloc(M_mat*N1);
    We2_output = aligned_malloc(128*768);


    EdgeBert_Init(dev, plic_dev, mem); 
    count = 0;

    
    for (int i=0; i<8; i++)
   {
    
    memcpy(input_1, Relu_output+i*N0*M_mat, N0*M_mat*sizeof(token_t));

    for (int j=0; j<48; j++)
    {   
        
        //if ((96+i*48+j+1) % 100 == 0)
        //printf("FFN %d Matmul\n", 96+i*48+j+1);
        
        memcpy(input_2, we2_mat+j*M_mat*N1, M_mat*N1*sizeof(token_t));
        
        if (count == 2)
         {
            EdgeBert_Init(dev, plic_dev, mem);
            count = 0; 
          } 



        EdgeBert_MatMul (dev, plic_dev, N0, N1, M_mat, is_relu, mem, Mask_mat, input_1, input_2, softmax);
        //memcpy(We2_output + N0*N1*i*j, mem+Mask_buffer_size+2*input_buffer_size+aux_buffer_size, N0*N1*sizeof(token_t));

        count = count + 1;

        for (int l=0; l<N0; l++)
            {
            for (int k=0; k<N1; k++)
                {
                We2_output[k+(l+i*N0)*768 + j*N1] = mem[Mask_buffer_size+2*input_buffer_size+aux_buffer_size+k+l*N0];
                }
            }
    }
   
    }
   

   aligned_free(input_1);  //
   aligned_free(input_2);
   // We2_out + attention_out  128*768 + 128*768
   // Layer Norm  --> FFN_output 128*768

   N0 = 64;
   M_mat = 768;
   N1 = 64;
   
   token_t* FFN_output;
   input_1 = aligned_malloc(N0*M_mat);
   input_2  = aligned_malloc(M_mat*N1);
   CPU_transpose(attention_out, 768, 128); 
   FFN_output = aligned_malloc(128*768);


   for (int i=0; i<2; i++)
   {
   memcpy(input_1, We2_output+i*N0*M_mat, N0*M_mat*sizeof(token_t));
   memcpy(input_2, attention_out+i*N1*M_mat, N1*M_mat*sizeof(token_t));
   EdgeBert_Init(dev, plic_dev, mem);
   EdgeBert_ElementAddLayerNorm(dev, plic_dev, N0, N1, M_mat, mem, input_1, input_2);
   memcpy(FFN_output + i*N0*M_mat, mem+Mask_buffer_size+2*input_buffer_size+aux_buffer_size, N0*M_mat*sizeof(token_t));
   }


   //printf("Finishing EdgeBERT Feed Forward Nets Computation DONE...\n");


   aligned_free(input_1);  //
   aligned_free(input_2);
   aligned_free(We2_output);
   aligned_free(Mask_mat); 
   aligned_free(we1_mat); // 768 X 3072(64*48)
   aligned_free(we2_mat);
   aligned_free(Relu_output);

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
static void init_buf(token_t *input_ids1st, token_t *input_ids2nd, token_t *we_mat1,token_t *we_mat2, token_t *we_mat3, token_t *Mask_mat, token_t *Aux_mat)
{
   //#include "input_ids1st.h" //128*768 -> 64*768
   //#include "input_ids2nd.h" //128*768 -> 64*768
   //#include "we_mat1.h" //768*64
   //#include "we_mat2.h" //768*64
   //#include "we_mat3.h" //768*64
   //#include "Mask_mat.h" //8192 chars
   //#include "Aux_mat.h" // 4096 chars
}






void CPU_multiply(int *a, int *b, int N0, int M_mat, int N1, int *d) 
{
    //printf("I'm here\n");
    for (int i = 0; i < N0; i++) {
        for (int j = 0; j < N1; j++) {
            int sum = 0;
            for (int k = 0; k < M_mat; k++)
                sum = sum + a[i * M_mat + k] * b[k * N1 + j];
            d[i * N1 + j] = sum;
        }
    }
}



void CPU_transpose_int (int *array, int m, int n){

    int new_array[m*n];
    for (int i = 0; i < m; ++i )
    {
       for (int j = 0; j < n; ++j )
       {
          // Index in the original matrix.
          int index1 = i*n+j;

          // Index in the transpose matrix.
          int index2 = j*m+i;

          new_array[index2] = array[index1];
       }
    }

    for (int i=0; i<m*n; i++) {
        array[i] = new_array[i];
    }
}



static void CPU_EdgeBert_Attension_profile ()
{


    int *input_ids;
    int *we_mat1;
    int *we_mat2; 
    int *we_mat3; 
    int *output1;
    int *output2;
    int *output3;

    input_ids = aligned_malloc(128*768*sizeof(int));
    we_mat1 = aligned_malloc(768*64*sizeof(int));
    we_mat2 = aligned_malloc(768*64*sizeof(int));
    we_mat3 = aligned_malloc(768*64*sizeof(int));
    output1 = aligned_malloc(128*64*sizeof(int));
    output2 = aligned_malloc(128*64*sizeof(int));
    output3 = aligned_malloc(128*64*sizeof(int));
    
    
    for (int i=0; i<128*768; i++)
    { 
        input_ids[i] = 12; 

    } 

    //printf("I'm here 2\n");

    for (int i=0; i<768*64; i++)
    { 
        we_mat1[i] = 24; 
        we_mat2[i] = -5; 
        we_mat3[i] = 126; 

    } 
    

int N0;
int N1;
int M_mat;

N0 = 128; M_mat = 768; N1 = 64;
//printf("1 matmul in attention head\n");
CPU_multiply(input_ids, we_mat1, N0, M_mat, N1, output1); 
//printf("2 matmul in attention head\n");
CPU_multiply(input_ids, we_mat2, N0, M_mat, N1, output2); 
//printf("3 matmul in attention head\n");
CPU_multiply(input_ids, we_mat3, N0, M_mat, N1, output3); 

CPU_transpose_int(output2, N0, N1);


N0 = 128; M_mat = 64; N1 = 128;
int *output4;
output4 = aligned_malloc(128*128*sizeof(int));

CPU_multiply(output1, output2, N0, M_mat, N1, output4);


N0 = 128; M_mat = 128; N1 = 64;
int *output5;
output5 = aligned_malloc(128*64*sizeof(int));
CPU_multiply(output4, output3, N0, M_mat, N1, output5);

//aligned_free(input_ids);
//aligned_free(we_mat1);
//aligned_free(we_mat2);
//aligned_free(we_mat3);
//aligned_free(output1);
//aligned_free(output2);
//aligned_free(output3);
//aligned_free(output4);
//aligned_free(output5);
   
}


static void CPU_EdgeBert_FeedForward ()
{

    int *attention_head_out;
    
    int *we1;
    int *we2;
    int *output1;
    int *output2;
    

    attention_head_out = aligned_malloc(128*768*sizeof(int));
    we1 = aligned_malloc(768*3072*sizeof(int));
    we2 = aligned_malloc(3072*768*sizeof(int));
    output1 = aligned_malloc(128*3072*sizeof(int));
    output2 = aligned_malloc(128*768*sizeof(int));


    for (int i=0; i<128*768; i++)
    { 
          attention_head_out[i] = 38;

    } 
    

    for (int i=0; i<3072*768; i++)
    { 
        we1[i] = 24; 
        we2[i] = -5;   

    } 
    

int N0;
int N1;
int M_mat;

N0 = 128; M_mat = 768; N1 = 3072;
//printf("1 matmul in attention head\n");
CPU_multiply(attention_head_out, we1, N0, M_mat, N1, output1); 
//printf("2 matmul in attention head\n");

N0 = 128; M_mat = 3072; N1 = 768;
CPU_multiply(output1, we2, N0, M_mat, N1, output2); 


}



//edgebert compuatation

int main(int argc, char * argv[])
{
    int i;
    int n;
    int ndev;
    struct esp_device dev, coh_dev;
    dev.addr = ACC_ADDR;

    struct esp_device plic_dev;
    plic_dev.addr = PLIC_ADDR;


    unsigned done;
    token_t *mem;


    unsigned errors1 = 0;
    unsigned errors2 = 0;
    unsigned coherence;
    unsigned data = 0, data_read = 0;
    

	
    mem_size = Mask_buffer_size + aux_buffer_size + 3*input_buffer_size;
    
    // TO MODIFY: Allocate memory
    // Allocation of the accelerator data array (mem) and of the expected output array (gold)
    mem = aligned_malloc(mem_size);

    

    // Flush (customize coherence model here)
    coherence = ACC_COH_RECALL;
    coh_dev.addr = CSR_TILE_ADDR;
    iowrite32(&coh_dev, CSR_REG_OFFSET*4, coherence);
    if (coherence != ACC_COH_RECALL)
	esp_flush(coherence,4);
    int num_interrupts;



    token_t* attention_heads;
    attention_heads = aligned_malloc(128*768);

   

   
                    

            EdgeBert_Attension_MM1 (&dev, &plic_dev, mem);

            


            





    //aligned_free(attention_out);
    aligned_free(mem);




    

    return 0;
}











