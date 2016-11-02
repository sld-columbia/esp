/*
 * Test for I2CSLV and I2CMST
 *
 * Copyright (c) 2009 Aeroflex Gaisler AB
 *
 * This test application transfers data between an I2CMST core
 * and an I2CSLV core. The transfers are _not_ interrupt driven.
 *
 * This application assumes that the I2CSLV's address is programmable. 
 *
 */

#include "testmod.h"

/* Register fields for I2CSLV */
/* Slave address register */
#define I2CSLV_SLVADDR_TBA   (1 << 31)
/* Control register */
#define I2CSLV_CTRL_RMOD_POS 4
#define I2CSLV_CTRL_RMOD     (1 << 4)
#define I2CSLV_CTRL_TMOD_POS 3
#define I2CSLV_CTRL_TMOD     (1 << 3)
#define I2CSLV_CTRL_TV       (1 << 2)
#define I2CSLV_CTRL_TAV      (1 << 1)
#define I2CSLV_CTRL_EN       (1 << 0)
/* Status register */
#define I2CSLV_STS_REC       (1 << 2)
#define I2CSLV_STS_TRA       (1 << 1)
#define I2CSLV_STS_NAK       (1 << 0)
/* Mask register */
#define I2CSLV_MSK_RECE      (1 << 2)
#define I2CSLV_MSK_TRAE      (1 << 1)
#define I2CSLV_MSK_NAKE      (1 << 0)

/* I2CSLV registers */
struct i2cslv_regs {
   volatile unsigned int slvaddr;
   volatile unsigned int ctrl;
   volatile unsigned int sts;
   volatile unsigned int msk;
   volatile unsigned int rd;
   volatile unsigned int td;
};

/* Register fields for I2CMST */
/* Control register */
#define I2CMST_CTR_EN   (1 << 7)   /* Enable core */
#define I2CMST_CTR_IEN  (1 << 6)   /* Interrupt enable */
/* Command register */
#define I2CMST_CR_STA   (1 << 7)   /* Generate start condition */
#define I2CMST_CR_STO   (1 << 6)   /* Generate stop condition */
#define I2CMST_CR_RD    (1 << 5)   /* Read from slave */
#define I2CMST_CR_WR    (1 << 4)   /* Write to slave */
#define I2CMST_CR_ACK   (1 << 3)   /* ACK, when a receiver send ACK (ACK = 0) 
                                      or NACK (ACK = 1) */
#define I2CMST_CR_IACK  (1 << 0)   /* Interrupt acknowledge */
/* Status register */
#define I2CMST_SR_RXACK (1 << 7)   /* Receibed acknowledge from slave */
#define I2CMST_SR_BUSY  (1 << 6)   /* I2C bus busy */
#define I2CMST_SR_AL    (1 << 5)   /* Arbitration lost */
#define I2CMST_SR_TIP   (1 << 1)   /* Transfer in progress */
#define I2CMST_SR_IF    (1 << 0)   /* Interrupt flag */

/* I2CMST registers */
struct i2cmst_regs {
   volatile unsigned int prer;
   volatile unsigned int ctr;
   volatile unsigned int xr;
   volatile unsigned int csr;
};


/* Test configuration */
#define PRESCALER   0x000A
#define SLAVE_ADDRESS 0x33

/*
 * i2c_test(..)
 *
 * mstaddr - I2CMST register base address
 * slvaddr - I2CSLV register base address
 *
 */
int i2c_test(int mstaddr, int slvaddr)
{
   int i;
   struct i2cmst_regs *mstregs;
   struct i2cslv_regs *slvregs;
   
   report_device(0x0103E000);

   mstregs = (struct i2cmst_regs*)mstaddr;
   slvregs = (struct i2cslv_regs*)slvaddr;

   /* Report combined test */
   report_subtest(2);
   
   /* Set I2CSLV's address */
   slvregs->slvaddr = SLAVE_ADDRESS;
   
   /* Set I2CSLV's mask register */
   slvregs->msk = 0;
   
   /* Init I2CSLV transmit register */
   slvregs->td = 0;
   
   /* Set I2CSLV's control register */
   slvregs->ctrl = (I2CSLV_CTRL_RMOD | I2CSLV_CTRL_TMOD | 
                    I2CSLV_CTRL_TV | I2CSLV_CTRL_EN);

   /* Initialize and enable I2CMST */
   mstregs->prer = PRESCALER;

   /* Enable core */
   mstregs->ctr = I2CMST_CTR_EN;
		
   /* Write address and write bit to transmit register */
   mstregs->xr = (SLAVE_ADDRESS << 1); /* Write is bit 0 = 0 */

   /* Set STA and WR in command register */
   mstregs->csr = I2CMST_CR_STA | I2CMST_CR_WR;
   
   /* Wait for TIP to go low */
   while (mstregs->csr & I2CMST_SR_TIP)
      ;
   
   /* Check RxACK in status register */
   if (mstregs->csr & I2CMST_SR_RXACK) {
      fail(0);
   }
   if (mstregs->csr & I2CMST_SR_AL) {
      fail(1);
   }
	
   for (i = 0; i < 3; i++) {
      /* Write data to transmit register */
      mstregs->xr = i;
      
      /* WR in command register and STO if we are at last byte */
      mstregs->csr = I2CMST_CR_WR | (i == 2 ? I2CMST_CR_STO : 0);
      
      /* Wait for I2CSLV to receive data */
      while (!(slvregs->sts & I2CSLV_STS_REC)) 
         ;
      
      /* Clear status register */
      slvregs->sts = 0xFF;

      /* Read data data */
      if (slvregs->rd != i) {
         fail(2+i);
      }

      /* Wait for transfer to end */
      while (mstregs->csr & I2CMST_SR_TIP)
         ;

      /* Check I2CMST RxACK bit */
      if (mstregs->csr & I2CMST_SR_RXACK) {
         fail(5+i);
      }
   }
	
   /* Write address and read bit into transmit register */
   mstregs->xr = (SLAVE_ADDRESS << 1) | 1;
   
   /* Set STA and WR */
   mstregs->csr = I2CMST_CR_STA | I2CMST_CR_WR;
  
   /* Wait for TIP to go low */
   while (mstregs->csr & I2CMST_SR_TIP)
      ;

   /* Check RxACK bit */
   if (mstregs->csr & I2CMST_SR_RXACK) {
      fail(11);
   }

   for (i = 0; i < 3; i++) {
      /* Set RD, STO and ACK are set if we are at the last element
         (CR_ACK = 0 to ACK) */
      mstregs->csr = (I2CMST_CR_RD | 
                      (i == 2 ? I2CMST_CR_STO | I2CMST_CR_ACK : 0));
      
      /* Wait for TIP to go low */
      while (mstregs->csr & I2CMST_SR_TIP)
         ;

      /* Slave should have transmitted word */
      if (!(slvregs->sts & I2CSLV_STS_TRA)) {
         fail(12+i);
      }
      
      /* Fill slave transmit register */
      if (i != 2) {
         slvregs->td = i+1;

         /* Transmit register is valid */
         slvregs->ctrl = slvregs->ctrl | I2CSLV_CTRL_TV;
      }

      /* Clear status register */
      slvregs->sts = slvregs->sts;

      if (mstregs->xr != i) {
         fail(15+i);
      }
   }

   /* Disable both cores */
   slvregs->ctrl = 0;
   mstregs->ctr = 0;

   return 0;
}

