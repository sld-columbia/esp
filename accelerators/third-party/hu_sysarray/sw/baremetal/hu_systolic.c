/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>
#include <fixed_point.h>

////////////////////////////////
// INTRUCTIONS
// - This example app is that bare-metal test application for the
//   gemm_stratus accelerator available in the ESP repository.
// - "TO MODIFY" comments provide instructions on the main parts to be modified.
////////////////////////////////


// TO MODIFY: datatype
//
// This part has the goal of defining 2 datatypes.
// - token_t is the datatype used by the accelerator
// - native_t is the datatype of the inputs and of the expected
//   outputs. It can match the token_t datatype, but in some case for
//   example the data is float, but the accelerator works on fixed
//   point.
// Steps
// - Select between uint, int, fixed-point and float for the token_t datatype
// - Go to the #ifdef corresponding to your datatype and add an entry for
//   your desired bitwidth if not already there. The fixed-point conversion
//   functions used below are implemented in esp/soft/common/drivers/common/include/fixed_point.h
//- Define native_t as needed
//

// Define data type (decomment the one needed)
// #define __UINT
// #define __INT
#define __FIXED
// #define __FLOAT

// Define bit width (decomment the one needed)
#ifndef __riscv
#define BITWIDTH 32
// #define BITWIDTH 64
#else
#define BITWIDTH 32
// #define BITWIDTH 64
#endif

/* End of user defined */

#ifdef __UINT
#if (BITWIDTH == 32)
typedef unsigned token_t;
#elif (BITWIDTH == 64)
typedef long long unsigned token_t;
#endif
#endif

#ifdef __INT
#if (BITWIDTH == 32)
typedef int token_t;
#elif (BITWIDTH == 64)
typedef long long token_t;
#endif
#endif

#ifdef __FIXED
#if (BITWIDTH == 32)
typedef int token_t;
#define fx2float fixed32_to_float
#define float2fx float_to_fixed32
#define FX_IL 16
#elif (BITWIDTH == 64)
typedef long long token_t;
#define fx2float fixed64_to_double
#define float2fx double_to_fixed64
#define FX_IL 32
#endif
#endif

#ifdef __FLOAT
#if (BITWIDTH == 32)
typedef float token_t;
#elif (BITWIDTH == 64)
typedef double token_t;
#endif
#endif

typedef float native_t;


static unsigned DMA_WORD_PER_BEAT(unsigned _st)
{
        return (sizeof(void *) / _st);
}

#define MAX_PRINTED_ERRORS 10


// TO MODIFY: device
// #define <device_id_name> <device_id>
// - device_id_name: is arbitrary and it is only used in one place
//   in the app, as argument for the probe() function call
// - device_id: use device_id specified in the accelerator XML 
// #define DEV_NAME "<vendor>,<acc_name>"
#define HU_SYSARRAY  0x102
#define DEV_NAME "hu,hu_sysarray"


static unsigned in_len1;
static unsigned in_len2;
static unsigned in_len3;
static unsigned out_len;
static unsigned in_size1;
static unsigned in_size2;
static unsigned out_size;
static unsigned out_offset;
static unsigned mem_size;

// TO MODIFY: configuration parameters
// Replace the variables define below with the proper accelerator configuration parameters.
// You can make them constant, or assigned them a value later in the app.
// In the default ESP bare-metal apps they match exactly the accelerator configuration registers.
// W/I/O dimensions


// bias left shift, 
const static bool  IsRelu = 1;
const static int   BiasShift = 6;
const static int   AccumShift = 10;
const static int   AccumMul   = 93;

// base address
const static unsigned w_rd_base = 0x4000;  //Data in in_B.h and in_W.h store here
const static unsigned d_rd_base = 0x8000;  //Data in in_I.h store here 
const static unsigned d_wr_base = 0xC000;  //Output data starting address


//start signal (write only), fire interrupt upon completion 
const static int MWR = 1   //master weight read
const static int MDR = 2   //master input read
const static int MDW = 3 //master input write
const static int START=4  //start systolic array


// TO MODIFY: configuration register offsets
// Replace the following offset for the accelerator registers with the
// ones of your accelerator. The configuration registers are 32-bit
// registers, so the addresses need to be aligned to 4 bytes.
#define Dummy_REG 0x00
#define SA_START 0x04
#define SA_CONFIC 0x08

//base address in DRAM for weight mem, data read mem and data write mem
#define SA_W_RD_BASE 0x0C
#define SA_D_RD_BASE 0x10
#define SA_D_WR_BASE 0x14




// TO MODIFY (maybe): output validation
// Function to validate the accelerator output (in `out`) to the expected output (in `gold`)
// In the default case this results in a simple elementwise comparison of arrays.
// If you need something more complex, please edit the function.
// In case of fixed-point data this function applies a conversion on the accelerator data
// from fixed to float. Please remove it if you don't need it.
static int validate_buf(token_t *out, native_t *gold)
{
	int j;
	native_t val;
	unsigned errors = 0;

        for (j = 0; j < out_len; j++) {
#ifdef __FIXED
	    val = fx2float(out[j], FX_IL);
#else
            val = out[j];
#endif

            if (gold[j] != val) {
                errors++;
                if (errors <= MAX_PRINTED_ERRORS) {
		    printf("%d : %d : %d\n", j, (int) val, (int) gold[j]);
		}
            }
	}

	return errors;
}

