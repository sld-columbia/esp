/* Package of macros for LEON-REX assembly in assemblers that do not
 * support it natively */

#ifndef REXMACROS_H_INCLUDED
#define REXMACROS_H_INCLUDED


/* ----------------------------------------------------------
 *  Macros for register numbers
 * ---------------------------------------------------------- */
/* Macros representing registers in reduced register set
 * - for use with R_* macros (exceptions for R_MOVAR/R_MOVRA) */
#define R4o0 0
#define R4o1 1
#define R4o2 2
#define R4o3 3
#define R4l4 4
#define R4l5 5
#define R4l6 6
#define R4l7 7
#define R4i0 8
#define R4i1 9
#define R4i2 10
#define R4i3 11
#define R4i4 12
#define R4i5 13
#define R4i6 14
#define R4i7 15

/* Macros for complementary registers for R_MOV_AR/R_MOV_RA */
#define R4Al0 0
#define R4Al1 1
#define R4Al2 2
#define R4Al3 3
#define R4Ao4 4
#define R4Ao5 5
#define R4Ao6 6
#define R4Ao7 7
#define R4Ag0 8
#define R4Ag1 9
#define R4Ag2 10
#define R4Ag3 11
#define R4Ag4 12
#define R4Ag5 13
#define R4Ag6 14
#define R4Ag7 15

/* Macros representing registers in full register set
 * (for use with SAVEREX/ADDREX macros and R_IOP/FPOP/LDOP only) */
#define R5g0 0
#define R5g1 1
#define R5g2 2
#define R5g3 3
#define R5g4 4
#define R5g5 5
#define R5g6 6
#define R5g7 7
#define R5o0 8
#define R5o1 9
#define R5o2 10
#define R5o3 11
#define R5o4 12
#define R5o5 13
#define R5o6 14
#define R5o7 15
#define R5l0 16
#define R5l1 17
#define R5l2 18
#define R5l3 19
#define R5l4 20
#define R5l5 21
#define R5l6 22
#define R5l7 23
#define R5i0 24
#define R5i1 25
#define R5i2 26
#define R5i3 27
#define R5i4 28
#define R5i5 29
#define R5i6 30
#define R5i7 31
#define R5sp R5o6

/* Reduced, complementary and full register set for FP operations */
#define R4f16 0
#define R4f17 1
#define R4f18 2
#define R4f19 3
#define R4f12 4
#define R4f13 5
#define R4f14 6
#define R4f15 7
#define R4f0  8
#define R4f1  9
#define R4f2  10
#define R4f3  11
#define R4f4  12
#define R4f5  13
#define R4f6  14
#define R4f7  15

#define R4Af8 0
#define R4Af9 1
#define R4Af10 2
#define R4Af11 3
#define R4Af20 4
#define R4Af21 5
#define R4Af22 6
#define R4Af23 7
#define R4Af24 8
#define R4Af25 9
#define R4Af26 10
#define R4Af27 11
#define R4Af28 12
#define R4Af29 13
#define R4Af30 14
#define R4Af31 15

#define R5f0 0
#define R5f1 1
#define R5f2 2
#define R5f3 3
#define R5f4 4
#define R5f5 5
#define R5f6 6
#define R5f7 7
#define R5f8 8
#define R5f9 9
#define R5f10 10
#define R5f11 11
#define R5f12 12
#define R5f13 13
#define R5f14 14
#define R5f15 15
#define R5f16 16
#define R5f17 17
#define R5f18 18
#define R5f19 19
#define R5f20 20
#define R5f21 21
#define R5f22 22
#define R5f23 23
#define R5f24 24
#define R5f25 25
#define R5f26 26
#define R5f27 27
#define R5f28 28
#define R5f29 29
#define R5f30 30
#define R5f31 31


/* -----------------------------------------------------------
 *  Macros for non-REX mode (function prologue)
 * ----------------------------------------------------------- */

