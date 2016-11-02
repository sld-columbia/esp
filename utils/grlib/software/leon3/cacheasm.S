	.text
	.align 64
	.global _line0, , _line1, _line2, _line3
	.global line0, line1, line2, line3

_line0:
line0:
	nop; nop; nop; nop; nop; nop; retl; nop;

_line1:
line1:
	nop; nop; nop; nop; nop; nop; retl; nop;

_line2:
line2:
	nop; nop; nop; nop; nop; nop; retl; nop;

_line3:
line3:
	nop; nop; nop; nop; nop; nop; retl; nop;


	.global chkitags
chkitags:
1:
	lda	[%o0] 0xc, %o2
	subcc	%o0, %o1, %o0
	bge	1b
	or	%o2, %o3, %o3
	retl
	mov	%o3, %o0

	.global chkdtags
chkdtags:
1:
	lda	[%o0] 0xe, %o2
	subcc	%o0, %o1, %o0
	bge	1b
	or	%o2, %o3, %o3
	retl
	mov	%o3, %o0


	.global ifill
ifill:
	subcc	%o0, 4, %o0
1:

	sta	%g0, [%o0] 0xd
	subcc	%o0, 4, %o0
	sta	%g0, [%o0] 0xd
	subcc	%o0, 4, %o0
	sta	%g0, [%o0] 0xd
	subcc	%o0, 4, %o0
	sta	%g0, [%o0] 0xd
	sta	%g0, [%o0] 0xc
	subcc	%o0, 4, %o0
	bg	1b
	nop
	retl
	nop

	.global dfill
dfill:
	subcc	%o0, 4, %o0
1:

	sta	%g0, [%o0] 0xf
	subcc	%o0, 4, %o0
	sta	%g0, [%o0] 0xf
	subcc	%o0, 4, %o0
	sta	%g0, [%o0] 0xf
	subcc	%o0, 4, %o0
	sta	%g0, [%o0] 0xf
	sta	%g0, [%o0] 0xe
	subcc	%o0, 4, %o0
	bg	1b
	nop
	retl
	nop

	.global ddramtest1
ddramtest1:
	mov	%o0, %o4
	mov	%o2, %o3
1:
	subcc	%o4, 8, %o4
	bg 1b
	std	%o2, [%o4 + %o1]

	mov	%o0, %o4
1:
	subcc	%o4, 8, %o4
	bg 1b
	ldd	[%o4 + %o1], %g0

	mov	%o0, %o4
	subcc	%o4, 4, %o4
	ld	[%o4 + %o1], %o3
2:
	subcc	%o3, %o2, %g0
	bne 	6f
	subcc	%o4, 4, %o4
	bg,a 2b
	ld	[%o4 + %o1], %o3

	retl
	mov	0, %o0

6: 	mov	1, %o0

	.global ddramtest2
ddramtest2:
	mov	%o0, %o4
	mov	%o2, %o3
1:
	subcc	%o4, 8, %o4
	bg 1b
	std	%o2, [%o4 + %o1]

	mov	%o0, %o4
	subcc	%o4, 4, %o4
	ld	[%o4 + %o1], %o3
2:
	subcc	%o3, %o2, %g0
	bne 	6f
	subcc	%o4, 4, %o4
	bg,a 2b
	ld	[%o4 + %o1], %o3


	retl
	mov	0, %o0

6: 	mov	1, %o0

	.global idramtest
idramtest:
	mov	%o0, %o4	! init data ram
	subcc	%o4, 4, %o4
	sta	%o1, [%o4] 0xd
1:
	lda	[%o4] 0xd, %o5
	subcc	%o5, %o1, %g0
	bne 	6f
	subcc	%o4, 4, %o4
	bg 1b
	sta	%o1, [%o4] 0xd

	retl
	mov	0, %o0

6: 	mov	1, %o0


	.global itramtest
itramtest:
	mov	%o0, %o5	! init data ram
	subcc	%o5, %o2, %o5
	sta	%o3, [%o5] 0xc
1:
	lda	[%o5] 0xc, %o4
	xor  	%o4, %o3, %o4
	andcc	%o4, %o1, %o4
	bne 	6f
	subcc	%o5, %o2, %o5
	bg 1b
	sta	%o3, [%o5] 0xc

	retl
	mov	0, %o0

6: 	mov	1, %o0

	.global dtramtest
dtramtest:
	mov	%o0, %o5	! init data ram
	subcc	%o5, %o3, %o5
	sta	%o4, [%o1 + %o5] 0xe

1:
	lda	[%o1 + %o5] 0xe, %g2
	xor  	%g2, %o4, %g2
	andcc	%g2, %o2, %g2
	bne 	6f
	subcc	%o5, %o3, %o5
	bg 1b
	sta	%o4, [%o1 + %o5] 0xe

	retl
	mov	0, %o0

6: 	mov	1, %o0


	.data
test_data:
	.word  1

	.text
	.global bpred_test

	nop; nop
	nop
bpred_test:

	set 	test_data, %o1
	ld 	[%o1], %o2
	subcc	%o2, 1, %g0
	bne	1f
	subcc	%02, 2, %g0
	ld 	[%o1], %o2
	ld 	[%o1], %o2
	sll	%o2, 2, %o2
	ba	2f
	nop
1:
	bne,a	2f
	restore
	ld 	[%o1], %o2
2:	

	save
	mov	%psr, %o1
	wr	%o1, 0x20, %psr
	set	reta, %l1
	add	%l1, 4, %l2
	nop
	jmp	%l1
	rett	%l2
	ta 1
	ta 1
reta:
	bl,a	3f
	add	%g0, 1, %o0
	sub	%o0, 1, %o0
	sll	%o0, 1, %o0
	sll	%o0, 2, %o0
3:
	retl
	nop


	.global rsysreg
rsysreg:
	retl
	lda	[%o0] 0x2, %o0

	.global wsysreg
wsysreg:
	retl
	sta	%o1, [%o0] 0x2

	.global asmgetitag
asmgetitag:
	retl
	lda	[%o0] 0xc, %o0

	.global asmsetitag
asmsetitag:
	retl
	sta	%o1, [%o0] 0xc

	.global asmgetidata
asmgetidata:
	retl
	lda	[%o0] 0xd, %o0

	.global asmsetidata
asmsetidata:
	retl
	sta	%o1, [%o0] 0xd

	.global asmgetdtag
asmgetdtag:
	retl
	lda	[%o0] 0xe, %o0

	.global asmsetdtag
asmsetdtag:
	retl
	sta	%o1, [%o0] 0xe

	.global asmgetddata
asmgetddata:
	retl
	lda	[%o0] 0xf, %o0

	.global asmsetddata
asmsetddata:
	retl
	sta	%o1, [%o0] 0xf

	.global setudata
setudata:
	retl
	sta	%o1, [%o0] 0x0

	.global getudata
getudata:
	retl
	lda	[%o0] 0x0, %o0

	.global xgetpsr
xgetpsr:
	retl
	mov	%psr, %o0

	.global setpsr
setpsr:
	mov  %o0, %psr;
	nop;
	nop;
	nop;
	retl
	nop

	.global flushi
flushi:
	retl
	sta	%g0, [%g0] 0x10

	.global flushd
flushd:
	retl
	sta	%g0, [%g0] 0x11

    .global getdw
getdw:
    retl
    ldd [%o0], %o0

