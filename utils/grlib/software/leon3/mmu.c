#include "leon3.h"
#include "testmod.h" 
#include "mmu.h" 
#ifdef LEON2
#include "leon2.h"
#endif

#define NODO_CLEAR
#define TLBNUM 8

#ifndef RAMSTART
#define RAMSTART 0x40000000
#endif

#ifndef ROMSTART
#define ROMSTART 0x00000000
#endif

extern unsigned long ctx;
extern unsigned long pg0,pm0,pt0,page0,page1,page2,pth_addr,pth_addr1;
typedef void (*functype)(void);


#define fail(err) do { } while(1);
#define report(test_case) 

void leon_flush_cache_all (void)
{

        __asm__ __volatile__(" flush ");
	/*
        __asm__ __volatile__("sta %%g0, [%%g0] %0\n\t": :
                             "i" (0x11) : "memory");
			     */


}

void leon_flush_tlb_all (void)
{
        leon_flush_cache_all();
        __asm__ __volatile__("sta %%g0, [%0] %1\n\t": :
                             "r" (0x400),
                             "i" (0x18) : "memory");
}

unsigned int mmugetpagesize(unsigned int k)
{
	int psz = 0;
	if (((k >> 24) & 0xf) >= 1 ) { /* impl version  >= 1 */
		psz = (k >> 16) & 0x3;
	}
	return psz;
}

