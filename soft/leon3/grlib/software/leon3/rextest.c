#include "testmod.h"

void rexfunc_none(void);
void rexfunc_nonel(void);
int rexfunc_add(int x, int y);
int rexfunc_sub(int x, int y);
int rexfunc_or(int x, int y);
int rexfunc_xor(int x, int y);
int rexfunc_andn(int x, int y);
int rexfunc_orn(int x, int y);
int rexfunc_subcc_branch(int x, int y);
int rexfunc_cmpr_branch(int x, int y);
int rexfunc_cmpi_branch(int x);
int rexfunc_addcci_branch(int x);
int rexfunc_addcc_branch(int x, int y);
int rexfunc_andcc_branch(int x, int y);
int rexfunc_orcc_branch(int x, int y);
int rexfunc_xorcc_branch(int x, int y);
int rexfunc_andncc_branch(int x, int y);
int rexfunc_orncc_branch(int x, int y);
int rexfunc_call(void);
int rexfunc_mov(int dummy, int x);
int get_g5(void);
int get_g6(void);
int rexfunc_slli(int x);
int rexfunc_srli(int x);
int rexfunc_set32(void);
int rexfunc_set21(void);
int rexfunc_set21s(void);
int rexfunc_one(void);
int rexfunc_setbit31(int x);
int rexfunc_setbit5(int x);
int rexfunc_clrbit31(int x);
int rexfunc_clrbit5(int x);
int rexfunc_tstbit31(int x);
int rexfunc_tstbit5(int x);
int rexfunc_masklo17(int x);
int rexfunc_ld(int *p);
int rexfunc_ldi0(int *p);
int rexfunc_ldo0(int *p);
int rexfunc_ldfp(int *p);
int rexfunc_ldsp(int *p);
int *rexfunc_ldinc(int *p, int *o);
char *rexfunc_ldubinc(char *p, int *o);
char *rexfunc_lduhinc(char *p, int *o);
int *rexfunc_lddinc(int *p, long long *o);
int rexfunc_ldub(char *p);
int rexfunc_lduh(char *p);
int *rexfunc_ldd(int *p, long long *o);
void rexfunc_st(int *p, int x);
void rexfunc_sti0(int *p, int x);
int *rexfunc_stinc(int *p, int x);
void rexfunc_stb(char *p, int x);
void rexfunc_sth(char *p, int x);
long long *rexfunc_std(long long *p, int dummy, int v0, int v1);
char *rexfunc_stbinc(char *p, int x);
char *rexfunc_sthinc(char *p, int x);
long long *rexfunc_stdinc(long long *p, int dummy, int v0, int v1);
int rexfunc_getpc(void);
int rexfunc_pushpop(void);
void rexfunc_ta0(void);
void rexfunc_ta1(void);

static char __attribute__ ((aligned (8))) arr[128];

static inline int chkfpu(void)
{
        unsigned long tmp;
        asm volatile ("  mov %%asr17, %0\n" : "=r"(tmp));
        return ((tmp >> 10) & 3);
}

static inline int chkrex(void)
{
        unsigned long tmp;
        asm volatile ("  mov %%asr17, %0\n" : "=r"(tmp));
        return ((tmp >> 21) & 15);
}

static inline void setrex(int mode)
{
        unsigned long tmp;
        asm volatile ("  mov %%asr17, %0\n": "=r"(tmp));
        tmp &= ~(3 << 21);
        tmp |= (mode << 21);
        asm volatile ("  mov %0, %%asr17\n"
                      "  nop\n"
                      "  nop\n"
                      "  nop\n": : "r"(tmp));
}



