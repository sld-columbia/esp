/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>
#include <fixed_point.h>

#ifndef __NVDLA_MINIMAL_H__
#define __NVDLA_MINIMAL_H__

#define NVDLA_ACC_BASE_ADDR 0x60400000
#define NVDLA_ACC_OFFSET 0x100000
// Set accelerator ID (ACC_TILE_ID) according to the position of the accelerator in the
// SoC. Acc IDs increment from left to right and from top to bottom.
#define NVDLA_ACC_ID 0
#define NVDLA_ACC_ADDR (NVDLA_ACC_BASE_ADDR + (NVDLA_ACC_OFFSET * NVDLA_ACC_ID))

#define NVDLA_CSR_BASE_ADDR 0x60090180
#define NVDLA_CSR_TILE_OFFSET 0x200
#define NVDLA_TILE_ID 2
#define NVDLA_CSR_REG_OFFSET 4
#define NVDLA_CSR_TILE_ADDR (NVDLA_CSR_BASE_ADDR + NVDLA_CSR_TILE_OFFSET * NVDLA_TILE_ID)

#define PLIC_ADDR 0x6c000000
#define PLIC_IP_OFFSET 0x1000
#define PLIC_INTACK_OFFSET 0x200004
#define NVDLA_IRQ 5
#define N_ITER 10	//number of loop iterations for which nvdla is to be run

#define NVDLA_BASE_ADDR NVDLA_ACC_ADDR

#endif /* __NVDLA_MINIMAL_H__ */

typedef unsigned long long int nvdla_token_t;
typedef unsigned long long int nvdla_native_t;
static unsigned i_base;
static unsigned w_base;
static unsigned b_base;
static unsigned o_base;
static unsigned mem_size;
static unsigned out_len;
static unsigned out_size;
static unsigned out_offset;


//static unsigned DMA_WORD_PER_BEAT(unsigned _st)
//{
//    return (sizeof(void *) / _st);
//}

#define MAX_PRINTED_ERRORS 10


#define SLD_NV_NVDLA  0x100
#define NVDLA_DEV_NAME "nvidia,nv_small"


typedef unsigned long long int nvdla_token_t;

static inline uint64_t nvdla_get_counter()
{ 
    uint64_t counter;
    asm volatile (
	"li t0, 0;"
	"csrr t0, mcycle;"
	"mv %0, t0"
	: "=r" ( counter )
	:
	: "t0"
        );
    return counter;
}

static void nvdla_probe(struct esp_device **espdevs_nvdla)
{
    int ndev;

    // Search for the device
    printf("Probing for NVDLA accs, scanning device tree... \n");

    ndev = probe(espdevs_nvdla, VENDOR_SLD, SLD_NV_NVDLA, NVDLA_DEV_NAME);
    if (ndev == 0)
	printf("NVDLA not found\n");
    else
	printf("Found %d NVDLA instances\n",ndev);
}

static int nvdla_validate_buf(nvdla_token_t *out, nvdla_native_t *gold)
{
    int j;
    nvdla_native_t val;
    unsigned errors = 0;

    for (j = 0; j < out_len; j++) {
	val = out[j];

	if (gold[j] != val) {
	    errors++;
	    if (errors <= MAX_PRINTED_ERRORS) {
		printf("%d : %llu : %llu\n", j, val, gold[j]);
	    }
	}
    }

    return errors;
}

static void nvdla_init_buf (nvdla_token_t *in, nvdla_native_t * gold)
{
#include "nvdla_input.h"
#include "nvdla_gold.h"
}