#define SAVEREX(R5rs1,negimm,R5rd) .word (0x81e00000 | (R5rd << 25) | (R5rs1 << 14) | ((negimm) & 0x1fff))
#define ADDREX(R5rs1,negimm,R5rd) .word (0x80000000 | (R5rd << 25) | (R5rs1 << 14) | ((negimm) & 0x1fff))

/* Use at beginning/end of regular function, saverex %sp, <spadj>, %sp */
/* Note spadj must be <0 */
#define REX_FUNCSTART(spadj) SAVEREX(R5sp,spadj,R5sp)
/* Begins leaf function. Note by using ADDREX directly instead you may be
 * able to make use of the implicit add operation */
#define REX_FUNCSTART_LEAF ADDREX(R5g0,-1,R5g0)

/* Use after REX function to re-align if necessary */
#define REX_FUNCEND .align 4





/* -------------------------------------------------------------
 *  Macros for REX mode opcodes
 * ------------------------------------------------------------- */

/* Note on order of parameters to these macros:
 *  - If the opcode modifies a register, that is always specified as the last parameter
 *    (in the auto-incrementing load case, the reg where data is read is the last)
 *  - When storing, the "rd" register (containing store data) is specified
 *      first, as in normal SPARC assembly
 *  - Other value(s) are specified in the order in which they would be in the
 *      unpacked opcode: rs1 first, immediate/rs2 second
 */

/* Generic opcode macro used by below specific macros */
#define R_GENOP_VAL(rop,r4d,rimm,rop3,rop3l,r4s_imm5_rop4) (((rop) << 14) | ((r4d) << 10) | ((rimm) << 9) | ((rop3) << 5) | ((rop3l) << 4) | ((r4s_imm5_rop4) & 0x1F))
#define R_GENOP(rop,r4d,rimm,rop3,rop3l,r4s_imm5_rop4) .hword R_GENOP_VAL(rop,r4d,rimm,rop3,rop3l,r4s_imm5_rop4)
#define R_GENBR(cond,bsz,btype,boffs) .hword (((cond) << 10) | ((bsz) << 9) | ((btype) << 8) | (((boffs) >> 1) & 0xFF))

/* 16-bit register transfer ops */

/* r_mov %rs, %rd */
#define R_MOV(R4rs,R4rd)     R_GENOP(2,R4rd,0, 8,0,R4rs)
/* r_mov %rs, %rd  (%rs in complementary set) */
#define R_MOV_AR(R4Ars,R4rd) R_GENOP(2,R4rd,0, 8,1,R4Ars)
/* r_mov %rs, %rd  (%rd in complementary set) */
#define R_MOV_RA(R4rs,R4Ard) R_GENOP(2,R4Ard,0,9,0,R4rs)
/* r_mov %rs, %rd  (%rs,%rd in complementary set) */
#define R_MOV_AA(R4Ars,R4Ard) R_GENOP(2,R4Ard,0,9,1,R4Ars)
#define R_MOV_AA_VAL(R4Ars,R4Ard) R_GENOP_VAL(2,R4Ard,0,9,1,R4Ars)

/* Constant assignment 16/32/48-bit */

/* r_set simm5, %rd */
#define R_SET5(simm5,R4rd)   R_GENOP(2,R4rd,1, 1,0,simm5)
/* r_set simm21, %rd */
#define R_SET21(simm21,R4rd) R_GENOP(2,R4rd,1, 7,0,((simm21)&0x1F)), ((simm21) >> 5)
/* r_set imm32, %rd */
#define R_SET32(imm32,R4rd)  R_GENOP(2,R4rd,1,15,0,8), ((imm32) >> 16), ((imm32 & 0xFFFF))
/* r_one imm5, %rd */
#define R_ONE(imm5,R4rd)     R_GENOP(2,R4rd,1, 5,0,imm5)
/* r_getpc %rd */
#define R_GETPC(R4rd)        R_GENOP(2,R4rd,1,14,0,9)
/* r_set %pc+imm, %rd */
#define R_SET32PC(imm,R4rd)   R_GENOP(2,R4rd,1,15,0,9), (imm>>16), (imm & 0xFFFF)

