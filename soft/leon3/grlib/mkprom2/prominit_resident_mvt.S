/************************************************************************/
/*   This file is a part of the mkprom3 boot-prom utility               */
/*   Copyright (C) 2004 Cobham Gaisler AB                               */
/*                                                                      */
/*   This library is free software; you can redistribute it and/or      */
/*   modify it under the terms of the GNU General Public                */
/*   License as published by the Free Software Foundation; either       */
/*   version 2 of the License, or (at your option) any later version.   */
/*                                                                      */
/*   See the file COPYING.GPL for the full details of the license.      */
/************************************************************************/

	
/*
 * this will override the weak hardreset_custom in libgloss's locore.s
 */

/* Entry for traps which jump to a programmer-specified trap handler.  */
#ifndef _SOFT_FLOAT
#define PSR_INIT 0x10e0
#else
#define PSR_INIT 0x00e0
#endif
#define TRAPR(H)  wr %g0, PSR_INIT, %psr; mov %g0, %tbr; ba (H); mov %g0, %wim;
#define TRAP(H)  mov %psr, %l0; sethi %hi(H), %l4; jmp %l4+%lo(H); nop;

/* Unexcpected trap will halt the processor by forcing it to error state */
#define BAD_TRAP ta 0; nop; nop; nop;

/* Number of register windows */
#define NWINDOWS 	8

#define WIM_INIT   2

	
	.seg    "text"
	.global _hardreset_real, _prom_hardreset_custom_weak, _prom_hardreset_mvt, _prom_hardreset_init, _prom_crt_start, _prom_crt_start, _prom_hardreset_copydata
	.global	_hardreset_mvt /* overwrite bcc reset entry */

	
_hardreset_mvt:
	set	_prom_hardreset_copydata, %g7
	ba,a	_prom_hardreset_init_ret

_prom_hardreset_copydata:
	
	! -------------------------------
	! only cpu 0 initializes
	mov	%psr, %g5
	srl	%g5, 24, %g5
	and  	%g5, 3, %g5
	subcc	%g5, 3, %g0             ! leon2: 0 or 2, leon3:	3
	bne	1f
	nop
	
	rd     %asr17,%g5
	srl    %g5,28,%g5
	cmp %g5,%g0
	 bne 2f
	nop
	
1:

	/* copy .data to RAM */
!	set   _end, %g2
	set   _edata, %g2
	set   _sdata, %g3
	sub   %g2, %g3, %g4
	set   _endtext, %g2

/* Copy %g4 bytes from %g2 to %g3. assuming "%g4 mod 8 = 0" */
	clr	%g5
mvdata:
	cmp	%g4, %g5
	be	.Lmvdataend
	 nop
	ldd	[%g2 + %g5], %g6
	std	%g6, [%g3 + %g5]
	ba	mvdata
	 add	%g5, 8, %g5
.Lmvdataend:

2:
       ! -------------------------------
	
	ba,a	_hardreset_real
	
_prom_crt_start:
	ta	0x0
