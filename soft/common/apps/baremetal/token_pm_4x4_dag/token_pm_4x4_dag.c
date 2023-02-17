/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>
#include "token_pm_4x4.h"
#include "token_pm_nv.h"
#include "token_pm_conv2d.h"
#include "token_pm_gemm.h"

int main(int argc, char * argv[])
{
    int i;
    int n;

    static unsigned mem_size;


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
    unsigned int* noc_dco_ptr = (unsigned int *) 0x60091FCC;
    *noc_dco_ptr = 0x5000D;
    unsigned errors = 0;
    unsigned coherence = ACC_COH_RECALL;
    const int ERROR_COUNT_TH = 0.001;

    uint64_t cycles_start = 0, cycles_end = 0; 

    int ndev;
   
   init_consts();
   reset_token_pm(espdevs);

   #ifdef PID_CONFIG
	   write_lut_all(espdevs, lut_data_const_vc707, random_rate_const, no_activity_const);
   #else	   
	   write_lut(espdevs, lut_data_const_vc707_GEMM, random_rate_const_0, no_activity_const,0);    
	   write_lut(espdevs, lut_data_const_vc707_GEMM, random_rate_const, no_activity_const,1);    
	   write_lut(espdevs, lut_data_const_vc707_GEMM, random_rate_const, no_activity_const,2);    
	   write_lut(espdevs, lut_data_const_vc707_GEMM, random_rate_const, no_activity_const,3);    
	   write_lut(espdevs, lut_data_const_vc707_NV, random_rate_const, no_activity_const,4);    
	   write_lut(espdevs, lut_data_const_vc707_NV, random_rate_const, no_activity_const,5);    
	   write_lut(espdevs, lut_data_const_vc707_NV, random_rate_const, no_activity_const,6);    
	   write_lut(espdevs, lut_data_const_vc707_NV, random_rate_const, no_activity_const,7);    
	   write_lut(espdevs, lut_data_const_vc707_CONV2D, random_rate_const, no_activity_const,8);    
	   write_lut(espdevs, lut_data_const_vc707_CONV2D, random_rate_const, no_activity_const,9);    
	   write_lut(espdevs, lut_data_const_vc707_CONV2D, random_rate_const, no_activity_const,10);    
	   write_lut(espdevs, lut_data_const_vc707_NV, random_rate_const, no_activity_const,11);    
	   write_lut(espdevs, lut_data_const_vc707_NV, random_rate_const, no_activity_const,12);    
   #endif
   
   for (i = 0; i < N_ACC; i++) {
       espdev = &espdevs[i];
       write_config2(espdev, neighbors_id_const[i]);
       write_config3(espdev, pm_network_const[i]);
       write_config1(espdev, no_activity_const, random_rate_const, 0, token_counter_override_vc707[i]);
       write_config1(espdev, no_activity_const, random_rate_const, 0, 0);
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

	
	struct esp_device *dev_nv2 = aligned_malloc(sizeof(struct esp_device));
	unsigned is_running_nv2=0, cycles_end_nv2=0, done_nv2=0, done_nv2_before=0;
	unsigned **ptable_nv2 = NULL;
	pixel *mem_nv2;
	struct esp_device *dev_nv1 = aligned_malloc(sizeof(struct esp_device));
	unsigned is_running_nv1=0, cycles_end_nv1=0, done_nv1=0, done_nv1_before=0;
	unsigned **ptable_nv1 = NULL;
	pixel *mem_nv1;
	struct esp_device *dev_conv2d0 = aligned_malloc(sizeof(struct esp_device));
	unsigned is_running_conv2d0=0, cycles_end_conv2d0=0, done_conv2d0=0, done_conv2d0_before=0;
	unsigned **ptable_conv2d0 = NULL;
	conv2d_token_t *gold_conv2d;
	conv2d_token_t *mem_conv2d0;
	struct esp_device *dev_conv2d2 = aligned_malloc(sizeof(struct esp_device));
	unsigned is_running_conv2d2=0, cycles_end_conv2d2=0, done_conv2d2=0, done_conv2d2_before=0;
	unsigned **ptable_conv2d2 = NULL;
	conv2d_token_t *mem_conv2d2;
	struct esp_device *dev_gemm1 = aligned_malloc(sizeof(struct esp_device));
	unsigned is_running_gemm1=0, cycles_end_gemm1=0, done_gemm1=0, done_gemm1_before=0;
	unsigned **ptable_gemm1 = NULL;
	gemm_token_t *mem_gemm1;
	struct esp_device *dev_gemm3 = aligned_malloc(sizeof(struct esp_device));
	unsigned is_running_gemm3=0, cycles_end_gemm3=0, done_gemm3=0, done_gemm3_before=0;
	unsigned **ptable_gemm3 = NULL;
	gemm_token_t *mem_gemm3;
	struct esp_device *dev_gemm0 = aligned_malloc(sizeof(struct esp_device));
	unsigned is_running_gemm0=0, cycles_end_gemm0=0, done_gemm0=0, done_gemm0_before=0;
	unsigned **ptable_gemm0 = NULL;
	gemm_token_t *gold_gemm;
	gemm_token_t *mem_gemm0;
	struct esp_device *dev_conv2d1 = aligned_malloc(sizeof(struct esp_device));
	unsigned is_running_conv2d1=0, cycles_end_conv2d1=0, done_conv2d1=0, done_conv2d1_before=0;
	unsigned **ptable_conv2d1 = NULL;
	conv2d_token_t *mem_conv2d1;
	struct esp_device *dev_nv4 = aligned_malloc(sizeof(struct esp_device));
	unsigned is_running_nv4=0, cycles_end_nv4=0, done_nv4=0, done_nv4_before=0;
	unsigned **ptable_nv4 = NULL;
	pixel *mem_nv4;
	struct esp_device *dev_nv3 = aligned_malloc(sizeof(struct esp_device));
	unsigned is_running_nv3=0, cycles_end_nv3=0, done_nv3=0, done_nv3_before=0;
	unsigned **ptable_nv3 = NULL;
	pixel *mem_nv3;
	struct esp_device *dev_gemm2 = aligned_malloc(sizeof(struct esp_device));
	unsigned is_running_gemm2=0, cycles_end_gemm2=0, done_gemm2=0, done_gemm2_before=0;
	unsigned **ptable_gemm2 = NULL;
	gemm_token_t *mem_gemm2;
	struct esp_device *dev_nv0 = aligned_malloc(sizeof(struct esp_device));
	unsigned is_running_nv0=0, cycles_end_nv0=0, done_nv0=0, done_nv0_before=0;
	unsigned **ptable_nv0 = NULL;
	pixel *gold_nv;
	pixel *mem_nv0;
	struct esp_device *dev_nv5 = aligned_malloc(sizeof(struct esp_device));
	unsigned is_running_nv5=0, cycles_end_nv5=0, done_nv5=0, done_nv5_before=0;
	unsigned **ptable_nv5 = NULL;
	pixel *mem_nv5;
	
   	printf("Setting up accelerators\n");
	mem_size = conv2d_init_params();
	#ifdef DEBUG
		printf("Setting up conv2d0\n");
	#endif
	dev_conv2d0->addr = ACC_ADDR_CONV2D0;
	setup_conv2d(dev_conv2d0, mem_conv2d0, ptable_conv2d0, mem_size);
	#ifdef DEBUG
		printf("Setting up conv2d1\n");
	#endif
	dev_conv2d1->addr = ACC_ADDR_CONV2D1;
	setup_conv2d(dev_conv2d1, mem_conv2d1, ptable_conv2d1, mem_size);
	#ifdef DEBUG
		printf("Setting up conv2d2\n");
	#endif
	dev_conv2d2->addr = ACC_ADDR_CONV2D2;
	setup_conv2d(dev_conv2d2, mem_conv2d2, ptable_conv2d2, mem_size);
	mem_size = gemm_init_params();
	#ifdef DEBUG
		printf("Setting up gemm0\n");
	#endif
	dev_gemm0->addr = ACC_ADDR_GEMM0;
	setup_gemm(dev_gemm0, mem_gemm0, ptable_gemm0, mem_size);
	#ifdef DEBUG
		printf("Setting up gemm1\n");
	#endif
	dev_gemm1->addr = ACC_ADDR_GEMM1;
	setup_gemm(dev_gemm1, mem_gemm1, ptable_gemm1, mem_size);
	#ifdef DEBUG
		printf("Setting up gemm2\n");
	#endif
	dev_gemm2->addr = ACC_ADDR_GEMM2;
	setup_gemm(dev_gemm2, mem_gemm2, ptable_gemm2, mem_size);
	#ifdef DEBUG
		printf("Setting up gemm3\n");
	#endif
	dev_gemm3->addr = ACC_ADDR_GEMM3;
	setup_gemm(dev_gemm3, mem_gemm3, ptable_gemm3, mem_size);
	//mem_size = nv_init_params();
	#ifdef DEBUG
		printf("Setting up nv0\n");
	#endif
	dev_nv0->addr = ACC_ADDR_NV0;
	setup_nv(dev_nv0, mem_nv0, ptable_nv0);
	#ifdef DEBUG
		printf("Setting up nv1\n");
	#endif
	dev_nv1->addr = ACC_ADDR_NV1;
	setup_nv(dev_nv1, mem_nv1, ptable_nv1);
	#ifdef DEBUG
		printf("Setting up nv2\n");
	#endif
	dev_nv2->addr = ACC_ADDR_NV2;
	setup_nv(dev_nv2, mem_nv2, ptable_nv2);
	#ifdef DEBUG
		printf("Setting up nv3\n");
	#endif
	dev_nv3->addr = ACC_ADDR_NV3;
	setup_nv(dev_nv3, mem_nv3, ptable_nv3);
	#ifdef DEBUG
		printf("Setting up nv4\n");
	#endif
	dev_nv4->addr = ACC_ADDR_NV4;
	setup_nv(dev_nv4, mem_nv4, ptable_nv4);
	#ifdef DEBUG
		printf("Setting up nv5\n");
	#endif
	dev_nv5->addr = ACC_ADDR_NV5;
	setup_nv(dev_nv5, mem_nv5, ptable_nv5);
	
	if (coherence != ACC_COH_RECALL) 
		esp_flush(coherence, 1);
	
    	printf("Start accelerators\n");
	cycles_start = get_counter();
	#ifdef DEBUG
		printf("Starting nv2\n");
	#endif
	espdev = &espdevs[6];
	is_running_nv2 = 1;
	iowrite32(dev_nv2, CMD_REG, CMD_MASK_START);
	#ifdef DEBUG
		printf("Starting nv1\n");
	#endif
	espdev = &espdevs[5];
	is_running_nv1 = 1;
	iowrite32(dev_nv1, CMD_REG, CMD_MASK_START);
	#ifdef DEBUG
		printf("Starting conv2d0\n");
	#endif
	espdev = &espdevs[8];
	is_running_conv2d0 = 1;
	iowrite32(dev_conv2d0, CMD_REG, CMD_MASK_START);
	#ifdef DEBUG
		printf("Starting conv2d2\n");
	#endif
	espdev = &espdevs[10];
	is_running_conv2d2 = 1;
	iowrite32(dev_conv2d2, CMD_REG, CMD_MASK_START);
	#ifdef DEBUG
		printf("Starting gemm1\n");
	#endif
	espdev = &espdevs[1];
	is_running_gemm1 = 1;
	iowrite32(dev_gemm1, CMD_REG, CMD_MASK_START);
	while (!(done_nv2 && done_nv1 && done_conv2d0 && done_conv2d2 && done_gemm1 && done_gemm3 && done_gemm0 && done_conv2d1 && done_nv4 && done_nv3 && done_gemm2 && done_nv0 && done_nv5)) {
		if (is_running_nv2==1) {
			if(!done_nv2) {
				done_nv2 = ioread32(dev_nv2, STATUS_REG);
				done_nv2 &= STATUS_MASK_DONE;
			}
		}
		if (is_running_nv1==1) {
			if(!done_nv1) {
				done_nv1 = ioread32(dev_nv1, STATUS_REG);
				done_nv1 &= STATUS_MASK_DONE;
			}
		}
		if (is_running_conv2d0==1) {
			if(!done_conv2d0) {
				done_conv2d0 = ioread32(dev_conv2d0, STATUS_REG);
				done_conv2d0 &= STATUS_MASK_DONE;
			}
		}
		if (is_running_conv2d2==1) {
			if(!done_conv2d2) {
				done_conv2d2 = ioread32(dev_conv2d2, STATUS_REG);
				done_conv2d2 &= STATUS_MASK_DONE;
			}
		}
		if (is_running_gemm1==1) {
			if(!done_gemm1) {
				done_gemm1 = ioread32(dev_gemm1, STATUS_REG);
				done_gemm1 &= STATUS_MASK_DONE;
			}
		}
		if (is_running_gemm3==1) {
			if(!done_gemm3) {
				done_gemm3 = ioread32(dev_gemm3, STATUS_REG);
				done_gemm3 &= STATUS_MASK_DONE;
			}
		}
		if (is_running_gemm0==1) {
			if(!done_gemm0) {
				done_gemm0 = ioread32(dev_gemm0, STATUS_REG);
				done_gemm0 &= STATUS_MASK_DONE;
			}
		}
		if (is_running_conv2d1==1) {
			if(!done_conv2d1) {
				done_conv2d1 = ioread32(dev_conv2d1, STATUS_REG);
				done_conv2d1 &= STATUS_MASK_DONE;
			}
		}
		if (is_running_nv4==1) {
			if(!done_nv4) {
				done_nv4 = ioread32(dev_nv4, STATUS_REG);
				done_nv4 &= STATUS_MASK_DONE;
			}
		}
		if (is_running_nv3==1) {
			if(!done_nv3) {
				done_nv3 = ioread32(dev_nv3, STATUS_REG);
				done_nv3 &= STATUS_MASK_DONE;
			}
		}
		if (is_running_gemm2==1) {
			if(!done_gemm2) {
				done_gemm2 = ioread32(dev_gemm2, STATUS_REG);
				done_gemm2 &= STATUS_MASK_DONE;
			}
		}
		if (is_running_nv0==1) {
			if(!done_nv0) {
				done_nv0 = ioread32(dev_nv0, STATUS_REG);
				done_nv0 &= STATUS_MASK_DONE;
			}
		}
		if (is_running_nv5==1) {
			if(!done_nv5) {
				done_nv5 = ioread32(dev_nv5, STATUS_REG);
				done_nv5 &= STATUS_MASK_DONE;
			}
		}
		if ((done_nv2 && !done_nv2_before)) {
			is_running_nv2 = 0;
			#ifdef DEBUG
				printf("Finished nv2\n");
			#endif
			#ifdef DEBUG
				printf("Starting gemm3\n");
			#endif
			espdev = &espdevs[3];
			is_running_gemm3 = 1;
			iowrite32(dev_gemm3, CMD_REG, CMD_MASK_START);
		}
		if ((done_nv2 && !done_nv2_before) || (done_conv2d1 && !done_conv2d1_before)) {
			if (done_nv2 && done_conv2d1) {
				#ifdef DEBUG
					printf("Starting gemm0\n");
				#endif
				espdev = &espdevs[0];
				is_running_gemm0 = 1;
				iowrite32(dev_gemm0, CMD_REG, CMD_MASK_START);
			}
		}
		if ((done_nv1 && !done_nv1_before)) {
			is_running_nv1 = 0;
			#ifdef DEBUG
				printf("Finished nv1\n");
			#endif
			#ifdef DEBUG
				printf("Starting conv2d1\n");
			#endif
			espdev = &espdevs[9];
			is_running_conv2d1 = 1;
			iowrite32(dev_conv2d1, CMD_REG, CMD_MASK_START);
		}
		if ((done_nv1 && !done_nv1_before)) {
			#ifdef DEBUG
				printf("Starting nv4\n");
			#endif
			espdev = &espdevs[11];
			is_running_nv4 = 1;
			iowrite32(dev_nv4, CMD_REG, CMD_MASK_START);
		}
		if ((done_conv2d0 && !done_conv2d0_before) || (done_conv2d2 && !done_conv2d2_before)) {
			if (done_conv2d0 && !done_conv2d0_before) {
				is_running_conv2d0 = 0;
				#ifdef DEBUG
					printf("Finished conv2d0\n");
				#endif
			}
			if (done_conv2d2 && !done_conv2d2_before) {
				is_running_conv2d2 = 0;
				#ifdef DEBUG
					printf("Finished conv2d2\n");
				#endif
			}
			if (done_conv2d0 && done_conv2d2) {
				#ifdef DEBUG
					printf("Starting nv3\n");
				#endif
				espdev = &espdevs[7];
				is_running_nv3 = 1;
				iowrite32(dev_nv3, CMD_REG, CMD_MASK_START);
			}
		}
		if ((done_conv2d2 && !done_conv2d2_before) || (done_gemm1 && !done_gemm1_before)) {
			if (done_gemm1 && !done_gemm1_before) {
				is_running_gemm1 = 0;
				#ifdef DEBUG
					printf("Finished gemm1\n");
				#endif
			}
			if (done_conv2d2 && done_gemm1) {
				#ifdef DEBUG
					printf("Starting gemm2\n");
				#endif
				espdev = &espdevs[2];
				is_running_gemm2 = 1;
				iowrite32(dev_gemm2, CMD_REG, CMD_MASK_START);
			}
		}
		if ((done_conv2d1 && !done_conv2d1_before)) {
			is_running_conv2d1 = 0;
			#ifdef DEBUG
				printf("Finished conv2d1\n");
			#endif
			#ifdef DEBUG
				printf("Starting nv0\n");
			#endif
			espdev = &espdevs[4];
			is_running_nv0 = 1;
			iowrite32(dev_nv0, CMD_REG, CMD_MASK_START);
		}
		if ((done_conv2d1 && !done_conv2d1_before) || (done_nv3 && !done_nv3_before)) {
			if (done_nv3 && !done_nv3_before) {
				is_running_nv3 = 0;
				#ifdef DEBUG
					printf("Finished nv3\n");
				#endif
			}
			if (done_conv2d1 && done_nv3) {
				#ifdef DEBUG
					printf("Starting nv5\n");
				#endif
				espdev = &espdevs[12];
				is_running_nv5 = 1;
				iowrite32(dev_nv5, CMD_REG, CMD_MASK_START);
			}
		}
		
		if (done_gemm3 && !done_gemm3_before) {
			is_running_gemm3 = 0;
			#ifdef DEBUG
				printf("Finished gemm3\n");
			#endif
		}
		
		if (done_gemm0 && !done_gemm0_before) {
			is_running_gemm0 = 0;
			#ifdef DEBUG
				printf("Finished gemm0\n");
			#endif
		}
		
		if (done_nv4 && !done_nv4_before) {
			is_running_nv4 = 0;
			#ifdef DEBUG
				printf("Finished nv4\n");
			#endif
		}
		
		if (done_gemm2 && !done_gemm2_before) {
			is_running_gemm2 = 0;
			#ifdef DEBUG
				printf("Finished gemm2\n");
			#endif
		}
		
		if (done_nv0 && !done_nv0_before) {
			is_running_nv0 = 0;
			#ifdef DEBUG
				printf("Finished nv0\n");
			#endif
		}
		
		if (done_nv5 && !done_nv5_before) {
			is_running_nv5 = 0;
			#ifdef DEBUG
				printf("Finished nv5\n");
			#endif
		}
	
		done_nv2_before = done_nv2;
		done_nv1_before = done_nv1;
		done_conv2d0_before = done_conv2d0;
		done_conv2d2_before = done_conv2d2;
		done_gemm1_before = done_gemm1;
		done_gemm3_before = done_gemm3;
		done_gemm0_before = done_gemm0;
		done_conv2d1_before = done_conv2d1;
		done_nv4_before = done_nv4;
		done_nv3_before = done_nv3;
		done_gemm2_before = done_gemm2;
		done_nv0_before = done_nv0;
		done_nv5_before = done_nv5;
	
	}
	cycles_end = get_counter();
	printf(" Done\n");
	printf("Total execution cycles: ", cycles_end-cycles_start);
	return 0;
}
