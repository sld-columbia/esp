#include "testmod.h"
#include "irqmp.h"
#include "gptimer.h"

struct irqmp *irqmp_base;
static volatile int irqtbl[18];

irqhandler(int irq)
{
        irqtbl[irqtbl[0]] = irq + 0x10;
        irqtbl[0]++;
}

void init_irqmp(struct irqmp *lr)
{
        lr->irqlevel = 0;       /* clear level reg */
        lr->irqmask = 0x0;      /* mask all interrupts */
        lr->irqclear = -1;      /* clear all pending interrupts */
        irqtbl[0] = 1;	        /* init irqtable */
}
	
int irqtest(int addr)
{        
        int i, a, psr, nctrl, ctrl;
        volatile int marr[4];
        volatile int larr[4];
        struct irqmp *lr = (struct irqmp *) addr;
        irqmp_base = lr;

        report_device(0x0100d000);
        init_irqmp(lr);

        for (i=1; i<16; i++) catch_interrupt(irqhandler, i);

        nctrl = ((lr->asmpctrl >> 28) & 0xFF) + 1;

        for (ctrl = 0; ctrl < nctrl; ctrl++) {
                lr = (struct irqmp *) (addr + 0x1000*ctrl);
                
                if (nctrl > 1) report_subtest(ctrl);
                
                if (ctrl) {
                        /* This controller has not yet been initialized */
                        init_irqmp(lr);
                        /* Assign processor 0 to this controller */
                        lr->icsel0 = ctrl << 28;
                        if (((lr->icsel0 >> 28) & 0xFF) != ctrl) fail(18);
                }

                /* test that interrupts are properly prioritised */
                
                lr->irqforce = 0x0fffe;	/* force all interrupts */
                if (lr->irqforce != 0x0fffe) fail(1); /* check force reg */

                lr->irqmask = 0x0fffe;	  /* unmask all interrupts */
                if (lr->irqmask != 0x0fffe) fail(2); /* check mask reg */
                while (lr->irqforce) {};  /* wait until all iterrupts are taken */

                /* check that all interrupts were take in right order */
                if (irqtbl[0] != 16) fail(3);
                for (i=1;i<16;i++) { if (irqtbl[i] != (0x20 - i))  fail(4);}

                /* test priority of the two interrupt levels */

                irqtbl[0] = 1;			/* init irqtable */
                lr->irqlevel = 0xaaaa;	/* set level reg to  odd irq -> level 1 */
                lr->irqmask = 0xfffe;	        
                if (lr->irqlevel != 0xaaaa) fail(5); /* check level reg */
                if (lr->irqmask != 0xfffe) fail(5); /* check mask reg */
                lr->irqforce = 0x0fffe;	/* force all interrupts */
                while (lr->irqforce) {};  /* wait until all iterrupts are taken */

                /* check that all interrupts were take in right order */
                if (irqtbl[0] != 16) fail(6);
                for (i=1;i<8;i++) { if (irqtbl[i] != (0x20 - (i*2-1)))
                                fail(7);}
                for (i=2;i<8;i++) { if (irqtbl[i+8] != (0x20 - (i*2)))
                                fail(8);}

                /* check interrupts of multi-cycle instructions */

                marr[0] = 1; marr[1] = marr[0]+1; marr[2] = marr[1]+1; 
                a = marr[2]+1; marr[3] = a; larr[0] = 6;

                lr->irqlevel = 0;	/* clear level reg */
                lr->irqmask = 0x0;	/* mask all interrupts */
                irqtbl[0] = 1;		/* init irqtable */
                lr->irqmask = 0x00002;	  /* unmask interrupt */
                lr->irqforce = 0x00002;	/* force interrupt */

                asm(
                        "	mov  %asr17, %g1\n\t"
                        "	andcc %g1, 0x100, %g0\n\t"
                        "	be 1f\n\t"
                        "	nop \n\t"
                        "	umul %g0, %g1, %g0\n\t"
                        "	umul %g0, %g1, %g0\n\t"
                        "	umul %g0, %g1, %g0\n\t"
                        " 	1:\n\t"
                        "	");
                larr[1] = larr[0];
                if (larr[0] != 6) fail(10);
                lr->irqforce = 0x00002;	/* force interrupt */
                asm("nop;");
                larr[1] = larr[0];
                if (larr[0] != 6) fail(10);
                lr->irqforce = 0x00002;	/* force interrupt */
                asm("nop;");
                larr[1] = 0;
                if (larr[1] != 0) fail(11);

                while (lr->irqforce) {};  /* wait until all iterrupts are taken */

                /* check number of interrupts */
                if (irqtbl[0] != 4) fail(13);

                lr->irqmask = 0x0;	/* mask all interrupts */

                /* check that PSR.PIL work properly */

                lr->irqforce = 0x0fffe;	/* force all interrupts */
                irqtbl[0] = 1;		/* init irqtable */
                psr = xgetpsr() | (15 << 8);
                setpsr(psr); /* PIL = 15 */
                lr->irqmask =  0x0fffe;	/* enable all interrupts (no ext irq) */
                while (!lr->irqmask);   /* avoid compiler optimisation */
                if (irqtbl[0] != 2) fail(14);
                if (irqtbl[1] != 0x1f) fail(15);
                setpsr(xgetpsr() - (1 << 8));
                for (i=2;i<16;i++) { 
                        setpsr(xgetpsr() - (1 << 8));
                        if (irqtbl[0] != i+1) fail(16);
                        if (irqtbl[i] != (0x20 - i))  fail(17);
                }

                /* test optional secondary interrupt controller */
/*
	lr->irqmask = 0x0;
	lr->imask2 = 0x0;
	lr->ipend2 = 0x0;	
	lr->ipend2 = 0x1;
	if (!lr->ipend2) return(0);
	lr->ipend2 = -1;
	lr->imask2 = -1;
	for (i=lr->istat2 & 0x1f; i >=0; i--) {
		if ((lr->istat2 & 0x1f) != i) fail (17+i);
		lr->istat2 = (1 << i);
	        lr->irqclear = -1;
	}
	if (lr->istat2 & 0x20) fail (33);
	if (lr->irqpend) fail (34);
*/
                lr->irqmask = 0x0;	/* mask all interrupts */
                lr->irqclear = -1;	/* clear all pending interrupts */
        }

        if (nctrl > 1) {
                /* Test ASMP control register lock bit */
                lr = (struct irqmp *) addr;
                lr->icsel0 = 0;
                if (lr->icsel0) fail(19);
                lr->icsel0 = 1 << 28;
                if (lr->icsel0 != (1 << 28)) fail(20);
                lr->asmpctrl = 1; /* Set lock bit */
                lr->icsel0 = 0;
                if (lr->icsel0 != (1 << 28)) fail(21);
                lr->asmpctrl = 0; /* Disable lock */
                lr->icsel0 = 0;
                if (lr->icsel0) fail(22);
                /* Test ASMP control register ICF bit */
                lr->asmpctrl = 0x2; /* Set ICF bit */
                if ((lr->asmpctrl & 0x2) != 0x02) fail(23);
                lr->asmpctrl = 0; /* Unset ICF bit */
                if ((lr->asmpctrl & 0x2) != 0) fail(24);
        }

        return(0);
}



