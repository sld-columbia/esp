/************************************************************************/
/*   This file is a part of the mkprom3 boot-prom utility               */
/*   Copyright (C) 2004 Cobham Gaisler AB                             */
/*                                                                      */
/*   This library is free software; you can redistribute it and/or      */
/*   modify it under the terms of the GNU General Public                */
/*   License as published by the Free Software Foundation; either       */
/*   version 2 of the License, or (at your option) any later version.   */
/*                                                                      */
/*   See the file COPYING.GPL for the full details of the license.      */
/************************************************************************/

#define VENDOR_GAISLER   1
#define GAISLER_APBMST   0x006
#define GAISLER_IRQMP    0x00D
#define GAISLER_AHB2AHB  0x020
#define GAISLER_DDR2SPA  0x02E
#define GAISLER_DDRSPA   0x025
#define GAISLER_SDCTRL       0x009
#define GAISLER_GRIOMMU      0x04F
#define GAISLER_L2CACHE      0x04B
#define GAISLER_FTMCTRL      0x054
#define GAISLER_FTSRCTRL     0x051
#define GAISLER_APBUART      0x00c
#define GAISLER_GPTIMER      0x011
#define GAISLER_GRTIMER      0x038
#define GAISLER_SPIMCTRL     0x045
#define GAISLER_FTSDCTRL64   0x058
#define GAISLER_DDRSDMUX     0x05d
#define GAISLER_SDCTRL64     0x04c
#define GAISLER_FTAHBRAM     0x050

#define ESA_MCTRL            0x00f
#define VENDOR_ESA           4

#define LEON3_IO_AREA 0xfff00000
#define LEON3_CONF_AREA 0xff000
#define LEON3_AHB_SLAVE_CONF_AREA (1 << 11)

	.seg    "text"
	.global _prom_registers_init, multibus_scan, bridge, bridge_ioarea

/* #define BOOTLOADER_DISABLE_DSU_ON_STARTUP */
	
	.global _dsustart, _dsutrace, MCTRL, FTMCTRL, FTSRCTRL

/* note: keep this routine at < 0x1000 if mctrl-rom is preinit for range 0-0x1000 at startup */
	
_prom_registers_init:

#ifndef BOOTLOADER_DISABLE_DSU_ON_STARTUP
	set	_dsutrace, %g1
	ld	[%g1], %g1
	cmp	%g1, %g0
	beq	Lnodsu
	 set	_dsustart, %g1
	ld	[%g1], %g1
	
	/* Init DSU instruction and AHB trace */
	set	_dsuctrl, %g2
	ld	[%g2], %g2
	/*set	0xef, %g2*/
	st	%g2, [%g1]
	nop
	set	1, %g2
	st	%g2, [%g1+0x40]
	
Lnodsu:
#endif
	
	mov	%o7, %g4

	set	0x81000f, %g2
	
	set	LEON3_IO_AREA | LEON3_CONF_AREA | 0xff0, %o0
	ld	[%o0], %o1
	/* grlib_deviceid = (j>>16); */
	srl	%o1,16,%o2
	/*grlib_buildid = (j&0xffff);*/
	set	0xffff, %o3
	and	%o2,%o3,%o2
	and	%o1,%o3,%o3

	/*
	if ((grlib_deviceid == 0x699) && (grlib_buildid == 2564)) {
	    cachectrl &= ~(1<<23);	// disable snooping on UT699 version A
        }	
	*/
	set	0x699, %o1
	cmp	%o2, %o1
	bne     nout699
	 set	2564, %o1
	cmp	%o3, %o1
	bne     nout699
	 set 	~(1<<23), %o1
	and	%g2,%o1,%g2
	
nout699:	
	sta	%g2, [%g0] 2	        ! enable LEON3 cache
	
        set	_nopnp, %o0
	ld	[%o0],%o0
	cmp	%o0, %g0
	bne	directinit
	 nop

	set	_pnp, %g5
	ld	[%g5], %g5 /* default: 0xFFFFF800 */
	set	0xfffff, %o0
	andn  	%g5,%o0,%g5
	
recur_point:	
	/* do not modify %g4. %g4 is the return addr */

	/*********************************************************/
	/* ************ gaisler ddrsdmux mctrl *************/
