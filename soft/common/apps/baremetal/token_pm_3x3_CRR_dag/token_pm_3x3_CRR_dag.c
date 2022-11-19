/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>
#include "token_pm_3x3_CRR.h"

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

	//Test with activity from all tiles 
	printf("Starting TB\n");

	unsigned int sum_max = 0;
	unsigned int tot_activity = 0;

	unsigned errors = 0;
	unsigned coherence = ACC_COH_RECALL;
	const int ERROR_COUNT_TH = 0.001;
	uint64_t cycles_start = 0; 
	int ndev, i_run, i_idl;

	unsigned cycles_end_fft0=0;
	unsigned **ptable_fft0 = NULL;
	fft_token_t *gold_fft;
	fft_token_t *mem_fft0;
	unsigned cycles_end_nvdla0=0;
	//unsigned **ptable_nvdla0 = NULL;
	//nvdla_token_t *mem_nvdla0;
	unsigned cycles_end_fft1=0;
	unsigned **ptable_fft1 = NULL;
	fft_token_t *mem_fft1;
	unsigned cycles_end_viterbi0=0;
	unsigned **ptable_viterbi0 = NULL;
	viterbi_token_t *gold_viterbi;
	viterbi_token_t *mem_viterbi0;
	unsigned cycles_end_viterbi1=0;
	unsigned **ptable_viterbi1 = NULL;
	viterbi_token_t *mem_viterbi1;
	unsigned cycles_end_fft2=0;
	unsigned **ptable_fft2 = NULL;
	fft_token_t *mem_fft2;
	
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
	is_running[1] = 1;
	start_tile(1);
	#ifdef DEBUG
		printf("Started tile fft0\n");
	#endif
	is_running[0] = 1;
	write_config1(&espdevs[0], 1, 0, 0, 0);
	#ifdef DEBUG
		printf("Started tile nvdla0\n");
	#endif
	start_tile(0);
	//write_config1(&espdevs[0], 0, 0, 0, 0);
	//set_freq(&espdevs[0],Fmin[0]);
	done[0] = 1;
	is_running[0] = 0;
	#ifdef DEBUG
		printf("Finished tile nvdla0\n");
	#endif

	while((head_run != NULL) ||(head_idle != NULL) ||(head_wait != NULL) ) {
		if (is_running[1] == 1) {
			done[1] = ioread32(dev_list_acc[1], STATUS_REG);
			done[1] &= STATUS_MASK_DONE;
		}
		if (is_running[3] == 1) {
			done[3] = ioread32(dev_list_acc[3], STATUS_REG);
			done[3] &= STATUS_MASK_DONE;
		}
		if (is_running[2] == 1) {
			done[2] = ioread32(dev_list_acc[2], STATUS_REG);
			done[2] &= STATUS_MASK_DONE;
		}
		if (is_running[4] == 1) {
			done[4] = ioread32(dev_list_acc[4], STATUS_REG);
			done[4] &= STATUS_MASK_DONE;
		}
		if (is_running[5] == 1) {
			done[5] = ioread32(dev_list_acc[5], STATUS_REG);
			done[5] &= STATUS_MASK_DONE;
		}
		if ((done[1] && !done_before[1])) {
			is_running[1] = 0;
			set_freq(&espdevs[1],Fmin[1]);
			i_run=removeFromList(&head_run,1);
			i_idl=removeFromList(&head_idle,1);
			if(i_run) {
				p_available=p_available+Pmax[1];
			}
			else if(i_idl) {
				p_available=p_available+Pmin[1];
			}
			#ifdef DEBUG
				printf("Finished tile 1 was in %u%u new Pav %u\n",i_run,i_idl, p_available);
			#endif
			is_running[3] = 1;
			start_tile(3);
			#ifdef DEBUG
				printf("Started tile fft1\n");
			#endif
		}
		if ((done[1] && !done_before[1])) {
			is_running[2] = 1;
			start_tile(2);
			#ifdef DEBUG
				printf("Started tile viterbi0\n");
			#endif
		}
		if ((done[0] && !done_before[0])) {
			is_running[4] = 1;
			start_tile(4);
			#ifdef DEBUG
				printf("Started tile viterbi1\n");
			#endif
		}
		if ((done[4] && !done_before[4]) || (done[3] && !done_before[3])) {
			if (done[4] && !done_before[4]) {
				is_running[4] = 0;
				set_freq(&espdevs[4],Fmin[4]);
				i_run=removeFromList(&head_run,4);
				i_idl=removeFromList(&head_idle,4);
				if(i_run) {
					p_available=p_available+Pmax[4];
				}
				else if(i_idl) {
					p_available=p_available+Pmin[4];
				}
				#ifdef DEBUG
					printf("Finished tile 4 was in %u%u new Pav %u\n",i_run,i_idl, p_available);
				#endif
			}
			if (done[3] && !done_before[3]) {
				is_running[3] = 0;
				set_freq(&espdevs[3],Fmin[3]);
				i_run=removeFromList(&head_run,3);
				i_idl=removeFromList(&head_idle,3);
				if(i_run) {
					p_available=p_available+Pmax[3];
				}
				else if(i_idl) {
					p_available=p_available+Pmin[3];
				}
				#ifdef DEBUG
					printf("Finished tile 3 was in %u%u new Pav %u\n",i_run,i_idl, p_available);
				#endif
			}
			if (done[4] && done[3]) {
				is_running[5] = 1;
				start_tile(5);
				#ifdef DEBUG
					printf("Started tile fft2\n");
				#endif
			}
		}
		
		if (done[2] && !done_before[2]) {
			is_running[2] = 0;
			set_freq(&espdevs[2],Fmin[2]);
			i_run=removeFromList(&head_run,2);
			i_idl=removeFromList(&head_idle,2);
			if(i_run) {
				p_available=p_available+Pmax[2];
			}
			else if(i_idl) {
				p_available=p_available+Pmin[2];
			}
			#ifdef DEBUG
				printf("Finished tile 2 was in %u%u new Pav %u\n",i_run,i_idl, p_available);
			#endif
		}
		
		if (done[5] && !done_before[5]) {
			is_running[5] = 0;
			set_freq(&espdevs[5],Fmin[5]);
			i_run=removeFromList(&head_run,5);
			i_idl=removeFromList(&head_idle,5);
			if(i_run) {
				p_available=p_available+Pmax[5];
			}
			else if(i_idl) {
				p_available=p_available+Pmin[5];
			}
			#ifdef DEBUG
				printf("Finished tile 5 was in %u%u new Pav %u\n",i_run,i_idl, p_available);
			#endif
		}
	
		done_before[1] = done[1];
		done_before[0] = done[0];
		done_before[3] = done[3];
		done_before[2] = done[2];
		done_before[4] = done[4];
		done_before[5] = done[5];
		
		CRR_step_rotate();
	}
	aligned_free(dev_list_acc);
	printf("Execution complete\n");
	return 0;
}
