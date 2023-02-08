// Copyright (c) 2011-2022 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include <stdio.h>
#include <stdlib.h>
#include <esp_accelerator.h>
#include <esp_probe.h>
int main(int argc, char **argv)
{
	//unsigned int* rst_ptr = (unsigned int *) 0x800907AC;
	//*rst_ptr = 1;
	//printf("Hello from ESP!\n");
//////////////// TEST 0 send CMD0, No Response////////////////	
	//setup_core
	struct esp_device sd_base;
	unsigned read_val;
	sd_base.addr = 0x10000000;
//////////////// TEST 1 Init sequence, with response check ///////////////
//		 CMD 0: reset card					//
//		 CMD 8: get voltage					//
//		 CMD55: indicate next command are application specific  //
//		 ACMD44: get the voltage windows			//
//		 CMD2: CID reg						//
//		 CMD3: get RCA						//
//////////////////////////////////////////////////////////////////////////
	//soft reset
	//*rst_ptr = 0;
	//*rst_ptr = 1;
//////////setup_core///////////////////////////
	//reset core
	iowrite32(&sd_base, 0x28, 0x00000001);
	//setup timeout
	iowrite32(&sd_base, 0x20, 0x000002FF);
	//setup data timeout
	iowrite32(&sd_base, 0x18, 0x00000FFF);
	//setup clock divider
	iowrite32(&sd_base, 0x24, 0x00000000);
	//start core
	iowrite32(&sd_base, 0x28, 0x00000000);
	//enable all cmd_irq
	iowrite32(&sd_base, 0x38, 0x0000001F);
	//enable all data_irq
	iowrite32(&sd_base, 0x40, 0x00000007);
	//set 4-bit bus
	iowrite32(&sd_base, 0x1C, 0x00000001);
////////////////////////////////////////////////
	//send CMD0 reset sdcard
	iowrite32(&sd_base, 0x04, 0x00000000);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	//read_val = ioread32(&sd_base, 0x34);
	//send CMD8 get voltage
	iowrite32(&sd_base, 0x04, 0x00000801);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	//read_val = ioread32(&sd_base, 0x34);
	//send CMD55 inidicate application specific
	iowrite32(&sd_base, 0x04, 0x00003719);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	//read_val = ioread32(&sd_base, 0x34);
	//send ACMD41 get voltage window
	iowrite32(&sd_base, 0x04, 0x00002901);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	//read_val = ioread32(&sd_base, 0x34);
	iowrite32(&sd_base, 0x04, 0x00003719);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00002901);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00003719);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00002901);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00003719);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00002901);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00003719);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00002901);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	
	//send CMD2 CID reg
	iowrite32(&sd_base, 0x04, 0x0000020a);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	//read_val = ioread32(&sd_base, 0x34);
	//send CMD3 get RCA
	iowrite32(&sd_base, 0x04, 0x00000309);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	//read_val = ioread32(&sd_base, 0x34);
	//send CMD7 set card in transfer state
	iowrite32(&sd_base, 0x04, 0x00000709);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	//read_val = ioread32(&sd_base, 0x34);
	//send CMD55 
	iowrite32(&sd_base, 0x04, 0x00003719);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	//read_val = ioread32(&sd_base, 0x34);
	//send CMD6 set bus width
	iowrite32(&sd_base, 0x04, 0x00000619);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	//read_val = ioread32(&sd_base, 0x34);
	//send CMD24 send data
	iowrite32(&sd_base, 0x60, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00001859);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	//read_val = ioread32(&sd_base, 0x34);
	//send CMD17 read data
	iowrite32(&sd_base, 0x3C, 0x00000000);
	iowrite32(&sd_base, 0x60, 0x00000001);
	iowrite32(&sd_base, 0x04, 0x00001139);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	//send CMD12 stop transfer
	iowrite32(&sd_base, 0x3C, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00000C19);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
		
			
/////////////////TEST 2 test send data///////////////////////////////////////
//   		 init card                                                 //
//         	 CMD 7. Put Card in transfer state                         //
//               CMD 55.                                                   //
//               ACMD 6. Set bus width                                     //
//               CMD 24. Send data                                         //
/////////////////////////////////////////////////////////////////////////////
	
	return 0;
}