LLddrsdmux:	
	set VENDOR_GAISLER, %o0
	set GAISLER_DDRSDMUX, %o1
	call mkprom_ahbslv_scan
	nop

	cmp %g0,%o0
	be 1f               /* Try next controller */
	 nop

	ld [%o0+16+4],%g1            /* get io bar */
	set LEON3_IO_AREA,%o0
	and %g1,%o0,%g1
	srl %g1,12,%g1
	/*or  %g1,%o0,%g1*/
	or  %g1,%g5,%g1

	/* 0000 - GAISLER_DDR2SP, 0001 - GAISLER_SDCTRL, 0010 - GAISLER_DDRSP, 0011 - GAISLER_SSRCTRL */
	ld	[%g1+0x20], %o0
	srl	%o0,12,%o0
	and	%o0,0xf,%o0
	
	/* GAISLER_DDR2SP */
	cmp	%o0,0
	beq	LL1ddr2spamux
	 nop
	cmp	%o0,1
	beq	LLsdrammux
	 nop
	cmp	%o0,2
	beq	LL1ddrspamux
	 nop
	
	/* GAISLER_SSRCTRL not supported yet */
	/* fall through */

1:	
	
	/*********************************************************/
	/* ************ gaisler DDR2 ctrl (DDR2SPA) ************ */
	
LL1ddr2spa:

        set VENDOR_GAISLER, %o0
        set GAISLER_DDR2SPA, %o1
        call mkprom_ahbslv_scan
        nop
        
        cmp %g0,%o0
        be LL1ddrspa                ! Scan for DDR controller
         nop

        ld [%o0+16+4],%g1            ! get io bar
        set LEON3_IO_AREA,%o0
        and %g1,%o0,%g1
	srl %g1,12,%g1
        /*or  %g1,%o0,%g1*/
	or  %g1,%g5,%g1
	
LL1ddr2spamux:
	
/* hardcode conservative value 200 mhz*/
#define BOOTLOADER_FREQ_KHZ 200000
	
	/* Wait 1.2ms for DDR memory. The DDR module requires a 200us of clocks before use.
	 * One loop takes 5 clocks. */ 
	set	((BOOTLOADER_FREQ_KHZ*1200/1000)/5+1), %o1
.LL1ddr2spa_wait1200us:
	nop
	nop
	subcc	%o1,1,%o1
	bne	.LL1ddr2spa_wait1200us
	 nop

#ifndef NGMP_PRE_BUS

        set	_ddr2spa_cfg1, %o0
	ld	[%o0],%o0
	st	%o0, [%g1]           ! Set DDR2CFG1
	set	_ddr2spa_cfg3, %o0
	ld	[%o0],%o0
	cmp	%o0, %g0
	beq	ddr2spa_checkcfg4
	 nop
	
	st	%o0, [%g1+0x08]      ! Set DDR2CFG3
ddr2spa_checkcfg4:
	
	set	_ddr2spa_cfg4, %o0
	ld	[%o0],%o0
	cmp	%o0, %g0
	beq	1f
	 nop
	
	/*set	1<<8, %o1*/            /* no 8bank during power-on init */
	/*andn    %o0,%o1,%o0*/
	st	%o0, [%g1+0x0C]      ! Set DDR2CFG4
	
1:
	/* perform power-on init */
	set	_ddr2spa_cfg1, %o0
	ld	[%o0],%o0
	set	1<<31, %o1           /* no refresh */
	andn    %o0,%o1,%o0
	set	1<<16, %o1           /* init */
	or      %o0,%o1,%o0
	
	st	%o0, [%g1]           ! DDR2CFG1

	/* wait 200us */
	set	((BOOTLOADER_FREQ_KHZ*1200/1000)/1+1), %o1
.LL1ddr2spa_wait1200us_init:
	nop
	nop
	subcc	%o1,1,%o1
	bne	.LL1ddr2spa_wait1200us_init
	 nop
	
	/* reset config values */
	set	_ddr2spa_cfg1, %o0
	ld	[%o0],%o0
	st	%o0, [%g1]           ! Set DDR2CFG1
	
	set	_ddr2spa_cfg4, %o0
	ld	[%o0],%o0
	cmp	%o0, %g0
	beq	1f
	 nop
	st	%o0, [%g1+0x0C]      ! Set DDR2CFG4
1:      
	
	
#endif
	
	/*********************************************************/
 	/************* gaisler DDR ctrl (DDRSPA) ************    */
	
