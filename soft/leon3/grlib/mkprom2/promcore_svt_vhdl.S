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

  .seg    "text"

  /* Hardware traps */
  /* svt code asumes that %g6 is never used in the code */
#define TT_MASK         0xff0   // trap type mask from tbr
#define TT_SHL          4       // shift to get a tbr value
#ifdef _SOFT_FLOAT
#define PSR_INIT 0x0e0
#else
#define PSR_INIT 0x10e0
#endif

  .global start, _start_svt_real
  .global _trap_table

start:
_trap_table:
_start_svt_real:
	
	/******************/
	/* initialize %tbr and %psr for vhdl simulation */
	rd	%psr, %g6
	rd	%tbr, %g7
	srl     %g7,TT_SHL,%g7
	andcc	%g7,(TT_MASK>>TT_SHL),%g0
	bne	1f
	 nop
	
	/* hardreset */
	set     PSR_INIT, %g6
	wr	%g0, %tbr
	 
1:	wr	%g6, %psr    /* restore cc */
	nop; nop; nop
	/******************/

#define INSIDE_VHDL_VERSION	
#include "promcore_svt.S"