/*
 * irqtimestamp_test():
 * addr      - Address of GPIO port
 * imask     - Value of GPIO port imask generic
 * int width - With of GPIO port
 * pirq      - Value of GPIO port pirq generic
 * irqgen    - Value of GPIO port irqgen generic
 *
 * This test makes use of a GPIO port to test IRQ(A)MP
 * interrupt timestamping. irqmp_test() must be run before 
 * this test in order to initialize irqmp_base. This tests
 * exists primarily to excercise the interrupt assertion
 * timestamps as these cannot be triggered without using
 * IRQ(A)MP only.
 *
 * This test requires that the GPIO lines have external pull-ups 
 *
 */

static volatile int *pio;

static int irqts_irqhandler(int irq)
{
        /* Drive no line */
        pio[2] = 0;

        return 0;
}

int irqtimestamp_test_mask(int addr, int imask, int width, int pirq, int irqgen, int iomask)
{

        char exttimer0 = 0, exttimer1 = 0;
        int k, i, numirq, ntstamp;
        unsigned int tmp[2];
        struct irqmp *lr = irqmp_base;
        struct irqmp_ts *tr = (struct irqmp_ts *)((int)irqmp_base + 0x100);
        

        pio = (int *) addr; 
        /*
         * pio[0] = din
         * pio[1] = dout
         * pio[2] = dir
         * pio[3] = imask
         * pio[4] = level
         * pio[5] = edge
         * pio[6] = bypass
         * pio[7] = reserved
         * pio[8] = irqmap
         */ 

        ntstamp = tr->ctrl >> IRQTSC_TSTAMP;

        report_subtest(16);

        /* Check reset value of S1, S2 and KS */
        if ((tr->ctrl & (IRQTSC_S1 | IRQTSC_S2 | IRQTSC_KS)) != 0)
                fail(1);

        /* Check that interrupt timestamp counter is disabled */
        tmp[0] = tr->cnt;
        if (tmp[0] != tr->cnt) exttimer0 = 1;

        /* Check that interrupt timestamp counter starts */
        tr->ctrl = 1;
        tmp[0] = tr->cnt;
        if (tmp[0] == tr->cnt) exttimer1 = 1;

        if (exttimer1) {
                /* Possibly external timer */
                if (exttimer0) fail(2); /* timer was changing but then stopped? */
                /* Enable counter */
                tmp[1] =  ~(1 << 31);
                asm volatile("mov %0, %%asr22; nop; nop; nop "
                             :
                             : "r"(tmp[1])
                             );
                if (tmp[0] == tr->cnt) fail(3);
        } 
        if (!exttimer0 && !exttimer1) {
                /* Check that interrupt timestamp counter stops */
                tr->ctrl = 0;
                tmp[0] = tr->cnt;
                if (tmp[0] != tr->cnt) fail(4);
        }

        /* Set up interrupt handler */
        if (irqgen == 0) {
                /* Fixed mapping IO[i] = interrupt pirq + i */
                for (i=1; i <width; i++) {
                        if ((iomask & (1 << i)) == 0) continue;
                        if ((pirq+i) < 32) {
                                catch_interrupt(irqts_irqhandler, pirq+i);
                                /* Enable interrupt on IRQMP */
                                irqmp_base->irqmask |= (1 << (pirq+i));
                        }
                }
        } else if (irqgen == 1) {
                /* One shared interrupt pirq */
                catch_interrupt(irqts_irqhandler, pirq);
                /* Enable interrupt on IRQMP */
                irqmp_base->irqmask = (1 << pirq);

        } else {
                /* Core can map lines to irqgen interrupt lines */
                for (i=0; i < irqgen; i++) {
                        if ((pirq+i) < 32) {
                                catch_interrupt(irqts_irqhandler, pirq+i);
                                /* Enable interrupt on IRQMP */
                                irqmp_base->irqmask |= (1 << (pirq+i));
                        }
                }
        }

        pio[1] = 0; /* Prepare to drive all lines low */
        pio[4] = 0;  /* Interrupt level = low */
        pio[5] = -1; /* Edge */
        pio[3] = -1; /* Enable all interrupts */

        /* Iterate once for irqgen = 0, 1 and irqgen times for other values */
        for (k = 0; k < (irqgen ? irqgen : 1); k++) {

                /* Possibly remap interrupts */
                for (i = 0; (irqgen > 1) && (i < ((width+3)/4)); i++) {
                        pio[8+i] = (k << 24) | (k << 16) | (k << 8) | k;
                }

                /* Assert interrupts */
                for (i = irqgen ? 0 : 1; i < width; i++) {
                        if ((iomask & (1 << i)) == 0) continue;

                        /* Initialize interrupt timestamping */
                        if (irqgen == 0) {
                                /* Fixed mapping IO[i] = interrupt pirq + i */
                                tr->ctrl = pirq+i;
                        } else if (irqgen == 1) {
                                /* One shared interrupt pirq */
                                tr->ctrl = pirq;
                        } else {
                                /* Core can map lines to irqgen interrupt lines */
                                tr->ctrl = pirq+k;       
                        }
                        
                        /* Drive line i low */
                        pio[2] = (1 << i);
                
                        /* 
                         * Wait for interrupt, or skip to next if interrupt is masked. 
                         * Test may lock here if imask is wrong or core/connection is 
                         * bad.
                         */
                        if ((imask & (1 << i)) == 0) continue;
                        while(pio[2]);
                        
                        /* Interrupt has been taken and acknowledged */
                        if ((tr->ctrl & IRQTSC_S1) == 0) fail(5);
                        if ((tr->ctrl & IRQTSC_S2) == 0) fail(6);
                        tr->ctrl = IRQTSC_S1 | IRQTSC_S2;
                        if ((tr->ctrl & (IRQTSC_S1 | IRQTSC_S2)) != 0) fail(7);
                }
                pio[2] = 0;

                /* Check that keep stamp works */
                for (i = 0; i < 32 && ((imask & (1 << i)) == 0); i++);
                if (irqgen == 0) {
                        /* Fixed mapping IO[i] = interrupt pirq + i */
                        tr->ctrl = IRQTSC_KS | (pirq+i);
                } else if (irqgen == 1) {
                        /* One shared interrupt pirq */
                        tr->ctrl = IRQTSC_KS | pirq;
                } else {
                        /* Core can map lines to irqgen interrupt lines */
                        tr->ctrl = IRQTSC_KS | (pirq+k);       
                }
                /* Assert interrupt */
                pio[2] = (1 << i);
                while(pio[2]);
                /* Interrupt has been taken and acknowledged */
                if ((tr->ctrl & IRQTSC_KS) == 0) fail(8);
                if ((tr->ctrl & IRQTSC_S1) == 0) fail(9);
                if ((tr->ctrl & IRQTSC_S2) == 0) fail(10);
                /* Save stamp values */
                tmp[0] = tr->assert;
                tmp[1] = tr->ack;
                /* Assert interrupt again */
                pio[2] = (1 << i);
                while(pio[2]);
                if ((tr->ctrl & IRQTSC_KS) == 0) fail(11);
                if ((tr->ctrl & IRQTSC_S1) == 0) fail(12);
                if ((tr->ctrl & IRQTSC_S2) == 0) fail(13);
                /* Check that stamp values have been kept */
                if (tmp[0] != tr->assert) fail(14);
                if (tmp[1] != tr->ack) fail(15);
                /* Clear status and disable interrupt timestamping */
                tr->ctrl = IRQTSC_S1 | IRQTSC_S2;

        }
        pio[3] = 0; /* Mask all interrupts on GRGPIO */

        irqmp_base->irqmask = 0x0;  /* mask all interrupts */
        irqmp_base->irqclear = -1;  /* clear all pending interrupts */

        if (exttimer1) {
                 /* Disable counter*/
                tmp[0] = (1 << 31);
                asm volatile("mov %0, %%asr22; nop; nop; nop "
                             :
                             : "r"(tmp[0])
                             );
        }

        return 0;
}