/* 16-bit arithmetic / logical ops */

/* r_add %rs, %rd */
#define R_ADDR(R4rs,R4rd)    R_GENOP(2,R4rd,0, 0,0,R4rs)
/* r_addcc %rs, %rd */
#define R_ADDCCR(R4rs,R4rd)  R_GENOP(2,R4rd,0, 0,1,R4rs)
/* r_addcc simm5, %rd */
#define R_ADDCCI(simm5,R4rd) R_GENOP(2,R4rd,1, 0,0,simm5)
/* r_sub %rs, %rd */
#define R_SUBR(R4rs,R4rd)    R_GENOP(2,R4rd,0, 1,0,R4rs)
/* r_subcc %rs, %rd */
#define R_SUBCCR(R4rs,R4rd)  R_GENOP(2,R4rd,0, 1,1,R4rs)
/* r_cmp %rs1, %rs2 */
#define R_CMPR(R4rs1,R4rs2)  R_GENOP(2,R4rs1,0,11,1,R4rs2)
/* r_cmp %rs1, imm5 */
#define R_CMPI(R4rs1,simm5)  R_GENOP(2,R4rs1,1, 8,0,simm5)
/* r_and %rs, %rd */
#define R_ANDR(R4rs,R4rd)    R_GENOP(2,R4rd,0, 2,0,R4rs)
/* r_andcc %rs, %rd */
#define R_ANDCCR(R4rs,R4rd)  R_GENOP(2,R4rd,0, 2,1,R4rs)
/* r_or %rs, %rd */
#define R_ORR(R4rs,R4rd)     R_GENOP(2,R4rd,0, 4,0,R4rs)
/* r_orcc %rs, %rd */
#define R_ORCCR(R4rs,R4rd)   R_GENOP(2,R4rd,0, 4,1,R4rs)
/* r_xor %rs, %rd */
#define R_XORR(R4rs,R4rd)    R_GENOP(2,R4rd,0, 6,0,R4rs)
/* r_xorcc %rs, %rd */
#define R_XORCCR(R4rs,R4rd)  R_GENOP(2,R4rd,0, 6,1,R4rs)
/* r_andn %rs, %rd */
#define R_ANDNR(R4rs,R4rd)   R_GENOP(2,R4rd,0,10,0,R4rs)
/* r_andncc %rs, %rd */
#define R_ANDNCCR(R4rs,R4rd) R_GENOP(2,R4rd,0,10,1,R4rs)
/* r_orn %rs, %rd */
#define R_ORNR(R4rs,R4rd)    R_GENOP(2,R4rd,0,12,0,R4rs)
/* r_orncc %rs, %rd */
#define R_ORNCCR(R4rs,R4rd)  R_GENOP(2,R4rd,0,12,1,R4rs)
/* r_xnor %rs, %rd */
#define R_XNORR(R4rs,R4rd)   R_GENOP(2,R4rd,0,14,0,R4rs)
/* r_xnorcc %rs, %rd */
#define R_XNORCCR(R4rs,R4rd) R_GENOP(2,R4rd,0,14,1,R4rs)
/* r_sll %rs, %rd */
#define R_SLLR(R4rs,R4rd)    R_GENOP(2,R4rd,0,11,0,R4rs)
/* r_sll imm5, %rd */
#define R_SLLI(imm5,R4rd)    R_GENOP(2,R4rd,1,11,0,imm5)
/* r_srl %rs, %rd */
#define R_SRLR(R4rs,R4rd)    R_GENOP(2,R4rd,0,13,0,R4rs)
/* r_srl imm5, %rd */
#define R_SRLI(imm5,R4rd)    R_GENOP(2,R4rd,1,13,0,imm5)
/* r_neg %rd */
#define R_NEG(R4rd)          R_GENOP(2,R4rd,1,14,0,4);
#define R_NOT(R4rd)          R_GENOP(2,R4rd,1,14,0,5);
/* 16-bit bit manipulation opcodes */

