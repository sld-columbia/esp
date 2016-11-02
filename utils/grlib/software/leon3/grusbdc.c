/* GAISLER_LICENSE */
/* ----------------------------------------------------------------------------- */
/*  File:        grusbdc.c */
/*  Author:      Marko Isomaki, */
/*  Description: System test software for USB device controller */
/* ----------------------------------------------------------------------------- */
#include "testmod.h"
#include <stdlib.h>

/* NOTE: Define/undefine FUNCTESTMODE depending on whether the system test should
be run in functional test mode or not. In functional test mode the device doesn't
need to receive a USB reset before sending data and also real USB timing isn't
used. The point of this is to speed up simulation, which might be necessary if
running ASIC tests */
/* #define FUNCTESTMODE */

/*bRequest constants*/
#define GET_STATUS        0x00
#define CLEAR_FEATURE     0x01
#define SET_FEATURE       0x03
#define SET_ADDRESS       0x05
#define GET_DESCRIPTOR    0x06
#define SET_DESCRIPTOR    0x07
#define GET_CONFIGURATION 0x08
#define SET_CONFIGURATION 0x09
#define GET_INTERFACE     0x0A
#define SET_INTERFACE     0x0B
#define SYNCH_FRAME       0x0C

/*wValue constants*/
#define DEVICE_REMOTE_WAKEUP 0x0100
#define ENDPOINT_HALT        0x0000
#define TEST_MODE            0x0200

/*descriptor types*/
#define DEVICE_T         0x01
#define CONFIGURATION_T  0x02
#define STRING_T         0x03
#define INTERFACE_T      0x04
#define ENDPOINT_T       0x05
#define DEVQUAL_T        0x06
#define OSCONF_T         0x07
#define INTERFACE_POWER  0x08

/*device descriptor*/
char grDD[20] = {
  0x12, /*bLength*/
  0x01, /*bDescriptorType*/
  0x10, 0x02, /*bcdUSB*/
  0xFF, /*bDeviceClass*/
  0x00, /*bDeviceSubClass*/
  0xFF, /*bDeviceProtocol*/
  0x40, /*bMaxPacketSize0*/
  0x81, 0x17, /*idVendor*/ 
  0xA0, 0x0A, /*idProduct*/
  0x00, 0x00, /*bcdDevice*/
  0x00, /*iManufacturer*/
  0x00, /*iProduct*/
  0x00, /*iSerialNumber*/
  0x01, /*bNumConfigurations*/
  0x00, /*Pad*/
  0x00  /*Pad*/
  };


/*config+interface+2*endpoint descriptor*/
  char grCD[32] = { 
  /*Configuration descriptor*/
  0x09, /*bLength*/
  0x02, /*bDescriptorType*/
  0x20, 0x00, /*wTotalLength*/
  0x01, /*bNumInterfaces*/
  0x01, /*bConfigurationValue*/
  0x00, /*iConfiguration*/
  0xC0, /*bmAttributes*/
  0x05, /*bMaxPower*/

 /*Interface descriptor*/
   0x09, /*bLength*/
   0x04, /*bDescriptorType*/
   0x00, /*bInterfaceNumber*/
   0x00, /*bAlternateSetting*/
   0x02, /*bNumEndpoints*/
   0xFF, /*bInterfaceClass*/
   0x00, /*bInterfaceSubClass*/
   0xFF, /*bInterfaceProtocol*/
   0x00, /*iInterface*/

   /*Endpoint 1 Bulk Out*/
   0x07, /*bLength*/
   0x05, /*bDescriptorType*/
   0x01, /*bEndpointAddress*/
   0x02, /*bmAttributes*/
   0x00, 0x02, /*wMaxPacketSize*/
   0x01, /*bInterval*/

   /*Endpoint 1 Bulk In*/
   0x07, /*bLength*/
   0x05, /*bDescriptorType*/
   0x81, /*bEndpointAddress*/
   0x02, /*bmAttributes*/
   0x00, 0x02, /*wMaxPacketSize*/
   0x01  /*bInterval*/
   
   };

/*device qualifier*/
char grDQ[10] = {
  0x0A, /*bLength*/
  DEVQUAL_T, /*bDescriptorType*/
  0x10, 0x02, /*bcdUSB*/
  0xFF, /*bDeviceClass*/
  0x00, /*bDeviceSubClass*/
  0xFF, /*bDeviceProtocol*/
  0x40, /*bMaxPacketSize0*/
  0x01, /*bNumConfigurations*/
  0x00 /*bReserved*/
};