void rextest(void)
{
  int i,j;
  long long l;
  int a[3];
  if (chkrex() == 0) return;
  report_subtest(REX_TEST);
  setrex(0);
  /* Basic enter/leave REX mode */
  rexfunc_none();
  rexfunc_nonel();
  /* Arithmetic, branches, calls */
  if (rexfunc_add(3,5)!=8) fail(1);
  if (rexfunc_sub(3,5)!=-2) fail(2);
  if (rexfunc_or(3,5)!=7) fail(3);
  if (rexfunc_xor(3,5)!=6) fail(4);
  if (rexfunc_andn(3,5)!=2) fail(5);
  if (rexfunc_orn(3,5)!=(~4)) fail(6);
  if (rexfunc_subcc_branch(10,10) != 4) fail(7);
  if (rexfunc_subcc_branch(10,11) != 3) fail(8);
  if (rexfunc_cmpr_branch(10,10) != 4) fail(9);
  if (rexfunc_cmpr_branch(10,11) != 3) fail(10);
  if (rexfunc_cmpi_branch(5) != 3) fail(11);
  if (rexfunc_cmpi_branch(6) != 4) fail(12);
  if (rexfunc_addcci_branch(5) != 3) fail(13);
  if (rexfunc_addcci_branch(6) != 4) fail(14);
  if (rexfunc_addcc_branch(10,-10) != 4) fail(15);
  if (rexfunc_addcc_branch(10,-11) != 3) fail(16);
  if (rexfunc_andcc_branch(10,0) != 4) fail(17);
  if (rexfunc_andcc_branch(10,11) != 3) fail(18);
  if (rexfunc_orcc_branch(0,0) != 4) fail(19);
  if (rexfunc_orcc_branch(10,11) != 3) fail(20);
  if (rexfunc_xorcc_branch(10,10) != 4) fail(21);
  if (rexfunc_xorcc_branch(10,11) != 3) fail(22);
  if (rexfunc_andncc_branch(10,10) != 4) fail(23);
  if (rexfunc_andncc_branch(10,9) != 3) fail(24);
  if (rexfunc_orncc_branch(0,-1) != 4) fail(25);
  if (rexfunc_orncc_branch(10,11) != 3) fail(26);
  if (rexfunc_call() != ((3^9)+15)) fail(27);
  if (rexfunc_mov(0,31) != 31 || get_g5()!=31 || get_g6()!=31) fail(28);
  if (rexfunc_slli(45) != (45 << 18)) fail(29);
  if (rexfunc_srli(56 << 18) != 56) fail(30);
  if (rexfunc_set32() != 0xFEDCBA98) fail(31);
  if (rexfunc_set21() != 0x000FEDCB) fail(32);
  if (rexfunc_set21s() != 0xFFFFEDCB) fail(33);
  if (rexfunc_one() != (1<<5)) fail(34);
  if (rexfunc_setbit31(4) != 0x80000004 || rexfunc_setbit5(4) != 0x00000024) fail(35);
  if (rexfunc_clrbit5(0xffffffff) != 0xffffffdf || rexfunc_clrbit31(0xffffffff) != 0x7fffffff) fail(36);
  if (rexfunc_tstbit5(0x20) != 1 || rexfunc_tstbit5(~0x20) != 0 ||
      rexfunc_tstbit31(0x80000000) != 1 || rexfunc_tstbit31(0x7fffffff) != 0) fail(37);
  if (rexfunc_invbit5(0xffff) != 0xffdf || rexfunc_invbit31(0xffff) != 0x8000ffff) fail(38);
  if (rexfunc_masklo17(-1) != 0x3ffff) fail(39);
  /* Load/store */
  for (i=0; i<sizeof(arr); i++) arr[i]=i;
  if (rexfunc_ld((int *)arr) != 0x00010203) fail(40);
  if (rexfunc_ldi0((int *)arr) != 0x48494A4B) fail(41);
  if (rexfunc_ldo0((int *)arr) != 0x48494A4B) fail(42);
  if (rexfunc_ldfp((int *)arr) != 0x48494A4B) fail(43);
  if (rexfunc_ldsp((int *)arr) != 0x48494A4B) fail(44);
  if (rexfunc_ldinc((int *)arr, &j) != (int *)(arr+4) || j!=0x00010203) fail(45);
  if (rexfunc_ldub(arr+1) != 0x01) fail(46);
  if (rexfunc_lduh(arr+2) != 0x0203) fail(47);
  if (rexfunc_ldd((int *)arr,&l) != (int *)arr || l!=0x0001020304050607LL) fail(48);
  if (rexfunc_ldubinc(arr+1, &j) != (arr+2) || j != 0x01) fail(49);
  if (rexfunc_lduhinc(arr+2, &j) != (arr+4) || j != 0x0203) fail(50);
  if (rexfunc_lddinc((int *)arr,&l) != (int *)(arr+8) || l!=0x0001020304050607LL) fail(51);
  rexfunc_st((int *)arr, 54);
  if (arr[3] != 54) fail(52);
  rexfunc_sti0((int *)arr, 73);
  if (arr[18*4+3] != 73) fail(53);
  if (rexfunc_stinc((int *)arr,13) != (int *)(arr+4) || arr[3]!=13) fail(54);
  rexfunc_stb((char *)arr+1, 10);
  if (arr[1] != 10) fail(55);
  rexfunc_sth((char *)arr+2, 0x7766);
  if (arr[2] != 0x77 || arr[3] != 0x66) fail(56);
  if (rexfunc_std(&l,0,0x12233445,0x56677889) != &l) fail(57);
  if (l != 0x1223344556677889LL) fail(58);
  if (rexfunc_stbinc((char *)arr+1, 25) != arr+2) fail(59);
  if (arr[1] != 25) fail(60);
  if (rexfunc_sthinc((char *)arr+2, 0x3211) != arr+4) fail(61);
  if (arr[2] != 0x32 || arr[3] != 0x11) fail(62);
  if (rexfunc_stdinc(&l,0,0x44443333,0x22221111) != ((&l)+1)) fail(63);
  if (l != 0x4444333322221111LL) fail(64);
  /* r_IOP */
  if (rexfunc_iop_addr(13,24) != 37) fail(65);
  if (rexfunc_iop_addi(13) != -51) fail(66);
  arr[43] = 0x26;
  if (rexfunc_ldop_ldubr(43,&arr) != 0x26) fail(67);
  /* r_FLOP */
  if (chkfpu() != 0) {
    a[0] = 0x3E800000; /* 0.25 */
    a[1] = 0xBF000000; /* -0.5 */
    a[2] = ~0;
    rexfunc_flop(a);
    if (a[2] != 0xBE000000) fail(68);
  }
  /* Misc */
  if (rexfunc_getpc() != ((int)(&rexfunc_getpc))+4) fail(69);
  if (rexfunc_set32pc() != ((int)(&rexfunc_set32pc))+4+0x12345678) fail(70);
  if (rexfunc_ld32() != 0x44556677) fail(71);
  if (rexfunc_ld32pc() != 0x44556677) fail(72);
  if (rexfunc_pushpop() != 0) fail(73);
  if (rexfunc_neg(472) != -472) fail(74);
  if (rexfunc_not(23) != ~23) fail(75);
  if (rexfunc_leave() != 54) fail(76);
  /* rexfunc_ta0(); */
  /* rexfunc_ta1(); */
}
