/*

    LEON2/3 LIBIO low-level routines 
    Written by Jiri Gaisler.
    Copyright (C) 2004  Cobham Gaisler AB

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

*/
/*
 * promcore_svt.s for LEON mkprom -qsvt case
 */
 
/* The traptable has to be the first code in a boot PROM. */

#define TRAP(H)  mov %psr, %l0; sethi %hi(H), %l4; jmp %l4+%lo(H); nop;
#define TRAPL(H)  mov %g0, %l0; sethi %hi(H), %l4; jmp %l4+%lo(H); nop;
#define TRAP_ENTRY(H) rd %psr, %l0; b H; rd %wim, %l3; nop;

#define WIM_INIT 2
#ifdef _SOFT_FLOAT
#define PSR_INIT 0x0e0
#else
#define PSR_INIT 0x10e0
#endif

#define NUMREGWINDOWS 8

/* Unexcpected trap will halt the processor by forcing it to error state */
#define BAD_TRAP ta 0; nop; nop; nop;

/* Software trap. Treat as BAD_TRAP */
#define SOFT_TRAP BAD_TRAP

# define TT_MASK         0xff0   // trap type mask from tbr
# define TT_SHL          4       // shift to get a tbr value

#ifndef INSIDE_VHDL_VERSION	

  .seg    "text"
#endif

  
  /* Hardware traps */
	/* svt code asumes that %g6 is never used in the code */

	
  .global _start_svt_weak
  .global cpuinit, _hardreset, _prom_hardreset_svt, _prom_hardreset_init
  .global _prom_fpdis_enable_svt,_prom_fpdis_svt,_prom_window_overflow_svt,_prom_window_underflow_svt
  .global _prom_leonbare_irq_entry_svt,_prom_irqcall_svt,_prom_flush_windows_svt,_prom_srmmu_fault_svt,_prom_irqcall_disableirq_svt

#ifndef INSIDE_VHDL_VERSION
  .global _start_svt_real, _trap_table, start
start:
_trap_table:
_start_svt_real:
#endif	
	
_start_svt_disp:	
	rd	%tbr, %l3
	rd	%psr, %l0
	! here,locals have been set up as follows:
	! %l0 = psr
	! %l1 = pc	
	! %l2 = npc
	! %l3 = tbr
	and     %l3,TT_MASK,%l3
	srl     %l3,TT_SHL,%l3
	
/*
struct get {
  int start,end,func;
};

struct get table[3] = {
  {0,1,..},
  {0,0,0},
};

int gettrap(int nr){
  struct get *p = table;
  while((p->start) || (p->end) || (p->func)) {
    if (p->start <= nr && p->end >= nr) {
      return p->func;
    }
    p++;
  }
  return 0;
}
	
$sparc-elf-gcc -S gettrap.c -o test.S -O2
*/
	
#define loc_o0 l3	
#define loc_o1 l4	
#define loc_o2 l5	
#define loc_o3 l6	
	
        sethi   %hi(trap_table), %loc_o2
        or      %loc_o2, %lo(trap_table), %loc_o2
        mov     %loc_o0, %loc_o3
        ld      [%loc_o2], %loc_o1
.LL13:
        cmp     %loc_o1, %loc_o3
.LL12:
        bg,a    .LL11
        add     %loc_o2, 12, %loc_o2
        ld      [%loc_o2+4], %loc_o0
        cmp     %loc_o0, %loc_o3
        bge,a   .LL1
        ld      [%loc_o2+8], %loc_o0
        add     %loc_o2, 12, %loc_o2
.LL11:
        ld      [%loc_o2], %loc_o0
        orcc    %loc_o0, 0, %loc_o1
        bne     .LL12
        cmp     %loc_o1, %loc_o3
        ld      [%loc_o2+4], %loc_o0
        cmp     %loc_o0, 0
        bne     .LL12
        cmp     %loc_o1, %loc_o3
        ld      [%loc_o2+8], %loc_o0
        cmp     %loc_o0, 0
        bne     .LL12
        cmp     %loc_o1, %loc_o3
	
	!not in table
	BAD_TRAP 
	
.LL1:
	jmp %loc_o0
	 nop	

! reset entry point for single vector trapping. Try enable svt 
_prom_hardreset_svt:
	mov	%psr, %l3
	srl	%l3, 24, %g5
	and  	%g5, 3, %g5
	subcc	%g5, 3, %g0             ! leon2: 0 or 2, leon3:	3
	bne	.L2
	nop
	
	mov	%asr17, %g5		! set svt
	set     1<<13,%g1
	or      %g5,%g1,%g5
	mov     %g5, %asr17
	nop;  nop; nop
	mov	%asr17,%g5 		! check svt
	andcc	%g5, %g1, %g0
	beq	.L2
	 nop

	set	_prom_hardreset_init,%l3
	jmp	%l3
         nop
	
.L2:	ta    0x0			! no svt implemented (ether leon2 or svt != 1)
        nop
	
        .global trap_table,svt_trap_table_ext,svt_trap_table_ext_end
        .section        ".rodata"
        .align 4
trap_table:
	.long 0,0,       _prom_hardreset_svt
	.long 1,1,       _prom_srmmu_fault_svt		! 01 instruction_access_exception (in mmu_asm.S)
	.long 4,4
#ifndef _SOFT_FLOAT
	.long _prom_fpdis_enable_svt				! 04 fp_disabled
#else
	.long _prom_fpdis_svt				! 04 fp_disabled
#endif
#ifndef _FLAT
	.long 5,   5,    _prom_window_overflow_svt		! 05 window_overflow
	.long 6,   6,    _prom_window_underflow_svt		! 06 window_underflow
#endif
	.long 9,9,       _prom_srmmu_fault_svt		! 09 data_access_exception (in mmu_asm.S)
	.long 0x11,0x1f, _prom_leonbare_irq_entry_svt	! 11-1f interrupt level
	.long 0x82,0x82, _prom_irqcall_svt			! 82
#ifndef _FLAT
	.long 0x83,0x83, _prom_flush_windows_svt		! 83
#endif
	.long 0x85,0x85, _prom_irqcall_disableirq_svt	! 85
svt_trap_table_ext:	
	.long   0,0,0
        .long   0,0,0
        .long   0,0,0
        .long   0,0,0
        .long   0,0,0
        .long   0,0,0
        .long   0,0,0
        .long   0,0,0
        .long   0,0,0
        .long   0,0,0
        .long   0,0,0
        .long   0,0,0
        .long   0,0,0
        .long   0,0,0
        .long   0,0,0
        .long   0,0,0
        .long   0,0,0
svt_trap_table_ext_end:		
        .long   0,0,0

