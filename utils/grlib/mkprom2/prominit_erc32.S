/************************************************************************/
/*   This file is a part of the mkprom3 boot-prom utility               */
/*   Copyright (C) 2004 Cobham Gaisler                                */
/*                                                                      */
/*   This library is free software; you can redistribute it and/or      */
/*   modify it under the terms of the GNU General Public                */
/*   License as published by the Free Software Foundation; either       */
/*   version 2 of the License, or (at your option) any later version.   */
/*                                                                      */
/*   See the file COPYING.GPL for the full details of the license.      */
/************************************************************************/

#define MEC_MCR         0x0
#define MEC_MCR_US      (0xff << 24) /* uart scalar */
#define MEC_MCR_UBR     (1 << 19)    /* uart prescalar off (1)*/
	
#define MEC_MEMCFG      0x10
#define MEC_MEMCFG_PSZ   ((0x7) << 18) /* prom size */
#define MEC_MEMCFG_RSZ   ((0x7) << 10) /* ram size */
#define MEC_MEMCFG_BANKS (0x3) /* ram banks */


	
#define MEC_GPT_COUNTER	0x088
#define MEC_GPT_RELOAD	0x088
#define MEC_GPT_SCALER	0x08C
#define MEC_TIMER_CTRL	0x098

#define MEC_UARTA	0x0E0
#define MEC_UARTB	0x0E4
#define MEC_UART_CTRL	0x0E8

#define MEC_IRQ_MASK    0x04C
#define MEC_IRQ_PENDING 0x048
  
	
#define MEC_GPICNFR	0x0A8

	.seg    "text"
	.global _prom_registers_init
	
_prom_registers_init:
	
	/* erc32 */
	set     ERC32_MEC, %g1
	set	0x0000, %g3
	st	%g3, [%g1+MEC_GPICNFR]	! erc32 clear Parallel I/O Port register
	
	/* erc32 */
	set	_memcfg1, %g2		! erc32 Load memory config register 1
	ld	[%g2], %g2
  	ld	[%g1 + MEC_MEMCFG], %g3		! 
	set	MEC_MEMCFG_PSZ | MEC_MEMCFG_RSZ | MEC_MEMCFG_BANKS, %g4
	andn	%g3, %g4, %g3
	and	%g2, %g4, %g2
	or	%g2, %g3, %g2
  	st	%g2, [%g1 + MEC_MEMCFG]
	
	set	freq, %g2		! leon2 Load timer scaler register
	ld	[%g2], %g2
	sub	%g2, 1, %g2

	/* erc32 */
	/*st	%g0, [%g1 + MEC_IRQ_MASK] 	! irq mask clear*/
	
	/* erc32 */
	st	%g2, [%g1 + MEC_GPT_SCALER]	! erc32 timer prescalar reload register 
	set	-1, %g3
	st	%g3, [%g1 + MEC_GPT_RELOAD]	! erc32 timer1 reload register
	
	set	_uart, %g2		! Load UART scaler register
	ld	[%g2], %g2
  	ld	[%g1 + MEC_MCR], %g3	! erc32 system control register 
	set	MEC_MCR_US|MEC_MCR_UBR, %g4 ! only set uart scalar and uart prescalar off
	andn	%g3, %g4, %g3
	and	%g2, %g4, %g2
	or	%g2, %g3, %g2
  	st	%g2, [%g1 + MEC_MCR]	! erc32 system control register 

	mov	%g0, %y 		! Init Y-register

 	retl
	 nop