LL1ddrspa:
	
	set VENDOR_GAISLER, %o0
	set GAISLER_DDRSPA, %o1
	call mkprom_ahbslv_scan
	nop
        
	cmp %g0,%o0
	be 1f                ! assuming sram/prom ctrl
	nop

        ld [%o0+16+4],%g1            ! get io bar
        set LEON3_IO_AREA,%o0
        and %g1,%o0,%g1
	srl %g1,12,%g1
        /*or  %g1,%o0,%g1*/
        or  %g1,%g5,%g1

LL1ddrspamux:
	
	/* Wait 1.2ms for DDR memory. The DDR module requires a 200us of clocks before use.
	 * One loop takes 5 clocks.
	 */ 
	set	((BOOTLOADER_FREQ_KHZ*1200/1000)/5+1), %o1
LL1ddrspa_wait1200us:
	nop
	nop
	subcc	%o1,1,%o1
	bne	LL1ddrspa_wait1200us
	 nop
	
        set	_ddrspa_cfg1, %o0
	set	0x10000, %o1
	ld	[%o0], %o0
	or	%o0, %o1, %o0
	st	%o0, [%g1]          ! Set SDCTRL

LL1ddrspa_wait_initdone:
	ld	[%g1], %o0
	andcc	%o1,%o0,%o0
	bne	LL1ddrspa_wait_initdone
	 nop

1:	

	/*********************************************************/
	/* ************ gaisler sdram mctrl *************/
LLsdram:	
	set VENDOR_GAISLER, %o0
	set GAISLER_SDCTRL, %o1
	call mkprom_ahbslv_scan
	nop

	cmp %g0,%o0
	be 1f               /* Try next memory controller */
	 nop

	ld [%o0+16+4],%g1            /* get io bar */
	set LEON3_IO_AREA,%o0
	and %g1,%o0,%g1
	srl %g1,12,%g1
	/*or  %g1,%o0,%g1*/
	or  %g1,%g5,%g1

LLsdrammux:	
	
        set	_sdmemcfg1, %o0
	ld	[%o0], %o0
	st	%o0, [%g1 ]

1:	
	/*********************************************************/
	/* ************ gaisler ftsdram64 mctrl *************/
LLftsdram64:	
	set VENDOR_GAISLER, %o0
	set GAISLER_FTSDCTRL64, %o1
	call mkprom_ahbslv_scan
	nop

	cmp %g0,%o0
	be 1f               /* Try next memory controller */
	 nop

	ld [%o0+16+4],%g1            /* get io bar */
	set LEON3_IO_AREA,%o0
	and %g1,%o0,%g1
	srl %g1,12,%g1
	/*or  %g1,%o0,%g1*/
	or  %g1,%g5,%g1
	
        set	ftsdctrl64_cfg, %o0
	ld	[%o0], %o0
	st	%o0, [%g1 ]
        set	ftsdctrl64_pwr, %o0
	ld	[%o0], %o0
	st	%o0, [%g1 + 4]

1:

	/*********************************************************/
	/* ************ gaisler sdram64 mctrl *************/
LLsdram64:	
	set VENDOR_GAISLER, %o0
	set GAISLER_SDCTRL64, %o1
	call mkprom_ahbslv_scan
	nop

	cmp %g0,%o0
	be 1f               /* Try next memory controller */
	 nop

	ld [%o0+16+4],%g1            /* get io bar */
	set LEON3_IO_AREA,%o0
	and %g1,%o0,%g1
	srl %g1,12,%g1
	/*or  %g1,%o0,%g1*/
	or  %g1,%g5,%g1
	
        set	ftsdctrl64_cfg, %o0
	ld	[%o0], %o0
	st	%o0, [%g1 ]
        /*set	ftsdctrl64_pwr, %o0
	ld	[%o0], %o0
	st	%o0, [%g1 + 4]
	*/

1:

	/*********************************************************/
	/* ************ gaisler spimctrl  *************/
	
LLspimctrl:	
	set VENDOR_GAISLER,   %o0
	set GAISLER_SPIMCTRL, %o1
	call mkprom_ahbslv_scan
	nop

	cmp %g0,%o0
	be 1f               /* Try next memory controller */
	 nop

	ld [%o0+16],%g1            /* get io bar */
	set LEON3_IO_AREA,%o0
	and %g1,%o0,%g1
	srl %g1,12,%g1
	/*or  %g1,%o0,%g1*/
	or  %g1,%g5,%g1
	
	set	_spimcfg, %o0
	ld	[%o0], %o0
	st	%o0, [%g1 + 0x4]        ! Set SPIMCTRL cfg register 
        
