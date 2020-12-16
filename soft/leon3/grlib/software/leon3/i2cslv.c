/*
 * Test for I2CSLV
 *
 * Copyright (c) 2009 Aeroflex Gaisler AB
 *
 * This test application tests the register interface.
 * No I2C transfers are performed.
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


int i2cslv_test(int addr)
{
   int i;
   unsigned int tmp;
   struct i2cslv_regs *reg;

   report_device(0x0103E000);
   
   reg = (struct i2cslv_regs*)addr;

   /* Register interface */
   report_subtest(1);
   
   /* Slave address register */
   tmp = reg->slvaddr;
   reg->slvaddr = 0x7F;
   if ((reg->slvaddr != tmp) && (reg->slvaddr != 0x7F)) {
      fail(0);
   }
   /* Possibly restore */
   reg->slvaddr = tmp;

   /* Control register */
   reg->ctrl = 0;
   if (reg->ctrl) {
      fail(1);
   }
   reg->ctrl = (I2CSLV_CTRL_RMOD | I2CSLV_CTRL_TMOD |
                I2CSLV_CTRL_TV | I2CSLV_CTRL_TAV | I2CSLV_CTRL_EN);

   if (reg->ctrl != (I2CSLV_CTRL_RMOD | I2CSLV_CTRL_TMOD |
                     I2CSLV_CTRL_TV | I2CSLV_CTRL_TAV | I2CSLV_CTRL_EN)) {
      fail(2);
   }

   reg->ctrl = 0;
   if (reg->ctrl) {
      fail(3);
   }

   /* Status register */
   if (reg->sts) {
      fail(4);
   }

   /* Mask register */
   reg->msk = 0;
   if (reg->msk) {
      fail(5);
   }

   reg->msk = (I2CSLV_MSK_RECE | I2CSLV_MSK_TRAE | I2CSLV_MSK_NAKE);
   if (reg->msk != (I2CSLV_MSK_RECE | I2CSLV_MSK_TRAE | I2CSLV_MSK_NAKE)) {
      fail(6);
   }

   reg->msk = 0;
   if (reg->msk) {
      fail(7);
   }

   /* Receive register */
   /* Not tested */

   /* Transmit register */
   /* Not tested */

   return 0;
}
