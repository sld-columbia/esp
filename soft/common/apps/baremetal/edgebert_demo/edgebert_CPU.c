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

    uint64_t count1;
    uint64_t count2;
   
    uint64_t exe_cycle;
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

N0 = 64; M_mat = 768; N1 = 64;
//printf("1 matmul in attention head\n");

count1 = get_counter();
CPU_multiply(input_ids, we_mat1, N0, M_mat, N1, output1); 
count2 = get_counter();
exe_cycle = (count2-count1);      
printf("...CPU_Atten_MM1 takes %"PRIu64" clock cycles...\n", exe_cycle);

//printf("2 matmul in attention head\n");
CPU_multiply(input_ids, we_mat2, N0, M_mat, N1, output2); 
//printf("3 matmul in attention head\n");
CPU_multiply(input_ids, we_mat3, N0, M_mat, N1, output3); 

CPU_multiply(input_ids, we_mat1, N0, M_mat, N1, output1); 
//printf("2 matmul in attention head\n");
CPU_multiply(input_ids, we_mat2, N0, M_mat, N1, output2); 
//printf("3 matmul in attention head\n");
CPU_multiply(input_ids, we_mat3, N0, M_mat, N1, output3); 


count1 = get_counter();
CPU_transpose_int(output2, 2*N0, N1);
count2 = get_counter();
exe_cycle = (count2-count1);      
printf("...CPU_transpose_1 takes %"PRIu64" clock cycles...\n", exe_cycle);


N0 = 128; M_mat = 64; N1 = 128;
int *output4;
output4 = aligned_malloc(128*128*sizeof(int));


count1 = get_counter();
CPU_multiply(output1, output2, N0, M_mat, N1, output4);
count2 = get_counter();
exe_cycle = (count2-count1);      
printf("...CPU_Atten_MM2 takes %"PRIu64" clock cycles...\n", exe_cycle);


N0 = 128; M_mat = 128; N1 = 64;
int *output5;

output5 = aligned_malloc(128*64*sizeof(int));

count1 = get_counter();
CPU_multiply(output4, output3, N0, M_mat, N1, output5);
count2 = get_counter();
exe_cycle = (count2-count1);      
printf("...CPU_Atten_MM3 takes %"PRIu64" clock cycles...\n", exe_cycle);

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

    
    uint64_t count1;
    uint64_t count2;
   
    uint64_t exe_cycle;

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

N0 = 64; M_mat = 768; N1 = 64;
//printf("1 matmul in attention head\n");

count1 = get_counter(); 
CPU_multiply(attention_head_out, we1, N0, M_mat, N1, output1); 
count2 = get_counter();
exe_cycle = (count2-count1);
        
printf("...CPU_ffn_MM1 takes %"PRIu64" clock cycles...\n", exe_cycle);


for (int i=0; i<2*48-1; i++)
   {    CPU_multiply(attention_head_out, we1, N0, M_mat, N1, output1); }


N0 = 16; M_mat = 3072; N1 = 16;

count1 = get_counter(); 
CPU_multiply(output1, we2, N0, M_mat, N1, output2); 
count2 = get_counter();
exe_cycle = (count2-count1);        
printf("...CPU_ffn_MM2 takes %"PRIu64" clock cycles...\n", exe_cycle);


for (int i=0; i<8*48-1; i++)
   {CPU_multiply(output1, we2, N0, M_mat, N1, output2);}




count1 = get_counter();
CPU_transpose_int(attention_head_out, 768, 128);
count2 = get_counter();
exe_cycle = (count2-count1);      
printf("...CPU_transpose_2 takes %"PRIu64" clock cycles...\n", exe_cycle);   



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
    

    uint64_t total_exe_cycle = 0;
    uint64_t count1;
    uint64_t count2;
    double exe_time;
    uint64_t exe_cycle;

    
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



    //stating CPU performance Estimation

    printf("\n\n");
    int *attention_heads_cpu;
    attention_heads_cpu = aligned_malloc(128*768*sizeof(int));
    
    printf("Transformer Matmul Performance Profiling on Ariane RISC-V CPU\n"); 
    printf("\nSTARTing CPU 12 Attention Heads Computation...\n"); 
    
    total_exe_cycle = 0;
    

    for (int i=0; i<12; i++)

        {   
            
            count1 = get_counter();           

            CPU_EdgeBert_Attension_profile();

            count2 = get_counter();
            
            exe_cycle = (count2-count1);
            //printf("...Attention Head %d takes %"PRIu64" clock cycles...\n", i, exe_cycle);


            for (int l=0; l<128; l++)
            {
            for (int k=0; k<64; k++)
                {
                //attention_heads[l*768+k+i*64] = mem[Mask_buffer_size+2*input_buffer_size+aux_buffer_size+k+l*64];
                attention_heads_cpu[l*768+k+i*64] = k+l*64;
                }
            }
        
        total_exe_cycle = total_exe_cycle +  exe_cycle; 
        
        }
    printf("FINISHing CPU 12 Attention Heads Computation...\n");
    //printf("###(%"PRIu64" clock cycles)###\n", total_exe_cycle);



    printf("\nSTARTing CPU 12 Attention Heads Prcessing...\n"); 
    
    

    //attention_heads X We_heads 128*768 X 768*768
    
    int *We_heads_cpu;
    We_heads_cpu = aligned_malloc(768*768*sizeof(int));
    int *attention_head_out_cpu;
    attention_head_out_cpu = aligned_malloc(128*768*sizeof(int));
    
    count1 = get_counter();  
    for (int i=0; i<768*768; i++)
    { We_heads_cpu[i] = -1;}

    N0 = 128; M_mat = 768; N1 = 768;
    
    CPU_multiply(attention_heads_cpu, We_heads_cpu, N0, M_mat, N1, attention_head_out_cpu); 

    CPU_transpose_int(attention_head_out_cpu, 768, 128); 

    count2 = get_counter();



    printf("FINISHing CPU 12 Attention Heads Processing...\n");   
    //printf("###(%"PRIu64" clock cycles)###\n", count2-count1);

    
   
    
    printf("\nSTARTing CPU Feed Forward Net Computation...\n");
   
    
    count1 = get_counter();
    CPU_EdgeBert_FeedForward ();
    //printf("EdgeBERT FFN DONE...\n");
    count2 = get_counter();
    printf("FINISHing CPU Feed Forward Net Computation...\n");
    //printf("###(%"PRIu64" clock cycles)###\n", count2-count1);


    
    printf("\nTransformer Matmul Performance Profiling on Ariane RISC-V CPU DONE...\n");
    printf("Thank you!\n");

    //aligned_free(attention_out);
    aligned_free(mem);




    

    return 0;
}