void setup_nvdla(nvdla_token_t *mem,unsigned i_base, unsigned o_base, unsigned b_base, unsigned w_base)
{
        *((unsigned int*) (NVDLA_BASE_ADDR + 28676)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 20484)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 24580)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 16388)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 12292)) = 0;
        int read_val, error_id = 0;
		/*
        read_val = ioread32(&dev, 28672);
        if (read_val != 0)
        printf("error %u\n", error_id);
        error_id++;
        
        read_val = ioread32(&dev, 20480);
        if (read_val != 0)
        printf("error %u\n", error_id);
        error_id++;

        read_val = ioread32(&dev, 24576);
        if (read_val != 0)
        printf("error %u\n", error_id);
        error_id++;

        read_val = ioread32(&dev, 16384);
        if (read_val != 0)
        printf("error %u\n", error_id);
        error_id++;

        read_val = ioread32(&dev, 12288);
        if (read_val != 0)
        printf("error %u\n", error_id);
        error_id++;*/


        *((unsigned int*) (NVDLA_BASE_ADDR + 28684)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 28688)) = 65537;
        *((unsigned int*) (NVDLA_BASE_ADDR + 28692)) = 19;
        *((unsigned int*) (NVDLA_BASE_ADDR + 28696)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 28700)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 28704)) = 16;
        *((unsigned int*) (NVDLA_BASE_ADDR + 28708)) = 32;
        *((unsigned int*) (NVDLA_BASE_ADDR + 28712)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 28716)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 20492)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 24588)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 16396)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 16400)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 16404)) = 327685;
        *((unsigned int*) (NVDLA_BASE_ADDR + 16408)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 16412)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 16416)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 16420)) = 5;
        *((unsigned int*) (NVDLA_BASE_ADDR + 16424)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 16428)) = 262148;
        *((unsigned int*) (NVDLA_BASE_ADDR + 16432)) = 1245184;
        *((unsigned int*) (NVDLA_BASE_ADDR + 16436)) = 504;
        *((unsigned int*) (NVDLA_BASE_ADDR + 16440)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 16444)) = 65537;
        *((unsigned int*) (NVDLA_BASE_ADDR + 16448)) = 19;
        *((unsigned int*) (NVDLA_BASE_ADDR + 16452)) = 3;
        *((unsigned int*) (NVDLA_BASE_ADDR + 16456)) = 5;
        *((unsigned int*) (NVDLA_BASE_ADDR + 16460)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 16464)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 16468)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 16472)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 16476)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 16480)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 12308)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 12312)) = 1048576;
        *((unsigned int*) (NVDLA_BASE_ADDR + 12316)) = 327685;
        *((unsigned int*) (NVDLA_BASE_ADDR + 12320)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 12324)) = 327685;
        *((unsigned int*) (NVDLA_BASE_ADDR + 12332)) = 1;
        *((unsigned int*) (NVDLA_BASE_ADDR + 12336)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 12340)) = ((unsigned) mem) + b_base; // 2686488576
        *((unsigned int*) (NVDLA_BASE_ADDR + 12344)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 12348)) = ((unsigned) mem) + b_base; // 2686488576
        *((unsigned int*) (NVDLA_BASE_ADDR + 12352)) = 48;
        *((unsigned int*) (NVDLA_BASE_ADDR + 12360)) = 288;
        *((unsigned int*) (NVDLA_BASE_ADDR + 12356)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 12364)) = 65537;
        *((unsigned int*) (NVDLA_BASE_ADDR + 12376)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 12380)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 12384)) = 5;
        *((unsigned int*) (NVDLA_BASE_ADDR + 12388)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 12392)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 12396)) = 24;
        *((unsigned int*) (NVDLA_BASE_ADDR + 12400)) = 19;
        *((unsigned int*) (NVDLA_BASE_ADDR + 12404)) = 1;
        *((unsigned int*) (NVDLA_BASE_ADDR + 12408)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 12412)) = ((unsigned) mem) + w_base; // 2686459904
        *((unsigned int*) (NVDLA_BASE_ADDR + 12416)) = 504;
        *((unsigned int*) (NVDLA_BASE_ADDR + 12440)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 12452)) = 1;
        *((unsigned int*) (NVDLA_BASE_ADDR + 12456)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 12460)) = 1;
        *((unsigned int*) (NVDLA_BASE_ADDR + 12464)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 12468)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 12472)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 12476)) = 0;

        //read_val = ioread32(&dev, 36868);
        //if (read_val != 1 && read_val != 65536)
        //    printf("error %u\n", error_id);
        //error_id++;

        //read_val = ioread32(&dev, 32772);
        //if (read_val != 1 && read_val != 65536)
        //    printf("error %u\n", error_id);
        //error_id++;

        *((unsigned int*) (NVDLA_BASE_ADDR + 36868)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 32772)) = 0;

        /*read_val = ioread32(&dev, 4100);
        if (read_val != 0)
        printf("error %u\n", error_id);
        error_id++;*/

        *((unsigned int*) (NVDLA_BASE_ADDR + 4100)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 32880)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 32808)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 32832)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 32856)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 32880)) = 1;
        *((unsigned int*) (NVDLA_BASE_ADDR + 32780)) = 1;
        *((unsigned int*) (NVDLA_BASE_ADDR + 32784)) = 1;
        *((unsigned int*) (NVDLA_BASE_ADDR + 32788)) = 19;
        *((unsigned int*) (NVDLA_BASE_ADDR + 32808)) = 44;
        *((unsigned int*) (NVDLA_BASE_ADDR + 32812)) = ((unsigned) mem) + i_base; // 2686464000
        *((unsigned int*) (NVDLA_BASE_ADDR + 32816)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 32820)) = 32;
        *((unsigned int*) (NVDLA_BASE_ADDR + 32824)) = 32;
        *((unsigned int*) (NVDLA_BASE_ADDR + 32832)) = 49;
        *((unsigned int*) (NVDLA_BASE_ADDR + 32856)) = 49;
        *((unsigned int*) (NVDLA_BASE_ADDR + 36924)) = 1;
        *((unsigned int*) (NVDLA_BASE_ADDR + 36928)) = 1;
        *((unsigned int*) (NVDLA_BASE_ADDR + 36932)) = 19;
        *((unsigned int*) (NVDLA_BASE_ADDR + 36940)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 36936)) = ((unsigned) mem) + o_base; // 2686492672
        *((unsigned int*) (NVDLA_BASE_ADDR + 36944)) = 16;
        *((unsigned int*) (NVDLA_BASE_ADDR + 36948)) = 32;
        *((unsigned int*) (NVDLA_BASE_ADDR + 36952)) = 72;
        *((unsigned int*) (NVDLA_BASE_ADDR + 36956)) = 1;
        *((unsigned int*) (NVDLA_BASE_ADDR + 36964)) = 6145;
        *((unsigned int*) (NVDLA_BASE_ADDR + 36972)) = 83;
        *((unsigned int*) (NVDLA_BASE_ADDR + 36992)) = 83;
        *((unsigned int*) (NVDLA_BASE_ADDR + 37040)) = 1;
        *((unsigned int*) (NVDLA_BASE_ADDR + 37044)) = 1;
        *((unsigned int*) (NVDLA_BASE_ADDR + 37052)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 37056)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 37060)) = 1;
        *((unsigned int*) (NVDLA_BASE_ADDR + 37064)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 36868)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 32772)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 32776)) = 1;
        *((unsigned int*) (NVDLA_BASE_ADDR + 36920)) = 1;
        *((unsigned int*) (NVDLA_BASE_ADDR + 28676)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 20484)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 24580)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 16388)) = 0;
        *((unsigned int*) (NVDLA_BASE_ADDR + 12292)) = 0;

        /*read_val = ioread32(&dev, 12300);
        if (read_val != 1)
        printf("error %u\n", error_id);
        error_id++;*/


        *((unsigned int*) (NVDLA_BASE_ADDR + 28680)) = 1;
        *((unsigned int*) (NVDLA_BASE_ADDR + 20488)) = 1;
        *((unsigned int*) (NVDLA_BASE_ADDR + 24584)) = 1;
        *((unsigned int*) (NVDLA_BASE_ADDR + 16392)) = 1;
        *((unsigned int*) (NVDLA_BASE_ADDR + 12304)) = 1;
}

