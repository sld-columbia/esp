/*
 * SPICTRL system test software
 *
 * Copyright (c) 2008 Gaisler Research AB
 * Copyright (c) 2009 - 2010 Aeroflex Gaisler AB
 *
 * The tests are started with spictrl_test(<addr>, sel) where:
 *
 * sel = 0, uses internal loopback to test the core
 *
 * sel = 1, requires that the sck, miso, and mosi 
 * signals must be connected together.
 *
 * sel = 0, 1 does not use any slave select signals.
 *
 * sel = 2, performs an internal loopback test and communicates
 * with a spi_flash simulation module. A model should be instantiated 
 * in the testbench with the following parameters:
 *
 * spi_flash
 *   ftype      => 3,
 *   debug      => Don't care,
 *   fname      => Don't care,
 *   readcmd    => 16#0B#,
 *   dummybyte  => 0,
 *   dualoutput => 0 
 *
 * sel = 2 requires that slave select 0 is connected to the spi_flash
 * model.
 *
 * All tests require that the SPISEL input is HIGH.
 *
 */

#include "testmod.h"
#include "irqmp.h"

/* Register offsets */
#define SPIC_CAP_OFF    0x00
#define SPIC_MODE_OFF   0x20
#define SPIC_AMMSK_OFF  0x50
#define SPIC_AMTX_OFF   0x200
#define SPIC_AMRX_OFF   0x400

/* Register fields */
/* Capability register */
#define SPIC_SSSZ   24
#define SPIC_MAXLEN 20
#define SPIC_TWEN   (1 << 19)
#define SPIC_AMODE  (1 << 18)
#define SPIC_ASELA  (1 << 17)
#define SPIC_SSEN   (1 << 16)
#define SPIC_FDEPTH 8
#define SPIC_REVI   0
/* Mode register */
#define SPIC_AMEN   (1 << 31)
#define SPIC_LOOP   (1 << 30)
#define SPIC_CPOL   (1 << 29)
#define SPIC_CPHA   (1 << 28)
#define SPIC_DIV16  (1 << 27)
#define SPIC_REV    (1 << 26)
#define SPIC_MS     (1 << 25)
#define SPIC_EN     (1 << 24)
#define SPIC_LEN    20
#define SPIC_PM     16
#define SPIC_TW     (1 << 15)
#define SPIC_ASEL   (1 << 14)
#define SPIC_FACT   (1 << 13)
#define SPIC_OD     (1 << 12)
#define SPIC_CG     7
#define SPIC_ASDEL  5
#define SPIC_TAC    (1 << 4)
#define SPIC_TTO    (1 << 3)
/* Event and Mask registers */
#define SPIC_TIP    (1 << 31)
#define SPIC_LT     (1 << 14)
#define SPIC_OV     (1 << 12)
#define SPIC_UN     (1 << 11)
#define SPIC_MME    (1 << 10)
#define SPIC_NE     (1 << 9)
#define SPIC_NF     (1 << 8)
/* Command register */
#define SPIC_LST    (1 << 22)
/* AM Configuration register */
#define SPIC_SEQ    (1 << 5)
#define SPIC_STRICT (1 << 4)
#define SPIC_OVTB   (1 << 3)
#define SPIC_OVDB   (1 << 2)
#define SPIC_ACT    (1 << 1)
#define SPIC_EACT   (1 << 0)

/* Reset values */
#define MODE_RESVAL  0
#define EVENT_RESVAL 0
#define MASK_RESVAL  0
#define CMD_RESVAL   0
#define TD_RESVAL    0

struct spictrlregs {
  volatile unsigned int mode;
  volatile unsigned int event;
  volatile unsigned int mask;
  volatile unsigned int com;
  volatile unsigned int td;
  volatile unsigned int rd;
  volatile unsigned int slvsel;
  volatile unsigned int aslvsel;
  volatile unsigned int amcfg;
  volatile unsigned int amper;
};

struct amregs {
  volatile unsigned int tx[128];
  volatile unsigned int rx[128];
};

/*
 * spictrl_extdev_test(int addr)
 *
 * Communicates with a spi_flash simulation module. A model 
 * should be instantiated in the testbench with the following
 * parameters:
 *
 * spi_flash
 *   ftype      => 3,
 *   debug      => Don't care,
 *   fname      => Don't care,
 *   readcmd    => 16#0B#,
 *   dummybyte  => 0,
 *   dualoutput => 0
 *
 * The test requires that slave select 0 is connected to the spi_flash model.
 *
 */