1:	

 	/*********************************************************/
	/* *************** start apb scans ***************** */
	
	/*********************************************************/
	/* ************ gaisler APMMST ************ */
	
LLapbmaster:	
	
        set VENDOR_GAISLER, %o0
        set GAISLER_APBMST, %o1
        call mkprom_ahbslv_scan
        nop
        
        cmp %g0,%o0
        be apbout
         nop
        
        ld [%o0+16],%g1
        set LEON3_IO_AREA,%o0
        and %g1,%o0,%g1            /*g1: apb base*/

        set LEON3_CONF_AREA,%o0
        or %g1,%o0,%g2             /*g2: apb conf base*/

	




	/*********************************************************/
 	/* ************ IRQ  ************                        */
	
apb_irq_init:
	mov %g2,%o0
        set VENDOR_GAISLER, %o1
        set GAISLER_IRQMP,%o2
        call mkprom_apbslv_scan
         mov %g0, %o6
        
        cmp %g0,%o0
        be 1f
         nop
        
        call mkprom_iobar_getbase
         mov %g1,%o1
        
        st    %g0, [%o1 + 0x0]  /*irq pri   */
        st    %g0, [%o1 + 0x4]  /*irq pend */  
        st    %g0, [%o1 + 0x8]  /*irq force */
        st    %g0, [%o1 + 0xC]  /*irq clear */
	
1:

	/*********************************************************/
 	/* ************ UART  ************                        */

apb_uart_init:
	mov %g0,%g3
apb_uart_init_loop:	
        mov %g2,%o0
        set VENDOR_GAISLER, %o1
        set GAISLER_APBUART,%o2
        call mkprom_apbslv_scan
         mov %g3, %o6

        cmp %g0,%o0
        be 1f
         nop
        
        call mkprom_iobar_getbase
         mov %g1,%o1
        
	set	_uart, %o0		! Load UART scaler register
	ld	[%o0], %o0
  	st	%o0, [%o1 + 0xc]	! leon3 uart scalar register
	nop
	set	3, %o0			! Enable UART
  	st	%o0, [%o1 + 0x8]	! leon3 uart ctrl register
	st	%g0, [%o1 + 0x4]	! leon3 uart status register

	add	%g3,1,%g3
	ba	apb_uart_init_loop
	 nop
	
1:	

	/*********************************************************/
 	/* ************ GPTIMER timer  ************                        */
gptimer_timer_init:
	set (GAISLER_GPTIMER << 16), %g3
	/* Count number of visited timers in %l0, starting at 0. */
	set	0, %l0
apb_timer_init_loop:	
        mov %g2,%o0
        set VENDOR_GAISLER, %o1
        srl	%g3, 16, %o2
        call mkprom_apbslv_scan
         and %g3, 0xff, %o6

        cmp %g0,%o0
        be 1f
         nop
        
        call mkprom_iobar_getbase
         mov %g1,%o1

	add	%o1, 0x10, %o3          ! base timer 0
	ld	[%o1+8], %o0		! load config reg
	andcc	%o0, 7, %o0
	beq	.Linitfirstsubtimer
	 nop

.Lforsubtimer:
	/* Is this the last subtimer of the timer core? */
	subcc	%o0, 1, %o0
	bne	.Linitanysubtimer
	 nop

	/* This is last subtimer. Is it on the first timer core? */
	cmp	%g0, %l0
	beq	.Linitwatchdog
	 nop

.Linitanysubtimer:
	/* Initialize subtimers [1, GPTIMER.CONF.TIMERS-1]. But not watchdog. */
	st	%g0, [%o3+0]
	st	%g0, [%o3+4]
	st	%g0, [%o3+8]
	add	%o3, 0x10, %o3
	cmp	%g0, %o0
	bne	.Lforsubtimer
	 nop
	ba	.Linitfirstsubtimer
	 nop

.Linitwatchdog:
	/* Initialize watchdog subtimer */
	set	300000000, %o0		! time-out value 5 minutes
	st	%o0, [%o3]	! leon3 watchdog count register 
	st	%o0, [%o3+4]	! leon3 watchdog reload register
	/* Do not touch watchdog subtimer control register */

