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
	//Set CPU to 800Mz - exact value is 800.9MHz 

//Test running all tiles
   struct esp_device *espdevs_gemm, *espdevs_viterbi, *espdevs_nvdla;
   struct esp_device *dev_g1 = aligned_malloc(sizeof(struct esp_device));
   struct esp_device *dev_g2 = aligned_malloc(sizeof(struct esp_device));
   struct esp_device *dev_g3 = aligned_malloc(sizeof(struct esp_device));
   struct esp_device *dev_g4 = aligned_malloc(sizeof(struct esp_device));
   struct esp_device *dev_n1 = aligned_malloc(sizeof(struct esp_device));
   struct esp_device *dev_n2 = aligned_malloc(sizeof(struct esp_device));
   struct esp_device *dev_n3 = aligned_malloc(sizeof(struct esp_device));
   struct esp_device *dev_n4 = aligned_malloc(sizeof(struct esp_device));
   struct esp_device *dev_n5 = aligned_malloc(sizeof(struct esp_device));
   struct esp_device *dev_n6 = aligned_malloc(sizeof(struct esp_device));
   struct esp_device *dev_c1 = aligned_malloc(sizeof(struct esp_device));
   struct esp_device *dev_c2 = aligned_malloc(sizeof(struct esp_device));
   struct esp_device *dev_c3 = aligned_malloc(sizeof(struct esp_device));
   unsigned done_all;
   unsigned done_g1=0, done_g2=0, done_g3=0, done_g4= 0, done_g1_before=0, done_g2_before=0, done_g3_before=0, done_g4_before=0;
   unsigned done_n1=0, done_n2=0, done_n3=0, done_n4=0, done_n5=0, done_n6=0, done_n1_before=0, done_n2_before=0, done_n3_before=0, done_n4_before=0, done_n5_before=0, done_n6_before=0;
   unsigned done_c1=0, done_c2=0, done_c3=0, done_c1_before=0, done_c2_before=0, done_c3_before=0;
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
   unsigned errors = 0;
   unsigned coherence = ACC_COH_RECALL;
   const int ERROR_COUNT_TH = 0.001;
   uint64_t cycles_start = 0, cycles_end_n1 = 0,cycles_end_n2 = 0, cycles_end_n3 = 0, cycles_end_n4 = 0, cycles_end_n5 = 0, cycles_end_n6 = 0, cycles_end_g1 = 0, cycles_end_g2 = 0, cycles_end_g3 = 0, cycles_end_g4 = 0, cycles_end_c1 = 0, cycles_end_c2 = 0, cycles_end_c3=0 ;
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
   
   
   // Configure and start PM of all accelerator tiles
   printf("Test 4: Config and start PM of all accelerators\n");
   printf("Clock frequency: 0x%x\n",TOKEN_PM_CONFIG8_REG_DEFAULT);
   //unsigned token_counter_override_vc707[N_ACC] = {0x80, 0xb0}; // {1000 0000 (0), 1011 0000 (48)}    
   //unsigned max_tokens_vc707[N_ACC] = {0, 48};
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
#ifdef TEST_0
   printf("Test0\n");

for (i = 0; i < N_ACC; i++) {
	espdev = &espdevs[i];
    write_config1(espdev, activity_const, random_rate_const, 0, 0);
	}
for (i = 0; i < N_ACC; i++) {
	espdev = &espdevs[i];
    write_config1(espdev, no_activity_const, random_rate_const, 0, 0);
	}
  
#endif

