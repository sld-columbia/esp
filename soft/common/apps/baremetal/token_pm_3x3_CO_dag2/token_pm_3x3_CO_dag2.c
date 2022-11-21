/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>
#include "token_pm_3x3_CO.h"

int main(int argc, char * argv[])
{
    int i;
    int n;
    unsigned acc_tile_pm_csr_addr[N_ACC];
    init_params();

    // setup CSR base addresses
    for (i = 0; i < N_ACC; i++) 
    {
	acc_tile_pm_csr_addr[i] = CSR_BASE_ADDR + CSR_TILE_OFFSET * acc_tile_ids[i] + CSR_TOKEN_PM_OFFSET;
	espdevs[i].addr = acc_tile_pm_csr_addr[i];
    }
	reset_token_pm(espdevs);

	//Test with activity from all tiles 
	printf("Starting TB\n");

	unsigned int sum_max = 0;
	unsigned int tot_activity = 0;

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
	uint64_t cycles_start = 0, cycles_end_n1 = 0, cycles_end_f1 = 0,cycles_end_v1 = 0, cycles_end_f2 = 0, cycles_end_v2 = 0, cycles_end_f3 = 0;
	int ndev;



	
	unsigned is_running_fft2=0, cycles_end_fft2=0, done_fft2=0, done_fft2_before=0;
	unsigned **ptable_fft2 = NULL;
	fft_token_t *mem_fft2;
	unsigned is_running_fft1=0, cycles_end_fft1=0, done_fft1=0, done_fft1_before=0;
	unsigned **ptable_fft1 = NULL;
	fft_token_t *mem_fft1;
	unsigned is_running_viterbi0=0, cycles_end_viterbi0=0, done_viterbi0=0, done_viterbi0_before=0;
	unsigned **ptable_viterbi0 = NULL;
	viterbi_token_t *gold_viterbi;
	viterbi_token_t *mem_viterbi0;
	unsigned is_running_fft0=0, cycles_end_fft0=0, done_fft0=0, done_fft0_before=0;
	unsigned **ptable_fft0 = NULL;
	fft_token_t *gold_fft;
	fft_token_t *mem_fft0;
	unsigned is_running_viterbi1=0, cycles_end_viterbi1=0, done_viterbi1=0, done_viterbi1_before=0;
	unsigned **ptable_viterbi1 = NULL;
	viterbi_token_t *mem_viterbi1;
	unsigned is_running_nvdla0=0, cycles_end_nvdla0=0, done_nvdla0=0, done_nvdla0_before=0;
	unsigned **ptable_nvdla0 = NULL;
	nvdla_token_t *gold_nvdla;
	nvdla_token_t *mem_nvdla0;
	
	#ifdef DEBUG
		printf("Setting up nvdla0\n");
	#endif
	dev_list_acc[0]->addr = ACC_ADDR_NVDLA0;
	mem_size = viterbi_init_params();
	#ifdef DEBUG
		printf("Setting up viterbi0\n");
	#endif
	dev_list_acc[2]->addr = ACC_ADDR_VITERBI0;
	setup_viterbi(dev_list_acc[2], gold_viterbi, mem_viterbi0, ptable_viterbi0);
	#ifdef DEBUG
		printf("Setting up viterbi1\n");
	#endif
	dev_list_acc[4]->addr = ACC_ADDR_VITERBI1;
	setup_viterbi(dev_list_acc[4], gold_viterbi, mem_viterbi1, ptable_viterbi1);
	mem_size = fft_init_params();
	#ifdef DEBUG
		printf("Setting up fft0\n");
	#endif
	dev_list_acc[1]->addr = ACC_ADDR_FFT0;
	setup_fft(dev_list_acc[1], gold_fft, mem_fft0, ptable_fft0);
	#ifdef DEBUG
		printf("Setting up fft1\n");
	#endif
	dev_list_acc[3]->addr = ACC_ADDR_FFT1;
	setup_fft(dev_list_acc[3], gold_fft, mem_fft1, ptable_fft1);
	#ifdef DEBUG
		printf("Setting up fft2\n");
	#endif
	dev_list_acc[5]->addr = ACC_ADDR_FFT2;
	setup_fft(dev_list_acc[5], gold_fft, mem_fft2, ptable_fft2);
	
	if (coherence != ACC_COH_RECALL) 
		esp_flush(coherence, 1);
	
	cycles_start = get_counter();
	is_running_fft2 = 1;
	start_tile(espdevs, 5);
	iowrite32(dev_list_acc[5], CMD_REG, CMD_MASK_START);
	tot_activity += 1;
	#ifdef DEBUG
		printf("Started tile fft2, Num active accelerators %d\n", tot_activity);
	#endif
	is_running_fft1 = 1;
	start_tile(espdevs, 3);
	iowrite32(dev_list_acc[3], CMD_REG, CMD_MASK_START);
	tot_activity += 1;
	#ifdef DEBUG
		printf("Started tile fft1, Num active accelerators %d\n", tot_activity);
	#endif
	is_running_viterbi0 = 1;
	start_tile(espdevs, 2);
	iowrite32(dev_list_acc[2], CMD_REG, CMD_MASK_START);
	tot_activity += 1;
	#ifdef DEBUG
		printf("Started tile viterbi0, Num active accelerators %d\n", tot_activity);
	#endif
	while (tot_activity !=0 ) {
		if (is_running_fft2==1) {
			if(CO_step_checkend(5)) {
				end_tile(espdevs, 5);
				tot_activity -= 1;
				is_running_fft2 = 0;
				#ifdef DEBUG
					printf("End tile fft2, Num active accelerators %d\n", tot_activity);
				#endif
			}
		}
		if (is_running_fft1==1) {
			if(CO_step_checkend(3)) {
				end_tile(espdevs, 3);
				tot_activity -= 1;
				is_running_fft1 = 0;
				#ifdef DEBUG
					printf("End tile fft1, Num active accelerators %d\n", tot_activity);
				#endif
			}
		}
		if (is_running_viterbi0==1) {
			if(CO_step_checkend(2)) {
				end_tile(espdevs, 2);
				tot_activity -= 1;
				is_running_viterbi0 = 0;
				#ifdef DEBUG
					printf("End tile viterbi0, Num active accelerators %d\n", tot_activity);
				#endif
			}
		}
		if (is_running_fft0==1) {
			if(CO_step_checkend(1)) {
				end_tile(espdevs, 1);
				tot_activity -= 1;
				is_running_fft0 = 0;
				#ifdef DEBUG
					printf("End tile fft0, Num active accelerators %d\n", tot_activity);
				#endif
			}
		}
		if (is_running_viterbi1==1) {
			if(CO_step_checkend(4)) {
				end_tile(espdevs, 4);
				tot_activity -= 1;
				is_running_viterbi1 = 0;
				#ifdef DEBUG
					printf("End tile viterbi1, Num active accelerators %d\n", tot_activity);
				#endif
			}
		}
		if ((done[2] && !done_before[2])) {
			end_tile(espdevs, 2);
			tot_activity -= 1;
			is_running_viterbi0 = 0;
			#ifdef DEBUG
				printf("End tile viterbi0, Num active accelerators %d\n", tot_activity);
			#endif
			is_running_fft0 = 1;
			start_tile(espdevs, 1);
			iowrite32(dev_list_acc[1], CMD_REG, CMD_MASK_START);
			tot_activity += 1;
			#ifdef DEBUG
				printf("Started tile fft0, Num active accelerators %d\n", tot_activity);
			#endif
		}
		if ((done[3] && !done_before[3]) || (done[5] && !done_before[5])) {
			if (done[3] && !done_before[3]) {
				end_tile(espdevs, 3);
				tot_activity -= 1;
				is_running_fft1 = 0;
				#ifdef DEBUG
					printf("End tile fft1, Num active accelerators %d\n", tot_activity);
				#endif
			}
			if (done[5] && !done_before[5]) {
				end_tile(espdevs, 5);
				tot_activity -= 1;
				is_running_fft2 = 0;
				#ifdef DEBUG
					printf("End tile fft2, Num active accelerators %d\n", tot_activity);
				#endif
			}
			if (done[3] && done[5]) {
				is_running_viterbi1 = 1;
				start_tile(espdevs, 4);
				iowrite32(dev_list_acc[4], CMD_REG, CMD_MASK_START);
				tot_activity += 1;
				#ifdef DEBUG
					printf("Started tile viterbi1, Num active accelerators %d\n", tot_activity);
				#endif
			}
		}
		if ((done[3] && !done_before[3]) || (done[4] && !done_before[4])) {
			if (done[4] && !done_before[4]) {
				end_tile(espdevs, 4);
				tot_activity -= 1;
				is_running_viterbi1 = 0;
				#ifdef DEBUG
					printf("End tile viterbi1, Num active accelerators %d\n", tot_activity);
				#endif
			}
			if (done[3] && done[4]) {
				is_running_nvdla0 = 1;
				start_tile(espdevs, 0);
				write_config1(&espdevs[0], 1, 0, 0, 0);
				run_nvdla(&espdevs[0], dev_list_acc[0], gold_nvdla, mem_nvdla0, 0, &tot_activity);
				#ifdef DEBUG
					printf("Finished nvdla0\n");
				#endif
				write_config1(&espdevs[0], 0, 0, 0, 0);
				done[0] = 1;
				end_tile(espdevs, 0);
				is_running_nvdla0 = 0;
				#ifdef DEBUG
					printf("Started tile nvdla0, Num active accelerators %d\n", tot_activity);
				#endif
			}
		}
		
		if (done[1] && !done_before[1]) {
			end_tile(espdevs, 1);
			tot_activity -= 1;
			is_running_fft0 = 0;
			#ifdef DEBUG
				printf("End tile fft0, Num active accelerators %d\n", tot_activity);
			#endif
		}
		
		done_before[5] = done[5];
		done_before[3] = done[3];
		done_before[2] = done[2];
		done_before[1] = done[1];
		done_before[4] = done[4];
		done_before[0] = done[0];
	}
	aligned_free(dev_list_acc);
	printf("Execution complete\n");
	return 0;
}