/* r_masklo imm5, %rd */
#define R_MASKLO(imm5,R4rd)  R_GENOP(2,R4rd,1, 2,0,imm5)
/* r_setbit imm5, %rd */
#define R_SETBIT(imm5,R4rd)  R_GENOP(2,R4rd,1, 4,0,imm5)
/* r_clrbit imm5, %rd */
#define R_CLRBIT(imm5,R4rd)  R_GENOP(2,R4rd,1,10,0,imm5)
/* r_invbit imm5, %rd */
#define R_INVBIT(imm5,R4rd)  R_GENOP(2,R4rd,1, 6,0,imm5)
/* r_tstbit imm5, %rd */
#define R_TSTBIT(imm5,R4rd)  R_GENOP(2,R4rd,1, 3,0,imm5)

/* Control transfer */
#define R_RETREST            R_GENOP(2,   0,1,14,0,0)
#define R_RETL               R_GENOP(2,   0,1,14,0,1)
#define R_TA0                R_GENOP(2,   0,1,14,0,6)
#define R_TA1                R_GENOP(2,   1,1,14,0,6)
#define R_LEAVE              R_GENOP(2,   0,1,14,0,7)

#define R_BN(tgt)            R_GENBR(0,0,0,tgt-.)
#define R_BE(tgt)            R_GENBR(1,0,0,tgt-.)
#define R_BLE(tgt)           R_GENBR(2,0,0,tgt-.)
#define R_BL(tgt)            R_GENBR(3,0,0,tgt-.)
#define R_BLEU(tgt)          R_GENBR(4,0,0,tgt-.)
#define R_BCS(tgt)           R_GENBR(5,0,0,tgt-.)
#define R_BNEG(tgt)          R_GENBR(6,0,0,tgt-.)
#define R_BVS(tgt)           R_GENBR(7,0,0,tgt-.)
#define R_BA(tgt)            R_GENBR(8,0,0,tgt-.)
#define R_BNE(tgt)           R_GENBR(9,0,0,tgt-.)
#define R_BG(tgt)            R_GENBR(10,0,0,tgt-.)
#define R_BGE(tgt)           R_GENBR(11,0,0,tgt-.)
#define R_BGU(tgt)           R_GENBR(12,0,0,tgt-.)
#define R_BCC(tgt)           R_GENBR(13,0,0,tgt-.)
#define R_BPOS(tgt)          R_GENBR(14,0,0,tgt-.)
#define R_BVC(tgt)           R_GENBR(15,0,0,tgt-.)

#define R_BN24(tgt)          R_GENBR(0,1,0,tgt-.),((tgt-.-2) >> 9)
#define R_BE24(tgt)          R_GENBR(1,1,0,tgt-.),((tgt-.-2) >> 9)
#define R_BLE24(tgt)         R_GENBR(2,1,0,tgt-.),((tgt-.-2) >> 9)
#define R_BL24(tgt)          R_GENBR(3,1,0,tgt-.),((tgt-.-2) >> 9)
#define R_BLEU24(tgt)        R_GENBR(4,1,0,tgt-.),((tgt-.-2) >> 9)
#define R_BCS24(tgt)         R_GENBR(5,1,0,tgt-.),((tgt-.-2) >> 9)
#define R_BNEG24(tgt)        R_GENBR(6,1,0,tgt-.),((tgt-.-2) >> 9)
#define R_BVS24(tgt)         R_GENBR(7,1,0,tgt-.),((tgt-.-2) >> 9)
#define R_BA24(tgt)          R_GENBR(8,1,0,tgt-.),((tgt-.-2) >> 9)
#define R_BNE24(tgt)         R_GENBR(9,1,0,tgt-.),((tgt-.-2) >> 9)
#define R_BG24(tgt)          R_GENBR(10,1,0,tgt-.),((tgt-.-2) >> 9)
#define R_BGE24(tgt)         R_GENBR(11,1,0,tgt-.),((tgt-.-2) >> 9)
#define R_BGU24(tgt)         R_GENBR(12,1,0,tgt-.),((tgt-.-2) >> 9)
#define R_BCC24(tgt)         R_GENBR(13,1,0,tgt-.),((tgt-.-2) >> 9)
#define R_BPOS24(tgt)        R_GENBR(14,1,0,tgt-.),((tgt-.-2) >> 9)
#define R_BVC24(tgt)         R_GENBR(15,1,0,tgt-.),((tgt-.-2) >> 9)


