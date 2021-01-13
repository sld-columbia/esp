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

#if defined(__FIX_B2BST)
  #define B2BSTORE_FIX nop
#else
  #define B2BSTORE_FIX
#endif

#define PSR_INIT 0x00e0
#define WIM_INIT   2

	.seg    "text"
	.global _prom_hardreset_init, _prom_hardreset_init_ret, _prom_crt_start
	.global _clean_ram0, _clean_ram0_size, _clean_ram1, _clean_ram1_size
	.global _prom_registers_init, _prom_ft, _prom_mp, _sparcleon0

_prom_hardreset_init:
	set	_prom_crt_start, %g7
	
_prom_hardreset_init_ret:
	
	wr      %g0, PSR_INIT, %psr
	set	start, %g1
	mov     %g1, %tbr
	mov     %g0, %wim;
	
	flush
	
	clr	%g1
	clr	%g2
	clr	%g3
	clr	%g4
	clr	%g5
	clr	%g6
	clr	%l0
	clr	%l3
	
!''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
! get nwindows and leon version
			
	mov	%psr, %l3
	srl	%l3, 24, %g5
	and  	%g5, 3, %g5
	subcc	%g5, 3, %g0             ! leon2: 0 or 2, leon3:	3
	bne	1f
	 nop
	mov	%asr17, %g5		! leon3 has nwindows in %asr17
	ba	2f
1:
	set	_iserc32, %l0           ! test if erc32
	ld	[%l0], %l0
	cmp	%l0, %g0                
	bne,a	2f
	 or	%g0,7,%g5
	
	set     LEON_REG, %l0         ! leon2 on-chip register base
	ld	[%l0+0x24], %l3
	srl	%l3, 20, %g5
2:
	and	%g5, 0x1f, %g5
	add     %g5,1,%g5
	
!''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	
	mov	%g5, %g2
wl0:
	clr	%i0
	clr	%i1
	clr	%i2
	clr	%i3
	clr	%i4
	clr	%i5
	clr	%i6 
	clr	%i7
	clr	%l0
	clr	%l1
	clr	%l2
	clr	%l3
	clr	%l4
	clr	%l5
	clr	%l6
	clr	%l7
	save
	subcc	%g2, 1, %g2
	bne	wl0
	 nop

	mov	%g0, %y 		! Init Y-register

	wr	%g0, PSR_INIT, %psr
	mov     %g0, %wim;
	nop
	nop

	call	bdcpuinit0
	 nop

	
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
	bne sysini0
	 nop
	
1:
       ! -------------------------------

	call	bdinit0			! Must not use the FPU
	 nop

	set	noinit, %g2
	ld	[%g2], %g2
	subcc   %g2, %g0, %g0
	bne	sysini0
	 nop

	call	_prom_registers_init
	 nop

sysini0:

	sethi	%hi(0x1000), %g5
	or	PSR_INIT, %g5, %g3
	wr	%g0, %g3, %psr
	set	WIM_INIT, %g3
	mov	%g3, %wim

#ifdef _SOFT_FLOAT
! check if FPU is present. Always clear FPU if present. If compiled with
! hard floats, we can safely assume FPU is present.
	mov	%psr, %g3
	andcc	%g3, %g5, %g0
	beq	sysini
	 nop
#endif

! Wash FPU register file

	set	_prom_zerofp, %g1
	
	ldd	[%g1], %f0
	ldd	[%g1], %f2
	ldd	[%g1], %f4
	ldd	[%g1], %f6
	ldd	[%g1], %f8
	ldd	[%g1], %f10
	ldd	[%g1], %f12
	ldd	[%g1], %f14
	ldd	[%g1], %f16
	ldd	[%g1], %f18
	ldd	[%g1], %f20
	ldd	[%g1], %f22
	ldd	[%g1], %f24 
	ldd	[%g1], %f26
	ldd	[%g1], %f28
	ldd	[%g1], %f30
	ld	[%g1], %fsr

#ifdef _SOFT_FLOAT
! Turn off FPU when soft float. Application is responsible to turn it on.
	wr	%g0, PSR_INIT, %psr
#endif

! System init

sysini:
#ifdef DOERCTEST	
	set	_iserc32, %g5           ! test if erc32
	ld	[%g5], %g5
	cmp	%g5, %g0                
	bne,a	mastergo
	 mov	%g0,%g5
