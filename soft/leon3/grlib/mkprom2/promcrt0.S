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

	.text
	.global _prom_start, main, _end, _prom_crt_start

_prom_crt_start:		
_prom_start:

#ifndef _FLAT
	save	%sp, -64, %sp
#else
	add	%sp, -72, %sp
	st	%o7, [%sp+64]
#endif
        /* clear the bss */
 
        sethi %hi(__bss_start),%g2
        or    %g2,%lo(__bss_start),%g2  ! g2 = start of bss
        sethi %hi(_end),%g3
        or    %g3,%lo(_end),%g3         ! g3 = end of bss

	cmp	%g2,%g3
	beq	1f
	 set    _end, %o0
	st     %g0,[%o0]
1:		
        mov   %g0,%g1                   ! so std has two zeros
	sub   %g3, %g2, %g3

/*
 * Clear %g3 bytes starting at %g2
 */
	clr	%g5
zerobss:
	cmp	%g3, %g5
	be	.Lzerobssend
	 nop
	std	%g0, [%g2 + %g5]
	ba	zerobss
	 add	%g5, 8, %g5
.Lzerobssend:

	/*set    _end, %o0
	st     %g0,[%o0]
	*/
	
	call	bdinit2
	nop

	/*call _init
	nop */
        call    main
        nop
#ifndef _FLAT
	ret
	restore
#else
	ld	[%sp+64], %o7
	retl
	add	%sp, 72, %sp
#endif

        .seg    "data"
        .global .bdata
.bdata:
 



