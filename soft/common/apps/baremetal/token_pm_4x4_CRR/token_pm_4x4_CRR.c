/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

//#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>
//#include "token_pm_3x3_Ccommon.h"
#include "token_pm_4x4_CRR.h"
//#include "token_pm_3x3_SW_data.h"
#include "token_pm_nv.h"
#include "token_pm_conv2d.h"
#include "token_pm_gemm.h"

//Global

int main(int argc, char * argv[])
{
    int i;
    int n;
    //unsigned config0, config1_v1, config1_v2, config2, config3;
    //unsigned tokens_next0, tokens_next1;



    unsigned acc_tile_pm_csr_addr[N_ACC];


    // setup CSR base addresses
    for (i = 0; i < N_ACC; i++) {
	acc_tile_pm_csr_addr[i] = CSR_BASE_ADDR + CSR_TILE_OFFSET * acc_tile_ids[i] + CSR_TOKEN_PM_OFFSET;
	espdevs[i].addr = acc_tile_pm_csr_addr[i];
    }

	reset_token_pm(espdevs);

	unsigned int* noc_dco_ptr = (unsigned int *) 0x60091FCC;
	*noc_dco_ptr = 0x5000D;


#ifdef TEST_0
	//Simply puts the token PM in full bypass mode to test the frequency write commands
    printf("Test 0: Starting\n");
	
    reset_token_pm(espdevs);
    for (i = 0; i < N_ACC; i++) {
		set_freq(&espdevs[i],Fmax[i]);
	}
	for (i = 0; i < N_ACC; i++) {
		set_freq(&espdevs[i],Fmin[i]);
	}
    printf("Test 0: End\n");

#endif

#ifdef TEST_1
//#define DEBUG 1

//Test with dummy activity. In progress
    printf("Test 1: Starting CRR on 4x4\n");


   //nvdla_token_t *mem_n1;
   //nvdla_token_t *gold_nvdla;
   

//Test running all tiles
   struct esp_device *espdevs_gemm, *espdevs_viterbi, *espdevs_nvdla;
   struct esp_device *dev_g1 = aligned_malloc(sizeof(struct esp_device));
   struct esp_device *dev_g2 = aligned_malloc(sizeof(struct esp_device));
   struct esp_device *dev_g3 = aligned_malloc(sizeof(struct esp_device));
   struct esp_device *dev_g4 = aligned_malloc(sizeof(struct esp_device));
   struct esp_device *dev_n1 = aligned_malloc(sizeof(struct esp_device));
   struct esp_device *dev_n2 = aligned_malloc(sizeof(struct esp_device));
   struct esp_device *dev_n3 = aligned_malloc(sizeof(struct esp_device));
   struct esp_device *dev_n4 = aligned_malloc(sizeof(struct esp_device));
   struct esp_device *dev_n5 = aligned_malloc(sizeof(struct esp_device));
   struct esp_device *dev_n6 = aligned_malloc(sizeof(struct esp_device));
   struct esp_device *dev_c1 = aligned_malloc(sizeof(struct esp_device));
   struct esp_device *dev_c2 = aligned_malloc(sizeof(struct esp_device));
   struct esp_device *dev_c3 = aligned_malloc(sizeof(struct esp_device));
    unsigned **ptable = NULL;
   unsigned **ptable_g1 = NULL;
   unsigned **ptable_g2 = NULL;
   unsigned **ptable_g3 = NULL;
   unsigned **ptable_g4 = NULL;
   unsigned **ptable_n1 = NULL;
   unsigned **ptable_n2 = NULL;
   unsigned **ptable_n3 = NULL;
   unsigned **ptable_n4 = NULL;
   unsigned **ptable_n5 = NULL;
   unsigned **ptable_n6 = NULL;
   unsigned **ptable_c1 = NULL;
   unsigned **ptable_c2 = NULL;
   unsigned **ptable_c3 = NULL;
   pixel *mem_n1, *mem_n2, *mem_n3, *mem_n4, *mem_n5, *mem_n6;
   gemm_token_t *mem_g1, *mem_g2, *mem_g3, *mem_g4;
   conv2d_token_t *mem_c1, *mem_c2, *mem_c3;
   unsigned errors = 0;
   unsigned coherence = ACC_COH_RECALL;
   const int ERROR_COUNT_TH = 0.001;
   uint64_t cycles_start = 0, cycles_end_n1 = 0,cycles_end_n2 = 0, cycles_end_n3 = 0, cycles_end_n4 = 0, cycles_end_n5 = 0, cycles_end_n6 = 0, cycles_end_g1 = 0, cycles_end_g2 = 0, cycles_end_g3 = 0, cycles_end_g4 = 0, cycles_end_c1 = 0, cycles_end_c2 = 0, cycles_end_c3=0 ;
       int ndev;

   printf("Test 1: Starting debug CRR\n");
	
	for (i=0;i<N_ACC;i++){
		dev_list_acc[i]=aligned_malloc(sizeof(struct esp_device));
	}
	

   /// GEMM setup/////
   printf("Setting up GEMM accelerators\n");
   dev_list_acc[0]->addr = ACC_ADDR_GEMM1;
   mem_size=gemm_init_params();
   #ifdef DEBUG
   	printf("GEMM init complete, Mem size=%u\n",mem_size);
   #endif
    
   setup_gemm(dev_list_acc[0], mem_g1, ptable_g1, mem_size);
   #ifdef DEBUG
   	printf("GEMM1 setup complete, address=0x%x\n",dev_list_acc[0]->addr);
   #endif

   dev_list_acc[1]->addr = ACC_ADDR_GEMM2;
   setup_gemm(dev_list_acc[1], mem_g2, ptable_g2, mem_size);
   #ifdef DEBUG
   	printf("GEMM2 setup complete, address=0x%x\n",dev_list_acc[1]->addr);
   #endif

   dev_list_acc[2]->addr = ACC_ADDR_GEMM3;
   setup_gemm(dev_list_acc[2], mem_g3, ptable_g3, mem_size);
   #ifdef DEBUG
   	printf("GEMM3 setup complete, address=0x%x\n",dev_list_acc[2]->addr);
   #endif

   dev_list_acc[3]->addr = ACC_ADDR_GEMM4;
   setup_gemm(dev_list_acc[3], mem_g4, ptable_g4, mem_size);
   #ifdef DEBUG
   	printf("GEMM4 setup complete, address=0x%x\n",dev_list_acc[3]->addr);
   #endif

   printf("GEMM setup complete\n");

    //NV is all set

   ////NV setup/////
   printf("Setting up NV accelerators\n");
    
   dev_list_acc[4]->addr = ACC_ADDR_NV1;
   setup_nv(dev_list_acc[4], mem_n1, ptable_n1);
   #ifdef DEBUG
   	printf("NV1 setup complete, address=0x%x\n",dev_list_acc[4]->addr);
   #endif

   dev_list_acc[5]->addr = ACC_ADDR_NV2;
   setup_nv(dev_list_acc[5], mem_n2, ptable_n2);
   #ifdef DEBUG
   	printf("NV2 setup complete, address=0x%x\n",dev_list_acc[5]->addr);
   #endif

   dev_list_acc[6]->addr = ACC_ADDR_NV3;
   setup_nv(dev_list_acc[6], mem_n3, ptable_n3);
   #ifdef DEBUG
   	printf("NV3 setup complete, address=0x%x\n",dev_list_acc[6]->addr);
   #endif

   dev_list_acc[7]->addr = ACC_ADDR_NV4;
   setup_nv(dev_list_acc[7], mem_n4, ptable_n4);
   #ifdef DEBUG
   	printf("NV4 setup complete, address=0x%x\n",dev_list_acc[7]->addr);
   #endif

   dev_list_acc[11]->addr = ACC_ADDR_NV5;
   setup_nv(dev_list_acc[11], mem_n5, ptable_n5);
   #ifdef DEBUG
   	printf("NV5 setup complete, address=0x%x\n",dev_list_acc[11]->addr);
   #endif

   dev_list_acc[12]->addr = ACC_ADDR_NV6;
   setup_nv(dev_list_acc[12], mem_n6, ptable_n6);
   #ifdef DEBUG
   	printf("NV6 setup complete, address=0x%x\n",dev_list_acc[12]->addr);
   #endif
   printf("NV setup complete\n");

    //NV is all set
	
   ////CONV2D setup/////
   printf("Setting up CONV2D accelerators\n");
   mem_size=conv2d_init_params();
    
   dev_list_acc[8]->addr = ACC_ADDR_CONV2D1;
   setup_conv2d(dev_list_acc[8], mem_c1, ptable_c1, mem_size);
   #ifdef DEBUG
   	printf("CONV2D1 setup complete, address=0x%x\n",dev_list_acc[8]->addr);
   #endif

   dev_list_acc[9]->addr = ACC_ADDR_CONV2D2;
   setup_conv2d(dev_list_acc[9], mem_c2, ptable_c2, mem_size);
   #ifdef DEBUG
   	printf("CONV2D2 setup complete, address=0x%x\n",dev_list_acc[9]->addr);
   #endif

   dev_list_acc[10]->addr = ACC_ADDR_CONV2D3;
   setup_conv2d(dev_list_acc[10], mem_c3, ptable_c3, mem_size);
   #ifdef DEBUG
   	printf("CONV2D3 setup complete, address=0x%x\n",dev_list_acc[10]->addr);
   #endif


    // Flush (customize coherence model here)
    if (coherence != ACC_COH_RECALL)
        esp_flush(coherence, 1);

	//Start accelerators
	for (i=0;i<N_ACC;i++){
		start_tile(i);
	}


	
	while((head_run != NULL) ||(head_idle != NULL) ||(head_wait != NULL) ) {
		CRR_step_checkend();
		CRR_step_rotate();
		#ifdef DEBUG
		printf("Run step\n");
		#endif
	
	}
		
	
#endif


    return 0;
}