.Linitfirstsubtimer:
	set	freq, %o0		! leon3 Load timer scaler register
	ld	[%o0], %o0
	sub	%o0, 1, %o0

  	st	%o0, [%o1 + 0x4]	! leon3 timer prescalar reload register 
  	st	%o0, [%o1 + 0x0]	! leon3 timer prescalar count register 
	nop
	set	-1, %o0
	st	%o0, [%o1 + 0x10]	! leon3 timer1 count register 
	st	%o0, [%o1 + 0x14]	! leon3 timer1 reload register 
	nop
	set	7, %o0
	st	%o0, [%o1 + 0x18]	! leon3 timer1 ctrl register 

	add	%g3,1,%g3
	add	%l0,1,%l0
	ba,a	apb_timer_init_loop

1:
	/*********************************************************/
 	/* ************ GRTIMER timer - same init as for GPTIMER ************ */
grtimer_timer_init:
	srl	%g3, 16, %g3
	cmp	%g3, GAISLER_GRTIMER
	beq	1f
	 set (GAISLER_GRTIMER << 16), %g3
	ba,a	apb_timer_init_loop

1:
	/*********************************************************/
 	/* ************ ESA MCTRL ctrl ************ */

MCTRL:
	mov %g2,%o0                  /* esa mctrl */
        set VENDOR_ESA, %o1
        set ESA_MCTRL,%o2
        call mkprom_apbslv_scan
         mov %g0, %o6
         
        cmp %g0,%o0
        be 1f
         nop

        call mkprom_iobar_getbase
         mov %g1,%o1

	st      %g0, [%o1 + 0x08]
	
	set	_memcfg1, %o0
	ld	[%o0], %o0
	nop
	ld	[%o1+0x00], %o2		
	and	%o2, 0x300, %o2
	andn	%o0, 0x300, %o0
	or	%o0, %o2, %o0
  	st	%o0, [%o1 + 0x00]
	set	_memcfg2, %o0
	ld	[%o0], %o0
	st	%o0, [%o1 + 0x04]

	set	_memcfg3, %o0
	ld	[%o0], %o0
	nop
	ld	[%o1 + 0x08],%o2
	set	0x100, %o3		! dont write PROM edac enable (bit 8), set from external PIN
	and	%o2, %o3, %o2
  	andn	%o0, %o3, %o0
	or	%o0, %o2, %o0
		
	st	%o0, [%o1 + 0x08]
	
1:
	/*********************************************************/
 	/* ************ Gaisler FTMCTRL ctrl ************ */
FTMCTRL:	
	mov %g2,%o0
        set VENDOR_GAISLER, %o1
        set GAISLER_FTMCTRL,%o2
        call mkprom_apbslv_scan
         mov %g0, %o6
         
        cmp %g0,%o0
        be 1f
         nop

        call mkprom_iobar_getbase
         mov %g1,%o1

	set	_memcfg1, %o0		/* Load memory config register 1 */
	ld	[%o0],%o0
	nop
	ld	[%o1+0x00], %o2
	and	%o2, 0x300, %o2				/* Preserve PROM width */
	andn	%o0, 0x300, %o0				/* Preserve PROM width */
	or	%o0, %o2, %o0
  	st	%o0, [%o1 + 0x00]
	set	_memcfg2, %o0		/* Load memory config register 2 */
	ld	[%o0],%o0
	st	%o0, [%o1 + 0x04]
	set	_memcfg3, %o0
	ld	[%o0],%o0
	nop
	ld	[%o1 + 0x08],%o2
	set	0x100, %o3		! dont write PROM edac enable (bit 8), set from external PIN
	and	%o2, %o3, %o2
  	andn	%o0, %o3, %o0
	or	%o0, %o2, %o0
	st	%o0, [%o1 + 0x08]

1:	
	/*********************************************************/
 	/* ************ Gaisler FTSRCTRL ctrl ************ */
	
FTSRCTRL:
	mov %g2,%o0
        set VENDOR_GAISLER, %o1
        set GAISLER_FTSRCTRL,%o2
        call mkprom_apbslv_scan
         mov %g0, %o6
         
        cmp %g0,%o0
        be 1f
         nop

        call mkprom_iobar_getbase
         mov %g1,%o1

	set	_memcfg1, %o0		/* Load memory config register 1 */
	ld	[%o0], %o0
  	st	%o0, [%o1 + 0x00]

	set	_memcfg2, %o0		/* Load memory config register 2 */
	ld	[%o0], %o0
	st	%o0, [%o1 + 0x04]

	set	_memcfg3, %o0		/* Load memory config register 3 */
	ld	[%o0], %o0
	nop
	ld	[%o1 + 0x08],%o2
	set	0x100, %o3		! dont write PROM edac enable (bit 8), set from external PIN
	and	%o2, %o3, %o2
  	andn	%o0, %o3, %o0
	or	%o0, %o2, %o0
	
	st	%o0, [%o1 + 0x08]

