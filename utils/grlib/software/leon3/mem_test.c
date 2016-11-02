
static inline unsigned char loadb_bp(int addr)
{
  unsigned char tmp;
  asm volatile (" lduba [%1]0x1c, %0 "
      : "=r"(tmp)
      : "r"(addr)
  );
  return tmp;
}

static inline unsigned short loadhw_bp(int addr)
{
  unsigned short tmp;
  asm volatile (" lduha [%1]0x1c, %0 "
      : "=r"(tmp)
      : "r"(addr)
  );
  return tmp;
}

static inline unsigned int loadw_bp(int addr)
{
  unsigned int tmp;
  asm volatile (" lda [%1]0x1c, %0 "
      : "=r"(tmp)
      : "r"(addr)
  );
  return tmp;
}

static inline unsigned long long loaddw_bp(int addr)
{
  unsigned long long tmp;
  asm volatile (" ldda [%1]0x1c, %0 "
      : "=r"(tmp)
      : "r"(addr)
  );
  return tmp;
}



int mem_test(void)
{
   unsigned long long i;
   unsigned char has_mmu;
   
   volatile char byteline[32];
   volatile unsigned short hwordline[16];
   volatile unsigned int wordline[8];
   volatile long long int dwordline[4];

   report_mem_test();


   has_mmu = 1; /* rsysreg(12) & 8; */

   report_subtest(1);
   /* byte writes */
   for (i = 0; i < 32; i++) {
      byteline[i] = i;
   }

   /* check result, will be read using line fetch */
   for (i = 0; i < 32; i++) {
      if (byteline[i] != i)
         fail(0);
   }

   /* check result using bypass */
   if (has_mmu) {
      for (i = 0; i < 32; i++) {
         if (loadb_bp((unsigned int)byteline+i) != i)
            fail(1);
      }
   }
 
   /* write bytes in reverse order */
   for (i = 0; i < 32; i++) {
      byteline[31-i] = i;
   }

   /* check result using bypass */
   if (has_mmu) {
      for (i = 0; i < 32; i++) {
         if (loadb_bp((unsigned int)byteline+i) != (31-i))
            fail(2);
      }
   }

   report_subtest(2);
   /* hword writes */
   for (i = 0; i < 16; i++) {
      hwordline[i] = i;
   }

   /* check result, will be read using line fetch */
   for (i = 0; i < 16; i++) {
      if (hwordline[i] != i)
         fail(3);
   }

   /* check result using bypass */
   if (has_mmu) {
      for (i = 0; i < 16; i++) {
         if (loadhw_bp((unsigned int)hwordline+i*2) != i)
            fail(4);
      }
   }

   /* write hwords in reverse order */
   for (i = 0; i < 16; i++) {
      hwordline[15-i] = (i << 8);
   }

   /* check result using bypass */
   if (has_mmu) {
      for (i = 0; i < 16; i++) {
         if (loadhw_bp((unsigned int)hwordline+i*2) != ((15-i) << 8))
            fail(5);
      }
   }

   report_subtest(3);
   /* word writes */
   for (i = 0; i < 8; i++) {
      wordline[i] = (i << 24) | (i << 16) | (i << 8) | i; 
   }

   /* check results using bypass */
   if (has_mmu) {
      for (i = 0; i < 8; i++) {
         if (loadw_bp((unsigned int)wordline+i*4) !=
             ((i << 24) | (i << 16) | (i << 8) | i))
            fail(6);
      }
   }

   report_subtest(4);
   /* dword writes */
   for (i = 0; i < 4; i++) {
      dwordline[i] = ((i << 56) | (i << 48) | (i << 40) | (i << 32) |
                      (i << 24) | (i << 16) | (i << 8) | i); 
   }

   /* check results using bypass */
   if (has_mmu) {
      for (i = 0; i < 4; i++) {
         if (loaddw_bp((unsigned int)dwordline+i*8) !=
             (((i << 56) | (i << 48) | (i << 40) | (i << 32) |
               (i << 24) | (i << 16) | (i << 8) | i)))
            fail(7);
      }
   }

   return 0;
}
