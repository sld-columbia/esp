#include <stdlib.h>
#include "testmod.h"
#include "gptimer.h"
#include "irqmp.h"
#include "gpio.h"
#include "grspwtdp-regs.h"

static volatile gpirq = 0;

static volatile struct grgpio_apb *gpio;
static volatile struct grspwtdp_regs *tdp;

void *gptimer_gpiobase(void *base)
{
  static void *ret;

  ret = (void *) gpio;
  if (NULL != base) {
    gpio = base;
  }

  return ret;
}

void *gptimer_spwtdpbase(void *base)
{
  static void *ret;

  ret = (void *) tdp;
  if (NULL != base) {
    tdp = base;
  }

  return ret;
}

static gptimer_irqhandler(int irq)
{
    gpirq += 1;
}

static void timecode_start(void)
{
  if (NULL == tdp) {
    fail(1);
  }
  /* Reset */
  tdp->conf[0] = 1;
  while (tdp->conf[0] & 1);
  /* MAPPING=19, Transmit Enable */
  tdp->conf[0] |= (19<<8) | (1<<7) | (1<<1);
  /* Configure Frequency Synthesizer value corresponding to 
     System Frequency (to start CUC time) */
  /* The value provided below is for 250 MHz */
  tdp->conf[1] = 72057594;
}

static void timecode_stop(void)
{
  if (NULL == tdp) {
    fail(1);
  }
  /* Disable Transmit Enable. */
  tdp->conf[0] &= ~((1<<7) | (1<<1));
}

/* Latch once on continuous external source (spacewire TDP). */
/* NOTE: This test depends on spacewire router which must not be clock gated at
 * this time. */
static void gptimer_test003(struct gptimer *lr, int irq)
{
  if (NULL == tdp) {
    fail(1);
  }

  int i;
  int ntimers;

  report_subtest(30);

  /* Setup GPTIMER to trig on spacewire router event. */
  lr->scalerload = 3;
  lr->scalercnt = 3;

  ntimers = lr->configreg & 0x7;
  for (i=0; i<ntimers; i++) {
    lr->timer[i].control = 0; // halt all timers
  }
  /* Latch timer values at Spacewire AMBA port 0 */
  lr->latchconfig = 0x00000002;
  lr->timer[0].counter = 0x20000000;
  lr->timer[0].reload =  0x20000000;
  /* Clear interrupt pending. Interrupt enable, load, enable. (but no restart) */
  lr->timer[0].control = (GPTIMER_IP | GPTIMER_IE | GPTIMER_LD | GPTIMER_EN);
  /* Enable latching on external event. */
  lr->configreg = GPTIMER_EL | 1<<13;
  if ((GPTIMER_EL | 1<<13) != (lr->configreg & (GPTIMER_EL | 1<<13))) {
    fail(2);
  }

  /* Record counter vaules before and after the latching. */
  unsigned int cbefore, cafter;
  cbefore = lr->timer[0].counter;
  timecode_start();
  /* Wait for latch. */
  while (lr->configreg & GPTIMER_EL);
  cafter = lr->timer[0].counter;
  /* Note that spw time code is still ticking... */

  /* Not expecting interrupt here. Counter is huge value. */
  if ((lr->timer[0].control & GPTIMER_IP)) {
    fail(3);
  }

  if (lr->timer[0].latch != lr->timer[0].latch) { fail(4); }
  if (lr->timer[0].latch == lr->timer[0].counter) { fail(5); }

  /* Verify that latch register is in a valid range. */
  if (cbefore < lr->timer[0].latch) {
    fail(6);
  }
  if (lr->timer[0].latch < cafter) {
    fail(7);
  }
  timecode_stop();
}

/*
 * Test the triggering timer latch from APB interrupt (interrupt timestamping).
 *
 * Configure GRGPIO0 to generate interrupt 16.
 * Configure GPTIMER to latch timer at interrupt time.
 * Make GRGPIO0 trigger interrupt X.
 * Verify that latch register is loaded.
 * Wait for timer interrupt.
 * Verify latch bit is cleared.
 */

