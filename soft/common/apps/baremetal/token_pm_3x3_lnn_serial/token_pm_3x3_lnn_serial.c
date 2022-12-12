/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>
#include "token_pm_3x3.h"
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

	//Set NoC LDO to 800Mz - exact value is 800.9MHz 
	 #ifdef DEBUG
	 	 printf("Set NoC RO\n");
	 #endif
	unsigned int* noc_dco_ptr = (unsigned int *) 0x600903CC;
	*noc_dco_ptr = 0x5000D;
	//Set CPU to 800Mz - exact value is 800.9MHz 
	unsigned int* cpu_dco_ptr = (unsigned int *) 0x600901C8;
	*cpu_dco_ptr = 0x5000D;


#ifdef TEST_4

//Test running all viterbi, NVDLA and FFT tiles
   struct esp_device *espdevs_fft, *espdevs_viterbi, *espdevs_nvdla;
   //fft_token_t *mem_f0, *mem_f1, *mem_f2;
   //fft_token_t *gold_fft;

   unsigned errors = 0;
   unsigned LOGLEN;
   unsigned coherence = ACC_COH_RECALL;
   const int ERROR_COUNT_TH = 0.001;
   uint64_t cycles_start = 0, cycles_end = 0; 
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

       write_config0(espdev, enable_const, max_tokens_vc707[i], refresh_rate_min_const-i, refresh_rate_max_const-i);
   }


	
	struct esp_device *dev_fft1 = aligned_malloc(sizeof(struct esp_device));
	unsigned is_running_fft1=0, cycles_end_fft1=0, done_fft1=0, done_fft1_before=0;
	unsigned **ptable_fft1 = NULL;
	fft_token_t *mem_fft1;
	struct esp_device *dev_fft2 = aligned_malloc(sizeof(struct esp_device));
	unsigned is_running_fft2=0, cycles_end_fft2=0, done_fft2=0, done_fft2_before=0;
	unsigned **ptable_fft2 = NULL;
	fft_token_t *mem_fft2;
	struct esp_device *dev_fft0 = aligned_malloc(sizeof(struct esp_device));
	unsigned is_running_fft0=0, cycles_end_fft0=0, done_fft0=0, done_fft0_before=0;
	unsigned **ptable_fft0 = NULL;
	fft_token_t *gold_fft;
	fft_token_t *mem_fft0;
	
	#ifdef DEBUG
		printf("Setting up fft2\n");
	#endif
	LOGLEN = 10;
	mem_size = fft_init_params(LOGLEN);
	dev_fft2->addr = ACC_ADDR_FFT2;
	setup_fft(dev_fft2, gold_fft, mem_fft2, ptable_fft2, LOGLEN);

	#ifdef DEBUG
		printf("Setting up fft0\n");
	#endif
	LOGLEN = 11;
	mem_size = fft_init_params(LOGLEN);
	dev_fft0->addr = ACC_ADDR_FFT0;
	setup_fft(dev_fft0, gold_fft, mem_fft0, ptable_fft0, LOGLEN);

	#ifdef DEBUG
		printf("Setting up fft1\n");
	#endif
	LOGLEN = 9;
	mem_size = fft_init_params(LOGLEN);
	dev_fft1->addr = ACC_ADDR_FFT1;
	setup_fft(dev_fft1, gold_fft, mem_fft1, ptable_fft1, LOGLEN);
	
	if (coherence != ACC_COH_RECALL) 
		esp_flush(coherence, 1);
	
	cycles_start = get_counter();
	#ifdef DEBUG
		printf("Starting fft1\n");
	#endif
	espdev = &espdevs[3];
	is_running_fft1 = 1;
	iowrite32(dev_fft1, CMD_REG, CMD_MASK_START);
	while (!(done_fft1 && done_fft2 && done_fft0)) {
		if (is_running_fft1==1) {
			if(!done_fft1) {
				done_fft1 = ioread32(dev_fft1, STATUS_REG);
				done_fft1 &= STATUS_MASK_DONE;
			}
		}
		if (is_running_fft2==1) {
			if(!done_fft2) {
				done_fft2 = ioread32(dev_fft2, STATUS_REG);
				done_fft2 &= STATUS_MASK_DONE;
			}
		}
		if (is_running_fft0==1) {
			if(!done_fft0) {
				done_fft0 = ioread32(dev_fft0, STATUS_REG);
				done_fft0 &= STATUS_MASK_DONE;
			}
		}
		if ((done_fft1 && !done_fft1_before)) {
			espdev = &espdevs[3];
			is_running_fft1 = 0;
			#ifdef DEBUG
				printf("Finished fft1\n");
			#endif
			#ifdef DEBUG
				printf("Starting fft2\n");
			#endif
			espdev = &espdevs[5];
			is_running_fft2 = 1;
			iowrite32(dev_fft2, CMD_REG, CMD_MASK_START);
		}
		if ((done_fft2 && !done_fft2_before)) {
			espdev = &espdevs[5];
			is_running_fft2 = 0;
			#ifdef DEBUG
				printf("Finished fft2\n");
			#endif
			#ifdef DEBUG
				printf("Starting fft0\n");
			#endif
			espdev = &espdevs[1];
			is_running_fft0 = 1;
			iowrite32(dev_fft0, CMD_REG, CMD_MASK_START);
		}
		
		if (done_fft0 && !done_fft0_before) {
			espdev = &espdevs[1];
			is_running_fft0 = 0;
			#ifdef DEBUG
				printf("Finished fft0\n");
			#endif
		}
	
		done_fft1_before = done_fft1;
		done_fft2_before = done_fft2;
		done_fft0_before = done_fft0;
	
	}
	cycles_end = get_counter();
	printf(" Done\n");
	printf("Total execution cycles: ", cycles_end-cycles_start);
#endif

    return 0;
}