#endif
	! -------------------------------
	! only cpu 0 initializes
	mov	%psr, %g5
	srl	%g5, 24, %g5
	and  	%g5, 3, %g5
	subcc	%g5, 3, %g0             ! leon2: 0 or 2, leon3:	3
	bne,a	mastergo
	 mov	%g0,%g5
	
	rd     %asr17,%g5
	srl    %g5,28,%g5
	cmp %g5,%g0
	beq mastergo
	 nop

	! note:	 on a .text in rom mkprom image _entry is 0
	sll %g5, 2, %g5	! CPUN => index in _stack[N] and _entry[N]
	set _mp, %g6
	ld [%g6], %g6
	cmp %g6, 0
	bne sysini_entry
	 nop
	mov %g0, %g5 ! Don't use CPU Index, use the same entry point and stack for all CPUs
sysini_entry:
	set _entry,%g6                 
	ld  [%g6+%g5],%g6
	cmp %g0,%g6
	bne,a slavego
	 mov  %g6,%g7                   ! execute only if branch taken (g6 != 0)

	/* if _sparcleon0 is set it is an image that is loaded to 0 */
	set _sparcleon0,%g2
	ld  [%g2],%g2
	cmp %g0,%g2
	bne,a slavego
	 mov  %g6,%g7                   ! execute only if branch taken (g2 != 0)
	
	ba,a slavego    
	 nop
	
        ! -------------------------------
mastergo:
	call	bdinit1
	 nop
	
	set	_doedac,%l0
	ld	[%l0],%l0
	cmp	%g0,%l0
	beq	noedac
	 nop

	call	_prom_ft
	 nop

	clr	%g1
	set	_clean_ram0,%g2
	ld	[%g2],%g2
	set	_clean_ram0_size,%g3
	ld	[%g3],%g3
	cmp	%g0, %g3
	beq	2f

/*
 * Clear %g3 bytes starting at %g2
 */
	clr	%g4
.Lcleanram0:
	cmp	%g3, %g4
	be	.Lcleanram0end
	 nop
	std	%g0, [%g2 + %g4]
	ba	.Lcleanram0
	 add	%g4, 8, %g4
.Lcleanram0end:

2:		
	set	_clean_ram1,%g2
	ld	[%g2],%g2
	set	_clean_ram1_size,%g3
	ld	[%g3],%g3
	cmp	%g0, %g3
	beq	4f

/*
 * Clear %g3 bytes starting at %g2
 */
	clr	%g4
.Lcleanram1:
	cmp	%g3, %g4
	be	.Lcleanram1end
	 nop
	std	%g0, [%g2 + %g4]
	ba	.Lcleanram1
	 add	%g4, 8, %g4
.Lcleanram1end:

4:	
	
noedac:	ba,a	mastercont
         nop
	
	/* only slave execute, no ut699 check needed */
slavego:
	set	0x81000f, %g2
	sta	%g2, [%g0] 2
	
mastercont:	
	set	_stack, %g2
	ld	[%g2+%g5], %fp  ! g5 is CPU Number * 4
	andn	%fp, 0x0f, %fp
	sub	%fp, 64, %sp
	
	mov	%g7,%o7
	jmp	%o7
	 nop

	.seg    "text"
	
	.global	_prom_getpsr
  	.global _prom_window_overflow,_prom_window_overflow_svt
  	.global _prom_window_underflow,_prom_window_underflow_svt
        .global _prom_leonbare_irq_entry,_prom_leonbare_irq_entry_svt
	.global _prom_fpdis_enable,_prom_fpdis_enable_svt
	.global	_prom_flush_windows,_prom_flush_windows_svt
        .global _prom_irqcall,_prom_irqcall_svt,_prom_irqcall_disableirq,_prom_irqcall_disableirq_svt
	.global _prom_cpuinit
	.global _prom_srmmu_fault, _prom_srmmu_fault_svt

	.align 8
_prom_zerofp:
	.word 0, 0
	
_prom_getpsr:
	retl
	 mov %psr, %o0

	
        ! Window overflow trap handler on save.

_prom_window_overflow_svt:		
_prom_window_overflow:
#ifndef _FLAT
  	mov  %wim, %l3       		! Calculate next WIM
  	mov  %g1, %l7           
  	srl  %l3, 1, %g1        
	
	/* ================== */
	mov	%psr, %l4
	srl	%l4, 24, %l4
	and  	%l4, 3, %l4
	subcc	%l4, 3, %g0             ! leon2: 0 or 2, leon3:	3
	bne	1f
	 nop
	ba	2f
	 mov	%asr17, %l4		! leon3 has nwindows in %asr17
1:
	set	_iserc32, %l4           ! test if erc32
	ld	[%l4], %l4
	cmp	%l4, %g0                
	beq,a	2f
	 or	%g0,7,%l4
	
	set     LEON_REG, %l4         ! leon2 on-chip register base
	ld	[%l4+0x24], %l4
	srl	%l4, 20, %l4
