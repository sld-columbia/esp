/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>
#include "token_pm_3x3_CRR.h"
#include "token_pm_3x3_SW_data.h"
#include "token_pm_fft.h"
#include "token_pm_vitdodec.h"
#include "token_pm_nvdla.h"

int main(int argc, char * argv[])
{
    int i;
    int n;
    //unsigned config0, config1_v1, config1_v2, config2, config3;
    //unsigned tokens_next0, tokens_next1;



    unsigned acc_tile_pm_csr_addr[N_ACC];
    struct esp_device espdevs[N_ACC];
    struct esp_device *espdev;

    // setup CSR base addresses
    for (i = 0; i < N_ACC; i++) {
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
//Test with dummy activity. In progress
	p_available=P_TOTAL;
	Pmax[N_ACC] = {max_tokens_NVDLA,max_tokens_FFT,max_tokens_VIT,max_tokens_FFT,max_tokens_VIT,max_tokens_FFT};
	Fmax[N_ACC] = {lut_data_const_NVDLA[max_tokens_NVDLA],lut_data_const_FFT[max_tokens_FFT],lut_data_const_VIT[max_tokens_VIT],lut_data_const_FFT[max_tokens_FFT],lut_data_const_VIT[max_tokens_VIT],lut_data_const_FFT[max_tokens_FFT]};
	Fmin[N_ACC] = {lut_data_const_NVDLA[0],lut_data_const_FFT[0],lut_data_const_VIT[0],lut_data_const_FFT[0],lut_data_const_VIT[0],lut_data_const_FFT[0]};
	dev_list[N_ACC]={dev_n0,dev_f1,dev_v1,dev_f2,dev_v2,dev_f3}
#endif




#ifdef TEST_2
//In progress
//Test running all viterbi, NVDLA and FFT tiles
   struct esp_device *espdevs_fft, *espdevs_viterbi, *espdevs_nvdla;
   struct esp_device *dev_n1 = aligned_malloc(sizeof(struct esp_device));
   struct esp_device *dev_f1 = aligned_malloc(sizeof(struct esp_device));
   struct esp_device *dev_f2 = aligned_malloc(sizeof(struct esp_device));
   struct esp_device *dev_f3 = aligned_malloc(sizeof(struct esp_device));
   struct esp_device *dev_v1 = aligned_malloc(sizeof(struct esp_device));
   struct esp_device *dev_v2 = aligned_malloc(sizeof(struct esp_device));
   //struct esp_device *dev, *dev_f1, *dev_f2, *dev_f3 ;
   //struct esp_device *dev_v1, *dev_v2 ;
   unsigned done_all, done_f1=0, done_v1=0, done_f1_before=0, done_v1_before=0;
   unsigned done_f2=0, done_v2=0, done_f2_before=0, done_v2_before=0;
   unsigned done_f3=0, done_n1=0, done_f3_before=0, done_n1_before=0;

   unsigned **ptable_f1 = NULL;
   unsigned **ptable_f2 = NULL;
   unsigned **ptable_f3 = NULL;
   unsigned **ptable_v1 = NULL;
   unsigned **ptable_v2 = NULL;
   nvdla_token_t *mem_n1;
   nvdla_token_t *gold_nvdla;
   fft_token_t *mem_f1, *mem_f2, *mem_f3;
   fft_token_t *gold_fft;
   vit_token_t *mem_v1, *mem_v2;
   vit_token_t *gold_vit;

   unsigned errors = 0;
   unsigned coherence = ACC_COH_RECALL;
   const int ERROR_COUNT_TH = 0.001;
   uint64_t cycles_start = 0, cycles_end_n1 = 0, cycles_end_f1 = 0,cycles_end_v1 = 0, cycles_end_f2 = 0, cycles_end_v2 = 0, cycles_end_f3 = 0;
   int ndev;
    
  

   //Initialize tokens
   init_consts();
   reset_token_pm(espdevs);
   #ifdef PID_CONFIG
	   write_lut_all(espdevs, lut_data_const_vc707, random_rate_const, no_activity_const);
   #else	   
	   write_lut(espdevs, lut_data_const_vc707_NVDLA, random_rate_const_0, no_activity_const,0);    
	   write_lut(espdevs, lut_data_const_vc707_FFT, random_rate_const, no_activity_const,1);    
	   write_lut(espdevs, lut_data_const_vc707_VIT, random_rate_const, no_activity_const,2);    
	   write_lut(espdevs, lut_data_const_vc707_FFT, random_rate_const, no_activity_const,3);    
	   write_lut(espdevs, lut_data_const_vc707_VIT, random_rate_const, no_activity_const,4);    
	   write_lut(espdevs, lut_data_const_vc707_FFT, random_rate_const, no_activity_const,5);    
   #endif
   
   // Configure and start PM of all accelerator tiles
   printf("Test 4: Config and start PM of all accelerators\n");
   printf("Clock frequency: 0x%x\n",TOKEN_PM_CONFIG8_REG_DEFAULT);
   //unsigned token_counter_override_vc707[N_ACC] = {0x80, 0xb0}; // {1000 0000 (0), 1011 0000 (48)}    
   //unsigned max_tokens_vc707[N_ACC] = {0, 48};
   for (i = 0; i < N_ACC; i++) {
       espdev = &espdevs[i];
       write_config2(espdev, neighbors_id_const[i]);
       write_config3(espdev, pm_network_const[i]);
		if(i>0){
			write_config1(espdev, no_activity_const, random_rate_const, 0, token_counter_override_vc707[i]);
			write_config1(espdev, no_activity_const, random_rate_const, 0, 0);
		}
		else {
			write_config1(espdev, no_activity_const,random_rate_const_0, 0, token_counter_override_vc707[i]);
			write_config1(espdev, no_activity_const, random_rate_const_0, 0, 0);	
		}

       write_config0(espdev, enable_const, max_tokens_vc707[i], refresh_rate_min_const, refresh_rate_max_const);
   }

   /*
   wait_for_token_next(&espdevs[0], 0);
   wait_for_token_next(&espdevs[1], 48);
   wait_for_token_next(&espdevs[2], 0);
   printf("   --> tokens_next converged\n");

   //Disable tile 0
   espdev = &espdevs[0];
   write_config1(espdev, no_activity_const, random_rate_const, 0, 0);

   //Enable tile 1
   espdev = &espdevs[1];
   write_config1(espdev, activity_const, random_rate_const, 0, 0);

   */

   ////FFT setup/////
   #ifdef DEBUG
   	printf("Setting up FFT accelerators\n");
   #endif
   mem_size=fft_init_params();
   //fft_probe(&espdevs_fft);
    
   //dev_f1 = &espdevs_fft[0];
   dev_f1->addr = ACC_ADDR_FFT1;
   setup_fft(dev_f1, gold_fft, mem_f1, ptable_f1);
   #ifdef DEBUG
   	printf("FFT1 setup complete, address=0x%x\n",dev_f1->addr);
   #endif
   //dev_f2= &espdevs_fft[1];
   dev_f2->addr = ACC_ADDR_FFT2;
   setup_fft(dev_f2, gold_fft, mem_f2, ptable_f2);
   #ifdef DEBUG
   	printf("FFT2 setup complete, address=0x%x\n",dev_f2->addr);
   #endif
   //dev_f3 = &espdevs_fft[2];
   dev_f3->addr = ACC_ADDR_FFT3;
   setup_fft(dev_f3, gold_fft, mem_f3, ptable_f3);
   #ifdef DEBUG
   	printf("FFT3 setup complete, address=0x%x\n",dev_f3->addr);
   #endif
   //printf("FFT setup complete\n");

    //FFT is all set
	
   //////Viterbi setup//////
	
    #ifdef DEBUG
    	printf("Starting viterbi init\n");
    #endif
    mem_size=vit_init_params();
    //vit_probe(&espdevs_viterbi);

    //dev_v1 = &espdevs_viterbi[0];
    dev_v1->addr = ACC_ADDR_VITERBI1;
    setup_viterbi(dev_v1, gold_vit, mem_v1, ptable_v1);
    #ifdef DEBUG
    	printf("Viterbi1 setup complete, address=0x%x\n",dev_v1->addr);
    #endif
    //dev_v2= &espdevs_viterbi[1];
    //dev_v2.addr = ACC_ADDR_VITERBI2;
    dev_v2->addr = ACC_ADDR_VITERBI2;
    setup_viterbi(dev_v2, gold_vit, mem_v2, ptable_v2);
    #ifdef DEBUG
    	printf("Viterbi2 setup complete, address=0x%x\n",dev_v2->addr);
    #endif
    //printf("Viterbi setup complete\n");
    
    //////NVDLA setup//////
    #ifdef DEBUG
    	printf("NVDLA init and start\n");
    #endif
    //nvdla_probe(&espdevs_nvdla);
    //dev_n1 = &espdevs_nvdla[0];
    dev_n1->addr = ACC_ADDR_NVDLA;

    // Flush (customize coherence model here)
    if (coherence != ACC_COH_RECALL)
        esp_flush(coherence, 1);
	
    //printf("Start accelerators\n");
    ///////Start accelerators//////
    iowrite32(dev_f1, CMD_REG, CMD_MASK_START);
    espdev = &espdevs[1];
    write_config1(espdev, activity_const, random_rate_const, 0, 0);
    #ifdef DEBUG
    	printf("Started F1\n");
    #endif
    iowrite32(dev_v1, CMD_REG, CMD_MASK_START);
    espdev = &espdevs[2];
    write_config1(espdev, activity_const, random_rate_const, 0, 0);
    #ifdef DEBUG
    	printf("Started V1\n");
    #endif
    iowrite32(dev_f2, CMD_REG, CMD_MASK_START);
    espdev = &espdevs[3];
    write_config1(espdev, activity_const, random_rate_const, 0, 0);
    #ifdef DEBUG
    	printf("Started F2\n");
    #endif
    iowrite32(dev_v2, CMD_REG, CMD_MASK_START);
    espdev = &espdevs[4];
    write_config1(espdev, activity_const, random_rate_const, 0, 0);
    #ifdef DEBUG
    	printf("Started V2\n");
    #endif
    iowrite32(dev_f3, CMD_REG, CMD_MASK_START);
    espdev = &espdevs[5];
    write_config1(espdev, activity_const, random_rate_const, 0, 0);
    #ifdef DEBUG
    	printf("Started F3\n");
    #endif

    cycles_start = get_counter();

   // //Enable tiles
   // printf("Enabling tiles\n");
   // for (i=0; i<N_ACC; i++)
   // {
   // 	espdev = &espdevs[i];
   // 	write_config1(espdev, activity_const, random_rate_const, 0, 0);
   // }
    espdev = &espdevs[0];
	write_config1(espdev,activity_const, random_rate_const_0, 0, 0);
    run_nvdla(espdev, dev_n1, gold_nvdla, mem_n1, 0);
	write_config1(espdev, 0, random_rate_const_0, 0, 0);

    #ifdef DEBUG
    	printf("NVDLA finished, address=0x%x\n",dev_n1->addr);
    #endif

    ////Wait for them to complete////
    printf("Running all accelerators... Start cycles = %u\n",cycles_start);
    //NVDLA is handled separately... We assume FFT and Viterbi terminate only after NVDLA
    while (!(done_f1 && done_f2 && done_f3 && done_v1 && done_v2)) {
		if(!done_f1) {
        		done_f1 = ioread32(dev_f1, STATUS_REG);
			done_f1 &= STATUS_MASK_DONE;
		}
		if(!done_f2) {
        		done_f2 = ioread32(dev_f2, STATUS_REG);
			done_f2 &= STATUS_MASK_DONE;
		}
		if(!done_f3) {
        		done_f3 = ioread32(dev_f3, STATUS_REG);
			done_f3 &= STATUS_MASK_DONE;
		}
		if(!done_v1) {
        		done_v1 = ioread32(dev_v1, STATUS_REG);
			done_v1 &= STATUS_MASK_DONE;
		}
		if(!done_v2) {
        		done_v2 = ioread32(dev_v2, STATUS_REG);
			done_v2 &= STATUS_MASK_DONE;
		}

		if(done_f1 && !done_f1_before) {
			cycles_end_f1 = get_counter();
			espdev = &espdevs[1];
			write_config1(espdev, 0, random_rate_const, 0, 0);
			done_f1_before=done_f1;
    			#ifdef DEBUG
				printf("Finished F1\n");
    			#endif
		}
		if(done_v1 && !done_v1_before) {
			cycles_end_v1 = get_counter();
			espdev = &espdevs[2];
			write_config1(espdev, 0, random_rate_const, 0, 0);
			done_v1_before=done_v1;
    			#ifdef DEBUG
				printf("Finished V1\n");
    			#endif
		}
		if(done_f2 && !done_f2_before) {
			cycles_end_f2 = get_counter();
			espdev = &espdevs[3];
			write_config1(espdev, 0, random_rate_const, 0, 0);
			done_f2_before=done_f2;
    			#ifdef DEBUG
				printf("Finished F2\n");
    			#endif
		}
		if(done_v2 && !done_v2_before) {
			cycles_end_v2 = get_counter();
			espdev = &espdevs[4];
			write_config1(espdev, 0, random_rate_const, 0, 0);
			done_v2_before=done_v2;
    			#ifdef DEBUG
				printf("Finished V2\n");
    			#endif
		}
		if(done_f3 && !done_f3_before) {
			cycles_end_f3 = get_counter();
			espdev = &espdevs[5];
			write_config1(espdev, 0, random_rate_const, 0, 0);
			done_f3_before=done_f3;
    			#ifdef DEBUG
				printf("Finished F3\n");
    			#endif
		}
    }
	
	printf("  Done\n");
	printf("  Viterbi Execution cycles : v1=%llu, v2=%llu\n", cycles_end_v1 - cycles_start,cycles_end_v2 - cycles_start);
	printf("  FFT Execution cycles : f1=%llu, f2=%llu, f3=%llu\n", cycles_end_f1 - cycles_start,cycles_end_f2 - cycles_start,cycles_end_f3 - cycles_start);

	
    printf("  validating...\n");

    // Validation Viterbi
    errors = vit_validate_buf(&mem_v1[out_offset], gold_vit);
    if (errors)
        printf("  ... FAIL Viterbi\n");
    else
        printf("  ... PASS Viterbi\n");

    // Validation FFT
	errors = fft_validate_buf(&mem_f1[out_offset], gold_fft);
	if ((errors / len) > ERROR_COUNT_TH)
	     printf("  ... FAIL FFT\n");
	 else
	     printf("  ... PASS FFT\n");


#endif

    return 0;
}
