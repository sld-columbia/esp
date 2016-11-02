#include "rexmacros.h"

        .text
        .global rexfunc_none, rexfunc_nonel, rexfunc_add, rexfunc_sub
        .global rexfunc_or, rexfunc_xor, rexfunc_andn, rexfunc_orn,
        .global rexfunc_subcc_branch
        .global rexfunc_cmpr_branch, rexfunc_cmpi_branch
        .global rexfunc_addcci_branch, rexfunc_addcc_branch
        .global rexfunc_andcc_branch, rexfunc_orcc_branch
        .global rexfunc_xorcc_branch, rexfunc_andncc_branch,
        .global rexfunc_orncc_branch
        .global rexfunc_call, rexfunc_mov, get_g5
        .global get_g6, rexfunc_sllr, rexfunc_slli, rexfunc_srlr, rexfunc_srli,
        .global rexfunc_set32, rexfunc_set21, rexfunc_set21s
        .global rexfunc_one, rexfunc_setbit5
        .global rexfunc_setbit31, rexfunc_clrbit5, rexfunc_clrbit31
        .global rexfunc_tstbit5, rexfunc_tstbit31, rexfunc_invbit5,
        .global rexfunc_invbit31, rexfunc_masklo17
        .global rexfunc_ld, rexfunc_ldi0, rexfunc_ldo0, rexfunc_ldinc
        .global rexfunc_ldub, rexfunc_lduh, rexfunc_ldd
        .global rexfunc_ldfp, rexfunc_ldsp
        .global rexfunc_ldubinc, rexfunc_lduhinc, rexfunc_lddinc
        .global rexfunc_st, rexfunc_sti0, rexfunc_stinc
        .global rexfunc_stb, rexfunc_sth, rexfunc_std
        .global rexfunc_stbinc, rexfunc_sthinc, rexfunc_stdinc
        .global rexfunc_iop_addr, rexfunc_iop_addi
        .global rexfunc_flop, rexfunc_ldop_ldubr, rexfunc_getpc, rexfunc_set32pc
        .global rexfunc_ld32, rexfunc_ld32pc, rexfunc_pushpop
        .global rexfunc_neg, rexfunc_not, rexfunc_leave, rexfunc_ta0, rexfunc_ta1

        /* REX function that returns immediately */
20:
rexfunc_none:
        REX_FUNCSTART(-128)
        R_RETREST
        REX_FUNCEND

        /* REX leaf function that returns immediately */
rexfunc_nonel:
        REX_FUNCSTART_LEAF
        R_RETL
        REX_FUNCEND

        /* Returns sum of two input arguments */