static void gptimer_test002(struct gptimer *lr, int irq)
{
  int ntimers;
  if (NULL == gpio) {
    return;
  }
  /* Setup IO 0 for rising edge triggering. */
  gpio->irqmask = 0;
  gpio->irqpol = 1;
  gpio->irqedge = ~0;
  gpio->irqmap[0] = 0;
  gpio->iodir = 1;
  gpio->iooutput = 0;

  /* Enable interrupt for IO 0. */
  gpio->irqmask |= 1;

  ntimers = lr->configreg & 0x7;
  lr->scalerload = 7;
  lr->scalercnt = 7;

  int i;
  for (i=0; i<ntimers; i++) {
    lr->timer[i].control = 0; // halt all timers
  }

  /* Latch timer values at AMBA APB interrupt 16 */
  lr->latchconfig = 0x00010000;
  for (i=0; i<ntimers; i++) {
    report_subtest(100+10*i);
    lr->timer[i].counter = 0;
    lr->timer[i].reload = 0x7f;
    /* Clear interrupt pending. Interrupt enable, load, enable. (but no restart) */
    lr->timer[i].control = (GPTIMER_IP | GPTIMER_IE | GPTIMER_LD | GPTIMER_EN);

    /* Enable latching, but do not reload on matching interrupt. */
    lr->configreg = GPTIMER_EL;
    if (!(lr->configreg & GPTIMER_EL)) {
      fail(1000+100*i+6);
    }

    /* Record counter vaules before and after the latching. */
    unsigned int cbefore, cafter;
    cbefore = lr->timer[i].counter;
    gpio->iooutput |= 1;
    gpio->iooutput &= ~1;

    /* Wait for latch. */
    while (lr->configreg & GPTIMER_EL);
    cafter = lr->timer[i].counter;

    if ((lr->timer[i].control & GPTIMER_IP)) {
      fail(1000+100*i+7);
    }
    /* Wait for timer interrupt. */
    while (!(lr->timer[i].control & GPTIMER_IP));

    lr->timer[i].control = GPTIMER_IP;
    if (lr->timer[i].control & GPTIMER_IP) {
      fail(1000+100*i+8);
    }

    /* Verify that latch register is in a valid range. */
    if (cbefore < lr->timer[i].latch) {
      fail(1000+100*i+10);
    }
    if (lr->timer[i].latch < cafter) {
      fail(1000+100*i+11);
    }

    /* Test the Configuration register ES bit. */
    /* Enable reload on matching interrupt. */
    lr->configreg = GPTIMER_ES;
    if (!(lr->configreg & GPTIMER_ES)) {
      fail(1000+100*i+12);
    }

    lr->timer[i].control = (GPTIMER_IP | GPTIMER_IE | GPTIMER_LD | GPTIMER_EN | GPTIMER_RS);
    while (lr->timer[i].counter > 0x3f);
    /* Trig timestamping. */
    gpio->iooutput |= 1;
    gpio->iooutput &= ~1;

    if ((lr->configreg & GPTIMER_ES)) {
      fail(1000+100*i+13);
    }
    /* Did timer restart? */
    if (lr->timer[i].counter <= 0x3f) {
      fail(1000+100*i+14);
    }

    lr->timer[i].control = 0;
  }
}

static void gptimer_test001(struct gptimer *lr, int irq)
{
        int i, j, ntimers;

	ntimers = lr->configreg & 0x7;
	lr->scalerload = -1;
	
	/* enable first timer to make sure the scaler is ticking */
	lr->timer[0].counter = -1;
	lr->timer[0].control = 0x1;

	if (lr->scalercnt == lr->scalercnt) fail(1);

/* timer 1 test */

	lr->scalerload = 31;
	lr->scalercnt = 31;
	for (i=0; i<ntimers; i++) lr->timer[i].control = 0; // halt all timers
	
	/* test basic functions */
	for (i=0; i<ntimers; i++) {
	    report_subtest(i);
	    lr->timer[i].counter = 0;
	    lr->timer[i].reload = 15;
	    lr->timer[i].control = 0x6;
	    if (lr->timer[i].counter != 15) fail(3); // check loading
	    lr->timer[i].control = (0xf | GPTIMER_IP);
	    for (j=14; j >= 0; j--) { while (lr->timer[i].counter != j) {}}
	    while (lr->timer[i].counter != 15) {}
    
	    if (!(lr->timer[i].control & GPTIMER_IP)) fail(4);
	    lr->timer[i].control = GPTIMER_IP;
	    if (lr->timer[i].control & GPTIMER_IP) fail(5);
	}

	if (ntimers > 1) {		/* simple check of chain function */
	    report_subtest(CHAIN_TEST);
	    lr->timer[0].control = 0xf;
	    lr->timer[1].control = 0x2f;
	    while (lr->timer[1].counter != 13) {}
	}

	for (i=0; i<ntimers; i++) lr->timer[i].control = 0; // halt all timers
	
	if (irqmp_base) {
	    catch_interrupt(gptimer_irqhandler, irq);
	    init_irqmp(irqmp_base);
	    irqmp_base->irqmask = 1 << irq;	  /* unmask interrupt */
	    lr->timer[0].reload = 15;
	    lr->timer[0].control = 0xd;
	    asm("wr %g0, %g0, %asr19");		/* power-down */
	}

	/* TODO: Check value of static variable gpirq. */
}

int gptimer_test(int addr, int irq)
{
        struct gptimer *lr = (struct gptimer *) addr;

	report_device(0x01011000);
	gptimer_test001(lr, irq);
#if 0
	gptimer_test002(lr, irq);
	gptimer_test003(lr, irq);
#endif
	return 0;
}


/*
gptimer_test_pp(int addr, int irq)
{
    struct ambadev dev;

    if (find_ahb_slvi(&dev) == 0) 
        gptimer_test(dev.start[0], dev.irq);
}
*/