// TO MODIFY (maybe): input and expected output initialization
// Inputs and expected outputs are initialized in the input.h and gold.h header files.
// This is to avoid using file IO functions in bare-metal, although it should be possible
// (you can check the riscv-pk and the riscv-tests repositories in esp/soft/ariane/)
// When the accelerator data is fixed-function, there is a conversion of the inputs to fixed-function.
// lease remove it if not needed.
static void init_buf (token_t *in, native_t * gold)
{
    int i;

#include "input_B.h"
#include "input_W.h"
#include "input_I.h"

#ifdef __FIXED
    for (i = 0; i < ninputs * (d1*d2 + d2*d3); i++) {
        in[i] = float2fx(in[i], FX_IL);
    }
#endif

#include "gold.h"
}

int main(int argc, char * argv[])
{
	int i;
	int n;
	int ndev;
	struct esp_device *espdevs;
	struct esp_device *dev;
	unsigned done;
	token_t *mem;
	native_t *gold;
	unsigned errors = 0;
	unsigned coherence;

	// TO MODIFY: non const parameters
	// These are two of the configuration parameters that were not defined as const.
	// Assign a value here to the parameters not defined as const.
	NVUINT32 data=0, data_read=0;
	data += (M-1);  // M_1
    	data += IsRelu << 8;
    	data += BiasShift << 16;
    	data += AccumShift << 20;
    	data += AccumMul << 24;



	// TO MODIFY: offsets in data buffer
	// The accelerator data is contained in a single array, `mem`. Both inputs and outputs.
	// The calculations below define the offsets and length of input and output.
	// You should adapt them to the accelerator to be tested.
	
	
	in_len1 = 32;    // bias
	in_len2 = 32*32; // weight      
	in_len3 = 32*32; // activation
	out_len = 32*32;
	in_size1 = (in_len1+in_len2) * sizeof(token_t);
	in_size2 = (in_len3) * sizeof(token_t);
	out_size = out_len * sizeof(token_t);
	out_offset  = in_size1+in_size2;
	mem_size = (out_offset * sizeof(token_t)) + out_size;

	// Search for the device
	printf("Scanning device tree... \n");

	ndev = probe(&espdevs, VENDOR_SLD, HU_SYSARRAY, DEV_NAME);
	if (ndev == 0) {
		printf("hu_sysarray not found\n");
		return 0;
	}

	for (n = 0; n < ndev; n++) {

		dev = &espdevs[n];

		// TO MODIFY: Allocate memory
		// Allocation of the accelerator data array (mem) and of the expected output array (gold)
		mem = aligned_malloc(mem_size);
		gold = aligned_malloc(out_size);
		printf("  memory buffer base-address = %p\n", mem);
		printf("  memory buffer base-address for gold = %p\n", gold);

		printf("  Generate input...\n");

		init_buf(mem, gold);

		// TO MODIFY: accelerator configuration
		// Write the accelerator configuration registers,
		// by modifying the following iowrite32 calls
		// iowrite32(dev, <reg_offset>, <reg_value>);
		
        iowrite32(dev, SA_CONFIC, data);
        iowrite32(dev, SA_W_RD_BASE, w_rd_base);  
        iowrite32(dev, SA_D_RD_BASE, d_rd_base);
        iowrite32(dev, SA_D_WR_BASE, d_wr_base);

        // Flush (customize coherence model here)
		// Thirdparty accelerators in ESP can currently only do direct memory access,
		// bypassing the cache hierarchy. This operation mode corresponds to the
		// `ACC_COH_NONE` label below. In this case the caches will be flushed before
		// the accelerator execution.
		esp_flush(ACC_COH_NONE);


        done = 0
        printf("  Start Master Inpute (in_I.h) Read\n");
        iowrite32(dev, SA_START, MDR);
        while (!done) {
        done = iointerrupt();  //wait for interrupt
        }
         
        done = 0 
        printf("  Start Master Bias (in_B.h) and Weight (in_W.h) Read\n");
        iowrite32(dev, SA_START, MWR);
        while (!done) {
        done = iointerrupt();  //wait for interrupt
        }

        done = 0
        printf("  Start Computation\n");
        iowrite32(dev, SA_START, START);
        while (!done) {
        done = iointerrupt();  //wait for interrupt
        }


        done = 0
        printf("  Start Master Actication Write\n");
        iowrite32(dev, SA_START, MDW);
        while (!done) {
        done = iointerrupt();  //wait for interrupt
        }



        printf("  Done\n");


		/* Validation */
		printf("  validating...\n");
		errors = validate_buf(&mem[out_offset], gold);

		if (errors)
			printf("  ... FAIL\n");
		else
			printf("  ... PASS\n");

		aligned_free(mem);
		aligned_free(gold);
	}

	return 0;
}