1:
	/*********************************************************/
 	/* ************ Gaisler FTAHBRAM  ************           */
FTAHBRAM:
	mov %g2,%o0
        set VENDOR_GAISLER, %o1
        set GAISLER_FTAHBRAM,%o2
        call mkprom_apbslv_scan
         mov %g0, %o6

        cmp %g0,%o0
        be 1f
         nop

        call mkprom_iobar_getbase
         mov %g1,%o1

        sethi	%hi(ftahbram_cfg), %o0
	ld	[%o0 + %lo(ftahbram_cfg)], %o0	! Load Config reg settings
	st	%o0, [%g1]			! Configuration Register

1:
apbout:	
	/*********************************************************/
	/* *************** start multibus  ***************** */

multibus_scan:
	mov	%g5, %o5
	set	0xff800, %o3
	or	%o5, %o3, %o5
	
	/*set	_pnp, %o5
	  ld	[%o5], %o5 */ /* default: 0xFFFFF800 */
	/*mov	-2048, %o5*/ 
	mov	0, %o3
	sll	%o3, 5, %o0
.LL112:
	add	%o5, %o0, %o4
	ld	[%o5+%o0], %o2
	srl	%o2, 24, %o0
	cmp	%g1, VENDOR_GAISLER
	bne,a	.LL102
	add	%o3, 1, %o3
	srl	%o2, 12, %o0
	and	%o0, 4095, %o0

#ifdef NGMP_PRE_BUS
	ba	.LL120
	 nop
#endif
	
	cmp	%o0, GAISLER_AHB2AHB
	beq	bridge
	 nop
	cmp	%o0, GAISLER_GRIOMMU
	beq	bridge
	 nop
	cmp	%o0, GAISLER_L2CACHE
	bne	.LL120
	 nop

	/* disable l2 cache */
	ld	[%o4 + ((4+1) * 4)], %o2 /* reg area at mem[1]  */
	set	0xFFF00000, %o6
	and	%o2, %o6, %o2
	ld	[%o2+0],%o6
	set	0x80000000, %o1
	andn	%o6, %o1, %o6
	/*st	%o6, [%o2+0]*/ /* disable */
	
bridge:
	/* pseudo recursion, bus nesting depth cannot exceed regster windows */
	save
	
	mov	%g4,%l4 /* ret addr */
	mov	%g5,%l5 /* io area */
	mov	%i0,%l6 /* bridge id */

bridge_ioarea:	
	ld	[%i4 + (2 * 4)], %g4 /* if custom_cfg[1] == 0 dont recurse  */ 
	cmp	%g4, %g0
	 beq	no_recur

	/* >>>>>>> detect endless recursion >>>>>>> */
	
	rd	%psr, %g3
	set	8, %g2
	
1:	cmp	%g4, %l5
	beq	avoid_cycle
	 nop
	
	restore
	
	subcc	%g2, 1, %g2
	bne	1b
	 nop
	
	wr	%g3, %psr
	nop
	nop
	nop
	ba	no_cycle
 	 nop
	
	! cyclic recursion in case of bidirectional bus detected 
avoid_cycle:	
	wr	%g3, %psr
	nop
	nop
	nop
	ba	no_recur
	 nop
	
	/* <<<<<<< detect endless recursion <<<<<<< */

no_cycle:	
	set	recur_point, %g5
	jmpl	%g5, %g4
	 ld	[%i4 + (2 * 4)], %g5 /* io area at custom_cfg[1] | 0xff000 */ 
	
no_recur:
	mov	%l4,%g4
	mov	%l5,%g5
	mov	%l6,%i0
	
	restore
	
.LL120:
#ifdef NGMP_PRE_BUS
	ba	.LL12012
	 nop
#endif
	
	cmp	%o0, GAISLER_L2CACHE
	bne	.LL12012
	 nop
	
	/* invalidate and enable l2 cache */
	ld	[%o4 + ((4+1) * 4)], %o2 /* reg area at mem[1]  */ 
	set	0xFFF00000, %o6
	and	%o2, %o6, %o2
	ld	[%o2+8],%o6
	and	%o6, 0x7, %o6
	or	%o6, 0x5, %o6
	st	%o6, [%o2+8]
	
	ld	[%o2+0],%o6
	set	0x80000000, %o1
	andn	%o6, %o1, %o6
	st	%o6, [%o2+0]  /* disable */
	
