// Copyright (c) 2011-2023 Columbia University, System Level Design Group
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

	//setup_core
	struct esp_device sd_base;
	unsigned read_val;
	sd_base.addr = 0x10000000;

    ////////////////////////////////////////////////////////////////
    //                                                            //
	//  test_send_cmd:                                            //
	//                                                            //
    //  TEST 0: Send CMD0, No Response, All Error check           //   
    //                                                            //
    ////////////////////////////////////////////////////////////////	
	iowrite32(&sd_base, 0x28, 0x00000001);
	iowrite32(&sd_base, 0x20, 0x0000FFFF);
	iowrite32(&sd_base, 0x18, 0x0000FFFF);
	iowrite32(&sd_base, 0x24, 0x00000000);
	iowrite32(&sd_base, 0x28, 0x00000000);
	iowrite32(&sd_base, 0x38, 0x0000001F);
	iowrite32(&sd_base, 0x40, 0x00000007);
	iowrite32(&sd_base, 0x1C, 0x00000001);
	iowrite32(&sd_base, 0x04, 0x00000000);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);

    ////////////////////////////////////////////////////////////////
    //                                                            // 
    //  test_init_sequence:                                       //
    //                                                            //
    //  Test 1: Init sequence, With response check                //
    //  CMD 0. Reset Card                                         //
    //  CMD 8. Get voltage (Only 2.0 Card response to this)       //
    //  CMD55. Indicate Next Command are Application specific     //
    //  ACMD44. Get Voltage windows                               //
    //  CMD2. CID reg                                             //
    //  CMD3. Get RCA.                                            //
    //                                                            //
    ////////////////////////////////////////////////////////////////
	iowrite32(&sd_base, 0x28, 0x00000001);
	iowrite32(&sd_base, 0x20, 0x000002FF);
	iowrite32(&sd_base, 0x18, 0x00000FFF);
	iowrite32(&sd_base, 0x24, 0x00000000);
	iowrite32(&sd_base, 0x28, 0x00000000);
	iowrite32(&sd_base, 0x38, 0x0000001F);
	iowrite32(&sd_base, 0x40, 0x00000007);
	iowrite32(&sd_base, 0x1C, 0x00000001);
	iowrite32(&sd_base, 0x04, 0x00000000);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00000801);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00003719);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00002901);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x0000020A);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00000309);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);

    ////////////////////////////////////////////////////////////////
    //                                                            //
    //  test_send_data                                            //
    //                                                            //
    //  TEST 2: Send data                                         //
    //  init card                                                 //
    //  CMD 7. Put Card in transfer state                         //
    //  CMD 55.                                                   //
    //  ACMD 6. Set bus width                                     //
    //  CMD 24. Send data                                         //
    //                                                            //
    ////////////////////////////////////////////////////////////////
	iowrite32(&sd_base, 0x28, 0x00000001);
	iowrite32(&sd_base, 0x20, 0x000002FF);
	iowrite32(&sd_base, 0x18, 0x00000FFF);
	iowrite32(&sd_base, 0x24, 0x00000000);
	iowrite32(&sd_base, 0x28, 0x00000000);
	iowrite32(&sd_base, 0x38, 0x0000001F);
	iowrite32(&sd_base, 0x40, 0x00000007);
	iowrite32(&sd_base, 0x1C, 0x00000001);
	iowrite32(&sd_base, 0x04, 0x00000000);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00000801);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00003719);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00002901);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x0000020A);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00000309);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00000709);
	iowrite32(&sd_base, 0x00, 0x20000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00003719);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00000619);
	iowrite32(&sd_base, 0x00, 0x00000002);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x60, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00001139);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x3C, 0x00000000);

    ////////////////////////////////////////////////////////////////
    //                                                            //
    //  test_send_rec_data                                        //
    //                                                            // 
    //  TEST 3: Send and receive data                             //
    //  init card                                                 //
    //  setup card for transfer                                   //
    //  CMD 24. Write data                                        //
    //  CMD 17. Read data                                         //
    //  CMD 12. Stop transfer                                     //
    //                                                            //
    ////////////////////////////////////////////////////////////////
	iowrite32(&sd_base, 0x28, 0x00000001);
	iowrite32(&sd_base, 0x20, 0x000002FF);
	iowrite32(&sd_base, 0x18, 0x00000FFF);
	iowrite32(&sd_base, 0x24, 0x00000000);
	iowrite32(&sd_base, 0x28, 0x00000000);
	iowrite32(&sd_base, 0x38, 0x0000001F);
	iowrite32(&sd_base, 0x40, 0x00000007);
	iowrite32(&sd_base, 0x1C, 0x00000001);
	iowrite32(&sd_base, 0x04, 0x00000000);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00000801);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00003719);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00002901);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x0000020A);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00000309);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00000709);
	iowrite32(&sd_base, 0x00, 0x20000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00003719);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00000619);
	iowrite32(&sd_base, 0x00, 0x00000002);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x60, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00001859);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x3C, 0x00000000);
	iowrite32(&sd_base, 0x60, 0x00000001);
	iowrite32(&sd_base, 0x04, 0x00001139);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x3C, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00000C19);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);

    ////////////////////////////////////////////////////////////////
    //                                                            //
    //  test_send_cmd_error_rsp                                   //
    //                                                            // 
    //  Test 4: Send CMD with a simulated bus error               //
    //  init card                                                 //
    //  all folowing responses with crc error and index error     //
    //  CMD 16. no error check                                    //
    //  CMD 16. with all error check                              //
    //  CMD 16. with crc error check                              //
    //                                                            //
    ////////////////////////////////////////////////////////////////
	iowrite32(&sd_base, 0x28, 0x00000001);
	iowrite32(&sd_base, 0x20, 0x000002FF);
	iowrite32(&sd_base, 0x18, 0x00000FFF);
	iowrite32(&sd_base, 0x24, 0x00000000);
	iowrite32(&sd_base, 0x28, 0x00000000);
	iowrite32(&sd_base, 0x38, 0x0000001F);
	iowrite32(&sd_base, 0x40, 0x00000007);
	iowrite32(&sd_base, 0x1C, 0x00000001);
	iowrite32(&sd_base, 0x04, 0x00000000);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00000801);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00003719);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00002901);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x0000020A);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00000309);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00001001);
	iowrite32(&sd_base, 0x00, 0x00000200);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00001019);
	iowrite32(&sd_base, 0x00, 0x00000200);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00001009);
	iowrite32(&sd_base, 0x00, 0x00000200);
	iowrite32(&sd_base, 0x34, 0x00000000);

    /////////////////////////////////////////////////////////////////
    //                                                             //
    //  test_send_rec_data_error_rsp                               //
    //                                                             //  
    //  Test 5: Send and receive data with error                   //  
    //                                                             //
    /////////////////////////////////////////////////////////////////
	iowrite32(&sd_base, 0x28, 0x00000001);
	iowrite32(&sd_base, 0x20, 0x000002FF);
	iowrite32(&sd_base, 0x18, 0x00000FFF);
	iowrite32(&sd_base, 0x24, 0x00000000);
	iowrite32(&sd_base, 0x28, 0x00000000);
	iowrite32(&sd_base, 0x38, 0x0000001F);
	iowrite32(&sd_base, 0x40, 0x00000007);
	iowrite32(&sd_base, 0x1C, 0x00000001);
	iowrite32(&sd_base, 0x04, 0x00000000);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00000801);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00003719);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00002901);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x0000020A);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00000309);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00000709);
	iowrite32(&sd_base, 0x00, 0x20000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00003719);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00000619);
	iowrite32(&sd_base, 0x00, 0x00000002);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x60, 0x00000000);
	iowrite32(&sd_base, 0x04, 0x00001859);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x3C, 0x00000000);
	iowrite32(&sd_base, 0x60, 0x00000001);
	iowrite32(&sd_base, 0x04, 0x00001139);
	iowrite32(&sd_base, 0x00, 0x00000000);
	iowrite32(&sd_base, 0x34, 0x00000000);
	iowrite32(&sd_base, 0x3C, 0x00000000);
	
	return 0;
}