/*other speed config+interface+2*endpoint descriptor*/
  char grOC[32] = { 
  /*Configuration descriptor*/
  0x09, /*bLength*/
  OSCONF_T, /*bDescriptorType*/
  0x20, 0x00, /*wTotalLength*/
  0x01, /*bNumInterfaces*/
  0x01, /*bConfigurationValue*/
  0x00, /*iConfiguration*/
  0xC0, /*bmAttributes*/
  0x05, /*bMaxPower*/

 /*Interface descriptor*/
   0x09, /*bLength*/
   0x04, /*bDescriptorType*/
   0x00, /*bInterfaceNumber*/
   0x00, /*bAlternateSetting*/
   0x02, /*bNumEndpoints*/
   0xFF, /*bInterfaceClass*/
   0x00, /*bInterfaceSubClass*/
   0xFF, /*bInterfaceProtocol*/
   0x00, /*iInterface*/

   /*Endpoint 1 Bulk Out*/
   0x07, /*bLength*/
   0x05, /*bDescriptorType*/
   0x01, /*bEndpointAddress*/
   0x02, /*bmAttributes*/
   0x00, 0x02, /*wMaxPacketSize*/
   0x01, /*bInterval*/

   /*Endpoint 1 Bulk In*/
   0x07, /*bLength*/
   0x05, /*bDescriptorType*/
   0x81, /*bEndpointAddress*/
   0x02, /*bmAttributes*/
   0x00, 0x02, /*wMaxPacketSize*/
   0x01  /*bInterval*/
   
   };

static inline int load(int addr)
{
    int tmp;        
    asm volatile(" lda [%1]1, %0 "
        : "=r"(tmp)
        : "r"(addr)
        );
    return tmp;
}

static inline char loadb(int addr)
{
  char tmp;        
  asm volatile (" lduba [%1]1, %0 "
      : "=r"(tmp)
      : "r"(addr)
  );
  return tmp;
}

int grusbdc_test(int ahbaddr) 
{
        int i;
        
        int cinpnt = 0;
        int coutpnt = 0;
        int configuration = 0;
        int status = 0;
        
        int *usbreg = (int *) ahbaddr;
        char *ctrlinbuf[2];
        char *ctrloutbuf[2];
        
        int *ctrlindesc;
        int *ctrloutdesc;
	
        ctrlinbuf[0] = (char *)malloc(64);
        ctrlinbuf[1] = (char *)malloc(64);
        ctrloutbuf[0] = (char *)malloc(64);
        ctrloutbuf[1] = (char *)malloc(64);

        ctrlindesc = (int *)malloc(32);
        ctrloutdesc = (int *)malloc(32);

	report_device(0x01021000);
	
#ifdef FUNCTESTMODE
	usbreg[128] = (1 << 15);
#else
	usbreg[128] = (1 << 14);
#endif
		
	/* Enable Endpoint 0 */ 
	usbreg[0] = 0x00002001;  /* OUT */ 
	usbreg[64] = 0x00002001; /* IN */
	
	/* Set descriptor addresses for all endpoints*/ 
	usbreg[2] = (int) ctrloutdesc;
	usbreg[66] = (int) ctrlindesc;
	
	/* Set descriptors for IN endpoint 0 */
	ctrlindesc[1] = (int)&grDD;
	ctrlindesc[2] = (int)&ctrlindesc[3];
	
	/* Enable descriptors for OUT endpoint 0 */
	ctrloutdesc[1] = (int)ctrloutbuf[0];
	ctrloutdesc[2] = (int)&ctrloutdesc[3];
	ctrloutdesc[4] = (int)ctrloutbuf[1];
	ctrloutdesc[5] = (int)&ctrloutdesc[0];
	ctrloutdesc[0] = 0x0000E000;
	ctrloutdesc[3] = 0x0000E000;
	usbreg[1] = 0x3;	
       
	while(load((int)&ctrloutdesc[0]) & 0x2000)
	  ;
	
	/* Enable IN descriptor */
	ctrlindesc[0] = 0xE000 | 18;
	usbreg[65] = 0x3;
	
	while(load((int)&ctrloutdesc[3]) & 0x2000)
	  ;	
			
	free(ctrlinbuf[0]);
	free(ctrlinbuf[1]); 
	free(ctrloutbuf[0]); 
	free(ctrloutbuf[1]); 
	
	free(ctrlindesc); 
	free(ctrloutdesc);
}
