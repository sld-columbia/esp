
#include "testmod.h"

extern int privtrap;
extern volatile int privtrap_ctr;

#define ULCAST(x) ((unsigned long)(x))

/* Test privilegded instruction trap */
void privtest(void)
{
  long long lval = 0;
  unsigned long lvalp = ULCAST(&lval);
  int i;
  volatile unsigned long *t_add;
  int tmp1=0,tmp2=0;


  report_subtest(PRIV_TEST);

  /* Patch the trap table */
  t_add = (unsigned long *) ((get_tbr() & ~0xfff) | 0x30);
  t_add[0] = 0xA010000F; /* mov %o7, %l0 */
  t_add[1] = (0x40000000 | ((ULCAST(&privtrap)-ULCAST(t_add)-4) >> 2));
  t_add[2] = 0x9E100010; /* (delay slot) mov %l0, %o7 */

  privtrap_ctr = 0;

  /* Clear SU bit */
  setpsr(xgetpsr() & (~0x80));

  /* Test special instructions that should _not_ be priviledged */
  for (i=0; i<3; i++) {
    switch (i) {
    case 0: asm volatile(" stbar"); break; /* alias for rd %asr15, %g0 */
    case 1: asm volatile(" casa [%1] 0xA, %2, %0" : "+r"(tmp1) : "r"(lvalp),"r"(tmp2) ); break;
    case 2: asm volatile(" wr %g0, %asr18"); break; /* used for SMAC/UMAC instructions */
    }
    if (privtrap_ctr != 0) fail(i);
  }

  /* Test instructions that are priviledged */
  for (i=0; i<57; i++) {
    /* Re-clear SU bit as it gets re-enabled by trap handler*/
    if (i>0) setpsr(xgetpsr() & (~0x80));
    /* Try priviledged inst */
    switch (i) {
    case 0: asm volatile(" ldsba [%0] 0xA, %%l1" : : "r"(lvalp)); break;
    case 1: asm volatile(" ldsba [%0] 0xB, %%l1" : : "r"(lvalp)); break;
    case 2: asm volatile(" ldsba [%0] 0x1, %%l1" : : "r"(lvalp)); break;
    case 3: asm volatile(" ldsha [%0] 0xA, %%l1" : : "r"(lvalp)); break;
    case 4: asm volatile(" ldsha [%0] 0xB, %%l1" : : "r"(lvalp)); break;
    case 5: asm volatile(" ldsha [%0] 0x1, %%l1" : : "r"(lvalp)); break;
    case 6: asm volatile(" ldsha [%0] 0xA, %%l1" : : "r"(lvalp+1)); break;
    case 7: asm volatile(" lduba [%0] 0xA, %%l1" : : "r"(lvalp)); break;
    case 8: asm volatile(" lduba [%0] 0xB, %%l1" : : "r"(lvalp)); break;
    case 9: asm volatile(" lduba [%0] 0x1, %%l1" : : "r"(lvalp)); break;
    case 10: asm volatile(" lduha [%0] 0xA, %%l1" : : "r"(lvalp)); break;
    case 11: asm volatile(" lduha [%0] 0xB, %%l1" : : "r"(lvalp)); break;
    case 12: asm volatile(" lduha [%0] 0x1, %%l1" : : "r"(lvalp)); break;
    case 13: asm volatile(" lduha [%0] 0xA, %%l1" : : "r"(lvalp+1)); break;
    case 14: asm volatile(" lda [%0] 0xA, %%l1" : : "r"(lvalp)); break;
    case 15: asm volatile(" lda [%0] 0xB, %%l1" : : "r"(lvalp)); break;
    case 16: asm volatile(" lda [%0] 0x1, %%l1" : : "r"(lvalp)); break;
    case 17: asm volatile(" lda [%0] 0xA, %%l1" : : "r"(lvalp+1)); break;
    case 18: asm volatile(" ldda [%0] 0xA, %%l0" : : "r"(lvalp)); break;
    case 19: asm volatile(" ldda [%0] 0xB, %%l0" : : "r"(lvalp)); break;
    case 20: asm volatile(" ldda [%0] 0x1, %%l0" : : "r"(lvalp)); break;
    case 21: asm volatile(" ldda [%0] 0xA, %%l0" : : "r"(lvalp+1)); break;
    case 22: asm volatile(" ldda [%0] 0xA, %%l1" : : "r"(lvalp)); break;
    case 23: asm volatile(" stba %%l1, [%0] 0xA" : : "r"(lvalp)); break;
    case 24: asm volatile(" stba %%l1, [%0] 0xB" : : "r"(lvalp)); break;
    case 25: asm volatile(" stba %%l1, [%0] 0x1" : : "r"(lvalp)); break;
    case 26: asm volatile(" stha %%l1, [%0] 0xA" : : "r"(lvalp)); break;
    case 27: asm volatile(" stha %%l1, [%0] 0xB" : : "r"(lvalp)); break;
    case 28: asm volatile(" stha %%l1, [%0] 0x1" : : "r"(lvalp)); break;
    case 29: asm volatile(" stha %%l1, [%0] 0xA" : : "r"(lvalp+1)); break;
    case 30: asm volatile(" sta %%l1, [%0] 0xA" : : "r"(lvalp)); break;
    case 31: asm volatile(" sta %%l1, [%0] 0xB" : : "r"(lvalp)); break;
    case 32: asm volatile(" sta %%l1, [%0] 0x1" : : "r"(lvalp)); break;
    case 33: asm volatile(" sta %%l1, [%0] 0xA" : : "r"(lvalp+1)); break;
    case 34: asm volatile(" stda %%l0, [%0] 0xA" : : "r"(lvalp)); break;
    case 35: asm volatile(" stda %%l0, [%0] 0xB" : : "r"(lvalp)); break;
    case 36: asm volatile(" stda %%l0, [%0] 0x1" : : "r"(lvalp)); break;
    case 37: asm volatile(" stda %%l0, [%0] 0xA" : : "r"(lvalp+1)); break;
    case 38: asm volatile(" stda %%l1, [%0] 0xA" : : "r"(lvalp)); break;
    case 39: asm volatile(" ldstuba [%l1] 0xA, %l1"); break;
    case 40: asm volatile(" swapa [%l1] 0xA, %l1"); break;
    case 41: asm volatile(" rett"); break;
    case 42: asm volatile(" rd %psr, %g0"); break;
    case 43: asm volatile(" rd %wim, %g0"); break;
    case 44: asm volatile(" rd %tbr, %g0"); break;
    case 45: asm volatile(" wr %g0, %psr"); break;
    case 46: asm volatile(" wr %g0, %wim"); break;
    case 47: asm volatile(" wr %g0, %tbr"); break;
    case 48: asm volatile(" wr %g0, %asr24"); break;
    case 49: asm volatile(" wr %g0, %asr25"); break;
    case 50: asm volatile(" wr %g0, %asr26"); break;
    case 51: asm volatile(" wr %g0, %asr27"); break;
    case 52: asm volatile(" wr %g0, %asr28"); break;
    case 53: asm volatile(" wr %g0, %asr29"); break;
    case 54: asm volatile(" wr %g0, %asr30"); break;
    case 55: asm volatile(" wr %g0, %asr31"); break;
    case 56: asm volatile(" casa [%1] 0x1, %2, %0" : "+r"(tmp1) : "r"(lvalp),"r"(tmp2) ); break;

    }
    /* Check that the trap triggered */
    if (privtrap_ctr != i+1) fail(32+i);
  }

  /* Check that we are back in supervisor mode */
  if ((xgetpsr() & 0x80) != 0x80) fail(100);

}
