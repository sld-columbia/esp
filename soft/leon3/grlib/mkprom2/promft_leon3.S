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

#define VENDOR_GAISLER   1
#define GAISLER_APBMST   0x006
#define GAISLER_IRQMP    0x00D
#define GAISLER_DDR2SPA  0x02E
#define GAISLER_DDRSPA   0x025
#define GAISLER_SDCTRL       0x009
#define GAISLER_FTMCTRL      0x054
#define GAISLER_FTSRCTRL     0x051
#define GAISLER_APBUART      0x00c
#define GAISLER_GPTIMER      0x011
#define ESA_MCTRL            0x00f
#define VENDOR_ESA           4
		
#define LEON3_IO_AREA 0xfff00000
#define LEON3_CONF_AREA 0xff000
#define LEON3_AHB_SLAVE_CONF_AREA (1 << 11)

	.text
	.global _prom_ft, _clean_ram0, _clean_ram0_size, _clean_ram1, _clean_ram1_size, mkprom_ahbslv_scan, mkprom_apbslv_scan, mkprom_iobar_getbase

_prom_ft:
	mov	%g5, %g6
	set	_pnp, %g5
	ld	[%g5], %g5 /* default: 0xFFFFF800 */
	set	0xfffff, %o0
	andn  	%g5,%o0,%g5
	
	/* leon3 */
	mov	%o7, %g4

	set VENDOR_GAISLER, %o0
        set GAISLER_APBMST, %o1
        call mkprom_ahbslv_scan
        nop
        
        cmp %g0,%o0
        be initout
         nop
        
        ld [%o0+16],%g1
        set LEON3_IO_AREA,%o0
        and %g1,%o0,%g1            /*g1: apb base*/

        set LEON3_CONF_AREA,%o0
        or %g1,%o0,%g2             /*g2: apb conf base*/

	/*********************************************************/
 	/* ************ Gaisler FTMCTRL ctrl ************ */
	
	mov %g0,%g3
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

	ld	[%o1 + 0x08], %o0
	set	0x200, %o2		! Ram edac enable
	or	%o0, %o2, %o0
  	st	%o0, [%o1 + 0x08]

	
1:
	
	/*********************************************************/
 	/* ************ Gaisler FTSRCTRL ctrl ************ */
	
	mov %g0,%g3
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
	
	ld	[%o1 + 0x08], %o0
	set	0x200, %o2		! Ram edac enable
	or	%o0, %o2, %o0
  	st	%o0, [%o1 + 0x08]
1:
	
initout:
	mov	%g6, %g5
 	jmpl 	%g4+8, %g0
	 nop

 



