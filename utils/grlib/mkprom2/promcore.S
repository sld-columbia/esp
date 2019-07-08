/*
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
 * promcore.s for LEON mkprom
 */
 
/* The traptable has to be the first code in a boot PROM. */

#define TRAP(H)  mov %psr, %l0; sethi %hi(H), %l4; jmp %l4+%lo(H); nop;
#define TRAPL(H)  mov %g0, %g4; sethi %hi(H), %g4; jmp %g4+%lo(H); nop;
#define TRAP_ENTRY(H) rd %psr, %l0; b H; rd %wim, %l3; nop;
/* srmmu trap */	
#define SRMMU_TFAULT rd %psr, %l0; rd %wim, %l3; b _prom_srmmu_fault; mov 1, %l6;
#define SRMMU_DFAULT rd %psr, %l0; rd %wim, %l3; b _prom_srmmu_fault; mov 9, %l6;

#define TRAP_ENTRY_INTERRUPT(int_level) \
        mov int_level, %l7; rd %psr, %l0; b _prom_leonbare_irq_entry; rd %wim, %l3;

#define TRAP_ENTRY(H) \
        rd %psr, %l0; b H; rd %wim, %l3; nop;

#define SMALLTRAPTABLE
	
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

  .seg    "text"
  .global _prom_trap_table, cpuinit, leonbare_irq_entry, _hardreset, _prom_hardreset_mvt, _prom_hardreset_init
  .global _prom_window_overflow, _prom_window_underflow, _prom_flush_windows, _prom_fpdis_enable
  .global start
start: 
_prom_trap_table:
  TRAPL(_prom_hardreset_init);	! 00 reset trap 
  SRMMU_TFAULT			! 01 instruction_access_exception (in mmu_asm.S)
  BAD_TRAP;			! 02 illegal_instruction
  BAD_TRAP;			! 03 priveleged_instruction
#ifndef _SOFT_FLOAT
  TRAP(_prom_fpdis_enable);		! 04 fp_disabled
#else
  TRAP(_prom_fpdis);			! 04 fp_disabled
#endif		
#ifndef _FLAT
  TRAP(_prom_window_overflow);	! 05 window_overflow
  TRAP(_prom_window_underflow);	! 06 window_underflow
#else
  BAD_TRAP; BAD_TRAP;
#endif
  BAD_TRAP;			! 07 memory_address_not_aligned
  BAD_TRAP;			! 08 fp_exception
  SRMMU_DFAULT		        ! 09 data_access_exception (in mmu_asm.S)
  BAD_TRAP;			! 0A tag_overflow

#ifndef SMALLTRAPTABLE
	
  BAD_TRAP;			! 0B undefined
  BAD_TRAP;			! 0C undefined
  BAD_TRAP;			! 0D undefined
  BAD_TRAP;			! 0E undefined
  BAD_TRAP;			! 0F undefined
  BAD_TRAP;			! 10 undefined

  /* Interrupt entries */
  TRAP_ENTRY_INTERRUPT(1);		! 11 interrupt level 1
  TRAP_ENTRY_INTERRUPT(2);		! 12 interrupt level 2
  TRAP_ENTRY_INTERRUPT(3);		! 13 interrupt level 3
  TRAP_ENTRY_INTERRUPT(4);		! 14 interrupt level 4
  TRAP_ENTRY_INTERRUPT(5);		! 15 interrupt level 5
  TRAP_ENTRY_INTERRUPT(6);		! 16 interrupt level 6
  TRAP_ENTRY_INTERRUPT(7);		! 17 interrupt level 7
  TRAP_ENTRY_INTERRUPT(8);		! 18 interrupt level 8
  TRAP_ENTRY_INTERRUPT(9);		! 19 interrupt level 9
  TRAP_ENTRY_INTERRUPT(10);		! 1A interrupt level 1
  TRAP_ENTRY_INTERRUPT(11);		! 1B interrupt level 11
  TRAP_ENTRY_INTERRUPT(12);		! 1C interrupt level 12
  TRAP_ENTRY_INTERRUPT(13);		! 1D interrupt level 13
  TRAP_ENTRY_INTERRUPT(14);		! 1E interrupt level 14
  TRAP_ENTRY_INTERRUPT(15);		! 1F interrupt level 15
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 20 - 23 undefined
  BAD_TRAP;					! 24 cp_disabled
	    BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 25 - 27 undefined
  BAD_TRAP;					! 28 cp_exception
	    BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 29 - 2B undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 2C - 2F undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 30 - 33 undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 34 - 37 undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 38 - 3B undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 3C - 3F undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 40 - 43 undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 44 - 47 undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 48 - 4B undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 4C - 4F undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 50 - 53 undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 54 - 57 undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 58 - 5B undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 5C - 5F undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 60 - 63 undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 64 - 67 undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 68 - 6B undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 6C - 6F undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 70 - 73 undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 74 - 77 undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 78 - 7B undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;	! 7C - 7F undefined

  /* Software traps */
  SOFT_TRAP; SOFT_TRAP; TRAP(_prom_irqcall); 	! 80 - 82 
#ifndef _FLAT
  TRAP_ENTRY(_prom_flush_windows)			! 83
#else
  SOFT_TRAP
#endif
  SOFT_TRAP;					! 84
  TRAP(_prom_irqcall_disableirq);			! 85
  SOFT_TRAP; SOFT_TRAP;				! 86 - 87
/*
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! 88 - 8B
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! 8C - 8F
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! 90 - 93
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! 94 - 97
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! 98 - 9B
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! 9C - 9F
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! A0 - A3
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! A4 - A7
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! A8 - AB
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! AC - AF
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! B0 - B3
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! B4 - B7
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! B8 - BB
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! BC - BF
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! C0 - C3
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! C4 - C7
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! C8 - CB
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! CC - CF
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! D0 - D3
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! D4 - D7
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! D8 - DB
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! DC - DF
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! E0 - E3
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! E4 - E7
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! E8 - EB
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! EC - EF
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! F0 - F3
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! F4 - F7
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! F8 - FB 
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;	! FC - FF
*/

	
#endif

