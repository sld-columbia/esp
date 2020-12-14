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


	.section .text
	
	/* ------- */
	.weak	bdinit0
	.set	bdinit0,__bdinit0
	/* ------- */
__bdinit0:
	retl
	nop
	
	/* ------- */
	.weak	bdinit1
	.set	bdinit1,__bdinit1
	/* ------- */
__bdinit1:
	retl
	nop
	
	.section .text
	/* ------- */
	.weak	bdinit2
	.set	bdinit2,__bdinit2
	/* ------- */
__bdinit2:
	retl
	nop