/* Memory access */
/* r_ld [%rs], %rd */
#define R_LD(R4rs,R4rd)      R_GENOP(3,R4rd,0,0,0,R4rs)
/* r_ldinc [%rs], %rd */
#define R_LDINC(R4rs,R4rd)   R_GENOP(3,R4rd,0,0,1,R4rs)
/* r_ldf [%rs], %rd */
#define R_LDF(R4rs,R4rd)     R_GENOP(3,R4rd,0,1,0,R4rs)
/* r_ldfinc [%rs], %rd */
#define R_LDFINC(R4rs,R4rd)  R_GENOP(3,R4rd,0,1,1,R4rs)
/* r_ldub [%rs], %rd */
#define R_LDUB(R4rs,R4rd)    R_GENOP(3,R4rd,0,2,0,R4rs)
/* r_ldubinc [%rs], %rd */
#define R_LDUBINC(R4rs,R4rd) R_GENOP(3,R4rd,0,2,1,R4rs)
/* r_lduh [%rs], %rd */
#define R_LDUH(R4rs,R4rd)    R_GENOP(3,R4rd,0,4,0,R4rs)
/* r_lduhinc [%rs], %rd */
#define R_LDUHINC(R4rs,R4rd) R_GENOP(3,R4rd,0,4,1,R4rs)
/* r_ldd [%rs], %rd */
#define R_LDD(R4rs,R4rd)     R_GENOP(3,R4rd,0,6,0,R4rs)
/* r_lddinc [%rs], %rd */
#define R_LDDINC(R4rs,R4rd)  R_GENOP(3,R4rd,0,6,1,R4rs)
/* r_lddf [%rs], %rd */
#define R_LDDF(R4rs,R4rd)    R_GENOP(3,R4rd,0,5,0,R4rs)
/* r_lddfinc [%rs], %rd */
#define R_LDDFINC(R4rs,R4rd) R_GENOP(3,R4rd,0,5,1,R4rs)
/* r_ld [%fp+offs], %rd */
#define R_LDFP(offs,R4rd)    R_GENOP(3,R4rd,1,0,0,(((offs) & 0x7f) >> 2))
/* r_ldf [%fp+offs], %rd */
#define R_LDFFP(offs,R4rd)   R_GENOP(3,R4rd,1,1,0,(((offs) & 0x7f) >> 2))
/* r_ld [%sp+offs], %rd */
#define R_LDSP(offs,R4rd)    R_GENOP(3,R4rd,1,2,0,(((offs) & 0x7f) >> 2))
/* r_ldf [%sp+offs], %rd */
#define R_LDFSP(offs,R4rd)   R_GENOP(3,R4rd,1,3,0,(((offs) & 0x7f) >> 2))
/* r_ld [%i0+offs], %rd */
#define R_LDI0(offs,R4rd)    R_GENOP(3,R4rd,1,4,0,(((offs) & 0x7f) >> 2))
/* r_ldf [%i0+offs], %rd */
#define R_LDFI0(offs,R4rd)   R_GENOP(3,R4rd,1,5,0,(((offs) & 0x7f) >> 2))
/* r_ld [%o0+offs], %rd */
#define R_LDO0(offs,R4rd)    R_GENOP(3,R4rd,1,6,0,(((offs) & 0x7f) >> 2))
/* r_st %rd, [%rs] */
#define R_ST(R4rd,R4rs)      R_GENOP(3,R4rd,0,8,0,R4rs)
/* r_stinc %rd, [%rs] */
#define R_STINC(R4rd,R4rs)   R_GENOP(3,R4rd,0,8,1,R4rs)
/* r_st %rfd, [%rs] */
#define R_STF(R4rd,R4rs)     R_GENOP(3,R4rd,0,9,0,R4rs)
/* r_stfinc %rd, [%rs] */
#define R_STFINC(R4rd,R4rs)  R_GENOP(3,R4rd,0,9,1,R4rs)
/* r_stb %rd, [%rs] */
#define R_STB(R4rd,R4rs)     R_GENOP(3,R4rd,0,10,0,R4rs)
/* r_stbinc %rd, [%rs] */
#define R_STBINC(R4rd,R4rs)  R_GENOP(3,R4rd,0,10,1,R4rs)
/* r_sth %rd, [%rs] */
#define R_STH(R4rd,R4rs)     R_GENOP(3,R4rd,0,12,0,R4rs)
/* r_sthinc %rd, [%rs] */
#define R_STHINC(R4rd,R4rs)  R_GENOP(3,R4rd,0,12,1,R4rs)
/* r_std %rfd, [%rs] */
#define R_STDF(R4rd,R4rs)    R_GENOP(3,R4rd,0,13,0,R4rs)
/* r_stdinc %rfd, [%rs] */
#define R_STDFINC(R4rd,R4rs) R_GENOP(3,R4rd,0,13,1,R4rs)
/* r_std %rd, [%rs] */
#define R_STD(R4rd,R4rs)     R_GENOP(3,R4rd,0,14,0,R4rs)
/* r_stdinc %rd, [%rs] */
#define R_STDINC(R4rd,R4rs)  R_GENOP(3,R4rd,0,14,1,R4rs)
/* r_st %rd, [%fp+offs] */
#define R_STFP(R4rd,offs)    R_GENOP(3,R4rd,1,8,0,(((offs) & 0x7f) >> 2))
/* r_st %rfd, [%fp+offs] */
#define R_STFFP(R4rd,offs)   R_GENOP(3,R4rd,1,9,0,(((offs) & 0x7f) >> 2))
/* r_st %rd, [%sp+offs] */
#define R_STSP(R4rd,offs)    R_GENOP(3,R4rd,1,10,0,(((offs) & 0x7f) >> 2))
/* r_st %rfd, [%sp+offs] */
#define R_STFSP(R4rd,offs)   R_GENOP(3,R4rd,1,11,0,(((offs) & 0x7f) >> 2))
/* r_st %rd, [%i0+offs] */
#define R_STI0(R4rd,offs)    R_GENOP(3,R4rd,1,12,0,(((offs) & 0x7f) >> 2))
/* r_st %rfd, [%i0+offs] */
#define R_STFI0(R4rd,offs)   R_GENOP(3,R4rd,1,13,0,(((offs) & 0x7f) >> 2))
/* r_st %rd, [%o0+offs] */
#define R_STO0(R4rd,offs)    R_GENOP(3,R4rd,1,14,0,(((offs) & 0x7f) >> 2))
/* r_ld [imm], %rd */
#define R_LD32(imm,R4rd)     R_GENOP(2,R4rd,1,15,0,10); .word imm
#define R_LD32_VAL(R4rd)     R_GENOP_VAL(2,R4rd,1,15,0,10)
/* r_ld [%pc+imm], %rd */
#define R_LD32PC(imm,R4rd)   R_GENOP(2,R4rd,1,15,0,11), (imm>>16), (imm & 0xFFFF)
/* r_push %rd */
#define R_PUSH(R4rd)         R_GENOP(2,R4rd,1,14,0,2)
/* r_pop %rd */
#define R_POP(R4rd)          R_GENOP(2,R4rd,1,14,0,3)