int pgsz = 0;
unsigned int pgd_sh = 24, pgd_m = 0xff;
unsigned int pmd_sh = 18, pmd_m = 0x3f;
unsigned int pte_sh = 12, pte_m = 0x3f;
void mmu_func1();
mmu_test()
{
  ctxd_t *c0 = (ctxd_t *)&ctx;
  pgd_t *g0 = (pgd_t *)&pg0;
  pmd_t *m0 = (pmd_t *)&pm0; 
  pte_t *p0 = (pte_t *)&pt0; 
  unsigned long pteval,j,k,v;
  unsigned long paddr, vaddr, val;
  unsigned long *pthaddr = &pth_addr1;
  functype func = mmu_func1;
  int i=0;
#ifdef LEON2
  struct l2regs *lr = (struct l2regs *) 0x80000000;
#endif

#ifdef LEON2
  if (!((lr->leonconf >> MMU_CONF_BIT) & 1)) return(0);
#else
  if ((rsysreg(12) & 8) == 0) return(0);
#endif
  report_subtest(MMU_TEST);

  /*
__asm__(
  "set 0xf, %g2\n\t"
  "sta    %g2,[%g0] 2\n\t"
  "set 0x40000000 , %g1\n\t"
  "ld [%g1],%g1\n\t"
  );*/

__asm__(
	".section .data\n\t"
	".align %0\n\t"
	"ctx: .skip %1\n\t"
	".align %1\n\t"
	"pg0: .skip %1\n\t"
	".align %2\n\t"
	"pm0: .skip %2\n\t"
	".align %3\n\t"
	"pt0: .skip %3\n\t"
	".align %0\n\t"
	"page0: .skip %0\n\t"
	"page1: .skip %0\n\t"
	"page2: .skip %4\n\t"
	".text\n"
	: : "i" (PAGE_SIZE_MAX), 
	"i"(SRMMU_PGD_TABLE_SIZE) , 
	"i"(SRMMU_PMD_TABLE_SIZE) ,
	"i"(SRMMU_PTE_TABLE_SIZE) ,
      "i"((3)*PAGE_SIZE) );


 
 pgsz = mmugetpagesize(srmmu_get_mmureg());

#define PGD_IDX(v) (((v) >> pgd_sh) & pgd_m)
#define PMD_IDX(v) (((v) >> pmd_sh) & pmd_m)
#define PTE_IDX(v) (((v) >> pte_sh) & pte_m)
#define DEF_ADDR(a,b,c,d) (((((a)&pgd_m)<<pgd_sh) | (((b)&pmd_m)<<pmd_sh) | (((c)&pte_m)<<pte_sh)) | (d))
 
      switch (pgsz) {
      case 0:
	      break;
      case 1:
	      pgd_sh = 24+1;
	      pgd_m = 0x7f;
	      pmd_sh = 18+1;
	      pmd_m = 0x3f;
	      pte_sh = 12+1;
	      pte_m = 0x3f;
	      break;
      case 2:
	      pgd_sh = 24+2;
	      pgd_m = 0x3f;
	      pmd_sh = 18+2;
	      pmd_m = 0x3f;
	      pte_sh = 12+2;
	      pte_m = 0x3f;
	      break;
      case 3:
	      pgd_sh = 28;
	      pgd_m = 0x0f;
	      pmd_sh = 21;
	      pmd_m = 0x7f; /* 7 bit pmd */
	      pte_sh = 12+3;
	      pte_m = 0x3f; /* 6 bit pte */
	      break;
      }

#define REAL_PAGE_SIZE (1<<(PAGE_SHIFT+pgsz))
 
 leon_flush_cache_all ();
 leon_flush_tlb_all ();

 /* Prepare Page Table Hirarchy */
 #ifndef NODO_CLEAR
 /* use ram vhdl model that clear mem at startup to suppress this loop */ 
 for (i = 0;i<SRMMU_PTRS_PER_CTX;i++) {
   srmmu_ctxd_set(c0+i,(pgd_t *)0);
 }
 #endif /*DO_CLEAR*/
 
 /* one-on-one mapping for context 0 */
 paddr = 0;
 srmmu_ctxd_set(c0+0,(pgd_t *)g0); //ctx 0
 srmmu_ctxd_set(c0+1,(pgd_t *)g0); //ctx 1
 pteval = ((ROMSTART >> 4) | SRMMU_ET_PTE | SRMMU_EXEC);           /*ROMSTART - ROMSTART+1000000: ROM */
 srmmu_set_pte(g0+PGD_IDX(ROMSTART), pteval);
 pteval = ((0x20000000 >> 4) | SRMMU_ET_PTE | SRMMU_EXEC);  /*20000000 - 21000000: IOAREA */
 srmmu_set_pte(g0+PGD_IDX(0x20000000), pteval);
 pteval = ((RAMSTART >> 4) | SRMMU_ET_PTE | SRMMU_EXEC | SRMMU_WRITE | SRMMU_CACHE);  /*RAMSTART - RAMSTART+01000000: CRAM */
 srmmu_set_pte(g0+PGD_IDX(RAMSTART), pteval);
 pteval = ((0x70000000 >> 4) | SRMMU_ET_PTE | SRMMU_EXEC | SRMMU_WRITE | SRMMU_CACHE);  /*70000000 - 71000000: CRAM */
 srmmu_set_pte(g0+PGD_IDX(0x70000000), pteval); 

#define a_30080000 DEF_ADDR(0x3,2,0,0)
#define a_30041000 DEF_ADDR(0x3,1,1,0)
#define a_30041004 DEF_ADDR(0x3,1,1,4)
#define a_30042000 DEF_ADDR(0x3,1,2,0)
#define a_30043000 DEF_ADDR(0x3,1,3,0)
#define a_31000000 DEF_ADDR(0x3,3,0,0)
 
 /* testarea: 
  *  map RAMSTART    at 3080000 [vaddr:(0) (0x3)(2)(-)] as pmd 
  *  map page0       at 3041000 [vaddr:(0) (0x3)(1)(1)] as page SRMMU_PRIV_RDONLY
  *  map mmu_func1() at 3042000 [vaddr:(0) (0x3)(1)(2)] as page
  *  map 3043000 - 307f000 [vaddr:(0) (0x3)(1)(3)] - [vaddr:(0) (0x3)(1)(63)] as page
  * page fault test: 
  *  missing pgd at 3030000 [vaddr:(0) (0x3)(0x3)(-)]
  */
 srmmu_pgd_set(g0+0x3,m0);
 pteval = ((((unsigned long)RAMSTART) >> 4) | SRMMU_ET_PTE | SRMMU_PRIV); 
 srmmu_set_pte(m0+2, pteval);
 srmmu_set_pte(m0+3, 0);
 srmmu_pmd_set(m0+1,p0);
 srmmu_set_pte(p0+2, 0);
 pteval = ((((unsigned long)&page0) >> 4) | SRMMU_ET_PTE | SRMMU_PRIV_RDONLY); 
 srmmu_set_pte(p0+1, pteval);
 ((unsigned long *)&page0)[0] = 0;
 ((unsigned long *)&page0)[1] = 0x12345678;
 for (i = 3;i<TLBNUM+3;i++) {
       pteval = (((((unsigned long)&page2)+(((i-3)%3)*REAL_PAGE_SIZE)) >> 4) | SRMMU_ET_PTE | SRMMU_PRIV); 
       srmmu_set_pte(p0+i, pteval);
 }

 *((unsigned long **)&pth_addr) =  pthaddr;
 /* repair info for fault (RAMSTART)*/
 pthaddr[0] = (unsigned long) (m0+0x3);
 pthaddr[1] = ((RAMSTART >> 4) | SRMMU_ET_PTE | SRMMU_PRIV);  
 pthaddr[2] = 31000000;
 /* repair info for write protection fault (0x3041000) */
 pthaddr[3] = (unsigned long) (p0+1);
 pthaddr[4] = ((((unsigned long)&page0) >> 4) | SRMMU_ET_PTE | SRMMU_PRIV);
 pthaddr[5] = a_30041000;
 /* repair info for instruction page fault (0x3042000) */
 pthaddr[6] = (unsigned long) (p0+2);
 pthaddr[7] = ((((unsigned long)func) >> 4) | SRMMU_ET_PTE | SRMMU_PRIV);
 pthaddr[8] = a_30042000;
 /* repair info for priviledge protection fault (0x30041000) */
 pthaddr[9] = (unsigned long) (p0+1);
 pthaddr[10] = ((((unsigned long)&page0) >> 4) | SRMMU_ET_PTE | SRMMU_EXEC | SRMMU_WRITE);
 pthaddr[11] = a_30041000;
 
 srmmu_set_ctable_ptr((unsigned long)c0);

 /* test reg access */
 k = srmmu_get_mmureg();
 k = srmmu_get_ctable_ptr();
 srmmu_set_context(1);
 k = srmmu_get_context();
 srmmu_set_context(0);

 /* close your eyes and pray ... */
 srmmu_set_mmureg(0x00000001);
 asm(" flush "); //iflush 
// asm(" sta	%g0, [%g0] 0x11 "); //dflush



#ifndef LEON2
  if (((rsysreg(0) >> ITE_BIT) & 3) == 0) mmu_double();
#endif


 /* test reg access */
 k = srmmu_get_mmureg();
 k = srmmu_get_ctable_ptr();
 k = srmmu_get_context();

 /* do tests*/
 if ( (*((unsigned long *)a_30041000)) != 0 ||
      (*((unsigned long *)a_30041004)) != 0x12345678 ) { fail(1); }
 if ( (*((unsigned long *)a_30080000)) != (*((unsigned long *)RAMSTART))) { fail(2); }
 
 /* page faults tests*/
 val = * ((volatile unsigned long *) a_31000000 );
 /* write protection fault */
 * ((volatile unsigned long *)a_30041004) = 0x87654321;
 if ( (*((volatile unsigned long *)a_30041004)) != 0x87654321 ) { fail(3); }
 /* doubleword write */
 __asm__ __volatile__("mov %0 ,%%g1\n\t"	\
                      "set 0x12345678,%%g2\n\t"\
                      "set 0xabcdef01,%%g3\n\t"\
                      "std %%g2, [%%g1]\n\t"\
                      "std %%g2, [%%g1]\n\t": : "r" (a_30041000) :
                      "g1","g2","g3");
 if ( (*((volatile unsigned long *)a_30041000)) != 0x12345678 ||
      (*((volatile unsigned long *)a_30041004)) != 0xabcdef01) { fail(4); }
  
 for (j=a_30043000,i = 3;i<TLBNUM+3;i++,j+=REAL_PAGE_SIZE) {
       *((unsigned long *)j) = j;
#ifdef LEON2
       asm(" sta	%g0, [%g0] 0x6 "); //dflush
#else
       asm(" sta	%g0, [%g0] 0x11 "); //dflush
#endif
       if ( *((unsigned long*) (((unsigned long)&page2)+(((i-3)%3)*REAL_PAGE_SIZE))) != j ) { fail(5); }
 }
#ifdef LEON2
       asm(" sta	%g0, [%g0] 0x6 "); //dflush
#else
       asm(" sta	%g0, [%g0] 0x11 "); //dflush
#endif
 for (j=0,i = 3;i<TLBNUM+3;i++) {
       pteval = (((((unsigned long)&page2)+(((i-3)%3)*REAL_PAGE_SIZE)) >> 4) | SRMMU_ET_PTE | SRMMU_PRIV); 
       if ((*(p0+i)) & (SRMMU_DIRTY | SRMMU_REF)) j++;
       if (((*(p0+i)) & ~(SRMMU_DIRTY | SRMMU_REF))  != (pteval& ~(SRMMU_DIRTY | SRMMU_REF))) { fail(6); }
 }
 //at least one entry has to have been flushed
 if (j == 0) { fail(7);}
 

 /* instruction page fault */
 func = (functype)a_30042000;
 func();
 
 /* flush */
 srmmu_flush_whole_tlb();
#ifdef LEON2
       asm(" sta	%g0, [%g0] 0x6 "); //dflush
#else
       asm(" sta	%g0, [%g0] 0x11 "); //dflush
#endif
       
 for (j=0,i = 3;i<TLBNUM+3;i++) {
       if ((*(p0+i)) & (SRMMU_DIRTY | SRMMU_REF)) j++;
 }
 if (j != TLBNUM) { fail(8);}
  
 /* check modified & ref bit */
 if (!srmmu_pte_dirty(p0[1]) || !srmmu_pte_young(p0[1])) { fail(9); };
 if (!srmmu_pte_young(m0[2])) { fail(10); };
 if (!srmmu_pte_young(p0[2])) { fail(11); };

 /* check priviledge fault */
 __asm__ __volatile__("mov	%%psr, %%g1\n\t" \
                      "andn	%%g1, 0x0080, %%g2\n\t"  \
                      " wr      %%g2, 0x0, %%psr\n\t"\
                      "nop\n\t"\
                      "nop\n\t"\
                      "nop\n\t" \
                      : : :
                      "g1");
 // supervisor = 0 
 val = * ((volatile unsigned long *)a_30041004);
 __asm__ __volatile__("set 0x4,%o1\n\t" \
		      "ta 0x2\n\t" \
                      "nop\n\t" );
 
#ifndef LEON2
 if (((rsysreg(0) >> ITE_BIT) & 3) == 0) mmu_double();
#endif
 // supervisor = 1 
 {
   //check ctx field
   unsigned long a;
   srmmu_set_context(0);
   a = *(unsigned long *)RAMSTART;
   srmmu_set_context(1);
   a = *(unsigned long *)RAMSTART;
   srmmu_set_context(0);
   a = *(unsigned long *)RAMSTART;
 }
 {
   //bypass asi:
   unsigned int i;
   i = leon_load_bp(RAMSTART);
   leon_store_bp(RAMSTART,i);
 }
 //mmu off
 srmmu_set_mmureg_aligned(0x00000000);
 
 asm("flush");
 return(0);
 {
   int i = 0;
   while (1) {
     i++;
   }
 };
 
 
}