.LL12012:
	mov	%o4, %o2
	add	%o3, 1, %o3
.LL102:
	cmp	%o3, 7
	bleu,a	.LL112
	sll	%o3, 5, %o0
	mov	0, %o2

multibusout:	
	ba	initout
	 nop


/************************************************************/
/****************** simple init *****************************/	
directinit:	

	/* leon3 */	
	set	_memcaddr, %g1
	ld	[%g1], %g1		
	set	0x81000f, %g2
  	sta	%g2, [%g0] 2	        ! enable LEON3 cache

	/* use ddr instead */
	set	_isddr, %g2
	ld	[%g2], %g2
	nop

	/* ********* non-ddr mctrls **********/
	st      %g0, [%g1 + 0x08]

	cmp	%g2, %g0
	bne	directddr
	 nop

	/* leon3 */
	set	_memcfg1, %g2		! leon3 Load memory config register 1
	ld	[%g2], %g2
	nop
  	ld	[%g1], %g3		! 
	and	%g3, 0x300, %g3
	or	%g2, %g3, %g2
  	st	%g2, [%g1 + 0x00]
	set	_memcfg2, %g2		! leon3 Load memory config register 2
	ld	[%g2], %g2
  	st	%g2, [%g1 + 0x04]
	set	_memcfg3, %g2		! leon3 Load memory config register 3
	ld	[%g2], %g2
	st	%g2, [%g1 + 0x08]
	ba	directirq
	 nop

	/* ********* ddr mctrls **********/
directddr:
	/* Wait 1.2ms for DDR memory. The DDR module requires a 200us of clocks before use.
	 * One loop takes 5 clocks.
	 */ 
	set	((BOOTLOADER_FREQ_KHZ*1200/1000)/5+1), %g2
.LL1ddr2spa_wait1200us_2:
	nop
	nop
	subcc	%g2,1,%g2
	bne	.LL1ddr2spa_wait1200us_2
	 nop

        set	_ddr2spa_cfg1, %g2
	ld	[%g2],%g2
	st	%g2, [%g1]           ! Set DDR2CFG1
	set	_ddr2spa_cfg3, %g2
	ld	[%g2],%g2
	cmp	%g2, %g0
	beq	1f
	 nop
	
	st	%g2, [%g1+0x08]      ! Set DDR2CFG3
1:
	set	_ddr2spa_cfg4, %g2
	ld	[%g2],%g2
	cmp	%g2, %g0
	beq	2f
	 nop
	
	st	%g2, [%g1+0x0C]      ! Set DDR2CFG4
2:
	
	
directirq:	
	/* IRQ Controller
	 * g3 = CPU Index
	 * g2 = CPU Address offset
	 * g1 = Base Address IRQ CTRL
	 */
	set	_irqmpaddr, %g1
	ld	[%g1], %g1
	set	0xffffffff, %g3
	st	%g0, [%g1 + 0x0]  /* irq pri */
        st	%g0, [%g1 + 0x4]  /* irq pend */  
        st	%g0, [%g1 + 0x8]  /* irq force */
        st	%g3, [%g1 + 0xC]  /* irq clear */

	/* Clear all CPUs Force and Mask register */
	mov	%g0, %g3
irqcpuinit:
	sll	%g3, 2, %g2
	add	%g1, %g2, %g2
	st	%g0, [%g2 + 0x40]  /* CPU[N] Mask */
        st	%g0, [%g2 + 0x80]  /* CPU[N] force */

	cmp	%g3, 15
	bne	irqcpuinit
	 inc	%g3

	set	freq, %g2		! leon3 Load timer scaler register
	ld	[%g2], %g2
	sub	%g2, 1, %g2

	/* leon3 */
	set	_gptaddr, %g1
	ld	[%g1], %g1	
	set	-1, %g3
  	st	%g2, [%g1 + 0x4]	! leon3 timer prescalar reload register 
  	st	%g2, [%g1 + 0x0]	! leon3 timer prescalar count register 
	st	%g3, [%g1 + 0x10]	! leon3 timer1 count register 
	st	%g3, [%g1 + 0x14]	! leon3 timer1 reload register 
	nop
	set	7, %g3
	st	%g3, [%g1 + 0x18]	! leon3 timer1 ctrl register 

	/* Get number of UARTs to configure */
	set	_uartnr, %g3
	ld	[%g3], %g3

	/* Configure all APBUARTs, one at a time. From UART[N-1] down to UART[0] */