/* r_IOP/r_FLOP/r_LDOP macros */
/* Relation between sparc v8 fpop,op3[0] and xfpop:
     xfpop[6]   = op3[0] | fpop[7]
     xfpop[5]   = fpop[6] & ~fpop[4]
     xfpop[4]   = ~op3[0] & (fpop[5] xor fpop[4])
     xfpop[3:0] = fpop[3:0]
*/
#define R_IOP_R(xop3,R4rs1,rs1alt,R5rs2,R4rd,rdalt) R_GENOP(2,R4rd,0,7,0,R4rs1), ( ((xop3)<<9) | ((rdalt)<<8) | ((rs1alt)<<7) | (R5rs2) )
#define R_IOP_I(xop3,R4rs1,rs1alt,simm7,R4rd,rdalt) R_GENOP(2,R4rd,0,7,0,R4rs1), ( (1<<15) | ((xop3)<<9) | ((rdalt)<<8) | ((rs1alt)<<7) | ((simm7) & 0x7F) )
#define R_FLOP(xfpop,R4rs1,rs1alt,R5rs2,R4rd,rdalt) R_GENOP(2,R4rd,0,7,1,R4rs1), ( ((xfpop)<<9) | ((rdalt)<<8) | ((rs1alt)<<7) | (R5rs2) )
#define R_LDOP_R(xop3,R4rs1,rs1alt,R5rs2,R4rd,rdalt) R_GENOP(3,R4rd,0,7,0,R4rs1), ( ((xop3)<<9) | ((rdalt)<<8) | ((rs1alt)<<7) | (R5rs2) )
#define R_LDOP_I(xop3,R4rs1,rs1alt,simm7,R4rd,rdalt) R_GENOP(3,R4rd,0,7,0,R4rs1), ( (1<<15) | ((xop3)<<9) | ((rdalt)<<8) | ((rs1alt)<<7) | ((simm7) & 0x7F) )

