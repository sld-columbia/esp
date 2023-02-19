/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>
#include "token_pm_4x4_CO.h"

int main(int argc, char * argv[])
{
    int i;
    int n;
    //unsigned config0, config1_v1, config1_v2, config2, config3;
    //unsigned tokens_next0, tokens_next1;
    unsigned acc_tile_pm_csr_addr[N_ACC];
    init_params();

    // setup CSR base addresses
    for (i = 0; i < N_ACC; i++) 
    {   
        acc_tile_pm_csr_addr[i] = CSR_BASE_ADDR + CSR_TILE_OFFSET * acc_tile_ids[i] + CSR_TOKEN_PM_OFFSET;
        espdevs[i].addr = acc_tile_pm_csr_addr[i];
    }   
        reset_token_pm(espdevs);

        unsigned int* noc_dco_ptr = (unsigned int *) 0x60091FCC;
        *noc_dco_ptr = 0x5000D;

	unsigned errors = 0;
	unsigned coherence = ACC_COH_RECALL;
	const int ERROR_COUNT_TH = 0.001;
	uint64_t cycles_start = 0;
	int ndev;
	unsigned int tot_activity = 0;

	
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
	iowrite32(dev_list_acc[6], CMD_REG, CMD_MASK_START);
	start_tile(espdevs, 6);
	tot_activity += 1;
	#ifdef DEBUG
		printf("Started tile nv2, Num active accelerators %d\n", tot_activity);
	#endif
	is_running_nv1 = 1;
	iowrite32(dev_list_acc[5], CMD_REG, CMD_MASK_START);
	start_tile(espdevs, 5);
	tot_activity += 1;
	#ifdef DEBUG
		printf("Started tile nv1, Num active accelerators %d\n", tot_activity);
	#endif
	is_running_conv2d0 = 1;
	iowrite32(dev_list_acc[8], CMD_REG, CMD_MASK_START);
	start_tile(espdevs, 8);
	tot_activity += 1;
	#ifdef DEBUG
		printf("Started tile conv2d0, Num active accelerators %d\n", tot_activity);
	#endif
	is_running_conv2d2 = 1;
	iowrite32(dev_list_acc[10], CMD_REG, CMD_MASK_START);
	start_tile(espdevs, 10);
	tot_activity += 1;
	#ifdef DEBUG
		printf("Started tile conv2d2, Num active accelerators %d\n", tot_activity);
	#endif
	is_running_gemm1 = 1;
	iowrite32(dev_list_acc[1], CMD_REG, CMD_MASK_START);
	start_tile(espdevs, 1);
	tot_activity += 1;
	#ifdef DEBUG
		printf("Started tile gemm1, Num active accelerators %d\n", tot_activity);
	#endif
	while (tot_activity !=0 ) {
		if (is_running_nv2==1) {
			if(CO_step_checkend(6)) {
				end_tile(espdevs, 6);
				tot_activity -= 1;
				is_running_nv2 = 0;
				#ifdef DEBUG
					printf("End tile nv2, Num active accelerators %d\n", tot_activity);
				#endif
			}
		}
		if (is_running_nv1==1) {
			if(CO_step_checkend(5)) {
				end_tile(espdevs, 5);
				tot_activity -= 1;
				is_running_nv1 = 0;
				#ifdef DEBUG
					printf("End tile nv1, Num active accelerators %d\n", tot_activity);
				#endif
			}
		}
		if (is_running_conv2d0==1) {
			if(CO_step_checkend(8)) {
				end_tile(espdevs, 8);
				tot_activity -= 1;
				is_running_conv2d0 = 0;
				#ifdef DEBUG
					printf("End tile conv2d0, Num active accelerators %d\n", tot_activity);
				#endif
			}
		}
		if (is_running_conv2d2==1) {
			if(CO_step_checkend(10)) {
				end_tile(espdevs, 10);
				tot_activity -= 1;
				is_running_conv2d2 = 0;
				#ifdef DEBUG
					printf("End tile conv2d2, Num active accelerators %d\n", tot_activity);
				#endif
			}
		}
		if (is_running_gemm1==1) {
			if(CO_step_checkend(1)) {
				end_tile(espdevs, 1);
				tot_activity -= 1;
				is_running_gemm1 = 0;
				#ifdef DEBUG
					printf("End tile gemm1, Num active accelerators %d\n", tot_activity);
				#endif
			}
		}
		if (is_running_gemm3==1) {
			if(CO_step_checkend(3)) {
				end_tile(espdevs, 3);
				tot_activity -= 1;
				is_running_gemm3 = 0;
				#ifdef DEBUG
					printf("End tile gemm3, Num active accelerators %d\n", tot_activity);
				#endif
			}
		}
		if (is_running_gemm0==1) {
			if(CO_step_checkend(0)) {
				end_tile(espdevs, 0);
				tot_activity -= 1;
				is_running_gemm0 = 0;
				#ifdef DEBUG
					printf("End tile gemm0, Num active accelerators %d\n", tot_activity);
				#endif
			}
		}
		if (is_running_conv2d1==1) {
			if(CO_step_checkend(9)) {
				end_tile(espdevs, 9);
				tot_activity -= 1;
				is_running_conv2d1 = 0;
				#ifdef DEBUG
					printf("End tile conv2d1, Num active accelerators %d\n", tot_activity);
				#endif
			}
		}
		if (is_running_nv4==1) {
			if(CO_step_checkend(11)) {
				end_tile(espdevs, 11);
				tot_activity -= 1;
				is_running_nv4 = 0;
				#ifdef DEBUG
					printf("End tile nv4, Num active accelerators %d\n", tot_activity);
				#endif
			}
		}
		if (is_running_nv3==1) {
			if(CO_step_checkend(7)) {
				end_tile(espdevs, 7);
				tot_activity -= 1;
				is_running_nv3 = 0;
				#ifdef DEBUG
					printf("End tile nv3, Num active accelerators %d\n", tot_activity);
				#endif
			}
		}
		if (is_running_gemm2==1) {
			if(CO_step_checkend(2)) {
				end_tile(espdevs, 2);
				tot_activity -= 1;
				is_running_gemm2 = 0;
				#ifdef DEBUG
					printf("End tile gemm2, Num active accelerators %d\n", tot_activity);
				#endif
			}
		}
		if (is_running_nv0==1) {
			if(CO_step_checkend(4)) {
				end_tile(espdevs, 4);
				tot_activity -= 1;
				is_running_nv0 = 0;
				#ifdef DEBUG
					printf("End tile nv0, Num active accelerators %d\n", tot_activity);
				#endif
			}
		}
		if (is_running_nv5==1) {
			if(CO_step_checkend(12)) {
				end_tile(espdevs, 12);
				tot_activity -= 1;
				is_running_nv5 = 0;
				#ifdef DEBUG
					printf("End tile nv5, Num active accelerators %d\n", tot_activity);
				#endif
			}
		}
		if ((done[6] && !done_before[6])) {
			is_running_gemm3 = 1;
			iowrite32(dev_list_acc[3], CMD_REG, CMD_MASK_START);
			start_tile(espdevs, 3);
			tot_activity += 1;
			#ifdef DEBUG
				printf("Started tile gemm3, Num active accelerators %d\n", tot_activity);
			#endif
		}
		if ((done[6] && !done_before[6]) || (done[9] && !done_before[9])) {
			if (done[6] && done[9]) {
				is_running_gemm0 = 1;
				iowrite32(dev_list_acc[0], CMD_REG, CMD_MASK_START);
				start_tile(espdevs, 0);
				tot_activity += 1;
				#ifdef DEBUG
					printf("Started tile gemm0, Num active accelerators %d\n", tot_activity);
				#endif
			}
		}
		if ((done[5] && !done_before[5])) {
			is_running_conv2d1 = 1;
			iowrite32(dev_list_acc[9], CMD_REG, CMD_MASK_START);
			start_tile(espdevs, 9);
			tot_activity += 1;
			#ifdef DEBUG
				printf("Started tile conv2d1, Num active accelerators %d\n", tot_activity);
			#endif
		}
		if ((done[5] && !done_before[5])) {
			is_running_nv4 = 1;
			iowrite32(dev_list_acc[11], CMD_REG, CMD_MASK_START);
			start_tile(espdevs, 11);
			tot_activity += 1;
			#ifdef DEBUG
				printf("Started tile nv4, Num active accelerators %d\n", tot_activity);
			#endif
		}
		if ((done[8] && !done_before[8]) || (done[10] && !done_before[10])) {
			if (done[8] && done[10]) {
				is_running_nv3 = 1;
				iowrite32(dev_list_acc[7], CMD_REG, CMD_MASK_START);
				start_tile(espdevs, 7);
				tot_activity += 1;
				#ifdef DEBUG
					printf("Started tile nv3, Num active accelerators %d\n", tot_activity);
				#endif
			}
		}
		if ((done[10] && !done_before[10]) || (done[1] && !done_before[1])) {
			if (done[10] && done[1]) {
				is_running_gemm2 = 1;
				iowrite32(dev_list_acc[2], CMD_REG, CMD_MASK_START);
				start_tile(espdevs, 2);
				tot_activity += 1;
				#ifdef DEBUG
					printf("Started tile gemm2, Num active accelerators %d\n", tot_activity);
				#endif
			}
		}
		if ((done[9] && !done_before[9])) {
			is_running_nv0 = 1;
			iowrite32(dev_list_acc[4], CMD_REG, CMD_MASK_START);
			start_tile(espdevs, 4);
			tot_activity += 1;
			#ifdef DEBUG
				printf("Started tile nv0, Num active accelerators %d\n", tot_activity);
			#endif
		}
		if ((done[9] && !done_before[9]) || (done[7] && !done_before[7])) {
			if (done[9] && done[7]) {
				is_running_nv5 = 1;
				iowrite32(dev_list_acc[12], CMD_REG, CMD_MASK_START);
				start_tile(espdevs, 12);
				tot_activity += 1;
				#ifdef DEBUG
					printf("Started tile nv5, Num active accelerators %d\n", tot_activity);
				#endif
			}
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
	}
	aligned_free(dev_list_acc);
	printf("Execution complete\n");
	return 0;
}
