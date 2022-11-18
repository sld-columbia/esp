/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

//#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>
//#include "token_pm_3x3_Ccommon.h"
#include "token_pm_3x3_CRR.h"
//#include "token_pm_3x3_SW_data.h"
#include "token_pm_fft.h"
#include "token_pm_vitdodec.h"

//Global

int main(int argc, char * argv[])
{
    int i;
    int n;
    int rot_iter;
    //unsigned config0, config1_v1, config1_v2, config2, config3;
    //unsigned tokens_next0, tokens_next1;



    unsigned acc_tile_pm_csr_addr[N_ACC];


    // setup CSR base addresses
    for (i = 0; i < N_ACC; i++) 
    {
	acc_tile_pm_csr_addr[i] = CSR_BASE_ADDR + CSR_TILE_OFFSET * acc_tile_ids[i] + CSR_TOKEN_PM_OFFSET;
	espdevs[i].addr = acc_tile_pm_csr_addr[i];
    }

#ifdef TEST_0
	//Simply puts the token PM in full bypass mode to test the frequency write commands
    printf("Test 0: Starting\n");
	
    reset_token_pm(espdevs);
	
	set_freq(&espdevs[0],0xA);
	set_freq(&espdevs[1],0x7);
	set_freq(&espdevs[2],0x3);
	set_freq(&espdevs[3],0x0);
	set_freq(&espdevs[4],0x8);
	set_freq(&espdevs[5],0x4);
    printf("Test 0: End\n");

#endif

#ifdef TEST_1
//#define DEBUG 1

//Test with dummy activity. In progress

   //nvdla_token_t *mem_n1;
   //nvdla_token_t *gold_nvdla;
   
   fft_token_t *mem_f1, *mem_f2, *mem_f3;
   fft_token_t *gold_fft;
   vit_token_t *mem_v1, *mem_v2;
   vit_token_t *gold_vit;

   unsigned errors = 0;
   unsigned coherence = ACC_COH_RECALL;
   const int ERROR_COUNT_TH = 0.001;
   uint64_t cycles_start = 0, cycles_end_n1 = 0, cycles_end_f1 = 0,cycles_end_v1 = 0, cycles_end_f2 = 0, cycles_end_v2 = 0, cycles_end_f3 = 0;
   int ndev;
    
   unsigned **ptable_f1 = NULL;
   unsigned **ptable_f2 = NULL;
   unsigned **ptable_f3 = NULL;
   unsigned **ptable_v1 = NULL;
   unsigned **ptable_v2 = NULL;

   printf("Setup accelerators\n");
	
	for (i=0;i<N_ACC;i++){
		dev_list_acc[i]=aligned_malloc(sizeof(struct esp_device));
	}
	

   ////FFT setup/////
   #ifdef DEBUG
   	printf("Setting up FFT accelerators\n");
   #endif
   mem_size=fft_init_params();
   dev_list_acc[1]->addr = ACC_ADDR_FFT1;
   setup_fft(dev_list_acc[1], gold_fft, mem_f1, ptable_f1);
   #ifdef DEBUG
   	printf("FFT1 setup complete, address=0x%x\n",dev_list_acc[1]->addr);
   #endif
   dev_list_acc[3]->addr = ACC_ADDR_FFT2;
   setup_fft(dev_list_acc[3], gold_fft, mem_f2, ptable_f2);
   #ifdef DEBUG
   	printf("FFT2 setup complete, address=0x%x\n",dev_list_acc[3]->addr);
   #endif
   dev_list_acc[5]->addr = ACC_ADDR_FFT3;
   setup_fft(dev_list_acc[5], gold_fft, mem_f3, ptable_f3);
   #ifdef DEBUG
   	printf("FFT3 setup complete, address=0x%x\n",dev_list_acc[5]->addr);
   #endif
   //printf("FFT setup complete\n");

    //FFT is all set
	
   //////Viterbi setup//////
	
    #ifdef DEBUG
    	printf("Starting viterbi init\n");
    #endif
    mem_size=vit_init_params();
    dev_list_acc[2]->addr = ACC_ADDR_VITERBI1;
    setup_viterbi(dev_list_acc[2], gold_vit, mem_v1, ptable_v1);
    #ifdef DEBUG
    	printf("Viterbi1 setup complete, address=0x%x\n",dev_list_acc[2]->addr);
    #endif
    dev_list_acc[4]->addr = ACC_ADDR_VITERBI2;
    setup_viterbi(dev_list_acc[4], gold_vit, mem_v2, ptable_v2);
    #ifdef DEBUG
    	printf("Viterbi2 setup complete, address=0x%x\n",dev_list_acc[4]->addr);
    #endif
    //printf("Viterbi setup complete\n");
    
    //////NVDLA setup//////
    #ifdef DEBUG
    	printf("NVDLA init and start\n");
    #endif
    dev_list_acc[0]->addr = ACC_ADDR_NVDLA;

    // Flush (customize coherence model here)
    if (coherence != ACC_COH_RECALL)
        esp_flush(coherence, 1);

	//Start accelerators 1 to 5
	for (i=1;i<N_ACC;i++){
		start_tile(i);
	}
	
	//Start NVDLA
	start_tile(0);

	//run_nvdla( &espdevs[0], dev_list_acc[0], gold_nvdla, mem_n1, 0);
	
	//Wait for NVDLA done
	//write_config1(&espdevs[0], 0, 0, 0, 0);
	#ifdef DEBUG
		printf("Finished NVDLA new Pav %u\n",p_available);
    #endif

    #ifdef DEBUG
		printf("Finished N1\n");
    #endif

	
	while((head_run != NULL) ||(head_idle != NULL) ||(head_wait != NULL) ) {
		CRR_step_checkend();
		CRR_step_rotate();
		//printf("Run step %u\n", rot_iter);
		rot_iter++;
	}
	printf("Finished CRR %u\n", rot_iter);
		
	
#endif


    return 0;
}