2:
	and	%l4, 0x1f, %l4
	/* ================== */
	
	sll  %l3, %l4 , %l4
  	or   %l4, %g1, %g1

  	save                              ! Get into window to be saved.
  	mov  %g1, %wim
  	nop; nop; nop
        std   %l0, [%sp + 0];
        B2BSTORE_FIX
        std   %l2, [%sp + 8];
        B2BSTORE_FIX
        std   %l4, [%sp + 16]; 
        B2BSTORE_FIX
        std   %l6, [%sp + 24]; 
        B2BSTORE_FIX
        std   %i0, [%sp + 32]; 
        B2BSTORE_FIX
        std   %i2, [%sp + 40]; 
        B2BSTORE_FIX
        std   %i4, [%sp + 48]; 
        B2BSTORE_FIX
        std   %i6, [%sp + 56]; 
  	restore				! Go back to trap window.
  	mov  %l7, %g1
  	jmp  %l1			! Re-execute save.
  	rett %l2
#else	
	ta	0			! halt 
#endif
	
  /* Window underflow trap handler on restore.  */


_prom_window_underflow_svt:
_prom_window_underflow:
#ifndef _FLAT
	mov  %wim, %l3			! Calculate next WIM
	sll  %l3, 1, %l4

	/* ================== */
	mov	%psr, %l5
	srl	%l5, 24, %l5
	and  	%l5, 3, %l5
	subcc	%l5, 3, %g0             ! leon2: 0 or 2, leon3:	3
	bne	1f
	 nop
	ba	2f
	 mov	%asr17, %l5		! leon3 has nwindows in %asr17
1:
	set	_iserc32, %l5           ! test if erc32
	ld	[%l5], %l5
	cmp	%l5, %g0                
	beq,a	2f
	 or	%g0,7,%l5
	
	set     LEON_REG, %l5           ! leon2 on-chip register base
	ld	[%l5+0x24], %l5
	srl	%l5, 20, %l5
2:
	and	%l5, 0x1f, %l5
	/* ================== */
	
	srl  %l3, %l5, %l5
  	or   %l5, %l4, %l5
  	mov  %l5, %wim
  	nop; nop; nop
  	restore				! Two restores to get into the
  	restore				! window to restore
        ldd   [%sp + 0], %l0; 		! Restore window from the stack
        ldd   [%sp + 8], %l2; 
        ldd   [%sp + 16], %l4; 
        ldd   [%sp + 24], %l6; 
        ldd   [%sp + 32], %i0; 
        ldd   [%sp + 40], %i2; 
        ldd   [%sp + 48], %i4; 
        ldd   [%sp + 56], %i6; 
  	save				! Get back to the trap window.
  	save
  	jmp  %l1			! Re-execute restore.
  	rett  %l2
#else	
	ta	0			! halt 
#endif
	
_prom_leonbare_irq_entry_svt:	 /* irq from svt trap dispatcher */
_prom_leonbare_irq_entry:		
_prom_fpdis_enable_svt:
_prom_fpdis_enable:
_prom_flush_windows_svt:		
_prom_flush_windows:
_prom_srmmu_fault:
_prom_srmmu_fault_svt:	
	ta	0x0

_prom_irqcall_svt:	
_prom_irqcall:
_prom_irqcall_disableirq_svt:
_prom_irqcall_disableirq:
	jmpl	%l1,  %g0
	rett	%l2

_prom_cpuinit:
	retl
	nop

	.global	_prom_fpdis,_prom_fpdis_svt
_prom_fpdis_svt:
_prom_fpdis:
	set	0x1000, %l4
	andcc	%l0, %l4, %l3
	bne,a	4f
	andn	%l0, %l4, %l0
	ta	0
4:
	mov      %l0, %psr		! restore %psr
	nop; nop; nop
  	jmp  %l2			! Jump to nPC
  	rett  %l2 + 4

	/* ------- */
	.weak	_prom_ft
	.set	_prom_ft,_prom_ft_weak
	/* ------- */
	
_prom_ft_weak:
	retl
	 nop
	
	/* ------- */
	.weak	_prom_mp
	.set	_prom_mp,_prom_mp_weak
	/* ------- */
	
_prom_mp_weak:
	retl
	 nop


/* bdcpuinit0() is defined weak so the user can override it in bdinit.o. */
	.weak	bdcpuinit0
	.set	bdcpuinit0,_bdcpuinit0_weak
_bdcpuinit0_weak:
	retl
	 nop

