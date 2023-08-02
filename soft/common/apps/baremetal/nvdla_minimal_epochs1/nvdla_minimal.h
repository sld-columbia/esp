/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#ifndef __NVDLA_MINIMAL_H__
#define __NVDLA_MINIMAL_H__

#define ACC_BASE_ADDR 0x60400000
#define ACC_OFFSET 0x100000
// Set accelerator ID (ACC_TILE_ID) according to the position of the accelerator in the
// SoC. Acc IDs increment from left to right and from top to bottom.
#define ACC_ID 1
#define ACC_ADDR (ACC_BASE_ADDR + (ACC_OFFSET * ACC_ID))

#define CSR_BASE_ADDR 0x60090180
#define CSR_TILE_OFFSET 0x200
#define TILE_ID 9
#define CSR_REG_OFFSET 4
#define CSR_TILE_ADDR (CSR_BASE_ADDR + CSR_TILE_OFFSET * TILE_ID)

#define PLIC_ADDR 0x6c000000
#define PLIC_IP_OFFSET 0x1000
#define PLIC_INTACK_OFFSET 0x200004
#define NVDLA_IRQ 5


#define NVDLA_BASE_ADDR ACC_ADDR

#endif /* __NVDLA_MINIMAL_H__ */

typedef unsigned long long int token_t;

static inline uint64_t get_counter()
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

void setup_nvdla(token_t *mem,unsigned i_base, unsigned o_base, unsigned b_base, unsigned w_base)
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