#define RX_ADDR(R4rs1,rs1alt,R5rs2,R4rd,rdalt) R_IOP_R(0,R4rs1,rs1alt,R5rs2,R4rd,rdalt)
#define RX_ADDI(R4rs1,rs1alt,simm7,R4rd,rdalt) R_IOP_I(0,R4rs1,rs1alt,simm7,R4rd,rdalt)

#define RX_FITOS(R4rs1,rs1alt,R4rd,R4rdalt)     R_FLOP(0x64,R4rs1,rs1alt,0,R4rd,rdalt)
#define RX_FITOD(R4rs1,rs1alt,R4rd,R4rdalt)     R_FLOP(0x68,R4rs1,rs1alt,0,R4rd,rdalt)
#define RX_FSTOI(R4rs1,rs1alt,R4rd,R4rdalt)     R_FLOP(0x51,R4rs1,rs1alt,0,R4rd,rdalt)
#define RX_FMULS(R4rs1,rs1alt,R5rs2,R4rd,rdalt) R_FLOP(0x29,R4rs1,rs1alt,R5rs2,R4rd,rdalt)

#define RX_LDUBR(R4rs1,rs1alt,R5rs2,R4rd,rdalt) R_LDOP_R(0x01,R4rs1,rs1alt,R5rs2,R4rd,rdalt)

/* ---------------------------------------------------------
 * Aliases and utility macros
 * --------------------------------------------------------- */

/* No-operation r_nop === mov %g0, %g0 */
#define R_NOP                R_MOV_AA(R4Ag0,R4Ag0)
#define R_NOP_VAL            R_MOV_AA_VAL(R4Ag0,R4Ag0)

/* Branch aliases */
#define R_B(tgt)             R_BA(tgt)
#define R_B24(tgt)           R_BA24(tgt)

/* Pad with r_nop to align to 32-bit boundary
 * Useful for use with call instruction since current assembler requires
 * it to be aligned (not required by hardware) */
#define R_ALIGN4 .balignw 4, R_NOP_VAL

#endif
