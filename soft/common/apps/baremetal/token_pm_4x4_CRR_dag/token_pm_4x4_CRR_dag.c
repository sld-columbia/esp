/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>
#include "token_pm_4x4_CRR.h"
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
	dev_list_acc[i]=aligned_malloc(sizeof(struct esp_device));
    }


    reset_token_pm(espdevs);

    unsigned int* noc_dco_ptr = (unsigned int *) 0x60091FCC;
    *noc_dco_ptr = 0x5000D;

    unsigned errors = 0;
    unsigned coherence = ACC_COH_RECALL;
    const int ERROR_COUNT_TH = 0.001;
    uint64_t cycles_start = 0;
    unsigned int tot_activity = 0;
    int ndev, i_run, i_idl;


	unsigned is_running_nv2=0, cycles_end_nv2=0, done_nv2=0, done_nv2_before=0;
	unsigned **ptable_nv2 = NULL;
	pixel *mem_nv2;
	unsigned is_running_nv1=0, cycles_end_nv1=0, done_nv1=0, done_nv1_before=0;
	unsigned **ptable_nv1 = NULL;
	pixel *mem_nv1;
	unsigned is_running_conv2d0=0, cycles_end_conv2d0=0, done_conv2d0=0, done_conv2d0_before=0;
	unsigned **ptable_conv2d0 = NULL;
	conv2d_token_t *gold_conv2d;
	conv2d_token_t *mem_conv2d0;
	unsigned is_running_conv2d2=0, cycles_end_conv2d2=0, done_conv2d2=0, done_conv2d2_before=0;
	unsigned **ptable_conv2d2 = NULL;
	conv2d_token_t *mem_conv2d2;
	unsigned is_running_gemm1=0, cycles_end_gemm1=0, done_gemm1=0, done_gemm1_before=0;
	unsigned **ptable_gemm1 = NULL;
	gemm_token_t *mem_gemm1;
	unsigned is_running_gemm3=0, cycles_end_gemm3=0, done_gemm3=0, done_gemm3_before=0;
	unsigned **ptable_gemm3 = NULL;
	gemm_token_t *mem_gemm3;
	unsigned is_running_gemm0=0, cycles_end_gemm0=0, done_gemm0=0, done_gemm0_before=0;
	unsigned **ptable_gemm0 = NULL;
	gemm_token_t *gold_gemm;
	gemm_token_t *mem_gemm0;
	unsigned is_running_conv2d1=0, cycles_end_conv2d1=0, done_conv2d1=0, done_conv2d1_before=0;
	unsigned **ptable_conv2d1 = NULL;
	conv2d_token_t *mem_conv2d1;
	unsigned is_running_nv4=0, cycles_end_nv4=0, done_nv4=0, done_nv4_before=0;
	unsigned **ptable_nv4 = NULL;
	pixel *mem_nv4;
	unsigned is_running_nv3=0, cycles_end_nv3=0, done_nv3=0, done_nv3_before=0;
	unsigned **ptable_nv3 = NULL;
	pixel *mem_nv3;
	unsigned is_running_gemm2=0, cycles_end_gemm2=0, done_gemm2=0, done_gemm2_before=0;
	unsigned **ptable_gemm2 = NULL;
	gemm_token_t *mem_gemm2;
	unsigned is_running_nv0=0, cycles_end_nv0=0, done_nv0=0, done_nv0_before=0;
	unsigned **ptable_nv0 = NULL;
	pixel *gold_nv;
	pixel *mem_nv0;
	unsigned is_running_nv5=0, cycles_end_nv5=0, done_nv5=0, done_nv5_before=0;
	unsigned **ptable_nv5 = NULL;
	pixel *mem_nv5;
	
	printf("Set up accelerators\n");
	mem_size = conv2d_init_params();
	#ifdef DEBUG
		printf("Setting up conv2d0\n");
	#endif
	dev_list_acc[8]->addr = ACC_ADDR_CONV2D0;
	setup_conv2d(dev_list_acc[8], mem_conv2d0, ptable_conv2d0, mem_size);
	#ifdef DEBUG
		printf("Setting up conv2d1\n");
	#endif
	dev_list_acc[9]->addr = ACC_ADDR_CONV2D1;
	setup_conv2d(dev_list_acc[9], mem_conv2d1, ptable_conv2d1, mem_size);
	#ifdef DEBUG
		printf("Setting up conv2d2\n");
	#endif
	dev_list_acc[10]->addr = ACC_ADDR_CONV2D2;
	setup_conv2d(dev_list_acc[10], mem_conv2d2, ptable_conv2d2, mem_size);
	mem_size = gemm_init_params();
	#ifdef DEBUG
		printf("Setting up gemm0\n");
	#endif
	dev_list_acc[0]->addr = ACC_ADDR_GEMM0;
	setup_gemm(dev_list_acc[0], mem_gemm0, ptable_gemm0, mem_size);
	#ifdef DEBUG
		printf("Setting up gemm1\n");
	#endif
	dev_list_acc[1]->addr = ACC_ADDR_GEMM1;
	setup_gemm(dev_list_acc[1], mem_gemm1, ptable_gemm1, mem_size);
	#ifdef DEBUG
		printf("Setting up gemm2\n");
	#endif
	dev_list_acc[2]->addr = ACC_ADDR_GEMM2;
	setup_gemm(dev_list_acc[2], mem_gemm2, ptable_gemm2, mem_size);
	#ifdef DEBUG
		printf("Setting up gemm3\n");
	#endif
	dev_list_acc[3]->addr = ACC_ADDR_GEMM3;
	setup_gemm(dev_list_acc[3], mem_gemm3, ptable_gemm3, mem_size);
	#ifdef DEBUG
		printf("Setting up nv0\n");
	#endif
	dev_list_acc[4]->addr = ACC_ADDR_NV0;
	setup_nv(dev_list_acc[4], mem_nv0, ptable_nv0);
	#ifdef DEBUG
		printf("Setting up nv1\n");
	#endif
	dev_list_acc[5]->addr = ACC_ADDR_NV1;
	setup_nv(dev_list_acc[5], mem_nv1, ptable_nv1);
	#ifdef DEBUG
		printf("Setting up nv2\n");
	#endif
	dev_list_acc[6]->addr = ACC_ADDR_NV2;
	setup_nv(dev_list_acc[6], mem_nv2, ptable_nv2);
	#ifdef DEBUG
		printf("Setting up nv3\n");
	#endif
	dev_list_acc[7]->addr = ACC_ADDR_NV3;
	setup_nv(dev_list_acc[7], mem_nv3, ptable_nv3);
	#ifdef DEBUG
		printf("Setting up nv4\n");
	#endif
	dev_list_acc[11]->addr = ACC_ADDR_NV4;
	setup_nv(dev_list_acc[11], mem_nv4, ptable_nv4);
	#ifdef DEBUG
		printf("Setting up nv5\n");
	#endif
	dev_list_acc[12]->addr = ACC_ADDR_NV5;
	setup_nv(dev_list_acc[12], mem_nv5, ptable_nv5);
	
	if (coherence != ACC_COH_RECALL) 
		esp_flush(coherence, 1);
	
	cycles_start = get_counter();
	printf("Start accelerators\n");
	is_running_nv2 = 1;
	start_tile(6);
	#ifdef DEBUG
		printf("Started tile nv2\n");
	#endif
	is_running_nv1 = 1;
	start_tile(5);
	#ifdef DEBUG
		printf("Started tile nv1\n");
	#endif
	is_running_conv2d0 = 1;
	start_tile(8);
	#ifdef DEBUG
		printf("Started tile conv2d0\n");
	#endif
	is_running_conv2d2 = 1;
	start_tile(10);
	#ifdef DEBUG
		printf("Started tile conv2d2\n");
	#endif
	is_running_gemm1 = 1;
	start_tile(1);
	#ifdef DEBUG
		printf("Started tile gemm1\n");
	#endif
	while((head_run != NULL) ||(head_idle != NULL) ||(head_wait != NULL) ) {
		if (is_running_nv2==1) {
			done[6] = ioread32(dev_list_acc[6], STATUS_REG);
			done[6] &= STATUS_MASK_DONE;
		}
		if (is_running_nv1==1) {
			done[5] = ioread32(dev_list_acc[5], STATUS_REG);
			done[5] &= STATUS_MASK_DONE;
		}
		if (is_running_conv2d0==1) {
			done[8] = ioread32(dev_list_acc[8], STATUS_REG);
			done[8] &= STATUS_MASK_DONE;
		}
		if (is_running_conv2d2==1) {
			done[10] = ioread32(dev_list_acc[10], STATUS_REG);
			done[10] &= STATUS_MASK_DONE;
		}
		if (is_running_gemm1==1) {
			done[1] = ioread32(dev_list_acc[1], STATUS_REG);
			done[1] &= STATUS_MASK_DONE;
		}
		if (is_running_gemm3==1) {
			done[3] = ioread32(dev_list_acc[3], STATUS_REG);
			done[3] &= STATUS_MASK_DONE;
		}
		if (is_running_gemm0==1) {
			done[0] = ioread32(dev_list_acc[0], STATUS_REG);
			done[0] &= STATUS_MASK_DONE;
		}
		if (is_running_conv2d1==1) {
			done[9] = ioread32(dev_list_acc[9], STATUS_REG);
			done[9] &= STATUS_MASK_DONE;
		}
		if (is_running_nv4==1) {
			done[11] = ioread32(dev_list_acc[11], STATUS_REG);
			done[11] &= STATUS_MASK_DONE;
		}
		if (is_running_nv3==1) {
			done[7] = ioread32(dev_list_acc[7], STATUS_REG);
			done[7] &= STATUS_MASK_DONE;
		}
		if (is_running_gemm2==1) {
			done[2] = ioread32(dev_list_acc[2], STATUS_REG);
			done[2] &= STATUS_MASK_DONE;
		}
		if (is_running_nv0==1) {
			done[4] = ioread32(dev_list_acc[4], STATUS_REG);
			done[4] &= STATUS_MASK_DONE;
		}
		if (is_running_nv5==1) {
			done[12] = ioread32(dev_list_acc[12], STATUS_REG);
			done[12] &= STATUS_MASK_DONE;
		}
		if ((done[6] && !done_before[6])) {
			is_running_nv2 = 0;
			set_freq(&espdevs[6],Fmin[6]);
			i_run=removeFromList(&head_run,6);
			i_idl=removeFromList(&head_idle,6);
			if(i_run) {
				p_available=p_available+Pmax[6];
			}
			else if(i_idl) {
				p_available=p_available+Pmin[6];
			}
			#ifdef DEBUG
				printf("Finished tile 6 was in %u%u new Pav %u\n",i_run,i_idl, p_available);
			#endif
			is_running_gemm3 = 1;
			start_tile(3);
			#ifdef DEBUG
				printf("Started tile gemm3\n");
			#endif
		}
		if ((done[6] && !done_before[6]) || (done[9] && !done_before[9])) {
			if (done[6] && done[9]) {
				is_running_gemm0 = 1;
				start_tile(0);
				#ifdef DEBUG
					printf("Started tile gemm0\n");
				#endif
			}
		}
		if ((done[5] && !done_before[5])) {
			is_running_nv1 = 0;
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
			is_running_conv2d1 = 1;
			start_tile(9);
			#ifdef DEBUG
				printf("Started tile conv2d1\n");
			#endif
		}
		if ((done[5] && !done_before[5])) {
			is_running_nv4 = 1;
			start_tile(11);
			#ifdef DEBUG
				printf("Started tile nv4\n");
			#endif
		}
		if ((done[8] && !done_before[8]) || (done[10] && !done_before[10])) {
			if (done[8] && !done_before[8]) {
				is_running_conv2d0 = 0;
				set_freq(&espdevs[8],Fmin[8]);
				i_run=removeFromList(&head_run,8);
				i_idl=removeFromList(&head_idle,8);
				if(i_run) {
					p_available=p_available+Pmax[8];
				}
				else if(i_idl) {
					p_available=p_available+Pmin[8];
				}
				#ifdef DEBUG
					printf("Finished tile 8 was in %u%u new Pav %u\n",i_run,i_idl, p_available);
				#endif
			}
			if (done[10] && !done_before[10]) {
				is_running_conv2d2 = 0;
				set_freq(&espdevs[10],Fmin[10]);
				i_run=removeFromList(&head_run,10);
				i_idl=removeFromList(&head_idle,10);
				if(i_run) {
					p_available=p_available+Pmax[10];
				}
				else if(i_idl) {
					p_available=p_available+Pmin[10];
				}
				#ifdef DEBUG
					printf("Finished tile 10 was in %u%u new Pav %u\n",i_run,i_idl, p_available);
				#endif
			}
			if (done[8] && done[10]) {
				is_running_nv3 = 1;
				start_tile(7);
				#ifdef DEBUG
					printf("Started tile nv3\n");
				#endif
			}
		}
		if ((done[10] && !done_before[10]) || (done[1] && !done_before[1])) {
			if (done[1] && !done_before[1]) {
				is_running_gemm1 = 0;
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
			}
			if (done[10] && done[1]) {
				is_running_gemm2 = 1;
				start_tile(2);
				#ifdef DEBUG
					printf("Started tile gemm2\n");
				#endif
			}
		}
		if ((done[9] && !done_before[9])) {
			is_running_conv2d1 = 0;
			set_freq(&espdevs[9],Fmin[9]);
			i_run=removeFromList(&head_run,9);
			i_idl=removeFromList(&head_idle,9);
			if(i_run) {
				p_available=p_available+Pmax[9];
			}
			else if(i_idl) {
				p_available=p_available+Pmin[9];
			}
			#ifdef DEBUG
				printf("Finished tile 9 was in %u%u new Pav %u\n",i_run,i_idl, p_available);
			#endif
			is_running_nv0 = 1;
			start_tile(4);
			#ifdef DEBUG
				printf("Started tile nv0\n");
			#endif
		}
		if ((done[9] && !done_before[9]) || (done[7] && !done_before[7])) {
			if (done[7] && !done_before[7]) {
				is_running_nv3 = 0;
				set_freq(&espdevs[7],Fmin[7]);
				i_run=removeFromList(&head_run,7);
				i_idl=removeFromList(&head_idle,7);
				if(i_run) {
					p_available=p_available+Pmax[7];
				}
				else if(i_idl) {
					p_available=p_available+Pmin[7];
				}
				#ifdef DEBUG
					printf("Finished tile 7 was in %u%u new Pav %u\n",i_run,i_idl, p_available);
				#endif
			}
			if (done[9] && done[7]) {
				is_running_nv5 = 1;
				start_tile(12);
				#ifdef DEBUG
					printf("Started tile nv5\n");
				#endif
			}
		}
		
		if (done[3] && !done_before[3]) {
			is_running_gemm3 = 0;
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
		
		if (done[0] && !done_before[0]) {
			is_running_gemm0 = 0;
			set_freq(&espdevs[0],Fmin[0]);
			i_run=removeFromList(&head_run,0);
			i_idl=removeFromList(&head_idle,0);
			if(i_run) {
				p_available=p_available+Pmax[0];
			}
			else if(i_idl) {
				p_available=p_available+Pmin[0];
			}
			#ifdef DEBUG
				printf("Finished tile 0 was in %u%u new Pav %u\n",i_run,i_idl, p_available);
			#endif
		}
		
		if (done[11] && !done_before[11]) {
			is_running_nv4 = 0;
			set_freq(&espdevs[11],Fmin[11]);
			i_run=removeFromList(&head_run,11);
			i_idl=removeFromList(&head_idle,11);
			if(i_run) {
				p_available=p_available+Pmax[11];
			}
			else if(i_idl) {
				p_available=p_available+Pmin[11];
			}
			#ifdef DEBUG
				printf("Finished tile 11 was in %u%u new Pav %u\n",i_run,i_idl, p_available);
			#endif
		}
		
		if (done[2] && !done_before[2]) {
			is_running_gemm2 = 0;
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
		
		if (done[4] && !done_before[4]) {
			is_running_nv0 = 0;
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
		
		if (done[12] && !done_before[12]) {
			is_running_nv5 = 0;
			set_freq(&espdevs[12],Fmin[12]);
			i_run=removeFromList(&head_run,12);
			i_idl=removeFromList(&head_idle,12);
			if(i_run) {
				p_available=p_available+Pmax[12];
			}
			else if(i_idl) {
				p_available=p_available+Pmin[12];
			}
			#ifdef DEBUG
				printf("Finished tile 12 was in %u%u new Pav %u\n",i_run,i_idl, p_available);
			#endif
		}
	
		done_before[6] = done[6];
		done_before[5] = done[5];
		done_before[8] = done[8];
		done_before[10] = done[10];
		done_before[1] = done[1];
		done_before[3] = done[3];
		done_before[0] = done[0];
		done_before[9] = done[9];
		done_before[11] = done[11];
		done_before[7] = done[7];
		done_before[2] = done[2];
		done_before[4] = done[4];
		done_before[12] = done[12];
		
		CRR_step_rotate();
	}
	aligned_free(dev_list_acc);
	printf("Execution complete\n");
	return 0;
}
