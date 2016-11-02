/*
 * Test for APBPS2
 *
 * Copyright (c) 2009 Aeroflex Gaisler AB
 *
 * This application requires that the APBPS2 core is attached to the 
 * ps2_device simulation model that is defined in gaisler.sim.
 *
 * The test will transmit 0xAA to the ps2_device simulation model
 * which will instruct the model to respond with the bytes 0x5A
 * and 0xA5.
 *
 */

#include "testmod.h"

/** Register fields **/
/* Status register */
#define APBPS2_S_RCNT_P 27    /* Receive FIFO count */
#define APBPS2_S_TCNT_P 22    /* Transmit FIFO count */
#define APBPS2_S_TF (1 << 5)  /* Transmitter buffer full */
#define APBPS2_S_RF (1 << 4)  /* Receiver buffer full */
#define APBPS2_S_KI (1 << 3)  /* Keyboard inhibit */
#define APBPS2_S_FE (1 << 2)  /* Framing error */
#define APBPS2_S_PE (1 << 1)  /* Party error */
#define APBPS2_S_DR (1 << 0)  /* Data ready */

/* Control register */
#define APBPS2_C_TI (1 << 3)  /* Host interrupt enable */
#define APBPS2_C_RI (1 << 2)  /* Keyboard interrupt enable */
#define APBPS2_C_TE (1 << 1)  /* Transmitter enable */
#define APBPS2_C_RE (1 << 0)  /* Receiver enable */


struct apbps2_regs {
   volatile unsigned int data;
   volatile unsigned int status;
   volatile unsigned int control;
   volatile unsigned int reload;
};


int apbps2_test(int addr)
{
   unsigned int i, tmp;
   struct apbps2_regs *reg;

   report_device(0x01060000);

   reg = (struct apbps2_regs*)addr;
   
   /* Don't care about generating the correct low time */
   reg->reload = 0;

   /* Check status bits */
   tmp = reg->status;
   
   if ((tmp >> APBPS2_S_RCNT_P) & 0x1F) {
      fail(0);
   }
   if ((tmp >> APBPS2_S_TCNT_P) & 0x1F) {
      fail(1);
   } 
   if (tmp & APBPS2_S_TF) {
      fail(2);
   }
   if (tmp & APBPS2_S_RF) {
      fail(3);
   }
   if (tmp & APBPS2_S_KI) {
      fail(4);
   }
   if (tmp & APBPS2_S_FE) {
      fail(5);
   }
   if (tmp & APBPS2_S_PE) {
      fail(6);
   }
   if (tmp & APBPS2_S_DR) {
      fail(7);
   }

   /* Enable transmitter and receiver */
   reg->control = APBPS2_C_TE | APBPS2_C_RE;

   /* Transmit test */
   report_subtest(1);
   
   reg->data = 0xAA;
   
   /* Wait for transmit FIFO counter to zero */
   while ((reg->status >> APBPS2_S_TCNT_P) & 0x1F)
      ; /* Will go low before transmissions is complete.. */

   /* Receive test */
   report_subtest(2);
   
   for (i = 0; i < 2; i++) {
      /* Wait for character to be received */
      while (!((reg->status >> APBPS2_S_RCNT_P) & 0x1F))
         ;
      tmp = reg->data;
      if ((i == 0 && tmp != 0x5A) || (i == 1 && tmp != 0xA5)) {
         fail(i);
      }
   }

   /* Disable core */
   reg->control = 0;
}