rexfunc_add:
        REX_FUNCSTART_LEAF
        R_ADDR(R4o1,R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_sub:
        REX_FUNCSTART_LEAF
        R_SUBR(R4o1,R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_or:
        REX_FUNCSTART_LEAF
        R_ORR(R4o1,R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_xor:
        REX_FUNCSTART_LEAF
        R_XORR(R4o1,R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_andn:
        REX_FUNCSTART_LEAF
        R_ANDNR(R4o1,R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_orn:
        REX_FUNCSTART_LEAF
        R_ORNR(R4o1,R4o0)
        R_RETL
        REX_FUNCEND

        /* Compare two input arguments using R_SUBCC, return 4 if equal or 3
        * if non-equal */
rexfunc_subcc_branch:
        REX_FUNCSTART_LEAF
        R_SUBCCR(R4o1,R4o0)
        R_BE(1f)
        R_SET5(3,R4o0)
        R_RETL
1:      R_SET5(4,R4o0)
        R_RETL
        REX_FUNCEND

        /* Same as rexfunc_branch but using r_cmp */
rexfunc_cmpr_branch:
        REX_FUNCSTART_LEAF
        R_CMPR(R4o1,R4o0)
        R_BE(1f)
        R_SET5(3,R4o0)
        R_RETL
1:      R_SET5(4,R4o0)
        R_RETL
        REX_FUNCEND

        /* Compare input arg with 6 using r_cmp (imm), return 4 if equal else 3 */
rexfunc_cmpi_branch:
        REX_FUNCSTART_LEAF
        R_CMPI(R4o0,6)
        R_BE(1f)
        R_SET5(3,R4o0)
        R_RETL
1:      R_SET5(4,R4o0)
        R_RETL
        REX_FUNCEND

        /* Compare input arg with 6 using r_addcc (imm), return 4 if equal else 3 */
rexfunc_addcci_branch:
        REX_FUNCSTART_LEAF
        R_ADDCCI(-6,R4o0)
        R_BE(1f)
        R_SET5(3,R4o0)
        R_RETL
1:      R_SET5(4,R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_addcc_branch:
        REX_FUNCSTART_LEAF
        R_ADDCCR(R4o1,R4o0)
        R_BE(1f)
        R_SET5(3,R4o0)
        R_RETL
1:      R_SET5(4,R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_andcc_branch:
        REX_FUNCSTART_LEAF
        R_ANDCCR(R4o1,R4o0)
        R_BE(1f)
        R_SET5(3,R4o0)
        R_RETL
1:      R_SET5(4,R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_orcc_branch:
        REX_FUNCSTART_LEAF
        R_ORCCR(R4o1,R4o0)
        R_BE(1f)
        R_SET5(3,R4o0)
        R_RETL
1:      R_SET5(4,R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_xorcc_branch:
        REX_FUNCSTART_LEAF
        R_XORCCR(R4o1,R4o0)
        R_BE(1f)
        R_SET5(3,R4o0)
        R_RETL
1:      R_SET5(4,R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_andncc_branch:
        REX_FUNCSTART_LEAF
        R_ANDNCCR(R4o1,R4o0)
        R_BE(1f)
        R_SET5(3,R4o0)
        R_RETL
1:      R_SET5(4,R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_orncc_branch:
        REX_FUNCSTART_LEAF
        R_ORNCCR(R4o1,R4o0)
        R_BE(1f)
        R_SET5(3,R4o0)
        R_RETL
1:      R_SET5(4,R4o0)
        R_RETL
        REX_FUNCEND

        /* Calculates subr1(3,9)+15 == (3^9)+15 == 25 where subr1 is non-REX subr */
rexfunc_call:
        REX_FUNCSTART(-128)
        R_SET5(3,R4o0)
        R_SET5(9,R4o1)
        R_ALIGN4
        call subr1
        R_SET5(15,R4i0)
        R_ADDR(R4o0,R4i0)
        R_RETREST
        REX_FUNCEND


subr1:  retl
        xor %o0, %o1, %o0

        /* MOV test, returns second arg bounced via %g5,g6, tests both complementary/normal regs */
rexfunc_mov:
        REX_FUNCSTART_LEAF
        R_MOV_RA(R4o1,R4Ag6)
        R_MOV_AA(R4Ag6,R4Ag5)
        R_MOV_AR(R4Ag5,R4o2)
        R_MOV(R4o2,R4o0)
        R_RETL
        REX_FUNCEND

get_g5: retl
        mov %g6, %o0

get_g6: retl
        mov %g6, %o0

rexfunc_sllr:
        REX_FUNCSTART_LEAF
        R_SLLR(R4o1,R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_slli:
        REX_FUNCSTART_LEAF
        R_SLLI(18,R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_srlr:
        REX_FUNCSTART_LEAF
        R_SRLR(R4o1,R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_srli:
        REX_FUNCSTART_LEAF
        R_SRLI(18,R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_set32:
        REX_FUNCSTART_LEAF
        R_SET32(0xFEDCBA98,R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_set21:
        REX_FUNCSTART_LEAF
        R_SET21(0xFEDCB, R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_set21s:
        REX_FUNCSTART_LEAF
        R_SET21(0x1FEDCB, R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_one:
        REX_FUNCSTART_LEAF
        R_ONE(5,R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_setbit5:
        REX_FUNCSTART_LEAF
        R_SETBIT(5,R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_setbit31:
        REX_FUNCSTART_LEAF
        R_SETBIT(31,R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_clrbit5:
        REX_FUNCSTART_LEAF
        R_CLRBIT(5,R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_clrbit31:
        REX_FUNCSTART_LEAF
        R_CLRBIT(31,R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_invbit5:
        REX_FUNCSTART_LEAF
        R_INVBIT(5,R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_invbit31:
        REX_FUNCSTART_LEAF
        R_INVBIT(31,R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_tstbit5:
        REX_FUNCSTART_LEAF
        R_TSTBIT(5,R4o0)
        R_SET5(0,R4o0)
        R_BE(1f)
        R_SET5(1,R4o0)
1:      R_RETL
        REX_FUNCEND

rexfunc_tstbit31:
        REX_FUNCSTART_LEAF
        R_TSTBIT(31,R4o0)
        R_SET5(0,R4o0)
        R_BE(1f)
        R_SET5(1,R4o0)
1:      R_RETL
        REX_FUNCEND

rexfunc_masklo17:
        REX_FUNCSTART_LEAF
        R_MASKLO(17,R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_ld:
        REX_FUNCSTART_LEAF
        R_LD(R4o0,R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_ldi0:
        REX_FUNCSTART(-96)
        R_LDI0(18*4, R4i0)
        R_RETREST
        REX_FUNCEND

rexfunc_ldo0:
        REX_FUNCSTART_LEAF
        R_LDO0(18*4, R4o0)
        R_RETL
        REX_FUNCEND

        /* Make a temorary copy of fp/sp, copy arg0 into fp/sp, load, then restore fp/sp */
rexfunc_ldfp:
        REX_FUNCSTART_LEAF
        R_MOV(R4i6,R4o1)
        R_MOV(R4o0,R4i6)
        R_LDFP(18*4, R4o0)
        R_MOV(R4o1,R4i6)
        R_RETL
        REX_FUNCEND
rexfunc_ldsp:
        REX_FUNCSTART_LEAF
        R_MOV_AR(R4Ao6,R4o1)
        R_MOV_RA(R4o0,R4Ao6)
        R_LDSP(18*4, R4o0)
        R_MOV_RA(R4o1,R4Ao6)
        R_RETL
        REX_FUNCEND

rexfunc_ldinc:
        REX_FUNCSTART_LEAF
        R_LDINC(R4o0,R4l4)
        R_ST(R4l4,R4o1)
        R_RETL
        REX_FUNCEND

rexfunc_ldub:
        REX_FUNCSTART_LEAF
        R_LDUB(R4o0,R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_lduh:
        REX_FUNCSTART_LEAF
        R_LDUH(R4o0,R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_ldd:
        REX_FUNCSTART_LEAF
        R_LDD(R4o0,R4o2)
        R_STD(R4o2,R4o1)
        R_RETL
        REX_FUNCEND

rexfunc_ldubinc:
        REX_FUNCSTART_LEAF
        R_LDUBINC(R4o0,R4o2)
        R_ST(R4o2,R4o1)
        R_RETL
        REX_FUNCEND

rexfunc_lduhinc:
        REX_FUNCSTART_LEAF
        R_LDUHINC(R4o0,R4o2)
        R_ST(R4o2,R4o1)
        R_RETL
        REX_FUNCEND

rexfunc_lddinc:
        REX_FUNCSTART_LEAF
        R_LDDINC(R4o0,R4o2)
        R_STD(R4o2,R4o1)
        R_RETL
        REX_FUNCEND

rexfunc_st:
        REX_FUNCSTART_LEAF
        R_ST(R4o1,R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_stb:
        REX_FUNCSTART_LEAF
        R_STB(R4o1,R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_sth:
        REX_FUNCSTART_LEAF
        R_STH(R4o1,R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_std:
        REX_FUNCSTART_LEAF
        R_STD(R4o2,R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_sti0:
        REX_FUNCSTART(-96)
        R_STI0(R4i1, 18*4)
        R_RETREST
        REX_FUNCEND

rexfunc_stinc:
        REX_FUNCSTART_LEAF
        R_STINC(R4o1,R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_stbinc:
        REX_FUNCSTART_LEAF
        R_STBINC(R4o1,R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_sthinc:
        REX_FUNCSTART_LEAF
        R_STHINC(R4o1,R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_stdinc:
        REX_FUNCSTART_LEAF
        R_STDINC(R4o2,R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_iop_addr:
        REX_FUNCSTART_LEAF
        RX_ADDR(R4o0,0,R5o1,R4o0,0)
        R_RETL
        REX_FUNCEND

rexfunc_iop_addi:
        REX_FUNCSTART_LEAF
        RX_ADDI(R4o0,0,-64,R4o0,0)
        R_RETL
        REX_FUNCEND

rexfunc_flop:
        REX_FUNCSTART_LEAF
        R_LDFINC(R4o0,R4f0)
        R_LDFINC(R4o0,R4f1)
        RX_FMULS(R4f0,0,R5f1,R4f0,0)
        R_STFINC(R4f0,R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_ldop_ldubr:
        REX_FUNCSTART_LEAF
        RX_LDUBR(R4o0,0,R5o1,R4o0,0)
        R_RETL
        REX_FUNCEND

rexfunc_getpc:
        REX_FUNCSTART_LEAF
        R_GETPC(R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_set32pc:
        REX_FUNCSTART_LEAF
        R_SET32PC(0x12345678,R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_ld32:
        REX_FUNCSTART_LEAF
        R_LD32(10f,R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_ld32pc:
        REX_FUNCSTART_LEAF
1:      R_LD32PC((10f-1b),R4o0)
        R_RETL
        REX_FUNCEND
10:     .word 0x44556677

rexfunc_pushpop:
        REX_FUNCSTART_LEAF
        R_SET5(3,R4o1)
        R_PUSH(R4o1)
        R_SET5(4,R4o1)
        R_PUSH(R4o1)
        R_SET5(5,R4o1)
        R_PUSH(R4o1)
        R_SET5(1,R4o0)
        R_POP(R4o1)
        R_CMPI(R4o1,5)
        R_BNE(1f)
        R_POP(R4o1)
        R_CMPI(R4o1,4)
        R_BNE(1f)
        R_POP(R4o1)
        R_CMPI(R4o1,3)
        R_BNE(1f)
        R_SET5(0,R4o0)
1:      R_RETL
        REX_FUNCEND

rexfunc_neg:
        REX_FUNCSTART_LEAF
        R_NEG(R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_not:
        REX_FUNCSTART_LEAF
        R_NOT(R4o0)
        R_RETL
        REX_FUNCEND

rexfunc_leave:
        REX_FUNCSTART_LEAF
        R_NOP
        R_LEAVE
        retl
        set 54, %o0

rexfunc_ta0:
        REX_FUNCSTART_LEAF
        R_TA0
        R_RETL

rexfunc_ta1:
        REX_FUNCSTART_LEAF
        R_TA1
        R_RETL