int spictrl_extdev_test(int addr)
{
   int i;
   int fd;
   int data;
   
   volatile unsigned int *capreg;
   struct spictrlregs *regs;

   capreg = (int*)addr;
   regs = (struct spictrlregs*)(addr + SPIC_MODE_OFF);
   
   report_subtest(4);
   
   /* Test requires core to have a maximum word length of at least 8 */
   if ((((*capreg >> SPIC_MAXLEN) & 0xF) != 0) &&
       (((*capreg >> SPIC_MAXLEN) & 0xF) < 7)) {
      fail(1);
   }

   regs->mode = (SPIC_MS | SPIC_EN | SPIC_REV | (7 << SPIC_LEN));

   /* Check event bits */
   if (regs->event & SPIC_LT)
      fail(2);
   if (regs->event & SPIC_OV)
      fail(3);
   if (regs->event & SPIC_UN)
      fail(4);
   if (regs->event & SPIC_MME)
      fail(5);
   if (regs->event & SPIC_NE)
      fail(6);
   if (!(regs->event & SPIC_NF))
      fail(7);
     
   /* Select slave */
   regs->slvsel = ~1;
  
   /* Address device */
   data = 0x0bdead55;
   for (i = 0; i < 4; i++) {
      regs->td = data << (i * 8);
      while (!(regs->event & SPIC_NF))
         ;
   }
   
   /* Depending on fifo depth we may have run into a overrun condition */
   fd = (*capreg >> SPIC_FDEPTH) & 0xff;
   if (((fd < 4) && !((regs->event & SPIC_OV))) ||
       ((fd >= 4) && (regs->event & SPIC_OV))) {
      fail(8);
   }
   regs->event = SPIC_OV;

   while (regs->event & SPIC_TIP)
     ;

   /* Empty receive queue */
   for (i = 0; i < 4; i++) {
      data = regs->rd;
   }
   /* Queue should now be empty */
   if (regs->event & SPIC_NE)
      fail(9);
   
   /* Read back data */
   data = 0;
   for (i = 0; i < 3; i++) {
      regs->td = 0;
      while (!(regs->event & SPIC_NE))
         ;
      data = (data << 8) | ((regs->rd >> 16) & 0xff);
   }

   /* Check data, ends with 4 since spi_flash model modifies data */
   if (data != 0xdead54)
      fail(10);
   
   /* Deselect slave */
   regs->slvsel = ~0;

   /* Deactivate core */
   regs->mode = 0;

   /* Clear status bits */
   regs->event = ~0;

   return 0;
}

static volatile int spictrl_irq = 0;

static spictrl_irqhandler(int irq)
{
    spictrl_irq += 1;
}


/*
 * spictrl_irqtest(int addr, int irq)
 *
 * Checks SPICTRL interrupt line by asserting NE interrupt
 *
 * (currently not called as part of spictrl_test, should be
 *  called directly after in case this test is used since
 *  "report_subtest" is called without other initialisation).
 */
int spictrl_irqtest(int addr, int irq)
{
   volatile unsigned int *capreg;
   struct spictrlregs *regs;
   volatile unsigned int tmp;

   capreg = (int*)addr;
   regs = (struct spictrlregs*)(addr + SPIC_MODE_OFF);

   report_subtest(5);
   
   if (irqmp_base) {
      init_irqmp(irqmp_base);
      irqmp_base->irqmask = 1 << irq;	  /* unmask interrupt */
   } else {
      fail(1);
   }

   catch_interrupt(spictrl_irqhandler, irq);

   if (regs->event != EVENT_RESVAL)
      fail(2);

   regs->mode = (SPIC_LOOP | SPIC_MS | SPIC_EN | (3 << SPIC_LEN));

   regs->mask = SPIC_NE;
   
   if (spictrl_irq)
      fail(3);

   regs->td = 0;

   while(regs->event & SPIC_TIP)
      ;

   if (!(regs->event & SPIC_NE))
      fail(4);

   tmp = regs->rd;

   if (regs->event & SPIC_NE)
      fail(5);

   if (spictrl_irq != 1)
      fail(6);
   
   regs->mask = 0;

   regs->mode = 0;

   return 0;
}

/*
 * spictrl_test(int addr, int testsel)
 *
 * Writes fifo depth + 1 words. Writes one more word and 
 * checks LT and OV status.
 *
 * Tests automated transfers if the core has support
 * for them.
 *
 * Calls spictrl_extdev_test if testsel = 2.
 *
 */
