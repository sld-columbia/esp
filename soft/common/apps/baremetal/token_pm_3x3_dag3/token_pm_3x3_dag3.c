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


	unsigned errors = 0;
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

	
	struct esp_device *dev_fft2 = aligned_malloc(sizeof(struct esp_device));
	unsigned is_running_fft2=0, cycles_end_fft2=0, done_fft2=0, done_fft2_before=0;
	unsigned **ptable_fft2 = NULL;
	fft_token_t *mem_fft2;
	struct esp_device *dev_nvdla0 = aligned_malloc(sizeof(struct esp_device));
	unsigned is_running_nvdla0=0, cycles_end_nvdla0=0, done_nvdla0=0, done_nvdla0_before=0;
	unsigned **ptable_nvdla0 = NULL;
	nvdla_token_t *gold_nvdla;
	nvdla_token_t *mem_nvdla0;
	struct esp_device *dev_viterbi0 = aligned_malloc(sizeof(struct esp_device));
	unsigned is_running_viterbi0=0, cycles_end_viterbi0=0, done_viterbi0=0, done_viterbi0_before=0;
	unsigned **ptable_viterbi0 = NULL;
	viterbi_token_t *gold_viterbi;
	viterbi_token_t *mem_viterbi0;
	struct esp_device *dev_viterbi1 = aligned_malloc(sizeof(struct esp_device));
	unsigned is_running_viterbi1=0, cycles_end_viterbi1=0, done_viterbi1=0, done_viterbi1_before=0;
	unsigned **ptable_viterbi1 = NULL;
	viterbi_token_t *mem_viterbi1;
	struct esp_device *dev_fft1 = aligned_malloc(sizeof(struct esp_device));
	unsigned is_running_fft1=0, cycles_end_fft1=0, done_fft1=0, done_fft1_before=0;
	unsigned **ptable_fft1 = NULL;
	fft_token_t *mem_fft1;
	struct esp_device *dev_fft0 = aligned_malloc(sizeof(struct esp_device));
	unsigned is_running_fft0=0, cycles_end_fft0=0, done_fft0=0, done_fft0_before=0;
	unsigned **ptable_fft0 = NULL;
	fft_token_t *gold_fft;
	fft_token_t *mem_fft0;
	
	#ifdef DEBUG
		printf("Setting up nvdla0\n");
	#endif
	dev_nvdla0->addr = ACC_ADDR_NVDLA0;
	mem_size = viterbi_init_params();
	#ifdef DEBUG
		printf("Setting up viterbi0\n");
	#endif
	dev_viterbi0->addr = ACC_ADDR_VITERBI0;
	setup_viterbi(dev_viterbi0, gold_viterbi, mem_viterbi0, ptable_viterbi0);
	#ifdef DEBUG
		printf("Setting up viterbi1\n");
	#endif
	dev_viterbi1->addr = ACC_ADDR_VITERBI1;
	setup_viterbi(dev_viterbi1, gold_viterbi, mem_viterbi1, ptable_viterbi1);
	mem_size = fft_init_params();
	#ifdef DEBUG
		printf("Setting up fft0\n");
	#endif
	dev_fft0->addr = ACC_ADDR_FFT0;
	setup_fft(dev_fft0, gold_fft, mem_fft0, ptable_fft0);
	#ifdef DEBUG
		printf("Setting up fft1\n");
	#endif
	dev_fft1->addr = ACC_ADDR_FFT1;
	setup_fft(dev_fft1, gold_fft, mem_fft1, ptable_fft1);
	#ifdef DEBUG
		printf("Setting up fft2\n");
	#endif
	dev_fft2->addr = ACC_ADDR_FFT2;
	setup_fft(dev_fft2, gold_fft, mem_fft2, ptable_fft2);
	
	if (coherence != ACC_COH_RECALL) 
		esp_flush(coherence, 1);
	
	cycles_start = get_counter();
	#ifdef DEBUG
		printf("Starting fft2\n");
	#endif
	espdev = &espdevs[5];
	is_running_fft2 = 1;
	iowrite32(dev_fft2, CMD_REG, CMD_MASK_START);
	#ifdef DEBUG
		printf("Starting nvdla0\n");
	#endif
	espdev = &espdevs[0];
	is_running_nvdla0 = 1;
	write_config1(espdev, activity_const, random_rate_const_0, 0, 0);
	run_nvdla(espdev, dev_nvdla0, gold_nvdla, mem_nvdla0, 0);
	#ifdef DEBUG
		printf("Finished nvdla0\n");
	#endif
	write_config1(espdev, 0, random_rate_const_0, 0, 0);
	done_nvdla0 = 1;
	is_running_nvdla0 = 0;
	#ifdef DEBUG
		printf("Starting viterbi0\n");
	#endif
	espdev = &espdevs[2];
	is_running_viterbi0 = 1;
	iowrite32(dev_viterbi0, CMD_REG, CMD_MASK_START);
	while (!(done_fft2 && done_nvdla0 && done_viterbi0 && done_viterbi1 && done_fft1 && done_fft0)) {
		if (is_running_fft2==1) {
			if(!done_fft2) {
				done_fft2 = ioread32(dev_fft2, STATUS_REG);
				done_fft2 &= STATUS_MASK_DONE;
			}
		}
		//if (is_running_nvdla0==1) {
		//	if(!done_nvdla0) {
		//		done_nvdla0 = ioread32(dev_nvdla0, STATUS_REG);
		//		done_nvdla0 &= STATUS_MASK_DONE;
		//	}
		//}
		if (is_running_viterbi0==1) {
			if(!done_viterbi0) {
				done_viterbi0 = ioread32(dev_viterbi0, STATUS_REG);
				done_viterbi0 &= STATUS_MASK_DONE;
			}
		}
		if (is_running_viterbi1==1) {
			if(!done_viterbi1) {
				done_viterbi1 = ioread32(dev_viterbi1, STATUS_REG);
				done_viterbi1 &= STATUS_MASK_DONE;
			}
		}
		if (is_running_fft1==1) {
			if(!done_fft1) {
				done_fft1 = ioread32(dev_fft1, STATUS_REG);
				done_fft1 &= STATUS_MASK_DONE;
			}
		}
		if (is_running_fft0==1) {
			if(!done_fft0) {
				done_fft0 = ioread32(dev_fft0, STATUS_REG);
				done_fft0 &= STATUS_MASK_DONE;
			}
		}
		if ((done_viterbi0 && !done_viterbi0_before) || (done_fft2 && !done_fft2_before)) {
			if (done_viterbi0 && !done_viterbi0_before) {
				espdev = &espdevs[2];
				is_running_viterbi0 = 0;
				#ifdef DEBUG
					printf("Finished viterbi0\n");
				#endif
			}
			if (done_fft2 && !done_fft2_before) {
				espdev = &espdevs[5];
				is_running_fft2 = 0;
				#ifdef DEBUG
					printf("Finished fft2\n");
				#endif
			}
			if (done_viterbi0 && done_fft2) {
				#ifdef DEBUG
					printf("Starting viterbi1\n");
				#endif
				espdev = &espdevs[4];
				is_running_viterbi1 = 1;
				iowrite32(dev_viterbi1, CMD_REG, CMD_MASK_START);
			}
		}
		if ((done_fft2 && !done_fft2_before) || (done_viterbi1 && !done_viterbi1_before)) {
			if (done_viterbi1 && !done_viterbi1_before) {
				espdev = &espdevs[4];
				is_running_viterbi1 = 0;
				#ifdef DEBUG
					printf("Finished viterbi1\n");
				#endif
			}
			if (done_fft2 && done_viterbi1) {
				#ifdef DEBUG
					printf("Starting fft1\n");
				#endif
				espdev = &espdevs[2];
				is_running_fft1 = 1;
				iowrite32(dev_fft1, CMD_REG, CMD_MASK_START);
			}
		}
		if ((done_viterbi1 && !done_viterbi1_before)) {
			#ifdef DEBUG
				printf("Starting fft0\n");
			#endif
			espdev = &espdevs[1];
			is_running_fft0 = 1;
			iowrite32(dev_fft0, CMD_REG, CMD_MASK_START);
		}
		
		if (done_nvdla0 && !done_nvdla0_before) {
		}
		
		if (done_fft1 && !done_fft1_before) {
			espdev = &espdevs[2];
			is_running_fft1 = 0;
			#ifdef DEBUG
				printf("Finished fft1\n");
			#endif
		}
		
		if (done_fft0 && !done_fft0_before) {
			espdev = &espdevs[1];
			is_running_fft0 = 0;
			#ifdef DEBUG
				printf("Finished fft0\n");
			#endif
		}
	
		done_fft2_before = done_fft2;
		done_nvdla0_before = done_nvdla0;
		done_viterbi0_before = done_viterbi0;
		done_viterbi1_before = done_viterbi1;
		done_fft1_before = done_fft1;
		done_fft0_before = done_fft0;
	
	}
	cycles_end = get_counter();
	printf(" Done\n");
	printf("Total execution cycles: ", cycles_end-cycles_start);
	return 0;
}
