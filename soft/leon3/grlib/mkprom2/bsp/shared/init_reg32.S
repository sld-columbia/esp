	.file	"init_reg32.c"
	.section	".text"
	.align 4
	.global init_reg32
	.type	init_reg32, #function
	.proc	016
init_reg32:
	ld	[%o1], %g1
.LL4:
	cmp	%g1, -1
	bne,a	.LL3
	 ld	[%o1+4], %g2
	jmp	%o7+8
	 nop
.LL3:
	add	%o1, 8, %o1
	st	%g2, [%g1+%o0]
	b	.LL4
	 ld	[%o1], %g1
	.size	init_reg32, .-init_reg32
	.ident	"GCC: (bcc-v2.0.2) 7.2.0"