int spictrl_test(int addr, int testsel)
{
  int i;
  int data;
  int fd;
  int maxwlen;
  int wmask;
  int wshft;
  int internal;

  volatile unsigned int *capreg;
  struct spictrlregs *regs;
  struct amregs *amreg;
  volatile unsigned int *ammsk;
    
  report_device(0x0102D000);

  capreg = (int*)addr;
  regs = (struct spictrlregs*)(addr + SPIC_MODE_OFF);
  amreg = (struct amregs*)(addr + SPIC_AMTX_OFF);
  ammsk = (int*)(addr + SPIC_AMMSK_OFF);

  /* Core may have a maximum word length that is less than 32 bits */
  maxwlen = (*capreg >> SPIC_MAXLEN) & 0xF;
  if (maxwlen == 0) {
    wmask = ~0;
    wshft = 0;
  } else {
    wmask = ~(~0 << (maxwlen + 1));
    wshft = (15 - maxwlen);
  }
  
  internal = ~(testsel & 1);

  report_subtest(1);

  /*
   * Check register reset values
   */
  if (regs->mode != MODE_RESVAL)
    fail(0);
  if (regs->event != EVENT_RESVAL)
    fail(1);
  if (regs->mask != MASK_RESVAL)
    fail(2);
  if (regs->com != CMD_RESVAL)
    fail(3);
  if (regs->td != TD_RESVAL)
    fail(4);
  /* RD register is not reset and therefore not read */

  report_subtest(2);

  /* 
   * Configure core in loopback and write FIFO depth + 1
   * words
   */
  fd = (*capreg >> SPIC_FDEPTH) & 0xff;

  regs->mode = ((internal ? SPIC_LOOP : 0) | SPIC_MS | 
                SPIC_EN | (maxwlen << SPIC_LEN));

  /* Check event bits */
  if (regs->event & SPIC_LT)
    fail(5);
  if (regs->event & SPIC_OV)
    fail(6);
  if (regs->event & SPIC_UN)
    fail(7);
  if (regs->event & SPIC_MME)
    fail(8);
  if (regs->event & SPIC_NE)
    fail(9);
  if (!(regs->event & SPIC_NF))
    fail(10);
    
  data = 0xaaaaaaaa; 

  for (i = 0; i <= fd; i++) {
    regs->td = data;
    data = ~data;
  }
  
  /* Multiple master error */
  if (regs->event & SPIC_MME)
    fail(11);

  /* Wait for first word to be transferred */
  while (!(regs->event & SPIC_NF))
    ;

  if (!(regs->event & SPIC_NE))
    fail(12);

  /* Write one more word to trigger overflow, set LST */
  regs->td = data;
  regs->com = SPIC_LST;

  while (!(regs->event & SPIC_LT))
    ;

  if (!(regs->event & SPIC_OV))
    fail(13);

  /* Verify that words transferred correctly */
  data = 0xaaaaaaaa;

  for (i = 0; i <= fd; i++) {
    if (regs->rd != ((data & wmask) << wshft))
      fail(14+i);
    data = ~data;
  }
  
  /* Deactivate core */
  regs->mode = 0;

  /* Clear status bits */
  regs->event = ~0;

  if (testsel == 2)
     spictrl_extdev_test(addr);

  /* Return if core does not support automated transfers */
  if (!(*capreg & SPIC_AMODE))
     return 0;

  /* AM Loopback test */
  report_subtest(3);

  /* Enable core with automated transfers */
  regs->mode = (SPIC_AMEN | SPIC_FACT | (internal ? SPIC_LOOP : 0) | 
                SPIC_MS | SPIC_EN | (maxwlen << SPIC_LEN));

  /* Write two words to AM transmit registers */
  data = 0xdeadf00d;

  for (i = 0; i < 2; i++) {
    amreg->tx[i] = data;
    data = ~data;
  }

  /* Set AM mask register to used only the first two words */
  *(ammsk+0) = 3;
  *(ammsk+1) = 0;
  *(ammsk+2) = 0;
  *(ammsk+3) = 0;
  
  /* Set AM period register */
  regs->amper = 3;

  /* Enable automated transfers */
  regs->amcfg = SPIC_ACT;
  
  /* Wait for NE event */
  while (!(regs->event & SPIC_NE))
     ;
  
  /* Read out data */
  data = 0xdeadf00d;

  for (i = 0; i < 2; i++) {
    if (amreg->rx[i] != ((data & wmask) << wshft))
      fail(15+fd+i);
    data = ~data;
  }
  
  /* Deactivate automated transfers */
  regs->amcfg = 0;
  
  /* Wait for automated mode to be deactivated */
  while ((regs->amcfg & SPIC_ACT))
     ;
  
  /* Deactivate core */
  regs->mode = 0;

  return 0;
}