uartinit:
	cmp	%g3, 0
	beq	initout
	 dec	%g3

	sll	%g3, 2, %g2		! Index to Address offset
	set	_uaddr, %g1
	ld	[%g1+%g2], %g1		! Get Address of UART[i]

	/* leon3 */
	set	_uart, %g2		! Load UART scaler register
	ld	[%g2], %g2
  	st	%g2, [%g1 + 0xc]	! leon3 uart scalar register
	nop
	set	3, %g2			! Enable UART
  	st	%g2, [%g1 + 0x8]	! leon3 uart ctrl register
	st	%g0, [%g1 + 0x4]	! leon3 uart status register
	ba	uartinit
	 nop

initout:	
	mov	%g0, %y 		! Init Y-register

 	jmpl 	%g4+8, %g0
	 nop
	

	.global  mkprom_ahbslv_scan	
	.align 4


mkprom_ahbslv_scan:
	mov	%o0, %g1
	mov	%g5, %o5
	set	0xff800, %o3
	or	%o5, %o3, %o5
	
	/* set	_pnp, %o5
	   ld	[%o5], %o5 */ /* default: 0xFFFFF800 */
	/*mov	-2048, %o5*/ 
	mov	0, %o3
	sll	%o3, 5, %o0
.LL11:
	add	%o5, %o0, %o4
	ld	[%o5+%o0], %o2
	srl	%o2, 24, %o0
	cmp	%o0, %g1
	bne,a	.LL10
	add	%o3, 1, %o3
	srl	%o2, 12, %o0
	and	%o0, 4095, %o0
	cmp	%o0, %o1
	be	.LL1
	mov	%o4, %o2
	add	%o3, 1, %o3
.LL10:
	cmp	%o3, 7
	bleu,a	.LL11
	sll	%o3, 5, %o0
	mov	0, %o2
.LL1:
	retl
	mov	%o2, %o0


!unsigned int mkprom_apbslv_scan(register unsigned int base,register unsigned int vendor, register unsigned int driver) {
!  register unsigned int conf, mbar,i, *confp;
!  for (i = 0; i < LEON3_APB_SLAVES; i++) 
!  {
!    confp = (unsigned int*)(base + (i * LEON3_APB_CONF_WORDS * 4));
!    conf = *confp;
!    //mbar = *(unsigned int*)(i * LEON3_AHB_CONF_WORDS+ (4 * 4));
!    if ((amba_vendor(conf) == vendor) && (amba_device(conf) == driver)) {
!      return (unsigned int)confp;
!    }
!  }
!  return 0;
!}

	.section	".text"
	.align 4
	.global  mkprom_apbslv_scan
	
mkprom_apbslv_scan:
	mov	%o0, %g1
	mov	0, %o4
	sll	%o4, 3, %o0
.LL22:
	add	%g1, %o0, %o5
	ld	[%g1+%o0], %o3
	srl	%o3, 24, %o0
	cmp	%o0, %o1
	bne,a	.LL21
	add	%o4, 1, %o4
	srl	%o3, 12, %o0
	and	%o0, 4095, %o0
	cmp	%o0, %o2
	bne	.LL121
	 cmp    %g0, %o6
	be,a  .LL12
	 mov	%o5, %o3
	sub	%o6, 1, %o6
.LL121:	
	add	%o4, 1, %o4
.LL21:
	cmp	%o4, 15
	bleu,a	.LL22
	sll	%o4, 3, %o0
	mov	0, %o3
.LL12:
	retl
	mov	%o3, %o0



!unsigned int getbase(register unsigned int *mbar,register unsigned int iobase) {
!  register unsigned int conf = mbar[1];
!  return ((iobase & 0xfff00000) |
!          ((conf & 0xfff00000)>> 12)) & (((conf & 0x0000fff0) <<4) | 0xfff00000);
!  
!}
        
         
	.section	".text"
	.align 4
	.global  mkprom_iobar_getbase

mkprom_iobar_getbase:
	ld	[%o0+4], %o2
	sethi	%hi(-1048576), %o3
	and	%o1, %o3, %o1
	and	%o2, %o3, %o0
	srl	%o0, 12, %o0
	or	%o1, %o0, %o1
	sethi	%hi(64512), %o0
	or	%o0, 1008, %o0
	and	%o2, %o0, %o2
	sll	%o2, 4, %o2
	or	%o2, %o3, %o2
	and	%o1, %o2, %o1
	retl
	mov	%o1, %o0
        
