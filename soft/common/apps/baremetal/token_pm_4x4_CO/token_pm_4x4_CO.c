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

#ifdef TEST_0
	//Simply puts the token PM in full bypass mode to test the frequency write commands
    	printf("Test 0: Starting\n");
	
	set_freq(&espdevs[0],0xA);
	set_freq(&espdevs[1],0x7);
	set_freq(&espdevs[2],0x3);
	set_freq(&espdevs[3],0x0);
	set_freq(&espdevs[4],0x8);
	set_freq(&espdevs[5],0x4);
	set_freq(&espdevs[6],0xA);
	set_freq(&espdevs[7],0x7);
	set_freq(&espdevs[8],0x3);
	set_freq(&espdevs[9],0x0);
	set_freq(&espdevs[10],0x8);
	set_freq(&espdevs[11],0x4);
	set_freq(&espdevs[12],0x4);

    	printf("Test 0: End\n");

#endif

#ifdef TEST_1
//Test with dummy activity
    	printf("Test 1: Starting\n");
	
	reset_token_pm(espdevs);

	unsigned int sum_max = 0;
	unsigned int tot_activity = 0;
	for (i=0; i<N_ACC; i++)
	{
		start_tile(espdevs, i);
		tot_activity += activity[i];
		printf("Start tile %d, Num active accelerators %d\n", i, tot_activity);
	}

	while (tot_activity != 0)
	{
		tot_activity = 0;
		for (i=0; i<N_ACC; i++)
		{
			end_tile(espdevs, i);
			tot_activity += activity[i];
			printf("End tile %d, Num active accelerators %d\n", i, tot_activity);
		}
	}

#endif

#ifdef TEST_2
	//Test with activity from all tiles 
	//printf("Test 2: Starting\n");
	
	unsigned int sum_max = 0;
	unsigned int tot_activity = 0;

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
   	unsigned coherence = ACC_COH_RECALL;



	/// GEMM setup/////
	printf("Setting up GEMM accelerators\n");
	//gemm_probe(&espdevs_gemm);
	mem_size=gemm_init_params();

	#ifdef DEBUG
		printf("GEMM init complete, Mem size=%u\n",mem_size);
	#endif

	dev_list_acc[0]->addr = ACC_ADDR_GEMM1;
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
	setup_conv2d(dev_list_acc[10], mem_c2, ptable_c3, mem_size);
	#ifdef DEBUG
		printf("CONV2D2 setup complete, address=0x%x\n",dev_list_acc[10]->addr);
	#endif


	//printf("Accelerators setup done\n");
	// Flush (customize coherence model here)
	if (coherence != ACC_COH_RECALL)
		esp_flush(coherence, 1);

	printf("Start accelerators\n");
	///////Start accelerators//////

	for (i=0; i<N_ACC; i++)
	{
		if(i == (N_ACC-1))
    			printf("A\n");
		start_tile(espdevs, i);
		iowrite32(dev_list_acc[i], CMD_REG, CMD_MASK_START);
		tot_activity += 1;
		#ifdef DEBUG
			printf("Start tile %d, Num active accelerators %d\n", i, tot_activity);
		#endif
	}



	while (tot_activity != 0)
	{
		//tot_activity = 0;
		for (i=0; i<N_ACC; i++)
		{
			if(CO_step_checkend(i))
			{
				end_tile(espdevs, i);
				tot_activity -= 1;
				#ifdef DEBUG
					printf("End tile %d, Num active accelerators %d\n", i, tot_activity);
				#endif
			}
		}
	}
	printf("Execution complete\n");
   	aligned_free(dev_list_acc);

#endif


    return 0;
}