void run_nvdla(struct esp_device *espdev, struct esp_device *dev, nvdla_token_t *mem, nvdla_native_t *gold, int random_rate_const)
{
    int i;
    int n;
    int ndev;
    struct esp_device coh_dev, plic_dev;
    //nvdla_token_t *mem;
    //nvdla_native_t *gold;
    unsigned errors = 0;
    unsigned coherence;
    unsigned error_id;
    unsigned read_val;
	long time0, time1, time2, time3;

    i_base = 0x200;
    w_base  = 0x000;
    b_base  = 0x280;
    o_base  = 0x400;
    mem_size = 0x500;

    out_len = 12;
    out_size = 12 * sizeof(nvdla_native_t);
    out_offset = o_base / sizeof(nvdla_native_t);


    // Allocation of the accelerator data array (mem) and of the expected output array (gold)
    mem = aligned_malloc(mem_size);
    gold = aligned_malloc(out_size);
    printf("  memory buffer base-address = %p\n", mem);

    nvdla_init_buf(mem, gold);

    // Flush (customize coherence model here)
    coherence = ACC_COH_RECALL;
    coh_dev.addr = NVDLA_CSR_TILE_ADDR;
    iowrite32(&coh_dev, NVDLA_CSR_REG_OFFSET*4, coherence); 

//    if (coherence != ACC_COH_RECALL)
//	esp_flush(coherence, 1);

    // Write the accelerator configuration registers


    //read_val = ioread32(dev, 28676);
    //if (read_val != 1 && read_val != 65536)
    //    printf("error %u\n", error_id);
    //error_id++;


for (int i = 0; i < N_ITER; i++) {

		/*if(i==2)
			{	
			//Here we remove tokens
			int curr_NVDLA_token = 	ioread32(espdev, TOKEN_PM_STATUS0_REG) & TOKEN_NEXT_MASK;
 			printf("Toekn read %u\n", curr_NVDLA_token);
			write_config1(espdev, activity_const, random_rate_const, 0, (1<<7)+curr_NVDLA_token-12); //+total_tokens-total_tokens_ini
			write_config1(espdev, activity_const, random_rate_const, 0, 0);

			}*/

        error_id = 0;

        //read_val = ioread32(dev, 28676);
        //if (read_val != 1 && read_val != 65536)
        //    printf("error %u\n", error_id);
        //error_id++;

        //printf("  start NVDLA\n");
        //time0=nvdla_get_counter();
        setup_nvdla(mem, i_base, o_base, b_base, w_base);
        //time1 = nvdla_get_counter();
        plic_dev.addr = PLIC_ADDR;
        while((ioread32(&plic_dev, PLIC_IP_OFFSET) & 0x40) == 0);
		printf("wait %u\n");
		        //time2 = nvdla_get_counter();

        //printf("Time load: %llu\n", time1 - time0);
       // printf("Time run: %llu\n", time2 - time1);
	/*
        read_val = ioread32(dev, 4100);
        if (read_val != 0)
        printf("error %u\n", error_id);
        error_id++;

        read_val = ioread32(dev, 4108);
        if (read_val != 1376257  && read_val != 2752514)
        printf("error %u\n", error_id);
        error_id++;
        *((unsigned int*) (NVDLA_BASE_ADDR + 4108)) = read_val;

        read_val = ioread32(dev, 4100);
        if (read_val != 0)
        printf("error %u\n", error_id);
        error_id++;

        read_val = ioread32(dev, 4108);
        if (read_val != 0)
        printf("error %u\n", error_id);
        error_id++;
	*/
        iowrite32(&plic_dev, PLIC_INTACK_OFFSET, NVDLA_IRQ + 1);
        iowrite32(&plic_dev, 0x2000, 0x40);
        iowrite32(&plic_dev, 0x18, 0x2);
        ioread32(&plic_dev, PLIC_INTACK_OFFSET);
        /* Validation */
        //errors = validate_buf(&mem[out_offset], gold);

        //if (errors)
        //printf("  ... FAIL\n");
        //else
        //printf("  ... PASS\n");
        //for (int j = 0; j < out_len; j++)
        //    mem[out_offset+j] = 0;
    }

   //aligned_free(mem);
   //aligned_free(gold);
}
