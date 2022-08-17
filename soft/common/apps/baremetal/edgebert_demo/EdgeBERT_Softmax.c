
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


static void EdgeBert_Attension_softmax (struct esp_device *dev, struct esp_device *plic_dev, token_t *mem)

{

    //printf("STARTing Attention Head in EdgeBert...\n");
    int num_interrupts;
    int softmax = 0;

    token_t *Mask_mat; 
    //token_t *Aux_mat;
    
    
    Mask_mat = aligned_malloc(8192);
    //Aux_mat = aligned_malloc(4096);

    memset(Mask_mat, 255, 8192*sizeof(token_t));
    //memset(Aux_mat, 3, 4096*sizeof(token_t));

    
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
   

   query_mat_1 = aligned_malloc(2*N0*N1);
   key_mat_1  = aligned_malloc(2*N0*N1);
   


   //query_mat_1 X key_mat_1
   N0 = 128;
   M_mat = 64;
   N1 = 128;
   token_t *query_mat_2; //the input for softmax: 128X128
   query_mat_2 = aligned_malloc(2*N0*N1);    

   

   EdgeBert_Init(dev, plic_dev, mem); 
   memcpy(key_mat_1 + N0*N1, mem+Mask_buffer_size+2*input_buffer_size+aux_buffer_size, N0*N1*sizeof(token_t));
   memcpy(query_mat_1 + N0*N1, mem+Mask_buffer_size+2*input_buffer_size+aux_buffer_size, N0*N1*sizeof(token_t));

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
   count1 = get_counter();  

   EdgeBert_SoftAttenM (dev, plic_dev, N0, N1, M_mat);

   count2 = get_counter();
            
      
   exe_cycle = (count2-count1);
   //printf("...Attention Head %d takes %u ns seconds...\n", i, exe_time);
   printf("...SoftMax takes %"PRIu64" clock cycles...\n", exe_cycle);



   //after softmax and attention span
   memcpy(query_mat_2, mem+Mask_buffer_size+2*input_buffer_size+aux_buffer_size, N0*N1*sizeof(token_t));



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
    memset(mem, 255, mem_size*sizeof(token_t));

    

    // Flush (customize coherence model here)
    coherence = ACC_COH_RECALL;
    coh_dev.addr = CSR_TILE_ADDR;
    iowrite32(&coh_dev, CSR_REG_OFFSET*4, coherence);
    if (coherence != ACC_COH_RECALL)
    esp_flush(coherence,4);
    int num_interrupts;

    
    
    token_t* attention_heads;
    attention_heads = aligned_malloc(128*768);

    uint64_t total_exe_cycle = 0;
    uint64_t count1;
    uint64_t count2;
    double exe_time;
    uint64_t exe_cycle;

    
                       

   EdgeBert_Attension_softmax (&dev, &plic_dev, mem);

    
    //aligned_free(attention_out);
   aligned_free(mem);

    

    return 0;
}