int irqtimestamp_test(int addr, int imask, int width, int pirq, int irqgen)
{
  return irqtimestamp_test_mask(addr,imask,width,pirq,irqgen,-1);
}

/*
 * irqwdog_test():
 * addr      - Array with addresses to GPTIMER cores
 * timer     - timer[n] selects the timer to use on core addr[n]
 * ncores    - Number of positions in addr and timer arrays
 *
 * This test makes use of one or several GPTIMER units to 
 * test IRQ(A)MP watchdog functionality. irqmp_test() must 
 * be run before this test in order to initialize irqmp_base.
 *
 * This test assumes that timer timer[n]'s tick output on the 
 * GPTIMER core with addr[n] is connected to IRQ(A)MP watchdog 
 * input n.  
 *
 */
int irqwdog_test(unsigned int *addr, unsigned int *timer, unsigned int ncores)
{

        int i, t;
        struct gptimer *tr;
        struct irqmp *lr = irqmp_base;
        

        report_subtest(17);

        lr->wdogctrl = 0;
        if (!lr->wdogctrl) fail(1);

        if (((lr->wdogctrl >> IRQWDC_NWDOG) & 0x1f) < ncores) fail(2);

        for (i = 0; i < ncores; i++) {
                t = timer[i]-1;
                init_irqmp(lr);
                
                /* Initialize watchog interrupt */
                lr->wdogctrl = ((i + 1) << IRQWDC_WDOGIRQ) | (1 << i);
                /* unmask all interrupts */
                lr->irqmask = -1;

                /* Initialize timer unit */
                tr = (struct gptimer*)addr[i];
                tr->scalerload = 31;
                tr->scalercnt = 31;
                /* Start timer */
                tr->timer[t].counter = 5;
                tr->timer[t].reload = 0;
                
                tr->timer[t].control = 0x1;
                /* Wait for timer to underflow */
                while (tr->timer[t].counter != 0) {}
                while (tr->timer[t].counter == 0) {}

                /* Disable timer */
                tr->timer[t].control = 0; 

                if (irqtbl[0] != 2) fail(3+i*2);

                if (irqtbl[1] != (i + 1 + 0x10)) fail(3+i*2+1);
                
                /* Clear watchdog interrupt */
                lr->wdogctrl = 0;
        }

        irqmp_base->irqmask = 0x0;  /* mask all interrupts */
        irqmp_base->irqclear = -1;  /* clear all pending interrupts */
        
        return 0;
}

