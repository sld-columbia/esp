/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>
#include "token_pm_3x3_CRR.h"
#include "token_pm_3x3_Ccommon.h"
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
	
   struct esp_device *dev_n1 = aligned_malloc(sizeof(struct esp_device));
   struct esp_device *dev_f1 = aligned_malloc(sizeof(struct esp_device));
   struct esp_device *dev_f2 = aligned_malloc(sizeof(struct esp_device));
   struct esp_device *dev_f3 = aligned_malloc(sizeof(struct esp_device));
   struct esp_device *dev_v1 = aligned_malloc(sizeof(struct esp_device));
   struct esp_device *dev_v2 = aligned_malloc(sizeof(struct esp_device));	
	struct esp_device **dev_list[N_ACC]={dev_n0,dev_f1,dev_v1,dev_f2,dev_v2,dev_f3};
	
#endif


    return 0;
}