#ifdef TEST_1
   /*
   wait_for_token_next(&espdevs[0], 0);
   wait_for_token_next(&espdevs[1], 48);
   wait_for_token_next(&espdevs[2], 0);
   printf("   --> tokens_next converged\n");

   //Disable tile 0
   espdev = &espdevs[0];
   write_config1(espdev, no_activity_const, random_rate_const, 0, 0);

   //Enable tile 1
   espdev = &espdevs[1];
   write_config1(espdev, activity_const, random_rate_const, 0, 0);

   */
   /// GEMM setup/////
   printf("Setting up GEMM accelerators\n");
   //gemm_probe(&espdevs_gemm);
   //dev_g1=&espdevs_gemm[0];
   dev_g1->addr = ACC_ADDR_GEMM1;
   mem_size=gemm_init_params();
   #ifdef DEBUG
   	printf("GEMM init complete, Mem size=%u\n",mem_size);
   #endif
    
   setup_gemm(dev_g1, mem_g1, ptable_g1, mem_size);
   #ifdef DEBUG
   	printf("GEMM1 setup complete, address=0x%x\n",dev_g1->addr);
   #endif

   dev_g2->addr = ACC_ADDR_GEMM2;
   setup_gemm(dev_g2, mem_g2, ptable_g2, mem_size);
   #ifdef DEBUG
   	printf("GEMM2 setup complete, address=0x%x\n",dev_g2->addr);
   #endif

   dev_g3->addr = ACC_ADDR_GEMM3;
   setup_gemm(dev_g3, mem_g3, ptable_g3, mem_size);
   #ifdef DEBUG
   	printf("GEMM3 setup complete, address=0x%x\n",dev_g3->addr);
   #endif

   dev_g4->addr = ACC_ADDR_GEMM4;
   setup_gemm(dev_g4, mem_g4, ptable_g4, mem_size);
   #ifdef DEBUG
   	printf("GEMM4 setup complete, address=0x%x\n",dev_g4->addr);
   #endif

   printf("GEMM setup complete\n");

    //NV is all set

   ////NV setup/////
   printf("Setting up NV accelerators\n");
    
   dev_n1->addr = ACC_ADDR_NV1;
   setup_nv(dev_n1, mem_n1, ptable_n1);
   #ifdef DEBUG
   	printf("NV1 setup complete, address=0x%x\n",dev_n1->addr);
   #endif

   dev_n2->addr = ACC_ADDR_NV2;
   setup_nv(dev_n2, mem_n2, ptable_n2);
   #ifdef DEBUG
   	printf("NV2 setup complete, address=0x%x\n",dev_n2->addr);
   #endif

   dev_n3->addr = ACC_ADDR_NV3;
   setup_nv(dev_n3, mem_n3, ptable_n3);
   #ifdef DEBUG
   	printf("NV3 setup complete, address=0x%x\n",dev_n3->addr);
   #endif

   dev_n4->addr = ACC_ADDR_NV4;
   setup_nv(dev_n4, mem_n4, ptable_n4);
   #ifdef DEBUG
   	printf("NV4 setup complete, address=0x%x\n",dev_n4->addr);
   #endif

   dev_n5->addr = ACC_ADDR_NV5;
   setup_nv(dev_n5, mem_n5, ptable_n5);
   #ifdef DEBUG
   	printf("NV5 setup complete, address=0x%x\n",dev_n5->addr);
   #endif

   dev_n6->addr = ACC_ADDR_NV6;
   setup_nv(dev_n6, mem_n6, ptable_n6);
   #ifdef DEBUG
   	printf("NV6 setup complete, address=0x%x\n",dev_n6->addr);
   #endif
   printf("NV setup complete\n");

    //NV is all set
	
   ////CONV2D setup/////
   printf("Setting up CONV2D accelerators\n");
   mem_size=conv2d_init_params();
    
   dev_c1->addr = ACC_ADDR_CONV2D1;
   setup_conv2d(dev_c1, mem_c1, ptable_c1, mem_size);
   #ifdef DEBUG
   	printf("CONV2D1 setup complete, address=0x%x\n",dev_c1->addr);
   #endif

   dev_c2->addr = ACC_ADDR_CONV2D2;
   setup_conv2d(dev_c2, mem_c2, ptable_c2, mem_size);
   #ifdef DEBUG
   	printf("CONV2D2 setup complete, address=0x%x\n",dev_c2->addr);
   #endif

   dev_c3->addr = ACC_ADDR_CONV2D3;
   setup_conv2d(dev_c3, mem_c3, ptable_c3, mem_size);
   #ifdef DEBUG
   	printf("CONV2D3 setup complete, address=0x%x\n",dev_c3->addr);
   #endif


    // Flush (customize coherence model here)
    if (coherence != ACC_COH_RECALL)
        esp_flush(coherence, 1);
	
    ///////Start accelerators//////
    printf("Start accelerators\n");
    iowrite32(dev_g1, CMD_REG, CMD_MASK_START);
    //espdev =&espdevs[0];
    //write_config1(espdev, activity_const, random_rate_const_0, 0, 0);
    #ifdef DEBUG
    	printf("Started G1\n");
    #endif
    iowrite32(dev_g2, CMD_REG, CMD_MASK_START);
    //espdev =&espdevs[1];
    //write_config1(espdev, activity_const, random_rate_const, 0, 0);
    #ifdef DEBUG
    	printf("Started G2\n");
    #endif
    iowrite32(dev_g3, CMD_REG, CMD_MASK_START);
    //espdev =&espdevs[2];
    //write_config1(espdev, activity_const, random_rate_const, 0, 0);
    #ifdef DEBUG
    	printf("Started G3\n");
    #endif
    iowrite32(dev_g4, CMD_REG, CMD_MASK_START);
    //espdev =&espdevs[3];
    //write_config1(espdev, activity_const, random_rate_const, 0, 0);
    #ifdef DEBUG
    	printf("Started G4\n");
    #endif
    iowrite32(dev_n1, CMD_REG, CMD_MASK_START);
    //espdev =&espdevs[4];
    //write_config1(espdev, activity_const, random_rate_const, 0, 0);
    #ifdef DEBUG
    	printf("Started N1\n");
    #endif
    iowrite32(dev_n2, CMD_REG, CMD_MASK_START);
    //espdev =&espdevs[5];
    //write_config1(espdev, activity_const, random_rate_const, 0, 0);
    #ifdef DEBUG
    	printf("Started N2\n");
    #endif
    iowrite32(dev_n3, CMD_REG, CMD_MASK_START);
    //espdev =&espdevs[6];
    //write_config1(espdev, activity_const, random_rate_const, 0, 0);
    #ifdef DEBUG
    	printf("Started N3\n");
    #endif
    iowrite32(dev_n4, CMD_REG, CMD_MASK_START);
    //espdev =&espdevs[7];
    //write_config1(espdev, activity_const, random_rate_const, 0, 0);
    #ifdef DEBUG
    	printf("Started N4\n");
    #endif
    iowrite32(dev_c1, CMD_REG, CMD_MASK_START);
    //espdev =&espdevs[8];
    //write_config1(espdev, activity_const, random_rate_const, 0, 0);
    #ifdef DEBUG
    	printf("Started C1\n");
    #endif
    iowrite32(dev_c2, CMD_REG, CMD_MASK_START);
    //espdev =&espdevs[9];
    //write_config1(espdev, activity_const, random_rate_const, 0, 0);
    #ifdef DEBUG
    	printf("Started C2\n");
    #endif
    iowrite32(dev_c3, CMD_REG, CMD_MASK_START);
    //espdev =&espdevs[10];
    //write_config1(espdev, activity_const, random_rate_const, 0, 0);
    #ifdef DEBUG
    	printf("Started C3\n");
    #endif
    iowrite32(dev_n5, CMD_REG, CMD_MASK_START);
    //espdev =&espdevs[11];
    //write_config1(espdev, activity_const, random_rate_const, 0, 0);
    #ifdef DEBUG
    	printf("Started N5\n");
    #endif
    //printf("A\n");
    iowrite32(dev_n6, CMD_REG, CMD_MASK_START);
    //espdev =&espdevs[12];
    //write_config1(espdev, activity_const, random_rate_const, 0, 0);
    #ifdef DEBUG
    	printf("Started N6\n");
    #endif

    cycles_start = get_counter();

    ////Wait for them to complete////
    printf("Running all accelerators... Start cycles = %u\n",cycles_start);
    while (!(done_g1 && done_g2 && done_g3 && done_g4 && done_n1 && done_n2 && done_n3 && done_n4 && done_n5 && done_n6 && done_c1 && done_c2 && done_c3)) {
		if(!done_g1) {
        		done_g1 = ioread32(dev_g1, STATUS_REG);
			done_g1 &= STATUS_MASK_DONE;
		}
		if(!done_g2) {
        		done_g2 = ioread32(dev_g2, STATUS_REG);
			done_g2 &= STATUS_MASK_DONE;
		}
		if(!done_g3) {
        		done_g3 = ioread32(dev_g3, STATUS_REG);
			done_g3 &= STATUS_MASK_DONE;
		}
		if(!done_g4) {
        		done_g4 = ioread32(dev_g4, STATUS_REG);
			done_g4 &= STATUS_MASK_DONE;
		}
		if(!done_n1) {
        		done_n1 = ioread32(dev_n1, STATUS_REG);
			done_n1 &= STATUS_MASK_DONE;
		}
		if(!done_n2) {
        		done_n2 = ioread32(dev_n2, STATUS_REG);
			done_n2 &= STATUS_MASK_DONE;
		}
		if(!done_n3) {
        		done_n3 = ioread32(dev_n3, STATUS_REG);
			done_n3 &= STATUS_MASK_DONE;
		}
		if(!done_n4) {
        		done_n4 = ioread32(dev_n4, STATUS_REG);
			done_n4 &= STATUS_MASK_DONE;
		}
		if(!done_c1) {
        		done_c1 = ioread32(dev_c1, STATUS_REG);
			done_c1 &= STATUS_MASK_DONE;
		}
		if(!done_c2) {
        		done_c2 = ioread32(dev_c2, STATUS_REG);
			done_c2 &= STATUS_MASK_DONE;
		}
		if(!done_c3) {
        		done_c3 = ioread32(dev_c3, STATUS_REG);
			done_c3 &= STATUS_MASK_DONE;
		}
		if(!done_n5) {
        		done_n5 = ioread32(dev_n5, STATUS_REG);
			done_n5 &= STATUS_MASK_DONE;
		}
		if(!done_n6) {
        		done_n6 = ioread32(dev_n6, STATUS_REG);
			done_n6 &= STATUS_MASK_DONE;
		}

		if(done_g1 && !done_g1_before) {
			//cycles_end_g1 = get_counter();
			//espdev =&espdevs[0];
			//write_config1(espdev, 0, random_rate_const_0, 0, 0);
			done_g1_before=done_g1;
		}
		if(done_g2 && !done_g2_before) {
			//cycles_end_g2 = get_counter();
			//espdev =&espdevs[1];
			//write_config1(espdev, 0, random_rate_const, 0, 0);
			done_g2_before=done_g2;
		}
		if(done_g3 && !done_g3_before) {
			//cycles_end_g3 = get_counter();
			//espdev =&espdevs[2];
			//write_config1(espdev, 0, random_rate_const, 0, 0);
			done_g3_before=done_g3;
		}
		if(done_g4 && !done_g4_before) {
			//cycles_end_g4 = get_counter();
			//espdev =&espdevs[3];
			//write_config1(espdev, 0, random_rate_const, 0, 0);
			done_g4_before=done_g4;
		}
		if(done_n1 && !done_n1_before) {
			//cycles_end_n1 = get_counter();
			//espdev =&espdevs[4];
			//write_config1(espdev, 0, random_rate_const, 0, 0);
			done_n1_before=done_n1;
		}
		if(done_n2 && !done_n2_before) {
			//cycles_end_n2 = get_counter();
			//espdev =&espdevs[5];
			//write_config1(espdev, 0, random_rate_const, 0, 0);
			done_n2_before=done_n2;
		}
		if(done_n3 && !done_n3_before) {
			//cycles_end_n3 = get_counter();
			//espdev =&espdevs[6];
			//write_config1(espdev, 0, random_rate_const, 0, 0);
			done_n3_before=done_n3;
		}
		if(done_n4 && !done_n4_before) {
			//cycles_end_n4 = get_counter();
			//espdev =&espdevs[7];
			//write_config1(espdev, 0, random_rate_const, 0, 0);
			done_n4_before=done_n4;
		}
		if(done_c1 && !done_c1_before) {
			//cycles_end_c1 = get_counter();
			//espdev =&espdevs[8];
			//write_config1(espdev, 0, random_rate_const, 0, 0);
			done_c1_before=done_c1;
		}
		if(done_c2 && !done_c2_before) {
			//cycles_end_c2 = get_counter();
			//espdev =&espdevs[9];
			//write_config1(espdev, 0, random_rate_const, 0, 0);
			done_c2_before=done_c2;
		}
		if(done_c3 && !done_c3_before) {
			//cycles_end_c3 = get_counter();
			//espdev =&espdevs[10];
			//write_config1(espdev, 0, random_rate_const, 0, 0);
			done_c3_before=done_c3;
		}
		if(done_n5 && !done_n5_before) {
			//cycles_end_n5 = get_counter();
			//espdev =&espdevs[11];
			//write_config1(espdev, 0, random_rate_const, 0, 0);
			done_n5_before=done_n5;
		}
		if(done_n6 && !done_n6_before) {
			//cycles_end_n6 = get_counter();
			//espdev =&espdevs[12];
			//write_config1(espdev, 0, random_rate_const, 0, 0);
			done_n6_before=done_n6;
		}
    }
	
	printf("  Done\n");
	//printf("  Nightvision Execution cycles : n1=%llu, n2=%llu, n3=%llu, n4=%llu, n5=%llu, n6=%llu\n", cycles_end_n1 - cycles_start, cycles_end_n2 - cycles_start, cycles_end_n3 - cycles_start, cycles_end_n4 - cycles_start, cycles_end_n5 - cycles_start, cycles_end_n6 - cycles_start);
	//printf("  GEMM Execution cycles : g1=%llu, g2=%llu, g3=%llu, g4=%llu \n", cycles_end_g1 - cycles_start, cycles_end_g2 - cycles_start, cycles_end_g3 - cycles_start, cycles_end_g4 - cycles_start);
	//printf("  Conv2D Execution cycles : c1=%llu, c2=%llu, c3=%llu\n", cycles_end_c1 - cycles_start, cycles_end_c2 - cycles_start, cycles_end_c3 - cycles_start);

#endif

    return 0;
}
