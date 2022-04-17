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
	printf("Test 2: Starting\n");
	
	unsigned int sum_max = 0;
	unsigned int tot_activity = 0;

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

	unsigned **ptable_f1 = NULL;
	unsigned **ptable_f2 = NULL;
	unsigned **ptable_f3 = NULL;
	unsigned **ptable_v1 = NULL;
	unsigned **ptable_v2 = NULL;


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

	printf("Accelerators setup done\n");
	// Flush (customize coherence model here)
	if (coherence != ACC_COH_RECALL)
		esp_flush(coherence, 1);

	//printf("Start accelerators\n");
	///////Start accelerators//////

	for (i=1; i<N_ACC; i++)
	{
		iowrite32(dev_list_acc[i], CMD_REG, CMD_MASK_START);
		start_tile(espdevs, i);
		tot_activity += 1;
		printf("Start tile %d, Num active accelerators %d\n", i, tot_activity);
	}


	//Start NVDLA
	start_tile(espdevs, 0);
	run_nvdla( &espdevs[0], dev_list_acc[0], gold_nvdla, mem_n1, 0, &tot_activity);
	//tot_activity += activity[0];
	//Wait for NVDLA done
	write_config1(&espdevs[0], 0, 0, 0, 0);
	end_tile(espdevs, 0);
    	//printf("NVDLA done, total activity is now: %d\n", tot_activity);

	//set_freq(&espdevs[0],Fmin[0]);
	//#ifdef DEBUG
	printf("Finished N1\n");
	//#endif

	while (tot_activity != 0)
	{
		//tot_activity = 0;
		for (i=1; i<N_ACC; i++)
		{
			if(CO_step_checkend(i))
			{
				end_tile(espdevs, i);
				tot_activity -= 1;
				printf("End tile %d, Num active accelerators %d\n", i, tot_activity);
			}
		}
	}

#endif


    return 0;
}
